/*
 * Copyright (c) 2026 Zhao Zhili <quinkblack@foxmail.com>
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

extern "C" {
#include "config.h"

#include "libavutil/avstring.h"
#include "libavutil/detection_bbox.h"
#include "libavutil/hwcontext.h"
#include "libavutil/pixdesc.h"
#if CONFIG_CUDA
#include "compat/cuda/dynlink_loader.h"  /* Must be before hwcontext_cuda.h to define CUDA_VERSION */
#include "libavutil/cuda_check.h"
#include "libavutil/hwcontext_cuda.h"
#include "libavutil/hwcontext_cuda_internal.h"
#endif
#include "libavutil/mem.h"
#include "libavutil/opt.h"

#include "avfilter.h"
#include "filters.h"
#include "formats.h"
#define class clazz
#include "framesync.h"
#undef class
#include "video.h"
}

/* C++ headers must be outside extern "C" block */
#if CONFIG_CUDA
#include <opencv2/core/cuda_stream_accessor.hpp>
#endif

#ifdef _WIN32
#include "compat/w32dlfcn.h"
#else
#include <dlfcn.h>
#endif

#include <memory>
#include <new>  /* For placement new */
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core/cuda.hpp>
#include <vector>

#include "quink_oc_plugin.h"

#define OC_PLUGIN_MAX_INPUTS  8
#define OC_PLUGIN_MAX_OUTPUTS 8

static AVPixelFormat default_fmts[] = {
    AV_PIX_FMT_BGR24, AV_PIX_FMT_BGRA, AV_PIX_FMT_NONE
};

static const struct PixFmtMap {
    enum AVPixelFormat av_fmt;
    int cv_type;
    float hscale;
    quink::QPixelFormat pix_fmt;
} pix_fmt_map[] = {
    {AV_PIX_FMT_BGR24,  CV_8UC3, 1.0f, quink::QPixelFormat::BGR},
    {AV_PIX_FMT_BGRA,   CV_8UC4, 1.0f, quink::QPixelFormat::BGRA},
    {AV_PIX_FMT_NV12,   CV_8UC1, 1.5f, quink::QPixelFormat::NV12},
    {AV_PIX_FMT_P010,   CV_16UC1, 1.5f, quink::QPixelFormat::P016},
    {AV_PIX_FMT_P016,   CV_16UC1, 1.5f, quink::QPixelFormat::P016},
    {AV_PIX_FMT_NONE, -1, 1},
};

static const PixFmtMap *mapFromAvFmt(enum AVPixelFormat fmt)
{
    for (int i = 0; pix_fmt_map[i].av_fmt != AV_PIX_FMT_NONE; i++) {
        if (pix_fmt_map[i].av_fmt == fmt)
            return &pix_fmt_map[i];
    }

    return nullptr;
}

static AVPixelFormat mapToAvFmt(quink::QPixelFormat pix_fmt)
{
    for (int i = 0; pix_fmt_map[i].av_fmt != AV_PIX_FMT_NONE; i++) {
        if (pix_fmt_map[i].pix_fmt == pix_fmt)
            return pix_fmt_map[i].av_fmt;
    }

    return AV_PIX_FMT_NONE;
}

static int mapToCvType(enum AVPixelFormat fmt)
{
    for (int i = 0; pix_fmt_map[i].av_fmt != AV_PIX_FMT_NONE; i++) {
        if (pix_fmt_map[i].av_fmt == fmt)
            return pix_fmt_map[i].cv_type;
    }
    return -1;
}

/**
 * Custom cv::MatAllocator that ties Mat lifetime to AVFrame refcount.
 * This enables zero-copy wrapping of AVFrame data into cv::Mat.
 */
class AVFrameMatAllocator : public cv::MatAllocator {
public:
    static cv::UMatData* createUMatData(AVFrame* frame) {
        if (!frame || !frame->data[0])
            return nullptr;

        AVFrame* ref_frame = av_frame_clone(frame);
        if (!ref_frame)
            return nullptr;

        cv::UMatData* u = new cv::UMatData(getInstance());
        u->data = u->origdata = ref_frame->data[0];
        u->size = static_cast<size_t>(ref_frame->linesize[0]) * ref_frame->height;
        u->userdata = ref_frame;
        u->flags |= cv::UMatData::USER_ALLOCATED;
        return u;
    }

    static AVFrameMatAllocator* getInstance() {
        static AVFrameMatAllocator instance;
        return &instance;
    }

    cv::UMatData* allocate(int dims, const int* sizes, int type,
                           void* data, size_t* step, cv::AccessFlag flags,
                           cv::UMatUsageFlags usageFlags) const override {
        (void)dims; (void)sizes; (void)type; (void)data;
        (void)step; (void)flags; (void)usageFlags;
        return nullptr;
    }

    bool allocate(cv::UMatData* u, cv::AccessFlag accessFlags,
                  cv::UMatUsageFlags usageFlags) const override {
        (void)u; (void)accessFlags; (void)usageFlags;
        return false;
    }

    void deallocate(cv::UMatData* u) const override {
        if (!u)
            return;
        if (u->userdata) {
            AVFrame* frame = static_cast<AVFrame*>(u->userdata);
            av_frame_free(&frame);
            u->userdata = nullptr;
        }
        u->data = u->origdata = nullptr;
        delete u;
    }
};

#if CONFIG_CUDA
/**
 * Wrap a CUDA AVFrame into a cv::cuda::GpuMat (zero-copy view).
 *
 * If tie_refcount is true, the returned GpuMat holds a reference to the
 * AVFrame via a custom allocator, keeping the CUDA buffer alive as long
 * as any copy of the GpuMat exists.  Used for INPUT frames so that
 * plugins can safely save a reference (e.g., for zero-copy pass-through).
 *
 * If tie_refcount is false, the returned GpuMat is a lightweight view
 * with no ownership semantics.  Used for OUTPUT frames whose underlying
 * AVFrame will be sent downstream immediately after process() returns.
 * The plugin must NOT save a reference to such a GpuMat.
 */
static cv::cuda::GpuMat wrapCudaFrame(AVFrame *frame, bool tie_refcount);

/**
 * Custom GpuMat allocator that ties GpuMat lifetime to AVFrame refcount.
 * Only used internally by wrapCudaFrame(frame, true).
 */
class AVFrameGpuMatAllocator : public cv::cuda::GpuMat::Allocator {
public:
    static AVFrameGpuMatAllocator* getInstance() {
        static AVFrameGpuMatAllocator instance;
        return &instance;
    }

    bool allocate(cv::cuda::GpuMat* mat, int rows, int cols, size_t elemSize) override {
        (void)mat; (void)rows; (void)cols; (void)elemSize;
        return false;
    }

    void free(cv::cuda::GpuMat* mat) override {
        RefData* ref_data = reinterpret_cast<RefData*>(mat->refcount);
        av_frame_free(&ref_data->frame);
        delete ref_data;
    }

    struct RefData {
        int refcount;
        AVFrame* frame;
    };
};

