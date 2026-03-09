# FFmpeg FATE Tests CMake Module
# 
# This module provides CMake-based support for FFmpeg's Automated Testing Environment (FATE)
# It can:
# - Parse FATE test definitions from .mak files
# - Generate CTest test entries
# - Run sample-based and sample-less tests
# - Compare outputs against reference files
#

# =============================================================================
# Configuration
# =============================================================================

set(FFMPEG_FATE_TESTS_DIR "${CMAKE_SOURCE_DIR}/tests")
set(FFMPEG_FATE_FATE_DIR "${FFMPEG_FATE_TESTS_DIR}/fate")
set(FFMPEG_FATE_DATA_DIR "${CMAKE_BINARY_DIR}/tests/data/fate")
set(FFMPEG_FATE_REF_DIR "${FFMPEG_FATE_TESTS_DIR}/ref/fate")

# Allow override via cmake options
if(NOT DEFINED FATE_SAMPLES_DIR)
    set(FATE_SAMPLES_DIR "$ENV{SAMPLES}" CACHE PATH "Path to FATE sample files")
endif()

if(NOT DEFINED FATE_TARGET_PATH)
    set(FATE_TARGET_PATH "${CMAKE_BINARY_DIR}" CACHE PATH "Path to built binaries")
endif()

# Create output directory
file(MAKE_DIRECTORY ${FFMPEG_FATE_DATA_DIR})

# =============================================================================
# Test Utilities
# =============================================================================

# Helper executables needed for FATE
set(FATE_UTILS
    base64
    tiny_psnr
    tiny_ssim
    audiomatch
)

# =============================================================================
# FATE Test Definition Parser
# =============================================================================

#
# _fate_parse_test_def:
#   Parse a single FATE test definition from a .mak file
#   Input lines like:
#     fate-aac-al04_44: CMD = pcm -i $(TARGET_SAMPLES)/aac/al04_44.mp4
#     fate-aac-al04_44: REF = $(SAMPLES)/aac/al04_44.s16
#
function(_fate_parse_test_def mak_content test_name)
    string(REPLACE "\n" ";" lines "${mak_content}")
    
    set(cmd "")
    set(ref "")
    set(cmp "")
    set(depends "")
    
    foreach(line ${lines})
        # Parse CMD
        if(line MATCHES "^${test_name}: CMD = (.+)$")
            set(cmd "${CMAKE_MATCH_1}")
        endif()
        # Parse REF
        if(line MATCHES "^${test_name}: REF = (.+)$")
            set(ref "${CMAKE_MATCH_1}")
        endif()
        # Parse CMP (comparison method)
        if(line MATCHES "^${test_name}: CMP = (.+)$")
            set(cmp "${CMAKE_MATCH_1}")
        endif()
        # Parse dependencies
        if(line MATCHES "^${test_name}:.*\\$\\(([^)]+)\\)" AND NOT line MATCHES "CMD|REF|CMP")
            list(APPEND depends "${CMAKE_MATCH_1}")
        endif()
    endforeach()
    
    # Return results
    set(${test_name}_CMD "${cmd}" PARENT_SCOPE)
    set(${test_name}_REF "${ref}" PARENT_SCOPE)
    set(${test_name}_CMP "${cmp}" PARENT_SCOPE)
    set(${test_name}_DEPS "${depends}" PARENT_SCOPE)
endfunction()

#
# _fate_substitute_variables:
#   Substitute Makefile variables in test commands
#
function(_fate_substitute_variables input output_var)
    set(result "${input}")
    
    # Substitute TARGET_SAMPLES
    if(FATE_SAMPLES_DIR)
        string(REPLACE "$(TARGET_SAMPLES)" "${FATE_SAMPLES_DIR}" result "${result}")
        string(REPLACE "$(SAMPLES)" "${FATE_SAMPLES_DIR}" result "${result}")
    endif()
    
    # Substitute TARGET_PATH
    string(REPLACE "$(TARGET_PATH)" "${FATE_TARGET_PATH}" result "${result}")
    
    # Substitute SRC_PATH
    string(REPLACE "$(SRC_PATH)" "${CMAKE_SOURCE_DIR}" result "${result}")
    
    set(${output_var} "${result}" PARENT_SCOPE)
