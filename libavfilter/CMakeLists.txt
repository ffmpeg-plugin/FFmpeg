# libavfilter CMakeLists.txt
# Auto-scans filter source files and generates allfilters.c / filter_list.c

# ============================================================================
# Core sources (unconditional)
# ============================================================================
set(avfilter_sources
    audio.c
    avfilter.c
    avfiltergraph.c
    buffersink.c
    buffersrc.c
    colorspace.c
    colorspacedsp.c
    ccfifo.c
    drawutils.c
    ebur128.c
    edge_common.c
    formats.c
    framepool.c
    framequeue.c
    framesync.c
    graphdump.c
    graphparser.c
    lavfutils.c
    log2_tab.c
    motion_estimation.c
    palette.c
    perlin.c
    psnr.c
    qp_table.c
    scale_eval.c
    scene_sad.c
    setpts.c
    settb.c
    split.c
    src_avsynctest.c
    src_movie.c
    textutils.c
    transform.c
    trim.c
    version.c
    video.c
    yadif_common.c
    bbox.c
    boxblur.c
    bwdifdsp.c
    # libswscale helper (always available since swscale is built-in)
    lswsutils.c
    # DSP helpers (compiled but don't define FFFilter symbols)
    vf_fsppdsp.c
    vf_idetdsp.c
)

# pthread.c is needed when threads are available
if(HAVE_THREADS)
    list(APPEND avfilter_sources pthread.c)
endif()

# file_open.c needed on Windows (MSVCRT)
if(HAVE_LIBC_MSVCRT)
    list(APPEND avfilter_sources file_open.c)
endif()

