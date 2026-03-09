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
macro(ffmpeg_check_lib name headers funcs)
    string(TOUPPER "${name}" _cl_name_upper)
    string(TOLOWER "${name}" _cl_name_lower)
    
    # Check if disabled
    _should_skip_lib_check(${name} _cl_skip_check)
    if(_cl_skip_check)
        set(CONFIG_${_cl_name_upper} 0)
        message(STATUS "Checking for ${name}: disabled by user")
    else()
        # Convert headers list to #include lines
        set(_cl_include_lines "")
        foreach(_cl_header ${headers})
            string(APPEND _cl_include_lines "#include <${_cl_header}>\n")
        endforeach()
        
        # Build test code
        set(_cl_test_code "\n${_cl_include_lines}\nint main(void) {\n")
        foreach(_cl_func ${funcs})
            string(APPEND _cl_test_code "    void (*p_${_cl_func})(void) = (void (*)(void))${_cl_func};\n")
        endforeach()
        string(APPEND _cl_test_code "    return 0;\n}\n")
        
        # Save and modify check state
        cmake_push_check_state(RESET)
        
        # Add include directories and libraries
        set(CMAKE_REQUIRED_INCLUDES "")
        set(CMAKE_REQUIRED_LIBRARIES "")
        set(CMAKE_REQUIRED_FLAGS "")
        
        foreach(_cl_arg ${ARGN})
            if(_cl_arg MATCHES "^-I")
                string(REGEX REPLACE "^-I" "" _cl_inc_dir "${_cl_arg}")
                list(APPEND CMAKE_REQUIRED_INCLUDES "${_cl_inc_dir}")
            elseif(_cl_arg MATCHES "^-L")
                string(REGEX REPLACE "^-L" "" _cl_lib_dir "${_cl_arg}")
                list(APPEND CMAKE_REQUIRED_LINK_DIRECTORIES "${_cl_lib_dir}")
            elseif(_cl_arg MATCHES "^-l")
                list(APPEND CMAKE_REQUIRED_LIBRARIES "${_cl_arg}")
            elseif(_cl_arg MATCHES "^-D")
                list(APPEND CMAKE_REQUIRED_DEFINITIONS "${_cl_arg}")
            elseif(_cl_arg MATCHES "^-framework")
                list(APPEND CMAKE_REQUIRED_LIBRARIES "${_cl_arg}")
            else()
                list(APPEND CMAKE_REQUIRED_LIBRARIES "${_cl_arg}")
            endif()
        endforeach()
        
        # Perform the check
        check_c_source_compiles("${_cl_test_code}" HAVE_${_cl_name_upper}_LIB)
        
        cmake_pop_check_state()
        
        if(HAVE_${_cl_name_upper}_LIB)
            set(CONFIG_${_cl_name_upper} 1)
            set(${_cl_name_lower}_extralibs "${ARGN}")
            message(STATUS "Checking for ${name}: yes")
        else()
            set(CONFIG_${_cl_name_upper} 0)
            message(STATUS "Checking for ${name}: no")
        endif()
    endif()
endmacro()

