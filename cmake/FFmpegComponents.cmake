# FFmpeg Components Selection Module
# Handles encoder/decoder/filter/muxer/demuxer/protocol/device selection
#
# This module generates:
# - config_components.h: Component enable/disable macros
# - codec_list.c: List of registered codecs (filtered by CONFIG_*)
# - parser_list.c: List of registered parsers (filtered by CONFIG_*)
# - bsf_list.c: List of registered bitstream filters (filtered by CONFIG_*)
# - filter_list.c: List of registered filters (filtered by CONFIG_*)
# - muxer_list.c, demuxer_list.c: List of registered (de)muxers (filtered by CONFIG_*)
# - protocol_list.c: List of registered protocols (filtered by CONFIG_*)
# - indev_list.c, outdev_list.c: List of registered devices (filtered by CONFIG_*)
#
# IMPORTANT: This module runs AFTER FFmpegDependencyResolver.cmake has set all
# CONFIG_* variables. It does NOT perform its own dependency checking.

message(STATUS "Configuring components...")

# ============================================================================
# Component Selection Options
# ============================================================================

option(ENABLE_EVERYTHING "Enable all components" OFF)
option(DISABLE_EVERYTHING "Disable all components" OFF)

# ============================================================================
# Extract all codecs from allcodecs.c
# ============================================================================

set(ALL_CODECS "")
set(ALL_ENCODERS "")
set(ALL_DECODERS "")

if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/allcodecs.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/allcodecs.c" CODEC_LINES REGEX "extern (const )?FFCodec ff_")
    foreach(LINE IN LISTS CODEC_LINES)
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
list(LENGTH ALL_PROTOCOLS PROTO_COUNT)
message(STATUS "Found ${PROTO_COUNT} protocols")

# ============================================================================
# Extract filters from allfilters.c
# ============================================================================
set(ALL_FILTERS "")
# Also store the full symbol names for list file generation
set(ALL_FILTER_SYMBOLS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c" FILTER_LINES REGEX "extern const FFFilter ff_")
    foreach(LINE IN LISTS FILTER_LINES)
        if(LINE MATCHES "extern const FFFilter (ff_[a-z0-9_]+);")
            set(FULL_NAME "${CMAKE_MATCH_1}")
            list(APPEND ALL_FILTER_SYMBOLS "${FULL_NAME}")
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
# Extract input/output devices from alldevices.c
# ============================================================================
set(ALL_INDEVS "")
set(ALL_OUTDEVS "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c" DEVICE_LINES REGEX "ff_[a-z0-9_]+_(indev|outdev)")
    foreach(LINE IN LISTS DEVICE_LINES)
        string(REGEX MATCHALL "ff_([a-z0-9_]+)_(indev|outdev)" MATCHES "${LINE}")
        foreach(MATCH IN LISTS MATCHES)
            if(MATCH MATCHES "ff_([a-z0-9_]+)_(indev|outdev)")
                set(DEV_NAME "${CMAKE_MATCH_1}")
                set(DEV_TYPE "${CMAKE_MATCH_2}")
                string(TOUPPER "${DEV_NAME}_${DEV_TYPE}" CONFIG_NAME)
                if(DEV_TYPE STREQUAL "indev")
                    list(APPEND ALL_INDEVS "${CONFIG_NAME}")
                else()
                    list(APPEND ALL_OUTDEVS "${CONFIG_NAME}")
                endif()
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES ALL_INDEVS)
    list(REMOVE_DUPLICATES ALL_OUTDEVS)
endif()
list(LENGTH ALL_INDEVS INDEV_COUNT)
list(LENGTH ALL_OUTDEVS OUTDEV_COUNT)
message(STATUS "Found ${INDEV_COUNT} input devices, ${OUTDEV_COUNT} output devices")

# ============================================================================
# Extract hwaccels from FFmpegComponentDeps.cmake variable names
# Hwaccels are NOT listed in allcodecs.c - they are only defined in
# FFmpegComponentDeps.cmake as *_HWACCEL_DEPS variables.
# ============================================================================
set(ALL_HWACCELS "")
get_cmake_property(_all_vars VARIABLES)
foreach(_var IN LISTS _all_vars)
    if(_var MATCHES "^([A-Z0-9_]+_HWACCEL)_(DEPS|DEPS_ANY|SELECT|SUGGEST|IF|IF_ANY|CONFLICT)$")
        list(APPEND ALL_HWACCELS "${CMAKE_MATCH_1}")
    endif()
