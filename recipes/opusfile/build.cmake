# Cross-platform build of opusfile (LAME-style: no upstream CMake, and autotools
# can't run on MSVC, so one CMake build for every platform). Builds a static
# opusfile lib, decode-only (no http -> no openssl, no config.h needed since
# HAVE_CONFIG_H is left undefined). The four libopusfile_la_SOURCES; http.c/
# wincerts.c are the separate libopusurl. A static lib only needs ogg/opus HEADERS
# to compile (the app links the actual ogg/opus libs via the resolved targets), so
# we just add the dep include dirs — no find_package/link. Runs in build_dep
# scope: SRC/INSTALL/BD_DEPENDS_PREFIXES.

set(_dep_incs "")
foreach(p ${BD_DEPENDS_PREFIXES})
    string(APPEND _dep_incs " \"${p}/include\" \"${p}/include/opus\"")
endforeach()

file(WRITE "${SRC}/CMakeLists.txt"
"cmake_minimum_required(VERSION 3.24)\n"
"project(opusfile C)\n"
"add_library(opusfile STATIC src/info.c src/internal.c src/opusfile.c src/stream.c)\n"
"target_include_directories(opusfile PRIVATE \"\${CMAKE_CURRENT_SOURCE_DIR}/include\" \"\${CMAKE_CURRENT_SOURCE_DIR}/src\"${_dep_incs})\n"
"install(TARGETS opusfile ARCHIVE DESTINATION lib)\n"
"install(FILES include/opusfile.h DESTINATION include/opus)\n"
)

_bd_cmake_build("${SRC}")
