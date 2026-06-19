set(DEP_VERSION 5.7.0)

set(DEP_SOURCE_URL    "https://github.com/dbry/WavPack/releases/download/5.7.0/wavpack-5.7.0.tar.xz")
set(DEP_SOURCE_SHA256 "e81510fd9ec5f309f58d5de83e9af6c95e267a13753d7e0bbfe7b91273a88bee")

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DWAVPACK_BUILD_PROGRAMS=OFF
    -DBUILD_TESTING=OFF
)
set(DEP_PATCHES patch/0001-asm-language-detection.patch)

set(DEP_LICENSE_FILES COPYING)
