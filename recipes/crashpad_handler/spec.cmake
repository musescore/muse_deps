set(DEP_VERSION ae5b334b23ec1331b13086beb73bde8168f0b386)

set(DEP_SOURCE_URL    "https://github.com/chromium/crashpad/archive/ae5b334b23ec1331b13086beb73bde8168f0b386.tar.gz")
set(DEP_SOURCE_SHA256 "1182fc6c9b7244598416366b40522298a3ff855b0168ab79252cf04973c02f0c")

set(DEP_SOURCES
    "mini_chromium|tarball|https://github.com/chromium/mini_chromium/archive/e5169551c51f3a52eee36b3b03f219cefe380237.tar.gz|e35ed2d041232fde0bbfbc1517431c3902890526c696d64ee062dc370baf2b9d"
    # Needed only for Windows, where standalone crashpad embeds zlib
    "zlib|git|https://chromium.googlesource.com/chromium/src/third_party/zlib|fef58692c1d7bec94c4ed3d030a45a1832a9615d"
    "gn-linux-amd64|tarball|https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/git_revision:5e19d2fb166fbd4f6f32147fbb2f497091a54ad8|a95c29544e581b56c1d3f1920637a9f518989b3b744d6b2234fe8de634acddf1"
    "gn-linux-arm64|tarball|https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-arm64/+/git_revision:5e19d2fb166fbd4f6f32147fbb2f497091a54ad8|c9ac3a6530362fd493a303b2f3e91eb868e717b9eab345dbda2cf1d8ce4aa815"
    "gn-mac-amd64|tarball|https://chrome-infra-packages.appspot.com/dl/gn/gn/mac-amd64/+/git_revision:5e19d2fb166fbd4f6f32147fbb2f497091a54ad8|3fbdf5e6681250201c145014839844d82b561c59a0f33f1d9fd2cf3b04de5696"
    "gn-mac-arm64|tarball|https://chrome-infra-packages.appspot.com/dl/gn/gn/mac-arm64/+/git_revision:5e19d2fb166fbd4f6f32147fbb2f497091a54ad8|bd485a3494c85341a59241e8307cdcbc1d244b58478ad331ede96449beae17ca"
    "gn-windows-amd64|tarball|https://chrome-infra-packages.appspot.com/dl/gn/gn/windows-amd64/+/git_revision:5e19d2fb166fbd4f6f32147fbb2f497091a54ad8|78ebf5d11d97298d8dce53090c18ad7d3463d8e52698ce6691d9fdd9b7774f07"
    # clang: mini_chromium builds at -std=c++23
    # upstream clang is prebuilt and is around 50MB
    "clang-linux-amd64|tarball|https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/clang-llvmorg-23-init-18172-g7389aa2e-2.tar.xz|164dfde4d4de8a7319d95815021942ac030415323b1244408f96c21677b349df"
    "clang-windows-amd64|tarball|https://commondatastorage.googleapis.com/chromium-browser-clang/Win/clang-llvmorg-23-init-18172-g7389aa2e-2.tar.xz|2f9d554551fedfebbee6eafb427ccb61c18a87298e9a1f8fbd4185c084c700b7"
    # clang for Linux ARM64 is not distributed by Chromium, and this guy is 1GB ¯\_(-_-)_/¯
    # it worth to investigate using system installed later
    "clang-linux-arm64|tarball|https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-aarch64-linux-gnu.tar.xz|dcaa1bebbfbb86953fdfbdc7f938800229f75ad26c5c9375ef242edad737d999"
)

set(DEP_PLATFORMS linux-x86_64 linux-aarch64 macos-aarch64 macos-x86_64 macos-universal windows-x86_64 windows-aarch64)

set(DEP_LICENSE_FILES LICENSE)
