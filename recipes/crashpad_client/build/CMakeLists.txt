# Inputs (set by the caller):
# - CRASHPAD_CLIENT_CP
# - CRASHPAD_CLIENT_MC
# - CRASHPAD_CLIENT_GEN
# - CRASHPAD_CLIENT_ARCH

set(_cp "${CRASHPAD_CLIENT_CP}")
set(_mc "${CRASHPAD_CLIENT_MC}")

set(_src
    ${_mc}/base/logging.cc
    ${_mc}/base/rand_util.cc
    ${_mc}/base/files/file_path.cc
    ${_mc}/base/strings/stringprintf.cc
    ${_mc}/base/strings/utf_string_conversions.cc
    ${_mc}/base/strings/utf_string_conversion_utils.cc
    ${_cp}/client/crash_report_database.cc
    ${_cp}/client/settings.cc
    ${_cp}/util/misc/uuid.cc
    ${_cp}/util/misc/metrics.cc
    ${_cp}/util/file/file_writer.cc
    ${_cp}/util/file/file_reader.cc
)
set(_def "")
set(_link "")
set(_priv_inc "")

if(UNIX AND NOT APPLE)
    list(APPEND _src
        ${_mc}/base/files/scoped_file.cc
        ${_mc}/base/files/file_util_posix.cc
        ${_mc}/base/strings/string_number_conversions.cc
        ${_mc}/base/posix/safe_strerror.cc
        ${_mc}/base/memory/page_size_posix.cc

        ${_cp}/client/client_argv_handling.cc
        ${_cp}/client/crashpad_client_linux.cc
        ${_cp}/client/crash_report_database_generic.cc

        ${_cp}/util/file/file_io.cc
        ${_cp}/util/file/file_io_posix.cc
        ${_cp}/util/file/filesystem_posix.cc
        ${_cp}/util/file/directory_reader_posix.cc
        ${_cp}/util/file/scoped_remove_file.cc

        ${_cp}/util/misc/random_string.cc
        ${_cp}/util/misc/initialization_state_dcheck.cc

        ${_cp}/util/posix/signals.cc
        ${_cp}/util/posix/close_multiple.cc
        ${_cp}/util/posix/spawn_subprocess.cc
        ${_cp}/util/posix/scoped_mmap.cc
        ${_cp}/util/posix/scoped_dir.cc

        ${_cp}/util/linux/scoped_pr_set_dumpable.cc
        ${_cp}/util/linux/scoped_pr_set_ptracer.cc
        ${_cp}/util/linux/exception_handler_client.cc
        ${_cp}/util/linux/exception_handler_protocol.cc
        ${_cp}/util/linux/socket.cc
        ${_cp}/util/linux/ptrace_broker.cc
        ${_cp}/util/linux/ptracer.cc
        ${_cp}/util/linux/scoped_ptrace_attach.cc
        ${_cp}/util/linux/thread_info.cc

        ${_cp}/compat/linux/sys/mman_memfd_create.cc
    )
    set(_def -DCRASHPAD_LSS_SOURCE_EMBEDDED)
    list(APPEND _priv_inc ${_cp}/compat/linux)
    set(_link pthread dl)
    # inject linux-syscall-support
    file(MAKE_DIRECTORY "${_cp}/third_party/lss/lss")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/linux_syscall_support.h"
         DESTINATION "${_cp}/third_party/lss/lss")
elseif(WIN32)
    list(APPEND _src
        ${_mc}/base/synchronization/lock.cc
        ${_mc}/base/synchronization/lock_impl_win.cc
        ${_mc}/base/process/memory.cc
        ${_mc}/base/strings/string_util_win.cc
        ${_mc}/base/scoped_clear_last_error_win.cc
        ${_mc}/base/third_party/icu/icu_utf.cc

        ${_cp}/client/crashpad_client_win.cc
        ${_cp}/client/crash_report_database_win.cc

        ${_cp}/util/win/scoped_process_suspend.cc
        ${_cp}/util/win/registration_protocol_win.cc
        ${_cp}/util/win/nt_internals.cc
        ${_cp}/util/win/scoped_local_alloc.cc
        ${_cp}/util/win/process_info.cc
        ${_cp}/util/win/get_function.cc
        ${_cp}/util/win/ntstatus_logging.cc
        ${_cp}/util/win/handle.cc
        ${_cp}/util/win/loader_lock.cc
        ${_cp}/util/win/initial_client_data.cc
        ${_cp}/util/win/command_line.cc
        ${_cp}/util/win/scoped_handle.cc
        ${_cp}/util/win/critical_section_with_debug_info.cc

        ${_cp}/util/stdlib/aligned_allocator.cc
        ${_cp}/util/stdlib/string_number_conversion.cc
        ${_cp}/util/string/split_string.cc

        ${_cp}/util/file/file_io.cc
        ${_cp}/util/file/file_io_win.cc
        ${_cp}/util/file/filesystem_win.cc
        ${_cp}/util/file/directory_reader_win.cc
        ${_cp}/util/file/scoped_remove_file.cc

        ${_cp}/util/misc/random_string.cc
        ${_cp}/util/misc/initialization_state_dcheck.cc
        ${_cp}/util/misc/time_win.cc
    )
    if(CRASHPAD_CLIENT_ARCH STREQUAL "aarch64")
        # link crashpad's prebuilt arm64 capture-context object
        list(APPEND _src ${_cp}/util/misc/capture_context_win_arm64.obj)
    else()
        list(APPEND _src ${_cp}/util/misc/capture_context_win.asm)
        enable_language(ASM_MASM)
    endif()
    set(_def -DOS_WIN -DNOMINMAX -DUNICODE -DWIN32_LEAN_AND_MEAN -DWIN32)
    list(APPEND _priv_inc ${_cp}/compat/win)
