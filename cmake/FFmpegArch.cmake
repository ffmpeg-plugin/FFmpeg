# FFmpegArch.cmake - Architecture and SIMD detection
#
# This module detects the target architecture and available SIMD extensions.
# It sets variables for ARCH_* and HAVE_* macros that will be used in config.h.

include(CheckCSourceCompiles)
include(CheckCSourceRuns)

# =============================================================================
# Handle --disable-asm equivalent
# =============================================================================
# When assembly is disabled, FFmpeg sets arch=c and disables all ARCH_* variables
# This matches configure behavior: enabled asm || { arch=c; disable $ARCH_LIST $ARCH_EXT_LIST; }

if(NOT ENABLE_ASM)
    message(STATUS "Assembly optimizations disabled (ENABLE_ASM=OFF)")
    message(STATUS "Setting architecture to 'c' (generic C implementation)")
    
    # Set architecture to 'c' - this disables all architecture-specific code paths
    set(FFMPEG_ARCH "c")
    
    # Disable all architecture flags - this prevents #if ARCH_AARCH64 etc. from triggering
    foreach(arch AARCH64 ARM IA64 LOONGARCH LOONGARCH32 LOONGARCH64 M68K MIPS MIPS64
                PARISC PPC PPC64 RISCV S390 SPARC SPARC64 TILEGX TILEPRO WASM X86 X86_32 X86_64)
        set(ARCH_${arch} 0)
    endforeach()
    
    # Disable all SIMD extensions
    # ARM SIMD flags
    foreach(ext ARMV5TE ARMV6 ARMV6T2 ARMV8 ARM_CRC DOTPROD I8MM NEON VFP VFPV3 SETEND SVE SVE2 SME SME_I16I64 SME2)
        set(HAVE_${ext} 0)
        set(HAVE_${ext}_EXTERNAL 0)
        set(HAVE_${ext}_INLINE 0)
    endforeach()
    
    # x86 SIMD flags
    foreach(ext AESNI CLMUL AMD3DNOW AMD3DNOWEXT AVX AVX2 AVX512 AVX512ICL FMA3 FMA4 MMX MMXEXT SSE SSE2 SSE3 SSE4 SSE42 SSSE3 XOP I686)
        set(HAVE_${ext} 0)
        set(HAVE_${ext}_EXTERNAL 0)
        set(HAVE_${ext}_INLINE 0)
    endforeach()
    
    # PPC SIMD flags
    foreach(ext ALTIVEC DCBZL LDBRX POWER8 PPC4XX VEC_XL VSX)
        set(HAVE_${ext} 0)
        set(HAVE_${ext}_EXTERNAL 0)
        set(HAVE_${ext}_INLINE 0)
    endforeach()
    
    # RISC-V SIMD flags
    foreach(ext RV RVV RV_ZICBOP RV_ZVBB)
        set(HAVE_${ext} 0)
        set(HAVE_${ext}_EXTERNAL 0)
        set(HAVE_${ext}_INLINE 0)
    endforeach()
    
    # MIPS SIMD flags
    foreach(ext MIPSFPU MIPS32R2 MIPS32R5 MIPS64R2 MIPS32R6 MIPS64R6 MIPSDSP MIPSDSPR2 MSA)
        set(HAVE_${ext} 0)
    endforeach()
    
    # LoongArch SIMD flags
    foreach(ext LOONGSON2 LOONGSON3 MMI LSX LASX)
        set(HAVE_${ext} 0)
    endforeach()
    
    # WASM SIMD flags
    foreach(ext SIMD128)
        set(HAVE_${ext} 0)
    endforeach()
    
    # Platform-specific attributes
    set(HAVE_ALIGNED_STACK 0)
    set(HAVE_FAST_64BIT 0)
    set(HAVE_FAST_CLZ 0)
    set(HAVE_FAST_CMOV 0)
    set(HAVE_FAST_FLOAT16 0)
    set(HAVE_SIMD_ALIGN_64 0)
    set(HAVE_SIMD_ALIGN_32 0)
    set(HAVE_SIMD_ALIGN_16 0)
    set(HAVE_FAST_UNALIGNED 0)
    
    # Set default AS_ARCH_LEVEL
    set(AS_ARCH_LEVEL "")

    # Assembler arch_extension directive support - all disabled when ASM is off
    foreach(ext CRC DOTPROD I8MM SVE SVE2 SME SME_I16I64 SME2)
        set(HAVE_AS_ARCHEXT_${ext}_DIRECTIVE 0)
    endforeach()
    
    # Symbol prefix
    if(APPLE)
        set(EXTERN_PREFIX "_")
        set(EXTERN_ASM "_")
    else()
        set(EXTERN_PREFIX "")
        set(EXTERN_ASM "")
    endif()
    
    message(STATUS "Architecture: c (generic)")
    message(STATUS "All SIMD extensions disabled")

