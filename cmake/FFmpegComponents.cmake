# FFmpeg Components Selection Module
# Handles encoder/decoder/filter/muxer/demuxer/protocol/device selection
# 
# This module generates:
# - config_components.h: Component enable/disable macros
# - codec_list.c: List of registered codecs
# - parser_list.c: List of registered parsers
# - bsf_list.c: List of registered bitstream filters
# - filter_list.c: List of registered filters
# - muxer_list.c, demuxer_list.c: List of registered (de)muxers
# - protocol_list.c: List of registered protocols

message(STATUS "Configuring components...")

# ============================================================================
# Component Selection Options
# ============================================================================

option(ENABLE_EVERYTHING "Enable all components" OFF)
option(DISABLE_EVERYTHING "Disable all components" OFF)

# ============================================================================
# Set default values for config variables (used in config_components.h)
# ============================================================================

# License flags - FFmpegDefaults.cmake already sets these based on ENABLE_GPL/ENABLE_VERSION3/ENABLE_NONFREE
# Do NOT override here - let the options take effect
# set(CONFIG_GPL ...) - handled by FFmpegDefaults.cmake
# set(CONFIG_VERSION3 ...) - handled by FFmpegDefaults.cmake
# set(CONFIG_NONFREE ...) - handled by FFmpegDefaults.cmake

# Library enable flags
set(CONFIG_AVUTIL 1)
set(CONFIG_AVCODEC 1)
set(CONFIG_AVFORMAT 1)
set(CONFIG_AVFILTER 1)
set(CONFIG_AVDEVICE 1)
set(CONFIG_SWSCALE 1)
set(CONFIG_SWRESAMPLE 1)

# Tool enable flags
set(CONFIG_FFMPEG 1)
set(CONFIG_FFPLAY 1)
set(CONFIG_FFPROBE 1)

# ============================================================================
# Extract all codecs from allcodecs.c
# ============================================================================

# Parse allcodecs.c to get all codec declarations
set(ALL_CODECS "")
set(ALL_ENCODERS "")
set(ALL_DECODERS "")

if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/allcodecs.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/allcodecs.c" CODEC_LINES REGEX "extern (const )?FFCodec ff_")
    foreach(LINE IN LISTS CODEC_LINES)
        # Extract codec name from: extern [const] FFCodec ff_xxx_encoder; or ff_xxx_decoder;
        if(LINE MATCHES "ff_([a-z0-9_]+)_(encoder|decoder)")
            set(CODEC_NAME "${CMAKE_MATCH_1}")
            set(CODEC_TYPE "${CMAKE_MATCH_2}")
            string(TOUPPER "${CODEC_NAME}_${CODEC_TYPE}" CONFIG_NAME)
            list(APPEND ALL_CODECS "${CONFIG_NAME}")
            if(CODEC_TYPE STREQUAL "encoder")
                list(APPEND ALL_ENCODERS "${CODEC_NAME}")
            else()
                list(APPEND ALL_DECODERS "${CODEC_NAME}")
            endif()
        endif()
    endforeach()
endif()

list(LENGTH ALL_CODECS CODEC_COUNT)
list(LENGTH ALL_ENCODERS ENCODER_COUNT)
list(LENGTH ALL_DECODERS DECODER_COUNT)
message(STATUS "Found ${CODEC_COUNT} codec definitions (${ENCODER_COUNT} encoders, ${DECODER_COUNT} decoders)")

# ============================================================================
# Extract muxers and demuxers from allformats.c
# ============================================================================
set(ALL_MUXERS "")
set(ALL_DEMUXERS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavformat/allformats.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavformat/allformats.c" FORMAT_LINES REGEX "ff_[a-z0-9_]+_(muxer|demuxer)")
    foreach(LINE IN LISTS FORMAT_LINES)
        string(REGEX MATCHALL "ff_([a-z0-9_]+)_(muxer|demuxer)" MATCHES "${LINE}")
        foreach(MATCH IN LISTS MATCHES)
            if(MATCH MATCHES "ff_([a-z0-9_]+)_(muxer|demuxer)")
                set(FMT_NAME "${CMAKE_MATCH_1}")
                set(FMT_TYPE "${CMAKE_MATCH_2}")
                string(TOUPPER "${FMT_NAME}_${FMT_TYPE}" CONFIG_NAME)
                if(FMT_TYPE STREQUAL "muxer")
                    list(APPEND ALL_MUXERS "${CONFIG_NAME}")
                else()
                    list(APPEND ALL_DEMUXERS "${CONFIG_NAME}")
                endif()
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES ALL_MUXERS)
    list(REMOVE_DUPLICATES ALL_DEMUXERS)
endif()
list(LENGTH ALL_MUXERS MUXER_COUNT)
list(LENGTH ALL_DEMUXERS DEMUXER_COUNT)
message(STATUS "Found ${MUXER_COUNT} muxers, ${DEMUXER_COUNT} demuxers")

