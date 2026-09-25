cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(cblit_cad LANGUAGES C CXX)

set(VERSION_wx_bgi "v2.7.6")

include(cmake/01-ProjectOptions.cmake)

message(STATUS "Using FetchContent dependencies for pheonix_gi")
include(cmake/02-Dependencies.cmake)

find_package(wxWidgets REQUIRED COMPONENTS core base)
include(${wxWidgets_USE_FILE})

set(WXBGI_GRAPHICS_LIBS ${FETCHCONTENT_BASE_DIR}/phoenix_gi-src/lib/phoenix_gi.so)
set(WXBGI_GRAPHICS_INCLUDE_DIRS
	${wxWidgets_INCLUDE_DIRS}
	${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src
)
include(cmake/03-Targets.cmake)
