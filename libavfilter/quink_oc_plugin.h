/*
 * OpenCV Plugin Interface for FFmpeg
 *
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

#ifndef AVFILTER_QUINK_OC_PLUGIN_H
#define AVFILTER_QUINK_OC_PLUGIN_H

#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <vector>
#include <string>

#define QUINK_OC_PLUGIN_API_VERSION 1

/**
 * Plugin capability flags.
 *
 * Plugins declare their capabilities in QuinkOCPluginDescriptor::capabilities.
 * FFmpeg uses these flags to determine the plugin type and call the appropriate methods.
 *
 * IMPORTANT: QUINK_OC_CAP_PROCESS and QUINK_OC_CAP_DETECT are MUTUALLY EXCLUSIVE.
 * A plugin must declare exactly one of these capabilities, not both.
 *
 * Plugin types:
 *   - PROCESS plugin: Inherits QuinkOCProcessPlugin, transforms frames
 *   - DETECT plugin:  Inherits QuinkOCDetectPlugin, analyzes frames for detection
 */
enum QuinkOCCapability {
    QUINK_OC_CAP_NONE        = 0,        ///< No special capabilities (invalid)
    QUINK_OC_CAP_PROCESS     = 1 << 0,   ///< Process plugin: transforms frames (CPU cv::Mat)
    QUINK_OC_CAP_DETECT      = 1 << 1,   ///< Detect plugin: analyzes frames for detection
    QUINK_OC_CAP_CUDA_PROCESS = 1 << 2,  ///< CUDA Process plugin: transforms frames (cv::cuda::GpuMat)
};

/**
 * Supported I/O modes (when QUINK_OC_CAP_PROCESS is set):
 *   - Single-input, single-output (1:1)
 *   - Multi-input, single-output (N:1) - e.g., video compositing, blending
 *   - Single-input, multi-output (1:N) - e.g., video splitting, analysis
 *
 * Multi-input + multi-output (N:M where N>1 and M>1) is NOT supported.
 * Use filter chains to achieve complex routing if needed.
 */

enum QuinkPixelFormat {
    QUINK_PIX_FMT_NONE = -1,
    QUINK_PIX_FMT_BGR = 0,
    QUINK_PIX_FMT_BGRA = 1,
    QUINK_PIX_FMT_NV12 = 2,     // Semi-Planar YUV [Y plane followed by interleaved UV plane]
    QUINK_PIX_FMT_P016 = 3,     // 16 bit Semi-Planar YUV [Y plane followed by interleaved UV plane].
};

struct QuinkOCFrameConfig {
    int width = 0;
    int height = 0;
    int cv_type = 0;
    QuinkPixelFormat pix_fmt = QUINK_PIX_FMT_NONE;
    // ISO/IEC 23091-2_2019 subclause 8.3
    int colorspace = 0;
    // Indicate whether NV12/P016 is limited range. BGR/BGRA is always full range
    bool limited_range = false;
};

enum QuinkOCProcessResult {
    QUINK_OC_OK = 0,              ///< Success, output frame(s) produced
    QUINK_OC_TRY_AGAIN = 1,       ///< Success, but output not ready yet
    QUINK_OC_ERROR = -1           ///< Processing error
};

/**
 * Detection results structure following OpenCV DNN conventions.
 *
 * This mirrors the output format of cv::dnn::DetectionModel::detect():
 *   - boxes: bounding boxes as cv::Rect
 *   - class_ids: integer class IDs
 *   - confidences: detection confidence scores
 *
 * Additionally provides:
 *   - labels: human-readable labels (optional, can be empty strings)
 *
 * All vectors must have the same size. Empty vectors indicate no detections.
 */
struct QuinkOCDetections {
    std::vector<cv::Rect> boxes;        ///< Bounding boxes (x, y, width, height)
    std::vector<int> class_ids;         ///< Class IDs (e.g., COCO class indices)
    std::vector<float> confidences;     ///< Confidence scores in range [0.0, 1.0]
    std::vector<std::string> labels;    ///< Human-readable labels (optional)

    void clear() {
        boxes.clear();
        class_ids.clear();
        confidences.clear();
        labels.clear();
    }

    size_t size() const {
        return boxes.size();
    }

    bool empty() const {
        return boxes.empty();
    }

    /**
     * Add a detection result.
     * @param box        Bounding box
     * @param class_id   Class ID
     * @param confidence Confidence score
     * @param label      Optional label (default empty)
     */
    void add(const cv::Rect& box, int class_id, float confidence,
             const std::string& label = "") {
        boxes.push_back(box);
        class_ids.push_back(class_id);
        confidences.push_back(confidence);
        labels.push_back(label);
    }
};

