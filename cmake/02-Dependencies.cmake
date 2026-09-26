set(VERSION_wx_bgi "v2.8.44")

set(mArchiveType "tar.gz")
# Use proper string comparison in CMake; 'STREQUAL' compares strings correctly.
if(OS_NAME STREQUAL "windows")
    set(mArchiveType "zip")
endif()

message(STATUS "Fetching phoenix_gi static library...")
FetchContent_Declare(
    phoenix_gi
    URL "https://github.com/andromedabay/phoenix_gi/releases/download/${VERSION_wx_bgi}/pack_builtin_wxwidg-${OS_NAME}-latest.${mArchiveType}"
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(phoenix_gi)

# If requested, configure CMake to use the wxWidgets binaries included inside
# the phoenix_gi package instead of locating a system-wide wxWidgets.
if(WXBGI_USE_BUILTIN_WX)
    message(STATUS "Configuring to use wxWidgets bundled in phoenix_gi package")
    set(_phoenix_lib_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/lib")
    set(_phoenix_include_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src")
    set(_wxwidgets_config_dir
        "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/wxWidgets/lib/cmake/wxWidgets-3.3")
    if(NOT EXISTS "${_wxwidgets_config_dir}/wxWidgetsConfig.cmake")
        message(FATAL_ERROR
            "Bundled wxWidgets CMake package was not found at ${_wxwidgets_config_dir}")
    endif()
    find_package(OpenGL REQUIRED)
    find_package(wxWidgets CONFIG REQUIRED COMPONENTS mono
        PATHS "${_wxwidgets_config_dir}" NO_DEFAULT_PATH)
    if(NOT TARGET wx::mono)
        message(FATAL_ERROR "Bundled wxWidgets package did not provide the wx::mono target")
    endif()
    set(wxWidgets_INCLUDE_DIRS "${_phoenix_include_dir}")
    set(wxWidgets_LIBRARIES wx::mono)

    if(WIN32)
        set(_phoenix_wx_wrapper "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/wx_bgi_wx.lib")
        set(_phoenix_glew_lib "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/glew_static.lib")
        foreach(_required_file IN ITEMS "${_phoenix_wx_wrapper}" "${_phoenix_glew_lib}")
            if(NOT EXISTS "${_required_file}")
                message(FATAL_ERROR "Required bundled phoenix_gi dependency is missing: ${_required_file}")
            endif()
        endforeach()

        add_library(phoenix_gi::wx_wrapper UNKNOWN IMPORTED)
        set_target_properties(phoenix_gi::wx_wrapper PROPERTIES
            IMPORTED_LOCATION "${_phoenix_wx_wrapper}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
        )

        add_library(phoenix_gi::glew UNKNOWN IMPORTED)
        set_target_properties(phoenix_gi::glew PROPERTIES
            IMPORTED_LOCATION "${_phoenix_glew_lib}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
            INTERFACE_COMPILE_DEFINITIONS GLEW_STATIC
        )
    endif()
endif()

# Create a phoenix_gi imported target if the package provides an import library.
set(_phoenix_implib "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/phoenix_gi.lib")
set(_phoenix_dll "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/phoenix_gi.dll")
if(EXISTS "${_phoenix_implib}" AND EXISTS "${_phoenix_dll}")
    # Create a SHARED imported target with both IMPORTED_IMPLIB and IMPORTED_LOCATION
    add_library(phoenix_gi::phoenix SHARED IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_IMPLIB "${_phoenix_implib}"
        IMPORTED_LOCATION "${_phoenix_dll}"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
    )
    message(STATUS "Created SHARED imported target phoenix_gi::phoenix -> implib=${_phoenix_implib} dll=${_phoenix_dll}")
elseif(EXISTS "${_phoenix_implib}")
    add_library(phoenix_gi::phoenix UNKNOWN IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_LOCATION "${_phoenix_implib}"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
    )
    message(STATUS "Created imported target phoenix_gi::phoenix -> ${_phoenix_implib}")
elseif(EXISTS "${_phoenix_lib_dir}/phoenix_gi.lib")
    add_library(phoenix_gi::phoenix UNKNOWN IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_LOCATION "${_phoenix_lib_dir}/phoenix_gi.lib"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
    )
    message(STATUS "Created imported target phoenix_gi::phoenix -> ${_phoenix_lib_dir}/phoenix_gi.lib")
else()
    message(STATUS "No phoenix_gi import library found to create phoenix_gi::phoenix imported target")
endif()

set(PHOENIX_GI_HEADERS_ARCHIVE
    "${phoenix_gi_SOURCE_DIR}/wx_bgi_headers.${mArchiveType}")
set(PHOENIX_GI_HEADERS_DIR
    "${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src")

file(MAKE_DIRECTORY "${PHOENIX_GI_HEADERS_DIR}")
if(mArchiveType STREQUAL "zip")
    # On Windows the archive is a zip file; use PowerShell Expand-Archive to extract reliably.
    execute_process(
        COMMAND powershell -NoProfile -Command Expand-Archive -Force -Path "${PHOENIX_GI_HEADERS_ARCHIVE}" -DestinationPath "${PHOENIX_GI_HEADERS_DIR}"
        RESULT_VARIABLE PHOENIX_GI_HEADERS_RESULT
    )
else()
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${PHOENIX_GI_HEADERS_ARCHIVE}"
        WORKING_DIRECTORY "${PHOENIX_GI_HEADERS_DIR}"
        RESULT_VARIABLE PHOENIX_GI_HEADERS_RESULT
    )
endif()
if(NOT PHOENIX_GI_HEADERS_RESULT EQUAL 0)
    message(FATAL_ERROR
        "Failed to extract phoenix_gi headers from ${PHOENIX_GI_HEADERS_ARCHIVE}")
endif()

