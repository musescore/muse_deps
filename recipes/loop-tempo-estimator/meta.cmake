set(DEP_KIND source)

function(loop_tempo_estimator_add_to_build)
    get_property(_src GLOBAL PROPERTY loop-tempo-estimator_SOURCE_DIR)
    if(NOT TARGET loop-tempo-estimator)
        add_subdirectory("${_src}/loop-tempo-estimator/source" loop-tempo-estimator EXCLUDE_FROM_ALL)
    endif()
endfunction()