#
# ffmpeg_require_pkg_config:
#   Mimics configure's require_pkg_config function
#   Implemented as a MACRO so variables are set in the caller's scope
#   (avoids the CMake PARENT_SCOPE limitation with nested function calls)
#   Parameters:
#     name - CONFIG_ variable base name  
#     pkg_version - pkg-config module with version (e.g., "openssl >= 1.0")
#     headers - header files to check
#     funcs - functions to check
#
macro(ffmpeg_require_pkg_config name pkg_version headers funcs)
    string(TOUPPER "${name}" _rpc_name_upper)
    string(TOLOWER "${name}" _rpc_name_lower)
    
    # Check if disabled
    _should_skip_lib_check(${name} _rpc_skip_check)
    if(_rpc_skip_check)
        set(CONFIG_${_rpc_name_upper} 0)
        message(STATUS "Checking for ${name}: disabled by user")
    else()
        # Extract package name (before any version spec)
        if("${pkg_version}" MATCHES "^([^ ]+)")
            set(_rpc_pkg_name "${CMAKE_MATCH_1}")
        else()
            set(_rpc_pkg_name "${pkg_version}")
        endif()
        
        # Check pkg-config
        if(PKG_CONFIG_FOUND)
            pkg_check_modules(PC_${_rpc_name_upper} QUIET "${pkg_version}")
        endif()
        
        if(PC_${_rpc_name_upper}_FOUND)
            # Pkg-config found the package, now verify headers/functions
            set(CMAKE_REQUIRED_INCLUDES ${PC_${_rpc_name_upper}_INCLUDE_DIRS})
            set(CMAKE_REQUIRED_LIBRARIES ${PC_${_rpc_name_upper}_LIBRARIES})
            set(CMAKE_REQUIRED_FLAGS ${PC_${_rpc_name_upper}_CFLAGS_OTHER})
            
            set(_rpc_include_lines "")
            foreach(_rpc_header ${headers})
                string(APPEND _rpc_include_lines "#include <${_rpc_header}>\n")
            endforeach()
            
            set(_rpc_test_code "\n${_rpc_include_lines}\nint main(void) {\n")
            foreach(_rpc_func ${funcs})
                if(_rpc_func)
                    string(APPEND _rpc_test_code "    void (*p_${_rpc_func})(void) = (void (*)(void))${_rpc_func};\n")
                endif()
            endforeach()
            string(APPEND _rpc_test_code "    return 0;\n}\n")
            
            check_c_source_compiles("${_rpc_test_code}" HAVE_${_rpc_name_upper}_PC)
            
            if(HAVE_${_rpc_name_upper}_PC OR NOT funcs)
                set(CONFIG_${_rpc_name_upper} 1)
                set(${_rpc_name_lower}_found TRUE)
                set(${_rpc_name_lower}_cflags "${PC_${_rpc_name_upper}_CFLAGS}")
                set(${_rpc_name_lower}_incdir "${PC_${_rpc_name_upper}_INCLUDEDIR}")
                set(${_rpc_name_lower}_extralibs "${PC_${_rpc_name_upper}_LDFLAGS}")
                set(${_rpc_name_upper}_INCLUDE_DIRS "${PC_${_rpc_name_upper}_INCLUDE_DIRS}")
                set(${_rpc_name_upper}_LIBRARIES "${PC_${_rpc_name_upper}_LIBRARIES}")
                set(${_rpc_name_upper}_LIBRARY_DIRS "${PC_${_rpc_name_upper}_LIBRARY_DIRS}")
                # Add library dirs globally so all targets (including executables) can find them
                if(PC_${_rpc_name_upper}_LIBRARY_DIRS)
                    link_directories(${PC_${_rpc_name_upper}_LIBRARY_DIRS})
                endif()
                message(STATUS "Checking for ${name}: yes (pkg-config)")
            else()
                set(CONFIG_${_rpc_name_upper} 0)
                set(${_rpc_name_lower}_found FALSE)
                message(STATUS "Checking for ${name}: no")
            endif()
        else()
            set(CONFIG_${_rpc_name_upper} 0)
            set(${_rpc_name_lower}_found FALSE)
            message(STATUS "Checking for ${name}: no")
        endif()
    endif()
endmacro()

#
# ffmpeg_check_pkg_config:
#   Like require_pkg_config but doesn't die on failure (mimics check_pkg_config)
#
macro(ffmpeg_check_pkg_config name pkg_version headers funcs)
    ffmpeg_require_pkg_config(${name} "${pkg_version}" "${headers}" "${funcs}")
