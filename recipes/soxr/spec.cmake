set(DEP_VERSION 0.1.3)

set(DEP_SOURCE_URL    "https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz")
set(DEP_SOURCE_SHA256 "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889")

set(DEP_PATCHES patch/0001-audacity-fixes.patch)

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_TESTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DWITH_OPENMP=OFF
    -DWITH_LSR_BINDINGS=OFF
    -DWITH_DEV_TRACE=OFF
    -DWITH_PFFFT=ON
    # no AVX instructions in distribution builds
    -DWITH_CR64S=OFF
)
set(DEP_CMAKE_ARGS_WINDOWS
    -DBUILD_SHARED_LIBS=OFF
)

set(DEP_LICENSE_FILES LICENCE COPYING.LGPL)
