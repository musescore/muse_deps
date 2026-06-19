# Shared on unix
set(DEP_TARGET libmp3lame::libmp3lame)
set(DEP_LIBS mp3lame)
# static on Windows
set(DEP_STATIC_WINDOWS ON)
set(DEP_SYSTEM_HEADER lame/lame.h)
