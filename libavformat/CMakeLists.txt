# libavformat CMakeLists.txt
# Uses file(GLOB) to collect all .c files, then excludes files requiring
# external libraries or specific platforms.

# ============================================================================
# Files that require external libraries or specific platforms - exclude by default
# ============================================================================
set(avformat_exclude_files
    # TLS backends - only one will be added based on available libs
    tls_gnutls.c
    tls_libtls.c
    tls_mbedtls.c
    tls_openssl.c
    tls_schannel.c
    tls_securetransport.c
    # RTMP DH/crypto - requires a big-number library (OpenSSL/GMP/GCrypt/mbedTLS)
    rtmpcrypt.c
    rtmpdh.c
    # External demuxer libraries
    avisynth.c
    bluray.c
    chromaprint.c
    dvdvideodec.c
    libamqp.c
    libgme.c
    libmodplug.c
    libopenmpt.c
    vapoursynth.c
    # Android/JNI specific (not available on Linux/macOS without JDK)
    ffjni.c
    # SCTP protocol (requires kernel SCTP support and netinet/sctp.h)
    sctp.c
    # External protocol libraries
    librist.c
    librtmp.c
    libsmbclient.c
    libsrt.c
    libssh.c
    libzmq.c
    # These are #included by allformats.c / protocols.c - not compiled directly
    muxer_list.c
    demuxer_list.c
    protocol_list.c
)

# ============================================================================
# Collect all .c files in libavformat/
# ============================================================================
file(GLOB _all_avformat_sources "${CMAKE_CURRENT_SOURCE_DIR}/*.c")

set(avformat_sources "")
foreach(_src ${_all_avformat_sources})
    get_filename_component(_fname "${_src}" NAME)
    if(NOT "${_fname}" IN_LIST avformat_exclude_files)
        list(APPEND avformat_sources "${_src}")
    endif()
endforeach()

