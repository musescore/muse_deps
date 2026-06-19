set(DEP_VERSION 0.74.0)

set(DEP_SOURCE_URL    "https://github.com/uncrustify/uncrustify/archive/refs/tags/uncrustify-0.74.0.tar.gz")
set(DEP_SOURCE_SHA256 "b7d24e256e7f919aa96289ac8167ac98340df7faa2d34b60d2242dc54700caaa")

# fixes build with cmake4
set(DEP_CMAKE_ARGS -DCMAKE_POLICY_VERSION_MINIMUM=3.5)
