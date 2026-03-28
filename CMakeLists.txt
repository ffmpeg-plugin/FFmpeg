cmake_minimum_required(VERSION 3.20)
project(FFmpeg VERSION 8.1 LANGUAGES C CXX ASM)

# =============================================================================
# Project Configuration
# =============================================================================

set(FFMPEG_CONFIGURATION "CMake build")

# =============================================================================
# Build Options
# =============================================================================

# License options
option(ENABLE_GPL       "Enable GPL licensed code"      OFF)
option(ENABLE_VERSION3  "Enable (L)GPLv3 code"          OFF)
option(ENABLE_NONFREE   "Enable nonfree code"           OFF)

# Build type options
option(ENABLE_SHARED    "Build shared libraries"        OFF)
option(ENABLE_STATIC    "Build static libraries"        ON)
option(ENABLE_DEBUG     "Enable debug symbols"          ON)
option(ENABLE_OPTIMIZATIONS "Enable compiler optimizations" ON)

# Library toggles
option(ENABLE_AVDEVICE   "Build libavdevice"   ON)
option(ENABLE_AVCODEC    "Build libavcodec"    ON)
option(ENABLE_AVFORMAT   "Build libavformat"   ON)
option(ENABLE_AVFILTER   "Build libavfilter"   ON)
option(ENABLE_SWSCALE    "Build libswscale"    ON)
option(ENABLE_SWRESAMPLE "Build libswresample" ON)

# Tool toggles
option(ENABLE_FFMPEG  "Build ffmpeg executable"  ON)
option(ENABLE_FFPLAY  "Build ffplay executable"  ON)
option(ENABLE_FFPROBE "Build ffprobe executable" ON)

# Assembly options
option(ENABLE_ASM "Enable assembly optimizations" ON)

# =============================================================================
# CMake Module Path
# =============================================================================

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# =============================================================================
# Platform and Architecture Detection
# =============================================================================

include(FFmpegArch)

# =============================================================================
# Feature Detection
# =============================================================================

include(FFmpegFeatureDetect)

# =============================================================================
# External Libraries
# =============================================================================

# Include defaults first (sets gpl/lgpl_gpl variables for license checks)
include(FFmpegDefaults)

include(FFmpegExternalLibs)

# =============================================================================
# RPATH Configuration (for build tree)
# =============================================================================

# On macOS/Linux, set rpath so executables can find dynamic libraries
# without needing to install them first
if(APPLE)
    # macOS: use @loader_path and homebrew paths
    set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)
    list(APPEND CMAKE_BUILD_RPATH
        "/opt/homebrew/lib"
        "/usr/local/lib"
    )
    set(CMAKE_INSTALL_RPATH "@executable_path/../lib")
elseif(UNIX)
    set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
endif()

# =============================================================================
# Find Required Packages
# =============================================================================

# Threads
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

# Set thread-related config variables
if(CMAKE_USE_PTHREADS_INIT)
    set(HAVE_PTHREADS 1)
    set(HAVE_THREADS 1)
elseif(CMAKE_USE_WIN32_THREADS_INIT)
    set(HAVE_PTHREADS 0)
    set(HAVE_W32THREADS 1)
    set(HAVE_THREADS 1)
else()
    set(HAVE_PTHREADS 0)
    set(HAVE_THREADS 0)
endif()
set(HAVE_OS2THREADS 0)

# =============================================================================
# Compiler Flags
# =============================================================================

include(FFmpegCompilerFlags)

# =============================================================================
# Utilities
# =============================================================================

include(FFmpegUtils)

# =============================================================================
# L2: Component Dependency Resolution (definitions loaded here, resolution deferred)
# =============================================================================

# Load component dependency definitions (from configure _deps/_select)
include(FFmpegComponentDeps)

# Load dependency resolver (defines ffmpeg_resolve_all_dependencies function)
include(FFmpegDependencyResolver)

# NOTE: ffmpeg_resolve_all_dependencies() is called LATER, after all CONFIG_*
# platform variables are set (around line 760+). This ensures the resolver can
# see CONFIG_VIDEOTOOLBOX, CONFIG_PTHREADS, etc.

# =============================================================================
# Essential Variables
# =============================================================================

# Year for copyright
string(TIMESTAMP CONFIG_THIS_YEAR "%Y")

# License string
if(ENABLE_NONFREE)
    set(FFMPEG_LICENSE "nonfree and unredistributable")
elseif(ENABLE_GPL AND ENABLE_VERSION3)
    set(FFMPEG_LICENSE "GPL version 3 or later")
elseif(ENABLE_GPL)
    set(FFMPEG_LICENSE "GPL version 2 or later")
elseif(ENABLE_VERSION3)
    set(FFMPEG_LICENSE "LGPL version 3 or later")
else()
    set(FFMPEG_LICENSE "LGPL version 2.1 or later")
endif()

# Type sizes
include(CheckTypeSize)
check_type_size("long" SIZEOF_LONG)
check_type_size("int" SIZEOF_INT)
check_type_size("short" SIZEOF_SHORT)
check_type_size("void*" SIZEOF_VOIDP)

# Network/socket struct detection
include(CheckCSourceCompiles)