endfunction()

# =============================================================================
# FATE Test Registration
# =============================================================================

#
# fate_add_test:
#   Register a single FATE test with CTest
#
#   Parameters:
#     test_name - Full FATE test name (e.g., fate-aac-al04_44)
#     cmd       - Command to run (without fate-run.sh wrapper)
#     ref       - Reference file path (optional)
#     cmp       - Comparison method: diff, oneoff, stddev, oneline, null (optional)
#
function(fate_add_test test_name cmd)
    cmake_parse_arguments(ARG "" "REF;CMP;WORKING_DIRECTORY" "" ${ARGN})
    
    # Skip if test requires samples but SAMPLES not set
    if(cmd MATCHES "TARGET_SAMPLES|SAMPLES" AND NOT FATE_SAMPLES_DIR)
        message(VERBOSE "Skipping ${test_name}: requires SAMPLES")
        return()
    endif()
    
    # Substitute variables in command
    _fate_substitute_variables("${cmd}" expanded_cmd)
    
    # Default comparison method
    if(NOT ARG_CMP)
        set(ARG_CMP "oneoff")
    endif()
    
    # Build test command
    # Create a shell script to run the test
    set(test_script "${FFMPEG_FATE_DATA_DIR}/${test_name}.sh")
    
    # Reference file substitution
    if(ARG_REF)
        _fate_substitute_variables("${ARG_REF}" expanded_ref)
    else()
        set(expanded_ref "")
    endif()
    
    # Generate test script
    set(script_content "#!/bin/sh
# Auto-generated FATE test script
set -e

OUTDIR=\"${FFMPEG_FATE_DATA_DIR}\"
OUTFILE=\"${OUTDIR}/${test_name}\"
REFFILE=\"${expanded_ref}\"

# Run the command
${expanded_cmd} > \"\${OUTFILE}\" 2>\"\${OUTFILE}.err\"

# Compare if reference exists
if [ -n \"\${REFFILE}\" ] && [ -f \"\${REFFILE}\" ]; then
    # Comparison logic based on method
    case \"${ARG_CMP}\" in
        diff)
            diff -u \"\${REFFILE}\" \"\${OUTFILE}\"
            ;;
        oneoff)
            # Use tiny_psnr for one-off comparison
            ${CMAKE_BINARY_DIR}/tests/tiny_psnr \"\${OUTFILE}\" \"\${REFFILE}\" 2 0 0
            ;;
        stddev)
            # Use tiny_psnr for stddev comparison
            ${CMAKE_BINARY_DIR}/tests/tiny_psnr \"\${OUTFILE}\" \"\${REFFILE}\" 2 0 0
            ;;
        oneline)
            # Single line comparison
            diff -u <(echo \"\$(cat \${OUTFILE})\") \"\${REFFILE}\"
            ;;
        null)
            # No comparison, just check exit code
            ;;
        *)
            echo \"Unknown comparison method: ${ARG_CMP}\"
            exit 1
            ;;
    esac
