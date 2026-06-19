set(DEP_VERSION 2.1)

set(DEP_SOURCES
    "mnxdom|tarball|https://github.com/rpatters1/mnxdom/archive/e7c947bf768caccf315426dcae0dfac02caf738b.tar.gz|4afeaa116fdf98518534e554886b94546406d144e240513347185c76a50621bb"
)

# mnxdom links the bare `nlohmann_json_schema_validator` in both modes, but the
# USE_SYSTEM path's find_package only provides the namespaced ::validator target
# (no include/lib via the bare name). Link the ::validator alias, which exists in
# both fetch and system modes.
set(DEP_PATCHES patch/0001-link-namespaced-json-schema-validator.patch)
