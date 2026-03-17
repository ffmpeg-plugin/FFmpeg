# FFmpeg External Libraries Configuration
# Based on FFmpeg's configure script library detection
#
# This module uses FFmpegLibraryDetection.cmake to provide
# configure-compatible library detection

include(${CMAKE_SOURCE_DIR}/cmake/FFmpegLibraryDetection.cmake)

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

# Windows System Libraries
if(WIN32)
    # advapi32 (registry and security functions)
    check_library_exists(advapi32 RegCloseKey "" HAVE_LIBADVAPI32)
    if(HAVE_LIBADVAPI32)
        set(ADVAPI32_LIBRARY advapi32)
    endif()

    # bcrypt (cryptography)
    check_library_exists(bcrypt BCryptGenRandom "" HAVE_LIBBCRYPT)
    if(HAVE_LIBBCRYPT)
        set(BCRYPT_LIBRARY bcrypt)
    endif()

    # ole32 (COM/OLE)
    check_library_exists(ole32 CoTaskMemFree "" HAVE_LIBOLE32)
    if(HAVE_LIBOLE32)
        set(OLE32_LIBRARY ole32)
    endif()

    # shell32 (Shell API)
    check_library_exists(shell32 CommandLineToArgvW "" HAVE_LIBSHELL32)
    if(HAVE_LIBSHELL32)
        set(SHELL32_LIBRARY shell32)
    endif()

    # psapi (process info)
    check_library_exists(psapi GetProcessMemoryInfo "" HAVE_LIBPSAPI)
    if(HAVE_LIBPSAPI)
        set(PSAPI_LIBRARY psapi)
    endif()

    # user32 (windows and messages)
    check_library_exists(user32 GetShellWindow "" HAVE_LIBUSER32)
    if(HAVE_LIBUSER32)
        set(USER32_LIBRARY user32)
    endif()

    # vfw32 (video capture)
    check_library_exists(vfw32 capCreateCaptureWindow "" HAVE_LIBVFW32)
    if(HAVE_LIBVFW32)
        set(VFW32_LIBRARY vfw32)
    endif()

    # ws2_32 (Winsock2)
    check_library_exists(ws2_32 getaddrinfo "" HAVE_LIBWS2_32)
    if(HAVE_LIBWS2_32)
        set(WS2_32_LIBRARY ws2_32)
    endif()
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
# Compression Libraries
# =============================================================================

# libz (zlib)
option(ENABLE_ZLIB "Enable zlib compression" ON)
FFmpegDetectZlib()

# libbz2 (bzip2)
option(ENABLE_BZLIB "Enable bzip2 compression" ON)
FFmpegDetectBZip2()

# liblzma (xz)
option(ENABLE_LZMA "Enable LZMA compression" ON)
FFmpegDetectLZMA()

# =============================================================================
# Character Set / Encoding
# =============================================================================

# iconv
option(ENABLE_ICONV "Enable iconv character conversion" ON)
FFmpegDetectIconv()

# =============================================================================
# Encryption / Security
# =============================================================================

# OpenSSL
option(ENABLE_OPENSSL "Enable OpenSSL support" ON)
FFmpegDetectOpenSSL()

# GnuTLS (OpenSSL alternative)
option(ENABLE_GNUTLS "Enable GnuTLS support" OFF)
if(ENABLE_GNUTLS)
    ffmpeg_require_pkg_config(gnutls gnutls "gnutls/gnutls.h" "gnutls_global_init")
else()
    set(CONFIG_GNUTLS 0)
endif()

# =============================================================================
# Graphics / Windowing
# =============================================================================

# SDL2 (for ffplay)
option(ENABLE_SDL2 "Enable SDL2 support (for ffplay)" ON)
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
option(ENABLE_ALSA "Enable ALSA audio support" ON)
FFmpegDetectAlsa()

# PulseAudio
option(ENABLE_LIBPULSE "Enable PulseAudio support" ON)
FFmpegDetectPulseAudio()

# sndio (BSD)
option(ENABLE_SNDIO "Enable sndio audio support" OFF)
if(ENABLE_SNDIO)
    ffmpeg_check_lib(sndio "sndio.h" "sio_open" "-lsndio")
else()
    set(CONFIG_SNDIO 0)
endif()

# OpenAL
option(ENABLE_OPENAL "Enable OpenAL support" OFF)
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
# Video Codecs / Encoders
# =============================================================================

# x264 (H.264 encoder)
option(ENABLE_LIBX264 "Enable x264 H.264 encoder" ON)
FFmpegDetectLibx264()

# x265 (HEVC encoder)
option(ENABLE_LIBX265 "Enable x265 HEVC encoder" ON)
FFmpegDetectLibx265()

# libvpx (VP8/VP9)
option(ENABLE_LIBVPX "Enable libvpx VP8/VP9 codec" ON)
FFmpegDetectLibvpx()

# aom (AV1)
option(ENABLE_LIBAOM "Enable libaom AV1 codec" ON)
if(ENABLE_LIBAOM)
    ffmpeg_require_pkg_config(libaom "aom >= 2.0.0" "aom/aom_codec.h" "aom_codec_version")
else()
    set(CONFIG_LIBAOM 0)
endif()

# SVT-AV1
option(ENABLE_LIBSVTAV1 "Enable SVT-AV1 encoder" OFF)
if(ENABLE_LIBSVTAV1)
    ffmpeg_require_pkg_config(libsvtav1 "SvtAv1Enc >= 0.9.0" "EbSvtAv1Enc.h" "svt_av1_enc_init_handle")
else()
    set(CONFIG_LIBSVTAV1 0)
endif()

# rav1e
option(ENABLE_LIBRAV1E "Enable rav1e AV1 encoder" OFF)
if(ENABLE_LIBRAV1E)
    ffmpeg_require_pkg_config(librav1e "rav1e >= 0.5.0" "rav1e.h" "rav1e_context_new")
