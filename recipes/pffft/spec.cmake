# Upstream has no releases, using sha
set(DEP_VERSION 0979688)

set(DEP_SOURCES
    "pffft|tarball|https://bitbucket.org/jpommier/pffft/get/09796885cd5b.tar.gz|fdc80563de8c31d6380886bc1ba0ffb897abde58611707ac94eb8ed8ab850cbb"
)

# diff between upstream and audacity version
set(DEP_PATCHES patch/0001-audacity-fork.patch)
