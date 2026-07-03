# manifest.cmake - consumer API for pulling external deps into an app
#
#   - every consumed dep is appended to the EXTDEPS_CONSUMED global property
#   - per-dep globals (<name>_INSTALL_LIBRARIES, <name>_PREFIX)

cmake_minimum_required(VERSION 3.25)

get_filename_component(EXTDEPS_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)

# Path to fetch deps into
if (NOT DEFINED LOCAL_ROOT_PATH OR LOCAL_ROOT_PATH STREQUAL "")
    set(LOCAL_ROOT_PATH "${CMAKE_BINARY_DIR}/_deps")
endif()

# when started in script mode CMAKE_SYSTEM_NAME and CMAKE_SYSTEM_PROCESSOR are not set
# set them explicitly
set(_extdeps_sys "${CMAKE_SYSTEM_NAME}")
set(_extdeps_proc "${CMAKE_SYSTEM_PROCESSOR}")
if (_extdeps_sys STREQUAL "")
    cmake_host_system_information(RESULT _extdeps_sys QUERY OS_NAME)
    cmake_host_system_information(RESULT _extdeps_proc QUERY OS_PLATFORM)
endif()

if (NOT DEFINED LIB_OS OR LIB_OS STREQUAL "")
    if (_extdeps_sys STREQUAL "Windows")
        set(LIB_OS "windows")
    elseif (_extdeps_sys MATCHES "Darwin|macOS")
        set(LIB_OS "macos")
    else()
        set(LIB_OS "linux")
    endif()
endif()