endforeach()
list(REMOVE_DUPLICATES ALL_HWACCELS)
list(LENGTH ALL_HWACCELS HWACCEL_COUNT)
message(STATUS "Found ${HWACCEL_COUNT} hwaccel definitions")

# ============================================================================
# Set CONFIG_* CACHE variables for all components
# The dependency resolver has already set CONFIG_* for components with deps.
# For components WITHOUT deps (built-in), default to 1 (enabled).
# ============================================================================

# Set codec CONFIG_* variables
foreach(CODEC IN LISTS ALL_CODECS)
    if(NOT DEFINED CONFIG_${CODEC})
        # No dependency definition -> built-in codec, enable by default
        set(CONFIG_${CODEC} 1 CACHE INTERNAL "Built-in codec, enabled by default")
    else()
        # Already set by dependency resolver, just ensure it's in CACHE
        set(CONFIG_${CODEC} ${CONFIG_${CODEC}} CACHE INTERNAL "")
    endif()
endforeach()

# Set muxer CONFIG_* variables
foreach(MUXER IN LISTS ALL_MUXERS)
    if(NOT DEFINED CONFIG_${MUXER})
        set(CONFIG_${MUXER} 1 CACHE INTERNAL "Built-in muxer, enabled by default")
    else()
        set(CONFIG_${MUXER} ${CONFIG_${MUXER}} CACHE INTERNAL "")
    endif()
endforeach()

# Set demuxer CONFIG_* variables
foreach(DEMUXER IN LISTS ALL_DEMUXERS)
    if(NOT DEFINED CONFIG_${DEMUXER})
        set(CONFIG_${DEMUXER} 1 CACHE INTERNAL "Built-in demuxer, enabled by default")
    else()
        set(CONFIG_${DEMUXER} ${CONFIG_${DEMUXER}} CACHE INTERNAL "")
    endif()
endforeach()

# Set protocol CONFIG_* variables
foreach(PROTO IN LISTS ALL_PROTOCOLS)
    if(NOT DEFINED CONFIG_${PROTO})
        set(CONFIG_${PROTO} 1 CACHE INTERNAL "Built-in protocol, enabled by default")
    else()
        set(CONFIG_${PROTO} ${CONFIG_${PROTO}} CACHE INTERNAL "")
    endif()
endforeach()

# Set filter CONFIG_* variables
foreach(FILTER IN LISTS ALL_FILTERS)
    if(NOT DEFINED CONFIG_${FILTER})
        set(CONFIG_${FILTER} 1 CACHE INTERNAL "Built-in filter, enabled by default")
    else()
        set(CONFIG_${FILTER} ${CONFIG_${FILTER}} CACHE INTERNAL "")
    endif()
endforeach()

# Set BSF CONFIG_* variables
foreach(BSF IN LISTS ALL_BSFS)
    if(NOT DEFINED CONFIG_${BSF})
        set(CONFIG_${BSF} 1 CACHE INTERNAL "Built-in BSF, enabled by default")
    else()
        set(CONFIG_${BSF} ${CONFIG_${BSF}} CACHE INTERNAL "")
    endif()
endforeach()

# Set parser CONFIG_* variables
foreach(PARSER IN LISTS ALL_PARSERS)
    if(NOT DEFINED CONFIG_${PARSER})
        set(CONFIG_${PARSER} 1 CACHE INTERNAL "Built-in parser, enabled by default")
    else()
        set(CONFIG_${PARSER} ${CONFIG_${PARSER}} CACHE INTERNAL "")
    endif()
endforeach()

# Set hwaccel CONFIG_* variables
foreach(HWACCEL IN LISTS ALL_HWACCELS)
    if(NOT DEFINED CONFIG_${HWACCEL})
        set(CONFIG_${HWACCEL} 0 CACHE INTERNAL "Hwaccel, disabled by default unless deps met")
    else()
        set(CONFIG_${HWACCEL} ${CONFIG_${HWACCEL}} CACHE INTERNAL "")
    endif()
