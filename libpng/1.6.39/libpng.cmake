
function(libpng_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "macos")

            # At the moment only relwithdebinfo
            # I don't think we need debug builds
            if (arch STREQUAL "x86_64")
                set(name "libpng_macos_x86_64_relwithdebinfo_appleclang15_os109")
            elseif (arch STREQUAL "aarch64")
                set(name "libpng_macos_aarch64_relwithdebinfo_appleclang15_os1013")
            elseif (arch STREQUAL "universal")
                set(name "libpng_macos_universal_relwithdebinfo_appleclang15_os1013")
            else()
                message(FATAL_ERROR "Not supported macos arch: ${arch}")
            endif()

            if (NOT EXISTS ${local_path}/${name}.7z)
                message(STATUS "[libpng] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
                file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
                file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
            endif()

            set(libpng_INCLUDE_DIRS ${local_path}/include)
            set(libpng_LIBRARIES
                ${local_path}/lib/libpng16.16.39.0.dylib
            )
            set(libpng_INSTALL_LIBRARIES
                ${local_path}/lib/libpng16.16.39.0.dylib
                ${local_path}/lib/libpng16.16.dylib
                ${local_path}/lib/libpng16.dylib
                ${local_path}/lib/libpng.dylib
            )
    elseif(os STREQUAL "windows")

        set(compiler "msvc192")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        if (build_type STREQUAL "debug")
            set(suffix "d")
        endif()

        set(name "libpng_windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[libpng] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(libpng_INCLUDE_DIRS ${local_path}/include)
        set(libpng_LIBRARIES
            ${local_path}/lib/libpng16${suffix}.lib
        )
        set(libpng_INSTALL_LIBRARIES
            ${local_path}/bin/libpng16${suffix}.dll
        )

    else()
        message(FATAL_ERROR "[libpng] Not supported os: ${os}")
    endif()

    if(NOT TARGET libpng::libpng)
       add_library(libpng::libpng INTERFACE IMPORTED GLOBAL)

       target_include_directories(libpng::libpng INTERFACE ${libpng_INCLUDE_DIRS} )
       target_link_libraries(libpng::libpng INTERFACE ${libpng_LIBRARIES} )
    endif()

    set_property(GLOBAL PROPERTY libpng_INCLUDE_DIRS ${libpng_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY libpng_LIBRARIES ${libpng_LIBRARIES})
    set_property(GLOBAL PROPERTY libpng_INSTALL_LIBRARIES ${libpng_INSTALL_LIBRARIES})

endfunction()

