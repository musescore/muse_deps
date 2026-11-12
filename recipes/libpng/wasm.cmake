# Wasm has no shared libraries, libpng has its own switches for them
set(DEP_CMAKE_ARGS_WASM
    -DPNG_SHARED=OFF
    -DPNG_STATIC=ON
)