static cv::cuda::GpuMat wrapCudaFrame(AVFrame *frame, bool tie_refcount) {
    if (!frame || frame->format != AV_PIX_FMT_CUDA || !frame->data[0])
        return cv::cuda::GpuMat();

    AVHWFramesContext *hw_frames_ctx =
        reinterpret_cast<AVHWFramesContext *>(frame->hw_frames_ctx->data);
    AVPixelFormat sw_format = hw_frames_ctx->sw_format;
    auto pix_info = mapFromAvFmt(sw_format);
    int cv_type = pix_info->cv_type;

    int height = frame->height;
    int width = frame->width;
    size_t step = static_cast<size_t>(frame->linesize[0]);
    height *= pix_info->hscale;

    cv::cuda::GpuMat mat(height, width, cv_type, frame->data[0], step);

    if (tie_refcount) {
        AVFrame *ref_frame = av_frame_clone(frame);
        if (!ref_frame)
            return cv::cuda::GpuMat();

        auto *ref_data = new AVFrameGpuMatAllocator::RefData{1, ref_frame};
        mat.allocator = AVFrameGpuMatAllocator::getInstance();
        mat.refcount = &ref_data->refcount;
    }

    return mat;
}

class PushPopCudaCtx {
public:
    PushPopCudaCtx(void *log_ctx, AVCUDADeviceContext *cuda_hwctx) : cuda_hwctx_(cuda_hwctx) {
        CudaFunctions *cu = cuda_hwctx_->internal->cuda_dl;
        int ret = cu->cuCtxPushCurrent(cuda_hwctx_->cuda_ctx);
        if (ret != CUDA_SUCCESS) {
            av_log(log_ctx, AV_LOG_ERROR, "Failed to push cuda context %d\n", ret);
            throw std::runtime_error("Failed to push cuda context");
        }
    }

    ~PushPopCudaCtx() {
        CUcontext dummy;
        CudaFunctions *cu = cuda_hwctx_->internal->cuda_dl;
        cu->cuCtxPopCurrent(&dummy);
    }

private:
    AVCUDADeviceContext *cuda_hwctx_ = nullptr;
};
#endif /* CONFIG_CUDA */

/*===========================================================================
 * Utility functions
 *===========================================================================*/

static cv::Mat wrapFrame(AVFrame *frame, bool tie_refcount) {
    int cv_type = mapToCvType(static_cast<enum AVPixelFormat>(frame->format));
    if (cv_type < 0 || !frame || !frame->data[0])
        return cv::Mat();

    if (tie_refcount) {
        cv::UMatData* u = AVFrameMatAllocator::createUMatData(frame);
        if (!u)
            return cv::Mat();

        cv::Mat mat(frame->height, frame->width, cv_type,
                    frame->data[0], static_cast<size_t>(frame->linesize[0]));
        mat.u = u;
        mat.addref();
        return mat;
    } else {
        return cv::Mat(frame->height, frame->width, cv_type,
                       frame->data[0], static_cast<size_t>(frame->linesize[0]));
    }
}

static void freeFrames(std::vector<AVFrame*> &frames, int count) {
    for (int i = 0; i < count; i++)
        av_frame_free(&frames[i]);
}

static int outputFrames(AVFilterContext *ctx, std::vector<AVFrame*> &frames, int nb_outputs) {
    for (int i = 0; i < nb_outputs; i++) {
        int ret = ff_filter_frame(ctx->outputs[i], frames[i]);
        if (ret < 0)
            return ret;
    }
    return 0;
}

/*===========================================================================
 * FrameHandler: Abstract base class for frame processing strategies
 *
 * Each plugin type (CPU Process, CUDA Process, Detect) has its own handler.
 * This separates processing logic from the main context management.
 *===========================================================================*/

class FrameHandler {
public:
    virtual ~FrameHandler() = default;

    /**
     * Process a single input frame (1:1 or 1:N mode).
     */
    virtual int processFrame(AVFilterLink *inlink, AVFrame *in) = 0;

    /**
     * Process multiple input frames (N:1 mode via framesync).
     */
    virtual int processFrameMulti(FFFrameSync *fs, AVFrame **inputs) = 0;

    /**
     * Flush buffered frames at end of stream.
     */
    virtual int flush() = 0;

    /**
     * Plugin-specific part of configure() - called after common config.
     * Default: do nothing (plugins that need special config override this).
     */
    virtual int configurePipeline() { return 0; }

    int64_t lastPts() const { return last_pts_; }
    bool isFlushing() const { return flushing_; }

protected:
    AVFilterContext *ctx_ = nullptr;
    int nb_inputs_ = 0;
    int nb_outputs_ = 0;
    std::vector<quink::FrameConfig> *out_configs_ = nullptr;
    int64_t last_pts_ = 0;
    bool flushing_ = false;
};

/*===========================================================================
 * CpuFrameHandler: CPU cv::Mat processing
 *===========================================================================*/

class CpuFrameHandler : public FrameHandler {
public:
    CpuFrameHandler(AVFilterContext *ctx, quink::ProcessPlugin *plugin,
                    int nb_inputs, int nb_outputs,
                    std::vector<quink::FrameConfig> *out_configs) {
        ctx_ = ctx;
        plugin_ = plugin;
        nb_inputs_ = nb_inputs;
        nb_outputs_ = nb_outputs;
        out_configs_ = out_configs;
    }

    int processFrame(AVFilterLink *inlink, AVFrame *in) override {
        (void)inlink;
        std::vector<AVFrame*> out_frames(nb_outputs_);
        std::vector<cv::Mat> input_mats(nb_inputs_);
        std::vector<cv::Mat> output_mats(nb_outputs_);

        for (int i = 0; i < nb_outputs_; i++) {
            out_frames[i] = allocOutputFrame(i, in->pts);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                av_frame_free(&in);
                return AVERROR(ENOMEM);
            }
            av_frame_copy_props(out_frames[i], in);
        }

        std::vector<uint8_t*> original_out_ptrs(nb_outputs_);
        for (int i = 0; i < nb_outputs_; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        input_mats[0] = wrapFrame(in, true);
        if (input_mats[0].empty()) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input frame\n");
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        for (int i = 0; i < nb_outputs_; i++) {
            output_mats[i] = wrapFrame(out_frames[i], false);
            if (output_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap output %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                av_frame_free(&in);
                return AVERROR(EINVAL);
            }
        }

        quink::ProcessResult result = plugin_->process(input_mats, output_mats);

        if (result == quink::ProcessResult::Error) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin processing failed\n");
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return AVERROR_EXTERNAL;
        }

        if (result == quink::ProcessResult::TryAgain) {
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return 0;
        }

        int ret = handleOutputReassignment(out_frames, original_out_ptrs,
                                           input_mats, output_mats, in);
        av_frame_free(&in);

        if (ret < 0) {
            freeFrames(out_frames, nb_outputs_);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(ctx_, out_frames, nb_outputs_);
    }

    int processFrameMulti(FFFrameSync *fs, AVFrame **inputs) override {
        std::vector<AVFrame*> out_frames(nb_outputs_);
        std::vector<cv::Mat> input_mats(nb_inputs_);
        std::vector<cv::Mat> output_mats(nb_outputs_);

        for (int i = 0; i < nb_outputs_; i++) {
            int64_t pts = av_rescale_q(fs->pts, fs->time_base, ctx_->outputs[i]->time_base);
            out_frames[i] = allocOutputFrame(i, pts);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                return AVERROR(ENOMEM);
            }
            av_frame_copy_props(out_frames[i], inputs[0]);
            out_frames[i]->pts = pts;
        }

