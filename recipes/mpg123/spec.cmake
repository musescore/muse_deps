set(DEP_VERSION 1.32.10)

set(DEP_SOURCE_URL    "https://www.mpg123.de/download/mpg123-1.32.10.tar.bz2")
set(DEP_SOURCE_SHA256 "87b2c17fe0c979d3ef38eeceff6362b35b28ac8589fbf1854b5be75c9ab6557c")

set(DEP_CMAKE_SOURCE_SUBDIR ports/cmake)
set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_LIBOUT123=OFF
    -DBUILD_PROGRAMS=OFF
)

set(DEP_PATCHES patch/0001-cmake-arm64-has-fpu.patch)

# WoA enable asm optimizations, and convert assembly to msvc syntax
set(DEP_PATCHES_WINDOWS patch/0002-msvc-arm64-neon-gas-preprocessor.patch)
set(DEP_CMAKE_ARGS_WINDOWS -DGAS_PREPROCESSOR=@RECIPE_DIR@/gas-preprocessor.pl)

set(DEP_LICENSE_FILES COPYING)
