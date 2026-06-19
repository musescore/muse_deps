# Cross-platform static build of libopusenc (LAME/opusfile-style: no upstream
# CMake, and autotools can't run on MSVC, so one CMake build for every platform).
# opusenc.c uses PACKAGE_NAME/PACKAGE_VERSION unguarded, so we generate a minimal
# config.h (the only autotools macros the code needs; all HAVE_* checks are
# #ifdef, i.e. absent == off) and define HAVE_CONFIG_H. OUTSIDE_SPEEX +
# RANDOM_PREFIX namespace the bundled speex resampler (resample.c). ogg + opus are
# header-only here (the app links the real libs via the resolved targets), so we
# just add the dep include dirs. Runs in build_dep scope: SRC/INSTALL/BD_DEPENDS_PREFIXES.

file(WRITE "${SRC}/config.h"
"#define PACKAGE_NAME \"libopusenc\"\n"
"#define PACKAGE_VERSION \"0.2.1\"\n"
)

set(_dep_incs "")
foreach(p ${BD_DEPENDS_PREFIXES})
    string(APPEND _dep_incs " \"${p}/include\" \"${p}/include/opus\"")
endforeach()

file(WRITE "${SRC}/CMakeLists.txt"
"cmake_minimum_required(VERSION 3.24)\n"
"project(opusenc C)\n"
"add_library(opusenc STATIC src/ogg_packer.c src/opus_header.c src/opusenc.c src/picture.c src/resample.c src/unicode_support.c)\n"
"target_compile_definitions(opusenc PRIVATE HAVE_CONFIG_H OUTSIDE_SPEEX RANDOM_PREFIX=opusenc_prefix)\n"
"target_include_directories(opusenc PRIVATE \"\${CMAKE_CURRENT_SOURCE_DIR}\" \"\${CMAKE_CURRENT_SOURCE_DIR}/include\" \"\${CMAKE_CURRENT_SOURCE_DIR}/src\"${_dep_incs})\n"
"install(TARGETS opusenc ARCHIVE DESTINATION lib)\n"
"install(FILES include/opusenc.h DESTINATION include/opus)\n"
)

_bd_cmake_build("${SRC}")