        std::vector<uint8_t*> original_out_ptrs(nb_outputs_);
        for (int i = 0; i < nb_outputs_; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        for (int i = 0; i < nb_inputs_; i++) {
            input_mats[i] = wrapFrame(inputs[i], true);
            if (input_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                return AVERROR(EINVAL);
            }
        }

        for (int i = 0; i < nb_outputs_; i++) {
            output_mats[i] = wrapFrame(out_frames[i], false);
            if (output_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap output %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                return AVERROR(EINVAL);
            }
        }

        quink::ProcessResult result = plugin_->process(input_mats, output_mats);

        if (result == quink::ProcessResult::Error) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin processing failed\n");
            freeFrames(out_frames, nb_outputs_);
            return AVERROR_EXTERNAL;
        }

        if (result == quink::ProcessResult::TryAgain) {
            freeFrames(out_frames, nb_outputs_);
            return 0;
        }

        int ret = handleOutputReassignment(out_frames, original_out_ptrs,
                                           input_mats, output_mats, inputs[0]);

        if (ret < 0) {
            freeFrames(out_frames, nb_outputs_);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(ctx_, out_frames, nb_outputs_);
    }

    int flush() override {
        flushing_ = true;
        std::vector<AVFrame*> out_frames(nb_outputs_);

        while (true) {
            std::vector<cv::Mat> output_mats(nb_outputs_);

            for (int i = 0; i < nb_outputs_; i++) {
                out_frames[i] = allocOutputFrame(i, last_pts_);
                if (!out_frames[i]) {
                    freeFrames(out_frames, i);
                    flushing_ = false;
                    return AVERROR(ENOMEM);
                }
                output_mats[i] = wrapFrame(out_frames[i], false);
                if (output_mats[i].empty()) {
                    freeFrames(out_frames, i + 1);
                    flushing_ = false;
                    return AVERROR(EINVAL);
                }
            }

            bool has_frame = plugin_->flush(output_mats);

            if (!has_frame) {
                freeFrames(out_frames, nb_outputs_);
                break;
            }

            last_pts_++;
            int ret = outputFrames(ctx_, out_frames, nb_outputs_);
            if (ret < 0) {
                flushing_ = false;
                return ret;
            }
        }

        flushing_ = false;
        return 0;
    }

private:
    quink::ProcessPlugin *plugin_;

    AVFrame* allocOutputFrame(int idx, int64_t pts) {
        AVFilterLink *outlink = ctx_->outputs[idx];
        AVFrame *out = ff_get_video_buffer(outlink,
                                           (*out_configs_)[idx].width,
                                           (*out_configs_)[idx].height);
        if (out) out->pts = pts;
        return out;
    }

    static AVFrame* findInputFrameByData(uint8_t *data,
                                          const std::vector<cv::Mat> &input_mats,
                                          int nb_inputs,
                                          AVFrame *single_input) {
        if (single_input && data == single_input->data[0])
            return single_input;

        for (int i = 0; i < nb_inputs; i++) {
            if (!input_mats[i].empty() && input_mats[i].data == data) {
                if (input_mats[i].u && input_mats[i].u->userdata)
                    return static_cast<AVFrame*>(input_mats[i].u->userdata);
            }
        }
        return nullptr;
    }

    int handleOutputReassignment(std::vector<AVFrame*> &out_frames,
                                  const std::vector<uint8_t*> &original_out_ptrs,
                                  const std::vector<cv::Mat> &input_mats,
                                  const std::vector<cv::Mat> &output_mats,
                                  AVFrame *ref_input) {
        for (int i = 0; i < nb_outputs_; i++) {
            uint8_t *current_data = output_mats[i].data;
            uint8_t *original_data = original_out_ptrs[i];

            if (current_data == original_data)
                continue;

            AVFrame *input_frame = findInputFrameByData(
                current_data, input_mats, nb_inputs_, ref_input);
            if (input_frame) {
                av_log(ctx_, AV_LOG_DEBUG,
                       "Output %d: zero-copy pass-through from input\n", i);
                av_frame_free(&out_frames[i]);
                out_frames[i] = av_frame_clone(input_frame);
                if (!out_frames[i]) {
                    av_log(ctx_, AV_LOG_ERROR,
                           "Failed to clone input frame for pass-through\n");
                    return AVERROR(ENOMEM);
                }
                continue;
            }

            av_log(ctx_, AV_LOG_ERROR,
                   "Output %d: illegal Mat reassignment detected. "
                   "Plugin must either write directly to output buffer (e.g., copyTo) "
                   "or use zero-copy pass-through (output = input). "
                   "Using clone() or create() is not allowed.\n", i);
            return AVERROR(EINVAL);
        }
        return 0;
    }
};

#if CONFIG_CUDA
/*===========================================================================
 * CudaFrameHandler: CUDA cv::cuda::GpuMat processing
 *===========================================================================*/

class CudaFrameHandler : public FrameHandler {
public:
    CudaFrameHandler(AVFilterContext *ctx, quink::CudaProcessPlugin *plugin,
                     int nb_inputs, int nb_outputs,
                     std::vector<quink::FrameConfig> *out_configs) {
        ctx_ = ctx;
        plugin_ = plugin;
        nb_inputs_ = nb_inputs;
        nb_outputs_ = nb_outputs;
        out_configs_ = out_configs;
    }

    int configurePipeline() override {
        AVFilterLink *link = ctx_->inputs[0];
        FilterLink *inl = ff_filter_link(link);
        auto in_frames_ctx =
            reinterpret_cast<AVHWFramesContext *>(inl->hw_frames_ctx->data);
        AVBufferRef *dev = in_frames_ctx->device_ref;
        cuda_hwctx_ = static_cast<AVCUDADeviceContext *>(in_frames_ctx->device_ctx->hwctx);
        cuda_stream_ = cv::cuda::StreamAccessor::wrapStream(
            static_cast<cudaStream_t>(cuda_hwctx_->stream));

        for (int i = 0; i < nb_outputs_; i++) {
            AVFilterLink *out = ctx_->outputs[i];
            FilterLink *out_fl = ff_filter_link(out);
            AVPixelFormat sw_format = mapToAvFmt((*out_configs_)[i].pix_fmt);
            if (sw_format == AV_PIX_FMT_NONE) {
                av_log(ctx_, AV_LOG_ERROR, "Invalid pix fmt %d in out config index %d\n",
                    static_cast<int>((*out_configs_)[i].pix_fmt), i);
                return AVERROR(EINVAL);
            }

            AVBufferRef *out_ref = av_hwframe_ctx_alloc(dev);
            auto out_frames_ctx =
                reinterpret_cast<AVHWFramesContext *>(out_ref->data);
            out_frames_ctx->format = AV_PIX_FMT_CUDA;
            out_frames_ctx->sw_format = sw_format;
            out_frames_ctx->width = (*out_configs_)[i].width;
            out_frames_ctx->height = (*out_configs_)[i].height;
            int ret = av_hwframe_ctx_init(out_ref);
            if (ret < 0) {
                av_buffer_unref(&out_ref);
                return ret;
            }

            out_fl->hw_frames_ctx = out_ref;
            if (sw_format == AV_PIX_FMT_BGR24 || sw_format == AV_PIX_FMT_BGRA) {
                out->color_range = AVCOL_RANGE_JPEG;
                out->colorspace = AVCOL_SPC_RGB;
            }
        }

        return 0;
    }

