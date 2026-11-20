# ==========================================================================
#  GroundClean 1.1.3 - build definition.
#
#  MSVC:  cmake -S . -B build -A Win32        (or -A x64)
#  MinGW: cmake -S . -B build -G "MinGW Makefiles"
# ==========================================================================

cmake_minimum_required(VERSION 3.16)

project(groundclean
        VERSION 1.1.3
        DESCRIPTION "Win32/Grenam (Ground.exe) remediation tool"
        LANGUAGES C)

enable_language(RC OPTIONAL)

if(NOT WIN32)
    message(FATAL_ERROR "GroundClean targets Windows only.")
endif()

# --------------------------------------------------------------------------
#  Options
# --------------------------------------------------------------------------
option(GC_STATIC_RUNTIME "Link the C runtime statically" ON)
option(GC_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
option(GC_BUILD_TESTS "Build the smoke-test target" OFF)

# --------------------------------------------------------------------------
#  Compiler-independent settings
# --------------------------------------------------------------------------
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

if(MSVC)
    # Static CRT keeps the single .exe deployable on a bare Windows 7 SP1 box.
    if(GC_STATIC_RUNTIME)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    endif()
endif()

# --------------------------------------------------------------------------
#  Sources
# --------------------------------------------------------------------------
set(GC_SOURCES
    src/main.c
    src/gc_common.c
    src/gc_log.c
    src/gc_priv.c
    src/gc_pe.c
    src/gc_proc.c
    src/gc_quarantine.c
    src/gc_remediate.c
    src/gc_reg.c
    src/gc_startup.c
    src/gc_autorun.c
    src/gc_scan.c
    src/gc_cli.c
)

set(GC_HEADERS
    include/gc_types.h
    include/gc_common.h
    include/gc_log.h
    include/gc_priv.h
    include/gc_pe.h
    include/gc_proc.h
    include/gc_quarantine.h
    include/gc_remediate.h
    include/gc_reg.h
    include/gc_startup.h
    include/gc_autorun.h
    include/gc_scan.h
    include/gc_cli.h
)

set(GC_RESOURCES
    res/groundclean.rc
    res/groundclean.manifest
    res/version.h
)

add_executable(groundclean ${GC_SOURCES} ${GC_HEADERS} ${GC_RESOURCES})

set_target_properties(groundclean PROPERTIES
    OUTPUT_NAME "GroundClean"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

target_include_directories(groundclean PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_compile_definitions(groundclean PRIVATE
    WIN32_LEAN_AND_MEAN
    _WIN32_WINNT=0x0601
    WINVER=0x0601)

target_link_libraries(groundclean PRIVATE
    shlwapi shell32 advapi32 ole32 oleaut32 uuid user32)

# --------------------------------------------------------------------------
#  Warnings
# --------------------------------------------------------------------------
if(MSVC)
    target_compile_options(groundclean PRIVATE /W4 /permissive- /utf-8)
    if(GC_WARNINGS_AS_ERRORS)
        target_compile_options(groundclean PRIVATE /WX)
    endif()
    # The .rc already carries the manifest; stop the linker adding a second.
    target_link_options(groundclean PRIVATE /MANIFEST:NO)
    set_property(TARGET groundclean PROPERTY
                 VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
else()
    target_compile_options(groundclean PRIVATE
        -Wall -Wextra -Wshadow -Wstrict-prototypes -Wmissing-prototypes)
    if(GC_WARNINGS_AS_ERRORS)
        target_compile_options(groundclean PRIVATE -Werror)
    endif()
    target_link_options(groundclean PRIVATE -Wl,--subsystem,console)
endif()

# --------------------------------------------------------------------------
#  Install
# --------------------------------------------------------------------------
include(GNUInstallDirs)
install(TARGETS groundclean RUNTIME DESTINATION .)

# --------------------------------------------------------------------------
#  Smoke test: dry-run against the C: root, expecting exit code 0 or 1.
# --------------------------------------------------------------------------
if(GC_BUILD_TESTS)
    enable_testing()
    add_test(NAME dryrun_smoke
             COMMAND groundclean --dry-run --drives=C --no-kill
                     --log=${CMAKE_BINARY_DIR}/smoke.log)
    set_tests_properties(dryrun_smoke PROPERTIES
        PASS_REGULAR_EXPRESSION "SUMMARY")
endif()

message(STATUS "GroundClean ${PROJECT_VERSION} configured")
message(STATUS "  static runtime : ${GC_STATIC_RUNTIME}")
message(STATUS "  output         : ${CMAKE_BINARY_DIR}/bin/GroundClean.exe")