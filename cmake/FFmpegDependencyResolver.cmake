# FFmpeg Dependency Resolver
# Implements dependency resolution matching configure's check_deps() + enable_deep() logic.
#
# Key design decisions:
#   1. Uses CACHE INTERNAL variables for all CONFIG_* state
#   2. Uses ITERATIVE two-pass approach instead of recursive macros
#      (CMake macros don't have their own scope, so recursive calls corrupt variables)
#   3. Pass 1: Propagate _select/_suggest for enabled components (enable_deep)
#   4. Pass 2: Check _deps/_deps_any/_conflict/_if/_if_any for each component
#   5. Components disabled by unmet deps are marked and cannot be re-enabled
#   6. Repeat until no changes occur (fixpoint iteration)
#
# This matches configure's behavior where:
#   check_deps() recursively resolves all components
#   enable_deep() / enable_deep_weak() propagate _select/_suggest

include_guard(GLOBAL)

# ============================================================================
# Helper: Check if a config variable is enabled
# Handles both CONFIG_XXX and lowercase license variables (gpl, lgpl_gpl)
# ============================================================================
function(_ffmpeg_is_enabled var_name result_var)
    string(TOUPPER "${var_name}" VAR_UPPER)

    # Check license variables first (lowercase in configure: gpl, lgpl_gpl, nonfree, version3)
    string(TOLOWER "${var_name}" VAR_LOWER)
    if(VAR_LOWER STREQUAL "gpl")
        if(CONFIG_GPL)
            set(${result_var} TRUE PARENT_SCOPE)
        else()
            set(${result_var} FALSE PARENT_SCOPE)
        endif()
        return()
    elseif(VAR_LOWER STREQUAL "lgpl_gpl")
        if(CONFIG_GPL)
            set(${result_var} TRUE PARENT_SCOPE)
        else()
            set(${result_var} FALSE PARENT_SCOPE)
        endif()
        return()
    elseif(VAR_LOWER STREQUAL "nonfree")
        if(CONFIG_NONFREE)
            set(${result_var} TRUE PARENT_SCOPE)
        else()
            set(${result_var} FALSE PARENT_SCOPE)
        endif()
        return()
    elseif(VAR_LOWER STREQUAL "version3")
        if(CONFIG_VERSION3)
            set(${result_var} TRUE PARENT_SCOPE)
        else()
            set(${result_var} FALSE PARENT_SCOPE)
        endif()
        return()
    endif()

    # Check CONFIG_XXX variable
    if(DEFINED CONFIG_${VAR_UPPER} AND CONFIG_${VAR_UPPER})
        set(${result_var} TRUE PARENT_SCOPE)
    else()
        set(${result_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

# ============================================================================
# Main Entry Point: Iterative Two-Pass Dependency Resolution
# ============================================================================
#
# Algorithm (matching configure's check_deps + enable_deep):
#
# In configure, check_deps processes components recursively:
#   1. First recursively check_deps on all referenced deps
#   2. Then check _if/_if_any -> enable_weak
#   3. Then check _deps/_deps_any/_conflict -> disable if unmet
#   4. If still enabled -> enable_deep_weak on _select/_suggest
#
# We flatten this into iterative passes:
#   Pass 1: Process _if/_if_any conditions (enable components)
#   Pass 2: Process _select/_suggest for enabled components (propagate enables)
#   Pass 3: Check _deps/_deps_any/_conflict (disable components with unmet deps)
#   Mark disabled components so they can't be re-enabled by _select
#   Repeat until stable
#
macro(ffmpeg_resolve_all_dependencies)
    message(STATUS "============================================")
    message(STATUS "Resolving FFmpeg Component Dependencies")
    message(STATUS "============================================")

    # ------------------------------------------------------------------
    # Step 1: Collect ALL component names that have dependency definitions
    # ------------------------------------------------------------------
    set(_all_dep_components "")
    get_cmake_property(_all_vars VARIABLES)
    foreach(_var IN LISTS _all_vars)
        if(_var MATCHES "^([A-Z0-9_]+)_(DEPS|SELECT|SUGGEST|DEPS_ANY|IF|IF_ANY|CONFLICT)$")
            list(APPEND _all_dep_components "${CMAKE_MATCH_1}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _all_dep_components)
    list(LENGTH _all_dep_components _num_dep_components)
    message(STATUS "Found ${_num_dep_components} components with dependency definitions")

    # ------------------------------------------------------------------
    # Step 1.5: Initialize all components to enabled (CONFIG_*=1)
    # In configure, all components default to enabled. check_deps then
    # disables those with unmet dependencies. We must do the same.
    #
    # FFmpegDefaults.cmake sets all config.h.in variables to 0 by default.
    # We override that here for components that have dependency definitions,
    # setting them to 1 (enabled). Pass 3 will then disable those with
    # unmet dependencies.
    #
    # Exception: components explicitly set by L1 detection or platform
    # detection (e.g., CONFIG_LIBX264=0 because libx264 not found) should
    # NOT be overridden. These are identified by being in CACHE already
    # (L1 detection uses CACHE INTERNAL).
    # ------------------------------------------------------------------
    set(_initialized_count 0)
    foreach(_comp IN LISTS _all_dep_components)
        # Check if this was explicitly set by L1/platform detection (CACHE variable)
        if(DEFINED CACHE{CONFIG_${_comp}})
            # Respect L1/platform detection result
            continue()
        endif()
        # Skip pure external library flags (LIB* without component suffix)
        # e.g., LIBX264, LIBX265, LIBLCEVC_DEC are external library flags
        # But LIBX264_ENCODER, LIBX265_ENCODER are component names - don't skip
        string(SUBSTRING "${_comp}" 0 3 _comp_prefix)
        if("${_comp_prefix}" STREQUAL "LIB")
            # Check if it has a component suffix
            if(NOT (_comp MATCHES "_(ENCODER|DECODER|MUXER|DEMUXER|PARSER|BSF|FILTER|HWACCEL|PROTOCOL|INDEV|OUTDEV)$"))
                # Pure library flag - skip
                continue()
            endif()
        endif()
        # Override FFmpegDefaults.cmake's default of 0
        set(CONFIG_${_comp} 1)
        math(EXPR _initialized_count "${_initialized_count} + 1")
    endforeach()
    message(STATUS "Initialized ${_initialized_count} components to enabled (default)")

    # Track components permanently disabled by unmet deps (prevents oscillation)
    set(_disabled_by_deps "")

    # ------------------------------------------------------------------
    # Step 2: Iterative fixpoint resolution
    # ------------------------------------------------------------------
    set(_iteration 0)
    set(_max_iterations 20)
    set(_changed TRUE)

    while(_changed AND _iteration LESS _max_iterations)
        math(EXPR _iteration "${_iteration} + 1")
        set(_changed FALSE)

        # ==============================================================
        # Pass 1: Process _if / _if_any conditions
        # These can enable components that are not yet enabled
        # ==============================================================
        foreach(_comp IN LISTS _all_dep_components)
            # Skip permanently disabled components
            list(FIND _disabled_by_deps "${_comp}" _dbd_idx)
            if(NOT _dbd_idx EQUAL -1)
                continue()
            endif()

            set(_dep_ifa "${${_comp}_IF}")
            set(_dep_ifn "${${_comp}_IF_ANY}")

            # _if: all conditions must be enabled -> enable_weak
            if(_dep_ifa AND NOT CONFIG_${_comp})
                set(_if_ok TRUE)
                foreach(_cond IN LISTS _dep_ifa)
                    _ffmpeg_is_enabled(${_cond} _cond_met)
                    if(NOT _cond_met)
                        set(_if_ok FALSE)
                        break()
                    endif()
                endforeach()
                if(_if_ok)
                    set(CONFIG_${_comp} 1)
                    set(CONFIG_${_comp} 1 CACHE INTERNAL "Enabled by _if condition")
                    set(_changed TRUE)
                endif()
            endif()

            # _if_any: any condition must be enabled -> enable_weak
            if(_dep_ifn AND NOT CONFIG_${_comp})
                set(_ifany_ok FALSE)
                foreach(_cond IN LISTS _dep_ifn)
                    _ffmpeg_is_enabled(${_cond} _cond_met)
                    if(_cond_met)
                        set(_ifany_ok TRUE)
                        break()
                    endif()
                endforeach()
                if(_ifany_ok)
                    set(CONFIG_${_comp} 1)
                    set(CONFIG_${_comp} 1 CACHE INTERNAL "Enabled by _if_any condition")
                    set(_changed TRUE)
                endif()
            endif()
        endforeach()

        # ==============================================================
        # Pass 2: Propagate _select and _suggest for enabled components
        # Uses iterative worklist to avoid recursive macro issues
        # ==============================================================
        foreach(_comp IN LISTS _all_dep_components)
            if(NOT CONFIG_${_comp})
                continue()
            endif()

            # _select: force-enable these (enable_deep_weak in configure)
            if(DEFINED ${_comp}_SELECT)
                foreach(_sel IN LISTS ${_comp}_SELECT)
                    string(TOUPPER "${_sel}" _sel_upper)
                    # Skip if already enabled or permanently disabled
                    if(NOT CONFIG_${_sel_upper})
                        list(FIND _disabled_by_deps "${_sel_upper}" _dbd_idx2)
                        if(_dbd_idx2 EQUAL -1)
                            # Enable this component and its transitive _select deps
                            set(_worklist "${_sel_upper}")
                            while(_worklist)
                                list(POP_FRONT _worklist _wl_item)
                                if(NOT CONFIG_${_wl_item})
                                    list(FIND _disabled_by_deps "${_wl_item}" _dbd_idx3)
                                    if(_dbd_idx3 EQUAL -1)
                                        set(CONFIG_${_wl_item} 1)
                                        set(CONFIG_${_wl_item} 1 CACHE INTERNAL "Enabled by _select from ${_comp}")
                                        set(_changed TRUE)
                                        # Add transitive _select deps
                                        if(DEFINED ${_wl_item}_SELECT)
                                            foreach(_wl_sel IN LISTS ${_wl_item}_SELECT)
                                                string(TOUPPER "${_wl_sel}" _wl_sel_upper)
                                                if(NOT CONFIG_${_wl_sel_upper})
                                                    list(APPEND _worklist "${_wl_sel_upper}")
                                                endif()
                                            endforeach()
                                        endif()
                                    endif()
                                endif()
                            endwhile()
                        endif()
                    endif()
                endforeach()
            endif()

            # _suggest: weakly enable these (only if already available)
            # In configure, _suggest means "enable if available". A component
            # is "available" if it was detected by L1 (CONFIG_XXX=1) or
            # enabled by the resolver. We must NOT enable components that
            # are explicitly disabled (CONFIG_XXX=0) or unknown.
            if(DEFINED ${_comp}_SUGGEST)
                foreach(_sug IN LISTS ${_comp}_SUGGEST)
                    string(TOUPPER "${_sug}" _sug_upper)
                    # _suggest only propagates _select chains for already-enabled components
                    # It does NOT enable disabled components (unlike _select which force-enables)
                    if(NOT CONFIG_${_sug_upper})
                        # Component is disabled or unknown - skip
                        continue()
                    endif()
                    # Component is already enabled - propagate its _select chain
                    if(DEFINED ${_sug_upper}_SELECT)
                        set(_sg_worklist "")
                        foreach(_sg_sel IN LISTS ${_sug_upper}_SELECT)
                            string(TOUPPER "${_sg_sel}" _sg_sel_upper)
                            if(NOT CONFIG_${_sg_sel_upper})
                                list(APPEND _sg_worklist "${_sg_sel_upper}")
                            endif()
                        endforeach()
                        while(_sg_worklist)
                            list(POP_FRONT _sg_worklist _sg_item)
                            if(NOT CONFIG_${_sg_item})
                                list(FIND _disabled_by_deps "${_sg_item}" _dbd_idx5)
                                if(_dbd_idx5 EQUAL -1)
                                    set(CONFIG_${_sg_item} 1)
                                    set(CONFIG_${_sg_item} 1 CACHE INTERNAL "Enabled by _select chain from suggest")
                                    set(_changed TRUE)
                                    if(DEFINED ${_sg_item}_SELECT)
                                        foreach(_sg_sel2 IN LISTS ${_sg_item}_SELECT)
                                            string(TOUPPER "${_sg_sel2}" _sg_sel2_upper)
                                            if(NOT CONFIG_${_sg_sel2_upper})
                                                list(APPEND _sg_worklist "${_sg_sel2_upper}")
                                            endif()
                                        endforeach()
                                    endif()
                                endif()
                            endif()
                        endwhile()
                    endif()
                endforeach()
            endif()
        endforeach()

        # ==============================================================
        # Pass 3: Check _deps/_deps_any/_conflict - disable if unmet
        # Components disabled here are marked permanently
        # ==============================================================
        foreach(_comp IN LISTS _all_dep_components)
            # Skip already disabled components
            if(NOT CONFIG_${_comp})
                continue()
            endif()

            set(_dep_all "${${_comp}_DEPS}")
            set(_dep_any "${${_comp}_DEPS_ANY}")
            set(_dep_con "${${_comp}_CONFLICT}")

            set(_should_disable FALSE)

            # _deps: ALL must be satisfied
            if(_dep_all)
                foreach(_dep IN LISTS _dep_all)
                    _ffmpeg_is_enabled(${_dep} _dep_met)
                    if(NOT _dep_met)
                        set(_should_disable TRUE)
                        break()
                    endif()
                endforeach()
            endif()

            # _deps_any: ANY must be satisfied
            if(_dep_any AND NOT _should_disable)
                set(_any_ok FALSE)
                foreach(_dep IN LISTS _dep_any)
                    _ffmpeg_is_enabled(${_dep} _dep_met)
                    if(_dep_met)
                        set(_any_ok TRUE)
                        break()
                    endif()
                endforeach()
                if(NOT _any_ok)
                    set(_should_disable TRUE)
                endif()
            endif()

            # _conflict: ALL conflicting must be disabled
            if(_dep_con AND NOT _should_disable)
                foreach(_con IN LISTS _dep_con)
                    _ffmpeg_is_enabled(${_con} _con_enabled)
                    if(_con_enabled)
                        set(_should_disable TRUE)
                        break()
                    endif()
                endforeach()
            endif()

            # _select: if any selected component is disabled, disable this too
            # This matches configure's: disabled_any $dep_sel && disable $cfg
            set(_dep_sel "${${_comp}_SELECT}")
            if(_dep_sel AND NOT _should_disable)
                foreach(_sel IN LISTS _dep_sel)
                    string(TOUPPER "${_sel}" _sel_upper)
                    list(FIND _disabled_by_deps "${_sel_upper}" _sel_dbd_idx)
                    if(_sel_dbd_idx GREATER -1)
                        # Selected component was permanently disabled by unmet deps
                        set(_should_disable TRUE)
                        break()
                    endif()
                endforeach()
            endif()

            if(_should_disable)
                set(CONFIG_${_comp} 0)
                set(CONFIG_${_comp} 0 CACHE INTERNAL "Disabled: deps not met")
                # Mark as permanently disabled to prevent oscillation
                list(APPEND _disabled_by_deps "${_comp}")
                set(_changed TRUE)
            endif()
        endforeach()

        message(STATUS "  Iteration ${_iteration}: changed=${_changed}")
    endwhile()

    if(_iteration GREATER_EQUAL _max_iterations)
        message(WARNING "Dependency resolution did not converge after ${_max_iterations} iterations")
    endif()

    # ------------------------------------------------------------------
    # Step 3: Report summary
    # ------------------------------------------------------------------
    set(_enabled_count 0)
    set(_disabled_count 0)
    set(_disabled_list "")
    foreach(_comp IN LISTS _all_dep_components)
        if(CONFIG_${_comp})
            math(EXPR _enabled_count "${_enabled_count} + 1")
        else()
            math(EXPR _disabled_count "${_disabled_count} + 1")
            list(APPEND _disabled_list "${_comp}")
        endif()
    endforeach()

    message(STATUS "============================================")
    message(STATUS "Dependency resolution complete (${_iteration} iterations):")
    message(STATUS "  ${_enabled_count} components enabled")
    message(STATUS "  ${_disabled_count} components disabled by unmet dependencies")
    if(_disabled_list)
        list(LENGTH _disabled_list _dl_len)
        if(_dl_len GREATER 20)
            list(SUBLIST _disabled_list 0 20 _disabled_preview)
            message(STATUS "  Disabled (first 20): ${_disabled_preview} ...")
        else()
            message(STATUS "  Disabled: ${_disabled_list}")
        endif()
    endif()
    message(STATUS "============================================")
endmacro()

# ============================================================================
# Utility Functions
# ============================================================================

# Check if a component is enabled (for use in CMakeLists.txt files)
function(ffmpeg_is_component_enabled component result_var)
    string(TOUPPER "${component}" COMP_UPPER)
    if(CONFIG_${COMP_UPPER})
        set(${result_var} TRUE PARENT_SCOPE)
    else()
        set(${result_var} FALSE PARENT_SCOPE)
    endif()
endfunction()
