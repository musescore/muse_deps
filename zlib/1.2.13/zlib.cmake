
function(zlib_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "windows")

        set(compiler "msvc192")
        set(suffix "")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        if (build_type STREQUAL "debug")
            set(suffix "d")
        endif()

        set(name "zlib_windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[zlib] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(zlib_INCLUDE_DIRS ${local_path}/include)
        set(zlib_LIBRARIES ${local_path}/lib/zdll.lib)
        set(zlib_INSTALL_LIBRARIES ${local_path}/bin/zlib1.dll)

        set_property(GLOBAL PROPERTY zlib_INCLUDE_DIRS ${zlib_INCLUDE_DIRS})
        set_property(GLOBAL PROPERTY zlib_LIBRARIES ${zlib_LIBRARIES})

    else()
        message(FATAL_ERROR "[zlib] Not supported os: ${os}")
    endif()

    if(NOT TARGET zlib::zlib)
       add_library(zlib::zlib INTERFACE IMPORTED GLOBAL)

       target_include_directories(zlib::zlib INTERFACE ${zlib_INCLUDE_DIRS} )
       target_link_libraries(zlib::zlib INTERFACE ${zlib_LIBRARIES} )
    endif()

    install(FILES ${zlib_INSTALL_LIBRARIES} TYPE BIN)

endfunction()
