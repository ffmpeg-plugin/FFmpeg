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

#ifdef _WIN32
#include "compat/w32dlfcn.h"
#else
#include <dlfcn.h>
#endif

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <new>  /* For placement new */
#include <vector>

#include "quink_oc_plugin.h"

#define OC_PLUGIN_MAX_INPUTS  8
#define OC_PLUGIN_MAX_OUTPUTS 8

static const struct {
    enum AVPixelFormat av_fmt;
    int cv_type;
} pix_fmt_map[] = {
    { AV_PIX_FMT_BGR24,     CV_8UC3  },
    { AV_PIX_FMT_BGRA,      CV_8UC4  },
    { AV_PIX_FMT_GRAY8,     CV_8UC1  },
    { AV_PIX_FMT_GRAY16LE,  CV_16UC1 },
    { AV_PIX_FMT_BGR48LE,   CV_16UC3 },
    { AV_PIX_FMT_NONE,      -1       },
};

static int pixfmt_to_cv_type(enum AVPixelFormat fmt)
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

        input_mats_.resize(nb_inputs);
        output_mats_.resize(nb_outputs);

        return 0;
    }

    int configure() {
        /* Collect input configurations */
        std::vector<QuinkOCFrameConfig> input_configs(nb_inputs);
        for (int i = 0; i < nb_inputs; i++) {
            AVFilterLink *link = ctx_->inputs[i];
            int cv_type = pixfmt_to_cv_type(static_cast<AVPixelFormat>(link->format));
            if (cv_type < 0) {
                av_log(ctx_, AV_LOG_ERROR, "Unsupported pixel format for input %d\n", i);
                return AVERROR(EINVAL);
            }
            input_configs[i] = { link->w, link->h, cv_type };
        }

        /* Initialize output configurations with defaults */
        out_configs_.resize(nb_outputs);
        for (int i = 0; i < nb_outputs; i++) {
            int src_idx = (i < nb_inputs) ? i : 0;
            out_configs_[i] = {
                input_configs[src_idx].width,
                input_configs[src_idx].height,
                0
            };
        }

        if (process_plugin_) {
        /* DETECT plugins don't need configure - they pass through frames */
        if (process_plugin_) {
            if (!process_plugin_->configure(input_configs, out_configs_)) {
                av_log(ctx_, AV_LOG_ERROR, "Plugin configure failed\n");
                return AVERROR(EINVAL);
            }
        }
        }

        /* Cache output pixel formats */
        out_pix_fmts_.resize(nb_outputs);
        for (int i = 0; i < nb_outputs; i++)
            out_pix_fmts_[i] = static_cast<AVPixelFormat>(ctx_->outputs[i]->format);

        configured_ = true;
        return 0;
    }

    /**
     * Process a single input frame (1:1 or 1:N mode).
     */
    int processFrame(AVFilterLink *inlink, AVFrame *in) {
        /* For DETECT plugins, use simplified pass-through flow */
        if (is_detect_plugin_)
            return processFrameDetectOnly(inlink, in);

        std::vector<AVFrame*> out_frames(nb_outputs);

        /* Allocate output frames */
        for (int i = 0; i < nb_outputs; i++) {
            out_frames[i] = allocOutputFrame(i, in->pts);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                av_frame_free(&in);
                return AVERROR(ENOMEM);
            }
            av_frame_copy_props(out_frames[i], in);
        }

        /* Save original output buffer pointers for later verification */
        std::vector<uint8_t*> original_out_ptrs(nb_outputs);
        for (int i = 0; i < nb_outputs; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        /* Wrap input as cv::Mat with tied refcount */
        input_mats_[0] = wrapFrame(in, static_cast<AVPixelFormat>(inlink->format), true);
        if (input_mats_[0].empty()) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input frame\n");
            freeFrames(out_frames, nb_outputs);
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        /* Wrap outputs as simple views */
        for (int i = 0; i < nb_outputs; i++) {
            output_mats_[i] = wrapFrame(out_frames[i], out_pix_fmts_[i], false);
            if (output_mats_[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap output %d\n", i);
                clearMats();
                freeFrames(out_frames, nb_outputs);
                av_frame_free(&in);
                return AVERROR(EINVAL);
            }
        }

        QuinkOCProcessResult result = process_plugin_->process(input_mats_, output_mats_);

        if (result == QuinkOCProcessResult::QUINK_OC_ERROR) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin processing failed\n");
            clearMats();
            freeFrames(out_frames, nb_outputs);
            av_frame_free(&in);
            return AVERROR_EXTERNAL;
        }

        if (result == QuinkOCProcessResult::QUINK_OC_TRY_AGAIN) {
            clearMats();
            freeFrames(out_frames, nb_outputs);
            av_frame_free(&in);
            return 0;
        }

        /* Handle output Mat reassignment (zero-copy pass-through or clone) */
        int ret = handleOutputReassignment(out_frames, original_out_ptrs, in);
        clearMats();
        av_frame_free(&in);

        if (ret < 0) {
            freeFrames(out_frames, nb_outputs);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(out_frames);
    }

    /**
     * Process frame for DETECT-only plugins.
     * Supports both immediate and delayed output modes.
     */
    int processFrameDetectOnly(AVFilterLink *inlink, AVFrame *in) {
        /* Wrap input as cv::Mat for detection (tied refcount for potential buffering) */
        cv::Mat input_mat = wrapFrame(in, static_cast<AVPixelFormat>(inlink->format), true);
        if (input_mat.empty()) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input frame for detection\n");
            av_frame_free(&in);
            return AVERROR(EINVAL);
        }

        /* Store frame in queue for potential delayed output */
        detect_frame_queue_.push_back(in);

        /* Run detection */
        cv::Mat output_mat;
        detections_.clear();
        QuinkOCProcessResult result = detect_plugin_->detect(input_mat, output_mat, detections_);

        if (result == QuinkOCProcessResult::QUINK_OC_ERROR) {
            av_log(ctx_, AV_LOG_ERROR, "Detection failed for frame pts %" PRId64 "\n", in->pts);
            /* Clean up queued frames */
            for (auto *f : detect_frame_queue_)
                av_frame_free(&f);
            detect_frame_queue_.clear();
            return AVERROR_EXTERNAL;
        }

        if (result == QuinkOCProcessResult::QUINK_OC_TRY_AGAIN) {
            /* Frame buffered by plugin, no output yet */
            av_log(ctx_, AV_LOG_DEBUG, "Detection buffering frame pts %" PRId64 "\n", in->pts);
            return 0;
        }

        /* QUINK_OC_OK: output frame ready */
        return outputDetectFrame(output_mat, in);
    }

    /**
     * Output a detection frame with its detection results.
     * Finds the corresponding AVFrame from the queue based on Mat data pointer.
     */
    int outputDetectFrame(const cv::Mat &output_mat, AVFrame *fallback_frame) {
        AVFrame *out_frame = nullptr;

        /* Find the AVFrame corresponding to output_mat */
        if (!output_mat.empty()) {
            for (auto it = detect_frame_queue_.begin(); it != detect_frame_queue_.end(); ++it) {
                AVFrame *f = *it;
                if (f && f->data[0] == output_mat.data) {
                    out_frame = f;
                    detect_frame_queue_.erase(it);
                    break;
                }
            }
        }

        /* Fallback: use the provided frame or the oldest in queue */
        if (!out_frame) {
            if (fallback_frame) {
                /* Remove fallback_frame from queue if present */
                for (auto it = detect_frame_queue_.begin(); it != detect_frame_queue_.end(); ++it) {
                    if (*it == fallback_frame) {
                        detect_frame_queue_.erase(it);
                        break;
                    }
                }
                out_frame = fallback_frame;
            } else if (!detect_frame_queue_.empty()) {
                out_frame = detect_frame_queue_.front();
                detect_frame_queue_.erase(detect_frame_queue_.begin());
            } else {
                av_log(ctx_, AV_LOG_ERROR, "No frame available for detection output\n");
                return AVERROR(EINVAL);
            }
        }

        /* Attach detection results as side data */
        if (!detections_.empty()) {
            int ret = attachDetectionSideData(out_frame);
            if (ret < 0) {
                av_frame_free(&out_frame);
                return ret;
            }
        }

        last_pts_ = out_frame->pts;

        /* Output frame to all outputs (for 1:N mode) */
        for (int i = 0; i < nb_outputs; i++) {
            AVFrame *out = (i == nb_outputs - 1) ? out_frame : av_frame_clone(out_frame);
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

    /**
     * Process multiple input frames (N:1 mode via framesync).
     */
    int processFrameMulti(FFFrameSync *fs, AVFrame **inputs) {
        /* DETECT plugins don't support multi-input mode */
        if (is_detect_plugin_) {
            av_log(ctx_, AV_LOG_ERROR, "DETECT plugins don't support multi-input mode\n");
            return AVERROR(EINVAL);
        }

        std::vector<AVFrame*> out_frames(nb_outputs);

        /* Allocate output frames */
        for (int i = 0; i < nb_outputs; i++) {
            int64_t pts = av_rescale_q(fs->pts, fs->time_base, ctx_->outputs[i]->time_base);
            out_frames[i] = allocOutputFrame(i, pts);
            if (!out_frames[i]) {
                freeFrames(out_frames, i);
                return AVERROR(ENOMEM);
            }
            av_frame_copy_props(out_frames[i], inputs[0]);
            out_frames[i]->pts = pts;
        }

        /* Save original output buffer pointers for later verification */
        std::vector<uint8_t*> original_out_ptrs(nb_outputs);
        for (int i = 0; i < nb_outputs; i++)
            original_out_ptrs[i] = out_frames[i]->data[0];

        /* Wrap all inputs with tied refcount */
        for (int i = 0; i < nb_inputs; i++) {
            input_mats_[i] = wrapFrame(inputs[i],
                static_cast<AVPixelFormat>(ctx_->inputs[i]->format), true);
            if (input_mats_[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap input %d\n", i);
                clearMats();
                freeFrames(out_frames, nb_outputs);
                return AVERROR(EINVAL);
            }
        }

        /* Wrap outputs as simple views */
        for (int i = 0; i < nb_outputs; i++) {
            output_mats_[i] = wrapFrame(out_frames[i], out_pix_fmts_[i], false);
            if (output_mats_[i].empty()) {
                av_log(ctx_, AV_LOG_ERROR, "Failed to wrap output %d\n", i);
                clearMats();
                freeFrames(out_frames, nb_outputs);
                return AVERROR(EINVAL);
            }
        }

        QuinkOCProcessResult result = process_plugin_->process(input_mats_, output_mats_);

        if (result == QuinkOCProcessResult::QUINK_OC_ERROR) {
            av_log(ctx_, AV_LOG_ERROR, "Plugin processing failed\n");
            clearMats();
            freeFrames(out_frames, nb_outputs);
            return AVERROR_EXTERNAL;
        }

        if (result == QuinkOCProcessResult::QUINK_OC_TRY_AGAIN) {
            clearMats();
            freeFrames(out_frames, nb_outputs);
            return 0;
        }

        /* Handle output Mat reassignment (zero-copy pass-through or clone) */
        int ret = handleOutputReassignment(out_frames, original_out_ptrs, inputs[0]);
        clearMats();

        if (ret < 0) {
            freeFrames(out_frames, nb_outputs);
            return ret;
        }

        last_pts_ = out_frames[0]->pts;
        return outputFrames(out_frames);
    }

    /**
     * Flush buffered frames from plugin at end of stream.
     */
    int flush() {
        /* DETECT plugins use flushDetect */
        if (is_detect_plugin_)
            return flushDetect();

        flushing_ = true;
        std::vector<AVFrame*> out_frames(nb_outputs);

        while (true) {
            for (int i = 0; i < nb_outputs; i++) {
                out_frames[i] = allocOutputFrame(i, last_pts_);
                if (!out_frames[i]) {
                    freeFrames(out_frames, i);
                    flushing_ = false;
                    return AVERROR(ENOMEM);
                }
                output_mats_[i] = wrapFrame(out_frames[i], out_pix_fmts_[i], false);
                if (output_mats_[i].empty()) {
                    freeFrames(out_frames, i + 1);
                    flushing_ = false;
                    return AVERROR(EINVAL);
                }
            }

            bool has_frame = process_plugin_->flush(output_mats_);

            if (!has_frame) {
                for (int i = 0; i < nb_outputs; i++)
                    output_mats_[i].release();
                freeFrames(out_frames, nb_outputs);
                break;
            }

            for (int i = 0; i < nb_outputs; i++)
                output_mats_[i].release();

            last_pts_++;
            int ret = outputFrames(out_frames);
            if (ret < 0) {
                flushing_ = false;
                return ret;
            }
        }

        flushing_ = false;
        return 0;
    }

    /**
     * Flush buffered frames from DETECT plugin at end of stream.
     */
    int flushDetect() {
        flushing_ = true;

        while (true) {
            cv::Mat output_mat;
            detections_.clear();

            bool has_frame = detect_plugin_->flushDetect(output_mat, detections_);
            if (!has_frame)
                break;

            int ret = outputDetectFrame(output_mat, nullptr);
            if (ret < 0) {
                flushing_ = false;
                return ret;
            }
        }

        /* Clean up any remaining frames in queue (shouldn't happen normally) */
        for (auto *f : detect_frame_queue_)
            av_frame_free(&f);
        detect_frame_queue_.clear();

        flushing_ = false;
        return 0;
    }

    bool isFlushing() const { return flushing_; }
    const QuinkOCFrameConfig& getOutputConfig(int idx) const { return out_configs_[idx]; }

private:
    AVFilterContext *ctx_ = nullptr;

    /* Plugin handle and instance */
    void *dl_handle_ = nullptr;
    const QuinkOCPluginDescriptor *descriptor_ = nullptr;
    QuinkOCPluginBase *plugin_ = nullptr;
    QuinkOCProcessPlugin *process_plugin_ = nullptr;  ///< Non-null for PROCESS plugins
    QuinkOCDetectPlugin *detect_plugin_ = nullptr;    ///< Non-null for DETECT plugins

    /* Processing state */
    std::vector<cv::Mat> input_mats_;
    std::vector<cv::Mat> output_mats_;
    std::vector<QuinkOCFrameConfig> out_configs_;
    std::vector<AVPixelFormat> out_pix_fmts_;

    bool configured_ = false;
    bool flushing_ = false;
    int64_t last_pts_ = 0;
    bool is_detect_plugin_ = false;
    QuinkOCDetections detections_;

    /* For DETECT plugins: store input frames for delayed output */
    std::vector<AVFrame*> detect_frame_queue_;

    /**
     * Attach detection results to frame as side data.
     */
    int attachDetectionSideData(AVFrame *frame) {
        AVDetectionBBoxHeader *header = av_detection_bbox_create_side_data(
            frame, static_cast<uint32_t>(detections_.size()));
        if (!header) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to allocate detection bbox side data\n");
            return AVERROR(ENOMEM);
        }

        /* Set source information */
        if (descriptor_ && descriptor_->name)
            snprintf(header->source, sizeof(header->source), "oc_plugin:%s", descriptor_->name);
        else
            snprintf(header->source, sizeof(header->source), "oc_plugin");

        /* Convert each detection */
        for (size_t i = 0; i < detections_.size(); i++) {
            AVDetectionBBox *dst = av_get_detection_bbox(header, static_cast<unsigned int>(i));

            dst->x = detections_.boxes[i].x;
            dst->y = detections_.boxes[i].y;
            dst->w = detections_.boxes[i].width;
            dst->h = detections_.boxes[i].height;

            /* Copy label */
            if (i < detections_.labels.size() && !detections_.labels[i].empty())
                av_strlcpy(dst->detect_label, detections_.labels[i].c_str(),
                           AV_DETECTION_BBOX_LABEL_NAME_MAX_SIZE);
            else
                dst->detect_label[0] = '\0';

            /* Convert float confidence to AVRational */
            float conf = (i < detections_.confidences.size()) ? detections_.confidences[i] : 0.0f;
            dst->detect_confidence.num = static_cast<int>(conf * 1000000);
            dst->detect_confidence.den = 1000000;

            dst->classify_count = 0;
        }

        av_log(ctx_, AV_LOG_DEBUG, "Attached %zu detection boxes to frame pts %" PRId64 "\n",
               detections_.size(), frame->pts);
        return 0;
    }

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

        /* Check plugin capabilities */
        bool has_process = (descriptor_->capabilities & QUINK_OC_CAP_PROCESS) != 0;
        bool has_detect = (descriptor_->capabilities & QUINK_OC_CAP_DETECT) != 0;

        /* Validate: must have exactly one capability */
        if (has_process && has_detect) {
            av_log(ctx_, AV_LOG_ERROR,
                   "Plugin declares both PROCESS and DETECT capabilities. "
                   "These are mutually exclusive.\n");
            return AVERROR(EINVAL);
        }
        if (!has_process && !has_detect) {
            av_log(ctx_, AV_LOG_ERROR,
                   "Plugin must declare either QUINK_OC_CAP_PROCESS or QUINK_OC_CAP_DETECT\n");
            return AVERROR(EINVAL);
        }

        is_detect_plugin_ = has_detect;

        return 0;
    }

    int initPlugin() {
        plugin_ = descriptor_->create();
        if (!plugin_) {
            av_log(ctx_, AV_LOG_ERROR, "Failed to create plugin instance\n");
            return AVERROR(ENOMEM);
        }

        /* Cast to appropriate derived type based on capabilities */
        if (is_detect_plugin_) {
            detect_plugin_ = dynamic_cast<QuinkOCDetectPlugin*>(plugin_);
            if (!detect_plugin_) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Plugin declares DETECT capability but doesn't inherit QuinkOCDetectPlugin\n");
                descriptor_->destroy(plugin_);
                plugin_ = nullptr;
                return AVERROR(EINVAL);
            }
        } else {
            process_plugin_ = dynamic_cast<QuinkOCProcessPlugin*>(plugin_);
            if (!process_plugin_) {
                av_log(ctx_, AV_LOG_ERROR,
                       "Plugin declares PROCESS capability but doesn't inherit QuinkOCProcessPlugin\n");
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
            return AVERROR(EINVAL);
        }

        av_log(ctx_, AV_LOG_INFO, "Loaded plugin: %s - %s\n",
               descriptor_->name, descriptor_->description);
        return 0;
    }

    void cleanup() {
        if (plugin_) {
            plugin_->uninit();
            if (descriptor_ && descriptor_->destroy)
                descriptor_->destroy(plugin_);
            plugin_ = nullptr;
            process_plugin_ = nullptr;
            detect_plugin_ = nullptr;
        }
        if (dl_handle_) {
            dlclose(dl_handle_);
            dl_handle_ = nullptr;
        }
    }

    /**
     * Wrap AVFrame as cv::Mat (zero-copy).
     * @param tie_refcount If true, Mat holds reference to AVFrame.
     */
    static cv::Mat wrapFrame(AVFrame *frame, AVPixelFormat fmt, bool tie_refcount) {
        int cv_type = pixfmt_to_cv_type(fmt);
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

    AVFrame* allocOutputFrame(int idx, int64_t pts) {
        AVFilterLink *outlink = ctx_->outputs[idx];
        AVFrame *out = ff_get_video_buffer(outlink, out_configs_[idx].width, out_configs_[idx].height);
        if (out)
            out->pts = pts;
        return out;
    }

    void clearMats() {
        for (auto &m : input_mats_) m.release();
        for (auto &m : output_mats_) m.release();
    }

    static void freeFrames(std::vector<AVFrame*> &frames, int count) {
        for (int i = 0; i < count; i++)
            av_frame_free(&frames[i]);
    }

    int outputFrames(std::vector<AVFrame*> &frames) {
        for (int i = 0; i < nb_outputs; i++) {
            int ret = ff_filter_frame(ctx_->outputs[i], frames[i]);
            if (ret < 0)
                return ret;
        }
        return 0;
    }

    /**
     * Check if a pointer belongs to any input frame's data buffer.
     */
    AVFrame* findInputFrameByData(uint8_t *data, AVFrame *single_input) {
        /* For single input mode */
        if (single_input && data == single_input->data[0])
            return single_input;

        /* Check all input mats (they hold references to input frames) */
        for (int i = 0; i < nb_inputs; i++) {
            if (!input_mats_[i].empty() && input_mats_[i].data == data) {
                /* The input mat's userdata contains the cloned AVFrame reference */
                if (input_mats_[i].u && input_mats_[i].u->userdata)
                    return static_cast<AVFrame*>(input_mats_[i].u->userdata);
            }
        }
        return nullptr;
    }

    /**
     * Handle cases where plugin reassigned output_mat to input_mat or clone().
     * Returns 0 on success, negative on error.
     */
    int handleOutputReassignment(std::vector<AVFrame*> &out_frames,
                                  const std::vector<uint8_t*> &original_out_ptrs,
                                  AVFrame *ref_input) {
        for (int i = 0; i < nb_outputs; i++) {
            uint8_t *current_data = output_mats_[i].data;
            uint8_t *original_data = original_out_ptrs[i];

            if (current_data == original_data) {
                /* Normal case: plugin wrote directly to output buffer */
                continue;
            }

            /* Check if output_mat now points to an input frame (zero-copy pass-through) */
            AVFrame *input_frame = findInputFrameByData(current_data, ref_input);
            if (input_frame) {
                /*
                 * Zero-copy pass-through: output_mat = input_mat
                 * Replace output frame with a reference to input frame
                 */
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

            /*
             * Illegal usage: output_mat = input_mat.clone() or other allocation
             * Plugin should use copyTo() instead of clone() to write to output buffer.
             */
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
    static AVPixelFormat default_fmts[] = {
        AV_PIX_FMT_BGR24, AV_PIX_FMT_BGRA, AV_PIX_FMT_GRAY8,
        AV_PIX_FMT_GRAY16LE, AV_PIX_FMT_BGR48LE, AV_PIX_FMT_NONE
    };
    AVFilterFormats *formats = ff_make_pixel_format_list(default_fmts);
    if (!formats)
        return AVERROR(ENOMEM);
    return ff_set_common_formats2(ctx, cfg_in, cfg_out, formats);
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

    /* For 1:N mode, check if ANY output wants frames */
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

    /* If all outputs are done, propagate EOF to input */
    if (all_done) {
        ff_inlink_set_status(inlink, AVERROR_EOF);
        return 0;
    }

    /* Forward status back from first output to input */
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
        /* Propagate status to ALL outputs */
        for (int i = 0; i < s->nb_outputs; i++)
            ff_outlink_set_status(ctx->outputs[i], status, pts);
        return 0;
    }

    /* Request input if any output wants frames */
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

    /* Configure all outputs */
    for (int i = 0; i < s->nb_outputs; i++) {
        AVFilterLink *out = ctx->outputs[i];
        FilterLink *out_fl = ff_filter_link(out);
        const QuinkOCFrameConfig &cfg = oc->getOutputConfig(i);

        out->w = cfg.width;
        out->h = cfg.height;
        out->time_base = inlink->time_base;
        out->sample_aspect_ratio = inlink->sample_aspect_ratio;
        out_fl->frame_rate = il->frame_rate;
    }

    /* For N:1 mode, setup framesync */
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

    /* Construct OCPluginContext via placement new */
    OCPluginContext *oc = new (s->ctx_storage) OCPluginContext();

    /* Copy options to OCPluginContext */
    oc->plugin_path = s->plugin_path;
    oc->plugin_params = s->plugin_params;
    oc->nb_inputs = s->nb_inputs;
    oc->nb_outputs = s->nb_outputs;
    oc->shortest = s->shortest;

    /* Validate configuration */
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

    /* Create input pads */
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

    /* Allocate frame storage for multi-input */
    if (s->nb_inputs > 1) {
        s->input_frames = static_cast<AVFrame**>(av_calloc(s->nb_inputs, sizeof(*s->input_frames)));
        if (!s->input_frames)
            return AVERROR(ENOMEM);
    }

    /* Create output pads */
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

    /* Explicitly destruct OCPluginContext */
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
    f.formats_state = FF_FILTER_FORMATS_QUERY_FUNC2;
    f.init = init;
    f.uninit = uninit;
    f.formats.query_func2 = query_formats;
    f.priv_size = sizeof(OCPluginFilterContext);
    f.activate = activate;
    return f;
}

extern "C" const FFFilter ff_vf_oc_plugin = create_ff_filter();
