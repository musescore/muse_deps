set(DEP_TARGET zlib::zlib)
set(DEP_LIBS z)
set(DEP_LIBS_WINDOWS zlib)
set(DEP_SYSTEM_HEADER zlib.h)

# zlib is consumed two ways: our zlib::zlib target
# and freetype third-party CMake calling find_package(ZLIB).
# Make sure FindZLIB will resolve to the same target, otherwise will link to system zlib
function(zlib_post_resolve mode local_path os arch version)
    get_property(_inc  GLOBAL PROPERTY zlib_INCLUDE_DIRS)
    get_property(_libs GLOBAL PROPERTY zlib_LIBRARIES)
    if(_libs)
        list(GET _libs 0 _lib)
        set(ZLIB_INCLUDE_DIR "${_inc}" CACHE PATH     "from extdeps zlib" FORCE)
        set(ZLIB_LIBRARY     "${_lib}" CACHE FILEPATH "from extdeps zlib" FORCE)
    endif()
endfunction()
