if(DEP_ALL_AS_SOURCE)
    set(DEP_KIND source)

    function(harfbuzz_add_to_build)
        if(TARGET harfbuzz::harfbuzz)
            return()
        endif()

        if(COMMAND freetype_add_to_build)
            freetype_add_to_build()
        endif()

        get_property(_src GLOBAL PROPERTY harfbuzz_SOURCE_DIR)

        set(BUILD_SHARED_LIBS OFF)
        set(HB_HAVE_FREETYPE ON CACHE BOOL "" FORCE)
        set(HB_BUILD_SUBSET OFF CACHE BOOL "" FORCE)

        add_subdirectory("${_src}/harfbuzz" "${CMAKE_BINARY_DIR}/_deps/harfbuzz-build" EXCLUDE_FROM_ALL)

        if(TARGET harfbuzz AND NOT TARGET harfbuzz::harfbuzz)
            add_library(harfbuzz::harfbuzz ALIAS harfbuzz)
        endif()
    endfunction()
else()
    set(DEP_TARGET harfbuzz::harfbuzz)
    set(DEP_LIBS harfbuzz)
    set(DEP_INCLUDE_SUBDIRS harfbuzz)
    set(DEP_SYSTEM_HEADER harfbuzz/hb-ft.h)
endif()