endforeach()

# Set indev/outdev CONFIG_* variables
foreach(INDEV IN LISTS ALL_INDEVS)
    if(NOT DEFINED CONFIG_${INDEV})
        set(CONFIG_${INDEV} 0 CACHE INTERNAL "Input device, disabled by default unless deps met")
    else()
        set(CONFIG_${INDEV} ${CONFIG_${INDEV}} CACHE INTERNAL "")
    endif()
endforeach()

foreach(OUTDEV IN LISTS ALL_OUTDEVS)
    if(NOT DEFINED CONFIG_${OUTDEV})
        set(CONFIG_${OUTDEV} 0 CACHE INTERNAL "Output device, disabled by default unless deps met")
    else()
        set(CONFIG_${OUTDEV} ${CONFIG_${OUTDEV}} CACHE INTERNAL "")
    endif()
endforeach()

# Set component group flags
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

# Set library flags
set(CONFIG_AVUTIL 1 CACHE INTERNAL "")
set(CONFIG_AVCODEC 1 CACHE INTERNAL "")
set(CONFIG_AVFORMAT 1 CACHE INTERNAL "")
set(CONFIG_AVFILTER 1 CACHE INTERNAL "")
set(CONFIG_AVDEVICE 1 CACHE INTERNAL "")
set(CONFIG_SWSCALE 1 CACHE INTERNAL "")
set(CONFIG_SWRESAMPLE 1 CACHE INTERNAL "")

# Tool flags
set(CONFIG_FFMPEG 1 CACHE INTERNAL "")
set(CONFIG_FFPLAY 1 CACHE INTERNAL "")
set(CONFIG_FFPROBE 1 CACHE INTERNAL "")

message(STATUS "Set CONFIG_* variables for all components")

# ============================================================================
# Generate config_components.h
# Uses CONFIG_* variables set by dependency resolver + defaults above
# ============================================================================

set(CONFIG_COMPONENTS_CONTENT "/* Auto-generated by CMake - do not edit! */
#ifndef FFMPEG_CONFIG_COMPONENTS_H
#define FFMPEG_CONFIG_COMPONENTS_H

")

# License flags
string(APPEND CONFIG_COMPONENTS_CONTENT "/* License flags */\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_GPL ${CONFIG_GPL}\n")
if(NOT DEFINED CONFIG_VERSION3)
    set(CONFIG_VERSION3 0)
endif()
if(NOT DEFINED CONFIG_NONFREE)
    set(CONFIG_NONFREE 0)
endif()
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_VERSION3 ${CONFIG_VERSION3}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_NONFREE ${CONFIG_NONFREE}\n\n")

# Library enable flags
string(APPEND CONFIG_COMPONENTS_CONTENT "/* Library enable flags */\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_AVUTIL ${CONFIG_AVUTIL}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_AVCODEC ${CONFIG_AVCODEC}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_AVFORMAT ${CONFIG_AVFORMAT}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_AVFILTER ${CONFIG_AVFILTER}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_AVDEVICE ${CONFIG_AVDEVICE}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_SWSCALE ${CONFIG_SWSCALE}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_SWRESAMPLE ${CONFIG_SWRESAMPLE}\n\n")

# Tool enable flags
string(APPEND CONFIG_COMPONENTS_CONTENT "/* Tool enable flags */\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_FFMPEG ${CONFIG_FFMPEG}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_FFPLAY ${CONFIG_FFPLAY}\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_FFPROBE ${CONFIG_FFPROBE}\n\n")

# Component groups
string(APPEND CONFIG_COMPONENTS_CONTENT "/* Component groups */\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_DECODERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_ENCODERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_MUXERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_DEMUXERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_PROTOCOLS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_FILTERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_BSFS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_PARSERS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_INDEVS 1\n")
string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_OUTDEVS 1\n\n")

# Codec configurations - use CONFIG_* from dependency resolver
string(APPEND CONFIG_COMPONENTS_CONTENT "/* Codec configurations */\n")
foreach(CODEC IN LISTS ALL_CODECS)
    if(CONFIG_${CODEC})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${CODEC} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${CODEC} 0\n")
    endif()
endforeach()

# Muxer configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Muxer configurations */\n")
foreach(MUXER IN LISTS ALL_MUXERS)
    if(CONFIG_${MUXER})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${MUXER} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${MUXER} 0\n")
    endif()
endforeach()

# Demuxer configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Demuxer configurations */\n")
foreach(DEMUXER IN LISTS ALL_DEMUXERS)
    if(CONFIG_${DEMUXER})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${DEMUXER} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${DEMUXER} 0\n")
    endif()
endforeach()

# Protocol configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Protocol configurations */\n")
foreach(PROTO IN LISTS ALL_PROTOCOLS)
    if(CONFIG_${PROTO})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PROTO} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PROTO} 0\n")
    endif()
