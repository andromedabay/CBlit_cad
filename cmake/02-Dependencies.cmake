set(VERSION_wx_bgi "v2.8.41")

set(mArchiveType "tar.gz")
# Use proper string comparison in CMake; 'STREQUAL' compares strings correctly.
if(OS_NAME STREQUAL "windows")
    set(mArchiveType "zip")
endif()

message(STATUS "Fetching phoenix_gi static library...")
FetchContent_Declare(
    phoenix_gi
    URL "https://github.com/andromedabay/phoenix_gi/releases/download/${VERSION_wx_bgi}/pack_builtin_wxwidg-${OS_NAME}-latest.${mArchiveType}"
)
FetchContent_MakeAvailable(phoenix_gi)

# If requested, configure CMake to use the wxWidgets binaries included inside
# the phoenix_gi package instead of locating a system-wide wxWidgets.
if(WXBGI_USE_BUILTIN_WX)
    message(STATUS "Configuring to use wxWidgets bundled in phoenix_gi package")
    set(_phoenix_lib_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/lib")
    set(_phoenix_include_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src")

    # Try to locate core/base wxWidgets libraries inside the package.
    if(WIN32)
        file(GLOB WXBGI_WX_CORE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_core*.lib"
            "${_phoenix_lib_dir}/*wx_core*.lib"
            "${_phoenix_lib_dir}/*wx*.lib"
        )
        file(GLOB WXBGI_WX_BASE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_base*.lib"
            "${_phoenix_lib_dir}/*wx_base*.lib"
            "${_phoenix_lib_dir}/*wx*.lib"
        )
    elseif(APPLE)
        file(GLOB WXBGI_WX_CORE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_core*.dylib"
            "${_phoenix_lib_dir}/*wx_core*.dylib"
            "${_phoenix_lib_dir}/*.a"
        )
        file(GLOB WXBGI_WX_BASE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_base*.dylib"
            "${_phoenix_lib_dir}/*wx_base*.dylib"
            "${_phoenix_lib_dir}/*.a"
        )
    else()
        file(GLOB WXBGI_WX_CORE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_core*.so"
            "${_phoenix_lib_dir}/*wx_core*.so"
            "${_phoenix_lib_dir}/*.a"
            "${_phoenix_lib_dir}/*.so"
        )
        file(GLOB WXBGI_WX_BASE_CANDIDATES
            "${_phoenix_lib_dir}/*wx*_base*.so"
            "${_phoenix_lib_dir}/*wx_base*.so"
            "${_phoenix_lib_dir}/*.a"
            "${_phoenix_lib_dir}/*.so"
        )
    endif()

    # Safely pick the first candidate from each glob list if any were found.
    if(WXBGI_WX_CORE_CANDIDATES)
        list(GET WXBGI_WX_CORE_CANDIDATES 0 WXBGI_WX_CORE_LIB)
    else()
        set(WXBGI_WX_CORE_LIB "")
    endif()

    if(WXBGI_WX_BASE_CANDIDATES)
        list(GET WXBGI_WX_BASE_CANDIDATES 0 WXBGI_WX_BASE_LIB)
    else()
        set(WXBGI_WX_BASE_LIB "")
    endif()

    if(WXBGI_WX_CORE_LIB AND WXBGI_WX_BASE_LIB)
        message(STATUS "Found bundled wxWidgets core: ${WXBGI_WX_CORE_LIB}")
        message(STATUS "Found bundled wxWidgets base: ${WXBGI_WX_BASE_LIB}")

        # Create imported targets so consumers can link to modern target names.
        add_library(wx::core UNKNOWN IMPORTED)
        set_target_properties(wx::core PROPERTIES
            IMPORTED_LOCATION "${WXBGI_WX_CORE_LIB}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
        )

        add_library(wx::base UNKNOWN IMPORTED)
        set_target_properties(wx::base PROPERTIES
            IMPORTED_LOCATION "${WXBGI_WX_BASE_LIB}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
        )

        # For compatibility with older code that reads wxWidgets_* variables,
        # expose the include dir and libraries list as well.
        set(wxWidgets_FOUND TRUE)
        set(wxWidgets_INCLUDE_DIRS "${_phoenix_include_dir}")
        set(wxWidgets_LIBRARIES wx::core wx::base)

        # Avoid attempts to include a non-existent wxWidgets use file
        unset(wxWidgets_USE_FILE CACHE)
    else()
        message(WARNING "WXBGI_USE_BUILTIN_WX was requested but could not locate wx core/base libraries in: ${_phoenix_lib_dir}")
    endif()
endif()

# Create a phoenix_gi imported target if the package provides an import library.
set(_phoenix_implib "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/phoenix_gi.lib")
set(_phoenix_dll "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/lib/phoenix_gi.dll")
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

# If the package provides a combined wx wrapper import library (wx_bgi_wx.lib),
# create wx::core and wx::base imported targets pointing to it so consumer code
# can link to wx::core/wx::base.
set(_wx_bgi_lib "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin/wx_bgi_wx.lib")
if(EXISTS "${_wx_bgi_lib}")
    if(NOT TARGET wx::core)
        add_library(wx::core UNKNOWN IMPORTED)
        set_target_properties(wx::core PROPERTIES
            IMPORTED_LOCATION "${_wx_bgi_lib}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
        )
    endif()
    if(NOT TARGET wx::base)
        add_library(wx::base UNKNOWN IMPORTED)
        set_target_properties(wx::base PROPERTIES
            IMPORTED_LOCATION "${_wx_bgi_lib}"
            INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_include_dir}"
        )
    endif()
    message(STATUS "Created imported wx::core and wx::base pointing to ${_wx_bgi_lib}")
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