if(WIN32)
    # Windows uses Winsock2
    # These structures are always available on Windows via winsock2.h / ws2tcpip.h
    # Force-set them to 1 to avoid CMake cache issues with check_c_source_compiles
    set(HAVE_SOCKLEN_T 1)
    set(HAVE_STRUCT_ADDRINFO 1)
    set(HAVE_STRUCT_SOCKADDR_STORAGE 1)
    set(HAVE_STRUCT_SOCKADDR_IN6 1)
    set(HAVE_STRUCT_SOCKADDR_SA_LEN 0)  # Windows doesn't have sa_len
    set(HAVE_GETADDRINFO 1)
    set(HAVE_STRUCT_POLLFD 1)
    set(HAVE_CLOSESOCKET 1)
    set(HAVE_WINSOCK2_H 1)
    set(HAVE_WS2TCPIP_H 1)
else()
    # POSIX systems
    # On macOS, socklen_t is always available (it's defined in system headers)
    # but check_c_source_compiles fails without _DARWIN_C_SOURCE on Apple platforms.
    # Use force-set approach for macOS to avoid CMake detection issues.
    set(CMAKE_REQUIRED_DEFINITIONS_SAVE ${CMAKE_REQUIRED_DEFINITIONS})
    if(APPLE)
        # On macOS, socklen_t is always present (required by POSIX)
        set(HAVE_SOCKLEN_T 1)
    else()
        # Need to include <sys/socket.h> for socklen_t detection
        # Some platforms require feature test macros
        set(CMAKE_REQUIRED_DEFINITIONS_SAVE ${CMAKE_REQUIRED_DEFINITIONS})
        set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE")
        check_c_source_compiles("
            #include <sys/types.h>
            #include <sys/socket.h>
            int main(void) { socklen_t x = 0; (void)x; return 0; }
        " HAVE_SOCKLEN_T)
        set(CMAKE_REQUIRED_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS_SAVE})
        if(NOT HAVE_SOCKLEN_T)
            set(HAVE_SOCKLEN_T 0)
        endif()
    endif()

    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/socket.h>
        #include <netdb.h>
        int main(void) { struct addrinfo ai; (void)ai; return 0; }
    " HAVE_STRUCT_ADDRINFO)
    if(NOT HAVE_STRUCT_ADDRINFO)
        set(HAVE_STRUCT_ADDRINFO 0)
    endif()

    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/socket.h>
        int main(void) { struct sockaddr_storage ss; (void)ss; return 0; }
    " HAVE_STRUCT_SOCKADDR_STORAGE)
    if(NOT HAVE_STRUCT_SOCKADDR_STORAGE)
        set(HAVE_STRUCT_SOCKADDR_STORAGE 0)
    endif()

    # HAVE_STRUCT_SOCKADDR_IN6 and HAVE_STRUCT_SOCKADDR_SA_LEN for macOS
    # On macOS, these are always available but check_c_source_compiles may fail
    # without proper feature test macros. Force-set them on macOS.
    if(APPLE)
        set(HAVE_STRUCT_SOCKADDR_IN6 1)
        set(HAVE_STRUCT_SOCKADDR_SA_LEN 1)
    else()
        check_c_source_compiles("
            #include <sys/types.h>
            #include <sys/socket.h>
            #include <netinet/in.h>
            int main(void) { struct sockaddr_in6 s6; (void)s6; return 0; }
        " HAVE_STRUCT_SOCKADDR_IN6)
        if(NOT HAVE_STRUCT_SOCKADDR_IN6)
            set(HAVE_STRUCT_SOCKADDR_IN6 0)
        endif()

        check_c_source_compiles("
            #include <sys/types.h>
            #include <sys/socket.h>
            int main(void) { struct sockaddr sa; (void)sa.sa_len; return 0; }
        " HAVE_STRUCT_SOCKADDR_SA_LEN)
        if(NOT HAVE_STRUCT_SOCKADDR_SA_LEN)
            set(HAVE_STRUCT_SOCKADDR_SA_LEN 0)
        endif()
    endif()

    set(CMAKE_REQUIRED_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS_SAVE})
endif()

# Inline ASM support
include(CheckCSourceCompiles)
check_c_source_compiles("
    int main(void) {
        __asm__ volatile(\"\" ::: \"memory\");
        return 0;
    }
" HAVE_INLINE_ASM)
if(NOT HAVE_INLINE_ASM)
    set(HAVE_INLINE_ASM 0)
endif()

# X86ASM (NASM) support - only applicable on x86/x86_64 architectures
find_program(NASM_EXECUTABLE nasm)
find_program(YASM_EXECUTABLE yasm)
if((NASM_EXECUTABLE OR YASM_EXECUTABLE) AND ARCH_X86)
    set(HAVE_X86ASM 1)
    set(NASM_FOUND TRUE)
    if(NASM_EXECUTABLE)
        set(NASM_PROGRAM ${NASM_EXECUTABLE})
        set(CMAKE_ASM_NASM_COMPILER ${NASM_EXECUTABLE})
    else()
        set(NASM_PROGRAM ${YASM_EXECUTABLE})
        set(CMAKE_ASM_NASM_COMPILER ${YASM_EXECUTABLE})
    endif()
    # Enable NASM language support at top level (must be done here, not in subdirs)
    enable_language(ASM_NASM)
    # Set NASM flags based on architecture and platform
    if(ARCH_X86_64)
        set(NASM_ARCH_FLAGS "-DARCH_X86_64=1 -DARCH_X86_32=0")
    else()
        set(NASM_ARCH_FLAGS "-DARCH_X86_64=0 -DARCH_X86_32=1")
    endif()
    if(APPLE)
        set(CMAKE_ASM_NASM_FLAGS "${NASM_ARCH_FLAGS} -f macho64")
    elseif(WIN32)
        set(CMAKE_ASM_NASM_FLAGS "${NASM_ARCH_FLAGS} -f win64")
    else()
        set(CMAKE_ASM_NASM_FLAGS "${NASM_ARCH_FLAGS} -f elf64")
    endif()
    # Add include path for config.h and ffmpeg source
    # -Pconfig.asm: pre-include config.asm before each .asm file (like FFmpeg's Makefile)
    set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -I${CMAKE_BINARY_DIR}/ -I${CMAKE_SOURCE_DIR}/ -Pconfig.asm")
    message(STATUS "NASM found: ${NASM_PROGRAM}, flags: ${CMAKE_ASM_NASM_FLAGS}")

    # Helper function: for each .asm source file in a list, add its directory
    # as a NASM include path via COMPILE_FLAGS property.
    # This mimics FFmpeg Makefile's -I$(<D)/ which adds the source file's directory.
    function(nasm_add_source_dir_includes target)
        get_target_property(sources ${target} SOURCES)
        foreach(src IN LISTS sources)
            if(src MATCHES "\\.asm$")
                get_filename_component(src_dir "${src}" DIRECTORY)
                if(src_dir)
                    # src_dir may be relative; make it absolute
                    if(NOT IS_ABSOLUTE "${src_dir}")
                        set(src_dir "${CMAKE_CURRENT_SOURCE_DIR}/${src_dir}")
                    endif()
                    set_property(SOURCE "${src}" APPEND_STRING
                        PROPERTY COMPILE_FLAGS " -I${src_dir}/")
                endif()
            endif()
        endforeach()
    endfunction()
else()
    set(HAVE_X86ASM 0)
    set(NASM_FOUND FALSE)
endif()

# Symbol versioning
set(HAVE_SYMVER 0)

# DOS paths (Windows only)
if(WIN32)
    set(HAVE_DOS_PATHS 1)
    set(HAVE_LIBC_MSVCRT 1)
    set(HAVE_UWP 0)
    set(HAVE_WINRT 0)
else()
    set(HAVE_DOS_PATHS 0)
    set(HAVE_LIBC_MSVCRT 0)
    set(HAVE_UWP 0)
    set(HAVE_WINRT 0)
endif()

# Runtime CPU detection
set(CONFIG_RUNTIME_CPUDETECT 1)

# Safe bitstream reader
set(CONFIG_SAFE_BITSTREAM_READER 1)

# Build type flags
if(ENABLE_SHARED)
    set(CONFIG_SHARED 1)
    set(CONFIG_STATIC 0)
else()
    set(CONFIG_SHARED 0)
    set(CONFIG_STATIC 1)
endif()

# Misc config
set(CONFIG_SMALL 0)
set(CONFIG_GRAY 0)
set(CONFIG_SWSCALE_ALPHA 1)
set(CONFIG_HARDCODED_TABLES 0)
set(CONFIG_FTRAPV 0)
set(CONFIG_MEMORY_POISONING 0)
set(CONFIG_NEON_CLOBBER_TEST 0)
set(CONFIG_XMM_CLOBBER_TEST 0)
set(CONFIG_VALGRIND_BACKTRACE 0)
set(CONFIG_OSSFUZZ 0)
# macOS requires PIC for all code (shared libraries and executables)
# Linux shared libraries also need PIC; for static-only Linux builds it's optional
if(APPLE OR (UNIX AND NOT APPLE AND BUILD_SHARED_LIBS))
    set(CONFIG_PIC 1)
else()
    set(CONFIG_PIC 0)
endif()
set(CONFIG_THUMB 0)
set(CONFIG_UNSTABLE 0)
set(CONFIG_AUTODETECT 1)
set(CONFIG_LARGE_TESTS 0)
set(CONFIG_LINUX_PERF 0)
set(CONFIG_MACOS_KPERF 0)
set(CONFIG_SHADER_COMPRESSION 0)
set(CONFIG_RESOURCE_COMPRESSION 0)

# Documentation
set(CONFIG_DOC 0)
set(CONFIG_HTMLPAGES 0)
set(CONFIG_MANPAGES 0)
set(CONFIG_PODPAGES 0)
set(CONFIG_TXTPAGES 0)

# Examples
set(CONFIG_AVIO_HTTP_SERVE_FILES_EXAMPLE 0)
set(CONFIG_AVIO_LIST_DIR_EXAMPLE 0)
set(CONFIG_AVIO_READ_CALLBACK_EXAMPLE 0)
set(CONFIG_DECODE_AUDIO_EXAMPLE 0)
set(CONFIG_DECODE_FILTER_AUDIO_EXAMPLE 0)
set(CONFIG_DECODE_FILTER_VIDEO_EXAMPLE 0)
set(CONFIG_DECODE_VIDEO_EXAMPLE 0)
set(CONFIG_DEMUX_DECODE_EXAMPLE 0)
set(CONFIG_ENCODE_AUDIO_EXAMPLE 0)
set(CONFIG_ENCODE_VIDEO_EXAMPLE 0)
set(CONFIG_EXTRACT_MVS_EXAMPLE 0)
set(CONFIG_FILTER_AUDIO_EXAMPLE 0)
set(CONFIG_HW_DECODE_EXAMPLE 0)
set(CONFIG_MUX_EXAMPLE 0)
set(CONFIG_QSV_DECODE_EXAMPLE 0)
set(CONFIG_REMUX_EXAMPLE 0)
set(CONFIG_RESAMPLE_AUDIO_EXAMPLE 0)
set(CONFIG_SCALE_VIDEO_EXAMPLE 0)
set(CONFIG_SHOW_METADATA_EXAMPLE 0)
set(CONFIG_TRANSCODE_AAC_EXAMPLE 0)
set(CONFIG_TRANSCODE_EXAMPLE 0)
set(CONFIG_VAAPI_ENCODE_EXAMPLE 0)
set(CONFIG_VAAPI_TRANSCODE_EXAMPLE 0)
set(CONFIG_QSV_TRANSCODE_EXAMPLE 0)

# FreeType2 detection (for vf_drawtext filter)
find_package(Freetype QUIET)
if(NOT Freetype_FOUND)
    # Try pkg-config fallback
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(FREETYPE QUIET IMPORTED_TARGET freetype2)
        if(FREETYPE_FOUND)
            set(FREETYPE_INCLUDE_DIRS ${FREETYPE_INCLUDE_DIRS})
            set(FREETYPE_LIBRARIES ${FREETYPE_LIBRARIES})
            message(STATUS "Found FreeType2 via pkg-config: ${FREETYPE_VERSION}")
        endif()
    endif()
else()
    message(STATUS "Found FreeType2: ${FREETYPE_VERSION_STRING}")
endif()

# HarfBuzz detection (for vf_drawtext filter text shaping)
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(HARFBUZZ QUIET IMPORTED_TARGET harfbuzz)
    if(HARFBUZZ_FOUND)
        message(STATUS "Found HarfBuzz: ${HARFBUZZ_VERSION}")
    endif()
endif()

# Vulkan detection
find_package(Vulkan QUIET)
if(Vulkan_FOUND)
    set(CONFIG_VULKAN 1)
    message(STATUS "Found Vulkan: ${Vulkan_VERSION}")
else()
    set(CONFIG_VULKAN 0)
endif()
set(CONFIG_VULKAN_STATIC 0)
set(CONFIG_VULKAN_1_4 0)
set(CONFIG_VULKAN_ENCODE 0)

# glslang detection (SPIR-V compiler for Vulkan shaders)
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(GLSLANG QUIET glslang)
    if(GLSLANG_FOUND)
        set(CONFIG_LIBGLSLANG 1)
        set(CONFIG_LIBSHADERC 0)
        message(STATUS "Found glslang: ${GLSLANG_VERSION}")
    else()
        # Try shaderc
        pkg_check_modules(SHADERC QUIET shaderc)
        if(SHADERC_FOUND)
            set(CONFIG_LIBSHADERC 1)
            set(CONFIG_LIBGLSLANG 0)
            message(STATUS "Found shaderc: ${SHADERC_VERSION}")
        else()
            set(CONFIG_LIBGLSLANG 0)
            set(CONFIG_LIBSHADERC 0)
        endif()
    endif()
else()
    set(CONFIG_LIBGLSLANG 0)
    set(CONFIG_LIBSHADERC 0)
endif()

# Internal features
# Internal features - only set those not covered by _select chains
set(CONFIG_FAST_UNALIGNED ${HAVE_FAST_UNALIGNED})
set(CONFIG_PIXELUTILS 1)

# Assembler features (defaults, may be overridden by arch detection)
foreach(var AS_ARCH_DIRECTIVE AS_ARCHEXT_CRC_DIRECTIVE AS_ARCHEXT_DOTPROD_DIRECTIVE
            AS_ARCHEXT_I8MM_DIRECTIVE AS_ARCHEXT_SVE_DIRECTIVE AS_ARCHEXT_SVE2_DIRECTIVE
            AS_ARCHEXT_SME_DIRECTIVE AS_ARCHEXT_SME_I16I64_DIRECTIVE AS_ARCHEXT_SME2_DIRECTIVE
            AS_DN_DIRECTIVE AS_FPU_DIRECTIVE AS_FUNC AS_OBJECT_ARCH ASM_MOD_Q
            BLOCKS_EXTENSION EBP_AVAILABLE EBX_AVAILABLE GNU_AS GNU_WINDRES IBM_ASM
            INLINE_ASM_DIRECT_SYMBOL_REFS INLINE_ASM_LABELS INLINE_ASM_NONLOCAL_LABELS
            PRAGMA_DEPRECATED RSYNC_CONTIMEOUT SYMVER_ASM_LABEL SYMVER_GNU_ASM
            VFP_ARGS XFORM_ASM XMM_CLOBBERS)
    if(NOT HAVE_${var})
        set(HAVE_${var} 0)
    endif()
endforeach()

# macOS/iOS specific features
foreach(var DPI_AWARENESS_CONTEXT IDXGIOUTPUT5
            __X_ABI_CWINDOWS_CGRAPHICS_CCAPTURE_CIGRAPHICSCAPTURESESSION5
            IDIRECT3DDXGIINTERFACEACCESS
            KCMVIDEOCODECTYPE_HEVC KCMVIDEOCODECTYPE_HEVCWITHALPHA
            KCMVIDEOCODECTYPE_VP9 KCMVIDEOCODECTYPE_AV1
            KCVPIXELFORMATTYPE_420YPCBCR10BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_422YPCBCR8BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_422YPCBCR10BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_422YPCBCR16BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_444YPCBCR8BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_444YPCBCR10BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_444YPCBCR16BIPLANARVIDEORANGE
            KCVPIXELFORMATTYPE_422YPCBCR8_YUVS
            KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_2084_PQ
            KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2100_HLG
            KCVIMAGEBUFFERTRANSFERFUNCTION_LINEAR
            KCVIMAGEBUFFERYCBCRMATRIX_ITU_R_2020
            KCVIMAGEBUFFERCOLORPRIMARIES_ITU_R_2020
            KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2020
            KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_428_1
            KVTQPMODULATIONLEVEL_DEFAULT SECPKGCONTEXT_KEYINGMATERIALINFO)
    if(NOT HAVE_${var})
        set(HAVE_${var} 0)
    endif()
endforeach()

# Struct members
foreach(var SOCKLEN_T STRUCT_ADDRINFO STRUCT_GROUP_SOURCE_REQ STRUCT_IP_MREQ_SOURCE
            STRUCT_IPV6_MREQ STRUCT_MSGHDR_MSG_FLAGS STRUCT_POLLFD STRUCT_RUSAGE_RU_MAXRSS
            STRUCT_SCTP_EVENT_SUBSCRIBE STRUCT_SOCKADDR_IN6 STRUCT_SOCKADDR_SA_LEN
            STRUCT_SOCKADDR_STORAGE STRUCT_STAT_ST_MTIM_TV_NSEC
            STRUCT_V4L2_FRMIVALENUM_DISCRETE STRUCT_MFXCONFIGINTERFACE)
    if(NOT HAVE_${var})
        set(HAVE_${var} 0)
    endif()
endforeach()

# External tools
foreach(var GZIP IOCTL_POSIX LIBDRM_GETFB2 MAKEINFO MAKEINFO_HTML
            OPENCL_D3D11 OPENCL_DRM_ARM OPENCL_DRM_BEIGNET OPENCL_DXVA2
            OPENCL_VAAPI_BEIGNET OPENCL_VAAPI_INTEL_MEDIA OPENCL_VIDEOTOOLBOX
            PERL POD2MAN TEXI2HTML XMLLINT ZLIB_GZIP OPENVINO2)
    if(NOT HAVE_${var})
        set(HAVE_${var} 0)
    endif()
endforeach()

# Libraries
if(UNIX AND NOT APPLE)
    set(HAVE_M 1)
    set(HAVE_LIBDL 1)
elseif(APPLE)
    set(HAVE_M 1)
    set(HAVE_LIBDL 0)
else()
    set(HAVE_M 0)
    set(HAVE_LIBDL 0)
endif()

# Intrinsics
if(HAVE_NEON_INTRINSICS)
    set(HAVE_INTRINSICS_NEON 1)
else()
    set(HAVE_INTRINSICS_NEON 0)
endif()
if(HAVE_SSE2_INTRINSICS)
    set(HAVE_INTRINSICS_SSE2 1)
else()
    set(HAVE_INTRINSICS_SSE2 0)
endif()

# Hardware acceleration defaults
set(CONFIG_CUDA 0)
set(CONFIG_CUDA_NVCC 0)
set(CONFIG_CUDA_SDK 0)
set(CONFIG_LIBNPP 0)
set(CONFIG_LIBMFX 0)
set(CONFIG_LIBVPL 0)
set(CONFIG_MMAL 0)
set(CONFIG_OMX 0)
set(CONFIG_OMX_RPI 0)
set(CONFIG_OPENCL 0)
set(CONFIG_AMF 0)
set(CONFIG_CUDA_LLVM 0)
set(CONFIG_CUVID 0)
set(CONFIG_D3D11VA 0)
set(CONFIG_D3D12VA 0)
set(CONFIG_DXVA2 0)
set(CONFIG_FFNVCODEC 0)
set(CONFIG_LIBDRM 0)
set(CONFIG_NVDEC 0)
set(CONFIG_NVENC 0)
set(CONFIG_VAAPI 0)
set(CONFIG_VDPAU 0)
set(CONFIG_VULKAN 0)
set(CONFIG_VULKAN_STATIC 0)
set(CONFIG_V4L2_M2M 0)
set(CONFIG_FONTCONFIG 0)

# Platform-specific hardware acceleration
if(APPLE)
    set(CONFIG_VIDEOTOOLBOX 1)
    set(CONFIG_AUDIOTOOLBOX 1)
    set(CONFIG_APPKIT 1)
    set(CONFIG_AVFOUNDATION 1)
    set(CONFIG_COREIMAGE 1)
    set(CONFIG_METAL 0)

    # Set implied feature flags for dependency resolver
    # These correspond to configure's check_func/check_header results
    # that are referenced in FFmpegComponentDeps.cmake _DEPS
    set(CONFIG_COREFOUNDATION 1)
    set(CONFIG_COREMEDIA 1)
    set(CONFIG_COREVIDEO 1)
    set(CONFIG_CORESERVICES 1)
    # VideoToolbox function availability (assumed present on modern macOS)
    set(CONFIG_VTDECOMPRESSIONSESSIONDECODEFRAME 1)
    set(CONFIG_VTCOMPRESSIONSESSIONPREPARETOENCODEFRAMES 1)
    set(CONFIG_VTPIXELTRANSFERSESSIONCREATE 1)
    set(CONFIG_VTPIXELROTATIONSESSIONCREATE 1)
    # AudioToolbox feature availability
    set(CONFIG_AUDIOOBJECTPROPERTYADDRESS 0)  # Not always available
    # Pthreads (needed by VT encoder deps)
    set(CONFIG_PTHREADS ${HAVE_PTHREADS})

    # VideoToolbox/CoreVideo enum availability (present on modern macOS 10.13+)
    set(HAVE_KCMVIDEOCODECTYPE_HEVC 1)
    set(HAVE_KCMVIDEOCODECTYPE_HEVCWITHALPHA 1)
    set(HAVE_KCMVIDEOCODECTYPE_VP9 1)
    set(HAVE_KCMVIDEOCODECTYPE_AV1 1)
    set(HAVE_KCVPIXELFORMATTYPE_420YPCBCR10BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_422YPCBCR8BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_422YPCBCR10BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_422YPCBCR16BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_444YPCBCR8BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_444YPCBCR10BIPLANARVIDEORANGE 1)
    set(HAVE_KCVPIXELFORMATTYPE_444YPCBCR16BIPLANARVIDEORANGE 1)
    set(HAVE_KVTQPMODULATIONLEVEL_DEFAULT 1)
else()
    set(CONFIG_VIDEOTOOLBOX 0)
    set(CONFIG_AUDIOTOOLBOX 0)
    set(CONFIG_APPKIT 0)
    set(CONFIG_AVFOUNDATION 0)
    set(CONFIG_COREIMAGE 0)
    set(CONFIG_METAL 0)
    set(CONFIG_COREFOUNDATION 0)
    set(CONFIG_COREMEDIA 0)
    set(CONFIG_COREVIDEO 0)
    set(CONFIG_CORESERVICES 0)
    set(CONFIG_VTDECOMPRESSIONSESSIONDECODEFRAME 0)
    set(CONFIG_VTCOMPRESSIONSESSIONPREPARETOENCODEFRAMES 0)
    set(CONFIG_VTPIXELTRANSFERSESSIONCREATE 0)
    set(CONFIG_VTPIXELROTATIONSESSIONCREATE 0)
    set(CONFIG_AUDIOOBJECTPROPERTYADDRESS 0)
    set(CONFIG_PTHREADS ${HAVE_PTHREADS})
endif()

# Note: VAAPI, VDPAU, ALSA are auto-detected by FFmpegDetectLibraries()
# Do NOT set defaults here - let the detection logic determine availability
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(CONFIG_ALSA 0)
endif()
# V4L2 M2M detection is handled in FFmpegExternalLibs.cmake
set(CONFIG_V4L2_M2M 0)  # TODO: detect properly

if(WIN32)
    set(CONFIG_D3D11VA 1)
    set(CONFIG_DXVA2 1)
    set(CONFIG_MEDIAFOUNDATION 0)
    set(CONFIG_SCHANNEL 0)
else()
    set(CONFIG_MEDIAFOUNDATION 0)
    set(CONFIG_SCHANNEL 0)
endif()

# Misc hardware/platform
set(CONFIG_RKMPP 0)
set(CONFIG_SNDIO 0)
set(CONFIG_XLIB 0)
set(CONFIG_LIBXCB 0)
set(CONFIG_LIBXCB_SHM 0)
set(CONFIG_LIBXCB_SHAPE 0)
set(CONFIG_LIBXCB_XFIXES 0)

# MMAL
set(HAVE_MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS 0)

# Section data
set(HAVE_SECTION_DATA_REL_RO 0)

# =============================================================================
# Component Configuration Variables
# ============================================================================

# FFmpegDefaults already included earlier (before FFmpegComponents)
# Set additional config variables for config.h.in template
set(CONFIG_FILTERS 1)
set(CONFIG_MUXERS 1)
set(CONFIG_DEMUXERS 1)
set(CONFIG_PROTOCOLS 1)

# Protocol configuration
set(CONFIG_TLS_PROTOCOL 1)
set(CONFIG_DTLS_PROTOCOL 0)

# Device configuration - handled by dependency resolver based on platform deps
# CONFIG_LAVFI_INDEV, CONFIG_AVFOUNDATION_INDEV, CONFIG_AUDIOTOOLBOX_OUTDEV
# are resolved by FFmpegDependencyResolver based on their _DEPS definitions

# Internal codec subsystem configs
# NOTE: Most internal subsystems (ATSC_A53, GOLOMB, H264DSP, etc.) are now
# automatically enabled by the dependency resolver via _select chains.
# For example: CONFIG_LIBX264_ENCODER -> _select -> ATSC_A53, GOLOMB
# Only set subsystems here that are NOT covered by _select chains or need
# special handling.

# Zlib-dependent wrappers
set(CONFIG_DEFLATE_WRAPPER ${CONFIG_ZLIB})
set(CONFIG_INFLATE_WRAPPER ${CONFIG_ZLIB})

# Features that are always enabled (not controlled by _select)
set(CONFIG_NETWORK 1)
set(CONFIG_FRAME_THREAD_ENCODER 1)

# Features explicitly disabled (require specific detection)
set(CONFIG_DNN 0)
set(CONFIG_EVCPARSE 0)
set(CONFIG_CBS_LCEVC 0)
set(CONFIG_LIBX262 0)
set(CONFIG_LIBX264_HDR10 0)
set(CONFIG_SNAPPY 0)

# D3D12 features (Windows only, require specific detection)
set(CONFIG_D3D12_INTRA_REFRESH 0)
set(CONFIG_D3D12_MOTION_ESTIMATOR 0)
set(CONFIG_D3D12_VIDEO_PROCESS_REFERENCE_INFO 0)
set(CONFIG_D3D12VA_ENCODE 0)
set(CONFIG_D3D12VA_ME_PRECISION_EIGHTH_PIXEL 0)

# QSV features (require Intel QSV detection)
set(CONFIG_QSV 0)
set(CONFIG_QSVDEC 0)
set(CONFIG_QSVENC 0)
set(CONFIG_QSVVPP 0)

# VAAPI/Vulkan encode features
set(CONFIG_VAAPI_1 0)
set(CONFIG_VAAPI_ENCODE 0)
set(CONFIG_VULKAN_1_4 0)
set(CONFIG_VULKAN_ENCODE 0)

# License flags (ensure set for config.h)
set(CONFIG_GPLV3 0)
set(CONFIG_LGPLV3 0)
if(ENABLE_GPL AND ENABLE_VERSION3)
    set(CONFIG_GPLV3 1)
endif()
if(ENABLE_VERSION3)
    set(CONFIG_LGPLV3 1)
endif()

# =============================================================================
# L2+L3: Dependency Resolution & Component Generation
# NOW all CONFIG_* platform variables are set, so the resolver can see them.
# =============================================================================

# Resolve all component dependencies
# This links L1 (external libraries) to L2 (components) via _SELECT relationships
ffmpeg_resolve_all_dependencies()

# Set library enable flags for FFmpegComponents module
set(FFMPEG_ENABLE_avutil     1)  # Always enabled
set(FFMPEG_ENABLE_avcodec    ${ENABLE_AVCODEC})
set(FFMPEG_ENABLE_avformat   ${ENABLE_AVFORMAT})
set(FFMPEG_ENABLE_avfilter   ${ENABLE_AVFILTER})
set(FFMPEG_ENABLE_avdevice   ${ENABLE_AVDEVICE})
set(FFMPEG_ENABLE_swscale    ${ENABLE_SWSCALE})
set(FFMPEG_ENABLE_swresample ${ENABLE_SWRESAMPLE})

# Generate config_components.h and component list files
include(FFmpegComponents)

# =============================================================================
# config_components.h is generated by FFmpegComponents.cmake
# Do not overwrite it here

# Generate avconfig.h for libavutil (this doesn't depend on external lib detection)
set(AV_HAVE_BIGENDIAN ${HAVE_BIGENDIAN})
set(AV_HAVE_FAST_UNALIGNED ${HAVE_FAST_UNALIGNED})
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/avconfig.h.in"
    "${CMAKE_BINARY_DIR}/libavutil/avconfig.h"
    @ONLY
)

# =============================================================================
# Version Information
# =============================================================================

# Read version from VERSION file
if(EXISTS "${CMAKE_SOURCE_DIR}/VERSION")
    file(STRINGS "${CMAKE_SOURCE_DIR}/VERSION" FFMPEG_VERSION_STRING LIMIT_COUNT 1)
    string(REPLACE "." ";" VERSION_LIST ${FFMPEG_VERSION_STRING})
    list(GET VERSION_LIST 0 FFMPEG_VERSION_MAJOR)
    list(GET VERSION_LIST 1 FFMPEG_VERSION_MINOR)
    list(GET VERSION_LIST 2 FFMPEG_VERSION_MICRO)
endif()

# Generate ffversion.h
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --always
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
endif()
if(NOT GIT_VERSION)
    if(EXISTS "${CMAKE_SOURCE_DIR}/VERSION")
        file(STRINGS "${CMAKE_SOURCE_DIR}/VERSION" GIT_VERSION LIMIT_COUNT 1)
    else()
        set(GIT_VERSION "unknown")
    endif()
endif()

set(FFVERSION_H "${CMAKE_BINARY_DIR}/libavutil/ffversion.h")
set(FFVERSION_CONTENT "/* Automatically generated by CMake, do not manually edit! */
#ifndef AVUTIL_FFVERSION_H
#define AVUTIL_FFVERSION_H
#define FFMPEG_VERSION \"${GIT_VERSION}\"
#endif /* AVUTIL_FFVERSION_H */
")

# Only write if content changed to avoid spurious rebuilds
if(EXISTS ${FFVERSION_H})
    file(READ ${FFVERSION_H} EXISTING_CONTENT)
endif()
if(NOT "${EXISTING_CONTENT}" STREQUAL "${FFVERSION_CONTENT}")
    file(WRITE ${FFVERSION_H} "${FFVERSION_CONTENT}")
endif()

# =============================================================================
# Detect External Libraries
# =============================================================================
# This must be called before add_subdirectory() so that CONFIG_ variables
# are available when processing library CMakeLists.txt files
FFmpegDetectLibraries()

# Print library detection summary
FFmpegPrintLibrarySummary()

# =============================================================================
# Generate Configuration Headers (after library detection)
# =============================================================================

# Generate config.h from CMake template
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/config.h.in"
    "${CMAKE_BINARY_DIR}/config.h"
    @ONLY
)
message(STATUS "Generated config.h from CMake template")

# Generate config.asm for NASM assembler
# NASM needs %define NAME VALUE format instead of #define NAME VALUE
if(HAVE_X86ASM)
    # Read config.h.in and convert #define NAME @VAR@ to %define NAME VALUE
    file(READ "${CMAKE_SOURCE_DIR}/cmake/config.h.in" config_h_in_content)
    # Extract all @VAR@ patterns and build NASM defines
    set(config_asm_content "; Automatically generated by CMake - do not modify!\n")
    # Get all variable names from config.h.in
    string(REGEX MATCHALL "#define ([A-Z_0-9]+) @([A-Z_0-9]+)@" config_defines "${config_h_in_content}")
    foreach(define_line IN LISTS config_defines)
        string(REGEX MATCH "#define ([A-Z_0-9]+) @([A-Z_0-9]+)@" _ "${define_line}")
        set(var_name "${CMAKE_MATCH_1}")
        set(cmake_var "${CMAKE_MATCH_2}")
        if(DEFINED ${cmake_var})
            set(var_value "${${cmake_var}}")
            if("${var_value}" STREQUAL "" OR NOT var_value)
                set(var_value "0")
            endif()
            string(APPEND config_asm_content "%define ${var_name} ${var_value}\n")
        else()
            string(APPEND config_asm_content "%define ${var_name} 0\n")
        endif()
    endforeach()
    file(WRITE "${CMAKE_BINARY_DIR}/config.asm" "${config_asm_content}")

    # Also append codec CONFIG_* variables from ALL_CODECS list
    # (these are set by FFmpegComponents.cmake and needed by some .asm files)
    if(ALL_CODECS)
        set(codec_asm_content "")
        foreach(codec IN LISTS ALL_CODECS)
            string(APPEND codec_asm_content "%define CONFIG_${codec} 1\n")
        endforeach()
        file(APPEND "${CMAKE_BINARY_DIR}/config.asm" "${codec_asm_content}")
    endif()

    message(STATUS "Generated config.asm for NASM assembler")

    # Generate config_components.asm (explicitly included by some .asm files)
    # Contains %define CONFIG_xxx_DECODER/ENCODER 1 for all enabled codecs
    set(config_components_asm_content "; Automatically generated by CMake - do not modify!\n")
    if(ALL_CODECS)
        foreach(codec IN LISTS ALL_CODECS)
            string(APPEND config_components_asm_content "%define CONFIG_${codec} 1\n")
        endforeach()
    endif()
    file(WRITE "${CMAKE_BINARY_DIR}/config_components.asm" "${config_components_asm_content}")
    message(STATUS "Generated config_components.asm for NASM assembler")
endif()

# =============================================================================
# Subdirectories
# =============================================================================

# Add libraries in dependency order
add_subdirectory(libavutil)

if(ENABLE_SWRESAMPLE)
    add_subdirectory(libswresample)
endif()

if(ENABLE_SWSCALE)
    add_subdirectory(libswscale)
endif()

if(ENABLE_AVCODEC)
    add_subdirectory(libavcodec)
endif()

if(ENABLE_AVFORMAT)
    add_subdirectory(libavformat)
endif()

if(ENABLE_AVFILTER)
    add_subdirectory(libavfilter)
endif()

if(ENABLE_AVDEVICE)
    add_subdirectory(libavdevice)
endif()

# Add tools
if(ENABLE_FFMPEG OR ENABLE_FFPLAY OR ENABLE_FFPROBE)
    add_subdirectory(fftools)
endif()

# Add tests (always, but FATE tests only if samples are provided)
option(BUILD_TESTING "Build tests" ON)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

# =============================================================================
# Apply External Libraries to Targets (Centralized Handling)
# =============================================================================
# This must be called AFTER all add_subdirectory() so all targets exist
include(FFmpegApplyExternalLibs)
ffmpeg_apply_external_libs()

# =============================================================================
# Summary
# =============================================================================

message(STATUS "")
message(STATUS "FFmpeg CMake Configuration Summary")
message(STATUS "===================================")
message(STATUS "  Version:        ${FFMPEG_VERSION_STRING}")
message(STATUS "  Architecture:   ${FFMPEG_ARCH}")
message(STATUS "  Build type:     ${CMAKE_BUILD_TYPE}")
message(STATUS "")
message(STATUS "Libraries:")
message(STATUS "  libavutil:      ON")
message(STATUS "  libswresample:  ${ENABLE_SWRESAMPLE}")
message(STATUS "  libswscale:     ${ENABLE_SWSCALE}")
message(STATUS "  libavcodec:     ${ENABLE_AVCODEC}")
message(STATUS "  libavformat:    ${ENABLE_AVFORMAT}")
message(STATUS "  libavfilter:    ${ENABLE_AVFILTER}")
message(STATUS "  libavdevice:    ${ENABLE_AVDEVICE}")
message(STATUS "")
message(STATUS "Tools:")
message(STATUS "  ffmpeg:         ${ENABLE_FFMPEG}")
message(STATUS "  ffplay:         ${ENABLE_FFPLAY}")
message(STATUS "  ffprobe:        ${ENABLE_FFPROBE}")
message(STATUS "")
