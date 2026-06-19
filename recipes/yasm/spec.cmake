set(DEP_VERSION 1.3.0)

set(DEP_SOURCE_URL    "https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz")
set(DEP_SOURCE_SHA256 "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f")

set(DEP_CMAKE_ARGS -DBUILD_SHARED_LIBS=OFF)

set(DEP_PATCHES patch/0001-cmake-updates.patch)

# windows x86 only
set(DEP_PLATFORMS windows-x86_64)

set(DEP_LICENSE_FILES COPYING)
