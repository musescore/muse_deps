set(DEP_VERSION 3.2.6)

# Audacity only needs wxBase; the old 3.1.3-audacity fork was an AU3 requirement
# and is no longer needed.
# The official release tarball bundles 3rdparty sources (zlib/expat/regex), so
# builtin libs work with no submodules, no patches, no system/external deps.

set(DEP_SOURCE_URL    "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.6/wxWidgets-3.2.6.tar.bz2")
set(DEP_SOURCE_SHA256 "939e5b77ddc5b6092d1d7d29491fe67010a2433cf9b9c0d841ee4d04acb9dce7")

set(DEP_CMAKE_ARGS
    -DwxBUILD_SHARED=ON
    -DwxBUILD_SAMPLES=OFF
    -DwxBUILD_TESTS=OFF
    -DwxBUILD_DEMOS=OFF
    -DwxBUILD_INSTALL=ON
    -DwxBUILD_COMPATIBILITY=3.0
    -DwxBUILD_PRECOMP=OFF
    -DwxUSE_WEBREQUEST=OFF
    -DwxUSE_ZLIB=builtin
    -DwxUSE_EXPAT=builtin
    -DwxUSE_REGEX=builtin
    -DwxUSE_LIBLZMA=OFF
    -DwxUSE_SECRETSTORE=OFF
)

# wx's macOS "base" sources require the cocoa port, which only a GUI build
# enables — base-only does NOT compile on macOS (confirmed with a clean upstream
# build). So build GUI on macOS (we still consume only libwx_baseu). Linux and
# Windows build base-only (no cocoa, and we don't want a GTK dependency).
set(DEP_CMAKE_ARGS_MACOS   -DwxUSE_GUI=ON)
set(DEP_CMAKE_ARGS_LINUX   -DwxUSE_GUI=OFF)
set(DEP_CMAKE_ARGS_WINDOWS -DwxUSE_GUI=OFF)

# macOS-only: wx's bundled zlib/png misdetect modern macOS as classic Mac OS
# (TARGET_OS_MAC) — zlib defines `fdopen NULL`, png includes classic <fp.h>.
set(DEP_PATCHES_MACOS
    patch/0001-zlib-no-classic-mac-fdopen.patch
    patch/0002-png-no-classic-mac-fp.patch
)

set(DEP_LICENSE_FILES "docs/licence.txt")
