# FFmpeg Apply External Libraries to Targets
# Centralized handling of external library includes and links
# This avoids scattering target_include_directories/target_link_libraries across lib directories
#
# This module should be included AFTER all add_subdirectory() calls so that all targets exist

# =============================================================================
# Helper: Apply include directories and libraries to a target if library is enabled
# =============================================================================
function(_ffmpeg_apply_lib_to_target lib_name target_name)
    string(TOUPPER "${lib_name}" lib_upper)
    string(TOLOWER "${lib_name}" lib_lower)
    
    if(NOT TARGET ${target_name})
        return()
    endif()
    
    if(NOT CONFIG_${lib_upper})
        return()
    endif()
    
    # Handle different variable naming conventions
    set(inc_dirs "")
    set(link_libs "")
    
    # Check various possible variable names for include directories
    if(DEFINED ${lib_upper}_INCLUDE_DIRS)
        set(inc_dirs ${${lib_upper}_INCLUDE_DIRS})
    elseif(DEFINED ${lib_upper}_INCLUDE_DIR)
        set(inc_dirs ${${lib_upper}_INCLUDE_DIR})
    elseif(DEFINED PC_${lib_upper}_INCLUDE_DIRS)
        set(inc_dirs ${PC_${lib_upper}_INCLUDE_DIRS})
    elseif(DEFINED ${lib_lower}_include_dirs)
        set(inc_dirs ${${lib_lower}_include_dirs})
    elseif(DEFINED ${lib_lower}_incdir)
        set(inc_dirs ${${lib_lower}_incdir})
    endif()
    
    # Check various possible variable names for libraries
    if(DEFINED ${lib_upper}_LIBRARIES)
        set(link_libs ${${lib_upper}_LIBRARIES})
    elseif(DEFINED ${lib_upper}_LIBRARY)
        set(link_libs ${${lib_upper}_LIBRARY})
    elseif(DEFINED ${lib_upper}_LIBS)
        set(link_libs ${${lib_upper}_LIBS})
    elseif(DEFINED PC_${lib_upper}_LIBRARIES)
        set(link_libs ${PC_${lib_upper}_LIBRARIES})
    elseif(DEFINED PC_${lib_upper}_LDFLAGS)
        set(link_libs ${PC_${lib_upper}_LDFLAGS})
    elseif(DEFINED ${lib_lower}_extralibs)
        set(link_libs ${${lib_lower}_extralibs})
    elseif(DEFINED ${lib_lower}_libraries)
        set(link_libs ${${lib_lower}_libraries})
    endif()
    
    # Apply include directories
    if(inc_dirs)
        target_include_directories(${target_name} PRIVATE ${inc_dirs})
    endif()
    
    # Apply link directories (needed for libraries in non-standard paths)
    set(link_dirs "")
    if(DEFINED PC_${lib_upper}_LIBRARY_DIRS)
        set(link_dirs ${PC_${lib_upper}_LIBRARY_DIRS})
    elseif(DEFINED ${lib_upper}_LIBRARY_DIRS)
        set(link_dirs ${${lib_upper}_LIBRARY_DIRS})
    endif()
    if(link_dirs)
        target_link_directories(${target_name} PUBLIC ${link_dirs})
    endif()
    
    # Apply link libraries
    # Use PUBLIC so that when executables link against this static library,
    # the external dependencies are automatically propagated
    if(link_libs)
        target_link_libraries(${target_name} PUBLIC ${link_libs})
    endif()
endfunction()

