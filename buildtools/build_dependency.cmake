# Builds a single dependency

# Release download root
# Resolution order (first wins):
#   1. -DEXTDEPS_PREBUILT_URL=<url>       explicit per-run override
#   2. $EXTDEPS_PREBUILT_URL              environment
#   3. prebuilt_url.txt at the repo root
#   4. hard-coded default
if(NOT DEFINED EXTDEPS_PREBUILT_URL AND DEFINED ENV{EXTDEPS_PREBUILT_URL})
    set(EXTDEPS_PREBUILT_URL "$ENV{EXTDEPS_PREBUILT_URL}")
endif()
if(NOT EXTDEPS_PREBUILT_URL AND EXISTS "${CMAKE_CURRENT_LIST_DIR}/../prebuilt_url.txt")
    file(READ "${CMAKE_CURRENT_LIST_DIR}/../prebuilt_url.txt" EXTDEPS_PREBUILT_URL)
    string(STRIP "${EXTDEPS_PREBUILT_URL}" EXTDEPS_PREBUILT_URL)
endif()
if(NOT EXTDEPS_PREBUILT_URL)
    set(EXTDEPS_PREBUILT_URL "https://github.com/musescore/muse_deps/releases/download")
endif()

get_filename_component(_BD_REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)

# Source download cache location. order same as above. (todo: find a better place on Windows)
function(_bd_resolve_cache out)
    if(DEFINED ENV{EXTDEPS_CACHE})
        set(${out} "$ENV{EXTDEPS_CACHE}" PARENT_SCOPE)
    elseif(DEFINED ENV{XDG_CACHE_HOME})
        set(${out} "$ENV{XDG_CACHE_HOME}/extdeps" PARENT_SCOPE)
    else()
        set(${out} "$ENV{HOME}/.cache/extdeps" PARENT_SCOPE)
    endif()
endfunction()

