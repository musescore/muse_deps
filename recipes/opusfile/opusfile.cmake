# Static lib
set(DEP_TARGET opusfile::opusfile)
set(DEP_LIBS opusfile)
set(DEP_STATIC ON)
set(DEP_LINK_DEPS Opus::opus)
set(DEP_INCLUDE_SUBDIRS opus)
set(DEP_SYSTEM_HEADER opus/opusfile.h)
