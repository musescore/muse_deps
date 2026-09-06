if(BD_OS STREQUAL "windows")
    set(LIBTYPE STATIC)
else()
    set(LIBTYPE SHARED)
endif()
configure_file("${BD_RECIPE_DIR}/CMakeLists.txt.in" "${SRC}/CMakeLists.txt" @ONLY)

_bd_cmake_build("${SRC}")