endmacro()

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
macro(FFmpegDetectOpenSSL)
    if(ENABLE_OPENSSL)
        find_package(OpenSSL QUIET)
        if(OpenSSL_FOUND)
            set(CONFIG_OPENSSL 1)
            set(OpenSSL_FOUND ${OpenSSL_FOUND})
            set(OPENSSL_FOUND ${OpenSSL_FOUND})
            set(OPENSSL_INCLUDE_DIR ${OPENSSL_INCLUDE_DIR})
            set(OPENSSL_LIBRARIES ${OPENSSL_LIBRARIES})
            message(STATUS "Found OpenSSL: ${OPENSSL_VERSION}")
        else()
            # Fallback: try to detect via headers/libs directly
            ffmpeg_check_lib(openssl "openssl/ssl.h" "SSL_library_init" "-lssl" "-lcrypto")
        endif()
    else()
        set(CONFIG_OPENSSL 0)
    endif()
endmacro()

#
# FFmpegDetectZlib:
#   Detect zlib compression library
#
macro(FFmpegDetectZlib)
    if(NOT DEFINED ENABLE_ZLIB OR ENABLE_ZLIB)
        find_package(ZLIB QUIET)
        if(ZLIB_FOUND)
            set(CONFIG_ZLIB 1)
            set(ZLIB_FOUND ${ZLIB_FOUND})
            set(ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIR})
            set(ZLIB_LIBRARIES ${ZLIB_LIBRARIES})
            message(STATUS "Found zlib: yes")
        else()
            ffmpeg_check_lib(zlib "zlib.h" "zlibVersion" "-lz")
        endif()
    else()
        set(CONFIG_ZLIB 0)
    endif()
endmacro()

#
# FFmpegDetectBZip2:
#   Detect BZip2 compression library
#
macro(FFmpegDetectBZip2)
    if(NOT DEFINED ENABLE_BZLIB OR ENABLE_BZLIB)
        find_package(BZip2 QUIET)
        if(BZIP2_FOUND)
            set(CONFIG_BZLIB 1)
            set(BZIP2_FOUND ${BZIP2_FOUND})
            set(BZIP2_INCLUDE_DIR ${BZIP2_INCLUDE_DIR})
            set(BZIP2_LIBRARIES ${BZIP2_LIBRARIES})
        else()
            ffmpeg_check_lib(bzlib "bzlib.h" "BZ2_bzlibVersion" "-lbz2")
        endif()
    else()
        set(CONFIG_BZLIB 0)
    endif()
endmacro()

#
# FFmpegDetectLZMA:
#   Detect LZMA compression library
#
macro(FFmpegDetectLZMA)
    if(NOT DEFINED ENABLE_LZMA OR ENABLE_LZMA)
        find_package(LibLZMA QUIET)
        if(LIBLZMA_FOUND)
            set(CONFIG_LZMA 1)
            set(LIBLZMA_FOUND ${LIBLZMA_FOUND})
            set(LIBLZMA_INCLUDE_DIR ${LIBLZMA_INCLUDE_DIR})
            set(LIBLZMA_LIBRARIES ${LIBLZMA_LIBRARIES})
        else()
            ffmpeg_check_lib(lzma "lzma.h" "lzma_version_number" "-llzma")
        endif()
    else()
        set(CONFIG_LZMA 0)
    endif()
endmacro()

#
# FFmpegDetectIconv:
#   Detect iconv character conversion library
#
macro(FFmpegDetectIconv)
    if(NOT DEFINED ENABLE_ICONV OR ENABLE_ICONV)
        find_package(Iconv QUIET)
        if(Iconv_FOUND)
            set(CONFIG_ICONV 1)
            set(Iconv_FOUND ${Iconv_FOUND})
            set(ICONV_FOUND ${Iconv_FOUND})
            set(ICONV_INCLUDE_DIR ${ICONV_INCLUDE_DIR})
            set(ICONV_LIBRARIES ${ICONV_LIBRARIES})
        else()
            set(CONFIG_ICONV 0)
        endif()
    else()
        set(CONFIG_ICONV 0)
    endif()
endmacro()

