set(DEP_KIND source)

set_property(GLOBAL PROPERTY _crashpad_client_recipe "${CMAKE_CURRENT_LIST_DIR}")

function(crashpad_client_add_to_build)
    if(TARGET gcrashpad)
        return()
    endif()
    get_property(_src GLOBAL PROPERTY crashpad_client_SOURCE_DIR)
    get_property(_recipe GLOBAL PROPERTY _crashpad_client_recipe)

    set(_arch "${LIB_ARCH}")
    if(NOT _arch)
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "[Aa][Rr][Mm]64|aarch64")
            set(_arch "aarch64")
        else()
            set(_arch "x86_64")
        endif()
    endif()

    set(CRASHPAD_CLIENT_CP "${_src}/crashpad")
    set(CRASHPAD_CLIENT_MC "${_src}/mini_chromium")
    set(CRASHPAD_CLIENT_GEN "${_recipe}/gen")
    set(CRASHPAD_CLIENT_ARCH "${_arch}")
    add_subdirectory("${_recipe}/build" "${CMAKE_BINARY_DIR}/_deps/crashpad_client-build")

    if(MSVC)
        target_compile_options(crashpad_client PRIVATE /wd4100)
    else()
        target_compile_options(crashpad_client PRIVATE -Wno-unused-parameter)
    endif()

endfunction()
