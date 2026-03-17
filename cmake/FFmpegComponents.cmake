# FFmpeg Components Configuration
# Handles enabling/disabling of individual encoders, decoders, muxers, demuxers,
# filters, protocols, hwaccels, parsers, and bitstream filters
#
# This mimics FFmpeg's configure --enable-encoder/--disable-encoder options

# =============================================================================
# Component Lists (will be populated from FFmpeg source)
# =============================================================================

# These lists will be filled by parsing FFmpeg's all*.c files or Makefiles
set(FFMPEG_ENCODERS "" CACHE INTERNAL "List of all encoders")
set(FFMPEG_DECODERS "" CACHE INTERNAL "List of all decoders")
set(FFMPEG_HWACCELS "" CACHE INTERNAL "List of all hardware accelerators")
set(FFMPEG_MUXERS "" CACHE INTERNAL "List of all muxers")
set(FFMPEG_DEMUXERS "" CACHE INTERNAL "List of all demuxers")
set(FFMPEG_PARSERS "" CACHE INTERNAL "List of all parsers")
set(FFMPEG_BSF "" CACHE INTERNAL "List of all bitstream filters")
set(FFMPEG_PROTOCOLS "" CACHE INTERNAL "List of all protocols")
set(FFMPEG_FILTERS "" CACHE INTERNAL "List of all filters")
set(FFMPEG_INDEVS "" CACHE INTERNAL "List of all input devices")
set(FFMPEG_OUTDEVS "" CACHE INTERNAL "List of all output devices")

# =============================================================================
# Component Selection Options
# =============================================================================

# Default options for component categories
option(ENABLE_ENCODERS "Enable all encoders" ON)
option(ENABLE_DECODERS "Enable all decoders" ON)
option(ENABLE_HWACCELS "Enable all hardware accelerators" ON)
option(ENABLE_MUXERS "Enable all muxers" ON)
option(ENABLE_DEMUXERS "Enable all demuxers" ON)
option(ENABLE_PARSERS "Enable all parsers" ON)
option(ENABLE_BSFS "Enable all bitstream filters" ON)
option(ENABLE_PROTOCOLS "Enable all protocols" ON)
option(ENABLE_FILTERS "Enable all filters" ON)
option(ENABLE_INDEVS "Enable all input devices" ON)
option(ENABLE_OUTDEVS "Enable all output devices" ON)

# Special option to disable everything (like --disable-everything)
option(DISABLE_EVERYTHING "Disable all components" OFF)

# =============================================================================
# Component Selection Macros
# =============================================================================

#
# ffmpeg_select_component:
#   Mark a component as enabled in the CONFIG_ variable
#
macro(ffmpeg_select_component type name)
    string(TOUPPER "${type}" _type_upper)
    string(TOUPPER "${name}" _name_upper)
    set(CONFIG_${_name_upper}_${_type_upper} 1)
endmacro()

#
# ffmpeg_unselect_component:
#   Mark a component as disabled in the CONFIG_ variable
#
macro(ffmpeg_unselect_component type name)
    string(TOUPPER "${type}" _type_upper)
    string(TOUPPER "${name}" _name_upper)
    set(CONFIG_${_name_upper}_${_type_upper} 0)
endmacro()