else()
    set(CONFIG_LIBRAV1E 0)
endif()

# dav1d decoder
option(ENABLE_LIBDAV1D "Enable dav1d AV1 decoder" ON)
if(ENABLE_LIBDAV1D)
    ffmpeg_require_pkg_config(libdav1d "dav1d >= 1.0.0" "dav1d/dav1d.h" "dav1d_version")
else()
    set(CONFIG_LIBDAV1D 0)
endif()

# =============================================================================
# Audio Codecs / Encoders
# =============================================================================

# Opus
option(ENABLE_LIBOPUS "Enable Opus codec" ON)
FFmpegDetectLibopus()

# MP3 (lame)
option(ENABLE_LIBMP3LAME "Enable MP3 encoding (lame)" ON)
FFmpegDetectLibmp3lame()

# FDK-AAC
option(ENABLE_LIBFDK_AAC "Enable FDK-AAC codec" OFF)
FFmpegDetectLibfdk_aac()

# Vorbis
option(ENABLE_LIBVORBIS "Enable Vorbis codec" ON)
FFmpegDetectLibvorbis()

# Theora
option(ENABLE_LIBTHEORA "Enable Theora codec" ON)
FFmpegDetectLibtheora()

# Speex
option(ENABLE_LIBSPEEX "Enable Speex codec" OFF)
FFmpegDetectLibspeex()

# Twolame
option(ENABLE_LIBTWOLAME "Enable Twolame MP2 encoder" OFF)
if(ENABLE_LIBTWOLAME)
    ffmpeg_check_lib(libtwolame "twolame.h" "twolame_init" "-ltwolame")
else()
    set(CONFIG_LIBTWOLAME 0)
endif()

# Shine (fixed-point MP3)
option(ENABLE_LIBSHINE "Enable Shine MP3 encoder" OFF)
if(ENABLE_LIBSHINE)
    ffmpeg_require_pkg_config(libshine shine "shine/layer3.h" "shine_encode_buffer")
else()
    set(CONFIG_LIBSHINE 0)
endif()

# SoX resampler
option(ENABLE_LIBSOXR "Enable SoX resampler" OFF)
if(ENABLE_LIBSOXR)
    ffmpeg_check_lib(libsoxr "soxr.h" "soxr_create" "-lsoxr")
else()
    set(CONFIG_LIBSOXR 0)
endif()

# GSM
option(ENABLE_LIBGSM "Enable GSM codec" OFF)
if(ENABLE_LIBGSM)
    # Try different header locations
    ffmpeg_check_lib(libgsm "gsm.h" "gsm_create" "-lgsm")
    if(NOT CONFIG_LIBGSM)
        ffmpeg_check_lib(libgsm "gsm/gsm.h" "gsm_create" "-lgsm")
    endif()
else()
    set(CONFIG_LIBGSM 0)
endif()

# ILBC
option(ENABLE_LIBILBC "Enable iLBC codec" OFF)
if(ENABLE_LIBILBC)
    ffmpeg_check_lib(libilbc "ilbc.h" "WebRtcIlbcfix_InitDecode" "-lilbc")
else()
    set(CONFIG_LIBILBC 0)
endif()

# OpenCORE AMR
option(ENABLE_LIBOPENCORE_AMRNB "Enable OpenCORE AMR-NB" OFF)
if(ENABLE_LIBOPENCORE_AMRNB)
    ffmpeg_check_pkg_config(libopencore_amrnb opencore-amrnb "opencore-amrnb/interf_dec.h" "Decoder_Interface_init")
else()
    set(CONFIG_LIBOPENCORE_AMRNB 0)
endif()

option(ENABLE_LIBOPENCORE_AMRWB "Enable OpenCORE AMR-WB" OFF)
if(ENABLE_LIBOPENCORE_AMRWB)
    ffmpeg_check_pkg_config(libopencore_amrwb opencore-amrwb "opencore-amrwb/dec_if.h" "D_IF_init")
else()
    set(CONFIG_LIBOPENCORE_AMRWB 0)
endif()

# Vo-amrwbenc
option(ENABLE_LIBVO_AMRWBENC "Enable vo-amrwbenc" OFF)
if(ENABLE_LIBVO_AMRWBENC)
    ffmpeg_check_pkg_config(libvo_amrwbenc vo-amrwbenc "vo-amrwbenc/enc_if.h" "E_IF_init")
else()
    set(CONFIG_LIBVO_AMRWBENC 0)
endif()

# Codec2
option(ENABLE_LIBCODEC2 "Enable Codec2" OFF)
if(ENABLE_LIBCODEC2)
    ffmpeg_check_lib(libcodec2 "codec2/codec2.h" "codec2_create" "-lcodec2")
else()
    set(CONFIG_LIBCODEC2 0)
endif()

# LC3
option(ENABLE_LIBLC3 "Enable LC3 codec" OFF)
if(ENABLE_LIBLC3)
    ffmpeg_require_pkg_config(liblc3 "lc3 >= 1.1.0" "lc3.h" "lc3_hr_setup_encoder")
else()
    set(CONFIG_LIBLC3 0)
endif()

# =============================================================================
# Additional Video Codecs
# =============================================================================

# libopenh264 (Cisco H.264)
option(ENABLE_LIBOPENH264 "Enable OpenH264" OFF)
if(ENABLE_LIBOPENH264)
    ffmpeg_check_pkg_config(libopenh264 "openh264 >= 1.3.0" "wels/codec_api.h" "WelsCreateDecoder")
else()
    set(CONFIG_LIBOPENH264 0)
endif()

# libkvazaar (HEVC encoder)
option(ENABLE_LIBKVAZAAR "Enable Kvazaar HEVC encoder" OFF)
if(ENABLE_LIBKVAZAAR)
    ffmpeg_require_pkg_config(libkvazaar "kvazaar >= 0.8.1" "kvazaar.h" "kvz_api_get")
