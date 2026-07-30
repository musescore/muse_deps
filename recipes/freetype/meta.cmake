set(DEP_TARGET freetype::freetype)
set(DEP_LIBS freetype)
set(DEP_INCLUDE_SUBDIRS freetype2)
set(DEP_SYSTEM_HEADER freetype2/ft2build.h)

if(DEP_STATIC)
    list(APPEND DEP_CMAKE_ARGS
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DFT_DISABLE_PNG=TRUE
    )
    list(REMOVE_ITEM DEP_DEPENDS libpng)
endif()
