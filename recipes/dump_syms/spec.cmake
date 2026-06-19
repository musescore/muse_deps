set(DEP_VERSION 2026.06.12)

set(DEP_SOURCE_URL    "https://github.com/google/breakpad/archive/5359c2336d74399e01c420dcc8034bf50cbe44bc.tar.gz")
set(DEP_SOURCE_SHA256 "1915bc0ae29e64b7a10a095d40697ef22ead23d0dd808e9ad493bdd1f38d5b7b")

set(DEP_PATCHES_LINUX   patch/0001-memory-allocator-needs-cstddef.patch)
set(DEP_PATCHES_WINDOWS patch/0002-vcxproj-release-links-dbghelp.patch)

# TODO: no WoA support yet / not investigated
set(DEP_PLATFORMS linux-x86_64 linux-aarch64 macos-aarch64 macos-x86_64 macos-universal windows-x86_64)

set(DEP_LICENSE_FILES LICENSE)
