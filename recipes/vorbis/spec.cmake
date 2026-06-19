set(DEP_VERSION 1.3.7)

set(DEP_SOURCE_URL    "https://github.com/xiph/vorbis/releases/download/v1.3.7/libvorbis-1.3.7.tar.gz")
set(DEP_SOURCE_SHA256 "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab")

set(DEP_DEPENDS ogg)

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
)

set(DEP_LICENSE_FILES COPYING)