#
# FFmpegDetectSDL2:
#   Detect SDL2 library (required for ffplay)
#
macro(FFmpegDetectSDL2)
    if(NOT DEFINED ENABLE_SDL2 OR ENABLE_SDL2)
        find_package(SDL2 QUIET)
        if(SDL2_FOUND)
            set(CONFIG_SDL2 1)
            set(SDL2_FOUND ${SDL2_FOUND})
            set(SDL2_INCLUDE_DIR ${SDL2_INCLUDE_DIR})
            set(SDL2_LIBRARIES ${SDL2_LIBRARIES})
            message(STATUS "Found SDL2: yes")
        else()
            ffmpeg_check_pkg_config(sdl2 sdl2 "SDL.h" "SDL_Init")
        endif()
    else()
        set(CONFIG_SDL2 0)
    endif()
endmacro()

#
# FFmpegDetectAlsa:
#   Detect ALSA audio library (Linux)
#
macro(FFmpegDetectAlsa)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_ALSA OR ENABLE_ALSA)
            ffmpeg_check_pkg_config(alsa alsa "alsa/asoundlib.h" "snd_pcm_open")
        else()
            set(CONFIG_ALSA 0)
        endif()
    else()
        set(CONFIG_ALSA 0)
    endif()
endmacro()

#
# FFmpegDetectPulseAudio:
#   Detect PulseAudio library
#
macro(FFmpegDetectPulseAudio)
    if(NOT DEFINED ENABLE_LIBPULSE OR ENABLE_LIBPULSE)
        ffmpeg_require_pkg_config(libpulse libpulse "pulse/pulseaudio.h" "pa_context_new")
    else()
        set(CONFIG_LIBPULSE 0)
    endif()
endmacro()

# =============================================================================
# Video codec library detection
# =============================================================================

#
# FFmpegDetectLibx264:
#   Detect x264 encoder library
#
macro(FFmpegDetectLibx264)
    if(ENABLE_LIBX264)
        ffmpeg_require_pkg_config(libx264 "x264 >= 0.118" "x264.h" "x264_encoder_open")
    else()
        set(CONFIG_LIBX264 0)
    endif()
endmacro()

#
# FFmpegDetectLibx265:
#   Detect x265 encoder library  
#
macro(FFmpegDetectLibx265)
    if(ENABLE_LIBX265)
        ffmpeg_require_pkg_config(libx265 x265 "x265.h" "x265_encoder_open")
    else()
        set(CONFIG_LIBX265 0)
    endif()
endmacro()

#
# FFmpegDetectLibvpx:
#   Detect libvpx VP8/VP9 codec library
#
macro(FFmpegDetectLibvpx)
    if(ENABLE_LIBVPX)
        ffmpeg_require_pkg_config(libvpx "vpx >= 1.4.0" "vpx/vpx_decoder.h" "vpx_codec_dec_init_ver")
    else()
        set(CONFIG_LIBVPX 0)
    endif()
endmacro()

#
# FFmpegDetectLibopus:
#   Detect Opus audio codec library
#
macro(FFmpegDetectLibopus)
    if(ENABLE_LIBOPUS)
        ffmpeg_require_pkg_config(libopus opus "opus_multistream.h" "opus_multistream_decoder_create")
    else()
        set(CONFIG_LIBOPUS 0)
    endif()
endmacro()

#
# FFmpegDetectLibmp3lame:
#   Detect MP3 encoding library
#
macro(FFmpegDetectLibmp3lame)
    if(ENABLE_LIBMP3LAME)
        ffmpeg_check_lib(libmp3lame "lame/lame.h" "lame_set_VBR_quality" "-lmp3lame" "-lm")
    else()
        set(CONFIG_LIBMP3LAME 0)
    endif()
endmacro()

#
# FFmpegDetectLibfdk_aac:
#   Detect FDK-AAC library
#
macro(FFmpegDetectLibfdk_aac)
    if(ENABLE_LIBFDK_AAC)
        ffmpeg_check_pkg_config(libfdk_aac fdk-aac "fdk-aac/aacenc_lib.h" "aacEncOpen")
        if(NOT CONFIG_LIBFDK_AAC)
            ffmpeg_check_lib(libfdk_aac "fdk-aac/aacenc_lib.h" "aacEncOpen" "-lfdk-aac")
        endif()
    else()
        set(CONFIG_LIBFDK_AAC 0)
    endif()
