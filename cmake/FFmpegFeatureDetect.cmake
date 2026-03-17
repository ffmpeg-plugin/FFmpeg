# FFmpeg Feature Detection CMake Module
# Detects system headers, functions, types and compiler capabilities

include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckCSourceCompiles)
include(CheckStructHasMember)
include(CheckCCompilerFlag)

# =============================================================================
# Endian Detection
# =============================================================================
include(TestBigEndian)
test_big_endian(HAVE_BIGENDIAN)
if(HAVE_BIGENDIAN)
    set(AV_HAVE_BIGENDIAN 1)
else()
    set(AV_HAVE_BIGENDIAN 0)
endif()

# =============================================================================
# Pointer Size Detection
# =============================================================================
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(HAVE_64BIT 1)
else()
    set(HAVE_64BIT 0)
endif()

# =============================================================================
# Header File Checks
# =============================================================================

# POSIX headers
check_include_file("assert.h" HAVE_ASSERT_H)
check_include_file("arpa/inet.h" HAVE_ARPA_INET_H)
check_include_file("dlfcn.h" HAVE_DLFCN_H)
check_include_file("fcntl.h" HAVE_FCNTL_H)
check_include_file("io.h" HAVE_IO_H)
check_include_file("limits.h" HAVE_LIMITS_H)
check_include_file("malloc.h" HAVE_MALLOC_H)
check_include_file("poll.h" HAVE_POLL_H)
check_include_file("pthread.h" HAVE_PTHREAD_H)
check_include_file("signal.h" HAVE_SIGNAL_H)
check_include_file("stdatomic.h" HAVE_STDATOMIC_H)
check_include_file("stdint.h" HAVE_STDINT_H)
check_include_file("stdio.h" HAVE_STDIO_H)
check_include_file("stdlib.h" HAVE_STDLIB_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("sys/ioctl.h" HAVE_SYS_IOCTL_H)
check_include_file("sys/mman.h" HAVE_SYS_MMAN_H)
check_include_file("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file("sys/resource.h" HAVE_SYS_RESOURCE_H)
check_include_file("sys/select.h" HAVE_SYS_SELECT_H)
check_include_file("sys/socket.h" HAVE_SYS_SOCKET_H)
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("sys/uio.h" HAVE_SYS_UIO_H)
check_include_file("sys/wait.h" HAVE_SYS_WAIT_H)
check_include_file("time.h" HAVE_TIME_H)
check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_file("windows.h" HAVE_WINDOWS_H)
check_include_file("winsock2.h" HAVE_WINSOCK2_H)
check_include_file("ws2tcpip.h" HAVE_WS2TCPIP_H)

# Mach headers (macOS)
check_include_file("mach/mach_time.h" HAVE_MACH_MACH_TIME_H)
check_include_file("mach/mach_host.h" HAVE_MACH_MACH_HOST_H)
check_include_file("mach/host_info.h" HAVE_MACH_HOST_INFO_H)

# Video4Linux
check_include_file("linux/videodev2.h" HAVE_LINUX_VIDEODEV2_H)

# OpenCL
check_include_file("CL/cl.h" HAVE_CL_CL_H)
if(NOT HAVE_CL_CL_H)
    check_include_file("OpenCL/cl.h" HAVE_OPENCL_CL_H)
endif()

# CUDA
check_include_file("cuda.h" HAVE_CUDA_H)

# Vulkan
check_include_file("vulkan/vulkan.h" HAVE_VULKAN_VULKAN_H)

# =============================================================================
# Function Checks
# =============================================================================

# Math functions need -lm on Linux
if(UNIX AND NOT APPLE)
    set(CMAKE_REQUIRED_LIBRARIES m)
endif()

# Helper macro for math function detection using source compilation
# Uses a wrapper function to avoid issues with macros that expand to builtins
macro(check_math_func func var)
    check_c_source_compiles("
        #define _GNU_SOURCE
        #include <math.h>
        double ff_check_math_func(void);
        double ff_check_math_func(void) { return (double)${func}((double)0); }
        int main(void) { return (int)ff_check_math_func(); }
    " ${var})
    if(NOT ${var})
        set(${var} 0)
    endif()
endmacro()

# For two-argument math functions (hypot, copysign, atan2f etc)
macro(check_math_func2 func var)
    check_c_source_compiles("
        #define _GNU_SOURCE
        #include <math.h>
        double ff_check_math_func2(void);
        double ff_check_math_func2(void) { return (double)${func}((double)0, (double)0); }
        int main(void) { return (int)ff_check_math_func2(); }
    " ${var})
    if(NOT ${var})
        set(${var} 0)
    endif()
endmacro()

# For classification macros (isinf/isnan/isfinite) use int return type
macro(check_math_macro func var)
    check_c_source_compiles("
        #define _GNU_SOURCE
        #include <math.h>
        int main(void) { int r = ${func}(0.0); return r; }
    " ${var})
    if(NOT ${var})
        set(${var} 0)
    endif()
endmacro()

check_math_func(atanf HAVE_ATANF)
check_math_func2(atan2f HAVE_ATAN2F)
check_math_func(cbrt HAVE_CBRT)
check_math_func(cbrtf HAVE_CBRTF)
check_math_func2(copysign HAVE_COPYSIGN)
check_math_func(cosf HAVE_COSF)
check_math_func(erf HAVE_ERF)
check_math_func(erfc HAVE_ERFC)
check_math_func(exp2 HAVE_EXP2)
check_math_func(exp2f HAVE_EXP2F)
check_math_func(expf HAVE_EXPF)
check_math_func(fma HAVE_FMA)
check_math_func2(hypot HAVE_HYPOT)
check_math_macro(isinf HAVE_ISINF)
check_math_macro(isfinite HAVE_ISFINITE)
check_math_macro(isnan HAVE_ISNAN)
check_math_func(ldexpf HAVE_LDEXPF)
check_math_func(lgamma HAVE_LGAMMA)
check_math_func(llrint HAVE_LLRINT)
check_math_func(llrintf HAVE_LLRINTF)
check_math_func(log2 HAVE_LOG2)
check_math_func(log2f HAVE_LOG2F)
check_math_func(log10f HAVE_LOG10F)
check_math_func(lrint HAVE_LRINT)
check_math_func(lrintf HAVE_LRINTF)
check_math_func(lround HAVE_LROUND)
check_math_func(lroundf HAVE_LROUNDF)
check_math_func(powf HAVE_POWF)
check_math_func(rint HAVE_RINT)
check_math_func(round HAVE_ROUND)
check_math_func(roundf HAVE_ROUNDF)
check_math_func(sincos HAVE_SINCOS)
check_math_func(sinf HAVE_SINF)
check_math_func(sqrtf HAVE_SQRTF)
check_math_func(trunc HAVE_TRUNC)
check_math_func(truncf HAVE_TRUNCF)

# Standard C functions (non-math)
check_function_exists(aligned_alloc HAVE_ALIGNED_ALLOC)
check_function_exists(clock_gettime HAVE_CLOCK_GETTIME)
check_function_exists(getaddrinfo HAVE_GETADDRINFO)
check_function_exists(getauxval HAVE_GETAUXVAL)
check_function_exists(getenv HAVE_GETENV)
check_function_EXISTS(gethrtime HAVE_GETHRTIME)
check_function_exists(getopt HAVE_GETOPT)
check_function_exists(getpeername HAVE_GETPEERNAME)
check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
check_function_exists(isatty HAVE_ISATTY)
check_function_exists(localtime_r HAVE_LOCALTIME_R)
check_function_exists(malloc_usable_size HAVE_MALLOC_USABLE_SIZE)
check_function_exists(mmap HAVE_MMAP)
check_function_exists(mprotect HAVE_MPROTECT)
check_function_exists(nanosleep HAVE_NANOSLEEP)
check_function_exists(pclose HAVE_PCLOSE)
check_function_exists(popen HAVE_POPEN)
check_function_exists(posix_memalign HAVE_POSIX_MEMALIGN)
check_function_exists(setrlimit HAVE_SETRLIMIT)
check_function_exists(snprintf HAVE_SNPRINTF)
check_function_exists(strerror_r HAVE_STRERROR_R)
check_function_exists(sysconf HAVE_SYSCONF)
check_function_exists(times HAVE_TIMES)

# Windows-specific functions
if(WIN32)
    check_function_exists(setmode HAVE_SETMODE)
    check_function_exists(_aligned_malloc HAVE_ALIGNED_MALLOC)
    check_function_exists(GetProcessAffinityMask HAVE_GETPROCESSAFFINITYMASK)
    check_function_exists(GetProcessMemoryInfo HAVE_GETPROCESSMEMORYINFO)
    check_function_exists(GetStdHandle HAVE_GETSTDHANDLE)
    check_function_exists(SetConsoleTextAttribute HAVE_SETCONSOLETEXTATTRIBUTE)
    check_function_exists(SetConsoleCtrlHandler HAVE_SETCONSOLECTRLHANDLER)
    check_function_exists(ConditionVariable SRWLOCK HAVE_SRWLOCK)
    check_function_exists(CreateSemaphore HAVE_CREATESEMAPHORE)
    check_function_exists(CreateThreadpoolTimer HAVE_CREATETHREADPOOLTIMER)
    check_function_exists(CreateWaitableTimerEx HAVE_CREATEWAITABLETIMEREX)

    # Additional Windows functions needed by FFmpeg
    check_function_exists(CommandLineToArgvW HAVE_COMMANDLINETOARGVW)
    check_function_exists(GetModuleHandle HAVE_GETMODULEHANDLE)
    check_function_exists(LoadLibrary HAVE_LOADLIBRARY)
    check_function_exists(SetDllDirectory HAVE_SETDLLDIRECTORY)

    # Windows functions that need explicit checking
    check_function_exists(_access HAVE_ACCESS)
    check_function_exists(_kbhit HAVE_KBHIT)
    check_function_exists(GetProcessTimes HAVE_GETPROCESSTIMES)
    check_function_exists(GetSystemTimeAsFileTime HAVE_GETSYSTEMTIMEASFILETIME)
    check_function_exists(MapViewOfFile HAVE_MAPVIEWOFFILE)
    check_function_exists(VirtualAlloc HAVE_VIRTUALALLOC)

    # Windows Winsock2 network structures and functions
    # These are always available on Windows via winsock2.h / ws2tcpip.h
    # Force-set them to 1 to avoid CMake cache issues
    set(HAVE_STRUCT_SOCKADDR_STORAGE 1)
    set(HAVE_STRUCT_ADDRINFO 1)
    set(HAVE_STRUCT_POLLFD 1)
    set(HAVE_GETADDRINFO 1)
    set(HAVE_CLOSESOCKET 1)
    set(HAVE_SOCKLEN_T 1)
    set(HAVE_STRUCT_SOCKADDR_IN6 1)
    set(HAVE_STRUCT_IPV6_MREQ 1)
    set(HAVE_STRUCT_IP_MREQ_SOURCE 1)
    set(HAVE_STRUCT_GROUP_SOURCE_REQ 1)

    set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES_SAVED})

    # Windows-specific headers that are always present on MSVC
    set(HAVE_DIRECT_H 1)   # <direct.h> - _mkdir, _wmkdir, _rmdir, _wrmdir
    set(HAVE_IO_H 1)       # <io.h> - _open, _close, _read, _write etc.
    set(HAVE_WINDOWS_H 1)  # <windows.h>
    set(HAVE_SHELLAPI_H 1) # <shellapi.h>

    # Check for DX headers (DirectX graphics)
    check_include_file("dxgidebug.h" HAVE_DXGIDEBUG_H)
    check_include_file("dxva.h" HAVE_DXVA_H)

    # Check for bcrypt (Windows cryptography)
    check_c_source_compiles("
        #include <windows.h>
        #include <bcrypt.h>
        int main(void) {
            BCRYPT_ALG_HANDLE hAlg;
            NTSTATUS status = BCryptOpenAlgorithmProvider(&hAlg, BCRYPT_SHA256_ALGORITHM, NULL, 0);
            return 0;
        }
    " HAVE_BCRYPT)

    # DPI awareness context (Windows 10+)
    check_c_source_compiles("
        #include <windows.h>
        int main(void) {
            DPI_AWARENESS_CONTEXT ctx = DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2;
            return 0;
        }
    " HAVE_DPI_AWARENESS_CONTEXT)

    # IDXGIOutput5 (DirectX 12)
    check_c_source_compiles("
        #include <dxgi1_5.h>
        int main(void) {
            IDXGIOutput5* pOutput = NULL;
            return 0;
        }
    " HAVE_IDXGIOUTPUT5)

    # SECPKGCONTEXT_KEYINGMATERIALINFO (Windows security)
    check_c_source_compiles("
        #include <windows.h>
        #include <sspi.h>
        int main(void) {
            SecPkgContext_KeyingMaterialInfo info;
            return 0;
        }
    " HAVE_SECPKGCONTEXT_KEYINGMATERIALINFO)

    # pragma deprecated is supported by MSVC
    set(HAVE_PRAGMA_DEPRECATED 1)

    # rsync --contimeout is available on most systems
    set(HAVE_RSYNC_CONTIMEOUT 1)

    # access() function on Windows
    set(HAVE_ACCESS 1)
else()
    set(HAVE_SETMODE 0)
    set(HAVE_ALIGNED_MALLOC 0)
    set(HAVE_GETPROCESSAFFINITYMASK 0)
    set(HAVE_GETPROCESSMEMORYINFO 0)
    set(HAVE_GETSTDHANDLE 0)
    set(HAVE_SETCONSOLETEXTATTRIBUTE 0)
    set(HAVE_SETCONSOLECTRLHANDLER 0)
    set(HAVE_SRWLOCK 0)
    set(HAVE_CREATESEMAPHORE 0)
    set(HAVE_CREATETHREADPOOLTIMER 0)
    set(HAVE_CREATEWAITABLETIMEREX 0)
    set(HAVE_COMMANDLINETOARGVW 0)
    set(HAVE_GETMODULEHANDLE 0)
    set(HAVE_LOADLIBRARY 0)
    set(HAVE_SETDLLDIRECTORY 0)
    set(HAVE_DIRECT_H 0)
    set(HAVE_IO_H 0)
    set(HAVE_WINDOWS_H 0)
    set(HAVE_SHELLAPI_H 0)

    # POSIX network structures (non-Windows)
    check_c_source_compiles("
        #include <sys/socket.h>
        int main(void) {
            struct sockaddr_storage ss;
            (void)ss;
            return 0;
        }
    " HAVE_STRUCT_SOCKADDR_STORAGE)
    if(NOT HAVE_STRUCT_SOCKADDR_STORAGE)
        set(HAVE_STRUCT_SOCKADDR_STORAGE 0)
    endif()

    check_c_source_compiles("
        #include <netdb.h>
        int main(void) {
            struct addrinfo ai;
            (void)ai;
            return 0;
        }
    " HAVE_STRUCT_ADDRINFO)
    if(NOT HAVE_STRUCT_ADDRINFO)
        set(HAVE_STRUCT_ADDRINFO 0)
    endif()

    check_c_source_compiles("
        #include <poll.h>
        int main(void) {
            struct pollfd pfd;
            pfd.fd = 0;
            pfd.events = POLLIN;
            (void)pfd;
            return 0;
        }
    " HAVE_STRUCT_POLLFD)
    if(NOT HAVE_STRUCT_POLLFD)
        set(HAVE_STRUCT_POLLFD 0)
    endif()

    check_c_source_compiles("
        #include <netdb.h>
        int main(void) {
            struct addrinfo *res = NULL;
            getaddrinfo(\"localhost\", NULL, NULL, &res);
            return 0;
        }
    " HAVE_GETADDRINFO)
    if(NOT HAVE_GETADDRINFO)
        set(HAVE_GETADDRINFO 0)
    endif()
endif()

# =============================================================================
# System Capability Checks
# =============================================================================

# Check for fast unaligned access (common on x86)
if(FFMPEG_ARCH MATCHES "^(x86|x86_64|amd64)$")
    set(HAVE_FAST_UNALIGNED 1)
    set(AV_HAVE_FAST_UNALIGNED 1)
else()
    # ARM may not have fast unaligned access
    if(APPLE OR FFMPEG_ARCH MATCHES "aarch64")
        # Modern ARM64 usually supports unaligned access well
        set(HAVE_FAST_UNALIGNED 1)
        set(AV_HAVE_FAST_UNALIGNED 1)
    else()
        set(HAVE_FAST_UNALIGNED 0)
        set(AV_HAVE_FAST_UNALIGNED 0)
    endif()
endif()

# Check for atomics support
check_c_source_compiles("
    #include <stdatomic.h>
    int main() {
        atomic_int x;
        atomic_init(&x, 0);
        atomic_fetch_add(&x, 1);
        return 0;
    }
" HAVE_C11_ATOMICS)

# Check for GCC-style atomics
check_c_source_compiles("
    int main() {
        int x = 0;
        __atomic_fetch_add(&x, 1, __ATOMIC_SEQ_CST);
        return 0;
    }
" HAVE_GCC_ATOMICS)

# Check for unistd.h with _SC_NPROCESSORS_ONLN
check_c_source_compiles("
    #include <unistd.h>
    int main() {
        int n = sysconf(_SC_NPROCESSORS_ONLN);
        return 0;
    }
" HAVE_SC_NPROCESSORS_ONLN)

# Check for getrusage
check_c_source_compiles("
    #include <sys/resource.h>
    #include <sys/time.h>
    int main() {
        struct rusage ru;
        getrusage(RUSAGE_SELF, &ru);
        return 0;
    }
" HAVE_GETRUSAGE)

# Check for sched_getaffinity
check_c_source_compiles("
    #include <sched.h>
    int main() {
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        return 0;
    }
" HAVE_SCHED_GETAFFINITY)

# Check for pthread_setname_np (needs _GNU_SOURCE on Linux)
set(CMAKE_REQUIRED_DEFINITIONS_SAVED ${CMAKE_REQUIRED_DEFINITIONS})
if(UNIX AND NOT APPLE)
    set(CMAKE_REQUIRED_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE)
endif()
check_c_source_compiles("
    #include <pthread.h>
    int main() {
        pthread_setname_np(pthread_self(), \"test\");
        return 0;
    }
" HAVE_PTHREAD_SETNAME_NP)
set(CMAKE_REQUIRED_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS_SAVED})

# Check for pthread_set_qos_class_self_np (macOS)
check_c_source_compiles("
    #include <pthread/qos.h>
    int main() {
        pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);
        return 0;
    }
" HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP)

# Check for kqueue (BSD/macOS)
check_c_source_compiles("
    #include <sys/types.h>
    #include <sys/event.h>
    #include <sys/time.h>
    int main() {
        int kq = kqueue();
        return 0;
    }
" HAVE_KQUEUE)

# Check for epoll (Linux)
check_c_source_compiles("
    #include <sys/epoll.h>
    int main() {
        int ep = epoll_create1(0);
        return 0;
    }
" HAVE_EPOLL)

# Check for dispatch_semaphore (macOS/iOS)
check_c_source_compiles("
    #include <dispatch/dispatch.h>
    int main() {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        return 0;
    }
" HAVE_DISPATCH_SEMAPHORE)

# Check for dispatch_group (macOS/iOS)
check_c_source_compiles("
    #include <dispatch/dispatch.h>
    int main() {
        dispatch_group_t group = dispatch_group_create();
        return 0;
    }
" HAVE_DISPATCH_GROUP)

# Check for Windows ConditionVariable support
check_c_source_compiles("
    #include <windows.h>
    int main() {
        CONDITION_VARIABLE cv;
        InitializeConditionVariable(&cv);
        return 0;
    }
" HAVE_WIN32_CONDVAR)

# =============================================================================
# Thread Local Storage Detection
# =============================================================================

# Check for thread_local/_Thread_local
set(CMAKE_REQUIRED_FLAGS_SAVE ${CMAKE_REQUIRED_FLAGS})
check_c_source_compiles("
    static _Thread_local int x = 0;
    int main() { return x; }
" HAVE_THREAD_LOCAL_C11)

check_c_source_compiles("
    static __thread int x = 0;
    int main() { return x; }
" HAVE___THREAD)

check_c_source_compiles("
    static __declspec(thread) int x = 0;
    int main() { return x; }
" HAVE_DECLSPEC_THREAD)
set(CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS_SAVE})

# =============================================================================
# SIMD Intrinsics Detection (for C code, not assembly)
# =============================================================================

# These are separate from the assembly detection in FFmpegArch.cmake
# They detect if the compiler supports intrinsics for SIMD operations

# SSE
check_c_source_compiles("
    #include <xmmintrin.h>
    int main() {
        __m128 x = _mm_setzero_ps();
        x = _mm_add_ps(x, x);
        return 0;
    }
" HAVE_SSE_INTRINSICS)

# SSE2
check_c_source_compiles("
    #include <emmintrin.h>
    int main() {
        __m128i x = _mm_setzero_si128();
        x = _mm_add_epi32(x, x);
        return 0;
    }
" HAVE_SSE2_INTRINSICS)

# SSE4.1
check_c_source_compiles("
    #include <smmintrin.h>
    int main() {
        __m128i x = _mm_setzero_si128();
        x = _mm_mullo_epi32(x, x);
        return 0;
    }
" HAVE_SSE4_INTRINSICS)

# AVX
check_c_source_compiles("
    #include <immintrin.h>
    int main() {
        __m256 x = _mm256_setzero_ps();
        x = _mm256_add_ps(x, x);
        return 0;
    }
" HAVE_AVX_INTRINSICS)

# AVX-512
check_c_source_compiles("
    #include <immintrin.h>
    int main() {
        __m512i x = _mm512_setzero_si512();
        x = _mm512_add_epi32(x, x);
        return 0;
    }
" HAVE_AVX512_INTRINSICS)

# AArch64 NEON (intrinsics)
check_c_source_compiles("
    #include <arm_neon.h>
    int main() {
        float32x4_t x = vdupq_n_f32(0.0f);
        x = vaddq_f32(x, x);
        return 0;
    }
" HAVE_NEON_INTRINSICS)

# =============================================================================
# Compiler Attribute Checks
# =============================================================================

# packed attribute
check_c_source_compiles("
    struct __attribute__((packed)) test { char a; int b; };
    int main() { return 0; }
" HAVE_ATTRIBUTE_PACKED)

# aligned attribute
check_c_source_compiles("
    struct __attribute__((aligned(16))) test { int a; };
    int main() { return 0; }
" HAVE_ATTRIBUTE_ALIGNED)

# visibility attribute
check_c_source_compiles("
    __attribute__((visibility(\"hidden\"))) void test(void);
    int main() { return 0; }
" HAVE_ATTRIBUTE_VISIBILITY)

# dllexport/dllimport
check_c_source_compiles("
    __declspec(dllexport) void test(void);
    int main() { return 0; }
" HAVE_DECLSPEC_DLLEXPORT)

# =============================================================================
# Complex Number Support
# =============================================================================

check_c_source_compiles("
    #include <complex.h>
    int main() {
        float complex c = 1.0f + 2.0if;
        float r = crealf(c);
        return 0;
    }
" HAVE_COMPLEX)

# =============================================================================
# Summary
# =============================================================================

message(STATUS "Feature detection complete")
message(STATUS "  Big endian: ${HAVE_BIGENDIAN}")
message(STATUS "  64-bit build: ${HAVE_64BIT}")
message(STATUS "  Fast unaligned: ${HAVE_FAST_UNALIGNED}")

# =============================================================================
# Inline Assembly Support
# =============================================================================
# MSVC does NOT support GCC-style inline asm (__asm__ volatile)
# GCC/Clang support it natively
if(MSVC)
    set(HAVE_INLINE_ASM 0)
    set(HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS 0)
    set(HAVE_INLINE_ASM_LABELS 0)
    set(HAVE_INLINE_ASM_NONLOCAL_LABELS 0)
else()
    # Check for GCC-style inline asm
    check_c_source_compiles("
        int main(void) {
            int x = 0;
            __asm__ volatile(\"\" : \"+r\"(x));
            return x;
        }
    " HAVE_INLINE_ASM)
    if(NOT HAVE_INLINE_ASM)
        set(HAVE_INLINE_ASM 0)
    endif()
    # Check for direct symbol refs in inline asm
    check_c_source_compiles("
        void test_func(void) {}
        int main(void) {
            __asm__ volatile(\"call test_func\" ::: \"memory\");
            return 0;
        }
    " HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS)
    if(NOT HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS)
        set(HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS 0)
    endif()
    # Check for labels in inline asm
    check_c_source_compiles("
        int main(void) {
            __asm__ volatile(\"0: jmp 0b\" :::);
            return 0;
        }
    " HAVE_INLINE_ASM_LABELS)
    if(NOT HAVE_INLINE_ASM_LABELS)
        set(HAVE_INLINE_ASM_LABELS 0)
    endif()
    # Check for nonlocal labels in inline asm
    check_c_source_compiles("
        int main(void) {
            __asm__ volatile(\".Ltest_label: nop\" :::);
            return 0;
        }
    " HAVE_INLINE_ASM_NONLOCAL_LABELS)
    if(NOT HAVE_INLINE_ASM_NONLOCAL_LABELS)
        set(HAVE_INLINE_ASM_NONLOCAL_LABELS 0)
    endif()
endif()
message(STATUS "  Inline ASM: ${HAVE_INLINE_ASM}")
