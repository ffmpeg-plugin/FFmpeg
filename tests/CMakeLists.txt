# FFmpeg Tests CMakeLists.txt
# FATE testing support with CMake integration

cmake_minimum_required(VERSION 3.16)

# Include FATE test framework
include(${CMAKE_SOURCE_DIR}/cmake/FFmpegFATETests.cmake)

# =============================================================================
# Configuration
# =============================================================================

# FATE samples directory (can be set via -DFATE_SAMPLES_DIR=path or SAMPLES env var)
if(DEFINED ENV{SAMPLES} AND NOT FATE_SAMPLES_DIR)
    set(FATE_SAMPLES_DIR "$ENV{SAMPLES}" CACHE PATH "Path to FATE test samples")
endif()

# Tool paths
set(FFMPEG_TOOL $<TARGET_FILE:ffmpeg>)
set(FFPROBE_TOOL $<TARGET_FILE:ffprobe>)
set(FFPLAY_TOOL $<TARGET_FILE:ffplay>)

# =============================================================================
# Test Utility Executables
# =============================================================================

# tiny_psnr - PSNR comparison tool
add_executable(tiny_psnr
    tiny_psnr.c
)
target_link_libraries(tiny_psnr PRIVATE avutil)
# These test tools don't have full prototype declarations, disable the warning
target_compile_options(tiny_psnr PRIVATE
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-missing-prototypes>
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-error=missing-prototypes>)

# tiny_ssim - SSIM comparison tool
add_executable(tiny_ssim
    tiny_ssim.c
)
target_link_libraries(tiny_ssim PRIVATE avutil)
target_compile_options(tiny_ssim PRIVATE
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-missing-prototypes>
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-error=missing-prototypes>)

# audiomatch - Audio comparison tool
add_executable(audiomatch
    audiomatch.c
)
target_link_libraries(audiomatch PRIVATE avutil)
target_compile_options(audiomatch PRIVATE
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-missing-prototypes>
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-error=missing-prototypes>)

# base64 - Base64 encoding/decoding utility
add_executable(base64
    base64.c
)
target_compile_options(base64 PRIVATE
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-missing-prototypes>
    $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wno-error=missing-prototypes>)

# =============================================================================
# Simple smoke tests (no samples required)
# =============================================================================

enable_testing()

