Dependency engine, metadata, source recipes, and the prebuilt archive lock for
apps that include this repo as a submodule.

## Repository Layout

```
buildtools/
  manifest.cmake             consumer-facing API: require_dep(), require_tool(), ...
  resolve.cmake              resolver: prebuilt / rebuild / system / source delivery
  build_dependency.cmake     builder: fetch -> verify -> patch -> build -> install
  build_platform.cmake       producer: build and package one os/arch set
  mirror_sources.cmake       producer: stage every pinned source archive
prebuilt.lock                immutable prebuilt archive index
recipes/
  <name>/
    meta.cmake               dep metadata: targets, libs, kind, hooks
    spec.cmake               version, source pins, build args, deps, patches, licenses
    build.cmake              optional custom build script
    patch/*.patch            optional patches
```

## Consumer Manifest

An app includes `buildtools/manifest.cmake`, then its own manifest of calls:

```cmake
require_dep(ogg)
require_dep(openssl SYSTEM)
require_dep(portaudio REBUILD)
require_tool(yasm)
require_source_dep(lv2sdk)
```

The manifest names deps and the preferred mode. Each version
lives in `recipes/<name>/spec.cmake` as `DEP_VERSION`. The app pins the whole set by
pinning this submodule's commit. You can't mix and match different versions.

Order matters: a dep must appear after everything it links (e.g. `opusfile`
after `opus` and `ogg`). `DEP_DEPENDS` passes prefixes into a recipe build but
does not order the manifest.

### Modes

- `require_dep(<name>)`: prebuilt (default). Match a `prebuilt.lock` line,
  verify its SHA-256, extract into the local prefix; build from source if no
  usable prebuilt exists.
- `require_dep(<name> REBUILD)`: always build from source.
- `require_dep(<name> SYSTEM)`: use host headers and libraries.
- `require_tool(<name>)`: resolve a host tool and prepend its `bin/` to `PATH`.
- `require_source_dep(<name>)`: fetch pinned source trees and expose
  `<name>_SOURCE_DIR` for in-tree compilation. For deps not consumed as
  installed binaries: header-only, vendored, or app-integrated source.

### Overrides

Override the manifest mode from the CMake command line:

```sh
cmake -DEXTDEPS_OVERRIDE_ALL=REBUILD ...
cmake -DEXTDEPS_OVERRIDE_ALL=SYSTEM ...
cmake -DEXTDEPS_OVERRIDE_OGG=PREBUILT ...
cmake -DEXTDEPS_OVERRIDE_PORTAUDIO=REBUILD ...
```

Values are `PREBUILT`, `REBUILD`, `SYSTEM`. A per-dep override beats
`EXTDEPS_OVERRIDE_ALL`; a global `=SYSTEM` does not force source-delivery deps to
system mode unless the dep declares a system path. `EXTDEPS_OVERRIDE_ALL` may
also be an environment variable; per-dep overrides are CMake variables.

## Dependency Metadata

One metadata file per dependency:

```cmake
# recipes/ogg/meta.cmake
set(DEP_TARGET Ogg::ogg)
set(DEP_LIBS ogg)
set(DEP_SYSTEM_HEADER ogg/ogg.h)
```

Keys:

- `DEP_KIND`: `library` (default), `source`, or `tool`.
- `DEP_TARGET`: imported target for a single-target library.
- `DEP_LIBS`: base library names on Unix, without `lib` prefix or extension.
- `DEP_LIBS_WINDOWS`: Windows base names when they differ.
- `DEP_TARGETS`: multiple targets from one prefix, as `"Target::name|lib1 lib2"`.
- `DEP_INCLUDE_SUBDIRS`: extra include dirs below `<prefix>/include`.
- `DEP_SYSTEM_HEADER`: header used to validate `SYSTEM` mode.
- `DEP_STATIC`: static everywhere; nothing bundled.
- `DEP_STATIC_WINDOWS`: static on Windows only; nothing bundled there.
- `DEP_LINK_DEPS`: extra interface link dependencies on the primary target.
- `DEP_SOURCE_SYSTEM`: source deps only; lets a blanket `=SYSTEM` bind a system
  package.

Optional hooks a `meta.cmake` may define:

- `<name>_resolve_override(mode local_path os arch version [config])`: replaces the
  generic resolution entirely (e.g. `wxwidgets`, `openssl`, `libcurl`). The 6th
  `config` argument is passed too (`wxwidgets` uses it; the others ignore it).
- `<name>_post_resolve(mode local_path os arch version)`: runs after resolution for
  consumer-side integration, usually `add_subdirectory()` or setting variables for
  existing `find_package()` users.
- `<name>_add_to_build()`: called by the **consuming app's** CMake (not the engine) to
  pull a source dep into its build, e.g. `rapidjson_add_to_build()`. Used by
  `crashpad_client`, `googletest`, `kddockwidgets`, `loop-tempo-estimator`,
  `rapidjson`, and `tft`.

## Recipe Spec

One recipe per buildable dependency:

