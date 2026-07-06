set(DEP_VERSION 1.6.7)

set(DEP_SOURCE_URL    "https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/1.6.7/pipewire-1.6.7.tar.gz")
set(DEP_SOURCE_SHA256 "a618c0a159055e2443f638c5c9f4b904e6902b655c09a7ff84546fa2447aedf8")

# Consumed only as an optional Linux audio driver backend
set(DEP_PLATFORMS linux-x86_64 linux-aarch64)

# Built as a minimal client library: only the audioconvert/support spa
# plugins that muse_audio_driver needs are enabled. Everything that would
# pull in extra system deps (bluez5, jack, v4l2, gstreamer, session
# managers, ...) is disabled so the build is deterministic across CI images.
set(DEP_MESON_ARGS
    -Ddocs=disabled
    -Dman=disabled
    -Dexamples=disabled
    -Dtests=disabled
    -Dinstalled_tests=disabled
    -Dgstreamer=disabled
    -Dgstreamer-device-provider=disabled
    -Dlibsystemd=disabled
    -Dlogind=disabled
    -Dsystemd-system-service=disabled
    -Dsystemd-user-service=disabled
    -Dselinux=disabled
    -Dpipewire-alsa=disabled
    -Dpipewire-jack=disabled
    -Dpipewire-v4l2=disabled
    -Djack-devel=false
    -Dalsa=disabled
    -Daudiomixer=disabled
    -Daudioconvert=enabled
    -Dbluez5=disabled
    -Dcontrol=disabled
    -Daudiotestsrc=disabled
    -Djack=disabled
    -Dsupport=enabled
    -Devl=disabled
    -Dv4l2=disabled
    -Ddbus=enabled
    -Dlibcamera=disabled
    -Dvideoconvert=disabled
    -Dvideotestsrc=disabled
    -Dpw-cat=disabled
    -Dudev=disabled
    -Dsdl2=disabled
    -Dsndfile=disabled
    -Dlibmysofa=disabled
    -Dlibpulse=disabled
    -Droc=disabled
    -Davahi=disabled
    -Decho-cancel-webrtc=disabled
    -Dlibusb=disabled
    -Dsession-managers=[]
    -Draop=disabled
    -Dlv2=disabled
    -Dx11=disabled
    -Dx11-xfixes=disabled
    -Dlibcanberra=disabled
    -Dlegacy-rtkit=false
    -Davb=disabled
    -Dflatpak=disabled
    -Dreadline=disabled
    -Dgsettings=disabled
    -Dcompress-offload=disabled
    -Drlimits-install=false
    -Dopus=disabled
    -Dlibffado=disabled
    -Dgsettings-pulse-schema=disabled
    -Debur128=disabled
    -Dfftw=disabled
    -Donnxruntime=disabled
    -Dsnap=disabled
)

set(DEP_LICENSE_FILES COPYING)
