# libcurl, SYSTEM ONLY
# todo: consider static linking to openssl
function(libcurl_resolve_override mode local_path os arch version)
    if(NOT mode STREQUAL "system")
        message(FATAL_ERROR "[libcurl] only system mode is supported, use require_dep(libcurl SYSTEM)")
    endif()
    find_package(CURL REQUIRED)
    set_property(GLOBAL PROPERTY libcurl_INCLUDE_DIRS "${CURL_INCLUDE_DIRS}")
    set_property(GLOBAL PROPERTY libcurl_LIBRARIES CURL::libcurl)
    set_property(GLOBAL PROPERTY libcurl_INSTALL_LIBRARIES "")
endfunction()
