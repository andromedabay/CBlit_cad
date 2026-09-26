cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(POLICY CMP0091)
	cmake_policy(SET CMP0091 NEW)
endif()

project(cblit_cad LANGUAGES C CXX)

set(VERSION_wx_bgi "v2.8.44")

# Option to use the wxWidgets binary bundled inside the phoenix_gi package
# Enable using the wxWidgets binary bundled with the phoenix_gi package by default.
# This sets the option default to ON and forces the cache variable so configurations
# started from IDE or CLI will pick it up persistently. Remove the 'FORCE' or
# change this to OFF if you want to allow overriding via -DWXBGI_USE_BUILTIN_WX.
option(WXBGI_USE_BUILTIN_WX "Use wxWidgets bundled with phoenix_gi instead of system wxWidgets" ON)

# Ensure the cache variable is set to ON so existing build trees pick up the change.
set(WXBGI_USE_BUILTIN_WX ON CACHE BOOL "Use wxWidgets bundled with phoenix_gi instead of system wxWidgets" FORCE)

include(cmake/01-ProjectOptions.cmake)

message(STATUS "Using FetchContent dependencies for phoenix_gi")
include(cmake/02-Dependencies.cmake)

if(NOT WXBGI_USE_BUILTIN_WX)
	find_package(wxWidgets REQUIRED COMPONENTS core base)
	include(${wxWidgets_USE_FILE})
else()
	message(STATUS "Skipping system wxWidgets find; using bundled copy from phoenix_gi")
endif()

set(_phoenix_lib_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/lib")

# Find the platform-appropriate phoenix_gi library to link against and the
# runtime library file to copy next to the executable when required.
set(WXBGI_GRAPHICS_LIBS "")
set(WXBGI_GRAPHICS_RUNTIME "")

if(WIN32)
	# On Windows require the specific phoenix_gi import library and DLL
	set(_phoenix_bin_dir "${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/bin")

	set(_candidate_imports
		"${_phoenix_lib_dir}/phoenix_gi.lib"
		"${_phoenix_bin_dir}/phoenix_gi.lib"
	)
	set(_candidate_dlls
		"${_phoenix_bin_dir}/phoenix_gi.dll"
		"${_phoenix_lib_dir}/phoenix_gi.dll"
	)

	foreach(p IN LISTS _candidate_imports)
		if(EXISTS "${p}")
			set(WXBGI_GRAPHICS_LIBS "${p}")
			break()
		endif()
	endforeach()

	foreach(d IN LISTS _candidate_dlls)
		if(EXISTS "${d}")
			set(WXBGI_GRAPHICS_RUNTIME "${d}")
			break()
		endif()
	endforeach()

	if(WXBGI_GRAPHICS_LIBS)
		message(STATUS "Found phoenix_gi import lib: ${WXBGI_GRAPHICS_LIBS}")
	else()
		message(STATUS "phoenix_gi import lib not found in expected locations")
	endif()

	if(WXBGI_GRAPHICS_RUNTIME)
		message(STATUS "Found phoenix_gi runtime DLL: ${WXBGI_GRAPHICS_RUNTIME}")
	else()
		message(STATUS "phoenix_gi runtime DLL not found in expected locations")
	endif()
elseif(APPLE)
	# Require specific macOS filename: libphoenix_gi.dylib (or static lib libphoenix_gi.a)
	set(_candidate_mac
		"${_phoenix_lib_dir}/libphoenix_gi.dylib"
		"${_phoenix_lib_dir}/libphoenix_gi.a"
	)
	foreach(p IN LISTS _candidate_mac)
		if(EXISTS "${p}")
			set(WXBGI_GRAPHICS_LIBS "${p}")
			set(WXBGI_GRAPHICS_RUNTIME "${p}")
			break()
		endif()
	endforeach()

	if(WXBGI_GRAPHICS_LIBS)
		message(STATUS "Found phoenix_gi macOS library: ${WXBGI_GRAPHICS_LIBS}")
	else()
		message(STATUS "phoenix_gi macOS library not found in ${_phoenix_lib_dir}")
	endif()
else()
	# Linux: require libphoenix_gi.so (shared) or libphoenix_gi.a (static)
	set(_candidate_linux
		"${_phoenix_lib_dir}/libphoenix_gi.so"
		"${_phoenix_lib_dir}/libphoenix_gi.a"
	)
	foreach(p IN LISTS _candidate_linux)
		if(EXISTS "${p}")
			set(WXBGI_GRAPHICS_LIBS "${p}")
			set(WXBGI_GRAPHICS_RUNTIME "${p}")
			break()
		endif()
	endforeach()

	if(WXBGI_GRAPHICS_LIBS)
		message(STATUS "Found phoenix_gi linux library: ${WXBGI_GRAPHICS_LIBS}")
	else()
		message(STATUS "phoenix_gi linux library not found in ${_phoenix_lib_dir}")
	endif()
endif()

# Require platform-specific files; fail early if missing when using bundled wx
if(WXBGI_USE_BUILTIN_WX AND NOT WXBGI_GRAPHICS_LIBS)
	message(FATAL_ERROR "Required phoenix_gi library not found in ${_phoenix_lib_dir}.\nExpected filenames per-platform:\n  Windows: phoenix_gi.lib (and phoenix_gi.dll)\n  macOS: libphoenix_gi.dylib or libphoenix_gi.a\n  Linux: libphoenix_gi.so or libphoenix_gi.a\nPlease provide the appropriate artifact in the phoenix_gi package or disable WXBGI_USE_BUILTIN_WX.")
endif()

set(WXBGI_GRAPHICS_INCLUDE_DIRS
	${wxWidgets_INCLUDE_DIRS}
	${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src
)
include(cmake/03-Targets.cmake)
