set(DEP_VERSION 3.7.12_build_20)

# VST3 SDK is split across the three subrepos consumed by the host build.

set(DEP_SOURCES
    "base|tarball|https://github.com/steinbergmedia/vst3_base/archive/f0998e7b8424b32ba275cf4218aa56beef29821c.tar.gz|5460f4d09bc65fbbc23315c6900dda33eb96a7a3f1720d1d7387592a69bc24ef"
    "pluginterfaces|tarball|https://github.com/steinbergmedia/vst3_pluginterfaces/archive/151ecde4d6ee1c457dcce848342b162461944fe6.tar.gz|e7bb5dc1701c2c136d0902d458533ef0fa9cf720c088f176659d017780ffda3a"
    "public.sdk|tarball|https://github.com/steinbergmedia/vst3_public_sdk/archive/3fce096d6ee575479753f1aab23033d2e2ffdc6e.tar.gz|2915be92fa70eda43b99ee492957b9334ae7cc6156f26f25bda952fc34248408"
)
