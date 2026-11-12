set(DEP_TARGET Vorbis::vorbis)
set(DEP_LIBS vorbis vorbisenc vorbisfile)
set(DEP_SYSTEM_HEADER vorbis/codec.h)

# Supported on wasm (built by build_platform.cmake for OS=wasm)
set(DEP_WASM ON)