# ============================================================================
# Filters that require external libraries not available by default.
# These are excluded from the auto-scan to avoid build failures.
# ============================================================================
set(avfilter_excluded_filters
    # pocketsphinx (speech recognition)
    af_asr.c
    # libbs2b (Bauer stereophonic-to-binaural DSP)
    af_bs2b.c
    # LV2 plugin support (lilv)
    af_lv2.c
    # LADSPA plugin support (ladspa.h)
    af_ladspa.c
    # librubberband (time-stretching)
    af_rubberband.c
    # libmysofa (SOFA/HRTF)
    af_sofalizer.c
    # whisper.cpp (speech recognition)
    af_whisper.c
    # flite (text-to-speech)
    asrc_flite.c
    # libzmq (ZeroMQ messaging)
    f_zmq.c
    # AMF (AMD Advanced Media Framework) - Windows only
    vf_amf_common.c
    vf_sr_amf.c
    vf_vpp_amf.c
    vsrc_amf.c
    # frei0r plugin support
    vf_frei0r.c
    vsrc_frei0r_src.c
    # lcms2 (color management)
    vf_iccdetect.c
    vf_iccgen.c
    # LCEVC (Low Complexity Enhancement Video Coding)
    vf_lcevc.c
    # lensfun (lens correction)
    vf_lensfun.c
    # libopencv
    vf_libopencv.c
    # libplacebo (GPU-accelerated video processing)
    vf_libplacebo.c
    # libvmaf (video quality assessment)
    vf_libvmaf.c
    vf_libvmaf_cuda.c
    # tesseract OCR
    vf_ocr.c
    # OpenColorIO
    vf_opencolorio.c
    # quirc (QR code decoder)
    vf_quirc.c
    # NVIDIA NPP (CUDA image processing)
    vf_scale_npp.c
    vf_sharpen_npp.c
    vf_transpose_npp.c
    # VideoToolbox (macOS only)
    vf_scale_vt.c
    vf_transpose_vt.c
    vf_yadif_videotoolbox.c
    # libass (subtitle rendering)
    vf_subtitles.c
    # vid.stab (video stabilization)
    vf_vidstabdetect.c
    vf_vidstabtransform.c
    # zimg/zscale
    vf_zscale.c
    # DirectX/Windows only
    vf_deinterlace_d3d12.c
    vsrc_ddagrab.c
    vsrc_gfxcapture.c
    # QSV (Intel Quick Sync Video) - requires MFX
    qsvvpp.c
    vf_deinterlace_qsv.c
    vf_hstack_qsv.c
    vf_overlay_qsv.c
    vf_scale_qsv.c
    vf_stack_qsv.c
    vf_vpp_qsv.c
    vf_vstack_qsv.c
    vf_xstack_qsv.c
    # D3D11/D3D12 (Windows only)
    vf_scale_d3d11.c
    vf_scale_d3d12.c
    vf_mestimate_d3d12.c
    # CoreImage (macOS only)
    vf_coreimage.c
    vsrc_coreimagesrc.c
    # Cairo (vector graphics)
    vf_drawvg.c
    # DNN-based filters (require DNN backend - libtensorflow, libopenvino, etc.)
    vf_derain.c
    vf_sr.c
    # CUDA PTX data (pre-compiled GPU kernels)
    vf_overlay_cuda_ptx_data.c
    vf_scale_cuda_ptx_data.c
    vf_yadif_cuda_ptx_data.c
    # Vulkan filters (require Vulkan SDK + glslang)
    vf_avgblur_vulkan.c
    vf_bwdif_vulkan.c
    vf_chromaber_vulkan.c
    vf_color_vulkan.c
    vf_colorspace_vulkan.c
    vf_convolution_vulkan.c
    vf_deshake_vulkan.c
    vf_flip_vulkan.c
    vf_gblur_vulkan.c
    vf_hflip_vulkan.c
    vf_nlmeans_vulkan.c
    vf_overlay_vulkan.c
    vf_pad_vulkan.c
    vf_remap_vulkan.c
    vf_scale_vulkan.c
    vf_sharpen_vulkan.c
    vf_tonemap_vulkan.c
    vf_transpose_vulkan.c
    vf_unsharp_vulkan.c
    vf_xfade_vulkan.c
    vsrc_testsrc_vulkan.c
    # Vulkan/OpenCL shared helpers
    vulkan.c
    vulkan_filter.c
    vulkan_spirv.c
    opencl.c
    # OpenCL filters
    vf_avgblur_opencl.c
    vf_boxblur_opencl.c
    vf_colorkey_opencl.c
    vf_colorspace_opencl.c
    vf_convolution_opencl.c
    vf_deshake_opencl.c
    vf_nlmeans_opencl.c
    vf_overlay_opencl.c
    vf_pad_opencl.c
    vf_remap_opencl.c
    vf_tonemap_opencl.c
    vf_transpose_opencl.c
    vf_unsharp_opencl.c
    vf_xfade_opencl.c
    # VAAPI shared helper + filters (excluded here, added conditionally below)
    vaapi_vpp.c
    vf_misc_vaapi.c
    vf_stack_vaapi.c
    vf_drawbox_vaapi.c
    vf_hstack_vaapi.c
    vf_pad_vaapi.c
    vf_procamp_vaapi.c
    vf_vstack_vaapi.c
    vf_xstack_vaapi.c
    vf_deinterlace_vaapi.c
    vf_overlay_vaapi.c
    vf_scale_vaapi.c
    vf_tonemap_vaapi.c
    vf_transpose_vaapi.c
    # Windows-only DirectShow/DDA capture
    vsrc_ddagrab.c
    # af_biquads.c uses macros to define filters - handled specially below
    af_biquads.c
    # CUDA filters (require CUDA SDK)
    vf_bilateral_cuda.c
    vf_bwdif_cuda.c
    vf_chromakey_cuda.c
    vf_colorspace_cuda.c
    vf_overlay_cuda.c
    vf_pad_cuda.c
    vf_scale_cuda.c
    vf_thumbnail_cuda.c
    vf_yadif_cuda.c
    # DNN (deep neural network) filters (require DNN backend)
    dnn_filter_common.c
    vf_dnn_classify.c
    vf_dnn_detect.c
    vf_dnn_processing.c
    # DSP helpers that are included by other files (not standalone filters)
    vf_fsppdsp.c
    vf_idetdsp.c
    # vf_neighbor.c uses macros to define filters - handled specially below
    vf_neighbor.c
    # All Vulkan filters (require Vulkan SDK + glslang)
    vf_blackdetect_vulkan.c
    vf_blend_vulkan.c
    vf_interlace_vulkan.c
    vf_scdet_vulkan.c
    vf_color_vulkan.c
    vf_colorspace_vulkan.c
    vf_deshake_vulkan.c
    vf_flip_vulkan.c
    vf_gblur_vulkan.c
    vf_hflip_vulkan.c
    vf_nlmeans_vulkan.c
    vf_overlay_vulkan.c
    vf_pad_vulkan.c
    vf_remap_vulkan.c
    vf_scale_vulkan.c
    vf_sharpen_vulkan.c
    vf_tonemap_vulkan.c
    vf_transpose_vulkan.c
    vf_unsharp_vulkan.c
    vf_xfade_vulkan.c
    vf_avgblur_vulkan.c
    vf_bwdif_vulkan.c
    vf_chromaber_vulkan.c
    vf_convolution_vulkan.c
    vsrc_testsrc_vulkan.c
    # All OpenCL filters (require OpenCL)
    vf_avgblur_opencl.c
    vf_boxblur_opencl.c
    vf_colorkey_opencl.c
    vf_colorspace_opencl.c
    vf_convolution_opencl.c
    vf_deshake_opencl.c
    vf_nlmeans_opencl.c
    vf_overlay_opencl.c
    vf_pad_opencl.c
    vf_remap_opencl.c
    vf_tonemap_opencl.c
    vf_transpose_opencl.c
    vf_unsharp_opencl.c
    vf_xfade_opencl.c
    vf_neighbor_opencl.c
    vf_program_opencl.c
    vf_erosion_opencl.c
    vf_dilation_opencl.c
    # CUDA hwupload
    vf_hwupload_cuda.c
    # vf_lut.c uses DEFINE_LUT_FILTER macro to define multiple filters - handled specially below
    vf_lut.c
)

