# SVN r331 is the exact revision Audacity last synced to (Jan 2021)
set(DEP_VERSION r331)

# Sourceforge generates the snapshot on demand and the archive live for 24 hours,
# so 404 are expected the next day after the initial sync
set(DEP_SOURCES
    "nyquist|tarball|https://sourceforge.net/code-snapshots/svn/n/ny/nyquist/code/nyquist-code-r331-trunk.zip|94bb10ec5189e07a0dc15d8e382aaa468cb0e33dce893633432931fea0113885"
)

# Replayed Audacity history, each patch contains ref of audacity commit
set(DEP_PATCHES
    "patch/0001-132173badf-cppcheck-fix-2-reports.patch"
    "patch/0002-016919a53b-bug1223-correction-fix-new-potential-cra.patch"
    "patch/0003-ecc2138c5c-comment-out-extra-tokens-at-end-of-endif.patch"
    "patch/0004-e6d069787b-fix-mistake-in-commit-a1dc830-and-add-a-.patch"
    "patch/0005-6b2a219e26-changes-to-make-xlisp-h-usable-in-c-code.patch"
    "patch/0006-2fec472ba2-lib-src-libnyquist-eliminate-register-lo.patch"
    "patch/0007-a3afdf80d0-lib-src-libnyquist-fix-warning-about-alw.patch"
    "patch/0008-5955dbc752-possible-fix-for-bug-590.patch"
    "patch/0009-5aa70545d5-use-casts-with-function-pointers-to-quie.patch"
    "patch/0010-5ba6072bbb-workaround-for-bug-2264.patch"
    "patch/0011-3dfc9d6dec-fix-build-on-cygwin-557.patch"
    "patch/0012-6181f406fd-fix-error-build-with-mingw-and-cygwin-55.patch"
    "patch/0013-29d35e46e9-misc-changes-to-get-new-nyquist-to-build.patch"
    "patch/0014-14b767b9eb-fix-bad-line-break-in-error-directive.patch"
    "patch/0015-ff60f598f3-fixes-2-bugs-in-nyquist-1-bug-2706-proba.patch"
    "patch/0016-0a085daa92-fix-build.patch"
    "patch/0017-91a557d838-this-fixes-a-problem-with-nyquist-s-trig.patch"
    "patch/0018-c216f46435-fix-bug-379.patch"
    "patch/0019-72d72d120d-issue-1642-fix-by-rdb-1672.patch"
    "patch/0020-91d64c4ed8-issue2372-nyquist-can-hang.patch"
    "patch/0021-91850989a0-adds-a-set-of-patches-to-better-support-.patch"
    "patch/0022-f5ac7bb104-typo-in-alpassvc-alg.patch"
    "patch/0023-3c42a58fba-typos-in-alpassvv-c.patch"
    "patch/0024-357aac03bc-typos-in-alpassvc-c.patch"
    "patch/0025-56807d780b-typo-in-alpassvv-alg.patch"
    "patch/0026-377e592e84-use-cstdint-instead-of-manually-defining.patch"
    "patch/0027-95a2dd95a8-add-a-set-of-patches-to-better-support-o.patch"
    "patch/0028-c4e391cfc4-move-debug-defines-after-including-stand.patch"
    "patch/0029-4191cfb837-freebsd-compilation-fixes.patch"
    "patch/0030-d881c57712-rename-swap-functions-to-not-conflict-wi.patch"
)
