# FFmpeg CMake Utilities
# Helper functions and macros for FFmpeg CMake build

# =============================================================================
# Source List Parsing from Makefile-style lists
# =============================================================================

# Function to parse OBJS lists from Makefiles like libavcodec/Makefile
function(parse_makefile_objs file_path out_var)
    set(SOURCES "")

    if(NOT EXISTS "${file_path}")
        set(${out_var} "" PARENT_SCOPE)
        return()
    endif()

    file(STRINGS "${file_path}" lines)
    set(in_objs_section FALSE)
    set(current_line "")

    foreach(line ${lines})
        # Check if starting OBJS section
        if(line MATCHES "^OBJS\\s*=")
            set(in_objs_section TRUE)
            string(REGEX REPLACE "^OBJS\\s*=" "" line "${line}")
        endif()

        if(NOT in_objs_section)
            continue()
        endif()

        # Remove comment
        string(REGEX REPLACE "#.*$" "" line "${line}")

        # Concatenate to current line (handle continuation)
        string(STRIP "${line}" line)
        string(APPEND current_line "${line}")

        # Check for continuation backslash
        if(current_line MATCHES "\\\\$")
            string(REGEX REPLACE "\\\\$" "" current_line "${current_line}")
            continue()
        endif()

        # Now we have a complete line, parse it
        if(current_line MATCHES "^OBJS\\-\\$")
            # End of base OBJS, start of conditional
            break()
        endif()

        # Extract source files
        string(REGEX MATCHALL "[a-zA-Z0-9_/-]+\\.[cS]" files "${current_line}")
        list(APPEND SOURCES ${files})

        set(current_line "")
    endforeach()

    # Remove empty entries and duplicates
    list(REMOVE_DUPLICATES SOURCES)
    list(REMOVE_ITEM SOURCES "")

    set(${out_var} ${SOURCES} PARENT_SCOPE)
endfunction()

# =============================================================================
# Architecture-specific Source Selection
# =============================================================================

# Function to add architecture-specific assembly sources
function(add_arch_sources target arch base_dir sources_var)
    set(sources ${${sources_var}})
    set(asm_sources "")

    if(arch STREQUAL "x86_64" OR arch STREQUAL "x86")
        if(ENABLE_ASM AND NASM_FOUND)
            # x86/x86_64 assembly
            file(GLOB_RECURSE nasm_sources
                "${CMAKE_CURRENT_SOURCE_DIR}/${base_dir}/x86/*.asm")
            list(APPEND asm_sources ${nasm_sources})
        endif()
    elseif(arch STREQUAL "aarch64")
        if(ENABLE_ASM)
            # AArch64 assembly
            file(GLOB_RECURSE arm_sources
                "${CMAKE_CURRENT_SOURCE_DIR}/${base_dir}/aarch64/*.S")
            list(APPEND asm_sources ${arm_sources})
        endif()
    elseif(arch STREQUAL "arm")
        if(ENABLE_ASM)
            # ARM assembly
            file(GLOB_RECURSE arm_sources
                "${CMAKE_CURRENT_SOURCE_DIR}/${base_dir}/arm/*.S")
            list(APPEND asm_sources ${arm_sources})
        endif()
    endif()

    # Add assembly sources to target
    if(asm_sources)
        target_sources(${target} PRIVATE ${asm_sources})
    endif()
endfunction()

# =============================================================================
# Dependency Management
# =============================================================================

