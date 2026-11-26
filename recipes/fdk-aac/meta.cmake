set(DEP_TARGET fdk-aac::fdk-aac)
set(DEP_LIBS fdk-aac)
set(DEP_INCLUDE_SUBDIRS fdk-aac)
set(DEP_SYSTEM_HEADER fdk-aac/aacenc_lib.h)

# Supported on wasm (built by build_platform.cmake for OS=wasm), static there
set(DEP_WASM ON)
