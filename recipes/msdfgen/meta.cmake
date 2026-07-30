set(DEP_TARGET msdfgen::msdfgen)
set(DEP_LIBS msdfgen-core msdfgen-ext)
set(DEP_INCLUDE_SUBDIRS msdfgen)
set(DEP_SYSTEM_HEADER msdfgen/msdfgen.h)

if(DEP_STATIC)
    list(APPEND DEP_CMAKE_ARGS
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DMSDFGEN_DYNAMIC_RUNTIME=ON
    )

    set(DEP_LIBS msdfgen-ext msdfgen-core)
    list(APPEND DEP_LINK_DEPS freetype::freetype)
endif()