endforeach()

# Filter configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Filter configurations */\n")
foreach(FILTER IN LISTS ALL_FILTERS)
    if(CONFIG_${FILTER})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${FILTER} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${FILTER} 0\n")
    endif()
endforeach()

# BSF configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* BSF configurations */\n")
foreach(BSF IN LISTS ALL_BSFS)
    if(CONFIG_${BSF})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${BSF} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${BSF} 0\n")
    endif()
endforeach()

# Parser configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Parser configurations */\n")
foreach(PARSER IN LISTS ALL_PARSERS)
    if(CONFIG_${PARSER})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PARSER} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${PARSER} 0\n")
    endif()
endforeach()

# Hardware acceleration configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Hardware acceleration configurations */\n")
foreach(HWACCEL IN LISTS ALL_HWACCELS)
    if(CONFIG_${HWACCEL})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${HWACCEL} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${HWACCEL} 0\n")
    endif()
endforeach()

# Input device configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Input device configurations */\n")
foreach(INDEV IN LISTS ALL_INDEVS)
    if(CONFIG_${INDEV})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${INDEV} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${INDEV} 0\n")
    endif()
endforeach()

# Output device configurations
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Output device configurations */\n")
foreach(OUTDEV IN LISTS ALL_OUTDEVS)
    if(CONFIG_${OUTDEV})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${OUTDEV} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${OUTDEV} 0\n")
    endif()
endforeach()

# Internal subsystem configurations (CONFIG_EXTRA in configure)
# These are components with _DEPS/_SELECT definitions that don't fall into
# any of the above categories (not encoders, decoders, muxers, etc.)
# Examples: RTPDEC, GOLOMB, ATSC_A53, ISO_MEDIA, CBS_H264, etc.
string(APPEND CONFIG_COMPONENTS_CONTENT "\n/* Internal subsystem configurations (CONFIG_EXTRA) */\n")

# Build a set of all already-written component names to avoid duplicates
set(_already_written "")
foreach(_item IN LISTS ALL_CODECS ALL_MUXERS ALL_DEMUXERS ALL_PROTOCOLS ALL_FILTERS ALL_BSFS ALL_PARSERS ALL_HWACCELS ALL_INDEVS ALL_OUTDEVS)
    list(APPEND _already_written "${_item}")
endforeach()

