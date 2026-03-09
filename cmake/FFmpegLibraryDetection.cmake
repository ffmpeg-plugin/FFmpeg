# FFmpeg Library Detection Module
# Mimics FFmpeg's configure script library detection
# Provides macros/functions similar to check_lib, require_pkg_config from configure

include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CMakePushCheckState)
include(FindPkgConfig)

# =============================================================================
# Utility Functions (internal)
# =============================================================================

# Helper to extract library name from -l flags
function(_extract_lib_name libs out_name)
    if(libs MATCHES "-l([^ ]+)")
        set(${out_name} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        set(${out_name} "" PARENT_SCOPE)
    endif()
endfunction()

# Helper to check if a library check should be skipped (disabled)
function(_should_skip_lib_check name out_skip)
    # Check if user explicitly disabled this library
    string(TOUPPER "ENABLE_${name}" opt_name)
    if(DEFINED ${opt_name} AND NOT ${opt_name})
        set(${out_skip} TRUE PARENT_SCOPE)
        return()
    endif()
    # Check if user explicitly requested this library (require mode)
    if(DEFINED ${opt_name} AND ${opt_name})
        set(${out_skip} FALSE PARENT_SCOPE)
        return()
    endif()
    # Default: don't skip (auto-detect)
    set(${out_skip} FALSE PARENT_SCOPE)
endfunction()

# =============================================================================
# Core Detection Functions (configure equivalents)
# =============================================================================

#
# ffmpeg_check_lib:
#   Mimics configure's check_lib function
#   Parameters:
#     name - CONFIG_ variable name (e.g., CONFIG_LIBOPENSSL -> openssl)
#     headers - header files to include (semicolon-separated)
#     funcs - functions to check (semicolon-separated)  
#     libs - linker flags/libraries
#
function(ffmpeg_check_lib name headers funcs)
    string(TOUPPER "${name}" name_upper)
    string(TOLOWER "${name}" name_lower)
    
    # Check if disabled
    _should_skip_lib_check(${name} skip_check)
    if(skip_check)
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
        message(STATUS "Checking for ${name}: disabled by user")
        return()
    endif()
    
    # Convert headers list to #include lines
    set(include_lines "")
    foreach(header ${headers})
        string(APPEND include_lines "#include <${header}>\n")
    endforeach()
    
    # Build test code
    set(test_code "
${include_lines}
int main(void) {
")
    foreach(func ${funcs})
        string(APPEND test_code "    void (*p_${func})(void) = (void (*)(void))${func};\n")
    endforeach()
    string(APPEND test_code "    return 0;\n}\n")
    
    # Save and modify check state
    cmake_push_check_state(RESET)
    
    # Add include directories and libraries
    set(CMAKE_REQUIRED_INCLUDES "")
    set(CMAKE_REQUIRED_LIBRARIES "")
    set(CMAKE_REQUIRED_FLAGS "")
    
    foreach(arg ${ARGN})
        if(arg MATCHES "^-I")
            string(REGEX REPLACE "^-I" "" inc_dir "${arg}")
            list(APPEND CMAKE_REQUIRED_INCLUDES "${inc_dir}")
        elseif(arg MATCHES "^-L")
            string(REGEX REPLACE "^-L" "" lib_dir "${arg}")
            list(APPEND CMAKE_REQUIRED_LINK_DIRECTORIES "${lib_dir}")
        elseif(arg MATCHES "^-l")
            list(APPEND CMAKE_REQUIRED_LIBRARIES "${arg}")
        elseif(arg MATCHES "^-D")
            list(APPEND CMAKE_REQUIRED_DEFINITIONS "${arg}")
        elseif(arg MATCHES "^-framework")
            list(APPEND CMAKE_REQUIRED_LIBRARIES "${arg}")
        else()
            list(APPEND CMAKE_REQUIRED_LIBRARIES "${arg}")
        endif()
    endforeach()
    
    # Perform the check
    check_c_source_compiles("${test_code}" HAVE_${name_upper}_LIB)
    
    cmake_pop_check_state()
    
    if(HAVE_${name_upper}_LIB)
        set(CONFIG_${name_upper} 1 PARENT_SCOPE)
        set(${name_lower}_extralibs "${ARGN}" PARENT_SCOPE)
        message(STATUS "Checking for ${name}: yes")
    else()
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
        message(STATUS "Checking for ${name}: no")
    endif()
endfunction()

#
# ffmpeg_require_pkg_config:
#   Mimics configure's require_pkg_config function
#   Parameters:
#     name - CONFIG_ variable base name  
#     pkg_version - pkg-config module with version (e.g., "openssl >= 1.0")
#     headers - header files to check
#     funcs - functions to check
#
function(ffmpeg_require_pkg_config name pkg_version headers funcs)
    string(TOUPPER "${name}" name_upper)
    string(TOLOWER "${name}" name_lower)
    
    # Check if disabled
    _should_skip_lib_check(${name} skip_check)
    if(skip_check)
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
        message(STATUS "Checking for ${name}: disabled by user")
        return()
    endif()
    
    # Extract package name (before any version spec)
    if(pkg_version MATCHES "^([^ ]+)")
        set(pkg_name "${CMAKE_MATCH_1}")
    else()
        set(pkg_name "${pkg_version}")
    endif()
    
    # Check pkg-config
    if(PKG_CONFIG_FOUND)
        pkg_check_modules(PC_${name_upper} QUIET "${pkg_version}")
    endif()
    
    if(PC_${name_upper}_FOUND)
        # Pkg-config found the package, now verify headers/functions
        set(CMAKE_REQUIRED_INCLUDES ${PC_${name_upper}_INCLUDE_DIRS})
        set(CMAKE_REQUIRED_LIBRARIES ${PC_${name_upper}_LIBRARIES})
        set(CMAKE_REQUIRED_FLAGS ${PC_${name_upper}_CFLAGS_OTHER})
        
        set(include_lines "")
        foreach(header ${headers})
            string(APPEND include_lines "#include <${header}>\n")
        endforeach()
        
        set(test_code "
${include_lines}
int main(void) {
")
        foreach(func ${funcs})
            if(func)
                string(APPEND test_code "    void (*p_${func})(void) = (void (*)(void))${func};\n")
            endif()
        endforeach()
        string(APPEND test_code "    return 0;\n}\n")
        
        check_c_source_compiles("${test_code}" HAVE_${name_upper}_PC)
        
        if(HAVE_${name_upper}_PC OR NOT funcs)
            set(CONFIG_${name_upper} 1 PARENT_SCOPE)
            set(${name_lower}_found TRUE PARENT_SCOPE)
            set(${name_lower}_cflags "${PC_${name_upper}_CFLAGS}" PARENT_SCOPE)
            set(${name_lower}_incdir "${PC_${name_upper}_INCLUDEDIR}" PARENT_SCOPE)
            set(${name_lower}_extralibs "${PC_${name_upper}_LDFLAGS}" PARENT_SCOPE)
            set(${name_upper}_INCLUDE_DIRS "${PC_${name_upper}_INCLUDE_DIRS}" PARENT_SCOPE)
            set(${name_upper}_LIBRARIES "${PC_${name_upper}_LIBRARIES}" PARENT_SCOPE)
            set(${name_upper}_LIBRARY_DIRS "${PC_${name_upper}_LIBRARY_DIRS}" PARENT_SCOPE)
            message(STATUS "Checking for ${name}: yes (pkg-config)")
            return()
        endif()
    endif()
    
    set(CONFIG_${name_upper} 0 PARENT_SCOPE)
    set(${name_lower}_found FALSE PARENT_SCOPE)
    message(STATUS "Checking for ${name}: no")
endfunction()

#
# ffmpeg_check_pkg_config:
#   Like require_pkg_config but doesn't die on failure (mimics check_pkg_config)
#
function(ffmpeg_check_pkg_config name pkg_version headers funcs)
    ffmpeg_require_pkg_config(${name} "${pkg_version}" "${headers}" "${funcs}")
endfunction()

#
# ffmpeg_check_lib_cxx:
#   Check for C++ library (mimics check_lib_cxx)
#
function(ffmpeg_check_lib_cxx name headers classes)
    string(TOUPPER "${name}" name_upper)
    
    _should_skip_lib_check(${name} skip_check)
    if(skip_check)
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
        return()
    endif()
    
    set(include_lines "")
    foreach(header ${headers})
        string(APPEND include_lines "#include <${header}>\n")
    endforeach()
    
    set(test_code "
${include_lines}
int main() {
")
    foreach(cls ${classes})
        string(APPEND test_code "    ${cls}* p = nullptr;\n")
    endforeach()
    string(APPEND test_code "    return 0;\n}\n")
    
    cmake_push_check_state(RESET)
    
    set(CMAKE_REQUIRED_FLAGS "${ARGN} -std=c++11")
    set(CMAKE_REQUIRED_LIBRARIES ${ARGN})
    
    check_cxx_source_compiles("${test_code}" HAVE_${name_upper}_LIB)
    
    cmake_pop_check_state()
    
    if(HAVE_${name_upper}_LIB)
        set(CONFIG_${name_upper} 1 PARENT_SCOPE)
        message(STATUS "Checking for ${name} (C++): yes")
    else()
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
        message(STATUS "Checking for ${name} (C++): no")
    endif()
endfunction()

#
# ffmpeg_check_headers:
#   Check for header files (mimics check_headers)
#
function(ffmpeg_check_headers)
    foreach(header ${ARGV})
        string(MAKE_C_IDENTIFIER "${header}" header_var)
        string(TOUPPER "${header_var}" header_var)
        check_include_file("${header}" HAVE_${header_var})
    endforeach()
endfunction()

# =============================================================================
# Dependency-aware enable/disable
# =============================================================================

#
# ffmpeg_enable_if_available:
#   Enable a feature/library if all its dependencies are available
#
function(ffmpeg_enable_if_available name)
    string(TOUPPER "${name}" name_upper)
    
    set(all_deps_met TRUE)
    foreach(dep ${ARGN})
        string(TOUPPER "CONFIG_${dep}" dep_config)
        if(NOT ${dep_config})
            set(all_deps_met FALSE)
            break()
        endif()
    endforeach()
    
    if(all_deps_met)
        set(CONFIG_${name_upper} 1 PARENT_SCOPE)
    else()
        set(CONFIG_${name_upper} 0 PARENT_SCOPE)
    endif()
endfunction()

#
# ffmpeg_disable_exclusive:
#   Disable mutually exclusive options
#   Usage: ffmpeg_disable_exclusive(libmfx libvpl)
#
function(ffmpeg_disable_exclusive)
    set(_first_enabled "")
    foreach(opt ${ARGV})
        string(TOUPPER "CONFIG_${opt}" opt_config)
        if(${opt_config})
            if(_first_enabled)
                message(WARNING "Both ${_first_enabled} and ${opt} enabled, disabling ${opt}")
                set(${opt_config} 0 PARENT_SCOPE)
            else()
                set(_first_enabled ${opt})
            endif()
        endif()
    endforeach()
endfunction()

# =============================================================================
# Library-specific wrappers
# These provide higher-level detection for common libraries
# =============================================================================

#
# FFmpegDetectOpenSSL:
#   Detect OpenSSL library
#
function(FFmpegDetectOpenSSL)
    if(ENABLE_OPENSSL)
        find_package(OpenSSL QUIET)
        if(OpenSSL_FOUND)
            set(CONFIG_OPENSSL 1 PARENT_SCOPE)
            set(OpenSSL_FOUND ${OpenSSL_FOUND} PARENT_SCOPE)
            set(OPENSSL_FOUND ${OpenSSL_FOUND} PARENT_SCOPE)
            set(OPENSSL_INCLUDE_DIR ${OPENSSL_INCLUDE_DIR} PARENT_SCOPE)
            set(OPENSSL_LIBRARIES ${OPENSSL_LIBRARIES} PARENT_SCOPE)
            message(STATUS "Found OpenSSL: ${OPENSSL_VERSION}")
        else()
            # Fallback: try to detect via headers/libs directly
            ffmpeg_check_lib(openssl "openssl/ssl.h" "SSL_library_init" "-lssl" "-lcrypto")
        endif()
    else()
        set(CONFIG_OPENSSL 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectZlib:
#   Detect zlib compression library
#
function(FFmpegDetectZlib)
    if(NOT DEFINED ENABLE_ZLIB OR ENABLE_ZLIB)
        find_package(ZLIB QUIET)
        if(ZLIB_FOUND)
            set(CONFIG_ZLIB 1 PARENT_SCOPE)
            set(ZLIB_FOUND ${ZLIB_FOUND} PARENT_SCOPE)
            set(ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIR} PARENT_SCOPE)
            set(ZLIB_LIBRARIES ${ZLIB_LIBRARIES} PARENT_SCOPE)
            message(STATUS "Found zlib: yes")
        else()
            ffmpeg_check_lib(zlib "zlib.h" "zlibVersion" "-lz")
        endif()
    else()
        set(CONFIG_ZLIB 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectBZip2:
#   Detect BZip2 compression library
#
function(FFmpegDetectBZip2)
    if(NOT DEFINED ENABLE_BZLIB OR ENABLE_BZLIB)
        find_package(BZip2 QUIET)
        if(BZIP2_FOUND)
            set(CONFIG_BZLIB 1 PARENT_SCOPE)
            set(BZIP2_FOUND ${BZIP2_FOUND} PARENT_SCOPE)
            set(BZIP2_INCLUDE_DIR ${BZIP2_INCLUDE_DIR} PARENT_SCOPE)
            set(BZIP2_LIBRARIES ${BZIP2_LIBRARIES} PARENT_SCOPE)
        else()
            ffmpeg_check_lib(bzlib "bzlib.h" "BZ2_bzlibVersion" "-lbz2")
        endif()
    else()
        set(CONFIG_BZLIB 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLZMA:
#   Detect LZMA compression library
#
function(FFmpegDetectLZMA)
    if(NOT DEFINED ENABLE_LZMA OR ENABLE_LZMA)
        find_package(LibLZMA QUIET)
        if(LIBLZMA_FOUND)
            set(CONFIG_LZMA 1 PARENT_SCOPE)
            set(LIBLZMA_FOUND ${LIBLZMA_FOUND} PARENT_SCOPE)
            set(LIBLZMA_INCLUDE_DIR ${LIBLZMA_INCLUDE_DIR} PARENT_SCOPE)
            set(LIBLZMA_LIBRARIES ${LIBLZMA_LIBRARIES} PARENT_SCOPE)
        else()
            ffmpeg_check_lib(lzma "lzma.h" "lzma_version_number" "-llzma")
        endif()
    else()
        set(CONFIG_LZMA 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectIconv:
#   Detect iconv character conversion library
#
function(FFmpegDetectIconv)
    if(NOT DEFINED ENABLE_ICONV OR ENABLE_ICONV)
        find_package(Iconv QUIET)
        if(Iconv_FOUND)
            set(CONFIG_ICONV 1 PARENT_SCOPE)
            set(Iconv_FOUND ${Iconv_FOUND} PARENT_SCOPE)
            set(ICONV_FOUND ${Iconv_FOUND} PARENT_SCOPE)
            set(ICONV_INCLUDE_DIR ${ICONV_INCLUDE_DIR} PARENT_SCOPE)
            set(ICONV_LIBRARIES ${ICONV_LIBRARIES} PARENT_SCOPE)
        else()
            set(CONFIG_ICONV 0 PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_ICONV 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectSDL2:
#   Detect SDL2 library (required for ffplay)
#
function(FFmpegDetectSDL2)
    if(NOT DEFINED ENABLE_SDL2 OR ENABLE_SDL2)
        find_package(SDL2 QUIET)
        if(SDL2_FOUND)
            set(CONFIG_SDL2 1 PARENT_SCOPE)
            set(SDL2_FOUND ${SDL2_FOUND} PARENT_SCOPE)
            set(SDL2_INCLUDE_DIR ${SDL2_INCLUDE_DIR} PARENT_SCOPE)
            set(SDL2_LIBRARIES ${SDL2_LIBRARIES} PARENT_SCOPE)
            message(STATUS "Found SDL2: yes")
        else()
            ffmpeg_check_pkg_config(sdl2 sdl2 "SDL.h" "SDL_Init")
        endif()
    else()
        set(CONFIG_SDL2 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectAlsa:
#   Detect ALSA audio library (Linux)
#
function(FFmpegDetectAlsa)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_ALSA OR ENABLE_ALSA)
            ffmpeg_check_pkg_config(alsa alsa "alsa/asoundlib.h" "snd_pcm_open")
        else()
            set(CONFIG_ALSA 0 PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_ALSA 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectPulseAudio:
#   Detect PulseAudio library
#
function(FFmpegDetectPulseAudio)
    if(NOT DEFINED ENABLE_LIBPULSE OR ENABLE_LIBPULSE)
        ffmpeg_require_pkg_config(libpulse libpulse "pulse/pulseaudio.h" "pa_context_new")
    else()
        set(CONFIG_LIBPULSE 0 PARENT_SCOPE)
    endif()
endfunction()

# =============================================================================
# Video codec library detection
# =============================================================================

#
# FFmpegDetectLibx264:
#   Detect x264 encoder library
#
function(FFmpegDetectLibx264)
    if(ENABLE_LIBX264)
        ffmpeg_require_pkg_config(libx264 "x264 >= 0.118" "x264.h" "x264_encoder_open")
    else()
        set(CONFIG_LIBX264 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibx265:
#   Detect x265 encoder library  
#
function(FFmpegDetectLibx265)
    if(ENABLE_LIBX265)
        ffmpeg_require_pkg_config(libx265 x265 "x265.h" "x265_encoder_open")
    else()
        set(CONFIG_LIBX265 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibvpx:
#   Detect libvpx VP8/VP9 codec library
#
function(FFmpegDetectLibvpx)
    if(ENABLE_LIBVPX)
        ffmpeg_require_pkg_config(libvpx "vpx >= 1.4.0" "vpx/vpx_decoder.h" "vpx_codec_dec_init_ver")
    else()
        set(CONFIG_LIBVPX 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibopus:
#   Detect Opus audio codec library
#
function(FFmpegDetectLibopus)
    if(ENABLE_LIBOPUS)
        ffmpeg_require_pkg_config(libopus opus "opus_multistream.h" "opus_multistream_decoder_create")
    else()
        set(CONFIG_LIBOPUS 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibmp3lame:
#   Detect MP3 encoding library
#
function(FFmpegDetectLibmp3lame)
    if(ENABLE_LIBMP3LAME)
        ffmpeg_check_lib(libmp3lame "lame/lame.h" "lame_set_VBR_quality" "-lmp3lame" "-lm")
    else()
        set(CONFIG_LIBMP3LAME 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibfdk_aac:
#   Detect FDK-AAC library
#
function(FFmpegDetectLibfdk_aac)
    if(ENABLE_LIBFDK_AAC)
        ffmpeg_check_pkg_config(libfdk_aac fdk-aac "fdk-aac/aacenc_lib.h" "aacEncOpen")
        if(NOT CONFIG_LIBFDK_AAC)
            ffmpeg_check_lib(libfdk_aac "fdk-aac/aacenc_lib.h" "aacEncOpen" "-lfdk-aac")
        endif()
    else()
        set(CONFIG_LIBFDK_AAC 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibvorbis:
#   Detect Vorbis audio codec library
#
function(FFmpegDetectLibvorbis)
    if(ENABLE_LIBVORBIS)
        ffmpeg_require_pkg_config(libvorbis vorbis "vorbis/codec.h" "vorbis_info_init")
        ffmpeg_require_pkg_config(libvorbisenc vorbisenc "vorbis/vorbisenc.h" "vorbis_encode_init")
    else()
        set(CONFIG_LIBVORBIS 0 PARENT_SCOPE)
        set(CONFIG_LIBVORBISENC 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibtheora:
#   Detect Theora video codec library
#
function(FFmpegDetectLibtheora)
    if(ENABLE_LIBTHEORA)
        ffmpeg_check_lib(libtheora "theora/theoraenc.h" "th_info_init" "-ltheoraenc" "-ltheoradec" "-logg")
    else()
        set(CONFIG_LIBTHEORA 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibspeex:
#   Detect Speex audio codec library
#
function(FFmpegDetectLibspeex)
    if(ENABLE_LIBSPEEX)
        ffmpeg_require_pkg_config(libspeex speex "speex/speex.h" "speex_decoder_init")
    else()
        set(CONFIG_LIBSPEEX 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibass:
#   Detect ASS/SSA subtitle rendering library
#
function(FFmpegDetectLibass)
    if(ENABLE_LIBASS)
        ffmpeg_require_pkg_config(libass "libass >= 0.11.0" "ass/ass.h" "ass_library_init")
    else()
        set(CONFIG_LIBASS 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibbluray:
#   Detect Blu-ray library
#
function(FFmpegDetectLibbluray)
    if(ENABLE_LIBBLURAY)
        ffmpeg_require_pkg_config(libbluray libbluray "libbluray/bluray.h" "bd_open")
    else()
        set(CONFIG_LIBBLURAY 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectLibxml2:
#   Detect XML2 library
#
function(FFmpegDetectLibxml2)
    if(ENABLE_LIBXML2)
        find_package(LibXml2 QUIET)
        if(LibXml2_FOUND)
            set(CONFIG_LIBXML2 1 PARENT_SCOPE)
            set(LibXml2_FOUND ${LibXml2_FOUND} PARENT_SCOPE)
            set(LIBXML2_FOUND ${LibXml2_FOUND} PARENT_SCOPE)
            set(LIBXML2_INCLUDE_DIR ${LIBXML2_INCLUDE_DIR} PARENT_SCOPE)
            set(LIBXML2_LIBRARIES ${LIBXML2_LIBRARIES} PARENT_SCOPE)
        else()
            ffmpeg_require_pkg_config(libxml2 libxml-2.0 "libxml/parser.h" "xmlReadMemory")
        endif()
    else()
        set(CONFIG_LIBXML2 0 PARENT_SCOPE)
    endif()
endfunction()

# =============================================================================
# Hardware acceleration detection
# =============================================================================

#
# FFmpegDetectVAAPI:
#   Detect Video Acceleration API (Linux)
#
function(FFmpegDetectVAAPI)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_VAAPI OR ENABLE_VAAPI)
            ffmpeg_require_pkg_config(vaapi libva "va/va.h" "vaInitialize")
            if(CONFIG_VAAPI)
                # Check for specific VaAPI codecs
                ffmpeg_check_pkg_config(vaapi_dec_h264 va "va/va_dec_h264.h" "")
                ffmpeg_check_pkg_config(vaapi_dec_hevc va "va/va_dec_hevc.h" "")
            endif()
        else()
            set(CONFIG_VAAPI 0 PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_VAAPI 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectVDPAU:
#   Detect NVIDIA VDPAU (Linux)
#
function(FFmpegDetectVDPAU)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_VDPAU OR ENABLE_VDPAU)
            ffmpeg_check_pkg_config(vdpau vdpau "vdpau/vdpau.h" "vdp_device_create_x11")
        else()
            set(CONFIG_VDPAU 0 PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_VDPAU 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectCUDA:
#   Detect NVIDIA CUDA
#
function(FFmpegDetectCUDA)
    if(ENABLE_CUDA OR ENABLE_CUVID OR ENABLE_NVENC)
        find_package(CUDA QUIET)
        if(CUDA_FOUND)
            set(CONFIG_CUDA 1 PARENT_SCOPE)
            set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS} PARENT_SCOPE)
            set(CUDA_LIBRARIES ${CUDA_LIBRARIES} PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_CUDA 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectVulkan:
#   Detect Vulkan graphics API
#
function(FFmpegDetectVulkan)
    if(ENABLE_VULKAN)
        find_package(Vulkan QUIET)
        if(Vulkan_FOUND)
            set(CONFIG_VULKAN 1 PARENT_SCOPE)
            set(VULKAN_INCLUDE_DIRS ${Vulkan_INCLUDE_DIRS} PARENT_SCOPE)
            set(VULKAN_LIBRARIES ${Vulkan_LIBRARIES} PARENT_SCOPE)
        else()
            set(CONFIG_VULKAN 0 PARENT_SCOPE)
        endif()
    else()
        set(CONFIG_VULKAN 0 PARENT_SCOPE)
    endif()
endfunction()

#
# FFmpegDetectOpenCL:
#   Detect OpenCL
#
function(FFmpegDetectOpenCL)
    if(ENABLE_OPENCL)
        find_package(OpenCL QUIET)
        if(OpenCL_FOUND)
            set(CONFIG_OPENCL 1 PARENT_SCOPE)
            set(OPENCL_INCLUDE_DIRS ${OpenCL_INCLUDE_DIRS} PARENT_SCOPE)
            set(OPENCL_LIBRARIES ${OpenCL_LIBRARIES} PARENT_SCOPE)
        else()
            # Check headers directly
            check_include_file("CL/cl.h" HAVE_CL_CL_H)
            if(NOT HAVE_CL_CL_H)
                check_include_file("OpenCL/cl.h" HAVE_OPENCL_CL_H)
            endif()
            if(HAVE_CL_CL_H OR HAVE_OPENCL_CL_H)
                set(CONFIG_OPENCL 1 PARENT_SCOPE)
            else()
                set(CONFIG_OPENCL 0 PARENT_SCOPE)
            endif()
        endif()
    else()
        set(CONFIG_OPENCL 0 PARENT_SCOPE)
    endif()
endfunction()

# =============================================================================
# Main detection routine
# Calls all individual detection functions based on enabled features
# =============================================================================

function(FFmpegDetectLibraries)
    message(STATUS "")
    message(STATUS "==========================================")
    message(STATUS "Detecting external libraries...")
    message(STATUS "==========================================")
    
    # Compression libraries
    FFmpegDetectZlib()
    FFmpegDetectBZip2()
    FFmpegDetectLZMA()
    FFmpegDetectIconv()
    
    # Encryption/security
    FFmpegDetectOpenSSL()
    
    # Graphics/UI libraries
    FFmpegDetectSDL2()
    
    # Audio output libraries
    FFmpegDetectAlsa()
    FFmpegDetectPulseAudio()
    
    # Video codecs
    FFmpegDetectLibx264()
    FFmpegDetectLibx265()
    FFmpegDetectLibvpx()
    FFmpegDetectLibopus()
    FFmpegDetectLibmp3lame()
    FFmpegDetectLibfdk_aac()
    FFmpegDetectLibvorbis()
    FFmpegDetectLibtheora()
    FFmpegDetectLibspeex()
    
    # Subtitles/Meta
    FFmpegDetectLibass()
    FFmpegDetectLibbluray()
    FFmpegDetectLibxml2()
    
    # Hardware acceleration
    FFmpegDetectVAAPI()
    FFmpegDetectVDPAU()
    FFmpegDetectVulkan()
    FFmpegDetectOpenCL()
    
    # Handle mutually exclusive options
    ffmpeg_disable_exclusive(libmfx libvpl)
    
    message(STATUS "==========================================")
    message(STATUS "Library detection complete")
    message(STATUS "==========================================")
    message(STATUS "")
endfunction()

# Export detection status summary function
function(FFmpegPrintLibrarySummary)
    message(STATUS "")
    message(STATUS "Library Detection Summary:")
    message(STATUS "---------------------------")
    
    set(_libs openssl zlib bzlib lzma iconv sdl2 alsa pulseaudio 
              libx264 libx265 libvpx libopus libmp3lame libfdk_aac
              libvorbis libtheora libspeex libass libbluray libxml2
              vaapi vdpau vulkan opencl)
    
    foreach(_lib ${_libs})
        string(TOUPPER "${_lib}" _lib_upper)
        if(CONFIG_${_lib_upper})
            message(STATUS "  ${_lib}: enabled")
        else()
            message(STATUS "  ${_lib}: disabled")
        endif()
    endforeach()
    
    message(STATUS "")
endfunction()