# ============================================================================
# Auto-discover all filter source files
# Patterns: af_*.c  vf_*.c  avf_*.c  vaf_*.c
#           asrc_*.c  vsrc_*.c  avsrc_*.c
#           asink_*.c vsink_*.c
#           f_*.c  (multimedia)
#           aeval.c generate_wave_table.c (helpers)
# ============================================================================
file(GLOB avfilter_filter_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/af_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/vf_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/avf_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/vaf_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/asrc_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/vsrc_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/avsrc_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/asink_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/vsink_*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/f_*.c"
)

# Add helper files that are needed by filters
# Note: generate_wave_table.c is a pure helper (no FFFilter symbols)
# aeval.c is NOT a pure helper - it defines ff_af_aeval and ff_asrc_aevalsrc
# so it is included in the normal filter scan below
foreach(helper generate_wave_table.c)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${helper}")
        list(APPEND avfilter_filter_sources "${CMAKE_CURRENT_SOURCE_DIR}/${helper}")
    endif()
endforeach()
# Add aeval.c as a regular filter source (it defines ff_af_aeval + ff_asrc_aevalsrc)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/aeval.c")
    list(APPEND avfilter_filter_sources "${CMAKE_CURRENT_SOURCE_DIR}/aeval.c")
endif()

# Convert absolute paths to relative paths and collect filter symbols
set(avfilter_filter_symbols "")
set(avfilter_filter_rel_sources "")

foreach(src_abs IN LISTS avfilter_filter_sources)
    get_filename_component(src_name "${src_abs}" NAME)
    get_filename_component(src_base "${src_abs}" NAME_WE)

    # Skip excluded filters (those requiring external libraries)
    if("${src_name}" IN_LIST avfilter_excluded_filters)
        message(STATUS "avfilter: skipping filter requiring external lib: ${src_name}")
        continue()
    endif()

    # Determine the filter symbol name from the filename
    # e.g. af_volume.c -> ff_af_volume
    #      vf_scale.c  -> ff_vf_scale
    # Skip helper files that don't define a filter symbol
    # Note: aeval.c is NOT a helper - it defines real filters
    set(is_helper FALSE)
    foreach(h generate_wave_table)
        if("${src_base}" STREQUAL "${h}")
            set(is_helper TRUE)
        endif()
    endforeach()

    list(APPEND avfilter_filter_rel_sources "${src_name}")

    if(NOT is_helper)
        # Always scan file content to find actual FFFilter symbols.
        # Some files (e.g. vf_aspect.c) define filters with different names than
        # the filename suggests (ff_vf_setdar/ff_vf_setsar instead of ff_vf_aspect).
        # Some files (e.g. vf_fsppdsp.c, vf_idetdsp.c) are DSP helpers with no filter.
        file(STRINGS "${src_abs}" _filter_lines REGEX "^const FFFilter ff_[a-zA-Z0-9_]+ =")
        if(_filter_lines)
            foreach(_fline IN LISTS _filter_lines)
                string(REGEX MATCH "ff_[a-zA-Z0-9_]+" _fsym "${_fline}")
                if(_fsym)
                    list(APPEND avfilter_filter_symbols "${_fsym}")
                endif()
            endforeach()
        else()
            # Fallback: use filename-based symbol (for files that use macros to define filters)
            set(sym "ff_${src_base}")
            list(APPEND avfilter_filter_symbols "${sym}")
        endif()
    endif()