# Also exclude variables already defined in config.h.in to prevent
# macro redefinition warnings (e.g. CONFIG_VULKAN defined in both files)
if(EXISTS "${CMAKE_SOURCE_DIR}/cmake/config.h.in")
    file(STRINGS "${CMAKE_SOURCE_DIR}/cmake/config.h.in" _config_h_lines)
    foreach(_line IN LISTS _config_h_lines)
        if(_line MATCHES "#define CONFIG_([A-Z0-9_]+)")
            list(APPEND _already_written "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endif()

# Scan all variables for dependency-defined components
get_cmake_property(_all_vars VARIABLES)
set(_internal_subsystems "")
foreach(_var IN LISTS _all_vars)
    if(_var MATCHES "^([A-Z0-9_]+)_(DEPS|SELECT|SUGGEST|DEPS_ANY|IF|IF_ANY|CONFLICT)$")
        set(_comp_name "${CMAKE_MATCH_1}")
        list(FIND _already_written "${_comp_name}" _aw_idx)
        if(_aw_idx EQUAL -1)
            list(APPEND _internal_subsystems "${_comp_name}")
        endif()
    endif()
endforeach()
list(REMOVE_DUPLICATES _internal_subsystems)
list(SORT _internal_subsystems)

foreach(_subsys IN LISTS _internal_subsystems)
    if(DEFINED CONFIG_${_subsys} AND CONFIG_${_subsys})
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${_subsys} 1\n")
    else()
        string(APPEND CONFIG_COMPONENTS_CONTENT "#define CONFIG_${_subsys} 0\n")
    endif()
endforeach()

list(LENGTH _internal_subsystems _num_internal)
message(STATUS "Added ${_num_internal} internal subsystem definitions to config_components.h")

string(APPEND CONFIG_COMPONENTS_CONTENT "\n#endif /* FFMPEG_CONFIG_COMPONENTS_H */\n")

file(WRITE "${CMAKE_BINARY_DIR}/config_components.h.tmp" "${CONFIG_COMPONENTS_CONTENT}")
configure_file("${CMAKE_BINARY_DIR}/config_components.h.tmp" "${CMAKE_BINARY_DIR}/config_components.h" COPYONLY)

# Count enabled/disabled
set(_enabled_codecs 0)
set(_disabled_codecs 0)
foreach(CODEC IN LISTS ALL_CODECS)
    if(CONFIG_${CODEC})
        math(EXPR _enabled_codecs "${_enabled_codecs} + 1")
    else()
        math(EXPR _disabled_codecs "${_disabled_codecs} + 1")
    endif()
endforeach()
message(STATUS "Generated config_components.h: ${_enabled_codecs} codecs enabled, ${_disabled_codecs} disabled")

# ============================================================================
# Generate List Files (filtered by CONFIG_*)
# ============================================================================

# Create output directories
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavcodec")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavformat")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavfilter")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavdevice")

# NOTE: codec_list.c is generated in libavcodec/CMakeLists.txt (with allcodecs_generated.c)

# --------------------------------------------------------------------------
# parser_list.c - only include enabled parsers
# --------------------------------------------------------------------------
set(PARSER_ENTRIES "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavcodec/parsers.c" PARSER_LINES REGEX "extern const FFCodecParser ff_")
    foreach(LINE IN LISTS PARSER_LINES)
        if(LINE MATCHES "extern const FFCodecParser (ff_([a-z0-9_]+)_parser)")
            set(PARSER_SYM "${CMAKE_MATCH_1}")
            set(PARSER_NAME "${CMAKE_MATCH_2}")
            string(TOUPPER "${PARSER_NAME}_PARSER" _cfg)
            if(CONFIG_${_cfg})
                string(APPEND PARSER_ENTRIES "    &${PARSER_SYM},\n")
            endif()
        endif()
    endforeach()
endif()

set(PARSER_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND PARSER_LIST_CONTENT "static const FFCodecParser * const parser_list[] = {\n")
string(APPEND PARSER_LIST_CONTENT "${PARSER_ENTRIES}")
string(APPEND PARSER_LIST_CONTENT "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/parser_list.c" "${PARSER_LIST_CONTENT}")

# NOTE: bsf_list.c is generated in libavcodec/CMakeLists.txt

# --------------------------------------------------------------------------
# muxer_list.c - only include enabled muxers
# --------------------------------------------------------------------------
# Scan source files for muxer symbols
set(MUXER_ENTRIES "")
set(MUXER_EXTERNS "")
file(GLOB _avfmt_sources "${CMAKE_SOURCE_DIR}/libavformat/*.c")
set(_muxer_syms "")
foreach(_src ${_avfmt_sources})
    file(STRINGS "${_src}" _lines REGEX "const[ \t]+FFOutputFormat[ \t]+ff_[a-zA-Z0-9_]+_muxer")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \t]+FFOutputFormat[ \t]+(ff_([a-zA-Z0-9_]+)_muxer)")
            set(_sym "${CMAKE_MATCH_1}")
            set(_name "${CMAKE_MATCH_2}")
            string(TOUPPER "${_name}_MUXER" _cfg)
            if(CONFIG_${_cfg})
                list(APPEND _muxer_syms "${_sym}")
            endif()
        endif()
    endforeach()
endforeach()
list(REMOVE_DUPLICATES _muxer_syms)
list(SORT _muxer_syms)