else()
    # =============================================================================
    # Detect Architecture (only when ENABLE_ASM is ON)
    # =============================================================================

    # Architecture Detection - Refactored
    # Based on CMAKE_SYSTEM_PROCESSOR, properly detect and set architecture flags

    # Convert CMAKE_SYSTEM_PROCESSOR to lowercase for easier comparison
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _SYSTEM_PROCESSOR)

    # Initialize all architecture flags to 0
    set(ARCH_LIST 
        AARCH64 ARM X86 X86_32 X86_64
        RISCV RISCV32 RISCV64
        LOONGARCH LOONGARCH64
        PPC PPC64
        MIPS MIPS64
        SPARC SPARC64
        ALPHA AVR32 BFIN M68K
    )

    foreach(arch ${ARCH_LIST})
        set(ARCH_${arch} 0)
    endforeach()

    # Detect actual architecture
    if(_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(ARCH_AARCH64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "armv7|armv6|armv5|arm|aarch32")
        set(ARCH_ARM 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")
        set(ARCH_X86 1)
        set(ARCH_X86_64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "i[3-6]86|x86|i86pc")
        set(ARCH_X86 1)
        set(ARCH_X86_32 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "riscv64")
        set(ARCH_RISCV 1)
        set(ARCH_RISCV64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "riscv32|riscv")
        set(ARCH_RISCV 1)
        set(ARCH_RISCV32 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "loongarch64")
        set(ARCH_LOONGARCH 1)
        set(ARCH_LOONGARCH64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "ppc64|powerpc64")
        set(ARCH_PPC 1)
        set(ARCH_PPC64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "ppc|powerpc")
        set(ARCH_PPC 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "mips64|mipsel64")
        set(ARCH_MIPS 1)
        set(ARCH_MIPS64 1)
    elseif(_SYSTEM_PROCESSOR MATCHES "mips|mipsel")
        set(ARCH_MIPS 1)
    else()
        message(WARNING "Unknown architecture: ${CMAKE_SYSTEM_PROCESSOR}")
    endif()

    # Unset temporary variable
    unset(_SYSTEM_PROCESSOR)

    # Initialize all architecture flags to 0 if not set
    foreach(arch AARCH64 ARM IA64 LOONGARCH LOONGARCH32 LOONGARCH64 M68K MIPS MIPS64
                PARISC PPC PPC64 RISCV S390 SPARC SPARC64 TILEGX TILEPRO WASM X86 X86_32 X86_64)
        if(NOT DEFINED ARCH_${arch})
            set(ARCH_${arch} 0)
        endif()
    endforeach()

    # =============================================================================
    # Detect SIMD Extensions - ARM (aarch64)
    # =============================================================================

    if(ARCH_AARCH64)
        message(STATUS "Detecting ARM/aarch64 SIMD extensions...")
        
        # ARMv8 baseline
        set(HAVE_ARMV8 1)
        
        # Set assembler arch level for aarch64
        set(AS_ARCH_LEVEL "armv8-a")
        
        # NEON - always available on aarch64 hardware, but controlled by ENABLE_ASM
        # When ENABLE_ASM is OFF, we disable NEON to prevent linking with assembly functions
        if(ENABLE_ASM)
            set(HAVE_NEON 1)
            set(HAVE_NEON_EXTERNAL 1)
            set(HAVE_NEON_INLINE 1)
            # HAVE_ARMASM: assembler supports ARM assembly (.S files)
            set(HAVE_ARMASM 1)
            # HAVE_AS_ARCH_DIRECTIVE: assembler supports .arch directive
            set(HAVE_AS_ARCH_DIRECTIVE 1)
        else()
            set(HAVE_NEON 0)
            set(HAVE_NEON_EXTERNAL 0)
            set(HAVE_NEON_INLINE 0)
            set(HAVE_ARMASM 0)
            set(HAVE_AS_ARCH_DIRECTIVE 0)
            message(STATUS "  Assembly disabled, NEON optimizations disabled")
        endif()
        
        # Check for ARM CRC instructions
        # Note: ARM CRC uses inline intrinsics but also requires assembly files
        # So we only enable it when ENABLE_ASM is ON
        if(ENABLE_ASM)
            check_c_source_compiles("
                #include <arm_acle.h>
                int main(void) {
                    unsigned int crc = __crc32cw(0, 0);
                    return 0;
                }
            " HAVE_ARM_CRC)
            if(HAVE_ARM_CRC)
                set(HAVE_ARM_CRC 1)
                set(HAVE_ARM_CRC_INLINE 1)
            else()
                set(HAVE_ARM_CRC 0)
            endif()
        else()
            set(HAVE_ARM_CRC 0)
            message(STATUS "  Assembly disabled, ARM CRC optimizations disabled")
        endif()
        
        # =============================================================================
        # Detect assembler .arch_extension directive support
        # These are needed by asm.S to enable specific instruction sets in .S files
        # We use execute_process to directly invoke the C compiler (which handles .S files)
        # =============================================================================

        # Helper macro: test if assembler supports .arch_extension <ext> + a sample instruction
        macro(check_as_archext_directive ext_name test_insn result_var)
            set(_test_src "${CMAKE_BINARY_DIR}/CMakeTmp/test_archext_${ext_name}.S")
            set(_test_obj "${CMAKE_BINARY_DIR}/CMakeTmp/test_archext_${ext_name}.o")
            file(WRITE "${_test_src}"
                ".arch armv8-a\n.arch_extension ${ext_name}\n.text\n${test_insn}\n"
            )
            execute_process(
                COMMAND ${CMAKE_C_COMPILER} -c "${_test_src}" -o "${_test_obj}"
                RESULT_VARIABLE _archext_result
                ERROR_QUIET
                OUTPUT_QUIET
            )
            if(_archext_result EQUAL 0)
                set(${result_var} 1)
            else()
                set(${result_var} 0)
            endif()
        endmacro()

        # Check .arch_extension crc
        check_as_archext_directive("crc" "crc32b w0, w0, w1" HAVE_AS_ARCHEXT_CRC_DIRECTIVE)
        message(STATUS "  AS .arch_extension crc:     ${HAVE_AS_ARCHEXT_CRC_DIRECTIVE}")

        # Check .arch_extension dotprod
        check_as_archext_directive("dotprod" "udot v0.4s, v1.16b, v2.16b" HAVE_AS_ARCHEXT_DOTPROD_DIRECTIVE)
        message(STATUS "  AS .arch_extension dotprod: ${HAVE_AS_ARCHEXT_DOTPROD_DIRECTIVE}")

        # Check .arch_extension i8mm
        check_as_archext_directive("i8mm" "usmmla v0.4s, v1.16b, v2.16b" HAVE_AS_ARCHEXT_I8MM_DIRECTIVE)
        message(STATUS "  AS .arch_extension i8mm:    ${HAVE_AS_ARCHEXT_I8MM_DIRECTIVE}")

        # Check .arch_extension sve
        check_as_archext_directive("sve" "ptrue p0.b" HAVE_AS_ARCHEXT_SVE_DIRECTIVE)
        message(STATUS "  AS .arch_extension sve:     ${HAVE_AS_ARCHEXT_SVE_DIRECTIVE}")

        # Check .arch_extension sve2
        check_as_archext_directive("sve2" "sqabs z0.b, p0/m, z0.b" HAVE_AS_ARCHEXT_SVE2_DIRECTIVE)
        message(STATUS "  AS .arch_extension sve2:    ${HAVE_AS_ARCHEXT_SVE2_DIRECTIVE}")

        # Check .arch_extension sme
        check_as_archext_directive("sme" "smstart" HAVE_AS_ARCHEXT_SME_DIRECTIVE)
        message(STATUS "  AS .arch_extension sme:     ${HAVE_AS_ARCHEXT_SME_DIRECTIVE}")

        # Check .arch_extension sme-i16i64
        check_as_archext_directive("sme-i16i64" "smstart" HAVE_AS_ARCHEXT_SME_I16I64_DIRECTIVE)
        message(STATUS "  AS .arch_extension sme-i16i64: ${HAVE_AS_ARCHEXT_SME_I16I64_DIRECTIVE}")

        # Check .arch_extension sme2
        check_as_archext_directive("sme2" "smstart" HAVE_AS_ARCHEXT_SME2_DIRECTIVE)
        message(STATUS "  AS .arch_extension sme2:    ${HAVE_AS_ARCHEXT_SME2_DIRECTIVE}")

        # Check for dotprod (dot product) instructions
        check_c_source_compiles("
            int main(void) {
                __asm__ volatile(\"udot v0.4s, v1.4b, v2.4b\" ::: \"v0\");
                return 0;
            }
        " HAVE_DOTPROD)
        if(HAVE_DOTPROD)
            set(HAVE_DOTPROD 1)
            set(HAVE_DOTPROD_INLINE 1)
        else()
            set(HAVE_DOTPROD 0)
        endif()
        
        # Check for I8MM (8-bit integer matrix multiply)
        check_c_source_compiles("
            int main(void) {
                __asm__ volatile(\"usmmla v0.4s, v1.16b, v2.16b\" ::: \"v0\");
                return 0;
            }
        " HAVE_I8MM)
        if(HAVE_I8MM)
            set(HAVE_I8MM 1)
        else()
            set(HAVE_I8MM 0)
        endif()
        
        # Check for SVE (Scalable Vector Extension)
        check_c_source_compiles("
            #include <arm_sve.h>
            int main(void) {
                svbool_t pg = svptrue_b8();
                return 0;
            }
        " HAVE_SVE)
        if(HAVE_SVE)
            set(HAVE_SVE 1)
            set(HAVE_SVE_INLINE 1)
        else()
            set(HAVE_SVE 0)
        endif()
        
        # Check for SVE2
        check_c_source_compiles("
            #include <arm_sve.h>
            int main(void) {
                svbool_t pg = svptrue_b8();
                svuint8_t a = svdup_u8(0);
                svuint8_t b = svdup_u8(0);
                svuint8_t c = svqadd_u8_m(pg, a, b);
                (void)c;
                return 0;
            }
        " HAVE_SVE2)
        if(HAVE_SVE2)
            set(HAVE_SVE2 1)
        else()
            set(HAVE_SVE2 0)
        endif()
        
        # Check for SME (Scalable Matrix Extension)
        # Note: On macOS/Darwin, the integrated assembler does NOT support
        # SME/SVE instructions in standalone .S files even if inline asm works
        if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(HAVE_SME 0)
            message(STATUS "SME: disabled on macOS (assembler limitation)")
        else()
            check_c_source_compiles("
                int main(void) {
                    __asm__ volatile(\"smstart\" ::: \"memory\");
                    __asm__ volatile(\"smstop\" ::: \"memory\");
                    return 0;
                }
            " HAVE_SME)
            if(HAVE_SME)
                set(HAVE_SME 1)
            else()
                set(HAVE_SME 0)
            endif()
        endif()
        
        # Set external/inline variants for ARM SIMD
        foreach(ext ARMV8 ARM_CRC DOTPROD NEON SVE SVE2 SME)
            if(NOT DEFINED HAVE_${ext}_EXTERNAL)
                set(HAVE_${ext}_EXTERNAL 0)
            endif()
            if(NOT DEFINED HAVE_${ext}_INLINE)
                set(HAVE_${ext}_INLINE 0)
            endif()
        endforeach()
        
    endif()

    # =============================================================================
    # Detect SIMD Extensions - x86/x86_64
    # =============================================================================

    if(ARCH_X86)
        message(STATUS "Detecting x86 SIMD extensions...")
        
        # Check for various x86 SIMD extensions
        # Note: On macOS aarch64 running x86 under Rosetta, these may report as available
        # but the external assembly may not work
        
        # MMX
        check_c_source_compiles("
            #include <mmintrin.h>
            int main(void) {
                __m64 a = _mm_setzero_si64();
                return 0;
            }
        " HAVE_MMX)
        
        # SSE
        check_c_source_compiles("
            #include <xmmintrin.h>
            int main(void) {
                __m128 a = _mm_setzero_ps();
                return 0;
            }
        " HAVE_SSE)
        
        # SSE2
        check_c_source_compiles("
            #include <emmintrin.h>
            int main(void) {
                __m128d a = _mm_setzero_pd();
                return 0;
            }
        " HAVE_SSE2)
        
        # SSE3
        check_c_source_compiles("
            #include <pmmintrin.h>
            int main(void) {
                __m128 a = _mm_setzero_ps();
                a = _mm_addsub_ps(a, a);
                return 0;
            }
        " HAVE_SSE3)
        
        # SSSE3
        check_c_source_compiles("
            #include <tmmintrin.h>
            int main(void) {
                __m128i a = _mm_setzero_si128();
                a = _mm_abs_epi8(a);
                return 0;
            }
        " HAVE_SSSE3)
        
        # SSE4.1
        check_c_source_compiles("
            #include <smmintrin.h>
            int main(void) {
                __m128i a = _mm_setzero_si128();
                a = _mm_mullo_epi32(a, a);
                return 0;
            }
        " HAVE_SSE4)
        
        # SSE4.2
        check_c_source_compiles("
            #include <nmmintrin.h>
            int main(void) {
                unsigned int crc = _mm_crc32_u32(0, 0);
                return 0;
            }
        " HAVE_SSE42)
        
        # AVX
        check_c_source_compiles("
            #include <immintrin.h>
            int main(void) {
                __m256 a = _mm256_setzero_ps();
                return 0;
            }
        " HAVE_AVX)
        
        # AVX2
        check_c_source_compiles("
            #include <immintrin.h>
            int main(void) {
                __m256i a = _mm256_setzero_si256();
                a = _mm256_add_epi64(a, a);
                return 0;
            }
        " HAVE_AVX2)

        # FMA3
        check_c_source_compiles("
            #include <immintrin.h>
            int main(void) {
                __m256 a = _mm256_setzero_ps();
                a = _mm256_fmadd_ps(a, a, a);
                return 0;
            }
        " HAVE_FMA3)

        # FMA4
        check_c_source_compiles("
            #include <x86intrin.h>
            int main(void) {
                __m128 a = _mm_setzero_ps();
                a = _mm_macc_ps(a, a, a);
                return 0;
            }
        " HAVE_FMA4)

        # AESNI
        check_c_source_compiles("
            #include <wmmintrin.h>
            int main(void) {
                __m128i a = _mm_setzero_si128();
                a = _mm_aesenc_si128(a, a);
                return 0;
            }
        " HAVE_AESNI)

        # XOP (AMD extension, may not be available on all compilers)
        check_c_source_compiles("
            #include <x86intrin.h>
            int main(void) {
                __m128i a = _mm_setzero_si128();
                a = _mm_comlt_epi8(a, a);
                return 0;
            }
        " HAVE_XOP)

        # Set external/inline variants
        # MSVC does NOT support GCC-style inline asm (__asm__ volatile)
        # So HAVE_xxx_INLINE must be 0 for MSVC, even if the SIMD extension is available
        # HAVE_xxx_EXTERNAL = 1 means the extension is available via NASM external assembly
        foreach(ext MMX MMXEXT SSE SSE2 SSE3 SSSE3 SSE4 SSE42 AVX AVX2 FMA3 FMA4 AESNI XOP)
            if(HAVE_${ext})
                set(HAVE_${ext}_EXTERNAL 1)
                if(MSVC)
                    # MSVC: no GCC inline asm support
                    set(HAVE_${ext}_INLINE 0)
                else()
                    set(HAVE_${ext}_INLINE 1)
                endif()
            endif()
        endforeach()

        # NASM can assemble AESNI/FMA3/FMA4/XOP instructions even if C intrinsics
        # are not available (e.g. MSVC doesn't support FMA4/XOP intrinsics).
        # Force-enable EXTERNAL flags for these when NASM is available.
        # Also force-enable AVX512/AVX512ICL/MMXEXT which NASM supports but
        # may not be detected via C intrinsics on all compilers.
        # Note: Do NOT force-enable MMX on 64-bit MSVC - _mm_empty() is not available
        # in 64-bit mode and will cause linker errors.
        foreach(ext AESNI FMA3 FMA4 XOP AVX512 AVX512ICL MMXEXT)
            set(HAVE_${ext}_EXTERNAL 1)
            set(HAVE_${ext} 1)
        endforeach()
    endif()

    # =============================================================================
    # Initialize all SIMD flags to 0 if not detected
    # (check_c_source_compiles sets var to empty string on failure, not 0)
    # =============================================================================

    # ARM SIMD flags
    foreach(ext ARMV5TE ARMV6 ARMV6T2 ARMV8 ARM_CRC DOTPROD I8MM NEON VFP VFPV3 SETEND SVE SVE2 SME SME_I16I64 SME2)
        if(NOT HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
        if(NOT HAVE_${ext}_EXTERNAL)
            set(HAVE_${ext}_EXTERNAL 0)
        endif()
        if(NOT HAVE_${ext}_INLINE)
            set(HAVE_${ext}_INLINE 0)
        endif()
    endforeach()

    # Assembler arch_extension directive support
    foreach(ext CRC DOTPROD I8MM SVE SVE2 SME SME_I16I64 SME2)
        if(NOT DEFINED HAVE_AS_ARCHEXT_${ext}_DIRECTIVE)
            set(HAVE_AS_ARCHEXT_${ext}_DIRECTIVE 0)
        endif()
    endforeach()

    # x86 SIMD flags
    foreach(ext AESNI CLMUL AMD3DNOW AMD3DNOWEXT AVX AVX2 AVX512 AVX512ICL FMA3 FMA4 MMX MMXEXT SSE SSE2 SSE3 SSE4 SSE42 SSSE3 XOP I686)
        if(NOT HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
        if(NOT HAVE_${ext}_EXTERNAL)
            set(HAVE_${ext}_EXTERNAL 0)
        endif()
        if(NOT HAVE_${ext}_INLINE)
            set(HAVE_${ext}_INLINE 0)
        endif()
    endforeach()

    # PPC SIMD flags
    foreach(ext ALTIVEC DCBZL LDBRX POWER8 PPC4XX VEC_XL VSX)
        if(NOT HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
        if(NOT HAVE_${ext}_EXTERNAL)
            set(HAVE_${ext}_EXTERNAL 0)
        endif()
        if(NOT HAVE_${ext}_INLINE)
            set(HAVE_${ext}_INLINE 0)
        endif()
    endforeach()

    # RISC-V SIMD flags
    foreach(ext RV RVV RV_ZICBOP RV_ZVBB)
        if(NOT DEFINED HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
        if(NOT DEFINED HAVE_${ext}_EXTERNAL)
            set(HAVE_${ext}_EXTERNAL 0)
        endif()
        if(NOT DEFINED HAVE_${ext}_INLINE)
            set(HAVE_${ext}_INLINE 0)
        endif()
    endforeach()

    # MIPS SIMD flags
    foreach(ext MIPSFPU MIPS32R2 MIPS32R5 MIPS64R2 MIPS32R6 MIPS64R6 MIPSDSP MIPSDSPR2 MSA)
        if(NOT DEFINED HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
    endforeach()

    # LoongArch SIMD flags
    foreach(ext LOONGSON2 LOONGSON3 MMI LSX LASX)
        if(NOT DEFINED HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
    endforeach()

    # WASM SIMD flags
    foreach(ext SIMD128)
        if(NOT DEFINED HAVE_${ext})
            set(HAVE_${ext} 0)
        endif()
    endforeach()

    # =============================================================================
    # Platform-specific attributes
    # =============================================================================

    # Aligned stack
    if(ARCH_AARCH64 OR ARCH_X86_64)
        set(HAVE_ALIGNED_STACK 1)
        set(HAVE_FAST_64BIT 1)
        set(HAVE_FAST_CLZ 1)
    else()
        set(HAVE_ALIGNED_STACK 0)
        set(HAVE_FAST_64BIT 0)
        set(HAVE_FAST_CLZ 0)
    endif()

    # Fast cmov
    set(HAVE_FAST_CMOV 0)

    # Fast float16 (aarch64 has this)
    if(ARCH_AARCH64)
        set(HAVE_FAST_FLOAT16 1)
    else()
        set(HAVE_FAST_FLOAT16 0)
    endif()

    # SIMD alignment
    if(HAVE_AVX512)
        set(HAVE_SIMD_ALIGN_64 1)
    else()
        set(HAVE_SIMD_ALIGN_64 0)
    endif()

    if(HAVE_AVX)
        set(HAVE_SIMD_ALIGN_32 1)
    else()
        set(HAVE_SIMD_ALIGN_32 0)
    endif()

    if(HAVE_NEON OR HAVE_SSE2)
        set(HAVE_SIMD_ALIGN_16 1)
    else()
        set(HAVE_SIMD_ALIGN_16 0)
    endif()

    # Big endian
    if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
        set(HAVE_BIGENDIAN 1)
    else()
        set(HAVE_BIGENDIAN 0)
    endif()

    # Fast unaligned access
    if(ARCH_AARCH64 OR ARCH_X86)
        set(HAVE_FAST_UNALIGNED 1)
    else()
        set(HAVE_FAST_UNALIGNED 0)
    endif()

    # Memory barrier - platform specific
    if(WIN32)
        set(HAVE_MEMORYBARRIER 1)
    else()
        set(HAVE_MEMORYBARRIER 0)
    endif()

    # mm_empty - x86 only
    if(ARCH_X86)
        set(HAVE_MM_EMPTY 1)
    else()
        set(HAVE_MM_EMPTY 0)
    endif()

    # rdtsc - x86 only
    if(ARCH_X86)
        set(HAVE_RDTSC 1)
    else()
        set(HAVE_RDTSC 0)
    endif()

    # sem_timedwait - POSIX specific
    if(UNIX AND NOT APPLE)
        set(HAVE_SEM_TIMEDWAIT 1)
    else()
        set(HAVE_SEM_TIMEDWAIT 0)
    endif()

    message(STATUS "Architecture: ${FFMPEG_ARCH}")
    if(ARCH_AARCH64)
        message(STATUS "  NEON:       ${HAVE_NEON}")
        message(STATUS "  SVE:        ${HAVE_SVE}")
        message(STATUS "  SVE2:       ${HAVE_SVE2}")
        message(STATUS "  SME:        ${HAVE_SME}")
        message(STATUS "  DOTPROD:    ${HAVE_DOTPROD}")
        message(STATUS "  I8MM:       ${HAVE_I8MM}")
    elseif(ARCH_X86)
        message(STATUS "  MMX:        ${HAVE_MMX}")
        message(STATUS "  SSE:        ${HAVE_SSE}")
        message(STATUS "  SSE2:       ${HAVE_SSE2}")
        message(STATUS "  SSE3:       ${HAVE_SSE3}")
        message(STATUS "  SSSE3:      ${HAVE_SSSE3}")
        message(STATUS "  SSE4:       ${HAVE_SSE4}")
        message(STATUS "  SSE42:      ${HAVE_SSE42}")
        message(STATUS "  AVX:        ${HAVE_AVX}")
        message(STATUS "  AVX2:       ${HAVE_AVX2}")
    endif()

endif() # ENABLE_ASM

# =============================================================================
# Common settings (applied regardless of ENABLE_ASM)
# =============================================================================

# Ensure all architecture variables are defined for config.h
foreach(arch_var AARCH64 ARM IA64 X86 X86_32 X86_64 RISCV MIPS MIPS64
                 LOONGARCH LOONGARCH32 LOONGARCH64 M68K PARISC PPC PPC64
                 S390 SPARC SPARC64 TILEGX TILEPRO WASM)
    if(NOT DEFINED ARCH_${arch_var})
        set(ARCH_${arch_var} 0)
    endif()
endforeach()

# Set default AS_ARCH_LEVEL if not set
if(NOT DEFINED AS_ARCH_LEVEL)
    set(AS_ARCH_LEVEL "")
endif()

# Symbol prefix for external assembly functions
# macOS uses underscore prefix, Linux/ELF uses none
if(APPLE)
    set(EXTERN_PREFIX "_")
    set(EXTERN_ASM "_")
else()
    set(EXTERN_PREFIX "")
    set(EXTERN_ASM "")
endif()
