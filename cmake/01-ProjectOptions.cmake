# Platform and compiler configuration for the Phoenix GI sample.

set (OS_NAME "")
if(WIN32)
    set(OS_NAME "windows")
    set(WXBGI_PACKAGE_ARCHIVE_EXTENSION "zip")
elseif(APPLE)
    set(OS_NAME "macos")
    set(WXBGI_PACKAGE_ARCHIVE_EXTENSION "tar.gz")
elseif(UNIX)
    set(OS_NAME "ubuntu")
    set(WXBGI_PACKAGE_ARCHIVE_EXTENSION "tar.gz")
else()
    message(FATAL_ERROR "Unsupported OS")
endif()

include(FetchContent)
set(FETCHCONTENT_BASE_DIR "${CMAKE_BINARY_DIR}/_deps_fc")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# Match the dynamic MSVC runtime used by the prebuilt Phoenix and wxWidgets DLLs.
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()