endmacro()

#
# FFmpegDetectLibvorbis:
#   Detect Vorbis audio codec library
#
macro(FFmpegDetectLibvorbis)
    if(ENABLE_LIBVORBIS)
        ffmpeg_require_pkg_config(libvorbis vorbis "vorbis/codec.h" "vorbis_info_init")
        ffmpeg_require_pkg_config(libvorbisenc vorbisenc "vorbis/vorbisenc.h" "vorbis_encode_init")
    else()
        set(CONFIG_LIBVORBIS 0)
        set(CONFIG_LIBVORBISENC 0)
    endif()
endmacro()

#
# FFmpegDetectLibtheora:
#   Detect Theora video codec library
#
macro(FFmpegDetectLibtheora)
    if(ENABLE_LIBTHEORA)
        ffmpeg_check_lib(libtheora "theora/theoraenc.h" "th_info_init" "-ltheoraenc" "-ltheoradec" "-logg")
    else()
        set(CONFIG_LIBTHEORA 0)
    endif()
endmacro()

#
# FFmpegDetectLibspeex:
#   Detect Speex audio codec library
#
macro(FFmpegDetectLibspeex)
    if(ENABLE_LIBSPEEX)
        ffmpeg_require_pkg_config(libspeex speex "speex/speex.h" "speex_decoder_init")
    else()
        set(CONFIG_LIBSPEEX 0)
    endif()
endmacro()

#
# FFmpegDetectLibass:
#   Detect ASS/SSA subtitle rendering library
#
macro(FFmpegDetectLibass)
    if(ENABLE_LIBASS)
        ffmpeg_require_pkg_config(libass "libass >= 0.11.0" "ass/ass.h" "ass_library_init")
    else()
        set(CONFIG_LIBASS 0)
    endif()
endmacro()

#
# FFmpegDetectLibbluray:
#   Detect Blu-ray library
#
macro(FFmpegDetectLibbluray)
    if(ENABLE_LIBBLURAY)
        ffmpeg_require_pkg_config(libbluray libbluray "libbluray/bluray.h" "bd_open")
    else()
        set(CONFIG_LIBBLURAY 0)
    endif()
endmacro()

#
# FFmpegDetectLibxml2:
#   Detect XML2 library
#
macro(FFmpegDetectLibxml2)
    if(ENABLE_LIBXML2)
        find_package(LibXml2 QUIET)
        if(LibXml2_FOUND)
            set(CONFIG_LIBXML2 1)
            set(LibXml2_FOUND ${LibXml2_FOUND})
            set(LIBXML2_FOUND ${LibXml2_FOUND})
            set(LIBXML2_INCLUDE_DIR ${LIBXML2_INCLUDE_DIR})
            set(LIBXML2_LIBRARIES ${LIBXML2_LIBRARIES})
        else()
            ffmpeg_require_pkg_config(libxml2 libxml-2.0 "libxml/parser.h" "xmlReadMemory")
        endif()
    else()
        set(CONFIG_LIBXML2 0)
    endif()
endmacro()

# =============================================================================
# Hardware acceleration detection
# =============================================================================