# Get the archive extension from a basename
function(_bd_src_ext basename out)
    if(basename MATCHES "\\.(tar\\.gz|tar\\.xz|tar\\.bz2|tgz|zip)$")
        set(${out} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        get_filename_component(_ext "${basename}" LAST_EXT)
        string(REGEX REPLACE "^\\." "" _ext "${_ext}")
        set(${out} "${_ext}" PARENT_SCOPE)
    endif()
endfunction()

# Return the source mirror URL, read from env or prebuilt.lock
function(_bd_mirror repo_root out)
    if(DEFINED ENV{EXTDEPS_MIRROR})
        set(${out} "$ENV{EXTDEPS_MIRROR}" PARENT_SCOPE)
        return()
    endif()
    set(${out} "" PARENT_SCOPE)
    set(lock_file "${repo_root}/prebuilt.lock")
    if(NOT EXISTS "${lock_file}")
        return()
    endif()
    file(STRINGS "${lock_file}" first_line LIMIT_COUNT 1)
    if(NOT first_line)
        return()
    endif()
    string(REGEX MATCH "[^ ]+$" release_tag "${first_line}")
    set(_base "${EXTDEPS_PREBUILT_URL}")
    if(EXISTS "${repo_root}/prebuilt_url.txt")
        file(READ "${repo_root}/prebuilt_url.txt" _base)
        string(STRIP "${_base}" _base)
    endif()
    set(${out} "${_base}/${release_tag}" PARENT_SCOPE)
endfunction()

# Split a DEP_SOURCES entry "sub|kind|location|pin" into its four fields.
macro(_bd_parse_source entry out_sub out_kind out_loc out_pin)
    string(REPLACE "|" ";" _bd_sf "${entry}")
    list(GET _bd_sf 0 ${out_sub})
    list(GET _bd_sf 1 ${out_kind})
    list(GET _bd_sf 2 ${out_loc})
    list(GET _bd_sf 3 ${out_pin})
endmacro()

# Try each URL in turn (retrying, verifying sha256).
# Sets out_ok TRUE on the first good download
function(_bd_try_fetch dest sha256 out_ok)
    set(${out_ok} FALSE PARENT_SCOPE)
    foreach(url ${ARGN})
        foreach(attempt 1 2 3)
            file(DOWNLOAD "${url}" "${dest}" STATUS _status INACTIVITY_TIMEOUT 30)
            list(GET _status 0 _code)
            if(_code EQUAL 0)
                file(SHA256 "${dest}" _got_sha256)
                if(_got_sha256 STREQUAL "${sha256}")
                    set(${out_ok} TRUE PARENT_SCOPE)
                    return()
                endif()
                message(WARNING "[fetch] ${url}: sha256 ${_got_sha256} != ${sha256}")
            else()
                message(STATUS "[fetch] attempt ${attempt} failed: ${url} (${_status})")
            endif()
            file(REMOVE "${dest}")
        endforeach()
    endforeach()
endfunction()

# Download from the first working URL or fail hard.
function(_bd_fetch dest sha256)
    _bd_try_fetch("${dest}" "${sha256}" _ok ${ARGN})
    if(NOT _ok)
        message(FATAL_ERROR "[fetch] all sources failed for ${dest}")
    endif()
endfunction()

# Run a command with reporting
function(_bd_run)
    execute_process(COMMAND ${ARGN} RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0)
        message(FATAL_ERROR "Command failed (${_result}): ${ARGN}")
    endif()
endfunction()

# Run a command in a working directory with reporting
function(_bd_run_dir wd)
    execute_process(COMMAND ${ARGN} WORKING_DIRECTORY "${wd}" RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0)
        message(FATAL_ERROR "Command failed (${_result}) in ${wd}: ${ARGN}")
    endif()
endfunction()

# Configure, build, and install a standard CMake project.
function(_bd_cmake_build srcdir)
    string(REPLACE "@RECIPE_DIR@" "${BD_RECIPE_DIR}" _dep_cmake_args "${DEP_CMAKE_ARGS}")
    set(_configure_args -S "${srcdir}" -B "${BUILD}" -G Ninja
            -DCMAKE_BUILD_TYPE=${BD_CONFIG}
            -DCMAKE_INSTALL_PREFIX=${INSTALL}
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5
            ${_dep_cmake_args})

    # Prepare initial cache variables
    set(_initial_cache "")
    if(BD_DEPENDS_PREFIXES)
        string(APPEND _initial_cache "set(CMAKE_PREFIX_PATH \"${BD_DEPENDS_PREFIXES}\" CACHE STRING \"\" FORCE)\n")
    endif()

    if(BD_OS STREQUAL "macos")
        if(BD_ARCH STREQUAL "universal")
            set(_osx_archs "x86_64;arm64")
        elseif(BD_ARCH STREQUAL "aarch64")
            set(_osx_archs "arm64")
        else()
            set(_osx_archs "x86_64")
        endif()
        string(APPEND _initial_cache "set(CMAKE_OSX_ARCHITECTURES \"${_osx_archs}\" CACHE STRING \"\" FORCE)\n")
        string(APPEND _initial_cache "set(CMAKE_OSX_DEPLOYMENT_TARGET \"${DEP_MACOS_DEPLOYMENT_TARGET}\" CACHE STRING \"\" FORCE)\n")
    endif()

    if(_initial_cache)
        file(MAKE_DIRECTORY "${BUILD}")
        file(WRITE "${BUILD}/init.cmake" "${_initial_cache}")
        list(APPEND _configure_args -C "${BUILD}/init.cmake")
    endif()

    # Run configure and build
    _bd_run(${CMAKE_COMMAND} ${_configure_args})
    _bd_run(${CMAKE_COMMAND} --build "${BUILD}" --config ${BD_CONFIG} --target install --parallel)
endfunction()

# Linux: ensure installed shared libs have their SONAME symlinks.
function(_bd_ensure_sonames os name install_dir)
    if(NOT os STREQUAL "linux")
        return()
    endif()
    find_program(READELF NAMES readelf)
    file(GLOB _shared_libs "${install_dir}/lib/*.so.*")
    foreach(_shared_lib ${_shared_libs})
        if(IS_SYMLINK "${_shared_lib}")
            continue()
        endif()
        get_filename_component(_lib_dir "${_shared_lib}" DIRECTORY)
        get_filename_component(_lib_name "${_shared_lib}" NAME)
        set(_wanted "")
        if(_lib_name MATCHES "^(.+\\.so\\.[0-9]+)\\.")
            list(APPEND _wanted "${CMAKE_MATCH_1}")
        endif()
        if(READELF)
            execute_process(COMMAND ${READELF} -d "${_shared_lib}"
                            OUTPUT_VARIABLE _dynamic_section ERROR_QUIET RESULT_VARIABLE _result)
            if(_result EQUAL 0 AND _dynamic_section MATCHES "\\(SONAME\\)[^\n]*\\[([^]]+)\\]")
                list(APPEND _wanted "${CMAKE_MATCH_1}")
            endif()
        endif()
        if(_wanted)
            list(REMOVE_DUPLICATES _wanted)
        endif()
        foreach(_soname ${_wanted})
            if(NOT _soname STREQUAL _lib_name AND NOT EXISTS "${_lib_dir}/${_soname}")
                file(CREATE_LINK "${_lib_name}" "${_lib_dir}/${_soname}" SYMBOLIC)
                message(STATUS "[${name}] soname symlink ${_soname} -> ${_lib_name}")
            endif()
        endforeach()
    endforeach()
endfunction()

# macOS: make installed dylibs relocatable.
function(_bd_relocatable_macos os install_dir)
    if(NOT os STREQUAL "macos")
        return()
    endif()
    find_program(INSTALL_NAME_TOOL NAMES install_name_tool)
    find_program(OTOOL NAMES otool)
    if(NOT INSTALL_NAME_TOOL OR NOT OTOOL)
        return()
    endif()
    file(GLOB _dylibs "${install_dir}/lib/*.dylib")
    foreach(_dylib ${_dylibs})
        if(IS_SYMLINK "${_dylib}")
            continue()
        endif()
        execute_process(COMMAND ${OTOOL} -D "${_dylib}" OUTPUT_VARIABLE _install_name ERROR_QUIET)
        get_filename_component(_name "${_dylib}" NAME)
        if(NOT _install_name MATCHES "@rpath/")
            execute_process(COMMAND ${INSTALL_NAME_TOOL} -id "@rpath/${_name}" "${_dylib}" ERROR_QUIET)
            message(STATUS "[${BD_NAME}] install_name -> @rpath/${_name}")
        endif()
    endforeach()
endfunction()

# Create a signature of the recipe directory and its contents
function(_bd_recipe_sig recipe_dir os arch out)
    set(_BD_ENGINE_REV 3)
    set(_sig "${_BD_ENGINE_REV}|${os}|${arch}")
    file(GLOB_RECURSE _files "${recipe_dir}/*")
    list(SORT _files)
    foreach(_file ${_files})
        # meta.cmake describes how the dep is consumed, not how it is built,
        # so it is excluded from the build signature.
        if(_file STREQUAL "${recipe_dir}/meta.cmake")
            continue()
        endif()
        file(SHA256 "${_file}" _hash)
        string(APPEND _sig "|${_hash}")
    endforeach()
    string(SHA256 _sig "${_sig}")
    set(${out} "${_sig}" PARENT_SCOPE)
endfunction()

function(build_dep)
    cmake_parse_arguments(BD "" "NAME;RECIPE_DIR;OS;ARCH;WORK;INSTALL_DIR;CACHE;CONFIG" "DEPENDS_PREFIXES" ${ARGN})

    if(NOT BD_CONFIG)
        set(BD_CONFIG "RelWithDebInfo")
    endif()

    if(NOT BD_CONFIG MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
        message(FATAL_ERROR "[${BD_NAME}] invalid CONFIG '${BD_CONFIG}' (expected a CMake build type)")
    endif()

    # Clear existing DEP_* variables so recipes do not leak into each other
    get_cmake_property(_allvars VARIABLES)
    foreach(_v ${_allvars})
        if(_v MATCHES "^DEP_")
            unset(${_v})
        endif()
    endforeach()

    # Read the recipe
    include("${BD_RECIPE_DIR}/spec.cmake")

    # Apply platform-specific overrides
    string(TOUPPER "${BD_OS}" _os)
    foreach(_key CMAKE_ARGS PATCHES)
        if(DEFINED DEP_${_key}_${_os})
            list(APPEND DEP_${_key} ${DEP_${_key}_${_os}})
        endif()
    endforeach()

    # Detect if there the recipe was alredy built
    _bd_recipe_sig("${BD_RECIPE_DIR}" "${BD_OS}" "${BD_ARCH}" _build_sig)
    set(_build_sig "${_build_sig}|${BD_CONFIG}")
    set(_build_stamp "${BD_INSTALL_DIR}/.build_stamp")
    if(EXISTS "${_build_stamp}")
        file(READ "${_build_stamp}" _prev_sig)
        if(_prev_sig STREQUAL "${_build_sig}")
            message(STATUS "[${BD_NAME}] up-to-date (recipe unchanged), skipping build")
            _bd_ensure_sonames("${BD_OS}" "${BD_NAME}" "${BD_INSTALL_DIR}")
            _bd_relocatable_macos("${BD_OS}" "${BD_INSTALL_DIR}")
            return()
        endif()
    endif()

    find_program(GIT NAMES git REQUIRED)

    if(NOT BD_CACHE)
        _bd_resolve_cache(BD_CACHE)
    endif()

    set(SRC "${BD_WORK}/src")
    set(BUILD "${BD_WORK}/build")
    file(REMOVE_RECURSE "${BD_WORK}")
    file(MAKE_DIRECTORY "${BD_WORK}")

    # Get sources
    set(_download_dir "${BD_CACHE}/downloads/${BD_NAME}")
    get_filename_component(_basename "${DEP_SOURCE_URL}" NAME)
    set(_archive "${_download_dir}/${_basename}")
    if(EXISTS "${_archive}")
        file(SHA256 "${_archive}" _got_sha256)
        if(NOT _got_sha256 STREQUAL "${DEP_SOURCE_SHA256}")
            message(FATAL_ERROR "[${BD_NAME}] cached ${_basename} SHA256 mismatch: ${_got_sha256} != ${DEP_SOURCE_SHA256}")
        endif()
        message(STATUS "[${BD_NAME}] cached ${_basename}")
    else()
        file(MAKE_DIRECTORY "${_download_dir}")
        message(STATUS "[${BD_NAME}] fetch ${DEP_SOURCE_URL}")
        set(_repo_root "${_BD_REPO_ROOT}")
        set(_version "${DEP_VERSION}")

        # First try our own presaved mirror,
        # if the depencency is new, then fetch from upstream
        # NOTE: some hosts do not like github CI IPs, you may need a workaround to get
        # tarballs into the system
        _bd_mirror("${_repo_root}" _mirror)
        set(_urls "")
        if(_mirror)
            _bd_src_ext("${_basename}" _ext)
            list(APPEND _urls "${_mirror}/${BD_NAME}-${_version}-src.${_ext}")
        endif()
        list(APPEND _urls "${DEP_SOURCE_URL}")
        _bd_fetch("${_archive}" "${DEP_SOURCE_SHA256}" ${_urls})
    endif()

    # Extract the source archive
    set(_extract_dir "${BD_WORK}/extract")
    file(MAKE_DIRECTORY "${_extract_dir}")
    file(ARCHIVE_EXTRACT INPUT "${_archive}" DESTINATION "${_extract_dir}")
    file(GLOB _top LIST_DIRECTORIES true "${_extract_dir}/*")
    list(LENGTH _top _top_count)
    if(_top_count EQUAL 1)
        list(GET _top 0 _source_root)
        file(RENAME "${_source_root}" "${SRC}")
    else()
        file(RENAME "${_extract_dir}" "${SRC}")
    endif()

    # Apply patches
    foreach(_patch ${DEP_PATCHES})
        message(STATUS "[${BD_NAME}] patch ${_patch}")
        _bd_run(${CMAKE_COMMAND} -E env GIT_DIR=${BD_WORK}/.no-such-repo
                ${GIT} apply --whitespace=nowarn "${BD_RECIPE_DIR}/${_patch}" WORKING_DIRECTORY "${SRC}")
        file(SHA256 "${BD_RECIPE_DIR}/${_patch}" _patch_hash)
        string(SUBSTRING "${_patch_hash}" 0 8 _patch_hash)
        message(STATUS "[${BD_NAME}] patch ${_patch} applied (${_patch_hash})")
    endforeach()

    # Build and install
    set(INSTALL "${BD_INSTALL_DIR}")
    if(NOT DEFINED DEP_MACOS_DEPLOYMENT_TARGET)
        # DM: should this be configurable?
        set(DEP_MACOS_DEPLOYMENT_TARGET "12.0")
    endif()

    # If the recipe has a build.cmake, run it
    if(EXISTS "${BD_RECIPE_DIR}/build.cmake")
        include("${BD_RECIPE_DIR}/build.cmake")
    # Otherwise, assume a standard CMake project
    else()
        set(_cmake_source_dir "${SRC}")
        if(DEP_CMAKE_SOURCE_SUBDIR)
            set(_cmake_source_dir "${SRC}/${DEP_CMAKE_SOURCE_SUBDIR}")
        endif()
        _bd_cmake_build("${_cmake_source_dir}")
    endif()

    # Install license files
    if(DEFINED DEP_LICENSE_FILES)
        file(MAKE_DIRECTORY "${INSTALL}/licenses")
        foreach(_license_file ${DEP_LICENSE_FILES})
            file(COPY "${SRC}/${_license_file}" DESTINATION "${INSTALL}/licenses")
        endforeach()
    endif()

    # Fix-up installed libraries
    _bd_ensure_sonames("${BD_OS}" "${BD_NAME}" "${INSTALL}")
    _bd_relocatable_macos("${BD_OS}" "${INSTALL}")

    # Record the build signature
    file(WRITE "${_build_stamp}" "${_build_sig}")
endfunction()