# =============================================================================
# Apply all external libraries to their respective targets
# Called once after all add_subdirectory() calls
# =============================================================================
function(ffmpeg_apply_external_libs)
    message(STATUS "Applying external library configurations to targets...")
    
    # -------------------------------------------------------------------------
    # Libraries linked to avcodec
    # -------------------------------------------------------------------------
    if(TARGET avcodec)
        _ffmpeg_apply_lib_to_target(LCMS2 avcodec)
        _ffmpeg_apply_lib_to_target(LIBX264 avcodec)
        _ffmpeg_apply_lib_to_target(LIBX265 avcodec)
        _ffmpeg_apply_lib_to_target(LIBVPX avcodec)
        _ffmpeg_apply_lib_to_target(LIBOPUS avcodec)
        _ffmpeg_apply_lib_to_target(LIBAOM avcodec)
        _ffmpeg_apply_lib_to_target(LIBDAV1D avcodec)
        _ffmpeg_apply_lib_to_target(LIBSPEEX avcodec)
        _ffmpeg_apply_lib_to_target(LIBTHEORA avcodec)
        _ffmpeg_apply_lib_to_target(LIBVORBIS avcodec)
        _ffmpeg_apply_lib_to_target(LIBVORBISENC avcodec)
        _ffmpeg_apply_lib_to_target(LIBWEBP avcodec)
        _ffmpeg_apply_lib_to_target(LIBWEBP_ANIM_ENCODER avcodec)
        _ffmpeg_apply_lib_to_target(LIBSHINE avcodec)
        _ffmpeg_apply_lib_to_target(LIBTWOLAME avcodec)
        _ffmpeg_apply_lib_to_target(LIBOPENJPEG avcodec)
        _ffmpeg_apply_lib_to_target(LIBOPENH264 avcodec)
        _ffmpeg_apply_lib_to_target(LIBOPENCORE_AMRNB avcodec)
        _ffmpeg_apply_lib_to_target(LIBOPENCORE_AMRWB avcodec)
        _ffmpeg_apply_lib_to_target(LIBVO_AMRWBENC avcodec)
        _ffmpeg_apply_lib_to_target(LIBVO_AACENC avcodec)
        _ffmpeg_apply_lib_to_target(LIBWAVPACK avcodec)
        _ffmpeg_apply_lib_to_target(LIBCELT avcodec)
        _ffmpeg_apply_lib_to_target(LIBSVTAV1 avcodec)
        _ffmpeg_apply_lib_to_target(LIBSVTJPEGXS avcodec)
        _ffmpeg_apply_lib_to_target(LIBXAVS avcodec)
        _ffmpeg_apply_lib_to_target(LIBXAVS2 avcodec)
        _ffmpeg_apply_lib_to_target(LIBXVID avcodec)
        _ffmpeg_apply_lib_to_target(LIBXEVD avcodec)
        _ffmpeg_apply_lib_to_target(LIBXEVDB avcodec)
        _ffmpeg_apply_lib_to_target(LIBXEVE avcodec)
        _ffmpeg_apply_lib_to_target(LIBXEVEB avcodec)
        _ffmpeg_apply_lib_to_target(LIBAOM avcodec)
        _ffmpeg_apply_lib_to_target(RAV1E avcodec)
        _ffmpeg_apply_lib_to_target(LIBRAV1E avcodec)
        _ffmpeg_apply_lib_to_target(SVTAV1 avcodec)
        _ffmpeg_apply_lib_to_target(SNAPPY avcodec)
        _ffmpeg_apply_lib_to_target(LCEVC_DEC avcodec)
        _ffmpeg_apply_lib_to_target(LIBLCEVC_DEC avcodec)
        _ffmpeg_apply_lib_to_target(LIBJXL avcodec)
        _ffmpeg_apply_lib_to_target(LIBJXL_THREADS avcodec)
        _ffmpeg_apply_lib_to_target(LIBLC3 avcodec)
        _ffmpeg_apply_lib_to_target(LIBARIBB24 avcodec)
        _ffmpeg_apply_lib_to_target(LIBARIBCAPTION avcodec)
        _ffmpeg_apply_lib_to_target(LIBDAVS2 avcodec)
        _ffmpeg_apply_lib_to_target(LIBMPEGHDEC avcodec)
        _ffmpeg_apply_lib_to_target(LIBOAPV avcodec)
        _ffmpeg_apply_lib_to_target(LIBUAVS3D avcodec)
        _ffmpeg_apply_lib_to_target(LIBVVENC avcodec)
        _ffmpeg_apply_lib_to_target(LIBKVAZAAR avcodec)
        _ffmpeg_apply_lib_to_target(LIBZVBI avcodec)
        _ffmpeg_apply_lib_to_target(LIBCODEC2 avcodec)
        _ffmpeg_apply_lib_to_target(LIBILBC avcodec)
        _ffmpeg_apply_lib_to_target(LIBFDK_AAC avcodec)
        _ffmpeg_apply_lib_to_target(LIBGSM avcodec)
        _ffmpeg_apply_lib_to_target(LIBMP3LAME avcodec)
        _ffmpeg_apply_lib_to_target(GMP avcodec)
        _ffmpeg_apply_lib_to_target(GCRYPT avcodec)
        _ffmpeg_apply_lib_to_target(MBEDCRYPTO avcodec)
        _ffmpeg_apply_lib_to_target(TENSORFLOW avcodec)
        _ffmpeg_apply_lib_to_target(QSV avcodec)
        _ffmpeg_apply_lib_to_target(VAAPI avcodec)
        _ffmpeg_apply_lib_to_target(VIAMDXVA avcodec)
        _ffmpeg_apply_lib_to_target(VDPAAU avcodec)
        _ffmpeg_apply_lib_to_target(CUDA avcodec)
        _ffmpeg_apply_lib_to_target(CUVID avcodec)
        _ffmpeg_apply_lib_to_target(NVCUVID avcodec)
        _ffmpeg_apply_lib_to_target(NVENC avcodec)
        _ffmpeg_apply_lib_to_target(OPENSSL avcodec)
        _ffmpeg_apply_lib_to_target(GNUTLS avcodec)
        _ffmpeg_apply_lib_to_target(MEDTLS avcodec)
        _ffmpeg_apply_lib_to_target(LIBX265 avcodec)
        
        # System compression/utility libraries used by various codecs
        # LZMA: CONFIG_LZMA is set but find_package(LibLZMA) sets LIBLZMA_LIBRARIES
        if(CONFIG_LZMA)
            if(TARGET LibLZMA::LibLZMA)
                target_link_libraries(avcodec PUBLIC LibLZMA::LibLZMA)
            elseif(LIBLZMA_LIBRARIES)
                target_link_libraries(avcodec PUBLIC ${LIBLZMA_LIBRARIES})
            else()
                target_link_libraries(avcodec PUBLIC lzma)
            endif()
        endif()
        _ffmpeg_apply_lib_to_target(ZLIB avcodec)
        _ffmpeg_apply_lib_to_target(BZIP2 avcodec)
        _ffmpeg_apply_lib_to_target(Iconv avcodec)
    endif()
    
    # -------------------------------------------------------------------------
    # Libraries linked to avformat
    # -------------------------------------------------------------------------
    if(TARGET avformat)
        # lcms2 is needed because fflcms2.h is included from internal.h
        _ffmpeg_apply_lib_to_target(LCMS2 avformat)
        
        _ffmpeg_apply_lib_to_target(GNUTLS avformat)
        _ffmpeg_apply_lib_to_target(OPENSSL avformat)
        _ffmpeg_apply_lib_to_target(MBEDTLS avformat)
        _ffmpeg_apply_lib_to_target(LIBRTMP avformat)
        _ffmpeg_apply_lib_to_target(LIBSSH avformat)
        _ffmpeg_apply_lib_to_target(LIBSRT avformat)
        _ffmpeg_apply_lib_to_target(LIBZMQ avformat)
        _ffmpeg_apply_lib_to_target(LIBBLURAY avformat)
        _ffmpeg_apply_lib_to_target(LIBCHROMAPRINT avformat)
        _ffmpeg_apply_lib_to_target(LIBGME avformat)
        _ffmpeg_apply_lib_to_target(LIBMODPLUG avformat)
        _ffmpeg_apply_lib_to_target(LIBOPENMPT avformat)
        _ffmpeg_apply_lib_to_target(LIBRSVG avformat)
        _ffmpeg_apply_lib_to_target(LIBSMBCLIENT avformat)
        _ffmpeg_apply_lib_to_target(LIBRIST avformat)
        _ffmpeg_apply_lib_to_target(LIBXML2 avformat)
        _ffmpeg_apply_lib_to_target(LIBRABBITMQ avformat)
        _ffmpeg_apply_lib_to_target(LIBDVDNAV avformat)
        _ffmpeg_apply_lib_to_target(LIBDVDREAD avformat)
        _ffmpeg_apply_lib_to_target(LIBARIBB24 avformat)
    endif()
    
    # -------------------------------------------------------------------------
    # Libraries linked to avfilter
    # -------------------------------------------------------------------------
    if(TARGET avfilter)
        _ffmpeg_apply_lib_to_target(LCMS2 avfilter)
        _ffmpeg_apply_lib_to_target(CAIRO avfilter)
        _ffmpeg_apply_lib_to_target(FREETYPE avfilter)
        _ffmpeg_apply_lib_to_target(FONTCONFIG avfilter)
        _ffmpeg_apply_lib_to_target(FRIBIDI avfilter)
        _ffmpeg_apply_lib_to_target(GLSLANG avfilter)
        _ffmpeg_apply_lib_to_target(HARFBUZZ avfilter)
        _ffmpeg_apply_lib_to_target(LIBMFX avfilter)
        _ffmpeg_apply_lib_to_target(LIBPLACEBO avfilter)
        _ffmpeg_apply_lib_to_target(LIBRUBBERBAND avfilter)
        _ffmpeg_apply_lib_to_target(LIBVMAF avfilter)
        _ffmpeg_apply_lib_to_target(OPENCL avfilter)
        _ffmpeg_apply_lib_to_target(LIBOPENCV avfilter)
        _ffmpeg_apply_lib_to_target(SHADERC avfilter)
        _ffmpeg_apply_lib_to_target(SPIRV_CROSS avfilter)
        _ffmpeg_apply_lib_to_target(ZIMG avfilter)
        _ffmpeg_apply_lib_to_target(VAAPI avfilter)
        _ffmpeg_apply_lib_to_target(VDPAAU avfilter)
        _ffmpeg_apply_lib_to_target(CUDA avfilter)
        _ffmpeg_apply_lib_to_target(OPENCL avfilter)
        _ffmpeg_apply_lib_to_target(LIBASS avfilter)
        _ffmpeg_apply_lib_to_target(LIBBS2B avfilter)
        _ffmpeg_apply_lib_to_target(LIBLENSFUN avfilter)
        _ffmpeg_apply_lib_to_target(LIBVIDSTAB avfilter)
        _ffmpeg_apply_lib_to_target(LV2 avfilter)
        _ffmpeg_apply_lib_to_target(WHISPER avfilter)
        _ffmpeg_apply_lib_to_target(LIBQRENCODE avfilter)
        _ffmpeg_apply_lib_to_target(LIBQUIRC avfilter)
        _ffmpeg_apply_lib_to_target(LIBTESSERACT avfilter)
        _ffmpeg_apply_lib_to_target(LIBV4L2 avfilter)
        _ffmpeg_apply_lib_to_target(LIBCACA avfilter)
        _ffmpeg_apply_lib_to_target(LIBOPENVINO avfilter)
        _ffmpeg_apply_lib_to_target(LIBTENSORFLOW avfilter)
        _ffmpeg_apply_lib_to_target(LIBTORCH avfilter)
    endif()
    
    # -------------------------------------------------------------------------
    # Libraries linked to avdevice
    # -------------------------------------------------------------------------
    if(TARGET avdevice)
        _ffmpeg_apply_lib_to_target(LIBDC1394 avdevice)
        _ffmpeg_apply_lib_to_target(LIBIEC61883 avdevice)
        _ffmpeg_apply_lib_to_target(LIBJACK avdevice)
        _ffmpeg_apply_lib_to_target(LIBOPENAL avdevice)
        _ffmpeg_apply_lib_to_target(LIBOPENCV avdevice)
        _ffmpeg_apply_lib_to_target(LIBPULSE avdevice)
        _ffmpeg_apply_lib_to_target(LIBSDL2 avdevice)
        _ffmpeg_apply_lib_to_target(LIBXCB avdevice)
        _ffmpeg_apply_lib_to_target(LIBXCB_SHM avdevice)
        _ffmpeg_apply_lib_to_target(LIBXCB_XFIXES avdevice)
        _ffmpeg_apply_lib_to_target(LIBXCB_SHAPE avdevice)
        _ffmpeg_apply_lib_to_target(ALSA avdevice)
        _ffmpeg_apply_lib_to_target(OSSFUZZ avdevice)
        _ffmpeg_apply_lib_to_target(FFDWMARAWCAP avdevice)
        _ffmpeg_apply_lib_to_target(EXTRALIBS avdevice)
    endif()
    
    # -------------------------------------------------------------------------
    # Libraries linked to swscale
    # -------------------------------------------------------------------------
    if(TARGET swscale)
        _ffmpeg_apply_lib_to_target(CUDA swscale)
        _ffmpeg_apply_lib_to_target(OPENCL swscale)
    endif()
    
    message(STATUS "External library configurations applied")
endfunction()
