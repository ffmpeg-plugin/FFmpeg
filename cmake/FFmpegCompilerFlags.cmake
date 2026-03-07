# FFmpeg Compiler Flags Module
# Sets compiler warning flags, optimization options, and defines

include(CheckCCompilerFlag)

message(STATUS "Configuring compiler flags...")

# Helper macro to add flag only if supported by C compiler
# Uses generator expression to ensure flag only applies to C/CXX, not ASM_NASM
macro(add_c_flag_if_supported flag)
    string(MAKE_C_IDENTIFIER "HAVE_FLAG_${flag}" flag_var)
    check_c_compiler_flag("${flag}" ${flag_var})
    if(${flag_var})
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:${flag}>)
    endif()
endmacro()

# ============================================================================
# Common defines and standards
# ============================================================================

cmake_policy(SET CMP0128 NEW)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

add_compile_definitions(
    _ISOC11_SOURCE
    _FILE_OFFSET_BITS=64
    _LARGEFILE_SOURCE
    PIC
    ZLIB_CONST
)

# ============================================================================
# Compat directory include paths
# ============================================================================
include_directories(
    ${CMAKE_SOURCE_DIR}/compat/stdbit
)
# dispatch_semaphore compat is only needed on Apple platforms
if(APPLE)
    include_directories(${CMAKE_SOURCE_DIR}/compat/dispatch_semaphore)
endif()

# Platform-specific defines
if(APPLE)
    add_compile_definitions(_DARWIN_C_SOURCE)
elseif(UNIX)
    add_compile_definitions(_GNU_SOURCE _BSD_SOURCE _DEFAULT_SOURCE)
endif()

# ============================================================================
# Warning flags (common to GCC and Clang)
# Use generator expressions to restrict flags to C/CXX only (not ASM_NASM)
# ============================================================================
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    add_compile_options(
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wall>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wdisabled-optimization>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wpointer-arith>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wredundant-decls>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wwrite-strings>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wtype-limits>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wundef>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wempty-body>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wmissing-prototypes>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wstrict-prototypes>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-parentheses>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-switch>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-format-zero-length>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-pointer-sign>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-unused-const-variable>
        $<$<COMPILE_LANGUAGE:C,CXX>:-fno-math-errno>
        $<$<COMPILE_LANGUAGE:C,CXX>:-fno-signed-zeros>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Werror=implicit-function-declaration>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Werror=missing-prototypes>
        $<$<COMPILE_LANGUAGE:C,CXX>:-Werror=return-type>
    )

    # GCC-specific flags
    if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
        add_c_flag_if_supported(-Wno-bool-operation)
        add_c_flag_if_supported(-Wno-char-subscripts)
        add_c_flag_if_supported(-Wno-maybe-uninitialized)
    endif()

    # Clang-specific flags
    if(CMAKE_C_COMPILER_ID MATCHES "Clang|AppleClang")
        add_c_flag_if_supported(-Qunused-arguments)
        add_c_flag_if_supported(-mstack-alignment=16)
        add_c_flag_if_supported(-Wno-bool-operation)
        add_c_flag_if_supported(-Wno-char-subscripts)
        add_c_flag_if_supported(-Wno-implicit-const-int-float-conversion)
        add_c_flag_if_supported(-Wno-microsoft-enum-forward-reference)
    endif()
endif()

# ============================================================================
# Optimization flags (C/CXX only)
# ============================================================================
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(
        $<$<COMPILE_LANGUAGE:C,CXX>:-O0>
        $<$<COMPILE_LANGUAGE:C,CXX>:-g3>
    )
    add_compile_definitions(DEBUG)
else()
    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-O3>)
endif()

# ============================================================================
# ASAN support
# ============================================================================
if(FFMPEG_ENABLE_ASAN)
    add_compile_options(
        $<$<COMPILE_LANGUAGE:C,CXX>:-fsanitize=address>
        $<$<COMPILE_LANGUAGE:C,CXX>:-fno-omit-frame-pointer>
    )
    add_link_options(-fsanitize=address)
endif()

# ============================================================================
# Position independent code
# ============================================================================
if(NOT WIN32)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# ============================================================================
# Architecture specific flags (auto-detected, not hardcoded)
# ============================================================================
# Note: SIMD flags are handled by FFmpegArch.cmake based on detected CPU features
# Do NOT hardcode -msse4.1 or similar here
