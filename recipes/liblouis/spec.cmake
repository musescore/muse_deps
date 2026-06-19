set(DEP_VERSION 3.24.0)

set(DEP_SOURCES
    "liblouis|tarball|https://github.com/liblouis/liblouis/releases/download/v3.24.0/liblouis-3.24.0.tar.gz|02360230cf5c1fe7dcec59c41a3e74bc283548b0de637963760fa8fad9cd0c39"
)

# MuseScore's MSVC build fix: a fixed buffer instead of a C99 VLA, and disable
# the dllexport API decoration (liblouis is linked statically here).
set(DEP_PATCHES patch/0001-fix-windows-build.patch)
