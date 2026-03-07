# libswresample CMakeLists.txt
# FFmpeg audio resampling library

set(SWRESAMPLE_HEADERS
    swresample.h
    version.h
    version_major.h
)

# Source files
set(SWRESAMPLE_SOURCES
    audioconvert.c
    dither.c
    options.c
    rematrix.c
    resample.c
    resample_dsp.c
    swresample.c
    swresample_frame.c
    version.c
)

# AArch64 assembly support
if(ARCH_AARCH64 AND ENABLE_ASM)
    list(APPEND SWRESAMPLE_SOURCES
        aarch64/audio_convert_init.c
        aarch64/resample_init.c
    )
    # Add assembly files
    list(APPEND SWRESAMPLE_SOURCES
        aarch64/audio_convert_neon.S
        aarch64/resample.S
    )
endif()

# ARM assembly support
if(ARCH_ARM AND ENABLE_ASM)
    list(APPEND SWRESAMPLE_SOURCES
        arm/audio_convert_init.c
        arm/resample_init.c
    )
    # Add assembly files
    list(APPEND SWRESAMPLE_SOURCES
        arm/audio_convert_neon.S
        arm/resample.S
    )
endif()

# x86 assembly support
if((ARCH_X86_64 OR ARCH_X86) AND ENABLE_ASM)
    if(NASM_FOUND)
        list(APPEND SWRESAMPLE_SOURCES
            x86/audio_convert_init.c
            x86/rematrix_init.c
            x86/resample_init.c
        )
        # Add NASM assembly files
        list(APPEND SWRESAMPLE_SOURCES
            x86/audio_convert.asm
            x86/rematrix.asm
            x86/resample.asm
        )
    endif()
endif()

# Create the library
add_library(swresample STATIC ${SWRESAMPLE_SOURCES})

# Set include directories
target_include_directories(swresample
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Add source directory as NASM include path for each .asm file
if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)
    nasm_add_source_dir_includes(swresample)
endif()

# Link dependencies - swresample only depends on avutil
target_link_libraries(swresample
    PUBLIC
        avutil
)

# Compiler definitions
target_compile_definitions(swresample PRIVATE 
    HAVE_AV_CONFIG_H
    BUILDING_swresample
)

# Position independent code for shared builds
set_pic_if_needed(swresample)

# Set output name
set_target_properties(swresample PROPERTIES
    OUTPUT_NAME swresample
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# Generate allfilters.c (if needed, placeholder)
# file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/allfilters.c "...")

# Export configuration
set(CONFIG_swresample 1 PARENT_SCOPE)

message(STATUS "libswresample configured")
