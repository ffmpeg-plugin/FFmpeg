#!/usr/bin/env python3
"""
Generate libavfilter/CMakeLists.txt from Makefiles with explicit source lists.

Replaces all file(GLOB ...) patterns with explicit source file lists derived
from the authoritative Makefile definitions.

Usage:
    python3 tools/gen_avfilter_cmake.py > libavfilter/CMakeLists.txt
"""

import re
import os
import sys
from collections import OrderedDict


def parse_makefile_config_entries(makefile_path):
    """Parse all OBJS-$(CONFIG_XXX), X86ASM-OBJS-$(CONFIG_XXX), NEON-OBJS-$(CONFIG_XXX), etc."""
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
    """Parse unconditional OBJS = ... entries."""
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
    lib_dir = os.path.join(src_root, 'libavfilter')
    
    # Parse Makefiles
    main_mf = os.path.join(lib_dir, 'Makefile')
    main_entries = parse_makefile_config_entries(main_mf)
    main_objs = parse_unconditional_objs(main_mf)
    
    # Subdirectory Makefiles
    dnn_mf = os.path.join(lib_dir, 'dnn', 'Makefile')
    dnn_entries = parse_makefile_config_entries(dnn_mf) if os.path.exists(dnn_mf) else {}
    
    x86_mf = os.path.join(lib_dir, 'x86', 'Makefile')
    x86_entries = parse_makefile_config_entries(x86_mf) if os.path.exists(x86_mf) else {}
    
    aarch64_mf = os.path.join(lib_dir, 'aarch64', 'Makefile')
    aarch64_entries = parse_makefile_config_entries(aarch64_mf) if os.path.exists(aarch64_mf) else {}
    
    # Merge all OBJS entries
    all_objs = OrderedDict()
    if 'OBJS' in main_entries:
        for k, v in main_entries['OBJS'].items():
            if k not in all_objs:
                all_objs[k] = []
            all_objs[k].extend(v)
    if 'OBJS' in dnn_entries:
        for k, v in dnn_entries['OBJS'].items():
            if k not in all_objs:
                all_objs[k] = []
            all_objs[k].extend(v)
    
    out = []
    def w(s=""):
        out.append(s)
    
    w("# libavfilter CMakeLists.txt")
    w("# Generated from libavfilter/Makefile by tools/gen_avfilter_cmake.py")
    w("# All source files are listed explicitly (no file(GLOB) usage).")
    w()
    
    # ---- Core sources ----
    w("# ============================================================================")
    w("# Core sources (unconditional, from OBJS = in Makefile)")
    w("# ============================================================================")
    w("set(avfilter_sources")
    for f in main_objs:
        if f == 'allfilters.c':
            w(f"    # allfilters.c is replaced by generated allfilters.c (see below)")
            continue
        w(f"    {f}")
    w(")")
    w()
    
    # ---- Conditional sources ----
    w("# ============================================================================")
    w("# Conditional sources based on CONFIG_* variables")
    w("# (from OBJS-$(CONFIG_*) in Makefile)")
    w("# ============================================================================")
    w()
    
    # Group by category
    filters = OrderedDict()
    subsystems = OrderedDict()
    
    for k, v in all_objs.items():
        if k.endswith('_FILTER') or k.endswith('_INDEV') or k.endswith('_OUTDEV'):
            filters[k] = v
        else:
            subsystems[k] = v
    
    if subsystems:
        w("# --- Subsystems and helpers ---")
        for k, v in subsystems.items():
            w(format_config_block(k, v, "avfilter_sources"))
            w()
    
    w("# --- Filters ---")
    for k, v in filters.items():
        w(format_config_block(k, v, "avfilter_sources"))
        w()
    
    # ---- x86 architecture ----
    w("# ============================================================================")
    w("# x86 architecture-specific sources")
    w("# ============================================================================")
    w("if(ARCH_X86 AND ENABLE_ASM)")
    w()
    
    # x86 OBJS entries
    if 'OBJS' in x86_entries:
        w("    # x86 C sources (conditional)")
        for k, v in x86_entries['OBJS'].items():
            w(format_config_block(k, v, "avfilter_sources", indent="    "))
            w()
    
    # x86 X86ASM-OBJS entries
    if 'X86ASM-OBJS' in x86_entries:
        w("    if(HAVE_X86ASM)")
        w("        # x86 ASM sources (conditional, require NASM/YASM)")
        for k, v in x86_entries['X86ASM-OBJS'].items():
            files = []
            for f in v:
                if f.endswith('.c'):
                    basename = os.path.basename(f)
                    if basename.endswith('_init.c') or basename in ('vf_noise.c', 'vf_spp.c'):
                        files.append(f)
                    else:
                        asm_path = f[:-2] + '.asm'
                        if os.path.exists(os.path.join(lib_dir, asm_path)):
                            files.append(asm_path)
                        else:
                            files.append(f)
                else:
                    files.append(f)
            w(format_config_block(k, files, "avfilter_sources", indent="        "))
            w()
        w("    endif()")
    
    w("endif()")
    w()
    
    # ---- AArch64 architecture ----
    w("# ============================================================================")
    w("# AArch64 architecture-specific sources")
    w("# ============================================================================")
    w("if(ARCH_AARCH64 AND ENABLE_ASM)")
    w()
    
    if 'OBJS' in aarch64_entries:
        w("    # AArch64 C sources (conditional)")
        for k, v in aarch64_entries['OBJS'].items():
            w(format_config_block(k, v, "avfilter_sources", indent="    "))
            w()
    
    if 'NEON-OBJS' in aarch64_entries:
        w("    if(HAVE_NEON)")
        w("        # NEON sources (conditional)")
        for k, v in aarch64_entries['NEON-OBJS'].items():
            files = []
            for f in v:
                if f.endswith('.c'):
                    s_path = f[:-2] + '.S'
                    if os.path.exists(os.path.join(lib_dir, s_path)):
                        files.append(s_path)
                    else:
                        files.append(f)
                else:
                    files.append(f)
            w(format_config_block(k, files, "avfilter_sources", indent="        "))
            w()
        w("    endif()")
        w()
    
    w("endif()")
    w()
    
    # ---- Remove duplicates and filter ----
    w("# ============================================================================")
    w("# Remove duplicates")
    w("# ============================================================================")
    w("list(REMOVE_DUPLICATES avfilter_sources)")
    w()
    w("# Filter out source files that don't exist")
    w('set(avfilter_sources_filtered "")')
    w("foreach(src IN LISTS avfilter_sources)")
    w('    if(IS_ABSOLUTE "${src}")')
    w("        list(APPEND avfilter_sources_filtered \"${src}\")")
    w('    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")')
    w("        list(APPEND avfilter_sources_filtered \"${src}\")")
    w("    else()")
    w('        message(STATUS "avfilter: skipping missing source file: ${src}")')
    w("    endif()")
    w("endforeach()")
    w("set(avfilter_sources ${avfilter_sources_filtered})")
    w()
    
    # ---- Generate filter_list.c and allfilters.c ----
    # This section scans source files for FFFilter symbols
    w("# ============================================================================")
    w("# Generate filter_list.c and allfilters.c")
    w("# Scan compiled source files for FFFilter symbol definitions")
    w("# ============================================================================")
    w()
    w('set(avfilter_filter_symbols "")')
    w()
    w("# Scan each source file for FFFilter definitions")
    w("foreach(src IN LISTS avfilter_sources)")
    w('    if(IS_ABSOLUTE "${src}")')
    w('        set(_src_abs "${src}")')
    w("    else()")
    w('        set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${src}")')
    w("    endif()")
    w('    if(NOT EXISTS "${_src_abs}")')
    w("        continue()")
    w("    endif()")
    w('    file(STRINGS "${_src_abs}" _filter_lines REGEX "^const FFFilter ff_[a-zA-Z0-9_]+ =")')
    w("    foreach(_fline IN LISTS _filter_lines)")
    w('        string(REGEX MATCH "ff_[a-zA-Z0-9_]+" _fsym "${_fline}")')
    w("        if(_fsym)")
    w('            list(APPEND avfilter_filter_symbols "${_fsym}")')
    w("        endif()")
    w("    endforeach()")
    w("endforeach()")
    w()
    
    # Macro-defined filters
    w("# Filters defined via macros (not detectable by simple file scan)")
    w("# af_biquads.c: ff_af_equalizer, ff_af_bass, ff_af_lowshelf, etc.")
    w('if(CONFIG_EQUALIZER_FILTER OR CONFIG_BASS_FILTER OR CONFIG_LOWSHELF_FILTER OR')
    w('   CONFIG_TREBLE_FILTER OR CONFIG_HIGHSHELF_FILTER OR CONFIG_TILTSHELF_FILTER OR')
    w('   CONFIG_BANDPASS_FILTER OR CONFIG_BANDREJECT_FILTER OR CONFIG_LOWPASS_FILTER OR')
    w('   CONFIG_HIGHPASS_FILTER OR CONFIG_ALLPASS_FILTER OR CONFIG_BIQUAD_FILTER)')
    w("    list(APPEND avfilter_filter_symbols")
    w("        ff_af_equalizer ff_af_bass ff_af_lowshelf ff_af_treble")
    w("        ff_af_highshelf ff_af_tiltshelf ff_af_bandpass ff_af_bandreject")
    w("        ff_af_lowpass ff_af_highpass ff_af_allpass ff_af_biquad")
    w("    )")
    w("endif()")
    w()
    w("# vf_neighbor.c: ff_vf_erosion, ff_vf_dilation, ff_vf_deflate, ff_vf_inflate")
    w("if(CONFIG_EROSION_FILTER OR CONFIG_DILATION_FILTER OR CONFIG_DEFLATE_FILTER OR CONFIG_INFLATE_FILTER)")
    w("    list(APPEND avfilter_filter_symbols")
    w("        ff_vf_erosion ff_vf_dilation ff_vf_deflate ff_vf_inflate")
    w("    )")
    w("endif()")
    w()
    w("# vf_lut.c: ff_vf_lut, ff_vf_lutyuv, ff_vf_lutrgb")
    w("if(CONFIG_LUT_FILTER OR CONFIG_LUTYUV_FILTER OR CONFIG_LUTRGB_FILTER)")
    w("    list(APPEND avfilter_filter_symbols")
    w("        ff_vf_lut ff_vf_lutyuv ff_vf_lutrgb")
    w("    )")
    w("endif()")
    w()
    
    # Buffer filters
    w("# Special buffer/abuffer filters (always needed)")
    w("set(avfilter_buffer_symbols")
    w("    ff_asrc_abuffer")
    w("    ff_vsrc_buffer")
    w("    ff_asink_abuffer")
    w("    ff_vsink_buffer")
    w(")")
    w()
    w("list(REMOVE_DUPLICATES avfilter_filter_symbols)")
    w()
    
    # Generate filter_list.c
    w("# Generate filter_list.c")
    w('set(FILTER_LIST_CONTENT "static const FFFilter * const filter_list[] = {\\n")')
    w("foreach(sym IN LISTS avfilter_filter_symbols)")
    w('    string(APPEND FILTER_LIST_CONTENT "    &${sym},\\n")')
    w("endforeach()")
    w("foreach(sym IN LISTS avfilter_buffer_symbols)")
    w('    string(APPEND FILTER_LIST_CONTENT "    &${sym},\\n")')
    w("endforeach()")
    w('string(APPEND FILTER_LIST_CONTENT "    NULL,\\n};\\n")')
    w('file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/filter_list.c" "${FILTER_LIST_CONTENT}")')
    w()
    
    # Generate allfilters.c
    w("# Generate allfilters.c")
    w(r'''set(ALLFILTERS_CONTENT
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

file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c" "${ALLFILTERS_CONTENT}")''')
    w()
    w("# Use the generated allfilters.c instead of the source one")
    w('list(APPEND avfilter_sources "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c")')
    w()
    
    # ---- Build target ----
    w("# ============================================================================")
    w("# Create the library")
    w("# ============================================================================")
    w("add_library(avfilter STATIC ${avfilter_sources})")
    w()
    w("# Include directories")
    w("target_include_directories(avfilter")
    w("    PUBLIC")
    w("        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>")
    w("    PRIVATE")
    w("        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/libavfilter>")
    w(")")
    w()
    w("# Add source directory as NASM include path for each .asm file")
    w("if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)")
    w("    nasm_add_source_dir_includes(avfilter)")
    w("endif()")
    w()
    w("# Link dependencies")
    w("target_link_libraries(avfilter")
    w("    PRIVATE")
    w("        swscale")
    w("        avformat")
    w("        avcodec")
    w("        swresample")
    w("        avutil")
    w("        Threads::Threads")
    w(")")
    w()
    w("""# Link FriBidi if available (needed for vf_drawtext bidirectional text)
if(CONFIG_LIBFRIBIDI AND LIBFRIBIDI_LIBRARIES)
    if(LIBFRIBIDI_LIBRARY_DIRS)
        target_link_directories(avfilter PUBLIC ${LIBFRIBIDI_LIBRARY_DIRS})
    endif()
    target_link_libraries(avfilter PRIVATE ${LIBFRIBIDI_LIBRARIES})
    if(LIBFRIBIDI_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${LIBFRIBIDI_INCLUDE_DIRS})
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
else()
    message(STATUS "avfilter: FreeType2 not found, excluding vf_drawtext.c")
    get_target_property(_avflt_srcs avfilter SOURCES)
    list(FILTER _avflt_srcs EXCLUDE REGEX "vf_drawtext\\.c$")
    set_target_properties(avfilter PROPERTIES SOURCES "${_avflt_srcs}")

    set(_drawtext_stub "${CMAKE_CURRENT_BINARY_DIR}/vf_drawtext_stub.c")
    file(WRITE "${_drawtext_stub}" "
/* Auto-generated stub: ff_vf_drawtext when FreeType2 is not available */
#include \\"avfilter.h\\"
#include \\"filters.h\\"

const AVFilter ff_vf_drawtext = {
    .name        = \\"drawtext\\",
    .description = \\"Draw text on the video frame (stub, FreeType2 not available)\\",
};
")
    target_sources(avfilter PRIVATE "${_drawtext_stub}")
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
if(CONFIG_LIBFONTCONFIG AND LIBFONTCONFIG_LIBRARIES)
    target_link_libraries(avfilter PRIVATE ${LIBFONTCONFIG_LIBRARIES})
    if(LIBFONTCONFIG_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${LIBFONTCONFIG_INCLUDE_DIRS})
    endif()
    if(LIBFONTCONFIG_LIBRARY_DIRS)
        target_link_directories(avfilter PRIVATE ${LIBFONTCONFIG_LIBRARY_DIRS})
    endif()
endif()

# Link VAAPI if available (needed for vaapi_vpp.c and VAAPI filters)
if(CONFIG_VAAPI AND VAAPI_LIBRARIES)
    target_link_libraries(avfilter PRIVATE ${VAAPI_LIBRARIES})
    if(VAAPI_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${VAAPI_INCLUDE_DIRS})
    endif()
endif()""")
    w()
    w("# Compiler definitions")
    w("target_compile_definitions(avfilter PRIVATE")
    w("    HAVE_AV_CONFIG_H")
    w("    BUILDING_avfilter")
    w(")")
    w()
    w("# Position independent code for shared builds")
    w("set_pic_if_needed(avfilter)")
    w()
    w("# Set output name")
    w("set_target_properties(avfilter PROPERTIES")
    w("    OUTPUT_NAME avfilter")
    w("    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w("    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w(")")
    w()
    w('list(LENGTH avfilter_filter_symbols _n_filters)')
    w('message(STATUS "libavfilter configured with ${_n_filters} filters")')
    
    print('\n'.join(out))


if __name__ == '__main__':
    main()
