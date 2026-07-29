if(DEP_ALL_AS_SOURCE)
    set(DEP_KIND source)

    function(freetype_add_to_build)
        if(TARGET freetype::freetype)
            return()
        endif()

        get_property(_src GLOBAL PROPERTY freetype_SOURCE_DIR)

        set(BUILD_SHARED_LIBS OFF)
        set(FT_DISABLE_ZLIB TRUE CACHE BOOL "" FORCE)
        set(FT_DISABLE_BZIP2 TRUE CACHE BOOL "" FORCE)
        set(FT_DISABLE_PNG FALSE CACHE BOOL "" FORCE)
        set(FT_DISABLE_HARFBUZZ TRUE CACHE BOOL "" FORCE)
        set(FT_DISABLE_BROTLI TRUE CACHE BOOL "" FORCE)

        add_subdirectory("${_src}/freetype" "${CMAKE_BINARY_DIR}/_deps/freetype-build" EXCLUDE_FROM_ALL)

        if(TARGET freetype AND NOT TARGET freetype::freetype)
            add_library(freetype::freetype ALIAS freetype)
        endif()

        if(TARGET freetype AND NOT TARGET Freetype::Freetype)
            add_library(Freetype::Freetype ALIAS freetype)
        endif()
    endfunction()
else()
    set(DEP_TARGET freetype::freetype)
    set(DEP_LIBS freetype)
    set(DEP_INCLUDE_SUBDIRS freetype2)
    set(DEP_SYSTEM_HEADER freetype2/ft2build.h)
endif()