# Test 1: ffmpeg -version
add_test(NAME smoke_ffmpeg_version
    COMMAND ${FFMPEG_TOOL} -version
)
set_tests_properties(smoke_ffmpeg_version PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 2: ffprobe -version
add_test(NAME smoke_ffprobe_version
    COMMAND ${FFPROBE_TOOL} -version
)
set_tests_properties(smoke_ffprobe_version PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 3: ffmpeg -formats
add_test(NAME smoke_ffmpeg_formats
    COMMAND ${FFMPEG_TOOL} -formats
)
set_tests_properties(smoke_ffmpeg_formats PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 4: ffmpeg -codecs
add_test(NAME smoke_ffmpeg_codecs
    COMMAND ${FFMPEG_TOOL} -codecs
)
set_tests_properties(smoke_ffmpeg_codecs PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 5: ffmpeg -filters
add_test(NAME smoke_ffmpeg_filters
    COMMAND ${FFMPEG_TOOL} -filters
)
set_tests_properties(smoke_ffmpeg_filters PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 6: ffmpeg -encoders
add_test(NAME smoke_ffmpeg_encoders
    COMMAND ${FFMPEG_TOOL} -encoders
)
set_tests_properties(smoke_ffmpeg_encoders PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 7: ffmpeg -decoders
add_test(NAME smoke_ffmpeg_decoders
    COMMAND ${FFMPEG_TOOL} -decoders
)
set_tests_properties(smoke_ffmpeg_decoders PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# Test 8: ffmpeg -hwaccels
add_test(NAME smoke_ffmpeg_hwaccels
    COMMAND ${FFMPEG_TOOL} -hwaccels
)
set_tests_properties(smoke_ffmpeg_hwaccels PROPERTIES
    LABELS "smoke;basic"
    TIMEOUT 10
)

# =============================================================================
# Basic encode/decode tests (synthetic, no samples)
# =============================================================================

# Test audio encoding: generate 1 second of silence
add_test(NAME encode_audio_silence
    COMMAND ${FFMPEG_TOOL} -f lavfi -i anullsrc=r=44100:cl=stereo -t 1 -c:a pcm_s16le -f wav -
)
set_tests_properties(encode_audio_silence PROPERTIES
    LABELS "encode;audio;synthetic"
    TIMEOUT 30
)

# Test video encoding: generate 1 frame of color
add_test(NAME encode_video_color
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -c:v rawvideo -f rawvideo -y ${CMAKE_CURRENT_BINARY_DIR}/test.raw
)
set_tests_properties(encode_video_color PROPERTIES
    LABELS "encode;video;synthetic"
    TIMEOUT 30
)

# Test container format: generate empty MP4
add_test(NAME container_mp4_synthetic
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1
                               -f lavfi -i anullsrc=r=44100:cl=mono:d=0.1
                               -c:v mpeg4 -c:a aac -f mp4 -y ${CMAKE_CURRENT_BINARY_DIR}/test.mp4
)
set_tests_properties(container_mp4_synthetic PROPERTIES
    LABELS "encode;container;synthetic"
    TIMEOUT 30
)

# Test container format: generate MKV
add_test(NAME container_mkv_synthetic
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1
                               -f lavfi -i anullsrc=r=44100:cl=mono:d=0.1
                               -c:v libx264 -c:a aac -f matroska -y ${CMAKE_CURRENT_BINARY_DIR}/test.mkv
)
set_tests_properties(container_mkv_synthetic PROPERTIES
    LABELS "encode;container;synthetic"
    TIMEOUT 30
)

# =============================================================================
# FFprobe tests
# =============================================================================

# Test ffprobe on a synthetic stream
add_test(NAME ffprobe_synthetic_stream
    COMMAND ${FFPROBE_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -show_streams -show_format
)
set_tests_properties(ffprobe_synthetic_stream PROPERTIES
    LABELS "ffprobe;synthetic"
    TIMEOUT 10
)

# Test ffprobe JSON output
add_test(NAME ffprobe_json_output
    COMMAND ${FFPROBE_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -print_format json -show_streams
)
set_tests_properties(ffprobe_json_output PROPERTIES
    LABELS "ffprobe;synthetic;json"
    TIMEOUT 10
)

# Test ffprobe XML output
add_test(NAME ffprobe_xml_output
    COMMAND ${FFPROBE_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -print_format xml -show_streams
)
set_tests_properties(ffprobe_xml_output PROPERTIES
    LABELS "ffprobe;synthetic;xml"
    TIMEOUT 10
)

# =============================================================================
# API tests (tests/api/)
# =============================================================================

# Find all API test source files
file(GLOB API_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/api/*-test.c")

foreach(api_test_src ${API_TEST_SOURCES})
    # Extract test name from filename
    get_filename_component(test_file ${api_test_src} NAME)
    string(REPLACE ".c" "" test_name ${test_file})
    string(REPLACE "api-" "" test_short_name ${test_name})
    
    # Create executable
    add_executable(${test_name} ${api_test_src})
    
    # Set up include directories
    target_include_directories(${test_name}
        PRIVATE
            ${CMAKE_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}
    )
    
    # Link libraries
    set(api_test_libs
        avcodec
        avformat
        avutil
    )
    
    # Add thread support if needed
    if(CMAKE_THREAD_LIBS_INIT)
        list(APPEND api_test_libs ${CMAKE_THREAD_LIBS_INIT})
    endif()
    
    # macOS frameworks
    if(APPLE)
        find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
        find_library(COREMEDIA_FRAMEWORK CoreMedia)
        find_library(COREVIDEO_FRAMEWORK CoreVideo)
        find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
        find_library(SECURITY_FRAMEWORK Security)
        
        if(VIDEOTOOLBOX_FRAMEWORK)
            list(APPEND api_test_libs ${VIDEOTOOLBOX_FRAMEWORK})
        endif()
        if(COREMEDIA_FRAMEWORK)
            list(APPEND api_test_libs ${COREMEDIA_FRAMEWORK})
        endif()
        if(COREVIDEO_FRAMEWORK)
            list(APPEND api_test_libs ${COREVIDEO_FRAMEWORK})
        endif()
        if(COREFOUNDATION_FRAMEWORK)
            list(APPEND api_test_libs ${COREFOUNDATION_FRAMEWORK})
        endif()
        if(SECURITY_FRAMEWORK)
            list(APPEND api_test_libs ${SECURITY_FRAMEWORK})
        endif()
    endif()
    
    # External libraries
    if(ZLIB_FOUND)
        list(APPEND api_test_libs ZLIB::ZLIB)
    endif()
    
    if(Iconv_FOUND)
        list(APPEND api_test_libs Iconv::Iconv)
    endif()
    
    target_link_libraries(${test_name} PRIVATE ${api_test_libs})
    
    # Add CTest entry
    fate_add_api_test(${test_short_name} ${test_name})
endforeach()

# =============================================================================
# checkasm tests (assembly verification)
# =============================================================================

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/checkasm/checkasm.c)
    # Collect all checkasm C source files
    file(GLOB CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/*.c")

    # Remove test files for disabled filters/components that pull in
    # extra object dependencies not present in the library.
    # This mirrors the conditional compilation in tests/checkasm/Makefile:
    # each checkasm test file is only compiled when its corresponding
    # CONFIG_* option is enabled.

    # libavcodec subsystem tests
    if(NOT CONFIG_AC3DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/ac3dsp\\.c$")
    endif()
    if(NOT CONFIG_AUDIODSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/audiodsp\\.c$")
    endif()
    if(NOT CONFIG_BLOCKDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/blockdsp\\.c$")
    endif()
    if(NOT CONFIG_BSWAPDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/bswapdsp\\.c$")
    endif()
    if(NOT CONFIG_FDCTDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/fdctdsp\\.c$")
    endif()
    if(NOT CONFIG_FMTCONVERT)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/fmtconvert\\.c$")
    endif()
    if(NOT CONFIG_G722DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/g722dsp\\.c$")
    endif()
    if(NOT CONFIG_H263DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/h263dsp\\.c$")
    endif()
    if(NOT CONFIG_H264CHROMA)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/h264chroma\\.c$")
    endif()
    if(NOT CONFIG_H264DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/h264dsp\\.c$")
    endif()
    if(NOT CONFIG_H264PRED)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/h264pred\\.c$")
    endif()
    if(NOT CONFIG_H264QPEL)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/h264qpel\\.c$")
    endif()
    if(NOT CONFIG_HPELDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hpeldsp\\.c$")
    endif()
    if(NOT CONFIG_HUFFYUVDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/huffyuvdsp\\.c$")
    endif()
    if(NOT CONFIG_HUFFYUVENCDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/huffyuvencdsp\\.c$")
    endif()
    if(NOT CONFIG_IDCTDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/idctdsp\\.c$")
    endif()
    if(NOT CONFIG_LLAUDDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/llauddsp\\.c$")
    endif()
    if(NOT CONFIG_LLVIDDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/llviddsp\\.c$")
    endif()
    if(NOT CONFIG_LLVIDENCDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/llvidencdsp\\.c$")
    endif()
    if(NOT CONFIG_LPC)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/lpc\\.c$")
    endif()
    if(NOT CONFIG_ME_CMP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/motion\\.c$")
    endif()
    if(NOT CONFIG_MPEGVIDEO)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/mpegvideo_unquantize\\.c$")
    endif()
    if(NOT CONFIG_MPEGVIDEOENCDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/mpegvideoencdsp\\.c$")
    endif()
    if(NOT CONFIG_QPELDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/qpeldsp\\.c$")
    endif()
    if(NOT CONFIG_VC1DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vc1dsp\\.c$")
    endif()
    if(NOT CONFIG_VP3DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vp3dsp\\.c$")
    endif()
    if(NOT CONFIG_VP8DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vp8dsp\\.c$")
    endif()
    if(NOT CONFIG_VIDEODSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/videodsp\\.c$")
    endif()

    # libavcodec decoder/encoder tests
    if(NOT CONFIG_AAC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/aacpsdsp\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/sbrdsp\\.c$")
    endif()
    if(NOT CONFIG_AAC_ENCODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/aacencdsp\\.c$")
    endif()
    if(NOT CONFIG_ALAC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/alacdsp\\.c$")
    endif()
    if(NOT CONFIG_APV_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/apv_dsp\\.c$")
    endif()
    if(NOT CONFIG_CAVS_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/cavsdsp\\.c$")
    endif()
    if(NOT CONFIG_DCA_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/dcadsp\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/synth_filter\\.c$")
    endif()
    if(NOT CONFIG_DIRAC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/diracdsp\\.c$")
    endif()
    if(NOT CONFIG_EXR_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/exrdsp\\.c$")
    endif()
    if(NOT CONFIG_FLAC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/flacdsp\\.c$")
    endif()
    if(NOT CONFIG_JPEG2000_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/jpeg2000dsp\\.c$")
    endif()
    if(NOT CONFIG_MPEG4_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/mpeg4videodsp\\.c$")
    endif()
    if(NOT CONFIG_OPUS_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/opusdsp\\.c$")
    endif()
    if(NOT CONFIG_PIXBLOCKDSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/pixblockdsp\\.c$")
    endif()
    if(NOT CONFIG_HEVC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_add_res\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_deblock\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_dequant\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_idct\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_sao\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/hevc_pel\\.c$")
    endif()
    if(NOT CONFIG_PNG_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/png\\.c$")
    endif()
    if(NOT CONFIG_RV34DSP)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/rv34dsp\\.c$")
    endif()
    if(NOT CONFIG_RV40_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/rv40dsp\\.c$")
    endif()
    if(NOT CONFIG_SVQ1_ENCODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/svq1enc\\.c$")
    endif()
    if(NOT CONFIG_TAK_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/takdsp\\.c$")
    endif()
    if(NOT CONFIG_UTVIDEO_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/utvideodsp\\.c$")
    endif()
    if(NOT CONFIG_V210_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/v210dec\\.c$")
    endif()
    if(NOT CONFIG_V210_ENCODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/v210enc\\.c$")
    endif()
    if(NOT CONFIG_VORBIS_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vorbisdsp\\.c$")
    endif()
    if(NOT CONFIG_VP6_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vp6dsp\\.c$")
    endif()
    if(NOT CONFIG_VP9_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vp9dsp\\.c$")
    endif()
    if(NOT CONFIG_VVC_DECODER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vvc_alf\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vvc_mc\\.c$")
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vvc_sao\\.c$")
    endif()

    # libavfilter tests
    if(NOT CONFIG_SCENE_SAD)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/scene_sad\\.c$")
    endif()
    if(NOT CONFIG_AFIR_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/af_afir\\.c$")
    endif()
    if(NOT CONFIG_BLACKDETECT_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_blackdetect\\.c$")
    endif()
    if(NOT CONFIG_BLEND_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_blend\\.c$")
    endif()
    if(NOT CONFIG_BWDIF_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_bwdif\\.c$")
    endif()
    if(NOT CONFIG_COLORDETECT_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_colordetect\\.c$")
    endif()
    if(NOT CONFIG_COLORSPACE_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_colorspace\\.c$")
    endif()
    if(NOT CONFIG_EQ_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_eq\\.c$")
    endif()
    if(NOT CONFIG_FSPP_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_fspp\\.c$")
    endif()
    if(NOT CONFIG_GBLUR_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_gblur\\.c$")
    endif()
    if(NOT CONFIG_HFLIP_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_hflip\\.c$")
    endif()
    if(NOT CONFIG_IDET_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_idet\\.c$")
    endif()
    if(NOT CONFIG_THRESHOLD_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_threshold\\.c$")
    endif()
    if(NOT CONFIG_NLMEANS_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_nlmeans\\.c$")
    endif()
    if(NOT CONFIG_SOBEL_FILTER)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/vf_convolution\\.c$")
    endif()

    # libavutil tests (pixelutils is conditional)
    if(NOT CONFIG_PIXELUTILS)
        list(FILTER CHECKASM_SOURCES EXCLUDE REGEX "checkasm/pixelutils\\.c$")
    endif()

    # Add architecture-specific assembly file
    if(ARCH_X86 AND HAVE_X86ASM)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/x86/checkasm.asm")
            list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/x86/checkasm.asm")
        endif()
    elseif(ARCH_AARCH64)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/aarch64/checkasm.S")
            list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/aarch64/checkasm.S")
        endif()
    elseif(ARCH_ARM)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/arm/checkasm.S")
            list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/arm/checkasm.S")
        endif()
    endif()

    add_executable(checkasm ${CHECKASM_SOURCES})
    target_include_directories(checkasm
        PRIVATE
            ${CMAKE_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}
    )
    target_link_libraries(checkasm
        PRIVATE
            avutil
            avcodec
            swscale
            swresample
            avfilter
    )

    # Add NASM source directory includes for x86 assembly
    if(ARCH_X86 AND HAVE_X86ASM)
        nasm_add_source_dir_includes(checkasm)
    endif()

    # Add test entry
    add_test(NAME fate-checkasm
        COMMAND checkasm
    )
    set_tests_properties(fate-checkasm PROPERTIES
        LABELS "fate;checkasm"
        TIMEOUT 300
    )
endif()

# =============================================================================
# FATE Test Integration (requires samples)
# =============================================================================

if(FATE_SAMPLES_DIR AND EXISTS ${FATE_SAMPLES_DIR})
    message(STATUS "FATE samples found: ${FATE_SAMPLES_DIR}")
else()
    message(STATUS "FATE samples not specified or not found.")
    message(STATUS "  Set -DFATE_SAMPLES_DIR=/path/to/samples or SAMPLES environment variable")
endif()

# Set up full FATE test suite
FFmpegSetupFATE()

# =============================================================================
# Custom targets for testing
# =============================================================================

# Target to run all smoke tests
add_custom_target(test-smoke
    COMMAND ${CMAKE_CTEST_COMMAND} -L smoke --output-on-failure
    COMMENT "Running smoke tests"
    USES_TERMINAL
)

# Target to run encode tests
add_custom_target(test-encode
    COMMAND ${CMAKE_CTEST_COMMAND} -L encode --output-on-failure
    COMMENT "Running encode tests"
    USES_TERMINAL
)

# Target to run API tests
add_custom_target(test-api
    COMMAND ${CMAKE_CTEST_COMMAND} -L api --output-on-failure
    COMMENT "Running API tests"
    USES_TERMINAL
)

# Target to run all tests (smoke + fate)
add_custom_target(test-all
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    COMMENT "Running all tests"
    USES_TERMINAL
)

# =============================================================================
# Test configuration summary
# =============================================================================

message(STATUS "")
message(STATUS "Test Configuration:")
message(STATUS "  Smoke tests:        8 tests")
message(STATUS "  Encode tests:       4 tests")
message(STATUS "  FFprobe tests:      3 tests")
message(STATUS "  FATE samples:       ${FATE_SAMPLES_DIR}")

# Count API tests
list(LENGTH API_TEST_SOURCES api_test_count)
message(STATUS "  API tests:          ${api_test_count} tests")

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/checkasm/checkasm.c)
    message(STATUS "  checkasm tests:     1 test suite")
endif()

message(STATUS "")
message(STATUS "Test Configuration:")
message(STATUS "  Smoke tests:      8 tests")
message(STATUS "  Encode tests:     4 tests")
message(STATUS "  FFprobe tests:    2 tests")
message(STATUS "  FATE samples:     ${FATE_SAMPLES}")
message(STATUS "")