# Function to setup library dependencies with proper linker order
function(ffmpeg_link_libraries target)
    # FFmpeg libraries need to be linked in reverse dependency order
    # avutil is always last as all other libs depend on it

    set(ffmpeg_libs "")

    if(TARGET avfilter AND ENABLE_AVFILTER)
        list(APPEND ffmpeg_libs avfilter)
    endif()
    if(TARGET avformat AND ENABLE_AVFORMAT)
        list(APPEND ffmpeg_libs avformat)
    endif()
    if(TARGET avcodec AND ENABLE_AVCODEC)
        list(APPEND ffmpeg_libs avcodec)
    endif()
    if(TARGET swscale AND ENABLE_SWSCALE)
        list(APPEND ffmpeg_libs swscale)
    endif()
    if(TARGET swresample AND ENABLE_SWRESAMPLE)
        list(APPEND ffmpeg_libs swresample)
    endif()
    if(TARGET avdevice AND ENABLE_AVDEVICE)
        list(APPEND ffmpeg_libs avdevice)
    endif()
    # avutil always last
    list(APPEND ffmpeg_libs avutil)

    target_link_libraries(${target} PRIVATE ${ffmpeg_libs})
endfunction()

# =============================================================================
# Header Installation
# =============================================================================

# Function to install FFmpeg library headers
function(install_ffmpeg_headers lib_name)
    set(header_dir "${CMAKE_SOURCE_DIR}/${lib_name}")

    # Find public headers (not internal ones)
    file(GLOB headers "${header_dir}/*.h")

    # Filter out internal headers
    set(public_headers "")
    foreach(header ${headers})
        get_filename_component(filename "${header}" NAME)

        # Skip internal headers (typically containing "internal" in name)
        if(filename MATCHES "internal")
            continue()
        endif()

        list(APPEND public_headers "${header}")
    endforeach()

    # Install headers
    install(FILES ${public_headers} DESTINATION "include/${lib_name}")
endfunction()

# =============================================================================
# Version Generation
# =============================================================================

# Function to generate library version header
function(generate_version_header lib_name version_major version_minor version_micro)
    string(TOUPPER "${lib_name}" lib_upper)

    set(version_h "${CMAKE_BINARY_DIR}/${lib_name}/version.h")

    file(WRITE "${version_h}" "/* Automatically generated - DO NOT EDIT */
#ifndef ${lib_upper}_VERSION_H
#define ${lib_upper}_VERSION_H

#define ${lib_upper}_VERSION_MAJOR ${version_major}
#define ${lib_upper}_VERSION_MINOR ${version_minor}
#define ${lib_upper}_VERSION_MICRO ${version_micro}
#define ${lib_upper}_VERSION_INT AV_VERSION_INT(${version_major}, ${version_minor}, ${version_micro})

#endif /* ${lib_upper}_VERSION_H */")
endfunction()

# =============================================================================
# Compiler Flag Helpers
# =============================================================================

# Function to check and add compiler flag if supported
function(add_c_flag_if_supported flag)
    string(REGEX REPLACE "[^a-zA-Z0-9]" "_" flag_var "HAVE_FLAG_${flag}")
    check_c_compiler_flag("${flag}" ${flag_var})
    if(${flag_var})
        add_compile_options(${flag})
    endif()
endfunction()

# Function to set position-independent code flags if needed
function(set_pic_if_needed target)
    if(ENABLE_SHARED)
        set_target_properties(${target} PROPERTIES
            POSITION_INDEPENDENT_CODE ON
        )
    endif()
endfunction()

# =============================================================================
# Source File Helpers
# =============================================================================

# Function to convert .c file list to object list for dependency tracking
function(c_to_o source_list out_var)
    set(objects "")
    foreach(src ${source_list})
        get_filename_component(base "${src}" NAME_WE)
        list(APPEND objects "${base}.o")
    endforeach()
    set(${out_var} ${objects} PARENT_SCOPE)
endfunction()

# Function to find all C/ASM sources in a directory
function(find_sources dir out_var)
    file(GLOB_RECURSE sources
        "${dir}/*.c"
        "${dir}/*.S"
        "${dir}/*.asm"
    )
    set(${out_var} ${sources} PARENT_SCOPE)
endfunction()

# =============================================================================
# Build Type Configuration
# =============================================================================

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    if(ENABLE_DEBUG)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
    else()
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
    endif()
endif()

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
