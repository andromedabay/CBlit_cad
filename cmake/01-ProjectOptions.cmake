# Project-wide options and core CMake configuration.

set (OS_NAME "")
if(WIN32)
    set(OS_NAME "windows")
elseif(APPLE)
    set(OS_NAME "macos")
elseif(UNIX)
    set(OS_NAME "ubuntu")
else()
    message(FATAL_ERROR "Unsupported OS")
endif()

if(APPLE)
    enable_language(OBJCXX)
endif()

include(CTest)
include(FetchContent)
set(FETCHCONTENT_BASE_DIR ${CMAKE_BINARY_DIR}/_deps_fc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# Use static MSVC runtime on Windows (/MT or /MTd) so the binary
# has no dependency on the MSVC Redistributable.
if(MSVC)
    # Use the DLL version of the MSVC runtime to match prebuilt phoenix_gi
    # binaries which are typically built against the dynamic CRT (MD/MDd).
    # Change to MultiThreaded (static) if you rebuild phoenix_gi with /MT.
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

# ---------------------------------------------------------------------------
# Backend options
# ---------------------------------------------------------------------------

# Make wxWidgets the default window backend.
option(WXBGI_ENABLE_WX
    "Build with wxWidgets window backend (default: ON; fetches wxWidgets 3.2.5)"
    ON)
set(wxBUILD_SHARED OFF)