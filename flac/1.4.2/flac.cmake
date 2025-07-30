function(flac_Populate remote_url local_path os arch build_type)

    if (os STREQUAL "linux")

        set(compiler "gcc10")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        set(name "linux_${arch}_relwithdebinfo_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[flac] Populate: ${remote_url}/${name} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(flac_INCLUDE_DIRS ${local_path}/include)
        set(flac_LIBRARIES
            ${local_path}/lib/libFLAC.so.12.0.0
            ${local_path}/lib/libFLAC.so.12
            ${local_path}/lib/libFLAC.so
        )
        set(flac_INSTALL_LIBRARIES ${flac_LIBRARIES})

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
            message(STATUS "[flac] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(flac_INCLUDE_DIRS ${local_path}/include)
        set(flac_LIBRARIES
            ${local_path}/lib/libFLAC.12.0.0.dylib
            ${local_path}/lib/libFLAC.12.dylib
            ${local_path}/lib/libFLAC.dylib
        )
        set(flac_INSTALL_LIBRARIES ${flac_LIBRARIES})

    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[flac] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(flac_INCLUDE_DIRS ${local_path}/include)
        set(flac_LIBRARIES ${local_path}/lib/FLAC.lib)
        set(flac_INSTALL_LIBRARIES ${local_path}/bin/FLAC.dll)

    else()
        message(FATAL_ERROR "[flac] Not supported os: ${os}")
    endif()

    if(NOT TARGET FLAC::FLAC)
       add_library(FLAC::FLAC INTERFACE IMPORTED GLOBAL)

       target_include_directories(FLAC::FLAC INTERFACE ${flac_INCLUDE_DIRS} )
       target_link_libraries(FLAC::FLAC INTERFACE ${flac_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY flac_INCLUDE_DIRS ${flac_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY flac_LIBRARIES ${flac_LIBRARIES})
    set_property(GLOBAL PROPERTY flac_INSTALL_LIBRARIES ${flac_INSTALL_LIBRARIES})

endfunction()
