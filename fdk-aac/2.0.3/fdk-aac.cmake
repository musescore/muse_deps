function(fdk-aac_Populate remote_url local_path os arch build_type)

    set(src_path ${local_path}/fdk-aac-2.0.3)
    set(name "fdk-aac_src")

    if (NOT EXISTS ${src_path}/CMakeLists.txt)
        message(STATUS "[fdk-aac] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
        file(DOWNLOAD ${remote_url}/${name}.zip ${local_path}/${name}.zip)
        file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.zip DESTINATION ${local_path})
    endif()

    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library" FORCE)
    set(BUILD_PROGRAMS OFF CACHE BOOL "Build extra utilities" FORCE)

    add_subdirectory(${src_path} ${CMAKE_BINARY_DIR}/fdk-aac EXCLUDE_FROM_ALL)

    set_property(GLOBAL PROPERTY fdk-aac_SOURCE_DIR ${src_path})

endfunction()
