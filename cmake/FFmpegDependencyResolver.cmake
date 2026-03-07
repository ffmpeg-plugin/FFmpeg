# FFmpeg Dependency Resolver
# Implements recursive dependency resolution matching configure's enable_deep logic

include_guard(GLOBAL)

# Global state for dependency resolution
set(FFMPEG_RESOLVED_COMPONENTS "")
set(FFMPEG_RESOLVING_STACK "")
set(FFMPEG_RESOLUTION_LOG "")

# ============================================================================
# Core Recursive Resolution Function
# ============================================================================

# ffmpeg_resolve_component: Recursively resolve a component's dependencies
# Arguments:
#   component: The component name (e.g., "h264_decoder", "libx264")
# Sets:
#   CONFIG_<COMPONENT>: 1 if enabled, 0 if disabled
function(ffmpeg_resolve_component component)
    string(TOUPPER "${component}" COMP_UPPER)
    
    # 1. Check if already resolved
    list(FIND FFMPEG_RESOLVED_COMPONENTS ${COMP_UPPER} already_resolved)
    if(NOT already_resolved EQUAL -1)
        return()
    endif()
    
    # 2. Check for circular dependency
    list(FIND FFMPEG_RESOLVING_STACK ${COMP_UPPER} in_stack)
    if(NOT in_stack EQUAL -1)
        string(REPLACE ";" " -> " stack_str "${FFMPEG_RESOLVING_STACK}")
        message(WARNING "Circular dependency detected: ${stack_str} -> ${COMP_UPPER}")
        set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
        return()
    endif()
    
    # 3. Mark as resolving
    list(APPEND FFMPEG_RESOLVING_STACK ${COMP_UPPER})
    
    # 4. Get dependency definitions
    set(deps "${${COMP_UPPER}_DEPS}")
    set(deps_any "${${COMP_UPPER}_DEPS_ANY}")
    set(select "${${COMP_UPPER}_SELECT}")
    set(suggest "${${COMP_UPPER}_SUGGEST}")
    set(conflict "${${COMP_UPPER}_CONFLICT}")
    set(cond_if "${${COMP_UPPER}_IF}")
    set(cond_if_any "${${COMP_UPPER}_IF_ANY}")
    
    # 5. Check conditions (_if)
    if(cond_if)
        foreach(cond ${cond_if})
            string(TOUPPER "${cond}" COND_UPPER)
            if(NOT CONFIG_${COND_UPPER})
                list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: disabled (condition ${COND_UPPER} not met)")
                set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
                list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
                return()
            endif()
        endforeach()
    endif()
    
    # 6. Check any-of conditions (_if_any)
    if(cond_if_any)
        set(any_cond_met FALSE)
        foreach(cond ${cond_if_any})
            string(TOUPPER "${cond}" COND_UPPER)
            if(CONFIG_${COND_UPPER})
                set(any_cond_met TRUE)
                break()
            endif()
        endforeach()
        if(NOT any_cond_met)
            list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: disabled (no condition in ${cond_if_any} met)")
            set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
            list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
            return()
        endif()
    endif()
    
    # 7. Check conflicts (_conflict)
    foreach(conf ${conflict})
        string(TOUPPER "${conf}" CONF_UPPER)
        if(CONFIG_${CONF_UPPER})
            list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: disabled (conflicts with ${CONF_UPPER})")
            set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
            list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
            return()
        endif()
    endforeach()
    
    # 8. Check hard dependencies (_deps)
    set(all_deps_met TRUE)
    foreach(dep ${deps})
        string(TOUPPER "${dep}" DEP_UPPER)
        
        # Check if dependency is available
        if(NOT DEFINED CONFIG_${DEP_UPPER} OR CONFIG_${DEP_UPPER} EQUAL 0)
            # Try to resolve the dependency
            ffmpeg_resolve_component(${dep})
            # Re-check after resolution
            if(NOT CONFIG_${DEP_UPPER})
                set(all_deps_met FALSE)
                list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: disabled (missing hard dep ${DEP_UPPER})")
                break()
            endif()
        endif()
    endforeach()
    
    if(NOT all_deps_met)
        set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
        list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
        return()
    endif()
    
    # 9. Check any-of dependencies (_deps_any)
    if(deps_any)
        set(any_dep_met FALSE)
        foreach(dep ${deps_any})
            string(TOUPPER "${dep}" DEP_UPPER)
            if(CONFIG_${DEP_UPPER})
                set(any_dep_met TRUE)
                break()
            endif()
        endforeach()
        if(NOT any_dep_met)
            list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: disabled (no dep in ${deps_any} met)")
            set(CONFIG_${COMP_UPPER} 0 PARENT_SCOPE)
            list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
            return()
        endif()
    endif()
    
    # 10. Enable the component
    set(CONFIG_${COMP_UPPER} 1 PARENT_SCOPE)
    list(APPEND FFMPEG_RESOLVED_COMPONENTS ${COMP_UPPER})
    list(APPEND FFMPEG_RESOLUTION_LOG "${COMP_UPPER}: enabled")
    
    # 11. Recursively enable select dependencies (_select)
    foreach(sel ${select})
        string(TOUPPER "${sel}" SEL_UPPER)
        ffmpeg_resolve_component(${sel})
        set(CONFIG_${SEL_UPPER} 1 PARENT_SCOPE)
    endforeach()
    
    # 12. Handle suggest dependencies (_suggest)
    foreach(sug ${suggest})
        string(TOUPPER "${sug}" SUG_UPPER)
        # Suggest only enables if already available
        if(DEFINED CONFIG_${SUG_UPPER} AND CONFIG_${SUG_UPPER})
            ffmpeg_resolve_component(${sug})
        endif()
    endforeach()
    
    # 13. Remove from resolving stack
    list(REMOVE_ITEM FFMPEG_RESOLVING_STACK ${COMP_UPPER})
