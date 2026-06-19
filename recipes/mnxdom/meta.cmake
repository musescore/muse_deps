set(DEP_KIND source)
set(DEP_SOURCE_SYSTEM ON) # may be switched to system mode

function(mnxdom_post_resolve mode local_path os arch version)
    if(TARGET mnxdom)
        return()
    endif()

    # if system mode requested searching the system
    if(mode STREQUAL "system")
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(mnxdom REQUIRED IMPORTED_TARGET mnxdom)
        add_library(mnxdom INTERFACE IMPORTED GLOBAL)
        target_link_libraries(mnxdom INTERFACE PkgConfig::mnxdom)
        target_compile_definitions(mnxdom INTERFACE MNXDOM_SYSTEM)
        return()
    endif()

    get_property(_njson GLOBAL PROPERTY nlohmann_json_PREFIX)
    get_property(_jsv   GLOBAL PROPERTY json_schema_validator_PREFIX)
    get_property(_w3c   GLOBAL PROPERTY mnx_w3c_SOURCE_DIR)
    list(PREPEND CMAKE_PREFIX_PATH "${_njson}" "${_jsv}")
    set(USE_SYSTEM_NLOHMANN_JSON ON CACHE BOOL "" FORCE)
    set(USE_SYSTEM_JSON_SCHEMA_VALIDATOR ON CACHE BOOL "" FORCE)
    set(MNX_W3C_SOURCE "${_w3c}/mnx_w3c" CACHE PATH "" FORCE)
    set(mnxdom_BUILD_TESTING OFF CACHE BOOL "" FORCE)
    add_subdirectory("${local_path}/mnxdom" "${CMAKE_BINARY_DIR}/_deps/mnxdom-build" EXCLUDE_FROM_ALL)
endfunction()
