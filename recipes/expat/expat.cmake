set(DEP_TARGET expat::expat)
set(DEP_LIBS expat)
set(DEP_LIBS_WINDOWS libexpat)   # MSVC build keeps the lib prefix: libexpat.lib / libexpat.dll
set(DEP_SYSTEM_HEADER expat.h)