endfunction()

# ============================================================================
# External Library Component Resolution
# ============================================================================

# Resolve components associated with enabled external libraries.
# This links L1 (external libraries) to L2 (components).
# When an external library like libx264 is enabled, this function:
# 1. Resolves the encoder/decoder/muxer/demuxer components that use this library
# 2. Resolves their dependencies recursively
function(ffmpeg_resolve_external_library_components)
    message(STATUS "Resolving external library components...")
    
    # Get all CONFIG_LIB* variables
    get_cmake_property(all_vars VARIABLES)
    
    foreach(var ${all_vars})
        # Match CONFIG_LIB<NAME> patterns (e.g., CONFIG_LIBX264)
        if(var MATCHES "^CONFIG_LIB([A-Z0-9_]+)$")
            set(lib_name "${CMAKE_MATCH_1}")  # e.g., "X264"
            
            if(${var})
                # This external library is enabled
                message(STATUS "  lib${lib_name} is enabled, resolving associated components...")
                
                # Try to resolve encoder component (e.g., LIBX264_ENCODER)
                set(encoder_name "LIB${lib_name}_ENCODER")
                if(DEFINED ${encoder_name}_DEPS OR DEFINED ${encoder_name}_SELECT)
                    message(STATUS "    -> ${encoder_name}")
                    ffmpeg_resolve_component(${encoder_name})
                    set(CONFIG_${encoder_name} 1 PARENT_SCOPE)
                endif()
                
                # Try to resolve decoder component (e.g., LIBX264_DECODER)
                set(decoder_name "LIB${lib_name}_DECODER")
                if(DEFINED ${decoder_name}_DEPS OR DEFINED ${decoder_name}_SELECT)
                    message(STATUS "    -> ${decoder_name}")
                    ffmpeg_resolve_component(${decoder_name})
                    set(CONFIG_${decoder_name} 1 PARENT_SCOPE)
                endif()
                
                # Try to resolve muxer component
                set(muxer_name "LIB${lib_name}_MUXER")
                if(DEFINED ${muxer_name}_DEPS OR DEFINED ${muxer_name}_SELECT)
                    message(STATUS "    -> ${muxer_name}")
                    ffmpeg_resolve_component(${muxer_name})
                    set(CONFIG_${muxer_name} 1 PARENT_SCOPE)
                endif()
                
                # Try to resolve demuxer component
                set(demuxer_name "LIB${lib_name}_DEMUXER")
                if(DEFINED ${demuxer_name}_DEPS OR DEFINED ${demuxer_name}_SELECT)
                    message(STATUS "    -> ${demuxer_name}")
                    ffmpeg_resolve_component(${demuxer_name})
                    set(CONFIG_${demuxer_name} 1 PARENT_SCOPE)
                endif()
                
                # Try to resolve filter component
                set(filter_name "LIB${lib_name}_FILTER")
                if(DEFINED ${filter_name}_DEPS OR DEFINED ${filter_name}_SELECT)
                    message(STATUS "    -> ${filter_name}")
                    ffmpeg_resolve_component(${filter_name})
                    set(CONFIG_${filter_name} 1 PARENT_SCOPE)
                endif()
            endif()
        endif()
    endforeach()
endfunction()

# ============================================================================
# Main Entry Point
# ============================================================================

# Main entry point for dependency resolution.
# Call this after all external libraries have been detected.
function(ffmpeg_resolve_all_dependencies)
    message(STATUS "============================================")
    message(STATUS "Resolving FFmpeg Component Dependencies")
    message(STATUS "============================================")
    
    # Reset state
    set(FFMPEG_RESOLVED_COMPONENTS "")
    set(FFMPEG_RESOLVING_STACK "")
    set(FFMPEG_RESOLUTION_LOG "")
    
    # Step 1: Resolve components linked to external libraries
    ffmpeg_resolve_external_library_components()
    
    # Step 2: Resolve explicitly enabled components
    if(FFMPEG_ENABLED_COMPONENTS)
        message(STATUS "Resolving explicitly enabled components...")
        foreach(comp ${FFMPEG_ENABLED_COMPONENTS})
            ffmpeg_resolve_component(${comp})
        endforeach()
    endif()
    
    # Step 3: Report results
    list(LENGTH FFMPEG_RESOLVED_COMPONENTS num_resolved)
    message(STATUS "============================================")
    message(STATUS "Dependency resolution complete: ${num_resolved} components enabled")
    message(STATUS "============================================")
endfunction()

# ============================================================================
# Utility Functions
# ============================================================================

# Print the resolution log for debugging.
function(ffmpeg_print_resolution_log)
    message(STATUS "Dependency Resolution Log:")
    foreach(entry ${FFMPEG_RESOLUTION_LOG})
        message(STATUS "  ${entry}")
    endforeach()
endfunction()

# Get list of all enabled components.
# Arguments:
#   output_var: Variable name to store the result
function(ffmpeg_get_enabled_components output_var)
    set(${output_var} ${FFMPEG_RESOLVED_COMPONENTS} PARENT_SCOPE)
endfunction()

# Check if a component is enabled.
# Arguments:
#   component: Component name to check
#   result_var: Variable to store TRUE/FALSE result
function(ffmpeg_is_component_enabled component result_var)
    string(TOUPPER "${component}" COMP_UPPER)
    list(FIND FFMPEG_RESOLVED_COMPONENTS ${COMP_UPPER} found)
    if(NOT found EQUAL -1)
        set(${result_var} TRUE PARENT_SCOPE)
    else()
        set(${result_var} FALSE PARENT_SCOPE)
    endif()
endfunction()
