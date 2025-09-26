
function(zlib_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "macos")

            # At the moment only relwithdebinfo
            # I don't think we need debug builds
            if (arch STREQUAL "x86_64")
                set(name "zlib_macos_x86_64_relwithdebinfo_appleclang15_os109")
            elseif (arch STREQUAL "aarch64")
                set(name "zlib_macos_aarch64_relwithdebinfo_appleclang15_os1013")
            elseif (arch STREQUAL "universal")
                set(name "zlib_macos_universal_relwithdebinfo_appleclang15_os1013")
            else()
                message(FATAL_ERROR "Not supported macos arch: ${arch}")
            endif()

            if (NOT EXISTS ${local_path}/${name}.7z)
                message(STATUS "[zlib] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
                file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
                file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
            endif()

            set(zlib_INCLUDE_DIRS ${local_path}/include)
            set(zlib_LIBRARIES
                ${local_path}/lib/libz.1.2.13.dylib
            )
            set(zlib_INSTALL_LIBRARIES
                ${local_path}/lib/libz.1.2.13.dylib
                ${local_path}/lib/libz.1.dylib
                ${local_path}/lib/libz.dylib
            )

    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
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

    else()
        message(FATAL_ERROR "[zlib] Not supported os: ${os}")
    endif()

    if(NOT TARGET zlib::zlib)
       add_library(zlib::zlib INTERFACE IMPORTED GLOBAL)

       target_include_directories(zlib::zlib INTERFACE ${zlib_INCLUDE_DIRS} )
       target_link_libraries(zlib::zlib INTERFACE ${zlib_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY zlib_INCLUDE_DIRS ${zlib_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY zlib_LIBRARIES ${zlib_LIBRARIES})
    set_property(GLOBAL PROPERTY zlib_INSTALL_LIBRARIES ${zlib_INSTALL_LIBRARIES})

endfunction()

