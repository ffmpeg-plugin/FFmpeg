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

if(MSVC)
    # MSVC: use /std:c17 to enable C17 standard (includes C11 atomics support)
    # Do not set CMAKE_C_STANDARD; control the standard directly via compiler flags
    add_compile_options($<$<COMPILE_LANGUAGE:C>:/std:c17>)
    add_compile_options($<$<COMPILE_LANGUAGE:CXX>:/std:c++17>)
else()
    set(CMAKE_C_STANDARD 17)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    set(CMAKE_C_EXTENSIONS ON)
endif()

# Common macro definitions
add_compile_definitions(
    _ISOC11_SOURCE
    _FILE_OFFSET_BITS=64
    _LARGEFILE_SOURCE
    ZLIB_CONST
)

# ============================================================================
# Platform-specific defines and include paths
# ============================================================================

if(WIN32)
    # Windows-specific macro definitions (corresponds to configure --toolchain=msvc CPPFLAGS)
    add_compile_definitions(
        WIN32_LEAN_AND_MEAN
        _USE_MATH_DEFINES
        _CRT_SECURE_NO_WARNINGS
        _CRT_NONSTDC_NO_WARNINGS
        _WIN32_WINNT=0x0600
    )
    # On Windows, use compat/atomics/win32/stdatomic.h instead of the system stdatomic.h
    # This avoids requiring MSVC C11 atomics support (only available with /std:c11 or higher)
    include_directories(${CMAKE_SOURCE_DIR}/compat/atomics/win32)
elseif(APPLE)
    add_compile_definitions(PIC _DARWIN_C_SOURCE)
elseif(UNIX)
    add_compile_definitions(PIC _GNU_SOURCE _BSD_SOURCE _DEFAULT_SOURCE)
endif()

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

# ============================================================================
# Warning flags
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

elseif(MSVC)
    # MSVC warning flags (corresponds to configure --toolchain=msvc CFLAGS)
    add_compile_options(
        $<$<COMPILE_LANGUAGE:C,CXX>:/nologo>
        $<$<COMPILE_LANGUAGE:C,CXX>:/W3>
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4018>   # signed/unsigned mismatch
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4028>   # parameter mismatch
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4146>   # unary minus on unsigned
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4244>   # conversion, possible loss of data
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4267>   # size_t to int conversion
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4305>   # truncation from double to float
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4554>   # operator precedence
        $<$<COMPILE_LANGUAGE:C,CXX>:/wd4996>   # deprecated function
        $<$<COMPILE_LANGUAGE:C,CXX>:/utf-8>    # source/output charset UTF-8
    )
endif()

# ============================================================================
# Optimization flags (compiler-specific)
# ============================================================================
if(MSVC)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        # MSVC Debug: /Od (no optimization) + /Zi (debug info in PDB)
        add_compile_options(
            $<$<COMPILE_LANGUAGE:C,CXX>:/Od>
            $<$<COMPILE_LANGUAGE:C,CXX>:/Zi>
        )
        add_compile_definitions(DEBUG)
    else()
        # MSVC Release: /O2 (maximize speed)
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:/O2>)
    endif()
else()
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(
            $<$<COMPILE_LANGUAGE:C,CXX>:-O0>
            $<$<COMPILE_LANGUAGE:C,CXX>:-g3>
        )
        add_compile_definitions(DEBUG)
    else()
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-O3>)
    endif()
endif()

# ============================================================================
# ASAN support
# ============================================================================
if(FFMPEG_ENABLE_ASAN)
    if(MSVC)
        add_compile_options(
            $<$<COMPILE_LANGUAGE:C,CXX>:/fsanitize=address>
        )
    else()
        add_compile_options(
            $<$<COMPILE_LANGUAGE:C,CXX>:-fsanitize=address>
            $<$<COMPILE_LANGUAGE:C,CXX>:-fno-omit-frame-pointer>
        )
        add_link_options(-fsanitize=address)
    endif()
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
