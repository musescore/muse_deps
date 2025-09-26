function(vorbis_Populate remote_url local_path os arch build_type)

    if (os STREQUAL "linux")

        set(compiler "gcc10")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        set(name "linux_${arch}_relwithdebinfo_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[vorbis] Populate: ${remote_url}/${name} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(vorbis_INCLUDE_DIRS ${local_path}/include)
        set(vorbis_LIBRARIES
            ${local_path}/lib/libvorbis.so.0.4.9
            ${local_path}/lib/libvorbis.so
            ${local_path}/lib/libvorbisenc.so.2.0.12
            ${local_path}/lib/libvorbisenc.so
            ${local_path}/lib/libvorbisfile.so.3.3.8
            ${local_path}/lib/libvorbisfile.so
        )
        set(vorbis_INSTALL_LIBRARIES ${vorbis_LIBRARIES})

    elseif(os STREQUAL "macos")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        if (arch STREQUAL "x86_64")
            set(name "macos_x86_64_relwithdebinfo_appleclang15_os109")
        elseif (arch STREQUAL "aarch64")
            set(name "macos_aarch64_relwithdebinfo_appleclang15_os1013")
        elseif (arch STREQUAL "universal")
            set(name "macos_universal_relwithdebinfo_appleclang15_os1013")
        else()
            message(FATAL_ERROR "Not supported macos arch: ${arch}")
        endif()

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[vorbis] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(vorbis_INCLUDE_DIRS ${local_path}/include)
        set(vorbis_LIBRARIES
            ${local_path}/lib/libvorbis.0.4.9.dylib
            ${local_path}/lib/libvorbis.dylib
            ${local_path}/lib/libvorbisenc.2.0.12.dylib
            ${local_path}/lib/libvorbisenc.dylib
            ${local_path}/lib/libvorbisfile.3.3.8.dylib
            ${local_path}/lib/libvorbisfile.dylib
        )
        set(vorbis_INSTALL_LIBRARIES ${vorbis_LIBRARIES})

    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[vorbis] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(vorbis_INCLUDE_DIRS ${local_path}/include)
        set(vorbis_LIBRARIES 
            ${local_path}/lib/vorbis.lib
            ${local_path}/lib/vorbisenc.lib
            ${local_path}/lib/vorbisfile.lib
        )
        set(vorbis_INSTALL_LIBRARIES
            ${local_path}/bin/vorbis.dll
            ${local_path}/bin/vorbisenc.dll
            ${local_path}/bin/vorbisfile.dll
        )

    else()
        message(FATAL_ERROR "[vorbis] Not supported os: ${os}")
    endif()

    if(NOT TARGET Vorbis::vorbis)
       add_library(Vorbis::vorbis INTERFACE IMPORTED GLOBAL)

       target_include_directories(Vorbis::vorbis INTERFACE ${vorbis_INCLUDE_DIRS} )
       target_link_libraries(Vorbis::vorbis INTERFACE ${vorbis_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY vorbis_INCLUDE_DIRS ${vorbis_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY vorbis_LIBRARIES ${vorbis_LIBRARIES})
    set_property(GLOBAL PROPERTY vorbis_INSTALL_LIBRARIES ${vorbis_INSTALL_LIBRARIES})

endfunction()