/*===========================================================================
 * Plugin Base Class
 *
 * All plugins (PROCESS or DETECT) inherit from this base class.
 * Provides common lifecycle methods: init() and uninit().
 *===========================================================================*/

class QuinkOCPluginBase {
public:
    virtual ~QuinkOCPluginBase() = default;

    /**
     * Initialize the plugin
     * @param params      User-specified parameter string (may be NULL)
     * @param nb_inputs   Number of inputs configured by user (via AVOption)
     * @param nb_outputs  Number of outputs configured by user (via AVOption)
     * @return true on success
     */
    virtual bool init(const char *params, int nb_inputs, int nb_outputs) = 0;

    /**
     * Cleanup resources
     */
    virtual void uninit() = 0;
};

/*===========================================================================
 * Process Plugin Class
 *
 * For plugins that transform video frames.
 * Inherit from this class and implement process(), flush(), configure().
 *
 * Supported I/O modes:
 *   - 1:1 (single-input, single-output)
 *   - N:1 (multi-input, single-output) - compositing, blending
 *   - 1:N (single-input, multi-output) - splitting
 *
 * Data flow:
 *   inputs --> process() --> QUINK_OC_OK:        outputs ready
 *                        --> QUINK_OC_TRY_AGAIN: buffered, no output yet
 *                        --> QUINK_OC_ERROR:     error
 *
 *   EOF --> flush() --> output buffered frames
 *===========================================================================*/

class QuinkOCProcessPlugin : public QuinkOCPluginBase {
public:
    /**
     * Process frames
     *
     * This method is called for each set of input frames.
     *
     * Allowed usage for outputs:
     *   1. Write directly to output buffer: input.copyTo(output)
     *   2. Zero-copy pass-through: output = input
     *
     * NOT allowed (will cause error):
     *   - output = input.clone() (defeats zero-copy, use copyTo instead)
     *   - output.create(...) or any reallocation
     *
     * @param inputs   Input cv::Mat images (zero-copy from FFmpeg, refcount tied to AVFrame)
     * @param outputs  Output cv::Mat images (pre-allocated buffer to write into)
     * @return QUINK_OC_OK:        success, output ready
     *         QUINK_OC_TRY_AGAIN: success, buffered, no output yet
     *         QUINK_OC_ERROR:     processing error
     */
    virtual QuinkOCProcessResult process(const std::vector<cv::Mat> &inputs,
                                         std::vector<cv::Mat> &outputs) = 0;

    /**
     * Flush buffered frames at end of stream
     *
     * Called when input stream ends. The plugin should output any remaining
     * buffered frames. This method may be called multiple times until it
     * returns false (no more frames to output).
     *
     * @param outputs  Output buffer to write flushed frame into
     * @return true if a frame was output, false if no more frames
     */
    virtual bool flush(std::vector<cv::Mat> &outputs) = 0;

    /**
     * Configure plugin with all input/output dimensions
     *
     * Called during filter configuration. Plugin sets output dimensions based
     * on all inputs. Each output's width/height is initialized to corresponding
     * input's dimensions (output[i] = input[i], or input[0] if i >= num_inputs).
     *
     * @param inputs   Input configurations (read-only)
     * @param outputs  Output configurations (plugin fills width/height)
     * @return true on success
     */
    virtual bool configure(const std::vector<QuinkOCFrameConfig> &inputs,
                           std::vector<QuinkOCFrameConfig> &outputs) = 0;
};

/*===========================================================================
 * CUDA Process Plugin Class
 *
 * For plugins that transform video frames using CUDA.
 * Works with AV_PIX_FMT_CUDA frames for zero-copy GPU processing.
 * Inherit from this class and implement process(), flush(), configure().
 *
 * Supported I/O modes:
 *   - 1:1 (single-input, single-output)
 *   - N:1 (multi-input, single-output) - compositing, blending
 *   - 1:N (single-input, multi-output) - splitting
 *
 * Data flow:
 *   inputs --> process() --> QUINK_OC_OK:        outputs ready
 *                        --> QUINK_OC_TRY_AGAIN: buffered, no output yet
 *                        --> QUINK_OC_ERROR:     error
 *
 *   EOF --> flush() --> output buffered frames
 *
 * NOTE: The stream parameter is provided by FFmpeg from the CUDA device context.
 * All async GPU operations should use this stream for proper synchronization.
 * FFmpeg will synchronize the stream after process() returns.
 *===========================================================================*/