# ============================================================================
# Add TLS backend based on available libraries
# Use CONFIG_* variables (set by FFmpegExternalLibs.cmake) to ensure
# consistency with config.h definitions
# ============================================================================
if(CONFIG_OPENSSL AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tls_openssl.c")
    list(APPEND avformat_sources "${CMAKE_CURRENT_SOURCE_DIR}/tls_openssl.c")
elseif(CONFIG_GNUTLS AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tls_gnutls.c")
    list(APPEND avformat_sources "${CMAKE_CURRENT_SOURCE_DIR}/tls_gnutls.c")
endif()

# ============================================================================
# RTMP DH/crypto - requires a big-number library (OpenSSL, GMP, GCrypt, or mbedTLS)
# ============================================================================
if(CONFIG_OPENSSL OR CONFIG_GMP OR CONFIG_GCRYPT OR CONFIG_MBEDTLS)
    foreach(_rtmp_src rtmpcrypt.c rtmpdh.c)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_rtmp_src}")
            list(APPEND avformat_sources "${CMAKE_CURRENT_SOURCE_DIR}/${_rtmp_src}")
        endif()
    endforeach()
endif()

# ============================================================================
# Generate muxer_list.c, demuxer_list.c, protocol_list.c
# by scanning the actual source files that will be compiled
# ============================================================================
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavformat")

set(_muxer_syms "")
set(_demuxer_syms "")
set(_protocol_syms "")

foreach(_src IN LISTS avformat_sources)
    if(NOT EXISTS "${_src}")
        continue()
    endif()
    get_filename_component(_src_name "${_src}" NAME)
    # Skip allformats.c and protocols.c - they only have extern declarations,
    # not actual format/protocol definitions
    if("${_src_name}" STREQUAL "allformats.c" OR "${_src_name}" STREQUAL "protocols.c")
        continue()
    endif()
    file(STRINGS "${_src}" _lines
        REGEX "^(const[ \t]+FFOutputFormat|const[ \t]+FFInputFormat|const[ \t]+URLProtocol)[ \t]+ff_[a-zA-Z0-9_]+")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \t]+FFOutputFormat[ \t]+(ff_[a-zA-Z0-9_]+_muxer)")
            list(APPEND _muxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \t]+FFInputFormat[ \t]+(ff_[a-zA-Z0-9_]+_demuxer)")
            list(APPEND _demuxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \t]+URLProtocol[ \t]+(ff_[a-zA-Z0-9_]+_protocol)")
            list(APPEND _protocol_syms "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endforeach()

list(REMOVE_DUPLICATES _muxer_syms)
list(REMOVE_DUPLICATES _demuxer_syms)
list(REMOVE_DUPLICATES _protocol_syms)
list(SORT _muxer_syms)
list(SORT _demuxer_syms)
list(SORT _protocol_syms)

# Remove symbols that are conditionally compiled and not available on this platform:
# - ff_fifo_test_muxer: only defined when FIFO_TEST is defined (test-only)
# - ff_android_content_protocol: only on Android (CONFIG_ANDROID_CONTENT_PROTOCOL)
# - ff_async_test_protocol: only when TEST is defined (#if 0 in async.c)
list(REMOVE_ITEM _muxer_syms ff_fifo_test_muxer)
list(REMOVE_ITEM _protocol_syms ff_android_content_protocol ff_async_test_protocol)

# Write muxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "extern const FFOutputFormat ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const FFOutputFormat * const muxer_list[] = {\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/muxer_list.c" "${_content}")

# Write demuxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "extern const FFInputFormat ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const FFInputFormat * const demuxer_list[] = {\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/demuxer_list.c" "${_content}")

# Write protocol_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/url.h\"\n\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "extern const URLProtocol ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const URLProtocol * const url_protocols[] = {\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/protocol_list.c" "${_content}")

list(LENGTH _muxer_syms _nmux)
list(LENGTH _demuxer_syms _ndemux)
list(LENGTH _protocol_syms _nproto)
message(STATUS "libavformat: ${_nmux} muxers, ${_ndemux} demuxers, ${_nproto} protocols")

# NOTE: muxer_list.c, demuxer_list.c, protocol_list.c are NOT added to avformat_sources!
# They are #include'd directly by allformats.c and protocols.c respectively.
# They just need to exist in ${CMAKE_BINARY_DIR}/libavformat/ (already written above).

# ============================================================================
# Create the library
# ============================================================================
add_library(avformat STATIC ${avformat_sources})

# Include directories
target_include_directories(avformat
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

# Link dependencies
target_link_libraries(avformat
    PRIVATE
        avcodec
        avutil
        Threads::Threads
)

# Link OpenSSL if enabled (needed for RTMP DH, TLS)
if(CONFIG_OPENSSL AND OPENSSL_FOUND)
    target_link_libraries(avformat PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# Link GnuTLS if enabled (needed for tls_gnutls.c)
if(CONFIG_GNUTLS AND GNUTLS_FOUND)
    if(TARGET PkgConfig::GNUTLS)
        target_link_libraries(avformat PRIVATE PkgConfig::GNUTLS)
    else()
        target_link_libraries(avformat PRIVATE ${GNUTLS_LIBRARIES})
        target_include_directories(avformat PRIVATE ${GNUTLS_INCLUDE_DIRS})
        if(GNUTLS_LIBRARY_DIRS)
            target_link_directories(avformat PRIVATE ${GNUTLS_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link libxml2 if available (needed for dashdec.c DASH demuxer)
find_package(LibXml2 QUIET)
if(LIBXML2_FOUND)
    target_link_libraries(avformat PRIVATE LibXml2::LibXml2)
    target_include_directories(avformat PRIVATE ${LIBXML2_INCLUDE_DIR})
    message(STATUS "avformat: linking libxml2")
else()
    message(STATUS "avformat: libxml2 not found, excluding dashdec.c, imfdec.c, imf_cpl.c")
    # dashdec.c, imfdec.c, imf_cpl.c all require libxml2 (via imf.h) - exclude them
    get_target_property(_avfmt_srcs avformat SOURCES)
    list(FILTER _avfmt_srcs EXCLUDE REGEX "(dashdec|imfdec|imf_cpl)\\.c$")
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")

    # allformats.c unconditionally references ff_dash_demuxer and ff_imf_demuxer.
    # protocols.c unconditionally references ff_unix_protocol.
    # Provide stub definitions so the linker can resolve these symbols.
    set(_stub_file "${CMAKE_CURRENT_BINARY_DIR}/avformat_xml_stubs.c")
    file(WRITE "${_stub_file}" "
/* Auto-generated stub: provides empty demuxer/muxer/protocol structs when deps are absent */
#include \"avformat.h\"
#include \"demux.h\"
#include \"mux.h\"
#include \"url.h\"

/* Stub for DASH demuxer (requires libxml2) */
const FFInputFormat ff_dash_demuxer = {
    .p.name = \"dash\",
    .p.long_name = \"Dynamic Adaptive Streaming over HTTP (stub)\",
};

/* Stub for IMF demuxer (requires libxml2) */
const FFInputFormat ff_imf_demuxer = {
    .p.name = \"imf\",
    .p.long_name = \"IMF (Interoperable Master Format) (stub)\",
};

/* Stub for WHIP muxer (requires OpenSSL) */
const FFOutputFormat ff_whip_muxer = {
    .p.name = \"whip\",
    .p.long_name = \"WebRTC WHIP (stub)\",
};

/* Stub for Unix domain socket protocol (requires sys/un.h, POSIX only) */
const URLProtocol ff_unix_protocol = {
    .name = \"unix\",
};
")
    target_sources(avformat PRIVATE "${_stub_file}")
endif()

# Link zlib if available (needed for mov.c, http.c, etc.)
find_package(ZLIB QUIET)
if(ZLIB_FOUND)
    target_link_libraries(avformat PRIVATE ZLIB::ZLIB)
endif()

# On Windows, exclude files that require POSIX-only headers
if(WIN32)
    get_target_property(_avfmt_srcs avformat SOURCES)
    # unix.c requires sys/un.h (Unix domain sockets) - not available on Windows MSVC
    list(FILTER _avfmt_srcs EXCLUDE REGEX "unix\\.c$")
    # whip.c requires OpenSSL TLS/DTLS functions - exclude when OpenSSL not available
    # Note: ff_whip_muxer stub is provided by avformat_xml_stubs.c when libxml2 is absent
    if(NOT OPENSSL_FOUND AND LIBXML2_FOUND)
        # Only exclude whip.c if we didn't already provide a stub via xml_stubs
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\\.c$")
    elseif(NOT OPENSSL_FOUND AND NOT LIBXML2_FOUND)
        # whip.c is already covered by the stub file, just exclude the real source
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\\.c$")
    endif()
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")

    # Link Winsock2 for network functions (select, ioctlsocket, gethostname, etc.)
    target_link_libraries(avformat PRIVATE ws2_32)
endif()

# Link bzip2 if available (needed for matroskadec.c)
find_library(BZIP2_LIBRARY NAMES bz2 bzip2)
find_path(BZIP2_INCLUDE_DIR NAMES bzlib.h)
if(BZIP2_LIBRARY AND BZIP2_INCLUDE_DIR)
    target_link_libraries(avformat PRIVATE ${BZIP2_LIBRARY})
    target_include_directories(avformat PRIVATE ${BZIP2_INCLUDE_DIR})
endif()

# Compiler definitions
target_compile_definitions(avformat PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avformat
)

# Position independent code for shared builds
set_pic_if_needed(avformat)

# Set output name
set_target_properties(avformat PROPERTIES
    OUTPUT_NAME avformat
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

message(STATUS "libavformat configured")
