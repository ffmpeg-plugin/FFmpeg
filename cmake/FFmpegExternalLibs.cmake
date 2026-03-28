# FFmpeg External Libraries Configuration
# Based on FFmpeg's configure script library detection
# STRICT ORDER: Following configure line 7227+ sequence
#
# This module uses FFmpegLibraryDetection.cmake to provide
# configure-compatible library detection
#
# Behavior:
#   - If user explicitly sets -DENABLE_LIBXXX=ON, library detection failure is FATAL
#   - If auto-detect (default ON), library not found is silently disabled

include(${CMAKE_SOURCE_DIR}/cmake/FFmpegLibraryDetection.cmake)

# =============================================================================
# Auto-detect vs Explicit Enable Management
# =============================================================================
#
# Usage pattern (clean and explicit):
#
#   ffmpeg_option(LIBX264 "Enable x264 encoder" ON)
#   if(ENABLE_LIBX264)
#       ffmpeg_find_library(LIBX264
#           PKG_CONFIG "x264"
#           HEADERS "x264.h"
#           FUNCTIONS "x264_encoder_encode"
#       )
#   endif()
#
# Behavior:
#   - User explicitly sets -DENABLE_LIBX264=ON → FATAL_ERROR if not found
#   - Auto-detect (default ON) → silently disable if not found
#

# Global list to track explicitly enabled libraries
# Reset on each configure to avoid stale values from previous runs
set(FFMPEG_REQUIRED_LIBS "" CACHE INTERNAL "Libraries explicitly enabled by user" FORCE)

#
# Record explicitly enabled library
# Called at CMakeLists.txt scope (before any detection)
#
function(ffmpeg_record_required name)
    string(TOUPPER "${name}" _name_upper)
    # Check if user explicitly set this option ON via -DENABLE_XXX=ON
    # We check if a marker variable exists in the cache
    if(DEFINED CACHE{FFMPEG_REQUIRED_${_name_upper}})
        if(ENABLE_${_name_upper})
            list(APPEND FFMPEG_REQUIRED_LIBS ${_name_upper})
            set(FFMPEG_REQUIRED_LIBS ${FFMPEG_REQUIRED_LIBS} CACHE INTERNAL "")
        endif()
    endif()
endfunction()