```cmake
# recipes/ogg/spec.cmake
set(DEP_VERSION 1.3.5)
set(DEP_SOURCE_URL    "https://example.invalid/libogg-1.3.5.tar.gz")
set(DEP_SOURCE_SHA256 "<sha256>")

set(DEP_CMAKE_ARGS
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_TESTING=OFF
)

set(DEP_LICENSE_FILES COPYING)
```

Keys:

- `DEP_VERSION`: selected version; the only place it is defined and read from.
- `DEP_SOURCE_URL` / `DEP_SOURCE_SHA256`: upstream archive and its SHA-256.
- `DEP_CMAKE_ARGS`: extra arguments for the configure step.
- `DEP_CMAKE_SOURCE_SUBDIR`: subdirectory holding the upstream CMake project.
- `DEP_PATCHES`: patches under the recipe directory.
- `DEP_DEPENDS`: dependency names whose prefixes are needed to build; versions
  come from those deps' metadata.
- `DEP_SOURCES`: extra pinned source trees, in source-delivery format.
- `DEP_LICENSE_FILES`: files copied from the source into `<prefix>/licenses`.
- `DEP_PLATFORMS`: optional filter matching `<os>` or `<os>-<arch>`.

Per-OS keys append to the common ones:

```cmake
set(DEP_CMAKE_ARGS_WINDOWS -DFOO=ON)
set(DEP_PATCHES_MACOS patch/fix-macos.patch)
```

When upstream has no usable CMake build, add `recipes/<name>/build.cmake`. It
runs after fetch and patch and can use builder-provided variables: `SRC`
(patched source), `BUILD`, `INSTALL`, `BD_OS`/`BD_ARCH`, `BD_DEPENDS_PREFIXES`
(prefixes for `DEP_DEPENDS`), and `_bd_cmake_build(<srcdir>)` (standard
configure/build/install helper).

## Source-Delivery Recipes

Source-delivery deps set `DEP_KIND source` and list source entries in the
recipe. Buildable recipes can also use `DEP_SOURCES` for extra pins staged by a
custom `build.cmake`.

```cmake
set(DEP_SOURCES
    "lv2|tarball|https://example.invalid/lv2.tar.gz|<sha256>"
    "some-lib|git|https://example.invalid/some-lib.git|<commit>"
)
```

Entry formats:

- `subdir|tarball|url|sha256`
- `subdir|git|repo|commit`
- `subdir|local|/path/to/subdir`: local iteration only; do not commit.

Patches apply inside the source subtree. With more than one subtree, qualify
each as `subdir|patch/file.patch`.

## Binary Tools

Some `DEP_KIND tool` deps are official upstream binaries, mirrored into an
immutable release and pinned in the recipe rather than built:

```cmake
set(DEP_BINARY_URL_ROOT "https://example.invalid/releases/download/tools")
set(DEP_BINARY_NAME sentry-cli)
set(DEP_BINARY_FILE_linux-x86_64 "sentry-cli-Linux-x86_64")
set(DEP_BINARY_SHA256_linux-x86_64 "<sha256>")
```

With `DEP_BINARY_URL_ROOT` set, both default and `REBUILD` fetch the pinned
binary; `SYSTEM` still searches `PATH`.

## Adding A Dependency

1. Create `recipes/<name>/meta.cmake` with target/library metadata, or set
   `DEP_KIND source`/`tool`.
2. Create `recipes/<name>/spec.cmake`, setting `DEP_VERSION` and pinning every
   source with SHA-256.
3. Add patches only when needed, under `recipes/<name>/patch/`.
4. Add `DEP_LICENSE_FILES`.
5. Add the dep to the consumer manifest after anything it depends on.
6. Configure once in the default mode; with no prebuilt yet, it builds from source.
7. Run a producer build and commit the updated `prebuilt.lock`.

## Bumping A Dependency

1. In `recipes/<name>/spec.cmake`, update `DEP_VERSION`, the source URL, and
   the SHA-256.
3. Revisit patches and CMake args; drop what upstream no longer needs.
4. Build locally in `REBUILD` mode.
5. Run the producer workflow and commit the new `prebuilt.lock`.
6. Bump the submodule pin in each consumer app.

## Build And Resolve Flow

Prebuilt path (default mode):

1. `require_dep(name)` reads the metadata, then for non-system modes includes the
   recipe `spec.cmake`, which defines `DEP_VERSION`.
2. `resolve.cmake` searches `prebuilt.lock` for `name version os arch`. The
   archive name carries the current recipe signature, so a stale lock cannot
   satisfy a changed recipe.
3. The archive is downloaded (or read from cache), SHA-verified, and extracted.
4. The prefix resolves into include dirs, link libraries, runtime bundle
   libraries, and imported targets.
5. Later, `extdeps_install_consumed()` installs runtime libraries and licenses
   for every consumed dep.

Default mode falls back to the source build if prebuilt resolution fails;
`REBUILD` starts there directly.

Source build (`build_dep()`):