endforeach()

# Add filter sources to main list
list(APPEND avfilter_sources ${avfilter_filter_rel_sources})

# Add vf_neighbor.c manually (uses macros to define filters, not detectable by file scan)
# It defines: ff_vf_erosion, ff_vf_dilation, ff_vf_deflate, ff_vf_inflate
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/vf_neighbor.c")
    list(APPEND avfilter_sources "vf_neighbor.c")
    list(APPEND avfilter_filter_symbols
        ff_vf_erosion
        ff_vf_dilation
        ff_vf_deflate
        ff_vf_inflate
    )
endif()

# Add af_biquads.c manually (uses macros to define filters, not detectable by file scan)
# It defines: ff_af_equalizer, ff_af_bass, ff_af_lowshelf, ff_af_treble, ff_af_highshelf,
#             ff_af_tiltshelf, ff_af_bandpass, ff_af_bandreject, ff_af_lowpass,
#             ff_af_highpass, ff_af_allpass, ff_af_biquad
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/af_biquads.c")
    list(APPEND avfilter_sources "af_biquads.c")
    list(APPEND avfilter_filter_symbols
        ff_af_equalizer
        ff_af_bass
        ff_af_lowshelf
        ff_af_treble
        ff_af_highshelf
        ff_af_tiltshelf
        ff_af_bandpass
        ff_af_bandreject
        ff_af_lowpass
        ff_af_highpass
        ff_af_allpass
        ff_af_biquad
    )
endif()

# Add vf_lut.c manually (uses DEFINE_LUT_FILTER macro to define multiple filters)
# It defines: ff_vf_lut, ff_vf_lutyuv, ff_vf_lutrgb
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/vf_lut.c")
    list(APPEND avfilter_sources "vf_lut.c")
    list(APPEND avfilter_filter_symbols
        ff_vf_lut
        ff_vf_lutyuv
        ff_vf_lutrgb
    )
endif()

# Add VAAPI VPP helper and filters if VAAPI is available
if(CONFIG_VAAPI)
    foreach(_vaapi_src
        vaapi_vpp.c
        vf_misc_vaapi.c
        vf_stack_vaapi.c
        vf_drawbox_vaapi.c
        vf_hstack_vaapi.c
        vf_pad_vaapi.c
        vf_procamp_vaapi.c
        vf_vstack_vaapi.c
        vf_xstack_vaapi.c
    )
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_vaapi_src}")
            list(APPEND avfilter_sources "${_vaapi_src}")
            # Scan for filter symbols in VAAPI filter files
            file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/${_vaapi_src}" _vaapi_lines
                REGEX "^const FFFilter ff_[a-zA-Z0-9_]+ =")
            foreach(_vline IN LISTS _vaapi_lines)
                string(REGEX MATCH "ff_[a-zA-Z0-9_]+" _vsym "${_vline}")
                if(_vsym)
                    list(APPEND avfilter_filter_symbols "${_vsym}")
                endif()
            endforeach()
        endif()
    endforeach()
endif()

# ============================================================================
# Special buffer/abuffer filters (always needed, defined in buffersrc/sink)
# ============================================================================
set(avfilter_buffer_symbols
    ff_asrc_abuffer
    ff_vsrc_buffer
    ff_asink_abuffer
    ff_vsink_buffer
)