    int processFrame(AVFilterLink *inlink, AVFrame *in) override {
        (void)inlink;

        if (in->format != AV_PIX_FMT_CUDA) {
            av_log(ctx_, AV_LOG_ERROR, "CUDA plugin requires CUDA frames, got format %d\n", in->format);
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        std::vector<AVFrame*> out_frames(nb_outputs_);

        for (int i = 0; i < nb_outputs_; i++) {
            AVFilterLink *outlink = ctx_->outputs[i];
            out_frames[i] = ff_get_video_buffer(outlink, (*out_configs_)[i].width, (*out_configs_)[i].height);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                av_frame_free(&in);
                return AVERROR(ENOMEM);
            }
            out_frames[i]->pts = in->pts;
            av_frame_copy_props(out_frames[i], in);
            out_frames[i]->colorspace = outlink->colorspace;
            out_frames[i]->color_range = outlink->color_range;
        }

        std::vector<cv::cuda::GpuMat> input_gpu_mats(nb_inputs_);
        std::vector<cv::cuda::GpuMat> output_gpu_mats(nb_outputs_);

        input_gpu_mats[0] = wrapCudaFrame(in, true);
        if (input_gpu_mats[0].empty()) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input CUDA frame\n");
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        for (int i = 0; i < nb_outputs_; i++) {
            output_gpu_mats[i] = wrapCudaFrame(out_frames[i], false);
            if (output_gpu_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap output CUDA frame %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                av_frame_free(&in);
                return AVERROR(EINVAL);
            }
        }

        std::vector<uint8_t*> original_out_ptrs(nb_outputs_);
        for (int i = 0; i < nb_outputs_; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        quink::ProcessResult result;
        {
            PushPopCudaCtx push_pop(ctx_, cuda_hwctx_);
            result = plugin_->process(input_gpu_mats, output_gpu_mats, cuda_stream_);
        }

        if (result == quink::ProcessResult::Error) {
            av_log(ctx_, AV_LOG_ERROR, "CUDA plugin processing failed\n");
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return AVERROR_EXTERNAL;
        }

        if (result == quink::ProcessResult::TryAgain) {
            freeFrames(out_frames, nb_outputs_);
            av_frame_free(&in);
            return 0;
        }

        int ret = checkGpuOutputIntegrity(original_out_ptrs, output_gpu_mats);
        av_frame_free(&in);

        if (ret < 0) {
            freeFrames(out_frames, nb_outputs_);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(ctx_, out_frames, nb_outputs_);
    }

    int processFrameMulti(FFFrameSync *fs, AVFrame **inputs) override {
        std::vector<AVFrame*> out_frames(nb_outputs_);

        for (int i = 0; i < nb_outputs_; i++) {
            AVFilterLink *outlink = ctx_->outputs[i];
            int64_t pts = av_rescale_q(fs->pts, fs->time_base, outlink->time_base);
            out_frames[i] = ff_get_video_buffer(outlink, (*out_configs_)[i].width, (*out_configs_)[i].height);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                return AVERROR(ENOMEM);
            }
            av_frame_copy_props(out_frames[i], inputs[0]);
            out_frames[i]->pts = pts;
            out_frames[i]->colorspace = outlink->colorspace;
            out_frames[i]->color_range = outlink->color_range;
        }

        std::vector<cv::cuda::GpuMat> input_gpu_mats(nb_inputs_);
        std::vector<cv::cuda::GpuMat> output_gpu_mats(nb_outputs_);

        for (int i = 0; i < nb_inputs_; i++) {
            if (inputs[i]->format != AV_PIX_FMT_CUDA) {
                av_log(ctx_, AV_LOG_ERROR,
                       "CUDA plugin requires CUDA frames for input %d, got format %d\n",
                       i, inputs[i]->format);
                freeFrames(out_frames, nb_outputs_);
                return AVERROR(EINVAL);
            }
            input_gpu_mats[i] = wrapCudaFrame(inputs[i], true);
            if (input_gpu_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap CUDA input %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                return AVERROR(EINVAL);
            }
        }

        for (int i = 0; i < nb_outputs_; i++) {
            output_gpu_mats[i] = wrapCudaFrame(out_frames[i], false);
            if (output_gpu_mats[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap CUDA output %d\n", i);
                freeFrames(out_frames, nb_outputs_);
                return AVERROR(EINVAL);
            }
        }

        std::vector<uint8_t*> original_out_ptrs(nb_outputs_);
        for (int i = 0; i < nb_outputs_; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        quink::ProcessResult result;
        {
            PushPopCudaCtx push_pop(ctx_, cuda_hwctx_);
            result = plugin_->process(input_gpu_mats, output_gpu_mats, cuda_stream_);
        }

        if (result == quink::ProcessResult::Error) {
            av_log(ctx_, AV_LOG_ERROR, "CUDA plugin multi-input processing failed\n");
            freeFrames(out_frames, nb_outputs_);
            return AVERROR_EXTERNAL;
        }

        if (result == quink::ProcessResult::TryAgain) {
            freeFrames(out_frames, nb_outputs_);
            return 0;
        }

        int ret = checkGpuOutputIntegrity(original_out_ptrs, output_gpu_mats);
        if (ret < 0) {
            freeFrames(out_frames, nb_outputs_);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(ctx_, out_frames, nb_outputs_);
    }

    int flush() override {
        flushing_ = true;
        std::vector<AVFrame*> out_frames(nb_outputs_);

        while (true) {
            std::vector<cv::cuda::GpuMat> output_gpu_mats(nb_outputs_);

            for (int i = 0; i < nb_outputs_; i++) {
                AVFilterLink *outlink = ctx_->outputs[i];
                out_frames[i] = ff_get_video_buffer(outlink, (*out_configs_)[i].width, (*out_configs_)[i].height);
                if (!out_frames[i]) {
                    freeFrames(out_frames, i);
                    flushing_ = false;
                    return AVERROR(ENOMEM);
                }
                out_frames[i]->pts = last_pts_;
            }

            for (int i = 0; i < nb_outputs_; i++) {
                output_gpu_mats[i] = wrapCudaFrame(out_frames[i], false);
                if (output_gpu_mats[i].empty()) {
                    freeFrames(out_frames, nb_outputs_);
                    flushing_ = false;
                    return AVERROR(EINVAL);
                }
            }

            bool has_frame;
            {
                PushPopCudaCtx push_pop(ctx_, cuda_hwctx_);
                has_frame = plugin_->flush(output_gpu_mats, cuda_stream_);
            }

            if (!has_frame) {
                freeFrames(out_frames, nb_outputs_);
                break;
            }

            last_pts_++;
            int ret = outputFrames(ctx_, out_frames, nb_outputs_);
            if (ret < 0) {
                flushing_ = false;
                return ret;
            }
        }

        flushing_ = false;
        return 0;
    }

private:
    quink::CudaProcessPlugin *plugin_;
    AVCUDADeviceContext *cuda_hwctx_ = nullptr;
    cv::cuda::Stream cuda_stream_;


    /**
     * Check that plugin did not reassign output GpuMat pointers.
     *
     * Unlike CPU cv::Mat where pass-through (output = input) is allowed,
     * CUDA GpuMat pass-through is NOT supported because each AVFrame's
     * GPU buffer is tied to its own hw_frames_ctx pool.  Swapping
     * hw_frames_ctx is invalid, and implicit memcpy is too magical.
     *
     * Plugins must explicitly copy data: input.copyTo(output, stream).
     */
    int checkGpuOutputIntegrity(
            const std::vector<uint8_t*> &original_out_ptrs,
            const std::vector<cv::cuda::GpuMat> &output_gpu_mats) {
        for (int i = 0; i < nb_outputs_; i++) {
            if (output_gpu_mats[i].data != original_out_ptrs[i]) {
                av_log(ctx_, AV_LOG_ERROR,
                       "CUDA output %d: GpuMat reassignment detected. "
                       "Pass-through (output = input) is not supported for CUDA plugins. "
                       "Use input.copyTo(output, stream) instead.\n", i);
                return AVERROR(EINVAL);
            }
        }
        return 0;
    }
};
#endif /* CONFIG_CUDA */

/*===========================================================================
 * DetectFrameHandler: Detection plugin processing
 *===========================================================================*/

class DetectFrameHandler : public FrameHandler {
public:
    DetectFrameHandler(AVFilterContext *ctx, quink::DetectPlugin *plugin,
                       const QuinkOCPluginDescriptor *descriptor,
                       int nb_inputs, int nb_outputs,
                       std::vector<quink::FrameConfig> *out_configs) {
        ctx_ = ctx;
        plugin_ = plugin;
        descriptor_ = descriptor;
        nb_inputs_ = nb_inputs;
        nb_outputs_ = nb_outputs;
        out_configs_ = out_configs;
    }

    int processFrame(AVFilterLink *inlink, AVFrame *in) override {
        (void)inlink;

        cv::Mat input_mat = wrapFrame(in, true);
        if (input_mat.empty()) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input frame for detection\n");
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        frame_queue_.push_back(in);

        cv::Mat output_mat;
        detections_.clear();
        quink::ProcessResult result = plugin_->detect(input_mat, output_mat, detections_);

        if (result == quink::ProcessResult::Error) {
            av_log(ctx_, AV_LOG_ERROR, "Detection failed for frame pts %" PRId64 "\n", in->pts);
            for (auto *f : frame_queue_)
                av_frame_free(&f);
            frame_queue_.clear();
            return AVERROR_EXTERNAL;
        }

        if (result == quink::ProcessResult::TryAgain) {
            av_log(ctx_, AV_LOG_DEBUG, "Detection buffering frame pts %" PRId64 "\n", in->pts);
            return 0;
        }

        return outputDetectFrame(output_mat, in);
    }

    int processFrameMulti(FFFrameSync *, AVFrame **) override {
        av_log(ctx_, AV_LOG_ERROR, "DETECT plugins don't support multi-input mode\n");
        return AVERROR(EINVAL);
    }

    int flush() override {
        flushing_ = true;

        while (true) {
            cv::Mat output_mat;
            detections_.clear();

            bool has_frame = plugin_->flushDetect(output_mat, detections_);
            if (!has_frame)
                break;

            int ret = outputDetectFrame(output_mat, nullptr);
            if (ret < 0) {
                flushing_ = false;
                return ret;
            }
        }

        for (auto *f : frame_queue_)
            av_frame_free(&f);
        frame_queue_.clear();

        flushing_ = false;
        return 0;
    }

private:
    quink::DetectPlugin *plugin_;
    const QuinkOCPluginDescriptor *descriptor_;
    quink::Detections detections_;
    std::vector<AVFrame*> frame_queue_;

    int outputDetectFrame(const cv::Mat &output_mat, AVFrame *fallback_frame) {
        AVFrame *out_frame = nullptr;

        if (!output_mat.empty()) {
            for (auto it = frame_queue_.begin(); it != frame_queue_.end(); ++it) {
                AVFrame *f = *it;
                if (f && f->data[0] == output_mat.data) {
                    out_frame = f;
                    frame_queue_.erase(it);
                    break;
                }
            }
        }

        if (!out_frame) {
            if (fallback_frame) {
                for (auto it = frame_queue_.begin(); it != frame_queue_.end(); ++it) {
                    if (*it == fallback_frame) {
                        frame_queue_.erase(it);
                        break;
                    }
                }
                out_frame = fallback_frame;
            } else if (!frame_queue_.empty()) {
                out_frame = frame_queue_.front();
                frame_queue_.erase(frame_queue_.begin());
            } else {
                av_log(ctx_, AV_LOG_ERROR, "No frame available for detection output\n");
                return AVERROR(EINVAL);
            }
        }

        if (!detections_.empty()) {
            int ret = attachDetectionSideData(out_frame);
            if (ret < 0) {
                av_frame_free(&out_frame);
                return ret;
            }
        }

        last_pts_ = out_frame->pts;

        for (int i = 0; i < nb_outputs_; i++) {
            AVFrame *out = (i == nb_outputs_ - 1) ? out_frame : av_frame_clone(out_frame);
            if (!out) {
                av_frame_free(&out_frame);
                return AVERROR(ENOMEM);
            }
            int ret = ff_filter_frame(ctx_->outputs[i], out);
            if (ret < 0)
                return ret;
        }
        return 0;
    }

    int attachDetectionSideData(AVFrame *frame) {
        AVDetectionBBoxHeader *header = av_detection_bbox_create_side_data(
            frame, static_cast<uint32_t>(detections_.size()));
        if (!header) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to allocate detection bbox side data\n");
            return AVERROR(ENOMEM);
        }

        if (descriptor_ && descriptor_->name)
            snprintf(header->source, sizeof(header->source), "oc_plugin:%s", descriptor_->name);
        else
            snprintf(header->source, sizeof(header->source), "oc_plugin");

        for (size_t i = 0; i < detections_.size(); i++) {
            AVDetectionBBox *dst = av_get_detection_bbox(header, static_cast<unsigned int>(i));

            dst->x = detections_.boxes[i].x;
            dst->y = detections_.boxes[i].y;
            dst->w = detections_.boxes[i].width;
            dst->h = detections_.boxes[i].height;

            if (i < detections_.labels.size() && !detections_.labels[i].empty())
                av_strlcpy(dst->detect_label, detections_.labels[i].c_str(),
                           AV_DETECTION_BBOX_LABEL_NAME_MAX_SIZE);
            else
                dst->detect_label[0] = '\0';

            float conf = (i < detections_.confidences.size()) ? detections_.confidences[i] : 0.0f;
            dst->detect_confidence.num = static_cast<int>(conf * 1000000);
            dst->detect_confidence.den = 1000000;

            dst->classify_count = 0;
        }

        av_log(ctx_, AV_LOG_DEBUG, "Attached %zu detection boxes to frame pts %" PRId64 "\n",
               detections_.size(), frame->pts);
        return 0;
    }
};

/*===========================================================================
 * OCPluginContext: Main context (plugin loading, configure, delegation)
 *===========================================================================*/

class OCPluginContext {
public:
    const char *plugin_path = nullptr;
    const char *plugin_params = nullptr;
    int nb_inputs = 1;
    int nb_outputs = 1;
    int shortest = 0;

    OCPluginContext() = default;
    ~OCPluginContext() { cleanup(); }

    OCPluginContext(const OCPluginContext&) = delete;
    OCPluginContext& operator=(const OCPluginContext&) = delete;

    int init(AVFilterContext *ctx) {
        ctx_ = ctx;

        int ret = loadPlugin();
        if (ret < 0)
            return ret;

        ret = initPlugin();
        if (ret < 0)
            return ret;

        return 0;
    }

    bool isCudaPlugin() const { return is_cuda_plugin_; }

    int configure() {
        if (configured_)
            return 0;
        configured_ = true;

        /* Collect input configurations */
        std::vector<quink::FrameConfig> input_configs(nb_inputs);
        for (int i = 0; i < nb_inputs; i++) {
            AVFilterLink *link = ctx_->inputs[i];
            AVPixelFormat av_fmt = AV_PIX_FMT_NONE;
#if CONFIG_CUDA
            if (is_cuda_plugin_) {
                if (link->format != AV_PIX_FMT_CUDA) {
                    av_log(ctx_, AV_LOG_ERROR,
                           "CUDA plugin requires AV_PIX_FMT_CUDA input, got %d\n", link->format);
                    return AVERROR(EINVAL);
                }
                FilterLink *fl = ff_filter_link(link);
                AVHWFramesContext *hw_frames_ctx = fl->hw_frames_ctx ?
                    (AVHWFramesContext*)fl->hw_frames_ctx->data : nullptr;
                if (!hw_frames_ctx) {
                    av_log(ctx_, AV_LOG_ERROR, "Missing hw_frames_ctx for CUDA input\n");
                    return AVERROR(EINVAL);
                }
                av_fmt = hw_frames_ctx->sw_format;
            } else
#endif
            {
                av_fmt = static_cast<AVPixelFormat>(link->format);
            }

            const PixFmtMap *pix_info = mapFromAvFmt(av_fmt);
            if (!pix_info) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Unsupported pixel format %s for input %d.\n",
                       av_get_pix_fmt_name(av_fmt), i);
                return AVERROR(EINVAL);
            }
            bool limited_range = false;
            if (link->color_range != AVCOL_RANGE_UNSPECIFIED)
                limited_range = link->color_range == AVCOL_RANGE_MPEG;
            input_configs[i] = {link->w, link->h,          pix_info->cv_type,
                                pix_info->pix_fmt, link->colorspace, limited_range};
        }

        /* Initialize output configurations with defaults */
        out_configs_.resize(nb_outputs);
        for (int i = 0; i < nb_outputs; i++) {
            int src_idx = (i < nb_inputs) ? i : 0;
            out_configs_[i] = {
                input_configs[src_idx].width,
                input_configs[src_idx].height,
                0,
                input_configs[src_idx].pix_fmt,
                input_configs[src_idx].colorspace,
                input_configs[src_idx].limited_range
            };
        }

        /* Call plugin configure */
        if (process_plugin_) {
            if (!process_plugin_->configure(input_configs, out_configs_)) {
                av_log(ctx_, AV_LOG_ERROR, "Plugin configure failed\n");
                return AVERROR(EINVAL);
            }
        } else if (cuda_process_plugin_) {
            if (!cuda_process_plugin_->configure(input_configs, out_configs_)) {
                av_log(ctx_, AV_LOG_ERROR, "CUDA Plugin configure failed\n");
                return AVERROR(EINVAL);
            }
        }
        /* DETECT plugins don't need configure */

        /* Create the appropriate frame handler */
        if (detect_plugin_) {
            handler_ = std::make_unique<DetectFrameHandler>(
                ctx_, detect_plugin_, descriptor_, nb_inputs, nb_outputs, &out_configs_);
        }
#if CONFIG_CUDA
        else if (cuda_process_plugin_) {
            auto cuda_handler = std::make_unique<CudaFrameHandler>(
                ctx_, cuda_process_plugin_, nb_inputs, nb_outputs, &out_configs_);
            int ret = cuda_handler->configurePipeline();
            if (ret < 0)
                return ret;
            handler_ = std::move(cuda_handler);
        }
#endif
        else {
            handler_ = std::make_unique<CpuFrameHandler>(
                ctx_, process_plugin_, nb_inputs, nb_outputs, &out_configs_);
        }

        return 0;
    }

    int processFrame(AVFilterLink *inlink, AVFrame *in) {
        return handler_->processFrame(inlink, in);
    }

    int processFrameMulti(FFFrameSync *fs, AVFrame **inputs) {
        return handler_->processFrameMulti(fs, inputs);
    }

    int flush() {
        return handler_->flush();
    }

    bool isFlushing() const { return handler_ && handler_->isFlushing(); }
    const quink::FrameConfig& getOutputConfig(int idx) const { return out_configs_[idx]; }

private:
    AVFilterContext *ctx_ = nullptr;

    /* Plugin handle and instance */
    void *dl_handle_ = nullptr;
    const QuinkOCPluginDescriptor *descriptor_ = nullptr;
    quink::PluginBase *plugin_ = nullptr;
    quink::ProcessPlugin *process_plugin_ = nullptr;
    quink::DetectPlugin *detect_plugin_ = nullptr;
    quink::CudaProcessPlugin *cuda_process_plugin_ = nullptr;

    /* Output configurations and handler */
    std::vector<quink::FrameConfig> out_configs_;
    std::unique_ptr<FrameHandler> handler_;

    bool configured_ = false;
    bool is_detect_plugin_ = false;
    bool is_cuda_plugin_ = false;

    int loadPlugin() {
        if (!plugin_path || !plugin_path[0]) {
            av_log(ctx_, AV_LOG_ERROR, "No plugin path specified\n");
            return AVERROR(EINVAL);
        }

        dl_handle_ = dlopen(plugin_path, RTLD_NOW | RTLD_LOCAL);
        if (!dl_handle_) {
            const char *err = dlerror();
            av_log(ctx_, AV_LOG_ERROR, "Failed to load plugin '%s': %s\n",
                   plugin_path, err ? err : "unknown error");
            return AVERROR(EINVAL);
        }

        auto get_descriptor = reinterpret_cast<QuinkOCPluginGetDescriptorFunc>(
            dlsym(dl_handle_, QUINK_OC_PLUGIN_DESCRIPTOR_SYMBOL));
        if (!get_descriptor) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin missing '%s' symbol\n",
                   QUINK_OC_PLUGIN_DESCRIPTOR_SYMBOL);
            return AVERROR(EINVAL);
        }

