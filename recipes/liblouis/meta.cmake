set(DEP_KIND source)

# remember the path to recipe so we can use it in post_resolve
set_property(GLOBAL PROPERTY _liblouis_recipe "${CMAKE_CURRENT_LIST_DIR}")

# this is called after the source is populated
# creates a target: liblouis and sets global LIBLOUIS_TABLE_NAMES with tables to install
function(liblouis_post_resolve mode local_path os arch version)
    get_property(_recipe GLOBAL PROPERTY _liblouis_recipe)
    set(_src "${local_path}/liblouis/liblouis")
    set(_gen "${CMAKE_BINARY_DIR}/_deps/liblouis-gen/liblouis")

    set(WIDECHARS_ARE_UCS4 TRUE)        # configMS.h
    set(WIDECHAR_TYPE "unsigned int")   # liblouis.h.in
    configure_file("${_recipe}/configMS.h" "${_gen}/config.h" @ONLY)
    configure_file("${_src}/liblouis.h.in" "${_gen}/liblouis.h" @ONLY)

    add_library(liblouis STATIC
        ${_src}/commonTranslationFunctions.c
        ${_src}/compileTranslationTable.c
        ${_src}/logging.c
        ${_src}/lou_backTranslateString.c
        ${_src}/lou_translateString.c
        ${_src}/maketable.c
        ${_src}/pattern.c
        ${_src}/utils.c
        ${_gen}/config.h
        ${_gen}/liblouis.h
    )
    target_compile_definitions(liblouis PRIVATE TABLESDIR=dataPathPtr)
    target_include_directories(liblouis PUBLIC ${_src} ${_gen})
    set_target_properties(liblouis PROPERTIES UNITY_BUILD OFF)
    if(MSVC)
        target_compile_options(liblouis PRIVATE /wd4018 /wd4100 /wd4101 /wd4189 /wd4244 /wd4267 /wd4389 /wd4456 /wd4457 /wd4701 /wd4702 /wd4703 /wd4996)
    else()
        # equivalents for C4018 and C4389 might be needed
        target_compile_options(liblouis PRIVATE -Wno-unused-parameter -Wno-unused-variable -Wno-conversion)
    endif()

    # expose tables for the consumer to install
    include("${_recipe}/tables.cmake")  # -> LIBLOUIS_TABLE_NAMES
    list(TRANSFORM LIBLOUIS_TABLE_NAMES PREPEND "${local_path}/liblouis/tables/")
    set_property(GLOBAL PROPERTY liblouis_TABLES "${LIBLOUIS_TABLE_NAMES}")
endfunction()
