# Stage every dep's upstream source tarball for a release.
#
# Usage (CI or local):
#   cmake -P buildtools/mirror_sources.cmake
#
# Downloads every dep's upstream source tarball, verifies its SHA-256, and
# stages it into .build/mirror/. The workflow attaches these to the release for
# CI prebuilt builds and local rebuilds.

cmake_minimum_required(VERSION 3.24)

set(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(OUT_DIR "${REPO_ROOT}/.build/mirror")
file(REMOVE_RECURSE "${OUT_DIR}")
file(MAKE_DIRECTORY "${OUT_DIR}")

include("${CMAKE_CURRENT_LIST_DIR}/build_dependency.cmake")   # _bd_src_ext, _bd_mirror, _bd_fetch

# Fetch and stage a source tarball
# - label: the staged filename prefix (e.g. "wxwidgets-3.2.2")
# - url: the upstream URL to fetch
# - sha256: the expected SHA-256
function(_mirror_fetch label url sha256)
    get_filename_component(_basename "${url}" NAME)
    if(_basename MATCHES "^git_revision:")
        set(_basename "${label}.zip")
    endif()

    _bd_src_ext("${_basename}" _ext)
    set(_dst_path "${OUT_DIR}/${label}-src.${_ext}")
    if(EXISTS "${_dst_path}")
        return()   # already mirrored
    endif()

    # Try the previous release mirror first. Fetch from upstream when the pin is new.
    _bd_mirror("${REPO_ROOT}" _prev_mirror)
    set(_urls "")
    if(_prev_mirror)
        list(APPEND _urls "${_prev_mirror}/${label}-src.${_ext}")
    endif()
    list(APPEND _urls "${url}")
    message(STATUS "[mirror] ${label}")
    _bd_fetch("${_dst_path}" "${sha256}" ${_urls})
endfunction()

# Mirror a single dep's sources
# - spec: the recipe spec.cmake to read
function(_mirror_one spec)
    include("${spec}")                                      # defines DEP_VERSION
    get_filename_component(_name_dir "${spec}" DIRECTORY)   # recipes/<name>
    get_filename_component(_name "${_name_dir}" NAME)
    set(_version "${DEP_VERSION}")

    # Mirror the primary source tarball
    if(DEFINED DEP_SOURCE_URL AND DEFINED DEP_SOURCE_SHA256)
        _mirror_fetch("${_name}-${_version}" "${DEP_SOURCE_URL}" "${DEP_SOURCE_SHA256}")
    endif()

    # Mirror any additional source tarballs
    foreach(_source ${DEP_SOURCES})
        _bd_parse_source("${_source}" _source_sub _source_kind _source_location _source_sha256)
        # For now only tarballs are mirrored.
        if(_source_kind STREQUAL "tarball")
            if(_source_sub STREQUAL _name)
                _mirror_fetch("${_name}-${_version}" "${_source_location}" "${_source_sha256}")
            else()
                _mirror_fetch("${_name}-${_source_sub}" "${_source_location}" "${_source_sha256}")
            endif()
        endif()
    endforeach()
endfunction()

# Walk over every spec.cmake in the repo and mirror its sources
file(GLOB _specs "${REPO_ROOT}/recipes/*/spec.cmake")
foreach(_spec ${_specs})
    _mirror_one("${_spec}")
endforeach()

message(STATUS "[mirror] staged into ${OUT_DIR}")
