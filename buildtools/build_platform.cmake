# build_platform.cmake - build every buildable recipe for a single platform.
#
# Usage (CI or local):
#   cmake -DOS=<macos|linux|windows> -DARCH=<x86_64|aarch64|universal> \
#         -P buildtools/build_platform.cmake
#
# Output goes to .build/platform/out/:
#   - one archive per dep, named <name>-<version>-<os>-<arch>-<sig12>.7z.
#     sig12 is the recipe's signature, any recipe change yields a new name
#   - a lock file fragment:
#       "<name> <version> <os> <arch> <file> <sha256>"

cmake_minimum_required(VERSION 3.24)

if(NOT DEFINED OS OR NOT DEFINED ARCH)
    message(FATAL_ERROR "Required: -DOS=<macos|linux|windows> -DARCH=<x86_64|aarch64|universal>")
endif()

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
set(RECIPES_ROOT "${REPO_ROOT}/recipes")
include("${CMAKE_CURRENT_LIST_DIR}/build_dependency.cmake")

find_program(SEVENZIP NAMES 7z 7za 7zr REQUIRED)

# Prepare staging directory
set(STAGE "${REPO_ROOT}/.build/platform/${OS}_${ARCH}")
file(REMOVE_RECURSE "${STAGE}")
file(MAKE_DIRECTORY "${STAGE}")

# Collect buildable recipes
file(GLOB _specs "${RECIPES_ROOT}/*/spec.cmake")
list(SORT _specs)
set(ALL "")
foreach(_spec ${_specs})
    unset(DEP_SOURCE_URL)
    unset(DEP_DEPENDS)
    unset(DEP_PLATFORMS)
    unset(DEP_VERSION)
    include("${_spec}")

    # Skip if no source is defined
    if(NOT DEFINED DEP_SOURCE_URL)
        continue()
    endif()

    # Skip if the recipe does not support this platform, no DEP_PLATFORMS means "supports all"
    if(DEFINED DEP_PLATFORMS)
        list(FIND DEP_PLATFORMS "${OS}" _os_idx)
        list(FIND DEP_PLATFORMS "${OS}-${ARCH}" _os_arch_idx)
        if(_os_idx EQUAL -1 AND _os_arch_idx EQUAL -1)
            continue()
        endif()
    endif()

    get_filename_component(_name_dir "${_spec}" DIRECTORY)   # recipes/<name>
    get_filename_component(_name "${_name_dir}" NAME)
    set(_version "${DEP_VERSION}")   # the recipe defines the version

    # Read the recipe
    unset(DEP_KIND)
    if(EXISTS "${_name_dir}/meta.cmake")
        include("${_name_dir}/meta.cmake")
    endif()

    # Skip source deps, they are not built
    if(DEP_KIND STREQUAL "source")
        continue()
    endif()

    set(_VER_${_name} "${_version}")
    set(_DEPS_${_name} "")
    foreach(_dep_name ${DEP_DEPENDS})
        list(APPEND _DEPS_${_name} "${_dep_name}")
    endforeach()

    if(DEP_KIND STREQUAL "tool")
        list(APPEND TOOLS "${_name}")
    else()
        list(APPEND ALL "${_name}")
    endif()
endforeach()
list(REMOVE_DUPLICATES ALL)

if(OS STREQUAL "windows")
    set(_path_sep ";")
else()
    set(_path_sep ":")
endif()

# Tools are built before libs and added to PATH as they may be needed at build time.
foreach(_tool ${TOOLS})
    message(STATUS "[platform] tool ${_tool}/${_VER_${_tool}}")
    build_dep(NAME ${_tool} RECIPE_DIR "${RECIPES_ROOT}/${_tool}"
              OS ${OS} ARCH ${ARCH}
              WORK "${REPO_ROOT}/.build/platform/work/${_tool}"
              INSTALL_DIR "${STAGE}/${_tool}")
    set(ENV{PATH} "${STAGE}/${_tool}/bin${_path_sep}$ENV{PATH}")
endforeach()

