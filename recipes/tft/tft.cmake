set(DEP_KIND source)

function(tft_add_to_build)
    get_property(_src GLOBAL PROPERTY tft_SOURCE_DIR)
    if(NOT TARGET tft)
        add_subdirectory("${_src}/tft" tft EXCLUDE_FROM_ALL)
    endif()
endfunction()
