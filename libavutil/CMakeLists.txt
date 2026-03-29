# libavutil CMakeLists.txt
# FFmpeg utility library

# Collect all source files from libavutil/Makefile OBJS
set(avutil_sources
    adler32.c
    aes.c
    aes_ctr.c
    ambient_viewing_environment.c
    audio_fifo.c
    avstring.c
    avsscanf.c
    base64.c
    blowfish.c
    bprint.c
    buffer.c
    cast5.c
    camellia.c
    channel_layout.c
    container_fifo.c
    cpu.c
    crc.c
    csp.c
    des.c
    detection_bbox.c
    dict.c
    display.c
    dovi_meta.c
    downmix_info.c
    encryption_info.c
    error.c
    eval.c
    executor.c
    fifo.c
    file.c
    file_open.c
    float_dsp.c
    float_scalarproduct.c
    film_grain_params.c
    fixed_dsp.c
    frame.c
    hash.c
    hdr_dynamic_metadata.c
    hdr_dynamic_vivid_metadata.c
    hmac.c
    hwcontext.c
    iamf.c
    imgutils.c
    integer.c
    intmath.c
    lfg.c
    lls.c
    log.c
    log2_tab.c
    lzo.c
    mathematics.c
    mastering_display_metadata.c
    md5.c
    mem.c
    murmur3.c
    opt.c
    parseutils.c
    pixdesc.c
    pixelutils.c
    random_seed.c
    rational.c
    refstruct.c
    reverse.c
    rc4.c
    ripemd.c
    samplefmt.c
    side_data.c
    sha.c
    sha512.c
    slicethread.c
    spherical.c
    stereo3d.c
    tdrdi.c
    threadmessage.c
    time.c
    timecode.c
    timecode_internal.c
    timestamp.c
    tree.c
    twofish.c
    utils.c
    xga_font_data.c
    xtea.c
    tea.c
    tx.c
    tx_float.c
    tx_double.c
    tx_int32.c
    uuid.c
    version.c
    video_enc_params.c
    video_hint.c
)

# hwcontext_stub.c is needed when Vulkan is not available
# (provides stub implementations for hwcontext_vulkan.h functions)
if(NOT CONFIG_VULKAN)
    list(APPEND avutil_sources hwcontext_stub.c)
endif()

# Conditional sources based on hardware acceleration
if(CONFIG_VIDEOTOOLBOX)
    list(APPEND avutil_sources hwcontext_videotoolbox.c)
endif()
if(CONFIG_VAAPI)
    list(APPEND avutil_sources hwcontext_vaapi.c)
endif()
if(CONFIG_VDPAU)
    list(APPEND avutil_sources hwcontext_vdpau.c)
endif()
if(CONFIG_VULKAN)
    list(APPEND avutil_sources hwcontext_vulkan.c vulkan.c)
endif()
if(CONFIG_OPENCL)
    list(APPEND avutil_sources hwcontext_opencl.c)
endif()
if(CONFIG_CUDA)
    list(APPEND avutil_sources hwcontext_cuda.c)
endif()
if(CONFIG_D3D11VA)
    list(APPEND avutil_sources hwcontext_d3d11va.c)
endif()
if(CONFIG_D3D12VA)
    list(APPEND avutil_sources hwcontext_d3d12va.c)
endif()
if(CONFIG_DXVA2)
    list(APPEND avutil_sources hwcontext_dxva2.c)
endif()
if(CONFIG_QSV)
    list(APPEND avutil_sources hwcontext_qsv.c)
endif()
if(CONFIG_MEDIACODEC)
    list(APPEND avutil_sources hwcontext_mediacodec.c)
endif()
if(CONFIG_AMF)
    list(APPEND avutil_sources hwcontext_amf.c)
endif()
if(CONFIG_LIBDRM)
    list(APPEND avutil_sources hwcontext_drm.c)
endif()

# half2float.c / float2half.c needed for swscale and EXR/PHM codecs
# (from STLIBOBJS-$(CONFIG_*) in Makefile)
if(ENABLE_SWSCALE OR CONFIG_EXR_DECODER OR CONFIG_PHM_DECODER)
    list(APPEND avutil_sources half2float.c)
endif()
if(CONFIG_EXR_DECODER OR CONFIG_EXR_ENCODER OR CONFIG_PHM_ENCODER)
    list(APPEND avutil_sources float2half.c)
endif()

# AArch64 specific sources with assembly
if(ARCH_AARCH64 AND ENABLE_ASM)
    list(APPEND avutil_sources
        aarch64/cpu.c
        aarch64/float_dsp_init.c
        aarch64/tx_float_init.c
    )
    # NEON-OBJS: require NEON support
    if(HAVE_NEON)
        list(APPEND avutil_sources
            aarch64/float_dsp_neon.S
            aarch64/tx_float_neon.S
        )
    endif()
    # PIXELUTILS-OBJS: require CONFIG_PIXELUTILS and HAVE_NEON
    if(CONFIG_PIXELUTILS AND HAVE_NEON)
        list(APPEND avutil_sources aarch64/pixelutils_neon.S)
    endif()
    # ARMV8-OBJS: require ARMv8 CRC extension AND assembler .arch_extension crc support
    if(HAVE_AS_ARCHEXT_CRC_DIRECTIVE)
        list(APPEND avutil_sources aarch64/crc.S)
    endif()
    # SVE-OBJS: require SVE support
    if(HAVE_SVE)
        list(APPEND avutil_sources aarch64/cpu_sve.S)
    endif()
    # SME-OBJS: require SME support
    if(HAVE_SME)
        list(APPEND avutil_sources aarch64/cpu_sme.S)
    endif()
    # Note: aarch64/asm.S is a header file included by other .S files, not compiled directly