1. Clears ambient `DEP_*` variables and includes `spec.cmake`.
2. Computes a recipe signature from OS, arch, engine revision, and every file
   under the recipe directory; skips the build if `<install>/.build_stamp`
   matches.
3. Fetches the archive into the persistent cache and verifies SHA-256.
4. Extracts into a clean work directory; applies common and OS-specific patches.
5. Configures, builds, and installs with CMake, or runs `build.cmake`.
6. Copies licenses, fixes packaging (Linux SONAME links, macOS install names),
   and writes the new build stamp.

## Prebuilt Archives

`prebuilt.lock` maps a dependency and platform to an immutable release asset:

```
<name> <version> <os> <arch> <archive> <sha256> <release>
```

Archives are named `<name>-<version>-<os>-<arch>-<sig12>.7z`, where `sig12` is
the first 12 hex chars of the recipe signature. Any recipe change changes the
signature and thus the name, so consumers never silently reuse an old prebuilt.

The archive cache lives under `<EXTDEPS_CACHE>/prebuilt/`. Override the release
download root with:

```sh
export EXTDEPS_PREBUILT_URL=https://mirror.example.invalid/releases/download
```

Use a `file://` URL for an air-gapped mirror.

## Source Cache And Mirrors

Source downloads live under `<EXTDEPS_CACHE>/downloads/<name>/`. Tarballs are
cached by upstream basename and SHA-verified; `DEP_SOURCES` git entries are
cached as `<subdir>.git` and checked out to their pinned commit. Every cached
source is re-verified before use, and a SHA mismatch is fatal.

Cache selection:

1. `-DEXTDEPS_CACHE=<dir>` or environment `EXTDEPS_CACHE`.
2. `$XDG_CACHE_HOME/extdeps`.
3. `$HOME/.cache/extdeps`.

When upstream fetch fails, the builder uses a mirror, selected from
`EXTDEPS_MIRROR` or the source assets on the release referenced by
`prebuilt.lock`. Generate those assets with:

```sh
cmake -P buildtools/mirror_sources.cmake
```

They are named `<name>-<version>-src.<ext>` and `<name>-<subdir>-src.<ext>`.

## Offline Preparation

Pre-fill the source cache before an offline or distro build:

```sh
cmake -DEXTDEPS_CACHE=/path/to/cache -P buildscripts/cmake/PrepareDepsSources.cmake
```

This script lives in the consumer repo because it reads the consumer manifests,
running them with representative platform options so the cache holds the union of
platform-gated sources. Fetching is idempotent and SHA-checked. For a fully
offline prebuilt build, also mirror the prebuilt release assets and point
`EXTDEPS_PREBUILT_URL` at the mirror.

## Producing Prebuilts

CI dispatches the prebuilt workflow; each matrix job builds one platform:

```sh
cmake -DOS=macos -DARCH=universal -P buildtools/build_platform.cmake
cmake -DOS=linux -DARCH=x86_64 -P buildtools/build_platform.cmake
cmake -DOS=windows -DARCH=x86_64 -P buildtools/build_platform.cmake
```

OS values: `macos`, `linux`, `windows`. Arch values: `x86_64`, `aarch64`,
`universal` where applicable.

`build_platform.cmake` finds every recipe with `DEP_SOURCE_URL` (skipping
source-delivery deps), builds tools first and adds them to `PATH`, builds
libraries in `DEP_DEPENDS` order, packages each prefix as one `.7z`, verifies
CMake can extract it, and writes `.build/platform/out/prebuilt-<os>-<arch>.lock`.

The workflow publishes all archives into a new immutable release, attaches the
mirrored sources, updates `prebuilt.lock`, and commits it. Consumers then only
bump the submodule pin.

## Packaging In Consumers

The resolver records consumed deps in the `EXTDEPS_CONSUMED` global property,
each with `<name>_INCLUDE_DIRS`, `<name>_LIBRARIES`, `<name>_INSTALL_LIBRARIES`,
and `<name>_PREFIX`.

Link imported targets where possible. At install time:

```cmake
extdeps_install_consumed(MACOS_BUNDLE audacity.app)
```

This installs runtime libraries and license directories for all consumed deps
using platform-appropriate destinations.

## Troubleshooting

- `lock entry ... doesn't match the local recipe`: the recipe changed but
  `prebuilt.lock` still points at an old archive. Build from source or publish
  new prebuilts.
- `no usable prebuilt ... building from source`: no matching lock line, missing
  archive, failed SHA check, or signature mismatch. Expected while developing a
  recipe.
- `resolved lib missing`: `DEP_LIBS`, `DEP_LIBS_WINDOWS`, `DEP_STATIC`, or the
  install layout does not match the files the build produced.
- `system header ... not found`: `SYSTEM` mode requested but the host package is
  missing or `DEP_SYSTEM_HEADER` is wrong.
- Repeated downloads: ensure the same `EXTDEPS_CACHE` is visible to configure,
  build, producer, and offline-prep commands.
- `Pathname can't be converted from UTF-8 to current locale`: set
  `LC_ALL=C.UTF-8`.