elseif(APPLE)
    list(APPEND _src
        ${_mc}/base/files/scoped_file.cc
        ${_mc}/base/files/file_util_posix.cc
        ${_mc}/base/posix/safe_strerror.cc
        ${_mc}/base/apple/mach_logging.cc
        ${_mc}/base/apple/scoped_mach_port.cc
        ${_mc}/base/apple/scoped_nsautorelease_pool.mm
        ${_mc}/base/apple/scoped_mach_vm.cc
        ${_mc}/base/apple/foundation_util.mm
        ${_mc}/base/strings/string_number_conversions.cc
        ${_mc}/base/strings/sys_string_conversions_mac.mm
        ${_mc}/base/strings/strcat.cc

        ${_cp}/client/crashpad_client_mac.cc
        ${_cp}/client/crash_report_database_mac.mm

        ${_cp}/util/posix/spawn_subprocess.cc
        ${_cp}/util/posix/close_multiple.cc
        ${_cp}/util/posix/scoped_dir.cc

        ${_cp}/util/file/file_io.cc
        ${_cp}/util/file/file_io_posix.cc
        ${_cp}/util/file/scoped_remove_file.cc
        ${_cp}/util/file/filesystem_posix.cc
        ${_cp}/util/file/directory_reader_posix.cc

        ${_cp}/util/misc/clock_mac.cc
        ${_cp}/util/misc/clock_posix.cc
        ${_cp}/util/misc/initialization_state_dcheck.cc
        ${_cp}/util/misc/random_string.cc

        ${_cp}/util/mac/xattr.cc
        ${_cp}/util/mac/mac_util.cc
        ${_cp}/util/mac/sysctl.cc

        ${_cp}/util/mach/bootstrap.cc
        ${_cp}/util/mach/notify_server.cc
        ${_cp}/util/mach/mach_message.cc
        ${_cp}/util/mach/child_port_handshake.cc
        ${_cp}/util/mach/child_port_server.cc
        ${_cp}/util/mach/exception_ports.cc
        ${_cp}/util/mach/composite_mach_message_server.cc
        ${_cp}/util/mach/mach_message_server.cc
        ${_cp}/util/mach/mach_extensions.cc

        ${CRASHPAD_CLIENT_GEN}/util/mach/child_portServer.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/child_portUser.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/excServer.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/excUser.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/mach_excServer.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/mach_excUser.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/notifyServer.c
        ${CRASHPAD_CLIENT_GEN}/util/mach/notifyUser.c
    )
    list(APPEND _priv_inc ${CRASHPAD_CLIENT_GEN})
    find_library(ApplicationServicesLib ApplicationServices)
    find_library(CoreFoundationLib CoreFoundation)
    find_library(FoundationLib Foundation)
    find_library(IOKitLib IOKit)
    find_library(SecurityLib Security)
    set(_link
        ${ApplicationServicesLib} ${CoreFoundationLib} ${FoundationLib}
        ${SecurityLib} ${IOKitLib} pthread bsm
    )
endif()

add_library(gcrashpad STATIC ${_src})
# mini_chromium needs C++20 (concepts, span)
target_compile_features(gcrashpad PRIVATE cxx_std_20)
target_include_directories(gcrashpad PUBLIC ${_cp} ${_mc})
if(_priv_inc)
    target_include_directories(gcrashpad PRIVATE ${_priv_inc})
endif()

# GN sets this on all non-android/fuchsia platforms
target_compile_definitions(gcrashpad PRIVATE CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1)
target_compile_definitions(gcrashpad PRIVATE ${_def})
if(_link)
    target_link_libraries(gcrashpad PUBLIC ${_link})
endif()
set_target_properties(gcrashpad PROPERTIES UNITY_BUILD OFF POSITION_INDEPENDENT_CODE ON)
if(MSVC)
    target_compile_options(gcrashpad PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:ASM_MASM>>:/w>)
else()
    target_compile_options(gcrashpad PRIVATE -w)
endif()