else()
    set(CONFIG_LIBKVAZAAR 0)
endif()

# libsvtjpegxs (SVT-JPEG XS)
option(ENABLE_LIBSVTJPEGXS "Enable SVT-JPEG XS" OFF)
if(ENABLE_LIBSVTJPEGXS)
    ffmpeg_require_pkg_config(libsvtjpegxs "SvtJpegxs >= 0.9.0" "svt_jpegxs_api.h" "svt_jpegxs_decoder_init")
else()
    set(CONFIG_LIBSVTJPEGXS 0)
endif()

# libuavs3d (AVS3 decoder)
option(ENABLE_LIBUAVS3D "Enable AVS3 decoder" OFF)
if(ENABLE_LIBUAVS3D)
    ffmpeg_check_pkg_config(libuavs3d "uavs3d >= 1.0" "uavs3d.h" "uavs3d_create")
else()
    set(CONFIG_LIBUAVS3D 0)
endif()

# libvvenc (VVC encoder)
option(ENABLE_LIBVVENC "Enable VVC encoder" OFF)
if(ENABLE_LIBVVENC)
    ffmpeg_check_pkg_config(libvvenc "vvenc >= 1.6.0" "vvenc/vvenc.h" "vvenc_get_version")
else()
    set(CONFIG_LIBVVENC 0)
endif()

# libxavs (AVS encoder)
option(ENABLE_LIBXAVS "Enable xavs AVS encoder" OFF)
if(ENABLE_LIBXAVS)
    ffmpeg_check_lib(libxavs "xavs.h" "xavs_encoder_encode" "-lxavs" "-lm")
else()
    set(CONFIG_LIBXAVS 0)
endif()

# libxavs2 (AVS2 encoder)
option(ENABLE_LIBXAVS2 "Enable xavs2 AVS2 encoder" OFF)
if(ENABLE_LIBXAVS2)
    ffmpeg_check_lib(libxavs2 "xavs2.h" "xavs2_encoder_encode" "-lxavs2")
else()
    set(CONFIG_LIBXAVS2 0)
endif()

# libxevd (EVC decoder)
option(ENABLE_LIBXEVD "Enable xevd EVC decoder" OFF)
if(ENABLE_LIBXEVD)
    ffmpeg_check_lib(libxevd "xevd.h" "xevd_create" "-lxevd")
else()
    set(CONFIG_LIBXEVD 0)
endif()

# libxeve (EVC encoder)
option(ENABLE_LIBXEVE "Enable xeve EVC encoder" OFF)
if(ENABLE_LIBXEVE)
    ffmpeg_check_lib(libxeve "xeve.h" "xeve_create" "-lxeve")
else()
    set(CONFIG_LIBXEVE 0)
endif()

# liboapv (APV decoder)
option(ENABLE_LIBOAPV "Enable oapv APV decoder" OFF)
if(ENABLE_LIBOAPV)
    ffmpeg_check_pkg_config(liboapv "oapv >= 1.0" "oapv/oapv.h" "oapv_version")
else()
    set(CONFIG_LIBOAPV 0)
endif()

# liblcevc_dec (LCEVC decoder)
option(ENABLE_LIBLCEVC_DEC "Enable LCEVC decoder" OFF)
if(ENABLE_LIBLCEVC_DEC)
    ffmpeg_require_pkg_config(liblcevc_dec "lcevc_dec >= 3.0" "LCEVC/lcevc_dec.h" "LCEVC_GetVersion")
else()
    set(CONFIG_LIBLCEVC_DEC 0)
endif()

# =============================================================================
# Image Libraries
# =============================================================================

# WebP
option(ENABLE_LIBWEBP "Enable WebP codec" ON)
if(ENABLE_LIBWEBP)
    ffmpeg_check_pkg_config(libwebp libwebp "webp/decode.h" "WebPDecodeRGB")
else()
    set(CONFIG_LIBWEBP 0)
endif()

# JPEG XL
option(ENABLE_LIBJXL "Enable JPEG XL codec" OFF)
if(ENABLE_LIBJXL)
    ffmpeg_require_pkg_config(libjxl "libjxl >= 0.7.0" "jxl/decode.h" "JxlDecoderVersion")
    ffmpeg_require_pkg_config(libjxl_threads "libjxl_threads >= 0.7.0" "jxl/thread_parallel_runner.h" "JxlThreadParallelRunner")
else()
    set(CONFIG_LIBJXL 0)
endif()

# TIFF (disabled for most builds, often GPL issues)
option(ENABLE_LIBTIFF "Enable TIFF" OFF)
if(ENABLE_LIBTIFF)
    find_package(TIFF QUIET)
    if(TIFF_FOUND)
        set(CONFIG_LIBTIFF 1)
    else()
        ffmpeg_check_pkg_config(libtiff-4 libtiff-4 "tiff.h" "TIFFGetVersion")
    endif()
else()
    set(CONFIG_LIBTIFF 0)
endif()

# =============================================================================
# Subtitle / Font Libraries
# =============================================================================

# libass (ASS/SSA subtitles)
option(ENABLE_LIBASS "Enable libass subtitle rendering" ON)
FFmpegDetectLibass()

# FreeType
option(ENABLE_LIBFREETYPE "Enable FreeType" ON)
if(ENABLE_LIBFREETYPE)
    find_package(Freetype QUIET)
    if(Freetype_FOUND)
        set(CONFIG_LIBFREETYPE 1)
    else()
        ffmpeg_require_pkg_config(libfreetype freetype2 "ft2build.h FT_FREETYPE_H" "FT_Init_FreeType")
    endif()
else()
    set(CONFIG_LIBFREETYPE 0)
endif()

# Fontconfig
option(ENABLE_LIBFONTCONFIG "Enable Fontconfig" ON)
if(ENABLE_LIBFONTCONFIG)
    ffmpeg_require_pkg_config(libfontconfig fontconfig "fontconfig/fontconfig.h" "FcInit")
