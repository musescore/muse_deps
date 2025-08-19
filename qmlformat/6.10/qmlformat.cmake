function(qmlformat_Populate remote_url local_path os)

    set(name "${os}_x86_64")

    if (NOT EXISTS ${local_path}/${name}.7z)
        message(STATUS "[qmlformat] Downloading: ${remote_url}/${name}.7z to ${local_path}")
        file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
        file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
    endif()

    # set qmlformat executable name
    if (os STREQUAL "linux")
        set(qmlformat_EXECUTABLE ${local_path}/bin/qmlformat)
    elseif (os STREQUAL "macos")
        set(qmlformat_EXECUTABLE ${local_path}/bin/qmlformat)
    elseif (os STREQUAL "windows")
        set(qmlformat_EXECUTABLE ${local_path}/bin/qmlformat.exe)
    endif()
    if (NOT EXISTS ${qmlformat_EXECUTABLE})
        message(STATUS "[qmlformat] Executable not found: ${qmlformat_EXECUTABLE}")
    endif()
endfunction()