#
# FFmpegDetectVAAPI:
#   Detect Video Acceleration API (Linux)
#
macro(FFmpegDetectVAAPI)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_VAAPI OR ENABLE_VAAPI)
            ffmpeg_require_pkg_config(vaapi libva "va/va.h" "vaInitialize")
            # Propagate variables from nested call to grandparent scope
            set(CONFIG_VAAPI ${CONFIG_VAAPI})
            set(VAAPI_FOUND ${vaapi_found})
            set(VAAPI_LIBRARIES ${VAAPI_LIBRARIES})
            set(VAAPI_INCLUDE_DIRS ${VAAPI_INCLUDE_DIRS})
            set(VAAPI_LIBRARY_DIRS ${VAAPI_LIBRARY_DIRS})
            if(CONFIG_VAAPI)
                # Check for specific VaAPI codecs
                ffmpeg_check_pkg_config(vaapi_dec_h264 va "va/va_dec_h264.h" "")
                set(CONFIG_VAAPI_DEC_H264 ${CONFIG_VAAPI_DEC_H264})
                ffmpeg_check_pkg_config(vaapi_dec_hevc va "va/va_dec_hevc.h" "")
                set(CONFIG_VAAPI_DEC_HEVC ${CONFIG_VAAPI_DEC_HEVC})
            endif()
        else()
            set(CONFIG_VAAPI 0)
        endif()
    else()
        set(CONFIG_VAAPI 0)
    endif()
endmacro()

#
# FFmpegDetectVDPAU:
#   Detect NVIDIA VDPAU (Linux)
#
macro(FFmpegDetectVDPAU)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(NOT DEFINED ENABLE_VDPAU OR ENABLE_VDPAU)
            ffmpeg_check_pkg_config(vdpau vdpau "vdpau/vdpau.h" "vdp_device_create_x11")
            # Propagate variables from nested call to grandparent scope
            set(CONFIG_VDPAU ${CONFIG_VDPAU})
            set(VDPAU_FOUND ${vdpau_found})
            set(VDPAU_LIBRARIES ${VDPAU_LIBRARIES})
            set(VDPAU_INCLUDE_DIRS ${VDPAU_INCLUDE_DIRS})
        else()
            set(CONFIG_VDPAU 0)
        endif()
    else()
        set(CONFIG_VDPAU 0)
    endif()
endmacro()

#
# FFmpegDetectCUDA:
#   Detect NVIDIA CUDA
#
macro(FFmpegDetectCUDA)
    if(ENABLE_CUDA OR ENABLE_CUVID OR ENABLE_NVENC)
        find_package(CUDA QUIET)
        if(CUDA_FOUND)
            set(CONFIG_CUDA 1)
            set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS})
            set(CUDA_LIBRARIES ${CUDA_LIBRARIES})
        endif()
    else()
        set(CONFIG_CUDA 0)
    endif()
endmacro()

#
# FFmpegDetectVulkan:
#   Detect Vulkan graphics API
#
macro(FFmpegDetectVulkan)
    if(ENABLE_VULKAN)
        find_package(Vulkan QUIET)
        if(Vulkan_FOUND)
            set(CONFIG_VULKAN 1)
            set(VULKAN_INCLUDE_DIRS ${Vulkan_INCLUDE_DIRS})
            set(VULKAN_LIBRARIES ${Vulkan_LIBRARIES})
        else()
            set(CONFIG_VULKAN 0)
        endif()
    else()
        set(CONFIG_VULKAN 0)
    endif()
endmacro()

#
# FFmpegDetectOpenCL:
#   Detect OpenCL
#
macro(FFmpegDetectOpenCL)
    if(ENABLE_OPENCL)
        find_package(OpenCL QUIET)
        if(OpenCL_FOUND)
            set(CONFIG_OPENCL 1)
            set(OPENCL_INCLUDE_DIRS ${OpenCL_INCLUDE_DIRS})
            set(OPENCL_LIBRARIES ${OpenCL_LIBRARIES})
        else()
            # Check headers directly
            check_include_file("CL/cl.h" HAVE_CL_CL_H)
            if(NOT HAVE_CL_CL_H)
                check_include_file("OpenCL/cl.h" HAVE_OPENCL_CL_H)
            endif()
            if(HAVE_CL_CL_H OR HAVE_OPENCL_CL_H)
                set(CONFIG_OPENCL 1)
            else()
                set(CONFIG_OPENCL 0)
            endif()
        endif()
    else()
        set(CONFIG_OPENCL 0)
    endif()
endmacro()

# =============================================================================
# Main detection routine
# Calls all individual detection functions based on enabled features
# =============================================================================

macro(FFmpegDetectLibraries)
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
endmacro()

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