else()
    set(CONFIG_LIBFONTCONFIG 0)
endif()

# FriBidi
option(ENABLE_LIBFRIBIDI "Enable FriBidi bidirectional text" ON)
if(ENABLE_LIBFRIBIDI)
    ffmpeg_require_pkg_config(libfribidi fribidi "fribidi.h" "fribidi_version_info")
else()
    set(CONFIG_LIBFRIBIDI 0)
endif()

# HarfBuzz (font shaping)
option(ENABLE_LIBHARFBUZZ "Enable HarfBuzz" OFF)
if(ENABLE_LIBHARFBUZZ)
    ffmpeg_require_pkg_config(libharfbuzz harfbuzz "hb.h" "hb_buffer_create")
else()
    set(CONFIG_LIBHARFBUZZ 0)
endif()

# libxml2
option(ENABLE_LIBXML2 "Enable libxml2" ON)
FFmpegDetectLibxml2()

# libzvbi (VBI decoding)
option(ENABLE_LIBZVBI "Enable libzvbi" OFF)
if(ENABLE_LIBZVBI)
    ffmpeg_check_pkg_config(libzvbi zvbi-0.2 "libzvbi.h" "vbi_decoder_new")
else()
    set(CONFIG_LIBZVBI 0)
endif()

# libvmaf (Video Multi-Method Assessment Fusion)
option(ENABLE_LIBVMAF "Enable VMAF" OFF)
if(ENABLE_LIBVMAF)
    ffmpeg_check_pkg_config(libvmaf "libvmaf >= 2.0.0" "libvmaf.h" "vmaf_init")
else()
    set(CONFIG_LIBVMAF 0)
endif()

# libv4l2 (Video4Linux2)
option(ENABLE_LIBV4L2 "Enable libv4l2" OFF)
if(ENABLE_LIBV4L2)
    ffmpeg_check_pkg_config(libv4l2 libv4l2 "libv4l2.h" "v4l2_open")
else()
    set(CONFIG_LIBV4L2 0)
endif()

# =============================================================================
# Network / Protocol Libraries
# =============================================================================

# librtmp
option(ENABLE_LIBRTMP "Enable librtmp" OFF)
if(ENABLE_LIBRTMP)
    ffmpeg_require_pkg_config(librtmp librtmp "librtmp/rtmp.h" "RTMP_Socket")
else()
    set(CONFIG_LIBRTMP 0)
endif()

# libsrt (Secure Reliable Transport)
option(ENABLE_LIBSRT "Enable SRT support" OFF)
if(ENABLE_LIBSRT)
    ffmpeg_require_pkg_config(libsrt "srt >= 1.3.0" "srt/srt.h" "srt_socket")
else()
    set(CONFIG_LIBSRT 0)
endif()

# librist
option(ENABLE_LIBRIST "Enable RIST support" OFF)
if(ENABLE_LIBRIST)
    ffmpeg_require_pkg_config(librist "librist >= 0.2.7" "librist/librist.h" "rist_receiver_create")
else()
    set(CONFIG_LIBRIST 0)
endif()

# libssh / libssh2
option(ENABLE_LIBSSH "Enable SSH support" OFF)
if(ENABLE_LIBSSH)
    ffmpeg_require_pkg_config(libssh "libssh >= 0.6.0" "libssh/sftp.h" "sftp_init")
    if(NOT CONFIG_LIBSSH)
        ffmpeg_require_pkg_config(libssh2 libssh2 "libssh2.h" "libssh2_init")
    endif()
else()
    set(CONFIG_LIBSSH 0)
endif()

# cURL
option(ENABLE_LIBCURL "Enable libcurl" OFF)
if(ENABLE_LIBCURL)
    find_package(CURL QUIET)
    if(CURL_FOUND)
        set(CONFIG_LIBCURL 1)
    endif()
else()
    set(CONFIG_LIBCURL 0)
endif()

# ZeroMQ
option(ENABLE_LIBZMQ "Enable ZeroMQ" OFF)
if(ENABLE_LIBZMQ)
    ffmpeg_check_pkg_config(libzmq libzmq "zmq.h" "zmq_init")
else()
    set(CONFIG_LIBZMQ 0)
endif()

# RabbitMQ
option(ENABLE_LIBRABBITMQ "Enable RabbitMQ" OFF)
if(ENABLE_LIBRABBITMQ)
    ffmpeg_require_pkg_config(librabbitmq "librabbitmq >= 0.7.1" "amqp.h" "amqp_new_connection")
else()
    set(CONFIG_LIBRABBITMQ 0)
endif()

# =============================================================================
# Hardware Acceleration
# =============================================================================

# Video Acceleration API (VAAPI) - Linux
option(ENABLE_VAAPI "Enable VAAPI (Linux)" ON)
FFmpegDetectVAAPI()

# VDPAU (NVIDIA) - Linux
option(ENABLE_VDPAU "Enable VDPAU (Linux NVIDIA)" ON)
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
option(ENABLE_VULKAN "Enable Vulkan" OFF)
FFmpegDetectVulkan()

# OpenCL
option(ENABLE_OPENCL "Enable OpenCL" OFF)
FFmpegDetectOpenCL()

