# FFmpeg Defaults Module
# Sets default values for all CONFIG_ and HAVE_ variables used in config.h.in
# This ensures all placeholders are defined even if not explicitly set

message(STATUS "Setting default configuration values...")

# ============================================================================
# Architecture defaults
# ============================================================================
# NOTE: Architecture variables (ARCH_*) are set by FFmpegArch.cmake
# Do NOT override them here - FFmpegArch.cmake handles:
# - ENABLE_ASM=OFF: sets all ARCH_* to 0
# - ENABLE_ASM=ON: detects architecture based on CMAKE_SYSTEM_PROCESSOR
# ============================================================================

# Ensure ARCH_* variables have defaults (but don't override if already set)
foreach(arch_var AARCH64 ARM IA64 LOONGARCH LOONGARCH32 LOONGARCH64 M68K MIPS MIPS64
                 PARISC PPC PPC64 RISCV S390 SPARC SPARC64 TILEGX TILEPRO WASM X86 X86_32 X86_64)
    if(NOT DEFINED ARCH_${arch_var})
        set(ARCH_${arch_var} 0)
    endif()
endforeach()

# ============================================================================
# Default AS_ARCH_LEVEL for ARM (can be overridden)
# ============================================================================
set(AS_ARCH_LEVEL "armv8-a")

# ============================================================================
# Set all undefined variables from config.h.in to 0
# ============================================================================
file(STRINGS "${CMAKE_SOURCE_DIR}/cmake/config.h.in" CONFIG_LINES)

foreach(LINE IN LISTS CONFIG_LINES)
    # Match lines like: #define CONFIG_FOO @CONFIG_FOO@
    # Extract the variable name from @VAR@
    if(LINE MATCHES "#define[ \t]+[A-Z0-9_]+[ \t]+@([A-Z0-9_]+)@")
        set(VAR_NAME "${CMAKE_MATCH_1}")
        
        # Set default to 0 if not already defined (do NOT use cache - let detection override)
        if(NOT DEFINED ${VAR_NAME})
            set(${VAR_NAME} 0)
        endif()
    endif()
endforeach()

# ============================================================================
# License configuration
# ============================================================================
# These mirror configure's --enable-gpl, --enable-version3 options
# Components with deps="gpl" or "lgpl_gpl" check these flags
if(ENABLE_GPL)
    set(CONFIG_GPL 1)
    set(gpl 1)
    set(lgpl_gpl 1)  # lgpl_gpl is satisfied when GPL is enabled
else()
    set(CONFIG_GPL 0)
    set(gpl 0)
    set(lgpl_gpl 0)
endif()

if(ENABLE_VERSION3)
    set(CONFIG_GPLV3 1)
    set(CONFIG_LGPLV3 1)
else()
    set(CONFIG_GPLV3 0)
    set(CONFIG_LGPLV3 0)
endif()

# ============================================================================
# Override defaults for essential options
# ============================================================================
set(CONFIG_AVUTIL 1)
set(CONFIG_AVCODEC 1)
set(CONFIG_AVFORMAT 1)
set(CONFIG_AVFILTER 1)
set(CONFIG_AVDEVICE 1)
set(CONFIG_SWSCALE 1)
set(CONFIG_SWRESAMPLE 1)

# Essential codecs/utilities
set(CONFIG_DECODERS 1)
set(CONFIG_ENCODERS 1)
set(CONFIG_MUXERS 1)
set(CONFIG_DEMUXERS 1)
set(CONFIG_PROTOCOLS 1)
set(CONFIG_FILTERS 1)
set(CONFIG_BSFS 1)
set(CONFIG_PARSERS 1)
set(CONFIG_INDEVS 1)
set(CONFIG_OUTDEVS 1)

# ============================================================================
# Platform-specific defaults
# ============================================================================
# NOTE: Most platform-specific configs are auto-detected in other modules:
# - APPKIT/AVFOUNDATION/COREIMAGE: FFmpegExternalLibs.cmake (macOS frameworks)
# - VIDEOTOOLBOX/AUDIOTOOLBOX: FFmpegExternalLibs.cmake (macOS frameworks)
# - VAAPI/VDPAU/ALSA: FFmpegLibraryDetection.cmake (Linux)
# Do NOT set defaults here - let detection logic determine availability
# ============================================================================

# Only set Windows-specific hardware acceleration defaults
# (Full detection would require checking ID3D11VideoDecoder types)
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(CONFIG_D3D11VA 1)
    set(CONFIG_DXVA2 1)
    set(HAVE_LIBC_MSVCRT 1)
else()
    set(CONFIG_D3D11VA 0)
    set(CONFIG_DXVA2 0)
    set(HAVE_LIBC_MSVCRT 0)
endif()

message(STATUS "Default configuration values set")