fi
")
    
    file(WRITE "${test_script}" "${script_content}")
    file(CHMOD "${test_script}" FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    
    # Add CTest entry
    add_test(NAME ${test_name}
        COMMAND ${CMAKE_COMMAND} -E env 
            PROGSUF=""
            EXECSUF=""
            HOSTEXECSUF=""
            ${test_script}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
    
    # Set test properties
    set_tests_properties(${test_name} PROPERTIES
        LABELS "fate"
        TIMEOUT 120
    )
    
    # Add dependency labels based on test name
    if(test_name MATCHES "^fate-([a-z0-9]+)-")
        set_tests_properties(${test_name} PROPERTIES
            LABELS "fate;${CMAKE_MATCH_1}"
        )
    endif()
endfunction()

# =============================================================================
# FATE Test Discovery
# =============================================================================

#
# fate_discover_tests_from_mak:
#   Parse a .mak file and register all tests found
#
function(fate_discover_tests_from_mak mak_file)
    if(NOT EXISTS ${mak_file})
        message(WARNING "FATE .mak file not found: ${mak_file}")
        return()
    endif()
    
    file(READ ${mak_file} mak_content)
    
    # Find all test names (fate-*: patterns)
    string(REGEX MATCHALL "(fate-[a-zA-Z0-9_-]+): CMD" matches "${mak_content}")
    
    foreach(match ${matches})
        if(match MATCHES "(fate-[a-zA-Z0-9_-]+):")
            set(test_name "${CMAKE_MATCH_1}")
            
            # Parse test definition
            _fate_parse_test_def("${mak_content}" ${test_name})
            
            set(cmd "${${test_name}_CMD}")
            set(ref "${${test_name}_REF}")
            set(cmp "${${test_name}_CMP}")
            
            if(cmd)
                fate_add_test(${test_name} "${cmd}" REF "${ref}" CMP "${cmp}")
            endif()
        endif()
    endforeach()
endfunction()

#
# fate_discover_all_tests:
#   Discover and register all FATE tests
#
function(fate_discover_all_tests)
    message(STATUS "Discovering FATE tests...")
    
    # API tests (don't require samples)
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/api.mak")
    
    # Library tests
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libavcodec.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libavformat.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libavutil.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libswresample.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libswscale.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/libavdevice.mak")
    
    # Codec/format tests
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/acodec.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/vcodec.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/lavf-audio.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/lavf-video.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/lavf-container.mak")
    fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/lavf-image.mak")
    
    # Format-specific tests (require samples)
    if(FATE_SAMPLES_DIR)
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/aac.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/ac3.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/alac.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/amrnb.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/amrwb.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/atrac.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/audio.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/avi.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/av1.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/bmp.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/caf.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/canopus.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/dca.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/demux.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/dvvideo.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/flac.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/gif.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/h264.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/hevc.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/image.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/jpeg2000.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/matroska.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mov.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mp3.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mpeg4.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mpegps.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mpegts.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/mxf.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/opus.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/prores.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/qt.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/real.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/vorbis.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/vpx.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/wma.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/xvid.mak")
        
        # Filter tests
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/filter-audio.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/filter-video.mak")
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/pixfmt.mak")
        
        # Seek tests
        fate_discover_tests_from_mak("${FFMPEG_FATE_FATE_DIR}/seek.mak")
    else()
        message(STATUS "FATE_SAMPLES not set, skipping sample-dependent tests")
    endif()
    
    message(STATUS "FATE test discovery complete")
endfunction()

# =============================================================================
# API Unit Test Support
# =============================================================================

#
# fate_add_api_test:
#   Add an API unit test (tests/api/)
#
function(fate_add_api_test test_name test_exe)
    set(test_path "${CMAKE_BINARY_DIR}/tests/api/${test_exe}")
    
    add_test(NAME fate-api-${test_name}
        COMMAND ${test_path} ${ARGN}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
    
    set_tests_properties(fate-api-${test_name} PROPERTIES
        LABELS "fate;api"
        TIMEOUT 60
    )
endfunction()

# =============================================================================
# Checkasm Support
# =============================================================================

#
# fate_add_checkasm_test:
#   Add a checkasm test for assembly verification
#
function(fate_add_checkasm_test component)
    if(TARGET checkasm_${component})
        add_test(NAME fate-checkasm-${component}
            COMMAND ${CMAKE_BINARY_DIR}/tests/checkasm/checkasm_${component}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
        set_tests_properties(fate-checkasm-${component} PROPERTIES
            LABELS "fate;checkasm;${component}"
            TIMEOUT 300
        )
    endif()
endfunction()

# =============================================================================
# Custom Test Targets
# =============================================================================

#
# fate_create_targets:
#   Create convenience targets for running FATE tests
#
function(fate_create_targets)
    # Main fate target - runs all FATE tests
    add_custom_target(fate
        COMMAND ${CMAKE_CTEST_COMMAND} -L fate --output-on-failure
        COMMENT "Running all FATE tests"
        USES_TERMINAL
    )
    
    # fate-api - runs only API tests
    add_custom_target(fate-api
        COMMAND ${CMAKE_CTEST_COMMAND} -L "fate;api" --output-on-failure
        COMMENT "Running FATE API tests"
        USES_TERMINAL
    )
    
    # fate-checkasm - runs only checkasm tests
    add_custom_target(fate-checkasm
        COMMAND ${CMAKE_CTEST_COMMAND} -L "fate;checkasm" --output-on-failure
        COMMENT "Running FATE checkasm tests"
        USES_TERMINAL
    )
    
    # fate-fast - runs quick tests only
    add_custom_target(fate-fast
        COMMAND ${CMAKE_CTEST_COMMAND} -L fate -LE "slow" --output-on-failure
        COMMENT "Running quick FATE tests"
        USES_TERMINAL
    )
    
    # fate-sync - sync FATE samples (if SAMPLES dir specified)
    if(FATE_SAMPLES_DIR)
        add_custom_target(fate-sync
            COMMAND rsync -av rsync://fate-suite.ffmpeg.org/fate-suite/ ${FATE_SAMPLES_DIR}/
            COMMENT "Syncing FATE samples to ${FATE_SAMPLES_DIR}"
            USES_TERMINAL
        )
    endif()
    
    # fate-list - list all available FATE tests
    add_custom_target(fate-list
        COMMAND ${CMAKE_CTEST_COMMAND} -L fate -N
        COMMENT "Listing available FATE tests"
        USES_TERMINAL
    )
    
    # fate-report - generate test report
    add_custom_target(fate-report
        COMMAND ${CMAKE_COMMAND} -E echo "FATE Test Report"
        COMMAND ${CMAKE_COMMAND} -E echo "================"
        COMMAND ${CMAKE_CTEST_COMMAND} -L fate --output-on-failure 2>&1 | tee ${CMAKE_BINARY_DIR}/fate-report.txt
        COMMENT "Generating FATE test report"
        USES_TERMINAL
    )
endfunction()

# =============================================================================
# Main Setup Function
# =============================================================================

#
# FFmpegSetupFATE:
#   Main entry point - call this to set up all FATE tests
#
function(FFmpegSetupFATE)
    message(STATUS "")
    message(STATUS "==========================================")
    message(STATUS "Setting up FATE tests...")
    message(STATUS "==========================================")
    
    if(FATE_SAMPLES_DIR)
        message(STATUS "FATE samples: ${FATE_SAMPLES_DIR}")
    else()
        message(STATUS "FATE samples: NOT SET (only sample-less tests will be available)")
        message(STATUS "  Set SAMPLES environment variable or -DFATE_SAMPLES_DIR=path")
    endif()
    
    # Enable CTest
    enable_testing()
    
    # Discover and register all tests
    fate_discover_all_tests()
    
    # Create convenience targets
    fate_create_targets()
    
    message(STATUS "==========================================")
    message(STATUS "FATE test setup complete")
    message(STATUS "==========================================")
    message(STATUS "")
    message(STATUS "FATE targets:")
    message(STATUS "  make fate        - Run all FATE tests")
    message(STATUS "  make fate-api    - Run API tests only")
    message(STATUS "  make fate-checkasm - Run assembly tests")
    message(STATUS "  make fate-fast   - Run quick tests only")
    message(STATUS "  make fate-list   - List all tests")
    message(STATUS "  make fate-report - Generate test report")
    if(FATE_SAMPLES_DIR)
        message(STATUS "  make fate-sync   - Sync FATE samples")
    endif()
    message(STATUS "")
endfunction()
