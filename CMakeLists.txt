cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

if(POLICY CMP0091)
	cmake_policy(SET CMP0091 NEW)
endif()

project(cblit_cad LANGUAGES C CXX)

set(PHOENIX_GI_VERSION "v2.8.44")

include(cmake/01-ProjectOptions.cmake)
include(cmake/02-Dependencies.cmake)
include(cmake/03-Targets.cmake)