        descriptor_ = get_descriptor();
        if (!descriptor_) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin returned NULL descriptor\n");
            return AVERROR(EINVAL);
        }

        if (descriptor_->api_version != QUINK_OC_PLUGIN_API_VERSION) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin API version mismatch: expected %d, got %d\n",
                   QUINK_OC_PLUGIN_API_VERSION, descriptor_->api_version);
            return AVERROR(EINVAL);
        }

        if (!descriptor_->create || !descriptor_->destroy) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin descriptor missing create/destroy\n");
            return AVERROR(EINVAL);
        }

        bool has_process = (descriptor_->capabilities & static_cast<unsigned int>(quink::Capability::Process)) != 0;
        bool has_detect = (descriptor_->capabilities & static_cast<unsigned int>(quink::Capability::Detect)) != 0;
        bool has_cuda_process = (descriptor_->capabilities & static_cast<unsigned int>(quink::Capability::CudaProcess)) != 0;

#if !CONFIG_CUDA
        if (has_cuda_process) {
            av_log(ctx_, AV_LOG_ERROR,
                   "CUDA plugin not supported - FFmpeg built without CUDA\n");
            return AVERROR(ENOSYS);
        }
#endif

        int cap_count = (has_process ? 1 : 0) + (has_detect ? 1 : 0) + (has_cuda_process ? 1 : 0);
        if (cap_count > 1) {
            av_log(ctx_, AV_LOG_ERROR,
                   "Plugin declares multiple capabilities. "
                   "PROCESS, DETECT, and CUDA_PROCESS are mutually exclusive.\n");
            return AVERROR(EINVAL);
        }
        if (cap_count == 0) {
            av_log(ctx_, AV_LOG_ERROR,
                   "Plugin must declare PROCESS, DETECT, or CUDA_PROCESS capability\n");
            return AVERROR(EINVAL);
        }

        is_detect_plugin_ = has_detect;
        is_cuda_plugin_ = has_cuda_process;

        return 0;
    }

    int initPlugin() {
        plugin_ = descriptor_->create();
        if (!plugin_) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to create plugin instance\n");
            return AVERROR(ENOMEM);
        }

        if (is_detect_plugin_) {
            detect_plugin_ = dynamic_cast<quink::DetectPlugin*>(plugin_);
            if (!detect_plugin_) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Plugin declares DETECT capability but doesn't inherit quink::DetectPlugin\n");
                descriptor_->destroy(plugin_);
                plugin_ = nullptr;
                return AVERROR(EINVAL);
            }
        } else if (is_cuda_plugin_) {
            cuda_process_plugin_ = dynamic_cast<quink::CudaProcessPlugin*>(plugin_);
            if (!cuda_process_plugin_) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Plugin declares CUDA_PROCESS capability but doesn't inherit quink::CudaProcessPlugin\n");
                descriptor_->destroy(plugin_);
                plugin_ = nullptr;
                return AVERROR(EINVAL);
            }
        } else {
            process_plugin_ = dynamic_cast<quink::ProcessPlugin*>(plugin_);
            if (!process_plugin_) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Plugin declares PROCESS capability but doesn't inherit quink::ProcessPlugin\n");
                descriptor_->destroy(plugin_);
                plugin_ = nullptr;
                return AVERROR(EINVAL);
            }
        }

        if (!plugin_->init(plugin_params, nb_inputs, nb_outputs)) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin initialization failed\n");
            descriptor_->destroy(plugin_);
            plugin_ = nullptr;
            process_plugin_ = nullptr;
            detect_plugin_ = nullptr;
            cuda_process_plugin_ = nullptr;
            return AVERROR(EINVAL);
        }

        av_log(ctx_, AV_LOG_INFO, "Loaded plugin: %s - %s\n",
               descriptor_->name, descriptor_->description);
        return 0;
    }

    void cleanup() {
        handler_.reset();
        if (plugin_) {
            plugin_->uninit();
            if (descriptor_ && descriptor_->destroy)
                descriptor_->destroy(plugin_);
            plugin_ = nullptr;
            process_plugin_ = nullptr;
            detect_plugin_ = nullptr;
            cuda_process_plugin_ = nullptr;
        }
        if (dl_handle_) {
            dlclose(dl_handle_);
            dl_handle_ = nullptr;
        }
    }
};