# ============================================================================
# Generate filter_list.c
# ============================================================================
set(FILTER_LIST_CONTENT "static const FFFilter * const filter_list[] = {\n")
foreach(sym IN LISTS avfilter_filter_symbols)
    string(APPEND FILTER_LIST_CONTENT "    &${sym},\n")
endforeach()
# Add buffer filters
foreach(sym IN LISTS avfilter_buffer_symbols)
    string(APPEND FILTER_LIST_CONTENT "    &${sym},\n")
endforeach()
string(APPEND FILTER_LIST_CONTENT "    NULL,\n};\n")

file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/filter_list.c" "${FILTER_LIST_CONTENT}")

# ============================================================================
# Generate allfilters.c
# ============================================================================
set(ALLFILTERS_CONTENT
"/*
 * filter registration - auto-generated by CMake
 * Based on libavfilter/allfilters.c
 */

#include \"avfilter.h\"
#include \"filters.h\"

")

foreach(sym IN LISTS avfilter_filter_symbols)
    string(APPEND ALLFILTERS_CONTENT "extern const FFFilter ${sym};\n")
endforeach()

string(APPEND ALLFILTERS_CONTENT "\n/* buffer/abuffer filters */\n")
foreach(sym IN LISTS avfilter_buffer_symbols)
    string(APPEND ALLFILTERS_CONTENT "extern  const FFFilter ${sym};\n")
endforeach()

string(APPEND ALLFILTERS_CONTENT "
#include \"libavfilter/filter_list.c\"

const AVFilter *av_filter_iterate(void **opaque)
{
    uintptr_t i = (uintptr_t)*opaque;
    const FFFilter *f = filter_list[i];

    if (f) {
        *opaque = (void*)(i + 1);
        return &f->p;
    }

    return NULL;
}

const AVFilter *avfilter_get_by_name(const char *name)
{
    const AVFilter *f = NULL;
    void *opaque = 0;

    if (!name)
        return NULL;

    while ((f = av_filter_iterate(&opaque)))
        if (!strcmp(f->name, name))
            return f;

    return NULL;
}
")

file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c" "${ALLFILTERS_CONTENT}")

# Use the generated allfilters.c instead of the source one
list(APPEND avfilter_sources "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c")

# ============================================================================
# Architecture-specific sources
# ============================================================================
if(ARCH_X86 AND ENABLE_ASM)
    # Auto-scan all .c files in x86/ subdirectory
    file(GLOB _avfilter_x86_c "${CMAKE_CURRENT_SOURCE_DIR}/x86/*.c")
    foreach(_src_abs IN LISTS _avfilter_x86_c)
        get_filename_component(_src_name "${_src_abs}" NAME)
        if("${_src_name}" MATCHES "_template\\.c$")
            continue()
        endif()
        list(APPEND avfilter_sources "x86/${_src_name}")
    endforeach()

    if(HAVE_X86ASM)
        file(GLOB _avfilter_x86_asm "${CMAKE_CURRENT_SOURCE_DIR}/x86/*.asm")
        foreach(_src_abs IN LISTS _avfilter_x86_asm)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avfilter_sources "x86/${_src_name}")
        endforeach()
    endif()
endif()

if(ARCH_AARCH64 AND ENABLE_ASM)
    file(GLOB _avfilter_aarch64_c "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/*.c")
    foreach(_src_abs IN LISTS _avfilter_aarch64_c)
        get_filename_component(_src_name "${_src_abs}" NAME)
        list(APPEND avfilter_sources "aarch64/${_src_name}")
    endforeach()
    if(HAVE_ARMASM OR HAVE_AS_ARCH_DIRECTIVE)
        file(GLOB _avfilter_aarch64_asm "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/*.S")
        foreach(_src_abs IN LISTS _avfilter_aarch64_asm)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avfilter_sources "aarch64/${_src_name}")
        endforeach()
    endif()
endif()

# Remove duplicates
list(REMOVE_DUPLICATES avfilter_sources)

