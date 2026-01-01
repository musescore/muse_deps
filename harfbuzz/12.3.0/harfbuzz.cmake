
function(harfbuzz_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "source")

            set(name "harfbuzz_src")

            if (NOT EXISTS ${local_path}/${name}.7z)
                message(STATUS "[harfbuzz] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
                file(DOWNLOAD ${remote_url}/${name}.7z ${local_path}/${name}.7z)
                file(ARCHIVE_EXTRACT INPUT ${local_path}/${name}.7z DESTINATION ${local_path})
            endif()

    else()
        message(FATAL_ERROR "[harfbuzz] Not supported os: ${os}")
    endif()

endfunction()

