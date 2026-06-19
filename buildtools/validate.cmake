# validate.cmake - check that every recipe is well-formed. Builds nothing.
#
#   cmake -P buildtools/validate.cmake
#
# Run by CI (.github/workflows/validate.yml) and locally before committing recipe
# changes. Exits non-zero (FATAL_ERROR) listing every problem found.

cmake_minimum_required(VERSION 3.24)

get_filename_component(_ROOT "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)   # buildtools/.. = repo root
include("${CMAKE_CURRENT_LIST_DIR}/build_dependency.cmake")           # _bd_recipe_sig

set(_errors 0)
function(_v_err msg)
    math(EXPR _errors "${_errors} + 1")
    set(_errors "${_errors}" PARENT_SCOPE)
    message(STATUS "  FAIL: ${msg}")
endfunction()

set(_recipes_dir "${_ROOT}/recipes")

# Collect every dep name (used for DEP_DEPENDS existence + cycle checks).
file(GLOB _dep_dirs LIST_DIRECTORIES true "${_recipes_dir}/*")
set(_all_names "")
foreach(_d ${_dep_dirs})
    if(IS_DIRECTORY "${_d}")
        get_filename_component(_n "${_d}" NAME)
        list(APPEND _all_names "${_n}")
    endif()
endforeach()

set(_count 0)
set(_with_spec 0)

foreach(_name ${_all_names})
    set(_dir "${_recipes_dir}/${_name}")
    set(_meta "${_dir}/meta.cmake")
    set(_spec "${_dir}/spec.cmake")

    if(NOT EXISTS "${_meta}")
        _v_err("${_name}: missing meta.cmake")
        continue()
    endif()
    math(EXPR _count "${_count} + 1")

    if(EXISTS "${_dir}/${_name}.cmake")
        _v_err("${_name}: stray ${_name}.cmake (metadata must be meta.cmake)")
    endif()

    # Reset recipe vars so one recipe cannot leak into the next.
    foreach(_var DEP_VERSION DEP_KIND DEP_SOURCES DEP_PATCHES DEP_PATCHES_WINDOWS
                 DEP_PATCHES_MACOS DEP_PATCHES_LINUX DEP_DEPENDS DEP_SOURCE_URL)
        unset(${_var})
    endforeach()
    set(_DEPS_${_name} "")

    include("${_meta}")

    # System-only deps (e.g. libcurl, openssl) have an override and no spec.
    if(NOT EXISTS "${_spec}")
        if(NOT COMMAND ${_name}_resolve_override)
            _v_err("${_name}: no spec.cmake and no ${_name}_resolve_override")
        endif()
        continue()
    endif()

    include("${_spec}")
    math(EXPR _with_spec "${_with_spec} + 1")

    if(NOT DEFINED DEP_VERSION OR "${DEP_VERSION}" STREQUAL "")
        _v_err("${_name}: spec.cmake does not set DEP_VERSION")
    endif()

    # DEP_SOURCES: each entry is "sub|kind|location|pin"; kind must be known.
    foreach(_s ${DEP_SOURCES})
        string(REPLACE "|" ";" _sf "${_s}")
        list(LENGTH _sf _nf)
        if(NOT _nf EQUAL 4)
            _v_err("${_name}: DEP_SOURCES entry needs 4 '|' fields: '${_s}'")
        else()
            list(GET _sf 1 _kind)
            if(NOT _kind MATCHES "^(tarball|git|local)$")
                _v_err("${_name}: DEP_SOURCES unknown kind '${_kind}' in '${_s}'")
            endif()
        endif()
    endforeach()

    # Referenced patch files must exist (common + per-OS lists).
    foreach(_p ${DEP_PATCHES} ${DEP_PATCHES_WINDOWS} ${DEP_PATCHES_MACOS} ${DEP_PATCHES_LINUX})
        string(REGEX REPLACE "^.*\\|" "" _prel "${_p}")   # drop optional "<dir>|" prefix
        if(NOT EXISTS "${_dir}/${_prel}")
            _v_err("${_name}: DEP_PATCHES file missing: ${_prel}")
        endif()
    endforeach()

    # DEP_DEPENDS must name real recipes.
    foreach(_dep ${DEP_DEPENDS})
        list(FIND _all_names "${_dep}" _idx)
        if(_idx EQUAL -1)
            _v_err("${_name}: DEP_DEPENDS references unknown dep '${_dep}'")
        endif()
    endforeach()
    set(_DEPS_${_name} "${DEP_DEPENDS}")

    _bd_recipe_sig("${_dir}" "linux" "x86_64" _sig)
    if("${_sig}" STREQUAL "")
        _v_err("${_name}: recipe signature is empty")
    endif()
endforeach()

# Cycle detection over DEP_DEPENDS (Kahn-style: drain nodes whose deps are all done).
set(_remaining "${_all_names}")
set(_done "")
set(_progress TRUE)
while(_progress)
    set(_progress FALSE)
    foreach(_n ${_remaining})
        set(_ready TRUE)
        foreach(_dep ${_DEPS_${_n}})
            list(FIND _all_names "${_dep}" _exists)
            list(FIND _done "${_dep}" _di)
            if(_exists GREATER -1 AND _di EQUAL -1)
                set(_ready FALSE)
            endif()
        endforeach()
        if(_ready)
            list(APPEND _done "${_n}")
            list(REMOVE_ITEM _remaining "${_n}")
            set(_progress TRUE)
        endif()
    endforeach()
endwhile()
if(_remaining)
    _v_err("DEP_DEPENDS cycle / unresolved among: ${_remaining}")
endif()

# prebuilt.lock: every non-empty line must have exactly 7 space-separated fields.
set(_lock "${_ROOT}/prebuilt.lock")
if(EXISTS "${_lock}")
    file(STRINGS "${_lock}" _lines)
    set(_ln 0)
    foreach(_line ${_lines})
        math(EXPR _ln "${_ln} + 1")
        string(STRIP "${_line}" _stripped)
        if("${_stripped}" STREQUAL "")
            continue()
        endif()
        string(REPLACE " " ";" _f "${_stripped}")
        list(LENGTH _f _nf)
        if(NOT _nf EQUAL 7)
            _v_err("prebuilt.lock line ${_ln}: expected 7 fields, got ${_nf}")
        endif()
    endforeach()
endif()

if(_errors GREATER 0)
    message(FATAL_ERROR "validate: ${_errors} problem(s) found")
endif()
message(STATUS "validate: OK - ${_count} deps (${_with_spec} buildable), recipes + prebuilt.lock well-formed")