#
# Check if library was explicitly enabled (must fail if not found)
#
function(ffmpeg_is_required name out_var)
    string(TOUPPER "${name}" _name_upper)
    list(FIND FFMPEG_REQUIRED_LIBS ${_name_upper} _index)
    if(_index GREATER_EQUAL 0)
        set(${out_var} TRUE PARENT_SCOPE)
    else()
        set(${out_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

#
# Handle library not found
# REQUIRED (explicitly enabled) → FATAL_ERROR
# AUTO-DETECT → STATUS message + disable
#
function(ffmpeg_lib_not_found name reason)
    ffmpeg_is_required(${name} _required)
    string(TOLOWER "${name}" _name_lower)
    string(TOUPPER "${name}" _name_upper)
    
    if(_required)
        message(FATAL_ERROR "ERROR: ${reason}")
    else()
        message(STATUS "  ${_name_lower}: not found")
        set(CONFIG_${_name_upper} 0 PARENT_SCOPE)
    endif()
endfunction()

#
# Wrapper for option() that auto-records explicit enable
#
macro(ffmpeg_option name description default)
    option(ENABLE_${name} "${description}" ${default})
    # If user explicitly set this option ON via -DENABLE_XXX=ON,
    # create a marker variable to track it
    string(TOUPPER "${name}" _name_upper)
    # Check if this option was explicitly set by user (not just default ON)
    # We check if the cache variable exists and was explicitly set
    # by examining if it was defined before the option() call
    if(DEFINED CACHE{ENABLE_${_name_upper}})
        # Check if the variable was explicitly set by user
        # by looking at the help string - if it matches our description,
        # it was created by option(), otherwise user set it explicitly
        get_property(_help_string CACHE ENABLE_${_name_upper} PROPERTY HELPSTRING)
        if(NOT _help_string STREQUAL "${description}")
            # User explicitly set this option via -D, mark it as required
            if(ENABLE_${_name_upper})
                set(FFMPEG_REQUIRED_${_name_upper} TRUE CACHE INTERNAL "Explicitly enabled by user")
            endif()
        endif()
    endif()
    ffmpeg_record_required(${name})
endmacro()

# =============================================================================
# Core System Libraries
# =============================================================================

# Math library
check_library_exists(m sin "" HAVE_LIBM)
if(HAVE_LIBM)
    set(MATH_LIBRARY m)
else()
    set(MATH_LIBRARY "")
endif()

# Dynamic loader
check_library_exists(dl dlopen "" HAVE_LIBDL)
if(HAVE_LIBDL)
    set(DL_LIBRARY dl)
else()
    set(DL_LIBRARY "")
endif()

# POSIX threads
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads)
if(CMAKE_THREAD_LIBS_INIT)
    set(PTHREAD_LIBRARY ${CMAKE_THREAD_LIBS_INIT})
else()
    # Try manual detection
    check_library_exists(pthread pthread_create "" HAVE_PTHREAD)
    if(HAVE_PTHREAD)
        set(PTHREAD_LIBRARY pthread)
    else()
        check_library_exists(pthreadGC2 pthread_create "" HAVE_PTHREADGC2)
        if(HAVE_PTHREADGC2)
            set(PTHREAD_LIBRARY pthreadGC2)
        endif()
    endif()
endif()

# RT library (for older glibc)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    check_library_exists(rt clock_gettime "" HAVE_LIBRT)
    if(HAVE_LIBRT)
        set(RT_LIBRARY rt)
    endif()
endif()

# =============================================================================
# Line 7228: AviSynth
# =============================================================================
ffmpeg_option(AVISYNTH "Enable AviSynth support" ON)
if(ENABLE_AVISYNTH)
    check_include_file("avisynth/avisynth_c.h" HAVE_AVISYNTH_C_H)
    check_include_file("avisynth/avs/version.h" HAVE_AVISYNTH_VERSION_H)
    if(HAVE_AVISYNTH_C_H AND HAVE_AVISYNTH_VERSION_H)
        # Check version >= 3.7.3
        include(CheckCXXSourceCompiles)
        set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES})
        check_cxx_source_compiles("#include <avisynth/avs/version.h>
int main() {
#if AVS_MAJOR_VER > 3 || (AVS_MAJOR_VER == 3 && AVS_MINOR_VER > 7) || (AVS_MAJOR_VER == 3 && AVS_MINOR_VER == 7 && AVS_BUGFIX_VER >= 3)
    return 0;
#else
#error AviSynth+ version must be >= 3.7.3
#endif
}" AVISYNTH_VERSION_OK)
        if(AVISYNTH_VERSION_OK)
            set(CONFIG_AVISYNTH 1)
        else()
            ffmpeg_lib_not_found(AVISYNTH "AviSynth+ header version must be >= 3.7.3")
        endif()
    else()
        message(STATUS "  AviSynth headers: not found")
    endif()
else()
    set(CONFIG_AVISYNTH 0)
endif()

# =============================================================================
# Line 7231: Cairo
# =============================================================================
ffmpeg_option(CAIRO "Enable Cairo graphics library" ON)
if(ENABLE_CAIRO)
    ffmpeg_require_pkg_config(cairo cairo "cairo.h" "cairo_create")
else()
    set(CONFIG_CAIRO 0)
endif()

# =============================================================================
# Line 7232: CUDA NVCC
# =============================================================================
ffmpeg_option(CUDA_NVCC "Enable CUDA NVCC compiler" ON)
if(ENABLE_CUDA_NVCC)
    find_program(NVCC_EXECUTABLE nvcc PATHS /usr/local/cuda/bin)
    if(NVCC_EXECUTABLE)
        set(CONFIG_CUDA_NVCC 1)
        message(STATUS "  nvcc: found (${NVCC_EXECUTABLE})")
    else()
        ffmpeg_lib_not_found(CUDA_NVCC "failed checking for nvcc.")
    endif()
else()
    set(CONFIG_CUDA_NVCC 0)
endif()

# =============================================================================
# Line 7233: Chromaprint
# =============================================================================
ffmpeg_option(CHROMAPRINT "Enable Chromaprint audio fingerprinting" ON)
if(ENABLE_CHROMAPRINT)
    ffmpeg_check_pkg_config(chromaprint libchromaprint "chromaprint.h" "chromaprint_get_version")
    if(NOT CONFIG_CHROMAPRINT)
        ffmpeg_check_lib(chromaprint "chromaprint.h" "chromaprint_get_version" "-lchromaprint")
    endif()
else()
    set(CONFIG_CHROMAPRINT 0)
endif()

# =============================================================================
# Line 7235: DeckLink
# =============================================================================
ffmpeg_option(DECKLINK "Enable DeckLink support" ON)
if(ENABLE_DECKLINK)
    check_include_file("DeckLinkAPI.h" HAVE_DECKLINK_API_H)
    if(HAVE_DECKLINK_API_H)
        check_include_file("DeckLinkAPIVersion.h" HAVE_DECKLINK_API_VERSION_H)
        if(HAVE_DECKLINK_API_VERSION_H)
            # Check version >= 10.11
            include(CheckCXXSourceCompiles)
            check_cxx_source_compiles("#include <DeckLinkAPIVersion.h>
int main() {
#if BLACKMAGIC_DECKLINK_API_VERSION >= 0x0a0b0000
    return 0;
#else
#error DeckLink API version must be >= 10.11
#endif
}" DECKLINK_VERSION_OK)
            if(DECKLINK_VERSION_OK)
                set(CONFIG_DECKLINK 1)
            else()
                ffmpeg_lib_not_found(DECKLINK "Decklink API version must be >= 10.11")
            endif()
        endif()
    else()
        message(STATUS "  DeckLinkAPI.h: not found")
    endif()
else()
    set(CONFIG_DECKLINK 0)
endif()

# =============================================================================
# Line 7237: Frei0r
# =============================================================================
ffmpeg_option(FREI0R "Enable frei0r video filter API" ON)
if(ENABLE_FREI0R)
    check_include_file("frei0r.h" HAVE_FREI0R_H)
    if(HAVE_FREI0R_H)
        set(CONFIG_FREI0R 1)
    else()
        message(STATUS "  frei0r.h: not found")
    endif()
else()
    set(CONFIG_FREI0R 0)
endif()

# =============================================================================
# Line 7238: GMP
# =============================================================================
ffmpeg_option(GMP "Enable GMP (GNU Multiple Precision Arithmetic Library)" ON)
if(ENABLE_GMP)
    ffmpeg_check_lib(gmp "gmp.h" "mpz_export" "-lgmp")
    if(NOT CONFIG_GMP)
        message(STATUS "  gmp: not found")
    endif()
else()
    set(CONFIG_GMP 0)
endif()

# =============================================================================
# Line 7239: GnuTLS
# =============================================================================
# Note: Disabled by default to avoid conflict with OpenSSL
# If both are detected, configure fails with "must not be enabled at the same time"
ffmpeg_option(GNUTLS "Enable GnuTLS support" OFF)
if(ENABLE_GNUTLS)
    ffmpeg_require_pkg_config(gnutls gnutls "gnutls/gnutls.h" "gnutls_global_init")
else()
    set(CONFIG_GNUTLS 0)
endif()

# =============================================================================
# Line 7240: JNI (Android)
# =============================================================================
ffmpeg_option(JNI "Enable JNI support (Android)" ON)
if(ENABLE_JNI)
    if(ANDROID)
        check_include_file("jni.h" HAVE_JNI_H)
        if(HAVE_JNI_H AND CONFIG_PTHREADS)
            set(CONFIG_JNI 1)
        else()
            message(STATUS "  jni: not found")
        endif()
    else()
        message(STATUS "  jni: not found (requires Android target)")
        set(CONFIG_JNI 0)
    endif()
else()
    set(CONFIG_JNI 0)
endif()

# =============================================================================
# Line 7241: LADSPA
# =============================================================================
ffmpeg_option(LADSPA "Enable LADSPA audio plugin support" ON)
if(ENABLE_LADSPA)
    check_include_files("ladspa.h;dlfcn.h" HAVE_LADSPA_H)
    if(HAVE_LADSPA_H)
        set(CONFIG_LADSPA 1)
    else()
        message(STATUS "  ladspa.h or dlfcn.h: not found")
    endif()
else()
    set(CONFIG_LADSPA 0)
endif()

# =============================================================================
# Line 7242: LCMS2
# =============================================================================
ffmpeg_option(LCMS2 "Enable Little CMS color management" ON)
if(ENABLE_LCMS2)
    ffmpeg_require_pkg_config(lcms2 "lcms2 >= 2.13" "lcms2.h" "cmsCreateContext")
else()
    set(CONFIG_LCMS2 0)
endif()

# =============================================================================
# Line 7243: libaom
# =============================================================================
ffmpeg_option(LIBAOM "Enable libaom AV1 codec" ON)
if(ENABLE_LIBAOM)
    ffmpeg_require_pkg_config(libaom "aom >= 2.0.0" "aom/aom_codec.h" "aom_codec_version")
else()
    set(CONFIG_LIBAOM 0)
endif()

# =============================================================================
# Line 7244: liboapv (Open AV1 Plugin for VVC)
# =============================================================================
ffmpeg_option(LIBOAPV "Enable liboapv OAPV codec" ON)
if(ENABLE_LIBOAPV)
    ffmpeg_require_pkg_config(liboapv "oapv >= 0.2.0.0" "oapv/oapv.h" "oapve_encode")
else()
    set(CONFIG_LIBOAPV 0)
endif()

# =============================================================================
# Line 7245: libaribb24
# =============================================================================
ffmpeg_option(LIBARIBB24 "Enable libaribb24 ARIB caption support" ON)
if(ENABLE_LIBARIBB24)
    # Try pkg-config first
    ffmpeg_check_pkg_config(libaribb24 "aribb24 > 1.0.3" "aribb24/aribb24.h" "arib_instance_new")
    if(NOT CONFIG_LIBARIBB24)
        # Fall back to GPL build
        if(ENABLE_GPL)
            ffmpeg_require_pkg_config(libaribb24 aribb24 "aribb24/aribb24.h" "arib_instance_new")
        else()
            ffmpeg_lib_not_found(LIBARIBB24 "libaribb24 requires version higher than 1.0.3 or --enable-gpl.")
        endif()
    endif()
else()
    set(CONFIG_LIBARIBB24 0)
endif()

# =============================================================================
# Line 7248: libaribcaption
# =============================================================================
ffmpeg_option(LIBARIBCAPTION "Enable libaribcaption ARIB caption support" ON)
if(ENABLE_LIBARIBCAPTION)
    ffmpeg_require_pkg_config(libaribcaption "libaribcaption >= 1.1.1" "aribcaption/aribcaption.h" "aribcc_context_alloc")
else()
    set(CONFIG_LIBARIBCAPTION 0)
endif()

# =============================================================================
# Line 7249: LV2
# =============================================================================
ffmpeg_option(LV2 "Enable LV2 audio plugin support" ON)
if(ENABLE_LV2)
    ffmpeg_require_pkg_config(lv2 lilv-0 "lilv/lilv.h" "lilv_world_new")
else()
    set(CONFIG_LV2 0)
endif()

# =============================================================================
# Line 7250: libiec61883
# =============================================================================
ffmpeg_option(LIBIEC61883 "Enable libiec61883 FireWire DV/HDV input" ON)
if(ENABLE_LIBIEC61883)
    set(CMAKE_REQUIRED_LIBRARIES "-lraw1394 -lavc1394 -lrom1394 -liec61883")
    check_include_file("libiec61883/iec61883.h" HAVE_IEC61883_H)
    check_library_exists(iec61883 iec61883_cmp_connect "" HAVE_IEC61883)
    if(HAVE_IEC61883_H AND HAVE_IEC61883)
        set(CONFIG_LIBIEC61883 1)
        set(LIBIEC61883_LIBRARIES "-lraw1394 -lavc1394 -lrom1394 -liec61883")
    else()
        message(STATUS "  libiec61883: not found")
    endif()
else()
    set(CONFIG_LIBIEC61883 0)
endif()

# =============================================================================
# Line 7251: libass
# =============================================================================
ffmpeg_option(LIBASS "Enable libass subtitle rendering" ON)
if(ENABLE_LIBASS)
    ffmpeg_require_pkg_config(libass "libass >= 0.11.0" "ass/ass.h" "ass_library_init")
else()
    set(CONFIG_LIBASS 0)
endif()

# =============================================================================
# Line 7252: libbluray
# =============================================================================
ffmpeg_option(LIBBLURAY "Enable libbluray Blu-ray support" ON)
if(ENABLE_LIBBLURAY)
    ffmpeg_require_pkg_config(libbluray libbluray "libbluray/bluray.h" "bd_open")
else()
    set(CONFIG_LIBBLURAY 0)
endif()

# =============================================================================
# Line 7253: libbs2b
# =============================================================================
ffmpeg_option(LIBBS2B "Enable libbs2b Bauer stereo-to-binaural filter" ON)
if(ENABLE_LIBBS2B)
    ffmpeg_require_pkg_config(libbs2b libbs2b "bs2b.h" "bs2b_open")
else()
    set(CONFIG_LIBBS2B 0)
endif()

# =============================================================================
# Line 7254: libcelt
# =============================================================================
ffmpeg_option(LIBCELT "Enable libcelt CELT codec" ON)
if(ENABLE_LIBCELT)
    ffmpeg_check_lib(libcelt "celt/celt.h" "celt_decode" "-lcelt0")
    if(CONFIG_LIBCELT)
        # Check for decoder_create_custom (version >= 0.11.0)
        set(CMAKE_REQUIRED_LIBRARIES "-lcelt0")
        check_library_exists(celt0 celt_decoder_create_custom "" HAVE_CELT_DECODER_CREATE_CUSTOM)
        if(NOT HAVE_CELT_DECODER_CREATE_CUSTOM)
            ffmpeg_lib_not_found(LIBCELT "libcelt must be installed and version must be >= 0.11.0.")
        endif()
    else()
        message(STATUS "  libcelt: not found")
    endif()
else()
    set(CONFIG_LIBCELT 0)
endif()

# =============================================================================
# Line 7257: libcaca
# =============================================================================
ffmpeg_option(LIBCACA "Enable libcaca ASCII art graphics" ON)
if(ENABLE_LIBCACA)
    ffmpeg_require_pkg_config(libcaca caca "caca.h" "caca_create_canvas")
else()
    set(CONFIG_LIBCACA 0)
endif()

# =============================================================================
# Line 7258: libcodec2
# =============================================================================
ffmpeg_option(LIBCODEC2 "Enable libcodec2 codec" ON)
if(ENABLE_LIBCODEC2)
    ffmpeg_check_lib(libcodec2 "codec2/codec2.h" "codec2_create" "-lcodec2")
    if(NOT CONFIG_LIBCODEC2)
        message(STATUS "  libcodec2: not found")
    endif()
else()
    set(CONFIG_LIBCODEC2 0)
endif()

# =============================================================================
# Compression Libraries
# =============================================================================

# libz (zlib)
ffmpeg_option(ZLIB "Enable zlib compression" ON)
FFmpegDetectZlib()

# libbz2 (bzip2)
ffmpeg_option(BZLIB "Enable bzip2 compression" ON)
FFmpegDetectBZip2()

# liblzma (xz)
ffmpeg_option(LZMA "Enable LZMA compression" ON)
FFmpegDetectLZMA()

# =============================================================================
# Character Set / Encoding
# =============================================================================

# iconv
ffmpeg_option(ICONV "Enable iconv character conversion" ON)
FFmpegDetectIconv()

# =============================================================================
# Encryption / Security
# =============================================================================

# OpenSSL
ffmpeg_option(OPENSSL "Enable OpenSSL support" ON)
FFmpegDetectOpenSSL()

# =============================================================================
# Graphics / Windowing
# =============================================================================

# SDL2 (for ffplay)
ffmpeg_option(SDL2 "Enable SDL2 support (for ffplay)" ON)
FFmpegDetectSDL2()

# X11 libraries (Linux)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    option(ENABLE_XLIB "Enable X11 support" ON)
    if(ENABLE_XLIB)
        # Use pkg-config for X11
        ffmpeg_check_pkg_config(xlib_x11 x11 "X11/Xlib.h" "XPending")
        if(NOT CONFIG_XLIB_X11)
            ffmpeg_check_lib(xlib_x11 "X11/Xlib.h" "XPending" "-lX11")
        endif()
        
        ffmpeg_check_pkg_config(xlib_xext xext "X11/Xlib.h X11/extensions/XShm.h" "XShmAttach")
        ffmpeg_check_pkg_config(xlib_xv xv "X11/Xlib.h X11/extensions/Xvlib.h" "XvGetPortAttribute")
    else()
        set(CONFIG_XLIB 0)
        set(CONFIG_XLIB_X11 0)
        set(CONFIG_XLIB_XEXT 0)
        set(CONFIG_XLIB_XV 0)
    endif()
endif()

# =============================================================================
# Audio Output
# =============================================================================

# ALSA (Linux)
ffmpeg_option(ALSA "Enable ALSA audio support" ON)
FFmpegDetectAlsa()

# PulseAudio
ffmpeg_option(LIBPULSE "Enable PulseAudio support" ON)
FFmpegDetectPulseAudio()

# sndio (BSD)
ffmpeg_option(SNDIO "Enable sndio audio support" ON)
if(ENABLE_SNDIO)
    ffmpeg_check_lib(sndio "sndio.h" "sio_open" "-lsndio")
else()
    set(CONFIG_SNDIO 0)
endif()

# OpenAL
ffmpeg_option(OPENAL "Enable OpenAL support" ON)
if(ENABLE_OPENAL)
    find_package(OpenAL QUIET)
    if(OPENAL_FOUND)
        set(CONFIG_OPENAL 1)
    else()
        ffmpeg_check_pkg_config(openal openal "AL/al.h" "alOpenDevice")
    endif()
else()
    set(CONFIG_OPENAL 0)
endif()

# =============================================================================
# Line 7259: libdav1d
# =============================================================================
ffmpeg_option(LIBDAV1D "Enable dav1d AV1 decoder" ON)
if(ENABLE_LIBDAV1D)
    ffmpeg_require_pkg_config(libdav1d "dav1d >= 1.0.0" "dav1d/dav1d.h" "dav1d_version")
else()
    set(CONFIG_LIBDAV1D 0)
endif()

# =============================================================================
# Line 7260: libdavs2
# =============================================================================
ffmpeg_option(LIBDAVS2 "Enable davs2 AVS2 decoder" ON)
if(ENABLE_LIBDAVS2)
    ffmpeg_require_pkg_config(libdavs2 "davs2 >= 1.6.0" "davs2.h" "davs2_decoder_open")
else()
    set(CONFIG_LIBDAVS2 0)
endif()

# =============================================================================
# Line 7261: libdc1394
# =============================================================================
ffmpeg_option(LIBDC1394 "Enable libdc1394 FireWire camera input" ON)
if(ENABLE_LIBDC1394)
    ffmpeg_require_pkg_config(libdc1394 libdc1394-2 "dc1394/dc1394.h" "dc1394_new")
else()
    set(CONFIG_LIBDC1394 0)
endif()

# =============================================================================
# Line 7262: libdrm
# =============================================================================
ffmpeg_option(LIBDRM "Enable libdrm (Linux)" ON)
if(ENABLE_LIBDRM AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
    ffmpeg_check_pkg_config(libdrm libdrm "xf86drm.h" "drmGetVersion")
else()
    set(CONFIG_LIBDRM 0)
endif()

# =============================================================================
# Line 7263: libdvdnav
# =============================================================================
ffmpeg_option(LIBDVDNAV "Enable libdvdnav" ON)
if(ENABLE_LIBDVDNAV)
    ffmpeg_require_pkg_config(libdvdnav "dvdnav >= 6.1.0" "dvdnav/dvdnav.h" "dvdnav_open2")
else()
    set(CONFIG_LIBDVDNAV 0)
endif()

# =============================================================================
# Line 7264: libdvdread
# =============================================================================
ffmpeg_option(LIBDVDREAD "Enable libdvdread" ON)
if(ENABLE_LIBDVDREAD)
    ffmpeg_require_pkg_config(libdvdread "dvdread >= 6.1.1" "dvdread/dvd_reader.h" "DVDOpen2")
else()
    set(CONFIG_LIBDVDREAD 0)
endif()

# =============================================================================
# Line 7265: libfdk_aac
# =============================================================================
ffmpeg_option(LIBFDK_AAC "Enable FDK-AAC codec" ON)
if(ENABLE_LIBFDK_AAC)
    ffmpeg_check_pkg_config(libfdk_aac fdk-aac "fdk-aac/aacenc_lib.h" "aacEncOpen")
    if(NOT CONFIG_LIBFDK_AAC)
        ffmpeg_check_lib(libfdk_aac "fdk-aac/aacenc_lib.h" "aacEncOpen" "-lfdk-aac")
        if(CONFIG_LIBFDK_AAC)
            message(WARNING "using libfdk without pkg-config")
        endif()
    endif()
else()
    set(CONFIG_LIBFDK_AAC 0)
endif()

# =============================================================================
# Line 7269: libflite
# =============================================================================
ffmpeg_option(LIBFLITE "Enable flite text-to-speech" ON)
if(ENABLE_LIBFLITE)
    set(flite_extralibs "-lflite_cmu_time_awb -lflite_cmu_us_awb -lflite_cmu_us_kal -lflite_cmu_us_kal16 -lflite_cmu_us_rms -lflite_cmu_us_slt -lflite_usenglish -lflite_cmulex -lflite")
    set(CMAKE_REQUIRED_LIBRARIES ${flite_extralibs})
    check_include_file("flite/flite.h" HAVE_FLITE_H)
    check_library_exists(flite flite_init "" HAVE_FLITE)
    if(HAVE_FLITE_H AND HAVE_FLITE)
        set(CONFIG_LIBFLITE 1)
        set(LIBFLITE_LIBRARIES ${flite_extralibs})
    else()
        message(STATUS "  libflite: not found")
    endif()
else()
    set(CONFIG_LIBFLITE 0)
endif()

# =============================================================================
# Line 7270-7274: Font libraries
# =============================================================================
ffmpeg_option(FONTCONFIG "Enable fontconfig" ON)
if(ENABLE_FONTCONFIG)
    set(CONFIG_FONTCONFIG 1)
    set(ENABLE_LIBFONTCONFIG ON)
endif()

ffmpeg_option(LIBFONTCONFIG "Enable Fontconfig" ON)
if(ENABLE_LIBFONTCONFIG)
    ffmpeg_require_pkg_config(libfontconfig fontconfig "fontconfig/fontconfig.h" "FcInit")
else()
    set(CONFIG_LIBFONTCONFIG 0)
endif()

ffmpeg_option(LIBFREETYPE "Enable FreeType" ON)
if(ENABLE_LIBFREETYPE)
    ffmpeg_require_pkg_config(libfreetype freetype2 "ft2build.h FT_FREETYPE_H" "FT_Init_FreeType")
else()
    set(CONFIG_LIBFREETYPE 0)
endif()

ffmpeg_option(LIBFRIBIDI "Enable FriBidi bidirectional text" ON)
if(ENABLE_LIBFRIBIDI)
    ffmpeg_require_pkg_config(libfribidi fribidi "fribidi.h" "fribidi_version_info")
else()
    set(CONFIG_LIBFRIBIDI 0)
endif()

ffmpeg_option(LIBHARFBUZZ "Enable HarfBuzz" ON)
if(ENABLE_LIBHARFBUZZ)
    ffmpeg_require_pkg_config(libharfbuzz harfbuzz "hb.h" "hb_buffer_create")
else()
    set(CONFIG_LIBHARFBUZZ 0)
endif()

# =============================================================================
# Line 7275: libglslang
# =============================================================================
ffmpeg_option(LIBGLSLANG "Enable glslang SPIRV compiler" ON)
if(ENABLE_LIBGLSLANG)
    check_include_file("glslang/build_info.h" HAVE_GLSLANG_BUILD_INFO_H)
    if(HAVE_GLSLANG_BUILD_INFO_H)
        # Check version >= 16
        include(CheckCXXSourceCompiles)
        check_cxx_source_compiles("#include <glslang/build_info.h>
int main() {
#if GLSLANG_VERSION_MAJOR >= 16
    return 0;
#else
    return 1;
#endif
}" GLSLANG_VERSION_OK)
        if(GLSLANG_VERSION_OK)
            set(spvremap "")
        else()
            set(spvremap "-lSPVRemapper")
        endif()
        
        # Check libglslang
        set(CMAKE_REQUIRED_LIBRARIES "-lglslang -lMachineIndependent -lGenericCodeGen ${spvremap} -lSPIRV -lSPIRV-Tools-opt -lSPIRV-Tools -lstdc++ ${MATH_LIBRARY} ${PTHREAD_LIBRARY}")
        check_include_file("glslang/Include/glslang_c_interface.h" HAVE_GLSLANG_C_INTERFACE_H)
        check_library_exists(glslang glslang_initialize_process "" HAVE_GLSLANG)
        if(HAVE_GLSLANG_C_INTERFACE_H AND HAVE_GLSLANG)
            set(CONFIG_LIBGLSLANG 1)
            set(LIBGLSLANG_LIBRARIES "-lglslang -lMachineIndependent -lGenericCodeGen ${spvremap} -lSPIRV -lSPIRV-Tools-opt -lSPIRV-Tools -lstdc++")
        else()
            # Try alternative library list
            set(CMAKE_REQUIRED_LIBRARIES "-lglslang -lMachineIndependent -lOSDependent -lHLSL -lOGLCompiler -lGenericCodeGen ${spvremap} -lSPIRV -lSPIRV-Tools-opt -lSPIRV-Tools -lstdc++ ${MATH_LIBRARY} ${PTHREAD_LIBRARY}")
            check_library_exists(glslang glslang_initialize_process "" HAVE_GLSLANG2)
            if(HAVE_GLSLANG_C_INTERFACE_H AND HAVE_GLSLANG2)
                set(CONFIG_LIBGLSLANG 1)
                set(LIBGLSLANG_LIBRARIES "-lglslang -lMachineIndependent -lOSDependent -lHLSL -lOGLCompiler -lGenericCodeGen ${spvremap} -lSPIRV -lSPIRV-Tools-opt -lSPIRV-Tools -lstdc++")
            else()
                message(STATUS "  libglslang: not found")
            endif()
        endif()
    else()
        message(STATUS "  glslang/build_info.h: not found")
    endif()
else()
    set(CONFIG_LIBGLSLANG 0)
endif()

# =============================================================================
# Line 7285: libgme
# =============================================================================
ffmpeg_option(LIBGME "Enable Game Music Emu library" ON)
if(ENABLE_LIBGME)
    ffmpeg_check_pkg_config(libgme libgme "gme/gme.h" "gme_new_emu")
    if(NOT CONFIG_LIBGME)
        ffmpeg_check_lib(libgme "gme/gme.h" "gme_new_emu" "-lgme -lstdc++")
        if(NOT CONFIG_LIBGME)
            message(STATUS "  libgme: not found")
        endif()
    endif()
else()
    set(CONFIG_LIBGME 0)
endif()

# =============================================================================
# Line 7287: libgsm
# =============================================================================
ffmpeg_option(LIBGSM "Enable GSM codec" ON)
if(ENABLE_LIBGSM)
    # Try different header locations
    ffmpeg_check_lib(libgsm "gsm.h" "gsm_create" "-lgsm")
    if(NOT CONFIG_LIBGSM)
        ffmpeg_check_lib(libgsm "gsm/gsm.h" "gsm_create" "-lgsm")
    endif()
    if(NOT CONFIG_LIBGME)
        message(STATUS "  libgsm: not found")
    endif()
else()
    set(CONFIG_LIBGSM 0)
endif()

# =============================================================================
# Line 7290: libilbc
# =============================================================================
ffmpeg_option(LIBILBC "Enable iLBC codec" ON)
if(ENABLE_LIBILBC)
    set(CMAKE_REQUIRED_LIBRARIES "${PTHREAD_LIBRARY}")
    ffmpeg_check_lib(libilbc "ilbc.h" "WebRtcIlbcfix_InitDecode" "-lilbc")
    if(NOT CONFIG_LIBILBC)
        message(STATUS "  libilbc: not found")
    endif()
else()
    set(CONFIG_LIBILBC 0)
endif()

# =============================================================================
# Line 7291: libjxl
# =============================================================================
ffmpeg_option(LIBJXL "Enable JPEG XL codec" ON)
if(ENABLE_LIBJXL)
    ffmpeg_require_pkg_config(libjxl "libjxl >= 0.7.0" "jxl/decode.h" "JxlDecoderVersion")
    ffmpeg_require_pkg_config(libjxl_threads "libjxl_threads >= 0.7.0" "jxl/thread_parallel_runner.h" "JxlThreadParallelRunner")
else()
    set(CONFIG_LIBJXL 0)
endif()

# =============================================================================
# Line 7293: libklvanc
# =============================================================================
ffmpeg_option(LIBKLVANC "Enable libklvanc (KLV Ancillary data)" ON)
if(ENABLE_LIBKLVANC)
    ffmpeg_check_lib(libklvanc "libklvanc/vanc.h" "klvanc_context_create" "-lklvanc")
    if(NOT CONFIG_LIBKLVANC)
        message(STATUS "  libklvanc: not found")
    endif()
else()
    set(CONFIG_LIBKLVANC 0)
endif()

# =============================================================================
# Line 7294: libkvazaar
# =============================================================================
ffmpeg_option(LIBKVAZAAR "Enable Kvazaar HEVC encoder" ON)
if(ENABLE_LIBKVAZAAR)
    ffmpeg_require_pkg_config(libkvazaar "kvazaar >= 2.0.0" "kvazaar.h" "kvz_api_get")
else()
    set(CONFIG_LIBKVAZAAR 0)
endif()

# =============================================================================
# Line 7295: liblc3
# =============================================================================
ffmpeg_option(LIBLC3 "Enable LC3 codec" ON)
if(ENABLE_LIBLC3)
    ffmpeg_require_pkg_config(liblc3 "lc3 >= 1.1.0" "lc3.h" "lc3_hr_setup_encoder")
else()
    set(CONFIG_LIBLC3 0)
endif()

# =============================================================================
# Line 7296: liblensfun
# =============================================================================
ffmpeg_option(LIBLENSFUN "Enable lensfun lens correction" ON)
if(ENABLE_LIBLENSFUN)
    ffmpeg_require_pkg_config(liblensfun lensfun "lensfun.h" "lf_db_create")
else()
    set(CONFIG_LIBLENSFUN 0)
endif()

# =============================================================================
# Line 7297: liblcevc_dec
# =============================================================================
ffmpeg_option(LIBLCEVC_DEC "Enable LCEVC decoder" ON)
if(ENABLE_LIBLCEVC_DEC)
    ffmpeg_require_pkg_config(liblcevc_dec "lcevc_dec >= 4.0.0" "LCEVC/lcevc_dec.h" "LCEVC_CreateDecoder")
else()
    set(CONFIG_LIBLCEVC_DEC 0)
endif()

# =============================================================================
# Line 7299-7326: libmfx / libvpl (Intel Media SDK / oneVPL)
# =============================================================================
ffmpeg_option(LIBMFX "Enable Intel Media SDK (deprecated, use libvpl)" ON)
ffmpeg_option(LIBVPL "Enable Intel oneVPL" ON)

if(ENABLE_LIBMFX AND ENABLE_LIBVPL)
    # Auto-resolve conflict: prefer libvpl over libmfx
    message(STATUS "  libmfx and libvpl both enabled, preferring libvpl")
    set(ENABLE_LIBMFX OFF)
elseif(ENABLE_LIBMFX)
    # Try pkg-config first
    ffmpeg_check_pkg_config(libmfx "libmfx >= 1.28 libmfx < 2.0" "mfxvideo.h" "MFXInit")
    if(NOT CONFIG_LIBMFX)
        # Try with mfx/mfxvideo.h
        ffmpeg_check_pkg_config(libmfx "libmfx >= 1.28 libmfx < 2.0" "mfx/mfxvideo.h" "MFXInit")
        if(CONFIG_LIBMFX)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${LIBMFX_INCLUDEDIR}/mfx")
        else()
            # Manual check
            set(CMAKE_REQUIRED_LIBRARIES "-llibmfx advapi32")
            check_include_file("mfxvideo.h" HAVE_MFXVIDEO_H)
            check_include_file("mfxdefs.h" HAVE_MFXDEFS_H)
            check_library_exists(mfx MFXInit "" HAVE_MFX)
            if(HAVE_MFXVIDEO_H AND HAVE_MFXDEFS_H AND HAVE_MFX)
                # Check version
                include(CheckCXXSourceCompiles)
                check_cxx_source_compiles("#include <mfxdefs.h>
int main() {
#if MFX_VERSION >= 1028 && MFX_VERSION < 2000
    return 0;
#else
#error libmfx version must be >= 1.28 and < 2.0
#endif
}" MFX_VERSION_OK)
                if(MFX_VERSION_OK)
                    set(CONFIG_LIBMFX 1)
                    set(LIBMFX_LIBRARIES "-llibmfx advapi32")
                    message(WARNING "using libmfx without pkg-config")
                else()
                    ffmpeg_lib_not_found(LIBMFX "libmfx version must be >= 1.28 and < 2.0")
                endif()
            else()
                message(STATUS "  libmfx: not found")
            endif()
        endif()
    endif()
    message(WARNING "libmfx is deprecated. Please run configure with --enable-libvpl to use libvpl instead.")
elseif(ENABLE_LIBVPL)
    ffmpeg_check_pkg_config(libmfx "vpl >= 2.6" "mfxvideo.h mfxdispatcher.h" "MFXLoad")
    if(NOT CONFIG_LIBMFX)
        message(STATUS "  libvpl >= 2.6: not found")
    endif()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DMFX_DEPRECATED_OFF")
    # Check for mfxConfigInterface
    check_type_size("struct mfxConfigInterface" MFX_CONFIG_INTERFACE_SIZE)
else()
    set(CONFIG_LIBMFX 0)
endif()

# =============================================================================
# Line 7332: libmodplug
# =============================================================================
ffmpeg_option(LIBMODPLUG "Enable libmodplug module player" ON)
if(ENABLE_LIBMODPLUG)
    ffmpeg_require_pkg_config(libmodplug libmodplug "libmodplug/modplug.h" "ModPlug_Load")
else()
    set(CONFIG_LIBMODPLUG 0)
endif()

# =============================================================================
# Line 7333: libmp3lame
# =============================================================================
ffmpeg_option(LIBMP3LAME "Enable MP3 encoding (lame)" ON)
if(ENABLE_LIBMP3LAME)
    # Check version >= 3.98.3
    ffmpeg_check_pkg_config(libmp3lame "libmp3lame >= 3.98.3" "lame/lame.h" "lame_set_VBR_quality")
    if(NOT CONFIG_LIBMP3LAME)
        set(CMAKE_REQUIRED_LIBRARIES "${MATH_LIBRARY}")
        ffmpeg_check_lib(libmp3lame "lame/lame.h" "lame_set_VBR_quality" "-lmp3lame")
    endif()
else()
    set(CONFIG_LIBMP3LAME 0)
endif()

# =============================================================================
# Line 7334: libmpeghdec
# =============================================================================
ffmpeg_option(LIBMPEHGDEC "Enable MPEG-H decoder" ON)
if(ENABLE_LIBMPEHGDEC)
    ffmpeg_require_pkg_config(libmpeghdec "mpeghdec >= 3.0.0" "mpeghdec/mpeghdecoder.h" "mpeghdecoder_init")
else()
    set(CONFIG_LIBMPEHGDEC 0)
endif()

# =============================================================================
# Line 7335: libmysofa
# =============================================================================
ffmpeg_option(LIBMYSOFA "Enable libmysofa SOFA file loader" ON)
if(ENABLE_LIBMYSOFA)
    ffmpeg_check_pkg_config(libmysofa libmysofa "mysofa.h" "mysofa_neighborhood_init_withstepdefine")
    if(NOT CONFIG_LIBMYSOFA)
        set(CMAKE_REQUIRED_LIBRARIES "-lz")
        ffmpeg_check_lib(libmysofa "mysofa.h" "mysofa_neighborhood_init_withstepdefine" "-lmysofa")
        if(NOT CONFIG_LIBMYSOFA)
            message(STATUS "  libmysofa: not found")
        endif()
    endif()
else()
    set(CONFIG_LIBMYSOFA 0)
endif()

# =============================================================================
# Line 7337: libnpp
# =============================================================================
ffmpeg_option(LIBNPP "Enable NVIDIA Performance Primitives" ON)
if(ENABLE_LIBNPP)
    # Check if libnpp support is available
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/libavfilter/version_major.h")
        ffmpeg_lib_not_found(LIBNPP "libnpp support is removed in this version")
    else()
        file(READ "${CMAKE_SOURCE_DIR}/libavfilter/version_major.h" VERSION_MAJOR_CONTENT)
        if(NOT VERSION_MAJOR_CONTENT MATCHES "FF_API_LIBNPP_SUPPORT")
            ffmpeg_lib_not_found(LIBNPP "libnpp support is removed in this version")
        else()
    
    # Check libnpp
    set(CMAKE_REQUIRED_LIBRARIES "-lnppig -lnppicc -lnppc -lnppidei -lnppif")
    check_include_file("npp.h" HAVE_NPP_H)
    check_library_exists(nppig nppGetLibVersion "" HAVE_NPP)
    if(HAVE_NPP_H AND HAVE_NPP)
        set(CONFIG_LIBNPP 1)
        set(LIBNPP_LIBRARIES "-lnppig -lnppicc -lnppc -lnppidei -lnppif")
    else()
        # Try alternative library list
        set(CMAKE_REQUIRED_LIBRARIES "-lnppi -lnppif -lnppc -lnppidei")
        check_library_exists(nppi nppGetLibVersion "" HAVE_NPP2)
        if(HAVE_NPP_H AND HAVE_NPP2)
            set(CONFIG_LIBNPP 1)
            set(LIBNPP_LIBRARIES "-lnppi -lnppif -lnppc -lnppidei")
        else()
            message(STATUS "  libnpp: not found")
        endif()
    endif()
    
    # Check for nppiYCbCr420_8u_P2P3R (deprecated function check)
    set(CMAKE_REQUIRED_LIBRARIES ${LIBNPP_LIBRARIES})
    check_library_exists(nppidei nppiYCbCr420_8u_P2P3R "" HAVE_NPPI_YCBCR420)
    if(NOT HAVE_NPPI_YCBCR420)
        message(STATUS "  libnpp: version 13.0+ detected, disabling (deprecated support)")
        set(CONFIG_LIBNPP 0)
    endif()
    
        endif()  # Close line 977: if(NOT VERSION_MAJOR_CONTENT MATCHES ...)
    endif()      # Close line 973: if(NOT EXISTS ...)
else()
    set(CONFIG_LIBNPP 0)
endif()

# =============================================================================
# Line 7344: libopencore_amrnb
# =============================================================================
ffmpeg_option(LIBOPENCORE_AMRNB "Enable OpenCORE AMR-NB" ON)
if(ENABLE_LIBOPENCORE_AMRNB)
    ffmpeg_check_pkg_config(libopencore_amrnb opencore-amrnb "opencore-amrnb/interf_dec.h" "Decoder_Interface_init")
    if(NOT CONFIG_LIBOPENCORE_AMRNB)
        ffmpeg_check_lib(libopencore_amrnb "opencore-amrnb/interf_dec.h" "Decoder_Interface_init" "-lopencore-amrnb")
    endif()
else()
    set(CONFIG_LIBOPENCORE_AMRNB 0)
endif()

# =============================================================================
# Line 7346: libopencore_amrwb
# =============================================================================
ffmpeg_option(LIBOPENCORE_AMRWB "Enable OpenCORE AMR-WB" ON)
if(ENABLE_LIBOPENCORE_AMRWB)
    ffmpeg_check_pkg_config(libopencore_amrwb opencore-amrwb "opencore-amrwb/dec_if.h" "D_IF_init")
    if(NOT CONFIG_LIBOPENCORE_AMRWB)
        ffmpeg_check_lib(libopencore_amrwb "opencore-amrwb/dec_if.h" "D_IF_init" "-lopencore-amrwb")
    endif()
else()
    set(CONFIG_LIBOPENCORE_AMRWB 0)
endif()

# =============================================================================
# Line 7348: libopencv
# =============================================================================
ffmpeg_option(LIBOPENCV "Enable OpenCV" ON)
if(ENABLE_LIBOPENCV)
    ffmpeg_check_pkg_config(libopencv opencv4 "opencv2/core/core_c.h" "cvCreateImageHeader")
    if(NOT CONFIG_LIBOPENCV)
        ffmpeg_check_lib(libopencv "opencv2/core/core_c.h" "cvCreateImageHeader" "-lopencv_core -lopencv_imgproc")
    endif()
else()
    set(CONFIG_LIBOPENCV 0)
endif()

# =============================================================================
# Line 7350: libopencolorio
# =============================================================================
ffmpeg_option(LIBOPENCOLORIO "Enable OpenColorIO" ON)
if(ENABLE_LIBOPENCOLORIO)
    ffmpeg_require_pkg_config_cxx(libopencolorio "OpenColorIO" "OpenColorIO/OpenColorIO.h" "OCIO_NAMESPACE::Config")
else()
    set(CONFIG_LIBOPENCOLORIO 0)
endif()

# =============================================================================
# Line 7351: libopenh264
# =============================================================================
ffmpeg_option(LIBOPENH264 "Enable OpenH264 H.264 encoder" ON)
if(ENABLE_LIBOPENH264)
    ffmpeg_require_pkg_config(libopenh264 "openh264 >= 1.3.0" "wels/codec_api.h" "WelsGetCodecVersion")
else()
    set(CONFIG_LIBOPENH264 0)
endif()

# =============================================================================
# Line 7352: libopenjpeg
# =============================================================================
ffmpeg_option(LIBOPENJPEG "Enable OpenJPEG" ON)
if(ENABLE_LIBOPENJPEG)
    ffmpeg_check_pkg_config(libopenjpeg "libopenjp2 >= 2.1.0" "openjpeg.h" "opj_version")
    if(NOT CONFIG_LIBOPENJPEG)
        ffmpeg_check_pkg_config(libopenjpeg "libopenjp2 >= 2.1.0" "openjpeg.h" "opj_version")
        if(CONFIG_LIBOPENJPEG)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DOPJ_STATIC")
        else()
            message(STATUS "  libopenjpeg >= 2.1.0: not found")
        endif()
    endif()
else()
    set(CONFIG_LIBOPENJPEG 0)
endif()

# =============================================================================
# Line 7354: libopenmpt
# =============================================================================
ffmpeg_option(LIBOPENMPT "Enable libopenmpt module player" ON)
if(ENABLE_LIBOPENMPT)
    ffmpeg_require_pkg_config(libopenmpt "libopenmpt >= 0.2.6557" "libopenmpt/libopenmpt.h" "openmpt_module_create")
    if(CONFIG_LIBOPENMPT)
        set(libopenmpt_extralibs "-lstdc++")
    endif()
else()
    set(CONFIG_LIBOPENMPT 0)
endif()

# =============================================================================
# Line 7355: libopenvino
# =============================================================================
ffmpeg_option(LIBOPENVINO "Enable OpenVINO inference engine" ON)
if(ENABLE_LIBOPENVINO)
    # Try new API first
    ffmpeg_check_pkg_config(libopenvino openvino "openvino/c/openvino.h" "ov_core_create")
    if(CONFIG_LIBOPENVINO)
        set(openvino2 1)
    else()
        # Try old API
        ffmpeg_check_pkg_config(libopenvino openvino "c_api/ie_c_api.h" "ie_c_api_version")
        if(NOT CONFIG_LIBOPENVINO)
            ffmpeg_check_lib(libopenvino "c_api/ie_c_api.h" "ie_c_api_version" "-linference_engine_c_api")
        endif()
    endif()
else()
    set(CONFIG_LIBOPENVINO 0)
endif()

# =============================================================================
# Line 7358: libopus
# =============================================================================
ffmpeg_option(LIBOPUS "Enable Opus codec" ON)
if(ENABLE_LIBOPUS)
    option(ENABLE_LIBOPUS_DECODER "Enable Opus decoder" ON)
    option(ENABLE_LIBOPUS_ENCODER "Enable Opus encoder" ON)
    
    if(ENABLE_LIBOPUS_DECODER)
        ffmpeg_require_pkg_config(libopus opus "opus_multistream.h" "opus_multistream_decoder_create")
    else()
        set(CONFIG_LIBOPUS_DECODER 0)
    endif()
    
    if(ENABLE_LIBOPUS_ENCODER)
        ffmpeg_require_pkg_config(libopus_encoder opus "opus_multistream.h" "opus_multistream_surround_encoder_create")
    else()
        set(CONFIG_LIBOPUS_ENCODER 0)
    endif()
else()
    set(CONFIG_LIBOPUS 0)
endif()

# =============================================================================
# Line 7366: libplacebo
# =============================================================================
ffmpeg_option(LIBPLACEBO "Enable libplacebo GPU-accelerated video filters" ON)
if(ENABLE_LIBPLACEBO)
    ffmpeg_require_pkg_config(libplacebo "libplacebo >= 5.229.0" "libplacebo/vulkan.h" "pl_vulkan_create")
else()
    set(CONFIG_LIBPLACEBO 0)
endif()

# =============================================================================
# Line 7367: libpulse
# =============================================================================
ffmpeg_option(LIBPULSE "Enable PulseAudio support" ON)
if(ENABLE_LIBPULSE)
    ffmpeg_require_pkg_config(libpulse libpulse "pulse/pulseaudio.h" "pa_context_new")
else()
    set(CONFIG_LIBPULSE 0)
endif()

# =============================================================================
# Line 7368: libqrencode
# =============================================================================
ffmpeg_option(LIBQRENCODE "Enable libqrencode QR code generator" ON)
if(ENABLE_LIBQRENCODE)
    ffmpeg_require_pkg_config(libqrencode libqrencode "qrencode.h" "QRcode_encodeString")
else()
    set(CONFIG_LIBQRENCODE 0)
endif()

# =============================================================================
# Line 7369: libquirc
# =============================================================================
ffmpeg_option(LIBQUIRC "Enable libquirc QR code decoder" ON)
if(ENABLE_LIBQUIRC)
    ffmpeg_check_lib(libquirc "quirc.h" "quirc_decode" "-lquirc")
    if(NOT CONFIG_LIBQUIRC)
        message(STATUS "  libquirc: not found")
    endif()
else()
    set(CONFIG_LIBQUIRC 0)
endif()

# =============================================================================
# Line 7370: librabbitmq
# =============================================================================
ffmpeg_option(LIBRABBITMQ "Enable RabbitMQ" ON)
if(ENABLE_LIBRABBITMQ)
    ffmpeg_require_pkg_config(librabbitmq "librabbitmq >= 0.7.1" "amqp.h" "amqp_new_connection")
else()
    set(CONFIG_LIBRABBITMQ 0)
endif()

# =============================================================================
# Line 7371: librav1e
# =============================================================================
ffmpeg_option(LIBRAV1E "Enable rav1e AV1 encoder" ON)
if(ENABLE_LIBRAV1E)
    ffmpeg_require_pkg_config(librav1e "rav1e >= 0.5.0" "rav1e.h" "rav1e_context_new")
else()
    set(CONFIG_LIBRAV1E 0)
endif()

# =============================================================================
# Line 7372: librist
# =============================================================================
ffmpeg_option(LIBRIST "Enable RIST support" ON)
if(ENABLE_LIBRIST)
    ffmpeg_require_pkg_config(librist "librist >= 0.2.7" "librist/librist.h" "rist_receiver_create")
else()
    set(CONFIG_LIBRIST 0)
endif()

# =============================================================================
# Line 7373: librsvg
# =============================================================================
ffmpeg_option(LIBRSVG "Enable librsvg SVG decoder" ON)
if(ENABLE_LIBRSVG)
    ffmpeg_require_pkg_config(librsvg librsvg-2.0 "librsvg-2.0/librsvg/rsvg.h" "rsvg_handle_new_from_data")
else()
    set(CONFIG_LIBRSVG 0)
endif()

# =============================================================================
# Line 7374: librtmp
# =============================================================================
ffmpeg_option(LIBRTMP "Enable librtmp" ON)
if(ENABLE_LIBRTMP)
    ffmpeg_require_pkg_config(librtmp librtmp "librtmp/rtmp.h" "RTMP_Socket")
else()
    set(CONFIG_LIBRTMP 0)
endif()

# =============================================================================
# Line 7375: librubberband
# =============================================================================
ffmpeg_option(LIBRUBBERBAND "Enable rubberband" ON)
if(ENABLE_LIBRUBBERBAND)
    ffmpeg_require_pkg_config(librubberband "rubberband >= 1.8.1" "rubberband/rubberband-c.h" "rubberband_new")
    if(CONFIG_LIBRUBBERBAND)
        set(librubberband_extralibs "-lstdc++")
    endif()
else()
    set(CONFIG_LIBRUBBERBAND 0)
endif()

# =============================================================================
# Line 7376: libshaderc
# =============================================================================
ffmpeg_option(LIBSHADERC "Enable shaderc SPIRV compiler" ON)
if(ENABLE_LIBSHADERC)
    ffmpeg_require_pkg_config(spirv_library "shaderc >= 2019.1" "shaderc/shaderc.h" "shaderc_compiler_initialize")
else()
    set(CONFIG_LIBSHADERC 0)
endif()

# =============================================================================
# Line 7377: libshine
# =============================================================================
ffmpeg_option(LIBSHINE "Enable Shine MP3 encoder" ON)
if(ENABLE_LIBSHINE)
    ffmpeg_require_pkg_config(libshine shine "shine/layer3.h" "shine_encode_buffer")
else()
    set(CONFIG_LIBSHINE 0)
endif()

# =============================================================================
# Line 7378: libsmbclient
# =============================================================================
ffmpeg_option(LIBSMBCLIENT "Enable Samba client" ON)
if(ENABLE_LIBSMBCLIENT)
    ffmpeg_check_pkg_config(libsmbclient smbclient "libsmbclient.h" "smbc_init")
    if(NOT CONFIG_LIBSMBCLIENT)
        ffmpeg_check_lib(libsmbclient "libsmbclient.h" "smbc_init" "-lsmbclient")
    endif()
else()
    set(CONFIG_LIBSMBCLIENT 0)
endif()

# =============================================================================
# Line 7380: libsnappy
# =============================================================================
ffmpeg_option(LIBSNAPPY "Enable snappy compression" ON)
if(ENABLE_LIBSNAPPY)
    ffmpeg_check_lib(libsnappy "snappy-c.h" "snappy_compress" "-lsnappy -lstdc++")
    if(NOT CONFIG_LIBSNAPPY)
        message(STATUS "  libsnappy: not found")
    endif()
else()
    set(CONFIG_LIBSNAPPY 0)
endif()

# =============================================================================
# Line 7381: libsoxr
# =============================================================================
ffmpeg_option(LIBSOXR "Enable SoX resampler" ON)
if(ENABLE_LIBSOXR)
    ffmpeg_check_lib(libsoxr "soxr.h" "soxr_create" "-lsoxr")
    if(NOT CONFIG_LIBSOXR)
        message(STATUS "  libsoxr: not found")
    endif()
else()
    set(CONFIG_LIBSOXR 0)
endif()

# =============================================================================
# Line 7382: libssh
# =============================================================================
ffmpeg_option(LIBSSH "Enable SSH support" ON)
if(ENABLE_LIBSSH)
    ffmpeg_require_pkg_config(libssh "libssh >= 0.6.0" "libssh/sftp.h" "sftp_init")
else()
    set(CONFIG_LIBSSH 0)
endif()

# =============================================================================
# Line 7383: libspeex
# =============================================================================
ffmpeg_option(LIBSPEEX "Enable Speex codec" ON)
if(ENABLE_LIBSPEEX)
    ffmpeg_require_pkg_config(libspeex speex "speex/speex.h" "speex_decoder_init")
else()
    set(CONFIG_LIBSPEEX 0)
endif()

# =============================================================================
# Line 7384: libsrt
# =============================================================================
ffmpeg_option(LIBSRT "Enable SRT support" ON)
if(ENABLE_LIBSRT)
    ffmpeg_require_pkg_config(libsrt "srt >= 1.3.0" "srt/srt.h" "srt_socket")
else()
    set(CONFIG_LIBSRT 0)
endif()

# =============================================================================
# Line 7385: libsvtav1
# =============================================================================
ffmpeg_option(LIBSVTAV1 "Enable SVT-AV1 encoder" ON)
if(ENABLE_LIBSVTAV1)
    ffmpeg_require_pkg_config(libsvtav1 "SvtAv1Enc >= 0.9.0" "EbSvtAv1Enc.h" "svt_av1_enc_init_handle")
else()
    set(CONFIG_LIBSVTAV1 0)
endif()

# =============================================================================
# Line 7386: libsvtjpegxs
# =============================================================================
ffmpeg_option(LIBSVTJPEGXS "Enable SVT-JPEG-XS codec" ON)
if(ENABLE_LIBSVTJPEGXS)
    ffmpeg_require_pkg_config(libsvtjpegxs "SvtJpegxs >= 0.10.0" "SvtJpegxsEnc.h" "svt_jpeg_xs_encoder_init")
else()
    set(CONFIG_LIBSVTJPEGXS 0)
endif()

# =============================================================================
# Line 7387: libtensorflow
# =============================================================================
ffmpeg_option(LIBTENSORFLOW "Enable TensorFlow" ON)
if(ENABLE_LIBTENSORFLOW)
    ffmpeg_check_lib(libtensorflow "tensorflow/c/c_api.h" "TF_Version" "-ltensorflow")
    if(NOT CONFIG_LIBTENSORFLOW)
        message(STATUS "  libtensorflow: not found")
    endif()
else()
    set(CONFIG_LIBTENSORFLOW 0)
endif()

# =============================================================================
# Line 7388: libtesseract
# =============================================================================
ffmpeg_option(LIBTESSERACT "Enable Tesseract OCR" ON)
if(ENABLE_LIBTESSERACT)
    ffmpeg_require_pkg_config(libtesseract tesseract "tesseract/capi.h" "TessBaseAPICreate")
else()
    set(CONFIG_LIBTESSERACT 0)
endif()

# =============================================================================
# Line 7389: libtheora
# =============================================================================
ffmpeg_option(LIBTHEORA "Enable Theora codec" ON)
if(ENABLE_LIBTHEORA)
    set(CMAKE_REQUIRED_LIBRARIES "-ltheoraenc -ltheoradec -logg")
    check_include_file("theora/theoraenc.h" HAVE_THEORAENC_H)
    check_library_exists(theoraenc th_info_init "" HAVE_THEORA)
    if(HAVE_THEORAENC_H AND HAVE_THEORA)
        set(CONFIG_LIBTHEORA 1)
        set(LIBTHEORA_LIBRARIES "-ltheoraenc -ltheoradec -logg")
    else()
        message(STATUS "  libtheora: not found")
    endif()
else()
    set(CONFIG_LIBTHEORA 0)
endif()

# =============================================================================
# Line 7390: libtls
# =============================================================================
ffmpeg_option(LIBTLS "Enable LibreSSL" ON)
if(ENABLE_LIBTLS)
    ffmpeg_require_pkg_config(libtls libtls "tls.h" "tls_configure")
    if(CONFIG_LIBTLS)
        if(ENABLE_GPL AND NOT ENABLE_NONFREE)
            ffmpeg_lib_not_found(LIBTLS "LibreSSL is incompatible with the gpl")
        endif()
    endif()
else()
    set(CONFIG_LIBTLS 0)
endif()

# =============================================================================
# Line 7392: libtorch
# =============================================================================
ffmpeg_option(LIBTORCH "Enable PyTorch" ON)
if(ENABLE_LIBTORCH)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag("-std=c++17" HAVE_CXX17)
    if(HAVE_CXX17)
        set(CMAKE_CXX_STANDARD 17)
        set(CMAKE_REQUIRED_LIBRARIES "-ltorch -lc10 -ltorch_cpu -lstdc++ -lpthread")
        check_include_file("torch/torch.h" HAVE_TORCH_H)
        set(CMAKE_REQUIRED_FLAGS "-std=c++17")
        check_cxx_source_compiles("#include <torch/torch.h>
int main() { torch::Tensor t; return 0; }" HAVE_TORCH)
        if(HAVE_TORCH_H AND HAVE_TORCH)
            set(CONFIG_LIBTORCH 1)
            set(LIBTORCH_LIBRARIES "-ltorch -lc10 -ltorch_cpu -lstdc++ -lpthread")
        else()
            message(STATUS "  libtorch: not found")
        endif()
    else()
        message(STATUS "  libtorch: C++17 support required but not available")
        set(CONFIG_LIBTORCH 0)
    endif()
else()
    set(CONFIG_LIBTORCH 0)
endif()

# =============================================================================
# Line 7393: libtwolame
# =============================================================================
ffmpeg_option(LIBTWOLAME "Enable Twolame MP2 encoder" ON)
if(ENABLE_LIBTWOLAME)
    ffmpeg_check_lib(libtwolame "twolame.h" "twolame_init" "-ltwolame")
    if(CONFIG_LIBTWOLAME)
        # Check for twolame_encode_buffer_float32_interleaved (version >= 0.3.10)
        check_library_exists(twolame twolame_encode_buffer_float32_interleaved "" HAVE_TWOLAME_FLOAT32)
        if(NOT HAVE_TWOLAME_FLOAT32)
            message(STATUS "  libtwolame: version < 0.3.10, disabling")
            set(CONFIG_LIBTWOLAME 0)
        endif()
    else()
        message(STATUS "  libtwolame: not found")
    endif()
else()
    set(CONFIG_LIBTWOLAME 0)
endif()

# =============================================================================
# Line 7396: libuavs3d
# =============================================================================
ffmpeg_option(LIBUAVS3D "Enable uavs3d AVS3 decoder" ON)
if(ENABLE_LIBUAVS3D)
    ffmpeg_require_pkg_config(libuavs3d "uavs3d >= 1.1.41" "uavs3d.h" "uavs3d_decode")
else()
    set(CONFIG_LIBUAVS3D 0)
endif()

# =============================================================================
# Line 7397: libv4l2
# =============================================================================
ffmpeg_option(LIBV4L2 "Enable Video4Linux2" ON)
if(ENABLE_LIBV4L2)
    ffmpeg_require_pkg_config(libv4l2 libv4l2 "libv4l2.h" "v4l2_ioctl")
else()
    set(CONFIG_LIBV4L2 0)
endif()

# =============================================================================
# Line 7398: libvidstab
# =============================================================================
ffmpeg_option(LIBVIDSTAB "Enable vid.stab video stabilization" ON)
if(ENABLE_LIBVIDSTAB)
    ffmpeg_require_pkg_config(libvidstab "vidstab >= 0.98" "vid.stab/libvidstab.h" "vsMotionDetectInit")
else()
    set(CONFIG_LIBVIDSTAB 0)
endif()

# =============================================================================
# Line 7399: libvmaf
# =============================================================================
ffmpeg_option(LIBVMAF "Enable libvmaf video quality filter" ON)
if(ENABLE_LIBVMAF)
    ffmpeg_require_pkg_config(libvmaf "libvmaf >= 2.0.0" "libvmaf.h" "vmaf_init")
    # Also check for CUDA support
    ffmpeg_check_pkg_config(libvmaf_cuda "libvmaf >= 2.0.0" "libvmaf_cuda.h" "vmaf_cuda_state_init")
else()
    set(CONFIG_LIBVMAF 0)
endif()

# =============================================================================
# Line 7401: libvo_amrwbenc
# =============================================================================
ffmpeg_option(LIBVO_AMRWBENC "Enable vo-amrwbenc" ON)
if(ENABLE_LIBVO_AMRWBENC)
    ffmpeg_check_pkg_config(libvo_amrwbenc vo-amrwbenc "vo-amrwbenc/enc_if.h" "E_IF_init")
    if(NOT CONFIG_LIBVO_AMRWBENC)
        ffmpeg_check_lib(libvo_amrwbenc "vo-amrwbenc/enc_if.h" "E_IF_init" "-lvo-amrwbenc")
    endif()
else()
    set(CONFIG_LIBVO_AMRWBENC 0)
endif()

# =============================================================================
# Line 7403: libvorbis
# =============================================================================
ffmpeg_option(LIBVORBIS "Enable Vorbis codec" ON)
if(ENABLE_LIBVORBIS)
    ffmpeg_require_pkg_config(libvorbis vorbis "vorbis/codec.h" "vorbis_info_init")
    ffmpeg_require_pkg_config(libvorbisenc vorbisenc "vorbis/vorbisenc.h" "vorbis_encode_init")
else()
    set(CONFIG_LIBVORBIS 0)
    set(CONFIG_LIBVORBISENC 0)
endif()

# =============================================================================
# Line 7406: whisper
# =============================================================================
ffmpeg_option(WHISPER "Enable Whisper speech recognition" ON)
if(ENABLE_WHISPER)
    ffmpeg_require_pkg_config(whisper "whisper >= 1.7.5" "whisper.h" "whisper_init_from_file_with_params")
else()
    set(CONFIG_WHISPER 0)
endif()

# =============================================================================
# Line 7408: libvpx
# =============================================================================
ffmpeg_option(LIBVPX "Enable libvpx VP8/VP9 codec" ON)
FFmpegDetectLibvpx()

# =============================================================================
# Line 7430: libvvenc
# =============================================================================
ffmpeg_option(LIBVVENC "Enable libvvenc H.266/VVC encoder" ON)
if(ENABLE_LIBVVENC)
    ffmpeg_require_pkg_config(libvvenc "libvvenc >= 1.6.1" "vvenc/vvenc.h" "vvenc_get_version")
else()
    set(CONFIG_LIBVVENC 0)
endif()

# =============================================================================
# Line 7431: libwebp
# =============================================================================
ffmpeg_option(LIBWEBP "Enable WebP codec" ON)
if(ENABLE_LIBWEBP)
    ffmpeg_check_pkg_config(libwebp libwebp "webp/decode.h" "WebPDecodeRGB")
else()
    set(CONFIG_LIBWEBP 0)
endif()

# =============================================================================
# Line 7434: libx264
# =============================================================================
ffmpeg_option(LIBX264 "Enable x264 H.264 encoder" ON)
FFmpegDetectLibx264()

# =============================================================================
# Line 7440: libx265
# =============================================================================
ffmpeg_option(LIBX265 "Enable x265 HEVC encoder" ON)
if(ENABLE_LIBX265)
    ffmpeg_require_pkg_config(libx265 x265 "x265.h" "x265_api_get")
else()
    set(CONFIG_LIBX265 0)
endif()

# =============================================================================
# Line 7442: libxavs
# =============================================================================
ffmpeg_option(LIBXAVS "Enable xavs AVS encoder" ON)
if(ENABLE_LIBXAVS)
    set(CMAKE_REQUIRED_LIBRARIES "${PTHREAD_LIBRARY} ${MATH_LIBRARY}")
    ffmpeg_check_lib(libxavs "stdint.h xavs.h" "xavs_encoder_encode" "-lxavs")
    if(NOT CONFIG_LIBXAVS)
        message(STATUS "  libxavs: not found")
    endif()
else()
    set(CONFIG_LIBXAVS 0)
endif()

# =============================================================================
# Line 7443: libxavs2
# =============================================================================
ffmpeg_option(LIBXAVS2 "Enable xavs2 AVS2 encoder" ON)
if(ENABLE_LIBXAVS2)
    ffmpeg_require_pkg_config(libxavs2 "xavs2 >= 1.3.0" "stdint.h xavs2.h" "xavs2_api_get")
else()
    set(CONFIG_LIBXAVS2 0)
endif()

# =============================================================================
# Line 7444: libxevd
# =============================================================================
ffmpeg_option(LIBXEVD "Enable xevd MPEG-5 EVC decoder" ON)
if(ENABLE_LIBXEVD)
    ffmpeg_require_pkg_config(libxevd "xevd >= 0.4.1" "xevd.h" "xevd_decode")
else()
    set(CONFIG_LIBXEVD 0)
endif()

# =============================================================================
# Line 7445: libxevdb
# =============================================================================
ffmpeg_option(LIBXEVDB "Enable xevdb MPEG-5 EVC baseline decoder" ON)
if(ENABLE_LIBXEVDB)
    ffmpeg_require_pkg_config(libxevdb "xevdb >= 0.4.1" "xevd.h" "xevd_decode")
else()
    set(CONFIG_LIBXEVDB 0)
endif()

# =============================================================================
# Line 7446: libxeve
# =============================================================================
ffmpeg_option(LIBXEVE "Enable xeve MPEG-5 EVC encoder" ON)
if(ENABLE_LIBXEVE)
    ffmpeg_require_pkg_config(libxeve "xeve >= 0.5.1" "xeve.h" "xeve_encode")
else()
    set(CONFIG_LIBXEVE 0)
endif()

# =============================================================================
# Line 7447: libxeveb
# =============================================================================
ffmpeg_option(LIBXEVEB "Enable xeveb MPEG-5 EVC baseline encoder" ON)
if(ENABLE_LIBXEVEB)
    ffmpeg_require_pkg_config(libxeveb "xeveb >= 0.5.1" "xeve.h" "xeve_encode")
else()
    set(CONFIG_LIBXEVEB 0)
endif()

# =============================================================================
# Line 7448: libxvid
# =============================================================================
ffmpeg_option(LIBXVID "Enable Xvid encoder" ON)
if(ENABLE_LIBXVID)
    ffmpeg_check_lib(libxvid "xvid.h" "xvid_global" "-lxvidcore")
    if(NOT CONFIG_LIBXVID)
        message(STATUS "  libxvid: not found")
    endif()
else()
    set(CONFIG_LIBXVID 0)
endif()

# =============================================================================
# Line 7449: libzimg
# =============================================================================
ffmpeg_option(LIBZIMG "Enable zimg" ON)
if(ENABLE_LIBZIMG)
    ffmpeg_require_pkg_config(libzimg "zimg >= 2.7.0" "zimg.h" "zimg_get_api_version")
else()
    set(CONFIG_LIBZIMG 0)
endif()

# =============================================================================
# Line 7450: libzmq
# =============================================================================
ffmpeg_option(LIBZMQ "Enable ZeroMQ" ON)
if(ENABLE_LIBZMQ)
    ffmpeg_require_pkg_config(libzmq "libzmq >= 4.2.1" "zmq.h" "zmq_ctx_new")
else()
    set(CONFIG_LIBZMQ 0)
endif()

# =============================================================================
# Line 7451: libzvbi
# =============================================================================
ffmpeg_option(LIBZVBI "Enable zvbi teletext" ON)
if(ENABLE_LIBZVBI)
    ffmpeg_require_pkg_config(libzvbi zvbi-0.2 "libzvbi.h" "vbi_decoder_new")
else()
    set(CONFIG_LIBZVBI 0)
endif()

# =============================================================================
# Line 7454: libxml2
# =============================================================================
ffmpeg_option(LIBXML2 "Enable libxml2" ON)
if(ENABLE_LIBXML2)
    ffmpeg_require_pkg_config(libxml2 libxml-2.0 "libxml2/libxml/xmlversion.h" "xmlCheckVersion")
else()
    set(CONFIG_LIBXML2 0)
endif()

# =============================================================================
# Line 7459: mediacodec (Android)
# =============================================================================
ffmpeg_option(MEDIACODEC "Enable Android MediaCodec" ON)
if(ENABLE_MEDIACODEC)
    if(NOT ANDROID)
        message(STATUS "  mediacodec: not found (requires Android target)")
        set(CONFIG_MEDIACODEC 0)
    elseif(NOT ENABLE_JNI)
        message(STATUS "  mediacodec: disabled (requires JNI)")
        set(CONFIG_MEDIACODEC 0)
    else()
        set(CONFIG_MEDIACODEC 1)
    endif()
else()
    set(CONFIG_MEDIACODEC 0)
endif()

# =============================================================================
# Hardware Acceleration
# =============================================================================

# Video Acceleration API (VAAPI) - Linux
ffmpeg_option(VAAPI "Enable VAAPI (Linux)" ON)
FFmpegDetectVAAPI()

# VDPAU (NVIDIA) - Linux
ffmpeg_option(VDPAU "Enable VDPAU (Linux NVIDIA)" ON)
FFmpegDetectVDPAU()

# VideoToolbox - macOS
if(APPLE)
    option(ENABLE_VIDEOTOOLBOX "Enable VideoToolbox (macOS)" ON)
    if(ENABLE_VIDEOTOOLBOX)
        find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
        find_library(COREVIDEO_FRAMEWORK CoreVideo)
        if(VIDEOTOOLBOX_FRAMEWORK AND COREVIDEO_FRAMEWORK)
            set(CONFIG_VIDEOTOOLBOX 1)
        else()
            set(CONFIG_VIDEOTOOLBOX 0)
        endif()
    else()
        set(CONFIG_VIDEOTOOLBOX 0)
    endif()
    
    # AudioToolbox
    option(ENABLE_AUDIOTOOLBOX "Enable AudioToolbox (macOS)" ON)
    if(ENABLE_AUDIOTOOLBOX)
        find_library(AUDIOTOOLBOX_FRAMEWORK AudioToolbox)
        if(AUDIOTOOLBOX_FRAMEWORK)
            set(CONFIG_AUDIOTOOLBOX 1)
        else()
            set(CONFIG_AUDIOTOOLBOX 0)
        endif()
    else()
        set(CONFIG_AUDIOTOOLBOX 0)
    endif()
    
    # CoreImage
    option(ENABLE_COREIMAGE "Enable CoreImage (macOS)" ON)
    if(ENABLE_COREIMAGE)
        find_library(COREIMAGE_FRAMEWORK CoreImage)
        if(COREIMAGE_FRAMEWORK)
            set(CONFIG_COREIMAGE 1)
        else()
            set(CONFIG_COREIMAGE 0)
        endif()
    else()
        set(CONFIG_COREIMAGE 0)
    endif()
    
    # AppKit
    option(ENABLE_APPKIT "Enable AppKit (macOS)" ON)
    if(ENABLE_APPKIT)
        find_library(APPKIT_FRAMEWORK AppKit)
        if(APPKIT_FRAMEWORK)
            set(CONFIG_APPKIT 1)
        else()
            set(CONFIG_APPKIT 0)
        endif()
    else()
        set(CONFIG_APPKIT 0)
    endif()
    
    # AVFoundation
    option(ENABLE_AVFOUNDATION "Enable AVFoundation (macOS)" ON)
    if(ENABLE_AVFOUNDATION)
        find_library(AVFOUNDATION_FRAMEWORK AVFoundation)
        if(AVFOUNDATION_FRAMEWORK)
            set(CONFIG_AVFOUNDATION 1)
        else()
            set(CONFIG_AVFOUNDATION 0)
        endif()
    else()
        set(CONFIG_AVFOUNDATION 0)
    endif()
    
    # SecureTransport
    option(ENABLE_SECURETRANSPORT "Enable SecureTransport (macOS)" ON)
    if(ENABLE_SECURETRANSPORT)
        find_library(SECURITY_FRAMEWORK Security)
        if(SECURITY_FRAMEWORK)
            set(CONFIG_SECURETRANSPORT 1)
        else()
            set(CONFIG_SECURETRANSPORT 0)
        endif()
    else()
        set(CONFIG_SECURETRANSPORT 0)
    endif()
else()
    set(CONFIG_VIDEOTOOLBOX 0)
    set(CONFIG_AUDIOTOOLBOX 0)
    set(CONFIG_COREIMAGE 0)
    set(CONFIG_APPKIT 0)
    set(CONFIG_AVFOUNDATION 0)
    set(CONFIG_SECURETRANSPORT 0)
endif()

# Vulkan
ffmpeg_option(VULKAN "Enable Vulkan" ON)
FFmpegDetectVulkan()

# OpenCL
ffmpeg_option(OPENCL "Enable OpenCL" ON)
FFmpegDetectOpenCL()

# CUDA (NVIDIA)
ffmpeg_option(CUDA "Enable CUDA" ON)
ffmpeg_option(CUVID "Enable CUVID (CUDA video decoder)" ON)
ffmpeg_option(NVENC "Enable NVENC (NVIDIA encoder)" ON)
if(ENABLE_CUDA OR ENABLE_CUVID OR ENABLE_NVENC)
    find_package(CUDA QUIET)
    if(CUDA_FOUND)
        set(CONFIG_CUDA 1)
        if(ENABLE_CUVID)
            set(CONFIG_CUVID 1)
        endif()
        if(ENABLE_NVENC)
            set(CONFIG_NVENC 1)
        endif()
    else()
        set(CONFIG_CUDA 0)
        set(CONFIG_CUVID 0)
        set(CONFIG_NVENC 0)
    endif()
else()
    set(CONFIG_CUDA 0)
    set(CONFIG_CUVID 0)
    set(CONFIG_NVENC 0)
endif()

# AMF (AMD Advanced Media Framework)
ffmpeg_option(AMF "Enable AMF (AMD)" ON)
if(ENABLE_AMF)
    set(CONFIG_AMF 1)
else()
    set(CONFIG_AMF 0)
endif()

# Media Foundation (Windows)
if(WIN32)
    option(ENABLE_MEDIAFOUNDATION "Enable MediaFoundation (Windows)" ON)
    if(ENABLE_MEDIAFOUNDATION)
        set(CONFIG_MEDIAFOUNDATION 1)
    else()
        set(CONFIG_MEDIAFOUNDATION 0)
    endif()
else()
    set(CONFIG_MEDIAFOUNDATION 0)
endif()

# =============================================================================
# Execute all library detection
# =============================================================================

FFmpegDetectLibraries()

# =============================================================================
# Library Conflict Resolution (matching configure behavior)
# =============================================================================
# configure dies with error when conflicting libraries are both enabled
# We replicate that behavior here

# TLS library conflicts
if(CONFIG_GNUTLS AND CONFIG_OPENSSL)
    message(FATAL_ERROR "ERROR: GnuTLS and OpenSSL must not be enabled at the same time.")
endif()

if(CONFIG_GNUTLS AND CONFIG_MBEDTLS)
    message(FATAL_ERROR "ERROR: GnuTLS and mbedTLS must not be enabled at the same time.")
endif()

if(CONFIG_OPENSSL AND CONFIG_MBEDTLS)
    message(FATAL_ERROR "ERROR: OpenSSL and mbedTLS must not be enabled at the same time.")
endif()

# =============================================================================
# Detection summary will be printed after FFmpegDetectLibraries() is called
# See CMakeLists.txt after FFmpegDetectLibraries()
# =============================================================================
