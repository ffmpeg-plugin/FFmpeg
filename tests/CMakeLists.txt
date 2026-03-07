# FFmpeg Tests CMakeLists.txt
# FATE testing support

enable_testing()

# FATE samples directory (optional)
set(FATE_SAMPLES "" CACHE PATH "Path to FATE test samples")

# Tool paths
set(FFMPEG_TOOL $<TARGET_FILE:ffmpeg>)
set(FFPROBE_TOOL $<TARGET_FILE:ffprobe>)

# ==============================================================================
# Simple smoke tests (no samples required)
# ==============================================================================

# Test 1: ffmpeg -version
add_test(NAME ffmpeg_version
    COMMAND ${FFMPEG_TOOL} -version
)

# Test 2: ffprobe -version
add_test(NAME ffprobe_version
    COMMAND ${FFPROBE_TOOL} -version
)

# Test 3: ffmpeg -formats
add_test(NAME ffmpeg_formats
    COMMAND ${FFMPEG_TOOL} -formats
)

# Test 4: ffmpeg -codecs
add_test(NAME ffmpeg_codecs
    COMMAND ${FFMPEG_TOOL} -codecs
)

# Test 5: ffmpeg -filters
add_test(NAME ffmpeg_filters
    COMMAND ${FFMPEG_TOOL} -filters
)

# Test 6: ffmpeg -encoders
add_test(NAME ffmpeg_encoders
    COMMAND ${FFMPEG_TOOL} -encoders
)

# Test 7: ffmpeg -decoders
add_test(NAME ffmpeg_decoders
    COMMAND ${FFMPEG_TOOL} -decoders
)

# Test 8: ffmpeg -hwaccels
add_test(NAME ffmpeg_hwaccels
    COMMAND ${FFMPEG_TOOL} -hwaccels
)

# ==============================================================================
# Basic encode/decode tests (synthetic, no samples)
# ==============================================================================

# Test audio encoding: generate 1 second of silence
add_test(NAME audio_encode_silence
    COMMAND ${FFMPEG_TOOL} -f lavfi -i anullsrc=r=44100:cl=stereo -t 1 -c:a pcm_s16le -f wav -
)

# Test video encoding: generate 1 frame of color
add_test(NAME video_encode_color
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -c:v rawvideo -f rawvideo -y /dev/null
)

# Test container format: generate empty MP4
add_test(NAME container_mp4
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -f lavfi -i anullsrc=r=44100:cl=mono:d=0.1 -c:v mpeg4 -c:a aac -f mp4 -y /dev/null
)

# Test container format: generate MKV
add_test(NAME container_mkv
    COMMAND ${FFMPEG_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -f lavfi -i anullsrc=r=44100:cl=mono:d=0.1 -c:v libx264 -c:a aac -f matroska -y /dev/null
)

# ==============================================================================
# FFprobe tests
# ==============================================================================

# Test ffprobe on a synthetic stream
add_test(NAME ffprobe_synthetic
    COMMAND ${FFPROBE_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -show_streams -show_format
)

# Test ffprobe JSON output
add_test(NAME ffprobe_json
    COMMAND ${FFPROBE_TOOL} -f lavfi -i color=c=black:s=320x240:d=0.1 -print_format json -show_streams
)

# ==============================================================================
# FATE test integration (requires samples)
# ==============================================================================

if(FATE_SAMPLES AND EXISTS ${FATE_SAMPLES})
    message(STATUS "FATE samples found: ${FATE_SAMPLES}")
    
    # Custom target for FATE testing
    add_custom_target(fate
        COMMAND ${CMAKE_COMMAND} -E env
            "FFMPEG=${FFMPEG_TOOL}"
            "FFPROBE=${FFPROBE_TOOL}"
            "TARGET_EXEC="
            "TARGET_PATH=${CMAKE_BINARY_DIR}"
            "SAMPLES=${FATE_SAMPLES}"
            "THREADS=1"
            bash ${CMAKE_SOURCE_DIR}/tests/fate-run.sh
        DEPENDS ffmpeg ffprobe
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running FATE tests with samples from ${FATE_SAMPLES}"
    )
else()
    message(STATUS "FATE samples not specified. Use -DFATE_SAMPLES=/path/to/samples to enable.")
endif()

# ==============================================================================
# API tests
# ==============================================================================

# Build API test executables
set(API_TESTS
    api-h264-test
    api-flac-test
    api-seek-test
)

foreach(test_name ${API_TESTS})
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/api/${test_name}.c)
        add_executable(${test_name} api/${test_name}.c)
        
        set(API_TEST_LINK_LIBS
            avcodec
            avformat
            avutil
        )
        
        # macOS frameworks
        if(APPLE)
            find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
            find_library(COREMEDIA_FRAMEWORK CoreMedia)
            find_library(COREVIDEO_FRAMEWORK CoreVideo)
            find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
            find_library(SECURITY_FRAMEWORK Security)
            
            if(VIDEOTOOLBOX_FRAMEWORK)
                list(APPEND API_TEST_LINK_LIBS ${VIDEOTOOLBOX_FRAMEWORK})
            endif()
            if(COREMEDIA_FRAMEWORK)
                list(APPEND API_TEST_LINK_LIBS ${COREMEDIA_FRAMEWORK})
            endif()
            if(COREVIDEO_FRAMEWORK)
                list(APPEND API_TEST_LINK_LIBS ${COREVIDEO_FRAMEWORK})
            endif()
            if(COREFOUNDATION_FRAMEWORK)
                list(APPEND API_TEST_LINK_LIBS ${COREFOUNDATION_FRAMEWORK})
            endif()
            if(SECURITY_FRAMEWORK)
                list(APPEND API_TEST_LINK_LIBS ${SECURITY_FRAMEWORK})
            endif()
        endif()
        
        # External libraries
        if(ZLIB_FOUND)
            list(APPEND API_TEST_LINK_LIBS ZLIB::ZLIB)
        endif()
        
        if(Iconv_FOUND)
            list(APPEND API_TEST_LINK_LIBS Iconv::Iconv)
        endif()
        
        target_link_libraries(${test_name} PRIVATE ${API_TEST_LINK_LIBS})
        target_include_directories(${test_name}
            PRIVATE
                ${CMAKE_BINARY_DIR}
        )
    endif()
endforeach()

# ==============================================================================
# checkasm tests (assembly verification)
# ==============================================================================

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/checkasm/checkasm.c)
    # Collect all checkasm C source files
    file(GLOB CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/*.c")

    # Add architecture-specific assembly file
    if(ARCH_X86 AND HAVE_X86ASM AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/x86/checkasm.asm")
        list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/x86/checkasm.asm")
    elseif(ARCH_AARCH64 AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/aarch64/checkasm.S")
        list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/aarch64/checkasm.S")
    elseif(ARCH_ARM AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/arm/checkasm.S")
        list(APPEND CHECKASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/checkasm/arm/checkasm.S")
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

    add_test(NAME checkasm
        COMMAND checkasm
    )
endif()

# ==============================================================================
# Test configuration summary
# ==============================================================================

message(STATUS "")
message(STATUS "Test Configuration:")
message(STATUS "  Smoke tests:      8 tests")
message(STATUS "  Encode tests:     4 tests")
message(STATUS "  FFprobe tests:    2 tests")
message(STATUS "  FATE samples:     ${FATE_SAMPLES}")
message(STATUS "")