# Filter out source files that don't exist (for relative paths)
set(avfilter_sources_filtered "")
foreach(src IN LISTS avfilter_sources)
    if(IS_ABSOLUTE "${src}")
        # Absolute path (generated file) - always include
        list(APPEND avfilter_sources_filtered "${src}")
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND avfilter_sources_filtered "${src}")
    else()
        message(STATUS "avfilter: skipping missing source file: ${src}")
    endif()
endforeach()
set(avfilter_sources ${avfilter_sources_filtered})

# ============================================================================
# Create the library
# ============================================================================
add_library(avfilter STATIC ${avfilter_sources})

# Include directories
target_include_directories(avfilter
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/libavfilter>
)

# Link dependencies
target_link_libraries(avfilter
    PRIVATE
        swscale
        avformat
        avcodec
        swresample
        avutil
        Threads::Threads
)

# Link FriBidi if available (needed for vf_drawtext bidirectional text)
if(CONFIG_LIBFRIBIDI AND LIBFRIBIDI_LIBRARIES)
    target_link_libraries(avfilter PRIVATE ${LIBFRIBIDI_LIBRARIES})
    if(LIBFRIBIDI_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${LIBFRIBIDI_INCLUDE_DIRS})
    endif()
    if(LIBFRIBIDI_LIBRARY_DIRS)
        target_link_directories(avfilter PRIVATE ${LIBFRIBIDI_LIBRARY_DIRS})
    endif()
endif()

# Link FreeType2 if available (needed for vf_drawtext)
if(Freetype_FOUND OR FREETYPE_FOUND)
    if(Freetype_FOUND)
        target_link_libraries(avfilter PRIVATE Freetype::Freetype)
    elseif(TARGET PkgConfig::FREETYPE)
        target_link_libraries(avfilter PRIVATE PkgConfig::FREETYPE)
    else()
        target_link_libraries(avfilter PRIVATE ${FREETYPE_LIBRARIES})
        target_include_directories(avfilter PRIVATE ${FREETYPE_INCLUDE_DIRS})
        if(FREETYPE_LIBRARY_DIRS)
            target_link_directories(avfilter PRIVATE ${FREETYPE_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link HarfBuzz if available (needed for vf_drawtext text shaping)
if(HARFBUZZ_FOUND)
    if(TARGET PkgConfig::HARFBUZZ)
        target_link_libraries(avfilter PRIVATE PkgConfig::HARFBUZZ)
    else()
        target_link_libraries(avfilter PRIVATE ${HARFBUZZ_LIBRARIES})
        target_include_directories(avfilter PRIVATE ${HARFBUZZ_INCLUDE_DIRS})
        if(HARFBUZZ_LIBRARY_DIRS)
            target_link_directories(avfilter PRIVATE ${HARFBUZZ_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link Vulkan if available (needed for Vulkan filters)
if(Vulkan_FOUND)
    target_link_libraries(avfilter PRIVATE Vulkan::Vulkan)
    target_include_directories(avfilter PRIVATE ${Vulkan_INCLUDE_DIRS})
endif()

# Link Fontconfig if available (needed for avf_showcqt font lookup)
if(FONTCONFIG_FOUND)
    if(TARGET PkgConfig::FONTCONFIG)
        target_link_libraries(avfilter PRIVATE PkgConfig::FONTCONFIG)
    else()
        target_link_libraries(avfilter PRIVATE ${FONTCONFIG_LIBRARIES})
        target_include_directories(avfilter PRIVATE ${FONTCONFIG_INCLUDE_DIRS})
        if(FONTCONFIG_LIBRARY_DIRS)
            target_link_directories(avfilter PRIVATE ${FONTCONFIG_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link VAAPI if available (needed for vaapi_vpp.c and VAAPI filters)
if(CONFIG_VAAPI AND VAAPI_FOUND)
    target_link_libraries(avfilter PRIVATE ${VAAPI_LIBRARIES})
    target_include_directories(avfilter PRIVATE ${VAAPI_INCLUDE_DIRS})
endif()

# Compiler definitions
target_compile_definitions(avfilter PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avfilter
)

# Position independent code for shared builds
set_pic_if_needed(avfilter)

# Set output name
set_target_properties(avfilter PROPERTIES
    OUTPUT_NAME avfilter
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

message(STATUS "libavfilter configured with ${avfilter_filter_symbols_count} filters")
