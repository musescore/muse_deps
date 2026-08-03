set(DEP_KIND source)

function(lodepng_add_to_build)
    if (TARGET lodepng)
        return()
    endif()

    get_property(_src GLOBAL PROPERTY lodepng_SOURCE_DIR)
    add_library(lodepng STATIC "${_src}/lodepng/lodepng.cpp")
    add_library(lodepng::lodepng ALIAS lodepng)
    target_include_directories(lodepng PUBLIC "${_src}/lodepng")
    set_target_properties(lodepng PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        UNITY_BUILD OFF
        AUTOMOC OFF
        AUTOUIC OFF
        AUTORCC OFF
    )
endfunction()