# ============================================================================
# Extract protocols from protocols.c
# ============================================================================
set(ALL_PROTOCOLS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavformat/protocols.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavformat/protocols.c" PROTO_LINES REGEX "ff_[a-z0-9_]+_protocol")
    foreach(LINE IN LISTS PROTO_LINES)
        string(REGEX MATCHALL "ff_([a-z0-9_]+)_protocol" MATCHES "${LINE}")
        foreach(MATCH IN LISTS MATCHES)
            if(MATCH MATCHES "ff_([a-z0-9_]+)_protocol")
                set(PROTO_NAME "${CMAKE_MATCH_1}")
                string(TOUPPER "${PROTO_NAME}_PROTOCOL" CONFIG_NAME)
                list(APPEND ALL_PROTOCOLS "${CONFIG_NAME}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES ALL_PROTOCOLS)
endif()

# Remove platform-specific protocols that require external libraries or specific OS
# Android content protocol requires JNI/Android SDK
if(NOT ANDROID)
    list(REMOVE_ITEM ALL_PROTOCOLS "ANDROID_CONTENT_PROTOCOL")
endif()

list(LENGTH ALL_PROTOCOLS PROTO_COUNT)
message(STATUS "Found ${PROTO_COUNT} protocols")

# ============================================================================
# Extract filters from allfilters.c
# ============================================================================
set(ALL_FILTERS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c")
    # allfilters.c format: "extern const FFFilter ff_af_aecho;"
    # or "extern const FFFilter ff_vf_scale;"
    # We need to extract the filter name and generate CONFIG_xxx_FILTER macros.
    # The CONFIG macro name is derived by stripping the "ff_af_" / "ff_vf_" / "ff_avf_" prefix
    # and appending "_FILTER", e.g. ff_vf_select -> CONFIG_SELECT_FILTER
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c" FILTER_LINES REGEX "extern const FFFilter ff_")
    foreach(LINE IN LISTS FILTER_LINES)
        if(LINE MATCHES "extern const FFFilter (ff_[a-z0-9_]+);")
            set(FULL_NAME "${CMAKE_MATCH_1}")
            # Strip known prefixes: ff_af_, ff_vf_, ff_avf_, ff_asrc_, ff_vsrc_, ff_asink_, ff_vsink_
            string(REGEX REPLACE "^ff_(af|vf|avf|asrc|vsrc|asink|vsink)_" "" FILTER_NAME "${FULL_NAME}")
            string(TOUPPER "${FILTER_NAME}_FILTER" CONFIG_NAME)
            list(APPEND ALL_FILTERS "${CONFIG_NAME}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES ALL_FILTERS)
endif()
list(LENGTH ALL_FILTERS FILTER_COUNT)
message(STATUS "Found ${FILTER_COUNT} filters")

# ============================================================================
# Extract BSFs from bitstream_filters.c
# ============================================================================
set(ALL_BSFS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/bitstream_filters.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/bitstream_filters.c" BSF_LINES REGEX "ff_[a-z0-9_]+_bsf")
    foreach(LINE IN LISTS BSF_LINES)
        string(REGEX MATCHALL "ff_([a-z0-9_]+)_bsf" MATCHES "${LINE}")
        foreach(MATCH IN LISTS MATCHES)
            if(MATCH MATCHES "ff_([a-z0-9_]+)_bsf")
                set(BSF_NAME "${CMAKE_MATCH_1}")
                string(TOUPPER "${BSF_NAME}_BSF" CONFIG_NAME)
                list(APPEND ALL_BSFS "${CONFIG_NAME}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES ALL_BSFS)
endif()
list(LENGTH ALL_BSFS BSF_COUNT)
message(STATUS "Found ${BSF_COUNT} BSFs")

# ============================================================================
# Extract parsers from parsers.c
# ============================================================================
set(ALL_PARSERS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c" PARSER_LINES2 REGEX "ff_[a-z0-9_]+_parser")
    foreach(LINE IN LISTS PARSER_LINES2)
        string(REGEX MATCHALL "ff_([a-z0-9_]+)_parser" MATCHES "${LINE}")
        foreach(MATCH IN LISTS MATCHES)
            if(MATCH MATCHES "ff_([a-z0-9_]+)_parser")
                set(PARSER_NAME "${CMAKE_MATCH_1}")
                string(TOUPPER "${PARSER_NAME}_PARSER" CONFIG_NAME)
                list(APPEND ALL_PARSERS "${CONFIG_NAME}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES ALL_PARSERS)
endif()
list(LENGTH ALL_PARSERS PARSER_COUNT)
message(STATUS "Found ${PARSER_COUNT} parsers")

# ============================================================================
# Built-in Codec Lists
# ============================================================================

# Build codec list based on enabled components
# Start with null codecs (always available)
set(CODEC_LIST "")

# Add all encoders and decoders
foreach(ENCODER IN LISTS ALL_ENCODERS)
    list(APPEND CODEC_LIST "${ENCODER}_encoder")
endforeach()

foreach(DECODER IN LISTS ALL_DECODERS)
    list(APPEND CODEC_LIST "${DECODER}_decoder")
endforeach()

# Always add null codecs
list(APPEND CODEC_LIST vnull_encoder vnull_decoder anull_encoder anull_decoder)

# ============================================================================
# Function to generate list files
# ============================================================================

function(generate_codec_list_file OUTPUT_FILE CODEC_LIST_VAR)
    # Build codec entries
    set(CODEC_ENTRIES "")
    foreach(CODEC IN LISTS ${CODEC_LIST_VAR})
        string(APPEND CODEC_ENTRIES "    &ff_${CODEC},\n")
    endforeach()
    
    # Generate file content - complete array definition
    # This file is included by allcodecs.c
    set(CONTENT "static const FFCodec * const codec_list[] = {\n")
    string(APPEND CONTENT "${CODEC_ENTRIES}    NULL };\n")
    
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

function(generate_parser_list_file OUTPUT_FILE)
    # Parse parsers.c to get all parser declarations
    set(PARSER_ENTRIES "")
    if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c")
        file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c" PARSER_LINES REGEX "extern const FFCodecParser ff_")
        foreach(LINE IN LISTS PARSER_LINES)
            if(LINE MATCHES "extern const FFCodecParser (ff_[a-z0-9_]+_parser)")
                set(PARSER_NAME "${CMAKE_MATCH_1}")
                string(APPEND PARSER_ENTRIES "    &${PARSER_NAME},\n")
            endif()
        endforeach()
    endif()

    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* Parser list - included by parsers.c */\n\n")
    string(APPEND CONTENT "static const FFCodecParser * const parser_list[] = {\n")
    string(APPEND CONTENT "${PARSER_ENTRIES}")
    string(APPEND CONTENT "    NULL\n};\n")

    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

function(generate_bsf_list_file OUTPUT_FILE)
    # Parse bitstream_filters.c to get all BSF declarations
    set(BSF_ENTRIES "")
    if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/bitstream_filters.c")
        file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/bitstream_filters.c" BSF_LINES REGEX "extern const FFBitStreamFilter ff_")
        foreach(LINE IN LISTS BSF_LINES)
            if(LINE MATCHES "extern const FFBitStreamFilter (ff_[a-z0-9_]+_bsf)")
                set(BSF_NAME "${CMAKE_MATCH_1}")
                string(APPEND BSF_ENTRIES "    &${BSF_NAME},\n")
            endif()
        endforeach()
    endif()

    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* BSF list - included by bitstream_filters.c */\n\n")
    string(APPEND CONTENT "static const FFBitStreamFilter * const bitstream_filters[] = {\n")
    string(APPEND CONTENT "${BSF_ENTRIES}")
    string(APPEND CONTENT "    NULL\n};\n")

    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# ============================================================================
# Generate List Files
# ============================================================================

# Create output directory if needed
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavcodec")

# Generate codec_list.c
generate_codec_list_file("${CMAKE_BINARY_DIR}/libavcodec/codec_list.c" CODEC_LIST)
message(STATUS "Generated codec_list.c with ${CODEC_LIST}")

# Generate parser_list.c
generate_parser_list_file("${CMAKE_BINARY_DIR}/libavcodec/parser_list.c")

# Generate bsf_list.c
generate_bsf_list_file("${CMAKE_BINARY_DIR}/libavcodec/bsf_list.c")

# ============================================================================
# Generate libavdevice list files
# ============================================================================

# Create output directory if needed
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavdevice")

# Generate indev_list.c
function(generate_indev_list_file OUTPUT_FILE)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* Minimal input device list */\n")
    string(APPEND CONTENT "static const FFInputFormat * const indev_list[] = {\n")
    string(APPEND CONTENT "    NULL };\n")
    
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# Generate outdev_list.c
function(generate_outdev_list_file OUTPUT_FILE)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* Minimal output device list */\n")
    string(APPEND CONTENT "static const FFOutputFormat * const outdev_list[] = {\n")
    string(APPEND CONTENT "    NULL };\n")
    
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# Generate device list files
generate_indev_list_file("${CMAKE_BINARY_DIR}/libavdevice/indev_list.c")
generate_outdev_list_file("${CMAKE_BINARY_DIR}/libavdevice/outdev_list.c")
message(STATUS "Generated libavdevice list files")

# ============================================================================
# Generate libavformat list files
# ============================================================================

# Create output directory if needed
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavformat")

# Scan libavformat source files to build muxer/demuxer/protocol lists
function(scan_avformat_symbols SOURCE_DIR)
    file(GLOB _avfmt_sources "${SOURCE_DIR}/*.c")
    set(_muxer_list "")
    set(_demuxer_list "")
    set(_protocol_list "")
    foreach(_src ${_avfmt_sources})
        file(STRINGS "${_src}" _lines
            REGEX "(const[ \t]+FFOutputFormat|const[ \t]+FFInputFormat|const[ \t]+URLProtocol)[ \t]+ff_[a-zA-Z0-9_]+")
        foreach(_line IN LISTS _lines)
            if(_line MATCHES "const[ \t]+FFOutputFormat[ \t]+(ff_[a-zA-Z0-9_]+_muxer)")
                list(APPEND _muxer_list "${CMAKE_MATCH_1}")
            elseif(_line MATCHES "const[ \t]+FFInputFormat[ \t]+(ff_[a-zA-Z0-9_]+_demuxer)")
                list(APPEND _demuxer_list "${CMAKE_MATCH_1}")
            elseif(_line MATCHES "const[ \t]+URLProtocol[ \t]+(ff_[a-zA-Z0-9_]+_protocol)")
                list(APPEND _protocol_list "${CMAKE_MATCH_1}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES _muxer_list)
    list(REMOVE_DUPLICATES _demuxer_list)
    list(REMOVE_DUPLICATES _protocol_list)
    list(SORT _muxer_list)
    list(SORT _demuxer_list)
    list(SORT _protocol_list)
    set(AVFORMAT_MUXER_LIST "${_muxer_list}" PARENT_SCOPE)
    set(AVFORMAT_DEMUXER_LIST "${_demuxer_list}" PARENT_SCOPE)
    set(AVFORMAT_PROTOCOL_LIST "${_protocol_list}" PARENT_SCOPE)
endfunction()

# Scan source files
scan_avformat_symbols("${CMAKE_SOURCE_DIR}/libavformat")
message(STATUS "Found ${CMAKE_MATCH_1} muxers, demuxers, protocols in libavformat")

# Generate muxer_list.c
function(generate_muxer_list_file OUTPUT_FILE MUXER_LIST)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "#include \"libavformat/internal.h\"\n\n")
    foreach(_sym IN LISTS MUXER_LIST)
        string(APPEND CONTENT "extern const FFOutputFormat ${_sym};\n")
    endforeach()
    string(APPEND CONTENT "\nstatic const FFOutputFormat * const muxer_list[] = {\n")
    foreach(_sym IN LISTS MUXER_LIST)
        string(APPEND CONTENT "    &${_sym},\n")
    endforeach()
    string(APPEND CONTENT "    NULL\n};\n")
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# Generate demuxer_list.c
function(generate_demuxer_list_file OUTPUT_FILE DEMUXER_LIST)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "#include \"libavformat/internal.h\"\n\n")
    foreach(_sym IN LISTS DEMUXER_LIST)
        string(APPEND CONTENT "extern const FFInputFormat ${_sym};\n")
    endforeach()
    string(APPEND CONTENT "\nstatic const FFInputFormat * const demuxer_list[] = {\n")
    foreach(_sym IN LISTS DEMUXER_LIST)
        string(APPEND CONTENT "    &${_sym},\n")
    endforeach()
    string(APPEND CONTENT "    NULL\n};\n")
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# Generate format list files
generate_muxer_list_file("${CMAKE_BINARY_DIR}/libavformat/muxer_list.c" "${AVFORMAT_MUXER_LIST}")
generate_demuxer_list_file("${CMAKE_BINARY_DIR}/libavformat/demuxer_list.c" "${AVFORMAT_DEMUXER_LIST}")

# Generate protocol_list.c
function(generate_protocol_list_file OUTPUT_FILE PROTOCOL_LIST)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "#include \"libavformat/url.h\"\n\n")
    foreach(_sym IN LISTS PROTOCOL_LIST)
        string(APPEND CONTENT "extern const URLProtocol ${_sym};\n")
    endforeach()
    string(APPEND CONTENT "\nstatic const URLProtocol * const url_protocols[] = {\n")
    foreach(_sym IN LISTS PROTOCOL_LIST)
        string(APPEND CONTENT "    &${_sym},\n")
    endforeach()
    string(APPEND CONTENT "    NULL\n};\n")
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

generate_protocol_list_file("${CMAKE_BINARY_DIR}/libavformat/protocol_list.c" "${AVFORMAT_PROTOCOL_LIST}")
list(LENGTH AVFORMAT_MUXER_LIST _nmux)
list(LENGTH AVFORMAT_DEMUXER_LIST _ndemux)
list(LENGTH AVFORMAT_PROTOCOL_LIST _nproto)
message(STATUS "Generated libavformat list files: ${_nmux} muxers, ${_ndemux} demuxers, ${_nproto} protocols")

# ============================================================================
# Generate libavfilter list files
# ============================================================================

# Create output directory if needed
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavfilter")

# Generate filter_list.c
function(generate_filter_list_file OUTPUT_FILE)
    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* Minimal filter list */\n\n")
    string(APPEND CONTENT "static const AVFilter * const filter_list[] = {\n")
    string(APPEND CONTENT "    NULL };\n")
    
    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

# Generate filter_list.c
function(generate_filter_list_file OUTPUT_FILE)
    # Parse allfilters.c to get all filter declarations
    set(FILTER_ENTRIES "")
    if(EXISTS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c")
        file(STRINGS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c" FILTER_LINES REGEX "extern const FFFilter ff_")
        foreach(LINE IN LISTS FILTER_LINES)
            if(LINE MATCHES "extern const FFFilter (ff_[a-z0-9_]+)")
                set(FILTER_NAME "${CMAKE_MATCH_1}")
                string(APPEND FILTER_ENTRIES "    &${FILTER_NAME},\n")
            endif()
        endforeach()
    endif()

    set(CONTENT "/* Auto-generated by CMake - do not edit! */\n")
    string(APPEND CONTENT "/* Filter list - included by allfilters.c */\n\n")
    string(APPEND CONTENT "static const FFFilter * const filter_list[] = {\n")
    string(APPEND CONTENT "${FILTER_ENTRIES}")
    string(APPEND CONTENT "    NULL\n};\n")

    file(WRITE "${OUTPUT_FILE}" "${CONTENT}")
endfunction()

generate_filter_list_file("${CMAKE_BINARY_DIR}/libavfilter/filter_list.c")

# ============================================================================
# Generate config_components.h
# ============================================================================

set(CONFIG_COMPONENTS_CONTENT "/* Auto-generated by CMake - do not edit! */
#ifndef FFMPEG_CONFIG_COMPONENTS_H
#define FFMPEG_CONFIG_COMPONENTS_H

/* License flags */
#define CONFIG_GPL ${CONFIG_GPL}
#define CONFIG_VERSION3 ${CONFIG_VERSION3}
#define CONFIG_NONFREE ${CONFIG_NONFREE}

/* Library enable flags */
#define CONFIG_AVUTIL ${CONFIG_AVUTIL}
#define CONFIG_AVCODEC ${CONFIG_AVCODEC}
#define CONFIG_AVFORMAT ${CONFIG_AVFORMAT}
#define CONFIG_AVFILTER ${CONFIG_AVFILTER}
#define CONFIG_AVDEVICE ${CONFIG_AVDEVICE}
#define CONFIG_SWSCALE ${CONFIG_SWSCALE}
#define CONFIG_SWRESAMPLE ${CONFIG_SWRESAMPLE}

/* Tool enable flags */
#define CONFIG_FFMPEG ${CONFIG_FFMPEG}
#define CONFIG_FFPLAY ${CONFIG_FFPLAY}
#define CONFIG_FFPROBE ${CONFIG_FFPROBE}

/* Component groups */
#define CONFIG_DECODERS 1
#define CONFIG_ENCODERS 1
#define CONFIG_MUXERS 1
#define CONFIG_DEMUXERS 1
#define CONFIG_PROTOCOLS 1
#define CONFIG_FILTERS 1
#define CONFIG_BSFS 1
#define CONFIG_PARSERS 1
#define CONFIG_INDEVS 1
#define CONFIG_OUTDEVS 1

/* All codec configurations */
/* Null codecs (built-in, always available) */
#define CONFIG_VNULL_ENCODER 1
#define CONFIG_VNULL_DECODER 1
#define CONFIG_ANULL_ENCODER 1
#define CONFIG_ANULL_DECODER 1

/* Built-in codecs - enabled by default */
")

# Add all extracted codec configurations
foreach(CODEC IN LISTS ALL_CODECS)
    # Check if this codec has external library dependencies
    set(codec_deps "${${CODEC}_DEPS}")
    if(codec_deps)
        # External library codec - check if dependencies are satisfied
        set(all_deps_met TRUE)
        foreach(dep ${codec_deps})
            # Handle special license dependencies
            if(dep STREQUAL "gpl")
                if(NOT DEFINED gpl OR NOT gpl)
                    set(all_deps_met FALSE)
                    break()
                endif()
            elseif(dep STREQUAL "lgpl_gpl" OR dep STREQUAL "LGPL_GPL")
                if(NOT DEFINED lgpl_gpl)
                    message(STATUS "DEBUG: lgpl_gpl NOT DEFINED!")
                    set(all_deps_met FALSE)
                    break()
                elseif(NOT lgpl_gpl)
                    message(STATUS "DEBUG: lgpl_gpl is 0!")
                    set(all_deps_met FALSE)
                    break()
                endif()
            else()
                string(TOUPPER "${dep}" DEP_UPPER)
                if(NOT DEFINED CONFIG_${DEP_UPPER} OR NOT CONFIG_${DEP_UPPER})
                    set(all_deps_met FALSE)
                    break()
                endif()
            endif()
        endforeach()
        
        if(all_deps_met)
            string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${CODEC} 1\n")
        else()
            string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${CODEC} 0\n")
        endif()
    else()
        # Built-in codec - always enable
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${CODEC} 1\n")
    endif()
endforeach()

# Add muxer configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Muxer configurations */\n")
foreach(MUXER IN LISTS ALL_MUXERS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${MUXER} 1\n")
endforeach()

# Add demuxer configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Demuxer configurations */\n")
foreach(DEMUXER IN LISTS ALL_DEMUXERS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${DEMUXER} 1\n")
endforeach()

# Add protocol configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Protocol configurations */\n")
foreach(PROTO IN LISTS ALL_PROTOCOLS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PROTO} 1\n")
endforeach()

# Add filter configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Filter configurations */\n")
foreach(FILTER IN LISTS ALL_FILTERS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${FILTER} 1\n")
endforeach()

# Add BSF configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* BSF configurations */\n")
foreach(BSF IN LISTS ALL_BSFS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${BSF} 1\n")
endforeach()

# Add parser configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Parser configurations */\n")
foreach(PARSER IN LISTS ALL_PARSERS)
    string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PARSER} 1\n")
endforeach()

string(APPEND CONFIG_COMPONENTS_CONTENT "
/* Hardware acceleration configs - disabled by default */
#define CONFIG_AV1_D3D11VA_HWACCEL 0
#define CONFIG_AV1_D3D11VA2_HWACCEL 0
#define CONFIG_AV1_D3D12VA_HWACCEL 0
#define CONFIG_AV1_DXVA2_HWACCEL 0
#define CONFIG_AV1_NVDEC_HWACCEL 0
#define CONFIG_AV1_VAAPI_HWACCEL 0
#define CONFIG_AV1_VDPAU_HWACCEL 0
#define CONFIG_AV1_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_AV1_VULKAN_HWACCEL 0
#define CONFIG_H264_D3D11VA_HWACCEL 0
#define CONFIG_H264_D3D11VA2_HWACCEL 0
#define CONFIG_H264_D3D12VA_HWACCEL 0
#define CONFIG_H264_DXVA2_HWACCEL 0
#define CONFIG_H264_NVDEC_HWACCEL 0
#define CONFIG_H264_VAAPI_HWACCEL 0
#define CONFIG_H264_VDPAU_HWACCEL 0
#define CONFIG_H264_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_H264_VULKAN_HWACCEL 0
#define CONFIG_HEVC_D3D11VA_HWACCEL 0
#define CONFIG_HEVC_D3D11VA2_HWACCEL 0
#define CONFIG_HEVC_D3D12VA_HWACCEL 0
#define CONFIG_HEVC_DXVA2_HWACCEL 0
#define CONFIG_HEVC_NVDEC_HWACCEL 0
#define CONFIG_HEVC_VAAPI_HWACCEL 0
#define CONFIG_HEVC_VDPAU_HWACCEL 0
#define CONFIG_HEVC_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_HEVC_VULKAN_HWACCEL 0
#define CONFIG_VP9_D3D11VA_HWACCEL 0
#define CONFIG_VP9_D3D11VA2_HWACCEL 0
#define CONFIG_VP9_D3D12VA_HWACCEL 0
#define CONFIG_VP9_DXVA2_HWACCEL 0
#define CONFIG_VP9_NVDEC_HWACCEL 0
#define CONFIG_VP9_VAAPI_HWACCEL 0
#define CONFIG_VP9_VDPAU_HWACCEL 0
#define CONFIG_VP9_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_VP9_VULKAN_HWACCEL 0
#define CONFIG_VVC_D3D11VA_HWACCEL 0
#define CONFIG_VVC_D3D11VA2_HWACCEL 0
#define CONFIG_VVC_D3D12VA_HWACCEL 0
#define CONFIG_VVC_DXVA2_HWACCEL 0
#define CONFIG_VVC_NVDEC_HWACCEL 0
#define CONFIG_VVC_VAAPI_HWACCEL 0
#define CONFIG_VVC_VDPAU_HWACCEL 0
#define CONFIG_VVC_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_VVC_VULKAN_HWACCEL 0
#define CONFIG_MPEG2_D3D11VA_HWACCEL 0
#define CONFIG_MPEG2_D3D11VA2_HWACCEL 0
#define CONFIG_MPEG2_D3D12VA_HWACCEL 0
#define CONFIG_MPEG2_DXVA2_HWACCEL 0
#define CONFIG_MPEG2_NVDEC_HWACCEL 0
#define CONFIG_MPEG2_VAAPI_HWACCEL 0
#define CONFIG_MPEG2_VDPAU_HWACCEL 0
#define CONFIG_MPEG2_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_MPEG4_D3D11VA_HWACCEL 0
#define CONFIG_MPEG4_D3D11VA2_HWACCEL 0
#define CONFIG_MPEG4_D3D12VA_HWACCEL 0
#define CONFIG_MPEG4_DXVA2_HWACCEL 0
#define CONFIG_MPEG4_NVDEC_HWACCEL 0
#define CONFIG_MPEG4_VAAPI_HWACCEL 0
#define CONFIG_MPEG4_VDPAU_HWACCEL 0
#define CONFIG_MPEG4_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_VC1_D3D11VA_HWACCEL 0
#define CONFIG_VC1_D3D11VA2_HWACCEL 0
#define CONFIG_VC1_D3D12VA_HWACCEL 0
#define CONFIG_VC1_DXVA2_HWACCEL 0
#define CONFIG_VC1_NVDEC_HWACCEL 0
#define CONFIG_VC1_VAAPI_HWACCEL 0
#define CONFIG_VC1_VDPAU_HWACCEL 0
#define CONFIG_VC1_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_WMV3_D3D11VA_HWACCEL 0
#define CONFIG_WMV3_D3D11VA2_HWACCEL 0
#define CONFIG_WMV3_D3D12VA_HWACCEL 0
#define CONFIG_WMV3_DXVA2_HWACCEL 0
#define CONFIG_WMV3_NVDEC_HWACCEL 0
#define CONFIG_WMV3_VAAPI_HWACCEL 0
#define CONFIG_WMV3_VDPAU_HWACCEL 0
#define CONFIG_WMV3_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_DPX_VULKAN_HWACCEL 0
#define CONFIG_FFV1_VULKAN_HWACCEL 0
#define CONFIG_H263_VAAPI_HWACCEL 0
#define CONFIG_H263_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_MJPEG_NVDEC_HWACCEL 0
#define CONFIG_MJPEG_VAAPI_HWACCEL 0
#define CONFIG_MPEG1_NVDEC_HWACCEL 0
#define CONFIG_MPEG1_VDPAU_HWACCEL 0
#define CONFIG_MPEG1_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_PRORES_RAW_VULKAN_HWACCEL 0
#define CONFIG_PRORES_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_PRORES_VULKAN_HWACCEL 0
#define CONFIG_VP8_NVDEC_HWACCEL 0
#define CONFIG_VP8_VAAPI_HWACCEL 0

/* Platform-specific codecs - disabled by default */
#define CONFIG_AUDIOTOOLBOX_DECODER 0
#define CONFIG_AUDIOTOOLBOX_ENCODER 0
#define CONFIG_VIDEOTOOLBOX_ENCODER 0
#define CONFIG_VIDEOTOOLBOX_DECODER 0
#define CONFIG_QSV_DECODER 0
#define CONFIG_QSV_ENCODER 0
#define CONFIG_MEDIACODEC_DECODER 0
#define CONFIG_D3D11VA_DECODER 0
#define CONFIG_CUVID_DECODER 0
#define CONFIG_NVDEC_DECODER 0
#define CONFIG_NVENC_ENCODER 0
#define CONFIG_VAAPI_ENCODER 0
#define CONFIG_VAAPI_DECODER 0

/* Input devices */
#define CONFIG_LAVFI_INDEV 0
#define CONFIG_AVFOUNDATION_INDEV 0
#define CONFIG_ALSA_INDEV 1

/* Output devices */
#define CONFIG_AUDIOTOOLBOX_OUTDEV 0

/* Protocols */

#endif /* FFMPEG_CONFIG_COMPONENTS_H */
")

file(WRITE "${CMAKE_BINARY_DIR}/config_components.h.tmp" "${CONFIG_COMPONENTS_CONTENT}")
configure_file("${CMAKE_BINARY_DIR}/config_components.h.tmp" "${CMAKE_BINARY_DIR}/config_components.h" COPYONLY)
message(STATUS "Generated config_components.h with ${CODEC_COUNT} codecs")

# ============================================================================
# Set cmake variables for all CONFIG_xxx so that if(CONFIG_xxx) works in
# sub-directory CMakeLists.txt files (e.g. libavcodec/CMakeLists.txt)
# Use CACHE variables so they are accessible in all subdirectories
# ============================================================================

# Set codec cmake variables
# For external library codecs (libxxx_encoder/decoder), check if dependencies are met
foreach(CODEC IN LISTS ALL_CODECS)
    # Check if this codec has external library dependencies
    set(codec_deps "${${CODEC}_DEPS}")
    set(codec_select "${${CODEC}_SELECT}")
    
    if(codec_deps OR codec_select)
        # External library codec - check if dependencies are satisfied
        set(all_deps_met TRUE)
        foreach(dep ${codec_deps})
            # Handle special license dependencies
            if(dep STREQUAL "gpl" OR dep STREQUAL "GPL")
                if(NOT DEFINED gpl OR NOT gpl)
                    set(all_deps_met FALSE)
                    break()
                endif()
            elseif(dep STREQUAL "lgpl_gpl" OR dep STREQUAL "LGPL_GPL")
                if(NOT DEFINED lgpl_gpl OR NOT lgpl_gpl)
                    set(all_deps_met FALSE)
                    break()
                endif()
            else()
                string(TOUPPER "${dep}" DEP_UPPER)
                # Check if dependency is defined and enabled (treat undefined as 0)
                if(NOT DEFINED CONFIG_${DEP_UPPER} OR NOT CONFIG_${DEP_UPPER})
                    set(all_deps_met FALSE)
                    break()
                endif()
            endif()
        endforeach()
        
        if(all_deps_met)
            set(CONFIG_${CODEC} 1 CACHE INTERNAL "")
        else()
            message(STATUS "  Disabling ${CODEC} (missing deps: ${codec_deps})")
            set(CONFIG_${CODEC} 0 CACHE INTERNAL "")
        endif()
    else()
        # Built-in codec - always enable
        set(CONFIG_${CODEC} 1 CACHE INTERNAL "")
    endif()
endforeach()

# Set muxer cmake variables
foreach(MUXER IN LISTS ALL_MUXERS)
    set(CONFIG_${MUXER} 1 CACHE INTERNAL "")
endforeach()

# Set demuxer cmake variables
foreach(DEMUXER IN LISTS ALL_DEMUXERS)
    set(CONFIG_${DEMUXER} 1 CACHE INTERNAL "")
endforeach()

# Set protocol cmake variables
foreach(PROTO IN LISTS ALL_PROTOCOLS)
    set(CONFIG_${PROTO} 1 CACHE INTERNAL "")
endforeach()

# Set filter cmake variables
foreach(FILTER IN LISTS ALL_FILTERS)
    set(CONFIG_${FILTER} 1 CACHE INTERNAL "")
endforeach()

# Set BSF cmake variables
foreach(BSF IN LISTS ALL_BSFS)
    set(CONFIG_${BSF} 1 CACHE INTERNAL "")
endforeach()

# Set parser cmake variables
foreach(PARSER IN LISTS ALL_PARSERS)
    set(CONFIG_${PARSER} 1 CACHE INTERNAL "")
endforeach()

# Note: Hardware acceleration variables are set by FFmpegDetectLibraries()
# Do NOT set defaults here - let the detection logic determine availability
# based on actual system capabilities (header files, libraries, etc.)
# - CONFIG_VAAPI: set by FFmpegDetectVAAPI()
# - CONFIG_VDPAU: set by FFmpegDetectVDPAU()
# - CONFIG_VIDEOTOOLBOX: set by platform detection in FFmpegExternalLibs.cmake
# - CONFIG_VULKAN: set by FFmpegDetectVulkan()
# - CONFIG_OPENCL: set by FFmpegDetectOpenCL()
# - CONFIG_CUDA: set by CUDA detection in FFmpegExternalLibs.cmake
# - CONFIG_D3D11VA/D3D12VA/DXVA2: set by Windows platform detection
# - CONFIG_QSV: set by Intel QSV detection
# - CONFIG_MEDIACODEC: set by Android/platform detection
# - CONFIG_AMF: set by AMD AMF detection
# - CONFIG_LIBDRM: set by libdrm detection in FFmpegExternalLibs.cmake

# Set component group cmake variables
set(CONFIG_DECODERS 1 CACHE INTERNAL "")
set(CONFIG_ENCODERS 1 CACHE INTERNAL "")
set(CONFIG_MUXERS 1 CACHE INTERNAL "")
set(CONFIG_DEMUXERS 1 CACHE INTERNAL "")
set(CONFIG_PROTOCOLS 1 CACHE INTERNAL "")
set(CONFIG_FILTERS 1 CACHE INTERNAL "")
set(CONFIG_BSFS 1 CACHE INTERNAL "")
set(CONFIG_PARSERS 1 CACHE INTERNAL "")
set(CONFIG_INDEVS 1 CACHE INTERNAL "")
set(CONFIG_OUTDEVS 1 CACHE INTERNAL "")

# Set library cmake variables
set(CONFIG_AVUTIL 1 CACHE INTERNAL "")
set(CONFIG_AVCODEC 1 CACHE INTERNAL "")
set(CONFIG_AVFORMAT 1 CACHE INTERNAL "")
set(CONFIG_AVFILTER 1 CACHE INTERNAL "")
set(CONFIG_AVDEVICE 1 CACHE INTERNAL "")
set(CONFIG_SWSCALE 1 CACHE INTERNAL "")
set(CONFIG_SWRESAMPLE 1 CACHE INTERNAL "")

message(STATUS "Set cmake CONFIG_xxx variables for conditional source inclusion")

# ============================================================================
# License flags
# ============================================================================
# FFmpegDefaults.cmake already sets these based on ENABLE_GPL/ENABLE_VERSION3/ENABLE_NONFREE
# Just ensure they have default values if not defined

if(NOT DEFINED CONFIG_GPL)
    set(CONFIG_GPL 0)
endif()

if(NOT DEFINED CONFIG_VERSION3)
    set(CONFIG_VERSION3 0)
endif()

if(NOT DEFINED CONFIG_NONFREE)
    set(CONFIG_NONFREE 0)
endif()

# Library enable flags (uppercase for config.h, use 0/1 for C code)
if(FFMPEG_ENABLE_avutil)
    set(CONFIG_AVUTIL 1)
else()
    set(CONFIG_AVUTIL 0)
endif()

if(FFMPEG_ENABLE_avcodec)
    set(CONFIG_AVCODEC 1)
else()
    set(CONFIG_AVCODEC 0)
endif()

if(FFMPEG_ENABLE_avformat)
    set(CONFIG_AVFORMAT 1)
else()
    set(CONFIG_AVFORMAT 0)
endif()

if(FFMPEG_ENABLE_avfilter)
    set(CONFIG_AVFILTER 1)
else()
    set(CONFIG_AVFILTER 0)
endif()

if(FFMPEG_ENABLE_avdevice)
    set(CONFIG_AVDEVICE 1)
else()
    set(CONFIG_AVDEVICE 0)
endif()

if(FFMPEG_ENABLE_swscale)
    set(CONFIG_SWSCALE 1)
else()
    set(CONFIG_SWSCALE 0)
endif()

if(FFMPEG_ENABLE_swresample)
    set(CONFIG_SWRESAMPLE 1)
else()
    set(CONFIG_SWRESAMPLE 0)
endif()

# Export variables for parent scope
set(CODEC_LIST "${CODEC_LIST}" PARENT_SCOPE)

