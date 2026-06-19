set(DEP_VERSION 12.3.0)

set(DEP_SOURCE_URL    "https://github.com/harfbuzz/harfbuzz/releases/download/12.3.0/harfbuzz-12.3.0.tar.xz")
set(DEP_SOURCE_SHA256 "8660ebd3c27d9407fc8433b5d172bafba5f0317cb0bb4339f28e5370c93d42b7")

set(DEP_DEPENDS freetype)

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DHB_HAVE_FREETYPE=ON
    -DHB_BUILD_SUBSET=OFF
)

set(DEP_LICENSE_FILES COPYING)