#
# ffmpeg_component_is_enabled:
#   Check if a component is enabled
#   Usage: ffmpeg_component_is_enabled(encoder libx264 result_var)
#
function(ffmpeg_component_is_enabled type name out_var)
    string(TOUPPER "${type}" _type_upper)
    string(TOUPPER "${name}" _name_upper)
    if(CONFIG_${_name_upper}_${_type_upper})
        set(${out_var} TRUE PARENT_SCOPE)
    else()
        set(${out_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

# =============================================================================
# Component Dependency Resolution
# =============================================================================

#
# ffmpeg_component_depends:
#   Declare that a component depends on other components
#   Usage: ffmpeg_component_depends(encoder h264_decoder decoder h264)
#
macro(ffmpeg_component_depends target_type target_name dep_type dep_name)
    string(TOUPPER "${target_type}" _target_type)
    string(TOUPPER "${target_name}" _target_name)
    string(TOUPPER "${dep_type}" _dep_type)
    string(TOUPPER "${dep_name}" _dep_name)
    set(_dep "${_dep_name}_${_dep_type}")
    list(APPEND ${_target_name}_${_target_type}_DEPS ${_dep})
endmacro()

#
# ffmpeg_resolve_component_deps:
#   Resolve all component dependencies and enable required components
#
function(ffmpeg_resolve_component_deps)
    # This is a simplified version - full implementation would iterate
    # through all components and their dependencies
    message(STATUS "Resolving component dependencies...")
endfunction()

# =============================================================================
# Component Selection from Options
# =============================================================================

#
# Process individual --enable-encoder/--disable-encoder style options
# These are set via cmake -DENABLE_ENCODER_libx264=ON or -DDISABLE_ENCODER_libx264=ON
#
function(ffmpeg_process_component_options)
    # Get all cmake variables
    get_cmake_property(_vars VARIABLES)

    foreach(_var ${_vars})
        # Check for ENABLE_ENCODER_*, ENABLE_DECODER_*, etc.
        if(_var MATCHES "^ENABLE_(ENCODER|DECODER|HWACCEL|MUXER|DEMUXER|PARSER|BSF|PROTOCOL|FILTER|INDEV|OUTDEV)_(.+)$")
            set(_type ${CMAKE_MATCH_1})
            set(_name ${CMAKE_MATCH_2})
            set(_value ${${_var}})

            if(_value)
                ffmpeg_select_component(${_type} ${_name})
                message(STATUS "Enabling ${_type}: ${_name}")
            endif()
        endif()

        # Check for DISABLE_ENCODER_*, DISABLE_DECODER_*, etc.
        if(_var MATCHES "^DISABLE_(ENCODER|DECODER|HWACCEL|MUXER|DEMUXER|PARSER|BSF|PROTOCOL|FILTER|INDEV|OUTDEV)_(.+)$")
            set(_type ${CMAKE_MATCH_1})
            set(_name ${CMAKE_MATCH_2})
            set(_value ${${_var}})

            if(_value)
                ffmpeg_unselect_component(${_type} ${_name})
                message(STATUS "Disabling ${_type}: ${_name}")
            endif()
        endif()
    endforeach()
endfunction()

# =============================================================================
# Initialize Component Defaults
# =============================================================================

#
# ffmpeg_init_component_defaults:
#   Initialize default component states based on category options
#
function(ffmpeg_init_component_defaults)
    message(STATUS "Initializing component defaults...")

    # If DISABLE_EVERYTHING is set, disable all categories
    if(DISABLE_EVERYTHING)
        set(ENABLE_ENCODERS OFF PARENT_SCOPE)
        set(ENABLE_DECODERS OFF PARENT_SCOPE)
        set(ENABLE_HWACCELS OFF PARENT_SCOPE)
        set(ENABLE_MUXERS OFF PARENT_SCOPE)
        set(ENABLE_DEMUXERS OFF PARENT_SCOPE)
        set(ENABLE_PARSERS OFF PARENT_SCOPE)
        set(ENABLE_BSFS OFF PARENT_SCOPE)
        set(ENABLE_PROTOCOLS OFF PARENT_SCOPE)
        set(ENABLE_FILTERS OFF PARENT_SCOPE)
        set(ENABLE_INDEVS OFF PARENT_SCOPE)
        set(ENABLE_OUTDEVS OFF PARENT_SCOPE)
        message(STATUS "Disabled all components (DISABLE_EVERYTHING)")
    endif()

    # Set default state for all components based on category options
    # This is done by FFmpegGenerateLists.cmake when generating component lists
endfunction()

# =============================================================================
# Component List Generation Helpers
# =============================================================================

#
# ffmpeg_add_to_component_list:
#   Add a component to the global list
#
function(ffmpeg_add_to_component_list type name)
    string(TOUPPER "${type}" _type_upper)
    set(_list_name "FFMPEG_${_type_upper}S")

    # Check if already in list
    if(NOT "${name}" IN_LIST ${_list_name})
        list(APPEND ${_list_name} ${name})
        set(${_list_name} ${${_list_name}} CACHE INTERNAL "List of all ${type}s" FORCE)
    endif()
endfunction()

#
# ffmpeg_get_component_list:
#   Get the list of components of a specific type
#
function(ffmpeg_get_component_list type out_var)
    string(TOUPPER "${type}" _type_upper)
    set(${out_var} ${FFMPEG_${_type_upper}S} PARENT_SCOPE)
endfunction()

# =============================================================================
# Print Component Summary
# =============================================================================

function(ffmpeg_print_component_summary)
    message(STATUS "")
    message(STATUS "Component Configuration Summary:")
    message(STATUS "--------------------------------")

    # Count enabled components
    set(_encoder_count 0)
    set(_decoder_count 0)
    set(_hwaccel_count 0)
    set(_muxer_count 0)
    set(_demuxer_count 0)
    set(_parser_count 0)
    set(_bsf_count 0)
    set(_protocol_count 0)
    set(_filter_count 0)

    foreach(_name ${FFMPEG_ENCODERS})
        string(TOUPPER "${_name}" _name_upper)
        if(CONFIG_${_name_upper}_ENCODER)
            math(EXPR _encoder_count "${_encoder_count} + 1")
        endif()
    endforeach()

    foreach(_name ${FFMPEG_DECODERS})
        string(TOUPPER "${_name}" _name_upper)
        if(CONFIG_${_name_upper}_DECODER)
            math(EXPR _decoder_count "${_decoder_count} + 1")
        endif()
    endforeach()

    message(STATUS "  Encoders:     ${_encoder_count}")
    message(STATUS "  Decoders:     ${_decoder_count}")
    message(STATUS "  HWAccels:     ${_hwaccel_count}")
    message(STATUS "  Muxers:       ${_muxer_count}")
    message(STATUS "  Demuxers:     ${_demuxer_count}")
    message(STATUS "  Parsers:      ${_parser_count}")
    message(STATUS "  Bitstream Filters: ${_bsf_count}")
    message(STATUS "  Protocols:    ${_protocol_count}")
    message(STATUS "  Filters:      ${_filter_count}")
    message(STATUS "")
endfunction()

# Initialize component defaults
ffmpeg_init_component_defaults()
