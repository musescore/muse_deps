# Static lib
set(DEP_TARGET opusenc::opusenc)
set(DEP_LIBS opusenc)
set(DEP_STATIC ON)
set(DEP_LINK_DEPS Opus::opus)
set(DEP_INCLUDE_SUBDIRS opus)
set(DEP_SYSTEM_HEADER opus/opusenc.h)
