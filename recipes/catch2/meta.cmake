set(DEP_KIND source)

# Catch2 v2 (single header, target Catch2::Catch2) as used by the AU3 libraries' unit tests.
function(catch2_add_to_build)
    if(TARGET Catch2)
        return()
    endif()
    get_property(_src GLOBAL PROPERTY catch2_SOURCE_DIR)
    # Catch2 2.x declares cmake_minimum_required(3.5): let our normal variables win over its option() defaults
    set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
    set(CATCH_BUILD_TESTING OFF)
    set(CATCH_INSTALL_DOCS OFF)
    set(CATCH_INSTALL_HELPERS OFF)
    set(CATCH_ENABLE_WERROR OFF)
    add_subdirectory("${_src}/catch2" catch2 EXCLUDE_FROM_ALL)
endfunction()