class QuinkOCCudaProcessPlugin : public QuinkOCPluginBase {
public:
    /**
     * Process frames on CUDA GPU
     *
     * This method is called for each set of input frames.
     * All data remains on GPU - no CPU<->GPU transfers.
     *
     * Allowed usage for outputs:
     *   1. Write directly to output buffer: input.copyTo(output, stream)
     *   2. Zero-copy pass-through: output = input
     *
     * NOT allowed (will cause error):
     *   - output = input.clone() (defeats zero-copy, use copyTo instead)
     *   - output.create(...) or any reallocation
     *
     * @param inputs   Input cv::cuda::GpuMat images (zero-copy from CUDA AVFrame, refcount tied)
     * @param outputs  Output cv::cuda::GpuMat images (pre-allocated GPU buffer, refcount tied)
     * @param stream   CUDA stream for async operations (from FFmpeg's CUDA device context)
     * @return QUINK_OC_OK:        success, output ready
     *         QUINK_OC_TRY_AGAIN: success, buffered, no output yet
     *         QUINK_OC_ERROR:     processing error
     */
    virtual QuinkOCProcessResult process(const std::vector<cv::cuda::GpuMat> &inputs,
                                         std::vector<cv::cuda::GpuMat> &outputs,
                                         cv::cuda::Stream &stream) = 0;

    /**
     * Flush buffered frames at end of stream
     *
     * Called when input stream ends. The plugin should output any remaining
     * buffered frames. This method may be called multiple times until it
     * returns false (no more frames to output).
     *
     * @param outputs  Output buffer to write flushed frame into
     * @param stream   CUDA stream for async operations
     * @return true if a frame was output, false if no more frames
     */
    virtual bool flush(std::vector<cv::cuda::GpuMat> &outputs,
                       cv::cuda::Stream &stream) = 0;

    /**
     * Configure plugin with all input/output dimensions
     *
     * Called during filter configuration. Plugin sets output dimensions based
     * on all inputs. Each output's width/height is initialized to corresponding
     * input's dimensions (output[i] = input[i], or input[0] if i >= num_inputs).
     *
     * @param inputs   Input configurations (read-only)
     * @param outputs  Output configurations (plugin fills width/height)
     * @return true on success
     */
    virtual bool configure(const std::vector<QuinkOCFrameConfig> &inputs,
                           std::vector<QuinkOCFrameConfig> &outputs) = 0;
};

/*===========================================================================
 * Detect Plugin Class
 *
 * For plugins that analyze frames and produce detection results.
 * Inherit from this class and implement detect() and optionally flushDetect().
 *
 * DETECT plugins are always 1:1 (single-input, single-output).
 * The input frame passes through to output with detection results attached
 * as AV_FRAME_DATA_DETECTION_BBOXES side data.
 *
 * Data flow:
 *   input frame --> detect() --> QUINK_OC_OK:        output frame + detections
 *                            --> QUINK_OC_TRY_AGAIN: buffered, no output yet
 *                            --> QUINK_OC_ERROR:     error
 *
 *   EOF --> flushDetect() --> output buffered frames + detections
 *
 * This design supports:
 *   - Immediate detection: return QUINK_OC_OK for each frame
 *   - Multi-frame analysis: return QUINK_OC_TRY_AGAIN to buffer frames,
 *     then return QUINK_OC_OK when ready (e.g., tracking, action recognition)
 *===========================================================================*/

class QuinkOCDetectPlugin : public QuinkOCPluginBase {
public:
    /**
     * Perform object detection on input frame
     *
     * The plugin must retain a reference to the input Mat if buffering is needed.
     * When returning QUINK_OC_OK, the plugin should set `output` to the frame
     * to be output (typically the input or a buffered frame).
     *
     * @param input       Input cv::Mat image (zero-copy from FFmpeg, read-only)
     * @param output      Output cv::Mat (set to input for pass-through, or buffered frame)
     * @param detections  Output detection results for the output frame
     * @return QUINK_OC_OK:        success, output frame ready
     *         QUINK_OC_TRY_AGAIN: success, frame buffered, no output yet
     *         QUINK_OC_ERROR:     processing error
     */
    virtual QuinkOCProcessResult detect(const cv::Mat &input, cv::Mat &output,
                                        QuinkOCDetections &detections) = 0;

    /**
     * Flush buffered frames at end of stream
     *
     * Called when input stream ends. The plugin should output any remaining
     * buffered frames with their detection results. This method may be called
     * multiple times until it returns false.
     *
     * Default implementation returns false (no buffering).
     *
     * @param output      Output cv::Mat (the buffered frame to output)
     * @param detections  Detection results for the output frame
     * @return true if a frame was output, false if no more frames
     */
    virtual bool flushDetect(cv::Mat &output, QuinkOCDetections &detections) = 0;
};

/**
 * Plugin Descriptor
 *
 * Contains plugin metadata and factory functions.
 * Plugins export a single function that returns a pointer to a static descriptor.
 */
