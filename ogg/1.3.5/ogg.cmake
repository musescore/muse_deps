function(ogg_Populate remote_url local_path os arch build_type)

    if (os STREQUAL "linux")

        set(compiler "gcc10")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        set(name "linux_${arch}_relwithdebinfo_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[ogg] Populate: ${remote_url}/${name} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(ogg_INCLUDE_DIRS ${local_path}/include)
        set(ogg_LIBRARIES
            ${local_path}/lib/libogg.so.0.8.5
            ${local_path}/lib/libogg.so.0
            ${local_path}/lib/libogg.so
        )
        set(ogg_INSTALL_LIBRARIES ${ogg_LIBRARIES})

    elseif(os STREQUAL "macos")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        if (arch STREQUAL "x86_64")
            set(name "macos_x86_64_relwithdebinfo_appleclang15_os109")
        elseif (arch STREQUAL "aarch64")
            set(name "macos_aarch64_relwithdebinfo_appleclang15_os1013")
        else()
            message(FATAL_ERROR "Not supported macos arch: ${arch}")
        endif()

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[ogg] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(ogg_INCLUDE_DIRS ${local_path}/include)
        set(ogg_LIBRARIES
            ${local_path}/lib/libogg.0.8.5.dylib
            ${local_path}/lib/libogg.0.dylib
            ${local_path}/lib/libogg.dylib
        )
        set(ogg_INSTALL_LIBRARIES ${ogg_LIBRARIES})

    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[ogg] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(ogg_INCLUDE_DIRS ${local_path}/include)
        set(ogg_LIBRARIES ${local_path}/lib/ogg.lib)
        set(ogg_INSTALL_LIBRARIES ${local_path}/bin/ogg.dll)

    else()
        message(FATAL_ERROR "[ogg] Not supported os: ${os}")
    endif()

    if(NOT TARGET Ogg::ogg)
       add_library(Ogg::ogg INTERFACE IMPORTED GLOBAL)

       target_include_directories(Ogg::ogg INTERFACE ${ogg_INCLUDE_DIRS} )
       target_link_libraries(Ogg::ogg INTERFACE ${ogg_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY ogg_INCLUDE_DIRS ${ogg_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY ogg_LIBRARIES ${ogg_LIBRARIES})
    set_property(GLOBAL PROPERTY ogg_INSTALL_LIBRARIES ${ogg_INSTALL_LIBRARIES})

endfunction()
