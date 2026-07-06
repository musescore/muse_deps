# PipeWire ships a Meson build, and muse_deps has no generic Meson helper
# yet, so this recipe fetches Meson's own pinned source release (no system
# pip install, so the build stays reproducible) and drives it directly.

set(_meson_version 1.11.1)
set(_meson_archive_name "meson-${_meson_version}.tar.gz")
set(_meson_sha256 "6788ae299979643f8d841bcaf64352558436cae45a0355148a3aeeccf7913866")
set(_meson_url "https://github.com/mesonbuild/meson/releases/download/${_meson_version}/${_meson_archive_name}")

set(_meson_download_dir "${BD_CACHE}/downloads/meson")
set(_meson_archive "${_meson_download_dir}/${_meson_archive_name}")
if(EXISTS "${_meson_archive}")
    file(SHA256 "${_meson_archive}" _got_sha256)
    if(NOT _got_sha256 STREQUAL _meson_sha256)
        message(FATAL_ERROR "[${BD_NAME}] cached ${_meson_archive_name} SHA256 mismatch: ${_got_sha256} != ${_meson_sha256}")
    endif()
else()
    file(MAKE_DIRECTORY "${_meson_download_dir}")
    _bd_fetch("${_meson_archive}" "${_meson_sha256}" "${_meson_url}")
endif()

set(_meson_root "${BD_WORK}/meson")
file(MAKE_DIRECTORY "${_meson_root}")
file(ARCHIVE_EXTRACT INPUT "${_meson_archive}" DESTINATION "${_meson_root}")
set(_meson_py "${_meson_root}/meson-${_meson_version}/meson.py")

find_program(PYTHON3 NAMES python3 REQUIRED)
find_program(NINJA NAMES ninja REQUIRED)

# Map the engine's CMake-style config onto a Meson buildtype
if(BD_CONFIG STREQUAL "Debug")
    set(_meson_buildtype debug)
elseif(BD_CONFIG STREQUAL "MinSizeRel")
    set(_meson_buildtype minsize)
elseif(BD_CONFIG STREQUAL "Release")
    set(_meson_buildtype release)
else()
    set(_meson_buildtype debugoptimized)
endif()

_bd_run(${PYTHON3} "${_meson_py}" setup "${BUILD}" "${SRC}"
    --prefix "${INSTALL}"
    --libdir lib
    --buildtype "${_meson_buildtype}"
    ${DEP_MESON_ARGS}
)
_bd_run(${PYTHON3} "${_meson_py}" compile -C "${BUILD}")
_bd_run(${PYTHON3} "${_meson_py}" install -C "${BUILD}")
