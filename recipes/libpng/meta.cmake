set(DEP_TARGET png::png)
set(DEP_LIBS png16)
set(DEP_LIBS_WINDOWS libpng16)
set(DEP_SYSTEM_HEADER png.h)

# Supported on wasm (built by build_platform.cmake for OS=wasm)
set(DEP_WASM ON)
