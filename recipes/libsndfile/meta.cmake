set(DEP_TARGET SndFile::sndfile)
set(DEP_LIBS sndfile)
set(DEP_SYSTEM_HEADER sndfile.h)

# Supported on wasm (built by build_platform.cmake for OS=wasm)
set(DEP_WASM ON)
