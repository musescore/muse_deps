set(DEP_VERSION 3.12.0)

set(DEP_SOURCE_URL    "https://github.com/nlohmann/json/releases/download/v3.12.0/json.tar.xz")
set(DEP_SOURCE_SHA256 "42f6e95cad6ec532fd372391373363b62a14af6d771056dbfc86160e6dfff7aa")

set(DEP_CMAKE_ARGS
    -DJSON_BuildTests=OFF
)

set(DEP_LICENSE_FILES LICENSE.MIT)
