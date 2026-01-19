function(libcurl_Populate remote_url local_path os arch build_type)

    if (os STREQUAL "linux")

        set(compiler "gcc12")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        set(name "linux_${arch}_relwithdebinfo_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[libcurl] Populate: ${remote_url}/${name} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()
    
        set(libcurl_INCLUDE_DIRS ${local_path}/include)
        set(libcurl_LIBRARIES
            ${local_path}/lib/libcurl.so.4.8.0
            ${local_path}/lib/libcurl.so.4
            ${local_path}/lib/libcurl.so
        )
        set(libcurl_INSTALL_LIBRARIES ${libcurl_LIBRARIES})
        set(openssl_libraries OpenSSL::SSL OpenSSL::Crypto)

    elseif(os STREQUAL "macos")

        # At the moment only relwithdebinfo
        # I don't think we need debug builds
        if (arch STREQUAL "x86_64")
            set(name "macos_x86_64_relwithdebinfo_appleclang15_os109")
        elseif (arch STREQUAL "aarch64")
            set(name "macos_aarch64_relwithdebinfo_appleclang15_os1013")
        elseif (arch STREQUAL "universal")
            set(name "macos_universal_relwithdebinfo_appleclang15")
        else()
            message(FATAL_ERROR "Not supported macos arch: ${arch}")
        endif()

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[libcurl] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(libcurl_INCLUDE_DIRS ${local_path}/include)
        set(libcurl_LIBRARIES
            ${local_path}/lib/libcurl.4.dylib
            ${local_path}/lib/libcurl.dylib
        )
        set(libcurl_INSTALL_LIBRARIES ${libcurl_LIBRARIES})
        set(openssl_libraries OpenSSL::SSL OpenSSL::Crypto)

    elseif(os STREQUAL "windows")

        set(compiler "msvc194")

        if (build_type STREQUAL "release")
            set(build_type "relwithdebinfo")
        endif()

        set(name "windows_${arch}_${build_type}_${compiler}")

        if (NOT EXISTS ${local_path}/${name}.7z)
            message(STATUS "[libcurl] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
            file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
            file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
        endif()

        set(libcurl_INCLUDE_DIRS ${local_path}/include)
        set(libcurl_LIBRARIES ${local_path}/lib/libcurl_imp.lib)
        set(libcurl_INSTALL_LIBRARIES ${local_path}/bin/libcurl.dll)

    else()
        message(FATAL_ERROR "[libcurl] Not supported os: ${os}")
    endif()

    if(NOT TARGET CURL::libcurl)
       add_library(CURL::libcurl INTERFACE IMPORTED GLOBAL)

       target_include_directories(CURL::libcurl INTERFACE ${libcurl_INCLUDE_DIRS} )
       target_link_libraries(CURL::libcurl INTERFACE ${libcurl_LIBRARIES} ${openssl_libraries} )
    endif()

    set_property(GLOBAL PROPERTY libcurl_INCLUDE_DIRS ${libcurl_INCLUDE_DIRS})
    set_property(GLOBAL PROPERTY libcurl_LIBRARIES ${libcurl_LIBRARIES})
    set_property(GLOBAL PROPERTY libcurl_INSTALL_LIBRARIES ${libcurl_INSTALL_LIBRARIES} ${openssl_INSTALL_LIBRARIES})

endfunction()
