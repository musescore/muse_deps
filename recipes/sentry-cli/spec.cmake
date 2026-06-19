set(DEP_VERSION 3.5.0)

# manually mirrored
set(DEP_BINARY_URL_ROOT "https://github.com/musescore/muse_deps/releases/download/mirror-sentry-cli-3.5.0")
set(DEP_BINARY_NAME sentry-cli)

set(DEP_BINARY_FILE_windows-x86_64   "sentry-cli-Windows-x86_64.exe")
set(DEP_BINARY_SHA256_windows-x86_64 "7b7db2a8650644a77beef525e1464db3dad0b5313f6589f2991d39af7eda78aa")

# Universal build for all macos versions, TODO: auto resolve to universal in-engine
set(DEP_BINARY_FILE_macos-aarch64    "sentry-cli-Darwin-universal")
set(DEP_BINARY_SHA256_macos-aarch64  "46a439a75a8dda4719dbfded7b09388dc4b2aa7e1976e28102dfeb14401b8587")
set(DEP_BINARY_FILE_macos-x86_64     "sentry-cli-Darwin-universal")
set(DEP_BINARY_SHA256_macos-x86_64   "46a439a75a8dda4719dbfded7b09388dc4b2aa7e1976e28102dfeb14401b8587")
set(DEP_BINARY_FILE_macos-universal  "sentry-cli-Darwin-universal")
set(DEP_BINARY_SHA256_macos-universal "46a439a75a8dda4719dbfded7b09388dc4b2aa7e1976e28102dfeb14401b8587")

set(DEP_BINARY_FILE_linux-x86_64     "sentry-cli-Linux-x86_64")
set(DEP_BINARY_SHA256_linux-x86_64   "522d469086996996322052b8f46bb679f010c53d884521023e79aa7680627104")
set(DEP_BINARY_FILE_linux-aarch64    "sentry-cli-Linux-aarch64")
set(DEP_BINARY_SHA256_linux-aarch64  "94c758dee171ba4f248c0514806c1a03331a59a59582874500f17555b922b257")