# CUDA (NVIDIA)
option(ENABLE_CUDA "Enable CUDA" OFF)
option(ENABLE_CUVID "Enable CUVID (CUDA video decoder)" OFF)
option(ENABLE_NVENC "Enable NVENC (NVIDIA encoder)" OFF)
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
option(ENABLE_AMF "Enable AMF (AMD)" OFF)
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

    # Direct3D 11 Video Acceleration
    option(ENABLE_D3D11VA "Enable D3D11VA (Windows)" ON)
    if(ENABLE_D3D11VA)
        check_include_file("d3d11.h" HAVE_D3D11_H)
        check_include_file("dxgi1_2.h" HAVE_DXGI1_2_H)
        if(HAVE_D3D11_H AND HAVE_DXGI1_2_H)
            set(CONFIG_D3D11VA 1)
        else()
            set(CONFIG_D3D11VA 0)
        endif()
    else()
        set(CONFIG_D3D11VA 0)
    endif()

    # Direct3D 12 Video Acceleration
    option(ENABLE_D3D12VA "Enable D3D12VA (Windows)" ON)
    if(ENABLE_D3D12VA)
        check_include_file("d3d12.h" HAVE_D3D12_H)
        check_include_file("d3d12video.h" HAVE_D3D12VIDEO_H)
        if(HAVE_D3D12_H AND HAVE_D3D12VIDEO_H)
            set(CONFIG_D3D12VA 1)
        else()
            set(CONFIG_D3D12VA 0)
        endif()
    else()
        set(CONFIG_D3D12VA 0)
    endif()

    # DXVA2 (DirectX Video Acceleration 2)
    option(ENABLE_DXVA2 "Enable DXVA2 (Windows)" ON)
    if(ENABLE_DXVA2)
        check_include_file("dxva2api.h" HAVE_DXVA2API_H)
        if(HAVE_DXVA2API_H)
            set(CONFIG_DXVA2 1)
        else()
            set(CONFIG_DXVA2 0)
        endif()
    else()
        set(CONFIG_DXVA2 0)
    endif()

    # NVIDIA CUDA/NVENC/NVDEC detection with ffnvcodec headers
    option(ENABLE_CUDA "Enable CUDA support" OFF)
    option(ENABLE_CUVID "Enable CUVID (NVIDIA decoder)" OFF)
    option(ENABLE_NVENC "Enable NVENC (NVIDIA encoder)" OFF)
    if(ENABLE_CUDA OR ENABLE_CUVID OR ENABLE_NVENC)
        find_package(CUDA QUIET)
        if(CUDA_FOUND)
            set(CONFIG_CUDA 1)
            # Check for ffnvcodec headers
            check_include_file("ffnvcodec/nvEncodeAPI.h" HAVE_FFNVCODEC_NVENCODEAPI_H)
            check_include_file("ffnvcodec/dynlink_cuda.h" HAVE_FFNVCODEC_DYNLINK_CUDA_H)
            check_include_file("ffnvcodec/dynlink_nvcuvid.h" HAVE_FFNVCODEC_DYNLINK_NVCUVID_H)

            if(ENABLE_CUVID AND HAVE_FFNVCODEC_DYNLINK_NVCUVID_H)
                set(CONFIG_CUVID 1)
            else()
                set(CONFIG_CUVID 0)
            endif()

            if(ENABLE_NVENC AND HAVE_FFNVCODEC_NVENCODEAPI_H)
                set(CONFIG_NVENC 1)
            else()
                set(CONFIG_NVENC 0)
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
else()
    set(CONFIG_MEDIAFOUNDATION 0)
    set(CONFIG_D3D11VA 0)
    set(CONFIG_D3D12VA 0)
    set(CONFIG_DXVA2 0)
    set(CONFIG_CUDA 0)
    set(CONFIG_CUVID 0)
    set(CONFIG_NVENC 0)
endif()

