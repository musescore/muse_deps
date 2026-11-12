# Emscripten builds the SHARED target as a static archive, which collides with the static libz.a
set(DEP_PATCHES_WASM patch/wasm/0001-cmake-emscripten-static-only-libz.patch)
