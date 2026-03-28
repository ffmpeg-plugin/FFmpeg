# FFmpeg fftools CMakeLists.txt
# Build configuration for ffmpeg, ffprobe, and ffplay executables

# =============================================================================
# Resource file generation (bin2c equivalent)
# =============================================================================

# Function to convert a binary file to C source
function(bin2c_generate input_file output_file var_name)
    add_custom_command(
        OUTPUT ${output_file}
        COMMAND ${CMAKE_COMMAND}
            -DINPUT_FILE=${input_file}
            -DOUTPUT_FILE=${output_file}
            -DVAR_NAME=${var_name}
            -P ${CMAKE_SOURCE_DIR}/cmake/Bin2C.cmake
        DEPENDS ${input_file}
        COMMENT "Generating ${output_file}"
    )
endfunction()

# Generate resource files
set(RESOURCE_GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/resources)
file(MAKE_DIRECTORY ${RESOURCE_GENERATED_DIR})

set(GRAPH_HTML_C ${RESOURCE_GENERATED_DIR}/graph.html.c)
set(GRAPH_CSS_C ${RESOURCE_GENERATED_DIR}/graph.css.c)

bin2c_generate(
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/graph.html
    ${GRAPH_HTML_C}
    graph_html
)

bin2c_generate(
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/graph.css
    ${GRAPH_CSS_C}
    graph_css
)

set(RESOURCE_SOURCES
    ${GRAPH_HTML_C}
    ${GRAPH_CSS_C}
)

# =============================================================================
# Source file lists
# =============================================================================

# Common textformat sources (shared by ffmpeg and ffprobe)
set(TEXTFORMAT_SOURCES
    textformat/avtextformat.c
    textformat/tf_compact.c
    textformat/tf_default.c
    textformat/tf_flat.c
    textformat/tf_ini.c
    textformat/tf_json.c
    textformat/tf_mermaid.c
    textformat/tf_xml.c
    textformat/tw_avio.c
    textformat/tw_buffer.c
    textformat/tw_stdout.c
)

# Common utility sources
set(COMMON_SOURCES
    cmdutils.c
    opt_common.c
)

# ffmpeg specific sources
set(FFMPEG_SOURCES
    ffmpeg.c
    ffmpeg_dec.c
    ffmpeg_demux.c
    ffmpeg_enc.c
    ffmpeg_filter.c
    ffmpeg_hw.c
    ffmpeg_mux.c
    ffmpeg_mux_init.c
    ffmpeg_opt.c
    ffmpeg_sched.c
    graph/graphprint.c
    resources/resman.c
    sync_queue.c
    thread_queue.c
)

# =============================================================================
# Build executables
# =============================================================================

# Build ffmpeg executable
if(ENABLE_FFMPEG)
    add_executable(ffmpeg
        ${FFMPEG_SOURCES}
        ${COMMON_SOURCES}
        ${TEXTFORMAT_SOURCES}
        ${RESOURCE_SOURCES}
    )
    
    set_target_properties(ffmpeg PROPERTIES
        OUTPUT_NAME ffmpeg
    )
    
    target_include_directories(ffmpeg
        PRIVATE
            ${CMAKE_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}
    )
    
    # Link libraries
    set(FFMPEG_LINK_LIBS
        avdevice
        avfilter
        avformat
        avcodec
        swresample
        swscale
        avutil
        ${CMAKE_THREAD_LIBS_INIT}
        ${MATH_LIBRARY}
    )
    
    # Add external libraries
    if(ZLIB_FOUND)
        list(APPEND FFMPEG_LINK_LIBS ZLIB::ZLIB)
    endif()
    
    if(BZIP2_FOUND)
        list(APPEND FFMPEG_LINK_LIBS BZip2::BZip2)
    endif()
    
    if(LIBLZMA_FOUND)
        list(APPEND FFMPEG_LINK_LIBS LibLZMA::LibLZMA)
    endif()
    
    if(Iconv_FOUND)
        list(APPEND FFMPEG_LINK_LIBS Iconv::Iconv)
    endif()
    
    # macOS frameworks
    if(APPLE)
        find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
        find_library(COREMEDIA_FRAMEWORK CoreMedia)
        find_library(COREVIDEO_FRAMEWORK CoreVideo)
        find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
        find_library(CORESERVICES_FRAMEWORK CoreServices)
        find_library(SECURITY_FRAMEWORK Security)
        
        if(VIDEOTOOLBOX_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${VIDEOTOOLBOX_FRAMEWORK})
        endif()
        if(COREMEDIA_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${COREMEDIA_FRAMEWORK})
        endif()
        if(COREVIDEO_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${COREVIDEO_FRAMEWORK})
        endif()
        if(COREFOUNDATION_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${COREFOUNDATION_FRAMEWORK})
        endif()
        if(CORESERVICES_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${CORESERVICES_FRAMEWORK})
        endif()
        if(SECURITY_FRAMEWORK)
            list(APPEND FFMPEG_LINK_LIBS ${SECURITY_FRAMEWORK})
        endif()
    endif()
    
    target_link_libraries(ffmpeg PRIVATE ${FFMPEG_LINK_LIBS})
endif()

