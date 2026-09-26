FetchContent_Declare(
    phoenix_gi
    URL "https://github.com/andromedabay/phoenix_gi/releases/download/${PHOENIX_GI_VERSION}/pack_builtin_wxwidg-${OS_NAME}-latest.${WXBGI_PACKAGE_ARCHIVE_EXTENSION}"
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(phoenix_gi)

set(_phoenix_root "${phoenix_gi_SOURCE_DIR}")
set(_phoenix_headers "${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src")
set(_wxwidgets_package_dir "${_phoenix_root}/wxWidgets/lib/cmake")
file(GLOB _wxwidgets_configs
    "${_wxwidgets_package_dir}/wxWidgets-*/wxWidgetsConfig.cmake")
list(LENGTH _wxwidgets_configs _wxwidgets_config_count)
if(NOT _wxwidgets_config_count EQUAL 1)
    message(FATAL_ERROR
        "Expected one bundled wxWidgets CMake package under ${_wxwidgets_package_dir}; found ${_wxwidgets_config_count}")
endif()
list(GET _wxwidgets_configs 0 _wxwidgets_config)
get_filename_component(_wxwidgets_config_dir "${_wxwidgets_config}" DIRECTORY)

find_package(OpenGL REQUIRED)
find_package(wxWidgets CONFIG REQUIRED COMPONENTS mono
    PATHS "${_wxwidgets_config_dir}" NO_DEFAULT_PATH)

if(WIN32)
    add_library(phoenix_gi::wx_wrapper UNKNOWN IMPORTED)
    set_target_properties(phoenix_gi::wx_wrapper PROPERTIES
        IMPORTED_LOCATION "${_phoenix_root}/bin/wx_bgi_wx.lib")

    add_library(phoenix_gi::glew UNKNOWN IMPORTED)
    set_target_properties(phoenix_gi::glew PROPERTIES
        IMPORTED_LOCATION "${_phoenix_root}/bin/glew_static.lib"
        INTERFACE_COMPILE_DEFINITIONS GLEW_STATIC)
endif()

if(WIN32)
    add_library(phoenix_gi::phoenix SHARED IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_IMPLIB "${_phoenix_root}/bin/phoenix_gi.lib"
        IMPORTED_LOCATION "${_phoenix_root}/bin/phoenix_gi.dll"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_headers}")
elseif(APPLE)
    add_library(phoenix_gi::phoenix SHARED IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_LOCATION "${_phoenix_root}/lib/phoenix_gi.dylib"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_headers}")
else()
    add_library(phoenix_gi::phoenix SHARED IMPORTED)
    set_target_properties(phoenix_gi::phoenix PROPERTIES
        IMPORTED_LOCATION "${_phoenix_root}/lib/phoenix_gi.so"
        INTERFACE_INCLUDE_DIRECTORIES "${_phoenix_headers}")
endif()

set(WXBGI_GRAPHICS_INCLUDE_DIRS "${_phoenix_headers}")
set(WXBGI_GRAPHICS_RUNTIME "$<TARGET_FILE:phoenix_gi::phoenix>")
if(TARGET wx::mono)
    set(WXBGI_WX_RUNTIME "$<TARGET_FILE:wx::mono>")
endif()

set(PHOENIX_GI_HEADERS_ARCHIVE
    "${_phoenix_root}/wx_bgi_headers.${WXBGI_PACKAGE_ARCHIVE_EXTENSION}")
file(MAKE_DIRECTORY "${_phoenix_headers}")
file(ARCHIVE_EXTRACT
    INPUT "${PHOENIX_GI_HEADERS_ARCHIVE}"
    DESTINATION "${_phoenix_headers}")

