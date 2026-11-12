set(DEP_TARGET Opus::opus)
set(DEP_LIBS opus)
set(DEP_INCLUDE_SUBDIRS opus)
set(DEP_SYSTEM_HEADER opus/opus.h)

# Supported on wasm (built by build_platform.cmake for OS=wasm)
set(DEP_WASM ON)