# Build ffprobe executable
if(ENABLE_FFPROBE)
    add_executable(ffprobe
        ffprobe.c
        ${COMMON_SOURCES}
        ${TEXTFORMAT_SOURCES}
    )
    
    set_target_properties(ffprobe PROPERTIES
        OUTPUT_NAME ffprobe
    )
    
    target_include_directories(ffprobe
        PRIVATE
            ${CMAKE_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}
    )
    
    # Link libraries
    set(FFPROBE_LINK_LIBS
        avformat
        avcodec
        avfilter
        avdevice
        swresample
        swscale
        avutil
        ${CMAKE_THREAD_LIBS_INIT}
        ${MATH_LIBRARY}
    )
    
# Add external libraries
    if(ZLIB_FOUND)
        list(APPEND FFPROBE_LINK_LIBS ZLIB::ZLIB)
    endif()
    
    if(Iconv_FOUND)
        list(APPEND FFPROBE_LINK_LIBS Iconv::Iconv)
    endif()
    
    # macOS frameworks
    if(APPLE)
        find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
        find_library(COREMEDIA_FRAMEWORK CoreMedia)
        find_library(COREVIDEO_FRAMEWORK CoreVideo)
        find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
        find_library(CORESERVICES_FRAMEWORK CoreServices)
        
        if(VIDEOTOOLBOX_FRAMEWORK)
            list(APPEND FFPROBE_LINK_LIBS ${VIDEOTOOLBOX_FRAMEWORK})
        endif()
        if(COREMEDIA_FRAMEWORK)
            list(APPEND FFPROBE_LINK_LIBS ${COREMEDIA_FRAMEWORK})
        endif()
        if(COREVIDEO_FRAMEWORK)
            list(APPEND FFPROBE_LINK_LIBS ${COREVIDEO_FRAMEWORK})
        endif()
        if(COREFOUNDATION_FRAMEWORK)
            list(APPEND FFPROBE_LINK_LIBS ${COREFOUNDATION_FRAMEWORK})
        endif()
        if(CORESERVICES_FRAMEWORK)
            list(APPEND FFPROBE_LINK_LIBS ${CORESERVICES_FRAMEWORK})
        endif()
    endif()
    
    target_link_libraries(ffprobe PRIVATE ${FFPROBE_LINK_LIBS})
endif()

# Build ffplay executable (requires SDL2)
if(ENABLE_FFPLAY)
    find_package(SDL2 QUIET)
    if(SDL2_FOUND)
        add_executable(ffplay
            ffplay.c
            ffplay_renderer.c
            ${COMMON_SOURCES}
        )
        
        set_target_properties(ffplay PROPERTIES
            OUTPUT_NAME ffplay
        )
        
        target_include_directories(ffplay
            PRIVATE
                ${CMAKE_BINARY_DIR}
                ${CMAKE_SOURCE_DIR}
                ${CMAKE_CURRENT_SOURCE_DIR}
                ${SDL2_INCLUDE_DIRS}
        )
        
        # Add libplacebo include if enabled (needed by ffplay_renderer.c)
        if(CONFIG_LIBPLACEBO AND PC_LIBPLACEBO_INCLUDE_DIRS)
            target_include_directories(ffplay PRIVATE ${PC_LIBPLACEBO_INCLUDE_DIRS})
        endif()
        
        # Link libraries
        set(FFPLAY_LINK_LIBS
            avdevice
            avfilter
            avformat
            avcodec
            swresample
            avutil
            ${SDL2_LIBRARIES}
            ${CMAKE_THREAD_LIBS_INIT}
        )
        
# Add external libraries
        if(ZLIB_FOUND)
            list(APPEND FFPLAY_LINK_LIBS ZLIB::ZLIB)
        endif()
        
        if(Iconv_FOUND)
            list(APPEND FFPLAY_LINK_LIBS Iconv::Iconv)
        endif()
        
        # macOS frameworks
        if(APPLE)
            find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox)
            find_library(COREMEDIA_FRAMEWORK CoreMedia)
            find_library(COREVIDEO_FRAMEWORK CoreVideo)
            find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
            find_library(CORESERVICES_FRAMEWORK CoreServices)
            
            if(VIDEOTOOLBOX_FRAMEWORK)
                list(APPEND FFPLAY_LINK_LIBS ${VIDEOTOOLBOX_FRAMEWORK})
            endif()
            if(COREMEDIA_FRAMEWORK)
                list(APPEND FFPLAY_LINK_LIBS ${COREMEDIA_FRAMEWORK})
            endif()
            if(COREVIDEO_FRAMEWORK)
                list(APPEND FFPLAY_LINK_LIBS ${COREVIDEO_FRAMEWORK})
            endif()
            if(COREFOUNDATION_FRAMEWORK)
                list(APPEND FFPLAY_LINK_LIBS ${COREFOUNDATION_FRAMEWORK})
            endif()
            if(CORESERVICES_FRAMEWORK)
                list(APPEND FFPLAY_LINK_LIBS ${CORESERVICES_FRAMEWORK})
            endif()
        endif()
        
        target_link_libraries(ffplay PRIVATE ${FFPLAY_LINK_LIBS})
        
        message(STATUS "SDL2 found, ffplay will be built")
    else()
        message(STATUS "SDL2 not found, ffplay will not be built")
    endif()
endif()

# =============================================================================
# Installation
# =============================================================================

if(ENABLE_FFMPEG)
    install(TARGETS ffmpeg RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

if(ENABLE_FFPROBE)
    install(TARGETS ffprobe RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

if(ENABLE_FFPLAY AND SDL2_FOUND)
    install(TARGETS ffplay RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