if (NOT DEFINED LIB_ARCH OR LIB_ARCH STREQUAL "")
    if (LIB_OS STREQUAL "macos")
        list(LENGTH CMAKE_OSX_ARCHITECTURES _arch_count)
        if (_arch_count GREATER 1)
            set(LIB_ARCH "universal")
        elseif (CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
            set(LIB_ARCH "aarch64")
        elseif (CMAKE_OSX_ARCHITECTURES STREQUAL "x86_64")
            set(LIB_ARCH "x86_64")
        elseif (_extdeps_proc MATCHES "arm64|aarch64")
            set(LIB_ARCH "aarch64")
        else()
            set(LIB_ARCH "x86_64")
        endif()
    elseif (_extdeps_proc MATCHES "[Aa][Rr][Mm]64|aarch64")
        set(LIB_ARCH "aarch64")
    else()
        set(LIB_ARCH "x86_64")
    endif()
endif()

# dependency releases are RelWithDebInfo, debug app builds on windows require
# Debug library builds, so they will be rebuilt
if (NOT DEFINED EXTDEPS_BUILD_CONFIG OR EXTDEPS_BUILD_CONFIG STREQUAL "")
    if (LIB_OS STREQUAL "windows" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(EXTDEPS_BUILD_CONFIG "Debug")
    else()
        set(EXTDEPS_BUILD_CONFIG "RelWithDebInfo")
    endif()
endif()

# Allow forcing the mode from the environment.
# An explicit -D has priority.
if (NOT DEFINED EXTDEPS_OVERRIDE_ALL AND DEFINED ENV{EXTDEPS_OVERRIDE_ALL})
    set(EXTDEPS_OVERRIDE_ALL "$ENV{EXTDEPS_OVERRIDE_ALL}")
endif()

# download cache location for source / REBUILD builds:
# -DEXTDEPS_CACHE highest priority
# pre-set $EXTDEPS_CACHE
# else ~/.cache
if (EXTDEPS_CACHE)
    set(ENV{EXTDEPS_CACHE} "${EXTDEPS_CACHE}")
endif()

# runs dependency resolution for a single dep
# - name: the dep name
# - mode: the mode to resolve in: prebuilt, system, rebuild
function(_extdeps_run name mode)
    set(local_path ${LOCAL_ROOT_PATH}/${name})

    # read the dep metadata and recipe
    include("${EXTDEPS_DIR}/recipes/${name}/meta.cmake")
    set(version "")
    if (NOT mode STREQUAL "system")
        include("${EXTDEPS_DIR}/recipes/${name}/spec.cmake")
        set(version "${DEP_VERSION}")
        if ("${version}" STREQUAL "")
            message(FATAL_ERROR "[deps] '${name}': recipe spec.cmake is missing DEP_VERSION")
        endif()
    endif()

    # local source type is for local development, built in place
    foreach(_source ${DEP_SOURCES})
        string(REPLACE "|" ";" _source_fields "${_source}")
        list(GET _source_fields 1 _source_kind)
        if(_source_kind STREQUAL "local")
            list(GET _source_fields 2 _source_location)
            get_filename_component(local_path "${_source_location}" DIRECTORY)
        endif()
    endforeach()

    # resolve the dep: fetch the prebuilt or source, or bind the system package
    include("${EXTDEPS_DIR}/buildtools/resolve.cmake")
    extdeps_resolve("${name}" "${version}" "${mode}" "${local_path}" "${LIB_OS}" "${LIB_ARCH}" "${EXTDEPS_BUILD_CONFIG}")
    set_property(GLOBAL PROPERTY ${name}_PREFIX "${local_path}")
    set_property(GLOBAL APPEND PROPERTY EXTDEPS_CONSUMED "${name}")
endfunction()

# require_dep and require_source_dep call this to check for an override.
# - name: the dep name, for per-dep overrides
# - manifest_mode: mode requested by the manifest
# - out: the variable to write the resolved mode into (prebuilt, system, rebuild)
function(_extdeps_override name manifest_mode out)
    string(TOUPPER ${name} _name_upper)

    # Per-dep override has a priority over _ALL
    set(_value "")
    if (DEFINED EXTDEPS_OVERRIDE_${_name_upper})
        set(_value "${EXTDEPS_OVERRIDE_${_name_upper}}")
    elseif (DEFINED EXTDEPS_OVERRIDE_ALL AND NOT manifest_mode STREQUAL "system")
        set(_value "${EXTDEPS_OVERRIDE_ALL}")
    endif()

    # No override, leave the manifest mode in place
    if ("${_value}" STREQUAL "")
        set(${out} "" PARENT_SCOPE)
        return()
    endif()

    string(TOUPPER "${_value}" _value)
    if (_value STREQUAL "REBUILD")
        set(${out} "rebuild" PARENT_SCOPE)
    elseif (_value STREQUAL "SYSTEM")
        set(${out} "system" PARENT_SCOPE)
    elseif (_value STREQUAL "PREBUILT")
        set(${out} "prebuilt" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "[deps] ${name}: EXTDEPS_OVERRIDE_* must be REBUILD, SYSTEM or PREBUILT (got '${_value}')")
    endif()
endfunction()

# The main entry point: resolve include dirs / link libs / install libs for
# a dep and create its imported target
function(require_dep name)

    if (ARGC GREATER 2)
        message(FATAL_ERROR "[deps] ${name}: require_dep accepts at most one mode argument")
    endif()

    # Default to prebuilt
    set(mode "prebuilt")
    if ("${ARGV1}" STREQUAL "SYSTEM")
        set(mode "system")
    elseif ("${ARGV1}" STREQUAL "REBUILD")
        set(mode "rebuild")
    elseif (NOT "${ARGV1}" STREQUAL "")
        message(FATAL_ERROR "[deps] ${name}: require_dep accepts only REBUILD or SYSTEM (got '${ARGV1}')")
    endif()

    # An environment override can change the mode
    _extdeps_override("${name}" "${mode}" _override)
    if (NOT "${_override}" STREQUAL "")
        set(mode "${_override}")
    endif()

    _extdeps_run("${name}" "${mode}")

    # Hand the resolved dirs / libs back to the caller's scope
    get_property(include_dirs GLOBAL PROPERTY ${name}_INCLUDE_DIRS)
    get_property(libraries GLOBAL PROPERTY ${name}_LIBRARIES)
    get_property(install_libraries GLOBAL PROPERTY ${name}_INSTALL_LIBRARIES)
    set(${name}_INCLUDE_DIRS ${include_dirs} PARENT_SCOPE)
    set(${name}_LIBRARIES ${libraries} PARENT_SCOPE)
    set(${name}_INSTALL_LIBRARIES ${install_libraries} PARENT_SCOPE)
endfunction()

# Build-time tools, not linked into the app, but used during the build
# (e.g. yasm for mpg123's x86 / x64 asm decoder)
# They are fetched and their bin/ directories are prepended to PATH
# so later dep builds' find_program() locate them
function(require_tool name)
    set(mode "prebuilt")
    _extdeps_override("${name}" "${mode}" _override)
    if (NOT "${_override}" STREQUAL "")
        set(mode "${_override}")
    endif()
    _extdeps_run("${name}" "${mode}")

    # Put the tool's bin/ on PATH so the builds that follow can find it
    get_property(bin_dir GLOBAL PROPERTY ${name}_BIN_DIR)
    if (bin_dir)
        if (WIN32)
            set(ENV{PATH} "${bin_dir};$ENV{PATH}")
        else()
            set(ENV{PATH} "${bin_dir}:$ENV{PATH}")
        endif()
        message(STATUS "[tool] ${name} available on PATH (${bin_dir})")
    endif()
endfunction()

# Dependency type that is built in-tree from source: header-only libraries
# or dependencies that are used not as a library (e.g. lv2sdk)
function(require_source_dep name)
    if (ARGC GREATER 2)
        message(FATAL_ERROR "[deps] ${name}: require_source_dep accepts at most one mode argument")
    endif()

    # Default to rebuild, the optional argument can ask for system
    set(mode "rebuild")
    if ("${ARGV1}" STREQUAL "SYSTEM")
        set(mode "system")
    elseif (NOT "${ARGV1}" STREQUAL "")
        message(FATAL_ERROR "[deps] ${name}: require_source_dep accepts only SYSTEM (got '${ARGV1}')")
    endif()

    _extdeps_override("${name}" "${mode}" _override)
    if (NOT "${_override}" STREQUAL "")
        set(mode "${_override}")
    endif()

    # only allow system if the dep has a system path
    if (mode STREQUAL "system" AND NOT "${ARGV1}" STREQUAL "SYSTEM")
        include("${EXTDEPS_DIR}/recipes/${name}/meta.cmake")
        if (NOT DEP_SOURCE_SYSTEM)
            set(mode "rebuild")
        endif()
    endif()

    _extdeps_run("${name}" "${mode}")
endfunction()

# Package the runtime libraries and licenses of all consumed deps into the app
function(extdeps_install_consumed)
    cmake_parse_arguments(ARG "" "MACOS_BUNDLE" "" ${ARGN})

    get_property(_deps GLOBAL PROPERTY EXTDEPS_CONSUMED)
    list(REMOVE_DUPLICATES _deps)
    foreach(_dep ${_deps})

        # Install the runtime libraries
        get_property(_libs GLOBAL PROPERTY ${_dep}_INSTALL_LIBRARIES)
        if (_libs)
            if (APPLE)
                install(FILES ${_libs} DESTINATION "${ARG_MACOS_BUNDLE}/Contents/Frameworks")
            elseif (WIN32)
                install(FILES ${_libs} TYPE BIN)
            else()
                install(FILES ${_libs} TYPE LIB)
            endif()
        endif()

        # Install the license
        get_property(_prefix GLOBAL PROPERTY ${_dep}_PREFIX)
        if (_prefix AND EXISTS "${_prefix}/licenses")
            if (APPLE)
                install(DIRECTORY "${_prefix}/licenses/" DESTINATION "${ARG_MACOS_BUNDLE}/Contents/Resources/licenses/${_dep}")
            else()
                install(DIRECTORY "${_prefix}/licenses/" DESTINATION licenses/${_dep})
            endif()
        endif()
    endforeach()
endfunction()
