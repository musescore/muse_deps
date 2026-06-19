set(DEP_VERSION 2.0.3)

set(DEP_SOURCE_URL    "https://github.com/mstorsjo/fdk-aac/archive/refs/tags/v2.0.3.tar.gz")
set(DEP_SOURCE_SHA256 "e25671cd96b10bad896aa42ab91a695a9e573395262baed4e4a2ff178d6a3a78")

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_PROGRAMS=OFF
)

set(DEP_LICENSE_FILES NOTICE)
