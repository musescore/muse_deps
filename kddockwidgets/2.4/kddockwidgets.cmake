
function(kddockwidgets_Populate remote_url local_path os arch build_type)

    set(src_path ${local_path}/kddockwidgets)

    if (NOT EXISTS ${src_path}/CMakeLists.txt)
        message(STATUS "[kddockwidgets] Cloning source to ${src_path}")
        find_package(Git REQUIRED)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --branch 2.4 --depth 1
                https://github.com/musescore/KDDockWidgets ${src_path}
            RESULT_VARIABLE git_result
        )
        if (NOT git_result EQUAL 0)
            message(FATAL_ERROR "[kddockwidgets] Failed to clone repository")
        endif()
    endif()

    if (NOT BUILD_SHARED_LIBS)
        set(KDDockWidgets_STATIC ON CACHE BOOL "Build static versions of the libraries" FORCE)
    endif()

    set(KDDockWidgets_QT6 ON CACHE BOOL "Build against Qt 6" FORCE)
    set(KDDockWidgets_FRONTENDS "qtquick" CACHE STRING "Frontends to build" FORCE)
    set(KDDockWidgets_EXAMPLES OFF CACHE BOOL "Build the examples" FORCE)
    set(KDDockWidgets_TESTS OFF CACHE BOOL "Build the tests" FORCE)

    add_subdirectory(${src_path} ${CMAKE_BINARY_DIR}/kddockwidgets EXCLUDE_FROM_ALL)

    set_property(GLOBAL PROPERTY kddockwidgets_SOURCE_DIR ${local_path})

endfunction()
