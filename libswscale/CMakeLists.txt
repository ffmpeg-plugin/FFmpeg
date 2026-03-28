# libswscale CMakeLists.txt
# Based on actual source files in libswscale/

# ============================================================================
# Core sources (unconditional)
# ============================================================================
set(swscale_sources
    alphablend.c
    cms.c
    csputils.c
    format.c
    gamma.c
    graph.c
    hscale.c
    hscale_fast_bilinear.c
    input.c
    log2_tab.c
    lut3d.c
    ops.c
    ops_backend.c
    ops_chain.c
    ops_dispatch.c
    ops_memcpy.c
    ops_optimizer.c
    options.c
    output.c
    rgb2rgb.c
    slice.c
    swscale.c
    swscale_unscaled.c
    utils.c
    version.c
    vscale.c
    yuv2rgb.c
)

# ============================================================================
# x86 assembly support
# ============================================================================
if(ARCH_X86 AND ENABLE_ASM)
    list(APPEND swscale_sources
        x86/ops.c
        x86/rgb2rgb.c
        x86/swscale.c
        x86/yuv2rgb.c
    )
    # hscale_fast_bilinear_simd.c uses GCC inline asm (__asm__ volatile)
    # Only compile when HAVE_MMXEXT_INLINE=1 (not available on MSVC)
    # Corresponds to: OBJS-$(HAVE_MMXEXT_INLINE) += x86/hscale_fast_bilinear_simd.o
    if(HAVE_MMXEXT_INLINE)
        list(APPEND swscale_sources x86/hscale_fast_bilinear_simd.c)
    endif()

    if(HAVE_X86ASM)
        list(APPEND swscale_sources
            x86/input.asm
            x86/output.asm
            x86/scale.asm
            x86/scale_avx2.asm
            x86/rgb_2_rgb.asm
            x86/yuv_2_rgb.asm
            x86/yuv2yuvX.asm
            x86/ops_common.asm
            x86/ops_float.asm
            x86/ops_int.asm
            x86/range_convert.asm
        )
    endif()
endif()

# ============================================================================
# AArch64 assembly support
# ============================================================================
if(ARCH_AARCH64 AND ENABLE_ASM)
    list(APPEND swscale_sources
        aarch64/swscale.c
        aarch64/swscale_unscaled.c
        aarch64/rgb2rgb.c
    )
    # Add aarch64 assembly (.S) files - all are NEON-OBJS per Makefile
    if(HAVE_NEON)
        list(APPEND swscale_sources
            aarch64/hscale.S
            aarch64/input.S
            aarch64/output.S
            aarch64/range_convert_neon.S
            aarch64/rgb2rgb_neon.S
            aarch64/swscale_unscaled_neon.S
            aarch64/xyz2rgb_neon.S
            aarch64/yuv2rgb_neon.S
        )
    endif()
endif()

# ============================================================================
# ARM assembly support
# ============================================================================
if(ARCH_ARM AND ENABLE_ASM)
    list(APPEND swscale_sources
        arm/swscale.c
    )
endif()

# ============================================================================
# Vulkan support
# ============================================================================
if(CONFIG_VULKAN)
    list(APPEND swscale_sources
        vulkan/ops.c
        vulkan/vulkan.c
    )
    if(CONFIG_LIBSHADERC)
        list(APPEND swscale_sources vulkan/vulkan_shaderc.c)
    endif()
    if(CONFIG_LIBGLSLANG)
        list(APPEND swscale_sources vulkan/vulkan_glslang.c)
    endif()
endif()

# ============================================================================
# Only add sources that actually exist
# ============================================================================
set(swscale_existing "")
foreach(src IN LISTS swscale_sources)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND swscale_existing "${src}")
    endif()
endforeach()

# ============================================================================
# Create the library
# ============================================================================
add_library(swscale STATIC ${swscale_existing})

# Set include directories
target_include_directories(swscale
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Add source directory as NASM include path for each .asm file
# (mimics FFmpeg Makefile's -I$(<D)/ behavior)
if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)
    nasm_add_source_dir_includes(swscale)
endif()

# Link dependencies
target_link_libraries(swscale
    PUBLIC
        avutil
)

# Compiler definitions
target_compile_definitions(swscale PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_swscale
)

# Position independent code for shared builds
set_pic_if_needed(swscale)

# Set output name
set_target_properties(swscale PROPERTIES
    OUTPUT_NAME swscale
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

message(STATUS "libswscale configured")