endif()

# ARM specific sources with assembly
if(ARCH_ARM AND ENABLE_ASM)
    list(APPEND avutil_sources
        arm/cpu.c
        arm/float_dsp_init.c
        arm/float_dsp_neon.S
    )
endif()

# x86 specific sources with assembly
if(ARCH_X86 AND ENABLE_ASM)
    list(APPEND avutil_sources
        x86/cpu.c
        x86/aes_init.c
        x86/fixed_dsp_init.c
        x86/float_dsp_init.c
        x86/imgutils_init.c
        x86/lls_init.c
        x86/tx_float_init.c
        x86/pixelutils_init.c
    )

    if(HAVE_X86ASM)
        # NASM is enabled in top-level CMakeLists.txt
        # Add NASM assembly files (with EXISTS check)
        foreach(asm_src x86/cpuid.asm x86/float_dsp.asm x86/tx_float.asm x86/pixelutils.asm x86/aes.asm x86/crc.asm x86/emms.asm x86/fixed_dsp.asm x86/imgutils.asm x86/lls.asm)
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${asm_src}")
                list(APPEND avutil_sources "${asm_src}")
            endif()
        endforeach()
    endif()
endif()

# Filter out source files that don't exist
set(avutil_sources_filtered "")
foreach(src IN LISTS avutil_sources)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND avutil_sources_filtered "${src}")
    else()
        message(STATUS "avutil: skipping missing source file: ${src}")
    endif()
endforeach()
set(avutil_sources ${avutil_sources_filtered})

# Create the library
add_library(avutil STATIC ${avutil_sources})

# Set include directories
# NOTE: Build directory must come BEFORE source directory
# so that the generated config.h is found instead of the source tree's version
target_include_directories(avutil
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
)

# Add source directory as NASM include path for each .asm file
# (mimics FFmpeg Makefile's -I$(<D)/ behavior)
if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)
    nasm_add_source_dir_includes(avutil)
endif()

# Link libraries
target_link_libraries(avutil
    PRIVATE
        ${CMAKE_DL_LIBS}
        Threads::Threads
)

# Link math library on Unix (not needed on Windows/macOS)
if(UNIX AND NOT APPLE)
    target_link_libraries(avutil PRIVATE m)
elseif(APPLE)
    target_link_libraries(avutil PRIVATE m)
endif()

# Link Vulkan if available
if(Vulkan_FOUND)
    target_link_libraries(avutil PRIVATE Vulkan::Vulkan)
    target_include_directories(avutil PRIVATE ${Vulkan_INCLUDE_DIRS})
endif()

# Link OpenCL if available
if(CONFIG_OPENCL AND OPENCL_LIBRARIES)
    target_link_libraries(avutil PRIVATE ${OPENCL_LIBRARIES})
    if(OPENCL_INCLUDE_DIRS)
        target_include_directories(avutil PRIVATE ${OPENCL_INCLUDE_DIRS})
    endif()
endif()

# Link VAAPI if available
# ffmpeg_require_pkg_config(vaapi libva ...) sets VAAPI_* variables
if(CONFIG_VAAPI AND VAAPI_LIBRARIES)
    target_link_libraries(avutil PRIVATE ${VAAPI_LIBRARIES})
    if(VAAPI_INCLUDE_DIRS)
        target_include_directories(avutil PRIVATE ${VAAPI_INCLUDE_DIRS})
    endif()
endif()

# Link OpenSSL if enabled (used by random_seed.c, tls_openssl.c, etc.)
if(CONFIG_OPENSSL AND OPENSSL_FOUND)
    target_link_libraries(avutil PRIVATE OpenSSL::SSL OpenSSL::Crypto)
    target_include_directories(avutil PRIVATE ${OPENSSL_INCLUDE_DIR})
endif()

# Link glslang or shaderc for SPIR-V compilation
if(CONFIG_LIBGLSLANG AND GLSLANG_FOUND)
    if(TARGET PkgConfig::GLSLANG)
        target_link_libraries(avutil PRIVATE PkgConfig::GLSLANG)
    else()
        target_link_libraries(avutil PRIVATE ${GLSLANG_LIBRARIES})
        target_include_directories(avutil PRIVATE ${GLSLANG_INCLUDE_DIRS})
        if(GLSLANG_LIBRARY_DIRS)
            target_link_directories(avutil PRIVATE ${GLSLANG_LIBRARY_DIRS})
        endif()
    endif()
elseif(CONFIG_LIBSHADERC AND SHADERC_FOUND)
    if(TARGET PkgConfig::SHADERC)
        target_link_libraries(avutil PRIVATE PkgConfig::SHADERC)
    else()
        target_link_libraries(avutil PRIVATE ${SHADERC_LIBRARIES})
        target_include_directories(avutil PRIVATE ${SHADERC_INCLUDE_DIRS})
        if(SHADERC_LIBRARY_DIRS)
            target_link_directories(avutil PRIVATE ${SHADERC_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Compiler definitions
target_compile_definitions(avutil PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avutil
)

# Platform-specific compile options and framework links
if(APPLE)
    target_compile_options(avutil PRIVATE -fobjc-arc)
    # hwcontext_videotoolbox.c requires these macOS frameworks
    target_link_libraries(avutil PRIVATE
        "-framework VideoToolbox"
        "-framework CoreVideo"
        "-framework CoreMedia"
        "-framework CoreFoundation"
    )
endif()

# Position independent code for shared builds
set_pic_if_needed(avutil)

# Set output name
set_target_properties(avutil PROPERTIES
    OUTPUT_NAME avutil
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# Export configuration
set(CONFIG_avutil 1 PARENT_SCOPE)

message(STATUS "libavutil configured: ${FFMPEG_ARCH} architecture")