/*===========================================================================
 * FFmpeg filter interface (static functions)
 *===========================================================================*/

struct OCPluginFilterContext {
    const AVClass *clazz;

    char *plugin_path;
    char *plugin_params;
    int nb_inputs;
    int nb_outputs;
    int shortest;

    /* Multi-input frame sync */
    FFFrameSync fs;
    AVFrame **input_frames;
    bool use_framesync;

    alignas(OCPluginContext) char ctx_storage[sizeof(OCPluginContext)];
};

static inline OCPluginContext* get_ctx(OCPluginFilterContext *s) {
    return reinterpret_cast<OCPluginContext*>(s->ctx_storage);
}

static int query_formats(const AVFilterContext *ctx,
                         AVFilterFormatsConfig **cfg_in,
                         AVFilterFormatsConfig **cfg_out)
{
#if CONFIG_CUDA
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(ctx->priv);
    OCPluginContext *oc = get_ctx(s);

    if (oc->isCudaPlugin()) {
        static AVPixelFormat cuda_fmts[] = {
            AV_PIX_FMT_CUDA, AV_PIX_FMT_NONE
        };
        AVFilterFormats *formats = ff_make_pixel_format_list(cuda_fmts);
        if (!formats)
            return AVERROR(ENOMEM);
        int ret = ff_set_common_formats2(ctx, cfg_in, cfg_out, formats);
        if (ret < 0)
            return ret;

        for (int i = 0; i < ctx->nb_inputs; i++) {
            ret = ff_formats_ref(ff_all_color_ranges(), &cfg_in[i]->color_ranges);
            if (ret < 0)
                return ret;
            ret = ff_formats_ref(ff_all_color_spaces(), &cfg_in[i]->color_spaces);
            if (ret < 0)
                return ret;
        }
        for (int i = 0; i < ctx->nb_outputs; i++) {
            ret = ff_formats_ref(ff_all_color_ranges(), &cfg_out[i]->color_ranges);
            if (ret < 0)
                return ret;
            ret = ff_formats_ref(ff_all_color_spaces(), &cfg_out[i]->color_spaces);
            if (ret < 0)
                return ret;
        }
        return 0;
    }
#endif
    {
        AVFilterFormats *formats = ff_make_pixel_format_list(default_fmts);
        if (!formats)
            return AVERROR(ENOMEM);
        return ff_set_common_formats2(ctx, cfg_in, cfg_out, formats);
    }
}

