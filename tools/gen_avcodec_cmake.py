#!/usr/bin/env python3
"""
Generate libavcodec/CMakeLists.txt from Makefiles with explicit source lists.

Replaces all file(GLOB ...) patterns with explicit source file lists derived
from the authoritative Makefile definitions.

Usage:
    python3 tools/gen_avcodec_cmake.py > libavcodec/CMakeLists.txt
"""

import re
import os
import sys
from collections import OrderedDict


def parse_makefile_config_entries(makefile_path):
    """Parse all OBJS-$(CONFIG_XXX), X86ASM-OBJS-$(CONFIG_XXX), NEON-OBJS-$(CONFIG_XXX), etc.
    
    Returns dict of: prefix -> OrderedDict(CONFIG_NAME -> [files])
    where prefix is 'OBJS', 'X86ASM-OBJS', 'NEON-OBJS', 'ARMV8-OBJS', 'SME2-OBJS'
    """
    with open(makefile_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    # prefix -> OrderedDict(config -> [files])
    result = {}
    
    current_prefix = None
    current_config = None
    current_files = []

    for line in lines:
        # Match various OBJS patterns:
        # OBJS-$(CONFIG_XXX) += ...
        # X86ASM-OBJS-$(CONFIG_XXX) += ...
        # NEON-OBJS-$(CONFIG_XXX) += ...
        # ARMV8-OBJS-$(CONFIG_XXX) += ...
        # SME2-OBJS-$(CONFIG_XXX) += ...
        # STLIBOBJS-$(CONFIG_XXX) += ...
        m = re.match(r'^((?:X86ASM-|NEON-|ARMV8-|SME2-|STLIBOBJS-)?OBJS)-\$\(CONFIG_([A-Z0-9_]+)\)\s*\+=\s*(.*)', line)
        if m:
            # Save previous entry
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
                elif token.endswith('.S'):
                    current_files.append(token)

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
                # End of entry
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
                elif token.endswith('.S'):
                    current_files.append(token)

            if not cont:
                if current_prefix not in result:
                    result[current_prefix] = OrderedDict()
                if current_config not in result[current_prefix]:
                    result[current_prefix][current_config] = []
                result[current_prefix][current_config].extend(current_files)
                current_prefix = None
                current_config = None
                current_files = []

    # Save last entry
    if current_config is not None:
        if current_prefix not in result:
            result[current_prefix] = OrderedDict()
        if current_config not in result[current_prefix]:
            result[current_prefix][current_config] = []
        result[current_prefix][current_config].extend(current_files)

    return result


def parse_unconditional_objs(makefile_path):
    """Parse unconditional OBJS = ... and OBJS += ... entries."""
    with open(makefile_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    objs = []
    in_objs = False

    for line in lines:
        # Match OBJS = ... or OBJS += ... (not OBJS-$(CONFIG_...))
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
    """Remove duplicates while preserving order."""
    seen = set()
    result = []
    for item in lst:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def format_source_list(files, varname, indent="    "):
    """Format a list of files as CMake list(APPEND ...) statements."""
    lines = []
    for f in dedup_preserve_order(files):
        lines.append(f"{indent}list(APPEND {varname} {f})")
    return '\n'.join(lines)


def format_config_block(config_name, files, varname, indent=""):
    """Format a CONFIG_* conditional block."""
    unique_files = dedup_preserve_order(files)
    lines = [f"{indent}if(CONFIG_{config_name})"]
    for f in unique_files:
        lines.append(f"{indent}    list(APPEND {varname} {f})")
    lines.append(f"{indent}endif()")
    return '\n'.join(lines)


def main():
    src_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    lib_dir = os.path.join(src_root, 'libavcodec')
    
    # Parse all Makefiles
    main_mf = os.path.join(lib_dir, 'Makefile')
    main_entries = parse_makefile_config_entries(main_mf)
    main_objs = parse_unconditional_objs(main_mf)
    
    # Subdirectory Makefiles (these contribute to the main OBJS)
    subdir_makefiles = ['aac', 'hevc', 'opus', 'vvc', 'bsf']
    subdir_entries = {}
    for subdir in subdir_makefiles:
        mf = os.path.join(lib_dir, subdir, 'Makefile')
        if os.path.exists(mf):
            subdir_entries[subdir] = parse_makefile_config_entries(mf)
    
    # Architecture-specific Makefiles
    x86_mf = os.path.join(lib_dir, 'x86', 'Makefile')
    x86_entries = parse_makefile_config_entries(x86_mf) if os.path.exists(x86_mf) else {}
    x86_objs = parse_unconditional_objs(x86_mf) if os.path.exists(x86_mf) else []
    
    x86_hevc_mf = os.path.join(lib_dir, 'x86', 'hevc', 'Makefile')
    x86_hevc_entries = parse_makefile_config_entries(x86_hevc_mf) if os.path.exists(x86_hevc_mf) else {}
    
    x86_vvc_mf = os.path.join(lib_dir, 'x86', 'vvc', 'Makefile')
    x86_vvc_entries = parse_makefile_config_entries(x86_vvc_mf) if os.path.exists(x86_vvc_mf) else {}
    
    aarch64_mf = os.path.join(lib_dir, 'aarch64', 'Makefile')
    aarch64_entries = parse_makefile_config_entries(aarch64_mf) if os.path.exists(aarch64_mf) else {}
    
    aarch64_vvc_mf = os.path.join(lib_dir, 'aarch64', 'vvc', 'Makefile')
    aarch64_vvc_entries = parse_makefile_config_entries(aarch64_vvc_mf) if os.path.exists(aarch64_vvc_mf) else {}
    
    # Tablegen files (explicit list)
    tablegen_files = []
    for f in sorted(os.listdir(lib_dir)):
        if 'tablegen' in f and f.endswith('.c') and f != 'cbrt_tablegen_common.c':
            tablegen_files.append(f)
    
    # ========================================================================
    # Generate CMakeLists.txt
    # ========================================================================
    
    out = []
    
    def w(s=""):
        out.append(s)
    
    w("# libavcodec CMakeLists.txt")
    w("# Generated from libavcodec/Makefile by tools/gen_avcodec_cmake.py")
    w("# All source files are listed explicitly (no file(GLOB) usage).")
    w()
    
    # ---- Core sources ----
    w("# ============================================================================")
    w("# Core sources (unconditional, from OBJS = in Makefile)")
    w("# ============================================================================")
    w("set(avcodec_sources")
    # Note: allcodecs.c is replaced by generated allcodecs_generated.c
    for f in main_objs:
        if f == 'allcodecs.c':
            w(f"    # allcodecs.c is replaced by generated allcodecs_generated.c (see below)")
            continue
        w(f"    {f}")
    w(")")
    w()
    
    # ---- Subsystem sources (CONFIG_* from main Makefile) ----
    w("# ============================================================================")
    w("# Conditional sources based on CONFIG_* variables")
    w("# (from OBJS-$(CONFIG_*) in Makefile and subdirectory Makefiles)")
    w("# ============================================================================")
    w()
    
    # Merge main OBJS entries with subdirectory entries
    all_objs_entries = OrderedDict()
    if 'OBJS' in main_entries:
        for k, v in main_entries['OBJS'].items():
            if k not in all_objs_entries:
                all_objs_entries[k] = []
            all_objs_entries[k].extend(v)
    
    for subdir, entries in subdir_entries.items():
        if 'OBJS' in entries:
            for k, v in entries['OBJS'].items():
                if k not in all_objs_entries:
                    all_objs_entries[k] = []
                all_objs_entries[k].extend(v)
    
    # Group by category for readability
    subsystems = OrderedDict()
    decoders = OrderedDict()
    encoders = OrderedDict()
    parsers = OrderedDict()
    hwaccels = OrderedDict()
    bsfs = OrderedDict()
    others = OrderedDict()
    
    for k, v in all_objs_entries.items():
        if k.endswith('_DECODER'):
            decoders[k] = v
        elif k.endswith('_ENCODER'):
            encoders[k] = v
        elif k.endswith('_PARSER'):
            parsers[k] = v
        elif k.endswith('_HWACCEL'):
            hwaccels[k] = v
        elif k.endswith('_BSF'):
            bsfs[k] = v
        elif any(k.endswith(s) for s in ['DSP', 'TABLES', 'PARSE', 'CHROMA', 'PRED', 'QPEL',
                                          'CABAC', 'CBS', 'GOLOMB', 'HUFFMAN', 'LPC', 'LSP',
                                          'LZF', 'RANGECODER', 'SINEWIN', 'STARTCODE',
                                          'RESILIENCE', 'PROFILE', 'FREQS']):
            subsystems[k] = v
        elif not k.endswith('_DECODER') and not k.endswith('_ENCODER'):
            subsystems[k] = v
    
    # Print subsystems
    w("# --- Internal subsystems ---")
    for k, v in subsystems.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # Print decoders
    w("# ============================================================================")
    w("# Decoder sources (CONFIG_*_DECODER)")
    w("# ============================================================================")
    w()
    for k, v in decoders.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # Print encoders
    w("# ============================================================================")
    w("# Encoder sources (CONFIG_*_ENCODER)")
    w("# ============================================================================")
    w()
    for k, v in encoders.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # Print parsers
    w("# ============================================================================")
    w("# Parser sources (CONFIG_*_PARSER)")
    w("# ============================================================================")
    w()
    for k, v in parsers.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # Print HW accels
    w("# ============================================================================")
    w("# Hardware acceleration sources (CONFIG_*_HWACCEL)")
    w("# ============================================================================")
    w()
    for k, v in hwaccels.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # Print BSFs
    w("# ============================================================================")
    w("# Bitstream filter sources (CONFIG_*_BSF)")
    w("# ============================================================================")
    w()
    for k, v in bsfs.items():
        w(format_config_block(k, v, "avcodec_sources"))
        w()
    
    # ---- x86 architecture ----
    w("# ============================================================================")
    w("# x86 architecture-specific sources")
    w("# ============================================================================")
    w("if(ARCH_X86 AND ENABLE_ASM)")
    w()
    
    # Unconditional x86 sources
    if x86_objs:
        w("    # Unconditional x86 sources")
        for f in dedup_preserve_order(x86_objs):
            w(f"    list(APPEND avcodec_sources {f})")
        w()
    
    # x86 OBJS-$(CONFIG_*) entries (C files, always compiled on x86)
    if 'OBJS' in x86_entries:
        w("    # x86 C sources (conditional)")
        for k, v in x86_entries['OBJS'].items():
            w(format_config_block(k, v, "avcodec_sources", indent="    "))
            w()
    
    # x86 X86ASM-OBJS entries (need HAVE_X86ASM)
    all_x86asm = OrderedDict()
    if 'X86ASM-OBJS' in x86_entries:
        for k, v in x86_entries['X86ASM-OBJS'].items():
            if k not in all_x86asm:
                all_x86asm[k] = []
            all_x86asm[k].extend(v)
    
    # Merge x86/hevc and x86/vvc entries
    if 'X86ASM-OBJS' in x86_hevc_entries:
        for k, v in x86_hevc_entries['X86ASM-OBJS'].items():
            if k not in all_x86asm:
                all_x86asm[k] = []
            all_x86asm[k].extend(v)
    
    if 'X86ASM-OBJS' in x86_vvc_entries:
        for k, v in x86_vvc_entries['X86ASM-OBJS'].items():
            if k not in all_x86asm:
                all_x86asm[k] = []
            all_x86asm[k].extend(v)
    
    if all_x86asm:
        w("    if(HAVE_X86ASM)")
        w("        # x86 ASM sources (conditional, require NASM/YASM)")
        for k, v in all_x86asm.items():
            # Convert .c to proper extensions - x86asm .o files are actually .asm
            files = []
            for f in v:
                if f.endswith('.c'):
                    # Check if it's a .c init file or an .asm file
                    # Init files end with _init.c and are C; others are .asm
                    basename = os.path.basename(f)
                    if basename.endswith('_init.c') or basename in ('fdct.c', 'mpegvideo.c', 
                        'mpegvideoenc.c', 'mpegaudiodsp.c', 'snowdsp.c', 'cavsdsp.c',
                        'mpeg4videodsp.c', 'h264_cabac.c', 'h264_qpel.c',
                        'vc1dsp_mmx.c', 'mlpdsp_init.c', 'lpc_init.c',
                        'h2656dsp.c', 'dsp_init.c'):
                        files.append(f)
                    else:
                        # This is an .asm file referenced as .o in Makefile
                        asm_path = f[:-2] + '.asm'
                        if os.path.exists(os.path.join(lib_dir, asm_path)):
                            files.append(asm_path)
                        elif os.path.exists(os.path.join(lib_dir, f)):
                            files.append(f)
                        else:
                            # Try .S
                            s_path = f[:-2] + '.S'
                            if os.path.exists(os.path.join(lib_dir, s_path)):
                                files.append(s_path)
                            else:
                                files.append(f)  # Keep as-is
                else:
                    files.append(f)
            
            w(format_config_block(k, files, "avcodec_sources", indent="        "))
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
    
    # aarch64 OBJS entries (always compiled on aarch64)
    all_aarch64_objs = OrderedDict()
    if 'OBJS' in aarch64_entries:
        for k, v in aarch64_entries['OBJS'].items():
            if k not in all_aarch64_objs:
                all_aarch64_objs[k] = []
            all_aarch64_objs[k].extend(v)
    if 'OBJS' in aarch64_vvc_entries:
        for k, v in aarch64_vvc_entries['OBJS'].items():
            if k not in all_aarch64_objs:
                all_aarch64_objs[k] = []
            all_aarch64_objs[k].extend(v)
    
    if all_aarch64_objs:
        w("    # AArch64 C sources (conditional)")
        for k, v in all_aarch64_objs.items():
            w(format_config_block(k, v, "avcodec_sources", indent="    "))
            w()
    
    # ARMv8 entries
    all_armv8 = OrderedDict()
    if 'ARMV8-OBJS' in aarch64_entries:
        for k, v in aarch64_entries['ARMV8-OBJS'].items():
            if k not in all_armv8:
                all_armv8[k] = []
            all_armv8[k].extend(v)
    
    if all_armv8:
        w("    # ARMv8 sources")
        for k, v in all_armv8.items():
            # Convert .c to .S for assembly files
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
            w(format_config_block(k, files, "avcodec_sources", indent="    "))
            w()
    
    # NEON entries
    all_neon = OrderedDict()
    if 'NEON-OBJS' in aarch64_entries:
        for k, v in aarch64_entries['NEON-OBJS'].items():
            if k not in all_neon:
                all_neon[k] = []
            all_neon[k].extend(v)
    if 'NEON-OBJS' in aarch64_vvc_entries:
        for k, v in aarch64_vvc_entries['NEON-OBJS'].items():
            if k not in all_neon:
                all_neon[k] = []
            all_neon[k].extend(v)
    
    if all_neon:
        w("    if(HAVE_NEON)")
        w("        # NEON sources (conditional)")
        for k, v in all_neon.items():
            # Convert .c to .S for assembly files
            files = []
            for f in v:
                if f.endswith('.c'):
                    s_path = f[:-2] + '.S'
                    if os.path.exists(os.path.join(lib_dir, s_path)):
                        files.append(s_path)
                    elif os.path.exists(os.path.join(lib_dir, f)):
                        files.append(f)
                    else:
                        files.append(f)
                else:
                    files.append(f)
            w(format_config_block(k, files, "avcodec_sources", indent="        "))
            w()
        w("    endif()")
        w()
    
    # SME2 entries
    all_sme2 = OrderedDict()
    if 'SME2-OBJS' in aarch64_vvc_entries:
        for k, v in aarch64_vvc_entries['SME2-OBJS'].items():
            if k not in all_sme2:
                all_sme2[k] = []
            all_sme2[k].extend(v)
    
    if all_sme2:
        w("    if(HAVE_SME2)")
        w("        # SME2 sources (conditional)")
        for k, v in all_sme2.items():
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
            w(format_config_block(k, files, "avcodec_sources", indent="        "))
            w()
        w("    endif()")
        w()
    
    # Also add neon/ subdirectory C files (mpegvideo.c)
    neon_dir = os.path.join(lib_dir, 'neon')
    if os.path.isdir(neon_dir):
        neon_c_files = [f for f in sorted(os.listdir(neon_dir)) if f.endswith('.c')]
        if neon_c_files:
            w("    if(HAVE_NEON)")
            w("        # neon/ subdirectory C helper files")
            for f in neon_c_files:
                w(f"        list(APPEND avcodec_sources neon/{f})")
            w("    endif()")
            w()
    
    w("endif()")
    w()
    
    # ---- Remove duplicates ----
    w("# ============================================================================")
    w("# Remove duplicates")
    w("# ============================================================================")
    w("list(REMOVE_DUPLICATES avcodec_sources)")
    w()
    
    # ---- Filter missing files ----
    w("# ============================================================================")
    w("# Filter out source files that don't exist (some files may have been")
    w("# reorganized into subdirectories in newer FFmpeg versions)")
    w("# ============================================================================")
    w('set(avcodec_sources_filtered "")')
    w("foreach(src IN LISTS avcodec_sources)")
    w('    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")')
    w("        list(APPEND avcodec_sources_filtered \"${src}\")")
    w("    else()")
    w('        message(STATUS "avcodec: skipping missing source file: ${src}")')
    w("    endif()")
    w("endforeach()")
    w("set(avcodec_sources ${avcodec_sources_filtered})")
    w()
    
    # ---- Codec list generation (keep from original) ----
    # This section is complex and should be preserved from the original CMakeLists.txt
    w("# ============================================================================")
    w("# Generate custom codec_list.c and bsf_list.c based on actually compiled files")
    w("# Strategy: scan allcodecs.c for all extern declarations, then filter by")
    w("# checking which symbols are actually defined in compiled source files.")
    w("# This handles codecs defined via macros (like PCM codecs in pcm.c).")
    w("# ============================================================================")
    w()
    
    # Tablegen files (explicit list)
    w("# Tablegen files (generate lookup tables, not compiled into library)")
    w("set(avcodec_tablegen_files")
    for f in tablegen_files:
        w(f"    {f}")
    w(")")
    w()
    
    # Template files (explicit list from original)
    w("# Files that are #included as templates by other .c files - do NOT compile directly")
    w("set(avcodec_template_files")
    template_files = []
    for f in sorted(os.listdir(lib_dir)):
        if f.endswith('_template.c') or f in ('aacps.c', 'aacpsdata.c', 'ac3dec.c',
            'bsf_list.c', 'golomb_tab.c', 'xvmc.c'):
            template_files.append(f)
    for f in template_files:
        w(f"    {f}")
    w(")")
    w()
    
    # External lib files (explicit list)
    w("# Files requiring external libraries not available by default")
    w("set(avcodec_external_lib_files")
    # Collect from Makefile entries that reference external libs
    external_patterns = [
        'amf', 'audiotoolbox', 'videotoolbox', 'mediacodec', 'mf_utils', 'mfenc', 'mfdec',
        'nvenc', 'nvdec', 'cuvid', 'qsv', 'libx264', 'libx265', 'libvpx', 'libopus',
        'libmp3lame', 'libfdk', 'libaom', 'libsvtav1', 'libdav1d', 'libvorbis', 'libtheora',
        'libwebp', 'libopenh264', 'libgsm', 'libspeex', 'libopenjpeg', 'libcodec2',
        'libjxl', 'librav1e', 'vpl_', 'd3d11va', 'd3d12va', 'dxva2', 'vaapi', 'vdpau',
        'openal', 'opengl', 'sdl2', 'libdc1394', 'libavs3', 'libxavs', 'libkvazaar',
        'libvvenc', 'libvvdec', 'libuavs3d', 'libxeve', 'libxevd', 'libshine', 'libtwolame',
        'libvo_', 'libopencore', 'libwavpack', 'libcelt', 'fflcms2', 'lcevcdec', 'mmaldec',
        'omx', 'v4l2', 'vulkan', 'rkmpp', 'ffjni', 'oh',
    ]
    ext_files = set()
    for f in sorted(os.listdir(lib_dir)):
        if not f.endswith('.c'):
            continue
        for pat in external_patterns:
            if pat in f.lower():
                ext_files.add(f)
                break
    for f in sorted(ext_files):
        w(f"    {f}")
    w(")")
    w()
    
    # Print the rest of the codec list generation and build target setup
    # (This is kept from the original CMakeLists.txt)
    w("""# Combine all excluded files
# allcodecs.c is excluded because it references ALL codecs (including hardware-accelerated ones
# that are not compiled). It is replaced by the generated allcodecs_generated.c below.
set(avcodec_auto_excluded ${avcodec_template_files} ${avcodec_external_lib_files} ${avcodec_tablegen_files}
    allcodecs.c)

# Step 1: Collect all symbols declared in allcodecs.c
set(_all_codec_syms "")
set(_all_bsf_syms "")
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/allcodecs.c" _allcodecs_lines
    REGEX "^extern const (FFCodec|FFBitStreamFilter) ff_[a-zA-Z0-9_]+;")
foreach(_line IN LISTS _allcodecs_lines)
    if(_line MATCHES "extern const FFCodec (ff_[a-zA-Z0-9_]+);")
        list(APPEND _all_codec_syms "${CMAKE_MATCH_1}")
    elseif(_line MATCHES "extern const FFBitStreamFilter (ff_[a-zA-Z0-9_]+);")
        list(APPEND _all_bsf_syms "${CMAKE_MATCH_1}")
    endif()
endforeach()

# Step 2: Collect symbols from excluded files (these should NOT be in the list)
set(_excluded_codec_syms "")
set(_excluded_bsf_syms "")
foreach(_excl_name IN LISTS avcodec_auto_excluded)
    set(_excl_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_excl_name}")
    if(NOT EXISTS "${_excl_abs}")
        continue()
    endif()
    # Scan for direct definitions
    file(STRINGS "${_excl_abs}" _excl_lines
        REGEX "^(const FFCodec|const FFBitStreamFilter) ff_[a-zA-Z0-9_]+ =")
    foreach(_line IN LISTS _excl_lines)
        if(_line MATCHES "const FFCodec (ff_[a-zA-Z0-9_]+)")
            list(APPEND _excluded_codec_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const FFBitStreamFilter (ff_[a-zA-Z0-9_]+)")
            list(APPEND _excluded_bsf_syms "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endforeach()

# Step 3: Filter - keep only symbols NOT in excluded files
set(_codec_symbols ${_all_codec_syms})
set(_bsf_symbols ${_all_bsf_syms})
if(_excluded_codec_syms)
    list(REMOVE_ITEM _codec_symbols ${_excluded_codec_syms})
endif()
if(_excluded_bsf_syms)
    list(REMOVE_ITEM _bsf_symbols ${_excluded_bsf_syms})
endif()

list(REMOVE_DUPLICATES _codec_symbols)
list(REMOVE_DUPLICATES _bsf_symbols)

# Step 4: Verify symbols actually exist in compiled sources
set(_found_codec_syms "")
set(_found_bsf_syms "")

# Preprocess all avcodec_sources files and collect defined symbols
foreach(_src IN LISTS avcodec_sources)
    set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
    if(NOT EXISTS "${_src_abs}")
        continue()
    endif()
    
    # Use gcc -E to preprocess and see which symbols are actually defined
    execute_process(
        COMMAND ${CMAKE_C_COMPILER} -E -I${CMAKE_SOURCE_DIR} -I${CMAKE_BINARY_DIR}
                -I${CMAKE_CURRENT_SOURCE_DIR}
                -DHAVE_AV_CONFIG_H -include ${CMAKE_BINARY_DIR}/config.h
                "${_src_abs}"
        OUTPUT_VARIABLE _expanded
        ERROR_QUIET
        RESULT_VARIABLE _gcc_result
        TIMEOUT 30
    )
    
    if(_gcc_result EQUAL 0)
        # Scan preprocessed output for FFCodec/FFBitStreamFilter definitions
        string(REGEX MATCHALL "const FFCodec ff_[a-zA-Z0-9_]+" _codec_matches "${_expanded}")
        string(REGEX MATCHALL "const FFBitStreamFilter ff_[a-zA-Z0-9_]+" _bsf_matches "${_expanded}")
        
        foreach(_match IN LISTS _codec_matches)
            if(_match MATCHES "const FFCodec (ff_[a-zA-Z0-9_]+)")
                list(APPEND _found_codec_syms "${CMAKE_MATCH_1}")
            endif()
        endforeach()
        
        foreach(_match IN LISTS _bsf_matches)
            if(_match MATCHES "const FFBitStreamFilter (ff_[a-zA-Z0-9_]+)")
                list(APPEND _found_bsf_syms "${CMAKE_MATCH_1}")
            endif()
        endforeach()
    endif()
endforeach()

# Remove duplicates while preserving order
list(REMOVE_DUPLICATES _found_codec_syms)
list(REMOVE_DUPLICATES _found_bsf_syms)

# Final filter: only keep symbols that were found in preprocessed output
set(_verified_codec_syms "")
foreach(_sym IN LISTS _codec_symbols)
    if("${_sym}" IN_LIST _found_codec_syms)
        list(APPEND _verified_codec_syms "${_sym}")
    endif()
endforeach()
set(_codec_symbols ${_verified_codec_syms})

# For BSFs, do the same
set(_verified_bsf_syms "")
foreach(_sym IN LISTS _bsf_symbols)
    if("${_sym}" IN_LIST _found_bsf_syms)
    endif()
endforeach()
set(_bsf_symbols ${_verified_bsf_syms})
set(_codec_list_content "static const FFCodec * const codec_list[] = {\\n")
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _codec_list_content "    &${_sym},\\n")
endforeach()
string(APPEND _codec_list_content "    NULL\\n};\\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/codec_list.c" "${_codec_list_content}")

# Generate bsf_list.c
set(_bsf_list_content "static const FFBitStreamFilter * const bitstream_filters[] = {\\n")
foreach(_sym IN LISTS _bsf_symbols)
    string(APPEND _bsf_list_content "    &${_sym},\\n")
endforeach()
string(APPEND _bsf_list_content "    NULL\\n};\\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/bsf_list.c" "${_bsf_list_content}")

# Generate allcodecs_generated.c to replace allcodecs.c
set(_gen_allcodecs "/*\\n * Auto-generated by CMake. Do not edit.\\n * Replaces allcodecs.c with only the codecs actually compiled.\\n */\\n")
string(APPEND _gen_allcodecs "#include <stdint.h>\\n")
string(APPEND _gen_allcodecs "#include <string.h>\\n")
string(APPEND _gen_allcodecs "#include \\"config.h\\"\\n")
string(APPEND _gen_allcodecs "#include \\"libavutil/thread.h\\"\\n")
string(APPEND _gen_allcodecs "#include \\"avcodec.h\\"\\n")
string(APPEND _gen_allcodecs "#include \\"codec.h\\"\\n")
string(APPEND _gen_allcodecs "#include \\"codec_id.h\\"\\n")
string(APPEND _gen_allcodecs "#include \\"codec_internal.h\\"\\n")
string(APPEND _gen_allcodecs "\\n")
# extern declarations for codecs
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _gen_allcodecs "extern const FFCodec ${_sym};\\n")
endforeach()
string(APPEND _gen_allcodecs "\\n")
# inline codec_list[] array
string(APPEND _gen_allcodecs "const FFCodec * codec_list[] = {\\n")
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _gen_allcodecs "    (FFCodec *)&${_sym},\\n")
endforeach()
string(APPEND _gen_allcodecs "    NULL\\n};\\n")
string(APPEND _gen_allcodecs "\\n")
# Copy the runtime functions from allcodecs.c
string(APPEND _gen_allcodecs "
static AVOnce av_codec_static_init = AV_ONCE_INIT;
static void av_codec_init_static(void)
{
    int dummy;
    for (int i = 0; codec_list[i]; i++) {
        const FFCodec *codec = codec_list[i];
        if (!codec->get_supported_config)
            continue;
FF_DISABLE_DEPRECATION_WARNINGS
        switch (codec->p.type) {
        case AVMEDIA_TYPE_VIDEO:
            if (!codec->p.pix_fmts)
                codec->get_supported_config(NULL, &codec->p,
                                            AV_CODEC_CONFIG_PIX_FORMAT, 0,
                                            (const void **) &codec->p.pix_fmts,
                                            &dummy);
            break;
        case AVMEDIA_TYPE_AUDIO:
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_SAMPLE_FORMAT, 0,
                                        (const void **) &codec->p.sample_fmts,
                                        &dummy);
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_SAMPLE_RATE, 0,
                                        (const void **) &codec->p.supported_samplerates,
                                        &dummy);
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_CHANNEL_LAYOUT, 0,
                                        (const void **) &codec->p.ch_layouts,
                                        &dummy);
            break;
        default:
            break;
        }
FF_ENABLE_DEPRECATION_WARNINGS
    }
}

const AVCodec *av_codec_iterate(void **opaque)
{
    uintptr_t i = (uintptr_t)*opaque;
    const FFCodec *c = codec_list[i];
    ff_thread_once(&av_codec_static_init, av_codec_init_static);
    if (c) {
        *opaque = (void*)(i + 1);
        return &c->p;
    }
    return NULL;
}

static enum AVCodecID remap_deprecated_codec_id(enum AVCodecID id)
{
    switch(id){
        default: return id;
    }
}

static const AVCodec *find_codec(enum AVCodecID id, int (*x)(const AVCodec *))
{
    const AVCodec *p, *experimental = NULL;
    void *i = 0;
    id = remap_deprecated_codec_id(id);
    while ((p = av_codec_iterate(&i))) {
        if (!x(p))
            continue;
        if (p->id == id) {
            if (p->capabilities & AV_CODEC_CAP_EXPERIMENTAL && !experimental) {
                experimental = p;
            } else
                return p;
        }
    }
    return experimental;
}

const AVCodec *avcodec_find_encoder(enum AVCodecID id)
{
    return find_codec(id, ff_codec_is_encoder);
}

const AVCodec *avcodec_find_decoder(enum AVCodecID id)
{
    return find_codec(id, ff_codec_is_decoder);
}

static const AVCodec *find_codec_by_name(const char *name, int (*x)(const AVCodec *))
{
    void *i = 0;
    const AVCodec *p;
    if (!name)
        return NULL;
    while ((p = av_codec_iterate(&i))) {
        if (!x(p))
            continue;
        if (strcmp(name, p->name) == 0)
            return p;
    }
    return NULL;
}

const AVCodec *avcodec_find_encoder_by_name(const char *name)
{
    return find_codec_by_name(name, ff_codec_is_encoder);
}

const AVCodec *avcodec_find_decoder_by_name(const char *name)
{
    return find_codec_by_name(name, ff_codec_is_decoder);
}
")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/allcodecs_generated.c" "${_gen_allcodecs}")

list(LENGTH _codec_symbols _n_codecs)
list(LENGTH _bsf_symbols _n_bsfs)
message(STATUS "libavcodec: generated allcodecs_generated.c with ${_n_codecs} codecs")
message(STATUS "libavcodec: generated bsf_list.c with ${_n_bsfs} BSFs")""")
    w()
    
    # ---- Build target ----
    w("# ============================================================================")
    w("# Build target")
    w("# ============================================================================")
    w()
    w('# Add generated directory to include path')
    w('include_directories("${CMAKE_BINARY_DIR}")')
    w('add_library(avcodec STATIC ${avcodec_sources}')
    w('    "${CMAKE_BINARY_DIR}/libavcodec/allcodecs_generated.c")')
    w()
    w("# Include directories")
    w("target_include_directories(avcodec")
    w("    PUBLIC")
    w("        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>")
    w("        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>")
    w(")")
    w()
    w("# Add source directory as NASM include path for each .asm file")
    w("if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)")
    w("    nasm_add_source_dir_includes(avcodec)")
    w("endif()")
    w()
    w("# Link dependencies")
    w("target_link_libraries(avcodec")
    w("    PRIVATE")
    w("        swresample")
    w("        avutil")
    w("        Threads::Threads")
    w(")")
    w()
    w("# Link optional external libraries (standard CMake packages)")
    w("if(CONFIG_ZLIB AND ZLIB_FOUND)")
    w("    target_link_libraries(avcodec PRIVATE ZLIB::ZLIB)")
    w("endif()")
    w("if(CONFIG_LZMA AND LIBLZMA_FOUND)")
    w("    target_link_libraries(avcodec PRIVATE LibLZMA::LibLZMA)")
    w("endif()")
    w("if(CONFIG_BZLIB AND BZIP2_FOUND)")
    w("    target_link_libraries(avcodec PRIVATE BZip2::BZip2)")
    w("endif()")
    w()
    w("# External library include/link are handled centrally in cmake/FFmpegApplyExternalLibs.cmake")
    w()
    w("# Apple frameworks (macOS/iOS)")
    w("if(APPLE)")
    w("    if(CONFIG_AUDIOTOOLBOX)")
    w('        target_link_libraries(avcodec PRIVATE "-framework AudioToolbox" "-framework CoreFoundation")')
    w("    endif()")
    w("    if(CONFIG_VIDEOTOOLBOX)")
    w("        target_link_libraries(avcodec PRIVATE")
    w('            "-framework VideoToolbox"')
    w('            "-framework CoreVideo"')
    w('            "-framework CoreMedia"')
    w('            "-framework CoreFoundation"')
    w("        )")
    w("    endif()")
    w("endif()")
    w()
    w("# Compiler definitions")
    w("target_compile_definitions(avcodec PRIVATE")
    w("    HAVE_AV_CONFIG_H")
    w("    BUILDING_avcodec")
    w(")")
    w()
    w("# Position independent code for shared builds")
    w("set_pic_if_needed(avcodec)")
    w()
    w("# Set output name")
    w("set_target_properties(avcodec PROPERTIES")
    w("    OUTPUT_NAME avcodec")
    w("    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w("    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib")
    w(")")
    w()
    w('message(STATUS "libavcodec configured")')
    
    print('\n'.join(out))


if __name__ == '__main__':
    main()