set(MUXER_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND MUXER_LIST_CONTENT "#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND MUXER_LIST_CONTENT "extern const FFOutputFormat ${_sym};\n")
endforeach()
string(APPEND MUXER_LIST_CONTENT "\nstatic const FFOutputFormat * const muxer_list[] = {\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND MUXER_LIST_CONTENT "    &${_sym},\n")
endforeach()
string(APPEND MUXER_LIST_CONTENT "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/muxer_list.c" "${MUXER_LIST_CONTENT}")

# --------------------------------------------------------------------------
# demuxer_list.c - only include enabled demuxers
# --------------------------------------------------------------------------
set(_demuxer_syms "")
foreach(_src ${_avfmt_sources})
    file(STRINGS "${_src}" _lines REGEX "const[ \t]+FFInputFormat[ \t]+ff_[a-zA-Z0-9_]+_demuxer")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \t]+FFInputFormat[ \t]+(ff_([a-zA-Z0-9_]+)_demuxer)")
            set(_sym "${CMAKE_MATCH_1}")
            set(_name "${CMAKE_MATCH_2}")
            string(TOUPPER "${_name}_DEMUXER" _cfg)
            if(CONFIG_${_cfg})
                list(APPEND _demuxer_syms "${_sym}")
            endif()
        endif()
    endforeach()
endforeach()
list(REMOVE_DUPLICATES _demuxer_syms)
list(SORT _demuxer_syms)

set(DEMUXER_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND DEMUXER_LIST_CONTENT "#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND DEMUXER_LIST_CONTENT "extern const FFInputFormat ${_sym};\n")
endforeach()
string(APPEND DEMUXER_LIST_CONTENT "\nstatic const FFInputFormat * const demuxer_list[] = {\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND DEMUXER_LIST_CONTENT "    &${_sym},\n")
endforeach()
string(APPEND DEMUXER_LIST_CONTENT "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/demuxer_list.c" "${DEMUXER_LIST_CONTENT}")

# --------------------------------------------------------------------------
# protocol_list.c - only include enabled protocols
# --------------------------------------------------------------------------
set(_proto_syms "")
foreach(_src ${_avfmt_sources})
    file(STRINGS "${_src}" _lines REGEX "const[ \t]+URLProtocol[ \t]+ff_[a-zA-Z0-9_]+_protocol")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \t]+URLProtocol[ \t]+(ff_([a-zA-Z0-9_]+)_protocol)")
            set(_sym "${CMAKE_MATCH_1}")
            set(_name "${CMAKE_MATCH_2}")
            string(TOUPPER "${_name}_PROTOCOL" _cfg)
            if(CONFIG_${_cfg})
                list(APPEND _proto_syms "${_sym}")
            endif()
        endif()
    endforeach()
endforeach()
list(REMOVE_DUPLICATES _proto_syms)
list(SORT _proto_syms)

set(PROTO_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND PROTO_LIST_CONTENT "#include \"libavformat/url.h\"\n\n")
foreach(_sym IN LISTS _proto_syms)
    string(APPEND PROTO_LIST_CONTENT "extern const URLProtocol ${_sym};\n")
endforeach()
string(APPEND PROTO_LIST_CONTENT "\nstatic const URLProtocol * const url_protocols[] = {\n")
foreach(_sym IN LISTS _proto_syms)
    string(APPEND PROTO_LIST_CONTENT "    &${_sym},\n")
endforeach()
string(APPEND PROTO_LIST_CONTENT "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/protocol_list.c" "${PROTO_LIST_CONTENT}")

list(LENGTH _muxer_syms _nmux)
list(LENGTH _demuxer_syms _ndemux)
list(LENGTH _proto_syms _nproto)
message(STATUS "Generated libavformat lists: ${_nmux} muxers, ${_ndemux} demuxers, ${_nproto} protocols")

# --------------------------------------------------------------------------
# filter_list.c - only include enabled filters
# --------------------------------------------------------------------------
set(FILTER_ENTRIES "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavfilter/allfilters.c" FILTER_LINES2 REGEX "extern const FFFilter ff_")
    foreach(LINE IN LISTS FILTER_LINES2)
        if(LINE MATCHES "extern const FFFilter (ff_(af|vf|avf|asrc|vsrc|asink|vsink)_([a-z0-9_]+));")
            set(FILTER_SYM "${CMAKE_MATCH_1}")
            set(FILTER_NAME "${CMAKE_MATCH_3}")
            string(TOUPPER "${FILTER_NAME}_FILTER" _cfg)
            if(CONFIG_${_cfg})
                string(APPEND FILTER_ENTRIES "    &${FILTER_SYM},\n")
            endif()
        endif()
    endforeach()
endif()

set(FILTER_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND FILTER_LIST_CONTENT "/* Filter list - included by allfilters.c */\n\n")
string(APPEND FILTER_LIST_CONTENT "static const FFFilter * const filter_list[] = {\n")
string(APPEND FILTER_LIST_CONTENT "${FILTER_ENTRIES}")
string(APPEND FILTER_LIST_CONTENT "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/filter_list.c" "${FILTER_LIST_CONTENT}")

# --------------------------------------------------------------------------
# indev_list.c - only include enabled input devices
# --------------------------------------------------------------------------
set(INDEV_ENTRIES "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c" INDEV_LINES REGEX "ff_[a-z0-9_]+_demuxer")
    foreach(LINE IN LISTS INDEV_LINES)
        if(LINE MATCHES "(ff_([a-z0-9_]+)_demuxer)")
            set(DEV_SYM "${CMAKE_MATCH_1}")
            set(DEV_NAME "${CMAKE_MATCH_2}")
            string(TOUPPER "${DEV_NAME}_INDEV" _cfg)
            if(CONFIG_${_cfg})
                string(APPEND INDEV_ENTRIES "    &${DEV_SYM},\n")
            endif()
        endif()
    endforeach()
endif()

set(INDEV_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND INDEV_LIST_CONTENT "static const FFInputFormat * const indev_list[] = {\n")
string(APPEND INDEV_LIST_CONTENT "${INDEV_ENTRIES}")
string(APPEND INDEV_LIST_CONTENT "    NULL };\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavdevice/indev_list.c" "${INDEV_LIST_CONTENT}")

# --------------------------------------------------------------------------
# outdev_list.c - only include enabled output devices
# --------------------------------------------------------------------------
set(OUTDEV_ENTRIES "")
if(EXISTS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c")
    file(STRINGS "${CMAKE_SOURCE_DIR}/libavdevice/alldevices.c" OUTDEV_LINES REGEX "ff_[a-z0-9_]+_muxer")
    foreach(LINE IN LISTS OUTDEV_LINES)
        if(LINE MATCHES "(ff_([a-z0-9_]+)_muxer)")
            set(DEV_SYM "${CMAKE_MATCH_1}")
            set(DEV_NAME "${CMAKE_MATCH_2}")
            string(TOUPPER "${DEV_NAME}_OUTDEV" _cfg)
            if(CONFIG_${_cfg})
                string(APPEND OUTDEV_ENTRIES "    &${DEV_SYM},\n")
            endif()
        endif()
    endforeach()
endif()

set(OUTDEV_LIST_CONTENT "/* Auto-generated by CMake - do not edit! */\n")
string(APPEND OUTDEV_LIST_CONTENT "static const FFOutputFormat * const outdev_list[] = {\n")
string(APPEND OUTDEV_LIST_CONTENT "${OUTDEV_ENTRIES}")
string(APPEND OUTDEV_LIST_CONTENT "    NULL };\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavdevice/outdev_list.c" "${OUTDEV_LIST_CONTENT}")

message(STATUS "Generated all component list files")

# ============================================================================
# License flags (ensure defaults)
# ============================================================================
if(NOT DEFINED CONFIG_GPL)
    set(CONFIG_GPL 0)
endif()
if(NOT DEFINED CONFIG_VERSION3)
    set(CONFIG_VERSION3 0)
endif()
if(NOT DEFINED CONFIG_NONFREE)
    set(CONFIG_NONFREE 0)
endif()

# Library enable flags based on user options
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

# Component lists are already available in the current scope since this file
# is included (not called as a function). No PARENT_SCOPE needed.