static int filter_frame(AVFilterLink *inlink, AVFrame *in)
{
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(inlink->dst->priv);
    return get_ctx(s)->processFrame(inlink, in);
}

static int process_frame_multi(FFFrameSync *fs)
{
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(fs->opaque);
    int ret;

    for (int i = 0; i < s->nb_inputs; i++) {
        ret = ff_framesync_get_frame(&s->fs, i, &s->input_frames[i], 0);
        if (ret < 0)
            return ret;
    }

    return get_ctx(s)->processFrameMulti(fs, s->input_frames);
}

static int activate(AVFilterContext *ctx)
{
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(ctx->priv);
    OCPluginContext *oc = get_ctx(s);
    AVFilterLink *outlink = ctx->outputs[0];
    int ret;

    if (s->use_framesync) {
        ret = ff_framesync_activate(&s->fs);
        if (ret < 0)
            return ret;

        if (ff_outlink_get_status(outlink) && !oc->isFlushing()) {
            ret = oc->flush();
            if (ret < 0)
                return ret;
        }
        return 0;
    }

    /* Single-input mode (1:1 or 1:N) */
    AVFilterLink *inlink = ctx->inputs[0];
    AVFrame *frame = nullptr;
    int status;
    int64_t pts;

    int any_wanted = 0;
    int all_done = 1;
    for (int i = 0; i < s->nb_outputs; i++) {
        AVFilterLink *out = ctx->outputs[i];
        if (!ff_outlink_get_status(out)) {
            all_done = 0;
            if (ff_outlink_frame_wanted(out))
                any_wanted = 1;
        }
    }

    if (all_done) {
        ff_inlink_set_status(inlink, AVERROR_EOF);
        return 0;
    }

    FF_FILTER_FORWARD_STATUS_BACK(outlink, inlink);

    ret = ff_inlink_consume_frame(inlink, &frame);
    if (ret < 0)
        return ret;

    if (frame) {
        ret = filter_frame(inlink, frame);
        if (ret < 0)
            return ret;
    }

    if (ff_inlink_acknowledge_status(inlink, &status, &pts)) {
        if (status == AVERROR_EOF && !oc->isFlushing()) {
            ret = oc->flush();
            if (ret < 0)
                return ret;
        }
        for (int i = 0; i < s->nb_outputs; i++)
            ff_outlink_set_status(ctx->outputs[i], status, pts);
        return 0;
    }

    if (any_wanted && !ff_outlink_get_status(outlink))
        ff_inlink_request_frame(inlink);

    return 0;
}

