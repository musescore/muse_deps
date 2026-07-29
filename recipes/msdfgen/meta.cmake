if(DEP_ALL_AS_SOURCE)
    set(DEP_KIND source)

    function(msdfgen_add_to_build)
        if(TARGET msdfgen::msdfgen)
            return()
        endif()

        if(COMMAND freetype_add_to_build)
            freetype_add_to_build()
        endif()

        if(TARGET freetype AND NOT TARGET Freetype::Freetype)
            add_library(Freetype::Freetype ALIAS freetype)
        endif()

        get_property(_src GLOBAL PROPERTY msdfgen_SOURCE_DIR)

        set(BUILD_SHARED_LIBS OFF)
        set(MSDFGEN_BUILD_STANDALONE OFF CACHE BOOL "" FORCE)
        set(MSDFGEN_USE_VCPKG OFF CACHE BOOL "" FORCE)
        set(MSDFGEN_USE_SKIA OFF CACHE BOOL "" FORCE)
        set(MSDFGEN_USE_OPENMP OFF CACHE BOOL "" FORCE)
        set(MSDFGEN_DISABLE_SVG ON CACHE BOOL "" FORCE)
        set(MSDFGEN_DISABLE_PNG ON CACHE BOOL "" FORCE)
        set(MSDFGEN_INSTALL OFF CACHE BOOL "" FORCE)

        add_subdirectory("${_src}/msdfgen" "${CMAKE_BINARY_DIR}/_deps/msdfgen-build" EXCLUDE_FROM_ALL)
    endfunction()
else()
    set(DEP_TARGETS "msdfgen::msdfgen|msdfgen-core msdfgen-ext")
    set(DEP_INCLUDE_SUBDIRS msdfgen)
    set(DEP_SYSTEM_HEADER msdfgen.h)
endif()
