set(DEP_VERSION 0.15.2c)

# Audacity's fork: adds a CMake build and ID3v2.3 rendering (ID3_TAG_OPTION_ID3V2_3)
set(DEP_SOURCE_URL    "https://github.com/audacity/libid3tag/archive/refs/tags/0.15.2c.tar.gz")
set(DEP_SOURCE_SHA256 "bef04cb487b7bdd69ee854f445ff994c197a6f7aeb5579258079bafe7d71b7df")

set(DEP_DEPENDS zlib)

set(DEP_CMAKE_ARGS -DBUILD_SHARED=OFF)

set(DEP_LICENSE_FILES COPYING COPYRIGHT CREDITS)
