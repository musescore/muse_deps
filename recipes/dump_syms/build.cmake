# dump_syms does not have cmake, builds with native tools on each platform
# here we wrap it in a cmake scipt
if(BD_OS STREQUAL "linux")
    # linux-syscall-support bundled with the recipe
    file(COPY "${BD_RECIPE_DIR}/linux_syscall_support.h"
         DESTINATION "${SRC}/src/third_party/lss")
    include(ProcessorCount)
    ProcessorCount(_jobs)
    _bd_run_dir("${SRC}" ./configure)
    _bd_run_dir("${SRC}" make -j${_jobs} src/tools/linux/dump_syms/dump_syms)
    file(COPY "${SRC}/src/tools/linux/dump_syms/dump_syms"
         DESTINATION "${INSTALL}/bin")

elseif(BD_OS STREQUAL "macos")
    if(BD_ARCH STREQUAL "universal")
        set(_archs "x86_64 arm64")
    elseif(BD_ARCH STREQUAL "aarch64")
        set(_archs "arm64")
    else()
        set(_archs "${BD_ARCH}")
    endif()
    _bd_run_dir("${SRC}/src/tools/mac/dump_syms"
        xcodebuild -project dump_syms.xcodeproj -target dump_syms
                   -configuration Release build
                   "SYMROOT=${BUILD}" "ARCHS=${_archs}" ONLY_ACTIVE_ARCH=NO)
    file(COPY "${BUILD}/Release/dump_syms" DESTINATION "${INSTALL}/bin")

elseif(BD_OS STREQUAL "windows")
    find_program(MSBUILD NAMES msbuild REQUIRED)
    _bd_run_dir("${SRC}/src/tools/windows/dump_syms"
        "${MSBUILD}" dump_syms.vcxproj /m /p:Configuration=Release /p:Platform=Win32)
    file(COPY "${SRC}/src/tools/windows/dump_syms/Release/dump_syms.exe"
         DESTINATION "${INSTALL}/bin")
    file(TO_CMAKE_PATH "$ENV{VSINSTALLDIR}" _vs)
    file(COPY "${_vs}/DIA SDK/bin/msdia140.dll" DESTINATION "${INSTALL}/bin")

else()
    message(FATAL_ERROR "[dump_syms] unsupported OS: ${BD_OS}")
endif()