struct QuinkOCPluginDescriptor {
    int api_version;            ///< Must be QUINK_OC_PLUGIN_API_VERSION
    const char *name;           ///< Plugin name
    const char *description;    ///< Plugin description
    unsigned int capabilities;  ///< Bitmask of QuinkOCCapability flags

    QuinkOCPluginBase* (*create)();            ///< Create plugin instance
    void (*destroy)(QuinkOCPluginBase* p);     ///< Destroy plugin instance
};

typedef const QuinkOCPluginDescriptor* (*QuinkOCPluginGetDescriptorFunc)();

/** Symbol name to load from shared library */
#define QUINK_OC_PLUGIN_DESCRIPTOR_SYMBOL "quink_oc_plugin_get_descriptor"

#if defined(_WIN32) || defined(_WIN64)
    #define QUINK_OC_EXPORT __declspec(dllexport)
#else
    #define QUINK_OC_EXPORT __attribute__((visibility("default")))
#endif

/**
 * Plugin entry macro for PROCESS plugins
 *
 * Usage: QUINK_OC_PROCESS_PLUGIN_ENTRY(PluginClass, "name", "description")
 *
 * Example:
 *   class BlurPlugin : public QuinkOCProcessPlugin { ... };
 *   QUINK_OC_PROCESS_PLUGIN_ENTRY(BlurPlugin, "blur", "Gaussian blur filter")
 */
#define QUINK_OC_PROCESS_PLUGIN_ENTRY(PluginClass, plugin_name, plugin_desc) \
    static QuinkOCPluginBase* _quink_create() { return new PluginClass(); } \
    static void _quink_destroy(QuinkOCPluginBase* p) { delete p; } \
    extern "C" QUINK_OC_EXPORT const QuinkOCPluginDescriptor* quink_oc_plugin_get_descriptor() { \
        static const QuinkOCPluginDescriptor desc = { \
            QUINK_OC_PLUGIN_API_VERSION, \
            plugin_name, \
            plugin_desc, \
            QUINK_OC_CAP_PROCESS, \
            _quink_create, \
            _quink_destroy \
        }; \
        return &desc; \
    }

/**
 * Plugin entry macro for CUDA PROCESS plugins
 *
 * Usage: QUINK_OC_CUDA_PROCESS_PLUGIN_ENTRY(PluginClass, "name", "description")
 *
 * Example:
 *   class CudaBlurPlugin : public QuinkOCCudaProcessPlugin { ... };
 *   QUINK_OC_CUDA_PROCESS_PLUGIN_ENTRY(CudaBlurPlugin, "cuda_blur", "CUDA Gaussian blur filter")
 */
#define QUINK_OC_CUDA_PROCESS_PLUGIN_ENTRY(PluginClass, plugin_name, plugin_desc) \
    static QuinkOCPluginBase* _quink_create() { return new PluginClass(); } \
    static void _quink_destroy(QuinkOCPluginBase* p) { delete p; } \
    extern "C" QUINK_OC_EXPORT const QuinkOCPluginDescriptor* quink_oc_plugin_get_descriptor() { \
        static const QuinkOCPluginDescriptor desc = { \
            QUINK_OC_PLUGIN_API_VERSION, \
            plugin_name, \
            plugin_desc, \
            QUINK_OC_CAP_CUDA_PROCESS, \
            _quink_create, \
            _quink_destroy \
        }; \
        return &desc; \
    }

/**
 * Plugin entry macro for DETECT plugins
 *
 * Usage: QUINK_OC_DETECT_PLUGIN_ENTRY(PluginClass, "name", "description")
 *
 * Example:
 *   class YoloPlugin : public QuinkOCDetectPlugin { ... };
 *   QUINK_OC_DETECT_PLUGIN_ENTRY(YoloPlugin, "yolo", "YOLO object detector")
 */
#define QUINK_OC_DETECT_PLUGIN_ENTRY(PluginClass, plugin_name, plugin_desc) \
    static QuinkOCPluginBase* _quink_create() { return new PluginClass(); } \
    static void _quink_destroy(QuinkOCPluginBase* p) { delete p; } \
    extern "C" QUINK_OC_EXPORT const QuinkOCPluginDescriptor* quink_oc_plugin_get_descriptor() { \
        static const QuinkOCPluginDescriptor desc = { \
            QUINK_OC_PLUGIN_API_VERSION, \
            plugin_name, \
            plugin_desc, \
            QUINK_OC_CAP_DETECT, \
            _quink_create, \
            _quink_destroy \
        }; \
        return &desc; \
    }

#endif /* AVFILTER_QUINK_OC_PLUGIN_H */
