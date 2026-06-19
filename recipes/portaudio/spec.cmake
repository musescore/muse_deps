set(DEP_VERSION 19.7.0)

set(DEP_SOURCE_URL    "https://github.com/PortAudio/portaudio/archive/refs/tags/v19.7.0.tar.gz")
set(DEP_SOURCE_SHA256 "5af29ba58bbdbb7bbcefaaecc77ec8fc413f0db6f4c4e286c40c3e1b83174fa0")

set(DEP_CMAKE_ARGS
    -DPA_BUILD_SHARED=ON
    -DPA_BUILD_STATIC=OFF
)

set(DEP_PATCHES_WINDOWS patch/0001-windows-loopback-and-mixer-exports.patch)

set(DEP_LICENSE_FILES LICENSE.txt)
