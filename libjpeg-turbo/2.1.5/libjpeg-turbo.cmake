
function(libjpeg-turbo_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "macos")

            # At the moment only relwithdebinfo
            # I don't think we need debug builds
            if (arch STREQUAL "x86_64")
                set(name "libjpeg-turbo_macos_x86_64_relwithdebinfo_appleclang15_os109")
            elseif (arch STREQUAL "aarch64")
                set(name "libjpeg-turbo_macos_aarch64_relwithdebinfo_appleclang15_os1013")
            elseif (arch STREQUAL "universal")
                set(name "libjpeg-turbo_macos_universal_relwithdebinfo_appleclang15_os1013")
            else()
                message(FATAL_ERROR "Not supported macos arch: ${arch}")
            endif()

            if (NOT EXISTS ${local_path}/${name}.7z)
                message(STATUS "[libjpeg-turbo] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
                file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
                file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
            endif()

            set(libjpeg-turbo_INCLUDE_DIRS ${local_path}/include)
            set(libjpeg-turbo_LIBRARIES
                ${local_path}/lib/libjpeg.8.2.2.dylib
                ${local_path}/lib/libturbojpeg.0.2.0.dylib
            )
            set(libjpeg-turbo_INSTALL_LIBRARIES
                ${local_path}/lib/libjpeg.8.2.2.dylib
                ${local_path}/lib/libjpeg.8.dylib
                ${local_path}/lib/libjpeg.dylib
                ${local_path}/lib/libturbojpeg.0.2.0.dylib
                ${local_path}/lib/libturbojpeg.0.dylib
                ${local_path}/lib/libturbojpeg.dylib
            )

    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "libjpeg-turbo_windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[libjpeg-turbo] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(libjpeg-turbo_INCLUDE_DIRS ${local_path}/include)
        set(libjpeg-turbo_LIBRARIES
            ${local_path}/lib/jpeg.lib
            ${local_path}/lib/turbojpeg.lib
        )
        set(libjpeg-turbo_INSTALL_LIBRARIES
            ${local_path}/bin/jpeg8.dll
            ${local_path}/bin/turbojpeg.dll
        )

    else()
        message(FATAL_ERROR "[libjpeg-turbo] Not supported os: ${os}")
    endif()

    if(NOT TARGET libjpeg-turbo::libjpeg-turbo)
       add_library(libjpeg-turbo::libjpeg-turbo INTERFACE IMPORTED GLOBAL)

       target_include_directories(libjpeg-turbo::libjpeg-turbo INTERFACE ${libjpeg-turbo_INCLUDE_DIRS} )
       target_link_libraries(libjpeg-turbo::libjpeg-turbo INTERFACE ${libjpeg-turbo_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY libjpeg-turbo_INCLUDE_DIRS ${libjpeg-turbo_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY libjpeg-turbo_LIBRARIES ${libjpeg-turbo_LIBRARIES})
    set_property(GLOBAL PROPERTY libjpeg-turbo_INSTALL_LIBRARIES ${libjpeg-turbo_INSTALL_LIBRARIES})

endfunction()

