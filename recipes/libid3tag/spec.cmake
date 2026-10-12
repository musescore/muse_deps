set(DEP_VERSION 0.15.2b)

# Audacity's fork: adds a CMake build and ID3v2.3 rendering (ID3_TAG_OPTION_ID3V2_3)
set(DEP_SOURCE_URL    "https://github.com/audacity/libid3tag/archive/refs/tags/0.15.2b.tar.gz")
set(DEP_SOURCE_SHA256 "1db8b1627b664e32094621efc1431a3471d760cc88800021e347302398ef5c6c")

set(DEP_DEPENDS zlib)

set(DEP_CMAKE_ARGS -DBUILD_SHARED=OFF)

set(DEP_LICENSE_FILES COPYING COPYRIGHT CREDITS)