static int config_output(AVFilterLink *outlink)
{
    AVFilterContext *ctx = outlink->src;
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(ctx->priv);
    OCPluginContext *oc = get_ctx(s);
    AVFilterLink *inlink = ctx->inputs[0];
    FilterLink *il = ff_filter_link(inlink);
    int ret = oc->configure();
    if (ret < 0)
        return ret;

    for (int i = 0; i < s->nb_outputs; i++) {
        AVFilterLink *out = ctx->outputs[i];
        FilterLink *out_fl = ff_filter_link(out);
        const quink::FrameConfig &cfg = oc->getOutputConfig(i);

        out->w = cfg.width;
        out->h = cfg.height;
        out->time_base = inlink->time_base;
        out->sample_aspect_ratio = inlink->sample_aspect_ratio;
        out_fl->frame_rate = il->frame_rate;
    }

    if (s->nb_inputs > 1 && s->nb_outputs == 1) {
        ret = ff_framesync_init(&s->fs, ctx, s->nb_inputs);
        if (ret < 0)
            return ret;

        s->fs.opaque = s;
        s->fs.on_event = process_frame_multi;

        FFFrameSyncIn *in = s->fs.in;
        for (int i = 0; i < s->nb_inputs; i++) {
            in[i].time_base = ctx->inputs[i]->time_base;
            in[i].sync = 1;
            in[i].before = EXT_STOP;
            in[i].after = s->shortest ? EXT_STOP : EXT_INFINITY;
        }

        ret = ff_framesync_configure(&s->fs);
        if (ret < 0)
            return ret;

        outlink->time_base = s->fs.time_base;
        s->use_framesync = true;
    }

    return 0;
}

static av_cold int init(AVFilterContext *ctx)
{
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(ctx->priv);
    int ret;

    OCPluginContext *oc = new (s->ctx_storage) OCPluginContext();

    oc->plugin_path = s->plugin_path;
    oc->plugin_params = s->plugin_params;
    oc->nb_inputs = s->nb_inputs;
    oc->nb_outputs = s->nb_outputs;
    oc->shortest = s->shortest;

    if (s->nb_inputs < 1 || s->nb_inputs > OC_PLUGIN_MAX_INPUTS) {
        av_log(ctx, AV_LOG_ERROR, "Invalid inputs: %d (1-%d)\n",
               s->nb_inputs, OC_PLUGIN_MAX_INPUTS);
        return AVERROR(EINVAL);
    }
    if (s->nb_outputs < 1 || s->nb_outputs > OC_PLUGIN_MAX_OUTPUTS) {
        av_log(ctx, AV_LOG_ERROR, "Invalid outputs: %d (1-%d)\n",
               s->nb_outputs, OC_PLUGIN_MAX_OUTPUTS);
        return AVERROR(EINVAL);
    }
    if (s->nb_inputs > 1 && s->nb_outputs > 1) {
        av_log(ctx, AV_LOG_ERROR, "N:M mode not supported, use 1:N or N:1\n");
        return AVERROR(EINVAL);
    }

    ret = oc->init(ctx);
    if (ret < 0)
        return ret;

    for (int i = 0; i < s->nb_inputs; i++) {
        AVFilterPad pad = {};
        pad.type = AVMEDIA_TYPE_VIDEO;
        pad.name = (s->nb_inputs == 1) ? av_strdup("default") : av_asprintf("input%d", i);
        if (s->nb_inputs == 1)
            pad.filter_frame = filter_frame;
        if (!pad.name)
            return AVERROR(ENOMEM);
        ret = ff_append_inpad_free_name(ctx, &pad);
        if (ret < 0)
            return ret;
    }

    if (s->nb_inputs > 1) {
        s->input_frames = static_cast<AVFrame**>(av_calloc(s->nb_inputs, sizeof(*s->input_frames)));
        if (!s->input_frames)
            return AVERROR(ENOMEM);
    }

    for (int i = 0; i < s->nb_outputs; i++) {
        AVFilterPad pad = {};
        pad.type = AVMEDIA_TYPE_VIDEO;
        pad.config_props = config_output;
        pad.name = (s->nb_outputs == 1) ? av_strdup("default") : av_asprintf("output%d", i);
        if (!pad.name)
            return AVERROR(ENOMEM);
        ret = ff_append_outpad_free_name(ctx, &pad);
        if (ret < 0)
            return ret;
    }

    return 0;
}

static av_cold void uninit(AVFilterContext *ctx)
{
    OCPluginFilterContext *s = static_cast<OCPluginFilterContext*>(ctx->priv);

    if (s->use_framesync)
        ff_framesync_uninit(&s->fs);

    av_freep(&s->input_frames);

    get_ctx(s)->~OCPluginContext();
}

#define OFFSET(x) offsetof(OCPluginFilterContext, x)
#define FLAGS AV_OPT_FLAG_VIDEO_PARAM | AV_OPT_FLAG_FILTERING_PARAM

static const AVOption oc_plugin_options[] = {
    { "plugin", "Path to OpenCV plugin shared library",
        OFFSET(plugin_path), AV_OPT_TYPE_STRING, {}, 0, 0, FLAGS },
    { "params", "Parameters to pass to the plugin",
        OFFSET(plugin_params), AV_OPT_TYPE_STRING, {}, 0, 0, FLAGS },
    { "inputs", "Number of inputs",
        OFFSET(nb_inputs), AV_OPT_TYPE_INT, {1}, 1, OC_PLUGIN_MAX_INPUTS, FLAGS },
    { "outputs", "Number of outputs",
        OFFSET(nb_outputs), AV_OPT_TYPE_INT, {1}, 1, OC_PLUGIN_MAX_OUTPUTS, FLAGS },
    { "shortest", "Force termination when shortest input ends",
        OFFSET(shortest), AV_OPT_TYPE_BOOL, {}, 0, 1, FLAGS },
    { nullptr }
};

static const AVClass oc_plugin_class = []() -> AVClass {
    AVClass cls = {};
    cls.class_name = "oc_plugin";
    cls.item_name = av_default_item_name;
    cls.option = oc_plugin_options;
    cls.version = LIBAVUTIL_VERSION_INT;
    cls.category = AV_CLASS_CATEGORY_FILTER;
    return cls;
}();

static FFFilter create_ff_filter() {
    FFFilter f = {};
    f.p.name = "oc_plugin";
    f.p.description = NULL_IF_CONFIG_SMALL("Apply processing using external OpenCV plugin.");
    f.p.priv_class = &oc_plugin_class;
    f.p.flags = AVFILTER_FLAG_DYNAMIC_INPUTS | AVFILTER_FLAG_DYNAMIC_OUTPUTS;
    f.flags_internal = FF_FILTER_FLAG_HWFRAME_AWARE;
    f.formats_state = FF_FILTER_FORMATS_QUERY_FUNC2;
    f.init = init;
    f.uninit = uninit;
    f.formats.query_func2 = query_formats;
    f.priv_size = sizeof(OCPluginFilterContext);
    f.activate = activate;
    return f;
}

extern "C" const FFFilter ff_vf_oc_plugin = create_ff_filter();