# libdrm (Linux)
option(ENABLE_LIBDRM "Enable libdrm (Linux)" ON)
if(ENABLE_LIBDRM AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
    ffmpeg_check_pkg_config(libdrm libdrm "xf86drm.h" "drmGetVersion")
else()
    set(CONFIG_LIBDRM 0)
endif()

# V4L2 M2M (Linux)
option(ENABLE_V4L2_M2M "Enable V4L2 mem2mem (Linux)" ON)
if(ENABLE_V4L2_M2M AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
    check_include_file("linux/videodev2.h" HAVE_LINUX_VIDEODEV2_H)
    if(HAVE_LINUX_VIDEODEV2_H)
        set(CONFIG_V4L2_M2M 1)
    else()
        set(CONFIG_V4L2_M2M 0)
    endif()
else()
    set(CONFIG_V4L2_M2M 0)
endif()

# =============================================================================
# Media Container / Format Libraries
# =============================================================================

# libbluray
option(ENABLE_LIBBLURAY "Enable libbluray" ON)
FFmpegDetectLibbluray()

# libdvdnav
option(ENABLE_LIBDVDNAV "Enable libdvdnav" OFF)
if(ENABLE_LIBDVDNAV)
    ffmpeg_require_pkg_config(libdvdnav "dvdnav >= 6.1.0" "dvdnav/dvdnav.h" "dvdnav_open2")
else()
    set(CONFIG_LIBDVDNAV 0)
endif()

# libdvdread
option(ENABLE_LIBDVDREAD "Enable libdvdread" OFF)
if(ENABLE_LIBDVDREAD)
    ffmpeg_require_pkg_config(libdvdread "dvdread >= 6.1.1" "dvdread/dvd_reader.h" "DVDOpen2")
else()
    set(CONFIG_LIBDVDREAD 0)
endif()

# Chromaprint
option(ENABLE_CHROMAPRINT "Enable Chromaprint" OFF)
if(ENABLE_CHROMAPRINT)
    ffmpeg_check_pkg_config(chromaprint libchromaprint "chromaprint.h" "chromaprint_get_version")
else()
    set(CONFIG_CHROMAPRINT 0)
endif()

# =============================================================================
# Filter / Effect Libraries
# =============================================================================

# frei0r
option(ENABLE_FREI0R "Enable frei0r" OFF)
if(ENABLE_FREI0R)
    check_include_file("frei0r.h" HAVE_FREI0R_H)
    if(HAVE_FREI0R_H)
        set(CONFIG_FREI0R 1)
    else()
        set(CONFIG_FREI0R 0)
    endif()
else()
    set(CONFIG_FREI0R 0)
endif()

# ladspa
option(ENABLE_LADSPA "Enable LADSPA" OFF)
if(ENABLE_LADSPA)
    check_include_files("ladspa.h;dlfcn.h" HAVE_LADSPA_H)
    if(HAVE_LADSPA_H)
        set(CONFIG_LADSPA 1)
    else()
        set(CONFIG_LADSPA 0)
    endif()
else()
    set(CONFIG_LADSPA 0)
endif()

# lv2
option(ENABLE_LV2 "Enable LV2" OFF)
if(ENABLE_LV2)
    ffmpeg_require_pkg_config(lv2 lilv-0 "lilv/lilv.h" "lilv_world_new")
else()
    set(CONFIG_LV2 0)
endif()

# vidstab
option(ENABLE_LIBVIDSTAB "Enable vid.stab" OFF)
if(ENABLE_LIBVIDSTAB)
    ffmpeg_require_pkg_config(libvidstab "vidstab >= 0.98" "vid.stab/libvidstab.h" "vsMotionDetectInit")
else()
    set(CONFIG_LIBVIDSTAB 0)
endif()

# zimg
option(ENABLE_LIBZIMG "Enable zimg" OFF)
if(ENABLE_LIBZIMG)
    ffmpeg_check_pkg_config(libzimg zimg "zimg.h" "zimg_filter_graph_build")
else()
    set(CONFIG_LIBZIMG 0)
endif()

# snappy
option(ENABLE_LIBSNAPPY "Enable snappy" OFF)
if(ENABLE_LIBSNAPPY)
    ffmpeg_check_lib(libsnappy "snappy-c.h" "snappy_compress" "-lsnappy" "-lstdc++")
else()
    set(CONFIG_LIBSNAPPY 0)
endif()

# rubberband
option(ENABLE_LIBRUBBERBAND "Enable rubberband" OFF)
if(ENABLE_LIBRUBBERBAND)
    ffmpeg_require_pkg_config(librubberband "rubberband >= 1.8.1" "rubberband/rubberband-c.h" "rubberband_new")
    if(CONFIG_LIBRUBBERBAND)
        set(librubberband_extralibs "-lstdc++")
    endif()
else()
    set(CONFIG_LIBRUBBERBAND 0)
endif()

# =============================================================================
# Machine Learning / Special Libraries
# =============================================================================

# TensorFlow
option(ENABLE_LIBTENSORFLOW "Enable TensorFlow" OFF)
if(ENABLE_LIBTENSORFLOW)
    ffmpeg_check_lib(libtensorflow "tensorflow/c/c_api.h" "TF_Version" "-ltensorflow")
else()
    set(CONFIG_LIBTENSORFLOW 0)
endif()

# Tesseract OCR
option(ENABLE_LIBTESSERACT "Enable Tesseract OCR" OFF)
if(ENABLE_LIBTESSERACT)
    ffmpeg_require_pkg_config(libtesseract tesseract "tesseract/capi.h" "TessBaseAPICreate")
else()
    set(CONFIG_LIBTESSERACT 0)
endif()

# =============================================================================
# Additional Audio Libraries
# =============================================================================

# libjack (JACK Audio Connection Kit)
option(ENABLE_LIBJACK "Enable JACK audio support" OFF)
if(ENABLE_LIBJACK)
    ffmpeg_check_pkg_config(libjack jack "jack/jack.h" "jack_client_open")
else()
    set(CONFIG_LIBJACK 0)
endif()

# libopenal (OpenAL 3D audio)
option(ENABLE_OPENAL "Enable OpenAL support" OFF)
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

# libmodplug (module music)
option(ENABLE_LIBMODPLUG "Enable ModPlug support" OFF)
if(ENABLE_LIBMODPLUG)
    ffmpeg_check_lib(libmodplug "libmodplug/modplug.h" "ModPlug_Load" "-lmodplug" "-lstdc++")
else()
    set(CONFIG_LIBMODPLUG 0)
endif()

# libopenmpt (module music)
option(ENABLE_LIBOPENMPT "Enable OpenMPT support" OFF)
if(ENABLE_LIBOPENMPT)
    ffmpeg_require_pkg_config(libopenmpt "libopenmpt >= 0.2.6557" "libopenmpt/libopenmpt.h" "openmpt_module_create")
else()
    set(CONFIG_LIBOPENMPT 0)
endif()

# libgme (Game Music Emu)
option(ENABLE_LIBGME "Enable Game Music Emu" OFF)
if(ENABLE_LIBGME)
    ffmpeg_check_lib(libgme "gme/gme.h" "gme_open_file" "-lgme" "-lstdc++")
else()
    set(CONFIG_LIBGME 0)
endif()

# libiec61883 (Firewire DV)
option(ENABLE_LIBIEC61883 "Enable IEC 61883 support" OFF)
if(ENABLE_LIBIEC61883)
    ffmpeg_check_pkg_config(libiec61883 libiec61883 "libiec61883/iec61883.h" "iec61883_cmp_connect")
else()
    set(CONFIG_LIBIEC61883 0)
endif()

# libdc1394 (Firewire camera)
option(ENABLE_LIBDC1394 "Enable libdc1394 support" OFF)
if(ENABLE_LIBDC1394)
    ffmpeg_check_pkg_config(libdc1394 "libdc1394-2 >= 2.2.3" "dc1394/dc1394.h" "dc1394_new")
else()
    set(CONFIG_LIBDC1394 0)
endif()

# libflite (speech synthesis)
option(ENABLE_LIBFLITE "Enable Flite speech synthesis" OFF)
if(ENABLE_LIBFLITE)
    ffmpeg_check_lib(libflite "flite/flite.h" "flite_init" "-lflite" "-lflite_cmulex" "-lflite_usenglish")
else()
    set(CONFIG_LIBFLITE 0)
endif()

# libcaca (ASCII art)
option(ENABLE_LIBCACA "Enable libcaca" OFF)
if(ENABLE_LIBCACA)
    ffmpeg_check_pkg_config(libcaca caca "caca.h" "caca_create_canvas")
else()
    set(CONFIG_LIBCACA 0)
endif()

# libbs2b (Bauer stereo to binaural)
option(ENABLE_LIBBS2B "Enable libbs2b" OFF)
if(ENABLE_LIBBS2B)
    ffmpeg_check_pkg_config(libbs2b "libbs2b >= 3.0.0" "bs2b.h" "bs2b_open")
else()
    set(CONFIG_LIBBS2B 0)
endif()

# libmysofa (SOFA HRTF)
option(ENABLE_LIBMYSOFA "Enable libmysofa" OFF)
if(ENABLE_LIBMYSOFA)
    ffmpeg_check_pkg_config(libmysofa "libmysofa >= 0.6" "mysofa.h" "mysofa_load")
else()
    set(CONFIG_LIBMYSOFA 0)
endif()

# libklvanc (KLV ANC data)
option(ENABLE_LIBKLVANC "Enable libklvanc" OFF)
if(ENABLE_LIBKLVANC)
    ffmpeg_check_pkg_config(libklvanc "libklvanc >= 1.4.0" "libklvanc/vanc-lines.h" "klvanc_context_create")
else()
    set(CONFIG_LIBKLVANC 0)
endif()

# =============================================================================
# ARIB Subtitle Libraries
# =============================================================================

# libaribb24 (ARIB STD-B24 subtitles)
option(ENABLE_LIBARIBB24 "Enable ARIBb24 subtitles" OFF)
if(ENABLE_LIBARIBB24)
    ffmpeg_require_pkg_config(libaribb24 "aribb24 >= 1.0.3" "aribb24/aribb24.h" "arib_instance_new")
else()
    set(CONFIG_LIBARIBB24 0)
endif()

# libaribcaption (ARIB caption)
option(ENABLE_LIBARIBCAPTION "Enable ARIB caption" OFF)
if(ENABLE_LIBARIBCAPTION)
    ffmpeg_require_pkg_config(libaribcaption "aribcaption >= 1.1.1" "aribcaption/decoder.hpp" "aribcaption::Decoder")
else()
    set(CONFIG_LIBARIBCAPTION 0)
endif()

# =============================================================================
# Additional Video/Image Libraries
# =============================================================================

# libplacebo (GPU-accelerated video rendering)
option(ENABLE_LIBPLACEBO "Enable libplacebo" OFF)
if(ENABLE_LIBPLACEBO)
    ffmpeg_require_pkg_config(libplacebo "libplacebo >= 4.192.0" "libplacebo/vulkan.h" "pl_vulkan_create")
else()
    set(CONFIG_LIBPLACEBO 0)
endif()

# libqrencode (QR code generation)
option(ENABLE_LIBQRENCODE "Enable QR code encoding" OFF)
if(ENABLE_LIBQRENCODE)
    ffmpeg_check_pkg_config(libqrencode libqrencode "qrencode.h" "QRcode_encodeString")
else()
    set(CONFIG_LIBQRENCODE 0)
endif()

# libquirc (QR code decoding)
option(ENABLE_LIBQUIRC "Enable QR code decoding" OFF)
if(ENABLE_LIBQUIRC)
    ffmpeg_check_lib(libquirc "quirc.h" "quirc_new" "-lquirc")
else()
    set(CONFIG_LIBQUIRC 0)
endif()

# libopencv (OpenCV computer vision)
option(ENABLE_LIBOPENCV "Enable OpenCV" OFF)
if(ENABLE_LIBOPENCV)
    find_package(OpenCV QUIET)
    if(OpenCV_FOUND)
        set(CONFIG_LIBOPENCV 1)
    else()
        ffmpeg_check_pkg_config(libopencv opencv4 "opencv2/core/core_c.h" "cvCreateImage")
    endif()
else()
    set(CONFIG_LIBOPENCV 0)
endif()

# libopencolorio (color management)
option(ENABLE_LIBOPENCOLORIO "Enable OpenColorIO" OFF)
if(ENABLE_LIBOPENCOLORIO)
    ffmpeg_check_pkg_config(libopencolorio "OpenColorIO >= 2.0" "OpenColorIO/OpenColorIO.h" "OpenColorIO::GetVersion")
else()
    set(CONFIG_LIBOPENCOLORIO 0)
endif()

# librsvg (SVG rendering)
option(ENABLE_LIBRSVG "Enable SVG rendering" OFF)
if(ENABLE_LIBRSVG)
    ffmpeg_require_pkg_config(librsvg "librsvg-2.0 >= 2.50.0" "librsvg/rsvg.h" "rsvg_handle_new_from_data")
else()
    set(CONFIG_LIBRSVG 0)
endif()

# lcms2 (Little CMS color management)
option(ENABLE_LCMS2 "Enable Little CMS" OFF)
if(ENABLE_LCMS2)
    ffmpeg_check_pkg_config(lcms2 "lcms2 >= 2.6" "lcms2.h" "cmsOpenProfileFromMem")
else()
    set(CONFIG_LCMS2 0)
endif()

# cairo (2D graphics)
option(ENABLE_CAIRO "Enable Cairo" OFF)
if(ENABLE_CAIRO)
    find_package(Cairo QUIET)
    if(Cairo_FOUND)
        set(CONFIG_CAIRO 1)
    else()
        ffmpeg_check_pkg_config(cairo cairo "cairo.h" "cairo_create")
    endif()
else()
    set(CONFIG_CAIRO 0)
endif()

# libcdio (CD access)
option(ENABLE_LIBCDIO "Enable libcdio" OFF)
if(ENABLE_LIBCDIO)
    ffmpeg_check_pkg_config(libcdio "libcdio >= 2.1.0" "cdio/cdio.h" "cdio_open")
else()
    set(CONFIG_LIBCDIO 0)
endif()

# chromaprint (audio fingerprinting)
option(ENABLE_CHROMAPRINT "Enable Chromaprint" OFF)
if(ENABLE_CHROMAPRINT)
    ffmpeg_check_pkg_config(chromaprint libchromaprint "chromaprint.h" "chromaprint_get_version")
else()
    set(CONFIG_CHROMAPRINT 0)
endif()

# =============================================================================
# Speech Recognition
# =============================================================================

# pocketsphinx
option(ENABLE_POCKETSPHINX "Enable PocketSphinx" OFF)
if(ENABLE_POCKETSPHINX)
    ffmpeg_require_pkg_config(pocketsphinx "pocketsphinx >= 5.0" "pocketsphinx.h" "ps_init")
else()
    set(CONFIG_POCKETSPHINX 0)
endif()

# whisper.cpp
option(ENABLE_WHISPER "Enable Whisper" OFF)
if(ENABLE_WHISPER)
    ffmpeg_check_lib(whisper "whisper.h" "whisper_init_from_file" "-lwhisper")
else()
    set(CONFIG_WHISPER 0)
endif()

# =============================================================================
# Network / Protocol Libraries
# =============================================================================

# libsmbclient (Samba)
option(ENABLE_LIBSMBCLIENT "Enable Samba client" OFF)
if(ENABLE_LIBSMBCLIENT)
    ffmpeg_check_pkg_config(libsmbclient smbclient "libsmbclient.h" "smbc_init")
else()
    set(CONFIG_LIBSMBCLIENT 0)
endif()

# libtls (LibreTLS)
option(ENABLE_LIBTLS "Enable LibreTLS" OFF)
if(ENABLE_LIBTLS)
    ffmpeg_check_pkg_config(libtls libtls "tls.h" "tls_init")
else()
    set(CONFIG_LIBTLS 0)
endif()

# gmp (GNU Multiple Precision Arithmetic)
option(ENABLE_GMP "Enable GMP" OFF)
if(ENABLE_GMP)
    ffmpeg_check_pkg_config(gmp gmp "gmp.h" "__gmpz_init")
else()
    set(CONFIG_GMP 0)
endif()

# gcrypt (GNU crypto)
option(ENABLE_GCRYPT "Enable gcrypt" OFF)
if(ENABLE_GCRYPT)
    ffmpeg_check_pkg_config(gcrypt libgcrypt "gcrypt.h" "gcry_check_version")
else()
    set(CONFIG_GCRYPT 0)
endif()

# =============================================================================
# Hardware Acceleration Libraries
# =============================================================================

# Intel Media SDK (libmfx)
option(ENABLE_LIBMFX "Enable Intel Media SDK" OFF)
if(ENABLE_LIBMFX)
    ffmpeg_check_pkg_config(libmfx "mfx >= 1.28" "mfx/mfxvideo.h" "MFXInit")
else()
    set(CONFIG_LIBMFX 0)
endif()

# Intel VPL (libvpl)
option(ENABLE_LIBVPL "Enable Intel VPL" OFF)
if(ENABLE_LIBVPL)
    ffmpeg_check_pkg_config(libvpl "vpl >= 2.6" "vpl/mfxvideo.h" "MFXLoad")
else()
    set(CONFIG_LIBVPL 0)
endif()

# NVIDIA NPP (Performance Primitives)
option(ENABLE_LIBNPP "Enable NVIDIA NPP" OFF)
if(ENABLE_LIBNPP AND ENABLE_CUDA)
    check_include_file("npp.h" HAVE_NPP_H)
    if(HAVE_NPP_H)
        set(CONFIG_LIBNPP 1)
    else()
        set(CONFIG_LIBNPP 0)
    endif()
else()
    set(CONFIG_LIBNPP 0)
endif()

# MMAL (Broadcom Multi-Media Abstraction Layer)
option(ENABLE_MMAL "Enable MMAL (Raspberry Pi)" OFF)
if(ENABLE_MMAL)
    ffmpeg_check_pkg_config(mmal mmal "interface/mmal/mmal.h" "mmal_port_connect")
else()
    set(CONFIG_MMAL 0)
endif()

# OpenMAX (OMX)
option(ENABLE_OMX "Enable OpenMAX" OFF)
if(ENABLE_OMX)
    ffmpeg_check_pkg_config(omx ilclient "IL/OMX_Core.h" "OMX_Init")
else()
    set(CONFIG_OMX 0)
endif()

# AMF (AMD Advanced Media Framework)
option(ENABLE_AMF "Enable AMF (AMD)" OFF)
if(ENABLE_AMF)
    set(CONFIG_AMF 1)
else()
    set(CONFIG_AMF 0)
endif()

# rkmpp (Rockchip MPP)
option(ENABLE_RKMPP "Enable Rockchip MPP" OFF)
if(ENABLE_RKMPP)
    ffmpeg_check_pkg_config(rkmpp rockchip_mpp "rockchip/rk_mpi.h" "mpp_create")
else()
    set(CONFIG_RKMPP 0)
endif()

# mediacodec (Android)
if(ANDROID)
    option(ENABLE_MEDIACODEC "Enable Android MediaCodec" ON)
    if(ENABLE_MEDIACODEC)
        set(CONFIG_MEDIACODEC 1)
    else()
        set(CONFIG_MEDIACODEC 0)
    endif()
else()
    set(CONFIG_MEDIACODEC 0)
endif()

# OpenHarmony codec
option(ENABLE_OHCODEC "Enable OpenHarmony codec" OFF)
if(ENABLE_OHCODEC)
    check_library_exists(ohcodec OH_VideoDecoder_Create "" HAVE_OHCODEC)
    if(HAVE_OHCODEC)
        set(CONFIG_OHCODEC 1)
    else()
        set(CONFIG_OHCODEC 0)
    endif()
else()
    set(CONFIG_OHCODEC 0)
endif()

# Handle mutually exclusive Intel libraries
ffmpeg_disable_exclusive(libmfx libvpl)

# =============================================================================
# Print detection summary
# =============================================================================

FFmpegPrintLibrarySummary()