# Build in dependency order: a dep is built once all its DEP_DEPENDS are built
set(DONE "")
list(LENGTH ALL _remaining)
# Repeat until nothing is left.
while(_remaining GREATER 0)
    set(_progress FALSE) # Did this pass build at least one dep?

    # Iterate over all deps, resolving the graph.
    foreach(_name ${ALL})
        list(FIND DONE "${_name}" _done_idx)
        if(NOT _done_idx EQUAL -1)
            continue() # already built
        endif()

        set(_ready TRUE)
        set(_dep_prefixes "")

        # check if the current item has unresolved deps
        foreach(_dep ${_DEPS_${_name}})
            list(FIND DONE "${_dep}" _dep_idx)
            if(_dep_idx EQUAL -1)
                set(_ready FALSE)
            else()
                list(APPEND _dep_prefixes "${STAGE}/${_dep}")
            endif()
        endforeach()
        if(NOT _ready)
            continue()
        endif()

        message(STATUS "[platform] build ${_name}/${_VER_${_name}}")
        build_dep(NAME ${_name} RECIPE_DIR "${RECIPES_ROOT}/${_name}"
                  OS ${OS} ARCH ${ARCH}
                  WORK "${REPO_ROOT}/.build/platform/work/${_name}" INSTALL_DIR "${STAGE}/${_name}"
                  DEPENDS_PREFIXES "${_dep_prefixes}")
        list(APPEND DONE "${_name}")
        set(_progress TRUE)
    endforeach()

    if(NOT _progress)
        message(FATAL_ERROR "[platform] dependency cycle / missing dep, done: ${DONE}, all: ${ALL}")
    endif()

    list(LENGTH DONE _done_count)
    list(LENGTH ALL _total)
    math(EXPR _remaining "${_total} - ${_done_count}")
endwhile()

# Build finished, now archive and record the outputs
set(OUT_DIR "${REPO_ROOT}/.build/platform/out")
file(REMOVE_RECURSE "${OUT_DIR}")
file(MAKE_DIRECTORY "${OUT_DIR}")
set(_lock "")
foreach(_name ${ALL} ${TOOLS})
    # Signature is based on the recipe, not the built output. Any recipe change
    # gets a new archive name and forces consumers to update.
    _bd_recipe_sig("${RECIPES_ROOT}/${_name}" "${OS}" "${ARCH}" _signature)
    string(SUBSTRING "${_signature}" 0 12 _signature)
    set(_archive "${_name}-${_VER_${_name}}-${OS}-${ARCH}-${_signature}.7z")

    message(STATUS "[platform] package ${_archive}")

    # -mf=off avoids 7z filters that CMake's archive extractor cannot read.
    execute_process(COMMAND ${SEVENZIP} a -t7z -mf=off "${OUT_DIR}/${_archive}" . -x!.build_stamp
                    WORKING_DIRECTORY "${STAGE}/${_name}" RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0)
        message(FATAL_ERROR "[platform] package ${_name} failed (${_result})")
    endif()

    # Prove CMake can read the archive we just produced.
    set(_verify_dir "${OUT_DIR}/.verify")
    file(REMOVE_RECURSE "${_verify_dir}")
    file(MAKE_DIRECTORY "${_verify_dir}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf "${OUT_DIR}/${_archive}"
                    WORKING_DIRECTORY "${_verify_dir}" RESULT_VARIABLE _result)
    file(GLOB_RECURSE _staged "${STAGE}/${_name}/*")
    file(GLOB_RECURSE _extracted "${_verify_dir}/*")
    list(LENGTH _staged _staged_count)
    list(LENGTH _extracted _extracted_count)
    math(EXPR _staged_count "${_staged_count} - 1")   # .build_stamp is excluded from the archive
    if(NOT _result EQUAL 0 OR NOT _staged_count EQUAL _extracted_count)
        message(FATAL_ERROR "[platform] ${_archive}: cmake extracted ${_extracted_count}/${_staged_count} files, archive not consumable")
    endif()
    file(REMOVE_RECURSE "${_verify_dir}")
    file(SHA256 "${OUT_DIR}/${_archive}" _sha)
    string(APPEND _lock "${_name} ${_VER_${_name}} ${OS} ${ARCH} ${_archive} ${_sha}\n")
endforeach()

# Write the lock fragment. The workflow later merges it into prebuilt.lock.
file(WRITE "${OUT_DIR}/prebuilt-${OS}-${ARCH}.lock" "${_lock}")
message(STATUS "[platform] done: ${OUT_DIR}")
