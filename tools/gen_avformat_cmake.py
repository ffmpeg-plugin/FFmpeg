#!/usr/bin/env python3
"""
Generate libavformat/CMakeLists.txt from Makefiles with explicit source lists.

Usage:
    python3 tools/gen_avformat_cmake.py > libavformat/CMakeLists.txt
"""

import re
import os
import sys
from collections import OrderedDict


def parse_makefile_config_entries(makefile_path):
    """Parse all OBJS-$(CONFIG_XXX) entries."""
    with open(makefile_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    result = {}
    
    current_prefix = None
    current_config = None
    current_files = []

    for line in lines:
        m = re.match(r'^((?:X86ASM-|NEON-|ARMV8-|SME2-|STLIBOBJS-)?OBJS)-\$\(CONFIG_([A-Z0-9_]+)\)\s*\+=\s*(.*)', line)
        if m:
            if current_config is not None:
                if current_prefix not in result:
                    result[current_prefix] = OrderedDict()
                if current_config not in result[current_prefix]:
                    result[current_prefix][current_config] = []
                result[current_prefix][current_config].extend(current_files)

            current_prefix = m.group(1)
            current_config = m.group(2)
            rest = m.group(3).strip()
            current_files = []

            cont = rest.endswith('\\')
            rest = rest.rstrip('\\').strip()

            for token in rest.split():
                token = token.strip()
                if not token or token.startswith('$('):
                    continue
                if token.endswith('.o'):
                    current_files.append(token[:-2] + '.c')

            if not cont:
                if current_prefix not in result:
                    result[current_prefix] = OrderedDict()
                if current_config not in result[current_prefix]:
                    result[current_prefix][current_config] = []
                result[current_prefix][current_config].extend(current_files)
                current_prefix = None
                current_config = None
                current_files = []

        elif current_config is not None:
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                if current_prefix not in result:
                    result[current_prefix] = OrderedDict()
                if current_config not in result[current_prefix]:
                    result[current_prefix][current_config] = []
                result[current_prefix][current_config].extend(current_files)
                current_prefix = None
                current_config = None
                current_files = []
                continue

            cont = stripped.endswith('\\')
            stripped = stripped.rstrip('\\').strip()

            for token in stripped.split():
                token = token.strip()
                if not token or token.startswith('$('):
                    continue
                if token.endswith('.o'):
                    current_files.append(token[:-2] + '.c')

            if not cont:
                if current_prefix not in result:
                    result[current_prefix] = OrderedDict()
                if current_config not in result[current_prefix]:
                    result[current_prefix][current_config] = []
                result[current_prefix][current_config].extend(current_files)
                current_prefix = None
                current_config = None
                current_files = []

    if current_config is not None:
        if current_prefix not in result:
            result[current_prefix] = OrderedDict()
        if current_config not in result[current_prefix]:
            result[current_prefix][current_config] = []
        result[current_prefix][current_config].extend(current_files)

    return result


def parse_unconditional_objs(makefile_path):
    with open(makefile_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    objs = []
    in_objs = False

    for line in lines:
        m = re.match(r'^OBJS\s*[+]?=\s*(.*)', line)
        if m and not re.match(r'^OBJS-', line.strip()):
            in_objs = True
            rest = m.group(1).strip()
            cont = rest.endswith('\\')
            rest = rest.rstrip('\\').strip()
            for token in rest.split():
                token = token.strip()
                if token.endswith('.o'):
                    objs.append(token[:-2] + '.c')
            if not cont:
                in_objs = False
        elif in_objs:
            stripped = line.strip()
            if not stripped:
                in_objs = False
                continue
            cont = stripped.endswith('\\')
            stripped = stripped.rstrip('\\').strip()
            for token in stripped.split():
                token = token.strip()
                if token.endswith('.o'):
                    objs.append(token[:-2] + '.c')
            if not cont:
                in_objs = False

    return objs


def dedup_preserve_order(lst):
    seen = set()
    result = []
    for item in lst:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def format_config_block(config_name, files, varname, indent=""):
    unique_files = dedup_preserve_order(files)
    lines = [f"{indent}if(CONFIG_{config_name})"]
    for f in unique_files:
        lines.append(f"{indent}    list(APPEND {varname} {f})")
    lines.append(f"{indent}endif()")
    return '\n'.join(lines)


def main():
    src_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    lib_dir = os.path.join(src_root, 'libavformat')
    
    main_mf = os.path.join(lib_dir, 'Makefile')
    main_entries = parse_makefile_config_entries(main_mf)
    main_objs = parse_unconditional_objs(main_mf)
    
    # Also parse iamf/Makefile if it exists
    iamf_mf = os.path.join(lib_dir, 'iamf', 'Makefile')
    iamf_entries = parse_makefile_config_entries(iamf_mf) if os.path.exists(iamf_mf) else {}
    
    # Merge all OBJS entries
    all_objs = OrderedDict()
    if 'OBJS' in main_entries:
        for k, v in main_entries['OBJS'].items():
            if k not in all_objs:
                all_objs[k] = []
            all_objs[k].extend(v)
    if 'OBJS' in iamf_entries:
        for k, v in iamf_entries['OBJS'].items():
            if k not in all_objs:
                all_objs[k] = []
            all_objs[k].extend(v)
    
    out = []
    def w(s=""):
        out.append(s)
    
    w("# libavformat CMakeLists.txt")
    w("# Generated from libavformat/Makefile by tools/gen_avformat_cmake.py")
    w("# All source files are listed explicitly (no file(GLOB) usage).")
    w()
    
    # Core sources
    w("# ============================================================================")
    w("# Core sources (unconditional, from OBJS = in Makefile)")
    w("# ============================================================================")
    w("set(avformat_sources")
    for f in main_objs:
        w(f"    {f}")
    w(")")
    w()
    
    # Conditional sources
    w("# ============================================================================")
    w("# Conditional sources based on CONFIG_* variables")
    w("# (from OBJS-$(CONFIG_*) in Makefile)")
    w("# ============================================================================")
    w()
    
    # Group by category
    muxers = OrderedDict()
    demuxers = OrderedDict()
    protocols = OrderedDict()
    subsystems = OrderedDict()
    
    for k, v in all_objs.items():
        if k.endswith('_MUXER'):
            muxers[k] = v
        elif k.endswith('_DEMUXER'):
            demuxers[k] = v
        elif k.endswith('_PROTOCOL'):
            protocols[k] = v
        else:
            subsystems[k] = v
    
    if subsystems:
        w("# --- Subsystems and helpers ---")
        for k, v in subsystems.items():
            w(format_config_block(k, v, "avformat_sources"))
            w()
    
    w("# --- Muxers ---")
    for k, v in muxers.items():
        w(format_config_block(k, v, "avformat_sources"))
        w()
    
    w("# --- Demuxers ---")
    for k, v in demuxers.items():
        w(format_config_block(k, v, "avformat_sources"))
        w()
    
    w("# --- Protocols ---")
    for k, v in protocols.items():
        w(format_config_block(k, v, "avformat_sources"))
        w()
    
    # Remove duplicates and filter
    w("# ============================================================================")
    w("# Remove duplicates")
    w("# ============================================================================")
    w("list(REMOVE_DUPLICATES avformat_sources)")
    w()
    w("# Filter out source files that don't exist")
    w('set(avformat_sources_filtered "")')
    w("foreach(src IN LISTS avformat_sources)")
    w('    if(IS_ABSOLUTE "${src}")')
    w("        list(APPEND avformat_sources_filtered \"${src}\")")
    w('    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")')
    w("        list(APPEND avformat_sources_filtered \"${src}\")")
    w("    else()")
    w('        message(STATUS "avformat: skipping missing source file: ${src}")')
    w("    endif()")
    w("endforeach()")
    w("set(avformat_sources ${avformat_sources_filtered})")
    w()
    
    # Generate muxer/demuxer/protocol lists
    w("""# ============================================================================
# Generate muxer_list.c, demuxer_list.c, protocol_list.c
# by scanning the actual source files that will be compiled
# ============================================================================
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavformat")

set(_muxer_syms "")
set(_demuxer_syms "")
set(_protocol_syms "")

foreach(_src IN LISTS avformat_sources)
    if(IS_ABSOLUTE "${_src}")
        set(_src_abs "${_src}")
    else()
        set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
    endif()
    if(NOT EXISTS "${_src_abs}")
        continue()
    endif()
    get_filename_component(_src_name "${_src_abs}" NAME)
    # Skip allformats.c and protocols.c - they only have extern declarations
    if("${_src_name}" STREQUAL "allformats.c" OR "${_src_name}" STREQUAL "protocols.c")
        continue()
    endif()
    file(STRINGS "${_src_abs}" _lines
        REGEX "^(const[ \\t]+FFOutputFormat|const[ \\t]+FFInputFormat|const[ \\t]+URLProtocol)[ \\t]+ff_[a-zA-Z0-9_]+")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \\t]+FFOutputFormat[ \\t]+(ff_[a-zA-Z0-9_]+_muxer)")
            list(APPEND _muxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \\t]+FFInputFormat[ \\t]+(ff_[a-zA-Z0-9_]+_demuxer)")
            list(APPEND _demuxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \\t]+URLProtocol[ \\t]+(ff_[a-zA-Z0-9_]+_protocol)")
            list(APPEND _protocol_syms "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endforeach()

list(REMOVE_DUPLICATES _muxer_syms)
list(REMOVE_DUPLICATES _demuxer_syms)
list(REMOVE_DUPLICATES _protocol_syms)
list(SORT _muxer_syms)
list(SORT _demuxer_syms)
list(SORT _protocol_syms)

# Remove symbols that are conditionally compiled and not available on this platform
list(REMOVE_ITEM _muxer_syms ff_fifo_test_muxer)
list(REMOVE_ITEM _protocol_syms ff_android_content_protocol ff_async_test_protocol)

if(NOT CONFIG_TLS_PROTOCOL AND NOT CONFIG_DTLS_PROTOCOL)
    list(REMOVE_ITEM _protocol_syms ff_gophers_protocol ff_https_protocol ff_tls_protocol)
endif()
if(NOT CONFIG_DTLS_PROTOCOL)
    list(REMOVE_ITEM _protocol_syms ff_dtls_protocol)
endif()
if(NOT CONFIG_WHIP_MUXER)
    list(REMOVE_ITEM _muxer_syms ff_whip_muxer)
endif()

# Write muxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\\n#include \\"libavformat/internal.h\\"\\n\\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "extern const FFOutputFormat ${_sym};\\n")
endforeach()
string(APPEND _content "\\nstatic const FFOutputFormat * const muxer_list[] = {\\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "    &${_sym},\\n")
endforeach()
string(APPEND _content "    NULL\\n};\\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/muxer_list.c" "${_content}")

# Write demuxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\\n#include \\"libavformat/internal.h\\"\\n\\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "extern const FFInputFormat ${_sym};\\n")
endforeach()
string(APPEND _content "\\nstatic const FFInputFormat * const demuxer_list[] = {\\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "    &${_sym},\\n")
endforeach()
string(APPEND _content "    NULL\\n};\\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/demuxer_list.c" "${_content}")

# Write protocol_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\\n#include \\"libavformat/url.h\\"\\n\\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "extern const URLProtocol ${_sym};\\n")
endforeach()
string(APPEND _content "\\nstatic const URLProtocol * const url_protocols[] = {\\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "    &${_sym},\\n")
endforeach()
string(APPEND _content "    NULL\\n};\\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/protocol_list.c" "${_content}")

list(LENGTH _muxer_syms _nmux)
list(LENGTH _demuxer_syms _ndemux)
list(LENGTH _protocol_syms _nproto)
message(STATUS "libavformat: ${_nmux} muxers, ${_ndemux} demuxers, ${_nproto} protocols")""")
    w()
    
    # Build target
    w("# ============================================================================")
    w("# Create the library")
    w("# ============================================================================")
    w("add_library(avformat STATIC ${avformat_sources})")
    w()
    w("# Include directories")
    w("target_include_directories(avformat")
    w("    PUBLIC")
    w("        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>")
    w(")")
    w()
    w("# Link dependencies")
    w("target_link_libraries(avformat")
    w("    PRIVATE")
    w("        avcodec")
    w("        avutil")
    w("        Threads::Threads")
    w(")")
    w()
    w("""# Link OpenSSL if enabled (needed for RTMP DH, TLS)
if(CONFIG_OPENSSL AND OPENSSL_FOUND)
    target_link_libraries(avformat PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# Link GnuTLS if enabled (needed for tls_gnutls.c)
if(CONFIG_GNUTLS AND GNUTLS_FOUND)
    if(TARGET PkgConfig::GNUTLS)
        target_link_libraries(avformat PRIVATE PkgConfig::GNUTLS)
    else()
        target_link_libraries(avformat PRIVATE ${GNUTLS_LIBRARIES})
        target_include_directories(avformat PRIVATE ${GNUTLS_INCLUDE_DIRS})
        if(GNUTLS_LIBRARY_DIRS)
            target_link_directories(avformat PRIVATE ${GNUTLS_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link libxml2 if available (needed for dashdec.c DASH demuxer)
if(CONFIG_LIBXML2 AND libxml2_found)
    if(PC_LIBXML2_LDFLAGS)
        target_link_libraries(avformat PRIVATE ${PC_LIBXML2_LDFLAGS})
    endif()
    if(PC_LIBXML2_INCLUDE_DIRS)
        target_include_directories(avformat PRIVATE ${PC_LIBXML2_INCLUDE_DIRS})
    endif()
    message(STATUS "avformat: linking libxml2")
else()
    message(STATUS "avformat: libxml2 not found, excluding dashdec.c, imfdec.c, imf_cpl.c")
    get_target_property(_avfmt_srcs avformat SOURCES)
    list(FILTER _avfmt_srcs EXCLUDE REGEX "(dashdec|imfdec|imf_cpl)\\.c$")
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")

    set(_stub_file "${CMAKE_CURRENT_BINARY_DIR}/avformat_xml_stubs.c")
    file(WRITE "${_stub_file}" "
/* Auto-generated stub: provides empty demuxer/muxer/protocol structs when deps are absent */
#include \\"avformat.h\\"
#include \\"demux.h\\"
#include \\"mux.h\\"
#include \\"url.h\\"

/* Stub for DASH demuxer (requires libxml2) */
const FFInputFormat ff_dash_demuxer = {
    .p.name = \\"dash\\",
    .p.long_name = \\"Dynamic Adaptive Streaming over HTTP (stub)\\",
};

/* Stub for IMF demuxer (requires libxml2) */
const FFInputFormat ff_imf_demuxer = {
    .p.name = \\"imf\\",
    .p.long_name = \\"IMF (Interoperable Master Format) (stub)\\",
};

/* Stub for WHIP muxer (requires OpenSSL) */
const FFOutputFormat ff_whip_muxer = {
    .p.name = \\"whip\\",
    .p.long_name = \\"WebRTC WHIP (stub)\\",
};

/* Stub for Unix domain socket protocol (requires sys/un.h, POSIX only) */
const URLProtocol ff_unix_protocol = {
    .name = \\"unix\\",
};
")
    target_sources(avformat PRIVATE "${_stub_file}")
endif()

# Link zlib if available (needed for mov.c, http.c, etc.)
find_package(ZLIB QUIET)
if(ZLIB_FOUND)
    target_link_libraries(avformat PRIVATE ZLIB::ZLIB)
endif()

# On Windows, exclude files that require POSIX-only headers
if(WIN32)
    get_target_property(_avfmt_srcs avformat SOURCES)
    list(FILTER _avfmt_srcs EXCLUDE REGEX "unix\\.c$")
    if(NOT OPENSSL_FOUND AND LIBXML2_FOUND)
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\\.c$")
    elseif(NOT OPENSSL_FOUND AND NOT LIBXML2_FOUND)
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\\.c$")
    endif()
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")
    target_link_libraries(avformat PRIVATE ws2_32)
endif()

# External library include/link are handled centrally in cmake/FFmpegApplyExternalLibs.cmake""")
    w()
    w("# Compiler definitions")
    w("target_compile_definitions(avformat PRIVATE")
    w("    HAVE_AV_CONFIG_H")
    w("    BUILDING_avformat")
    w(")")
    w()
    w("# Position independent code for shared builds")
    w("set_pic_if_needed(avformat)")
    w()
    w("# Set output name")
    w("set_target_properties(avformat PROPERTIES")
    w("    OUTPUT_NAME avformat")
    w("    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w("    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w(")")
    w()
    w('message(STATUS "libavformat configured")')
    
    print('\n'.join(out))


if __name__ == '__main__':
    main()
