function(opus_Populate remote_url local_path os arch build_type)

    if (os STREQUAL "linux")

        set(compiler "gcc12")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        set(name "linux_${arch}_relwithdebinfo_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[opus] Populate: ${remote_url}/${name} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(opus_INCLUDE_DIRS ${local_path}/include)
        set(opus_LIBRARIES
            ${local_path}/lib/libopus.so.0.10.1
            ${local_path}/lib/libopus.so.0
            ${local_path}/lib/libopus.so
        )
        set(opus_INSTALL_LIBRARIES ${opus_LIBRARIES})

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
            message(STATUS "[opus] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(opus_INCLUDE_DIRS ${local_path}/include)
        set(opus_LIBRARIES
            ${local_path}/lib/libopus.0.10.1.dylib
            ${local_path}/lib/libopus.0.dylib
            ${local_path}/lib/libopus.dylib
        )
        set(opus_INSTALL_LIBRARIES ${opus_LIBRARIES})

    elseif(os STREQUAL "windows")

        set(compiler "msvc194")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[opus] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(opus_INCLUDE_DIRS ${local_path}/include)
        set(opus_LIBRARIES ${local_path}/lib/opus.lib)
        set(opus_INSTALL_LIBRARIES ${local_path}/bin/opus.dll)

    else()
        message(FATAL_ERROR "[opus] Not supported os: ${os}")
    endif()

    if(NOT TARGET Opus::opus)
       add_library(Opus::opus INTERFACE IMPORTED GLOBAL)

       target_include_directories(Opus::opus INTERFACE ${opus_INCLUDE_DIRS} )
       target_link_libraries(Opus::opus INTERFACE ${opus_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY opus_INCLUDE_DIRS ${opus_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY opus_LIBRARIES ${opus_LIBRARIES})
    set_property(GLOBAL PROPERTY opus_INSTALL_LIBRARIES ${opus_INSTALL_LIBRARIES})

endfunction()
