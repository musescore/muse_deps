# last release is from 2015, use master's sha instead
set(DEP_VERSION 111c9be)

set(DEP_SOURCES
    "picojson|tarball|https://github.com/kazuho/picojson/archive/111c9be5188f7350c2eac9ddaedd8cca3d7bf394.tar.gz|671f89832a17e9e71398f80c0a326afa2ebe81f4c26d5a9992e1fcd0888ae151"
)

set(DEP_PATCHES patch/0001-deterministic-number-serialization.patch)
