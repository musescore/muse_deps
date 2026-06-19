set(DEP_VERSION 1.3.1)

set(DEP_SOURCE_URL    "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz")
set(DEP_SOURCE_SHA256 "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23")

set(DEP_CMAKE_ARGS -DBUILD_SHARED_LIBS=ON -DZLIB_BUILD_EXAMPLES=OFF)

set(DEP_LICENSE_FILES LICENSE)
