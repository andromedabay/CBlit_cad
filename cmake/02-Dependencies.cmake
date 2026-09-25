set(VERSION_wx_bgi "v2.8.41")

message(STATUS "Fetching phoenix_gi static library...")
FetchContent_Declare(
    phoenix_gi
    URL "https://github.com/andromedabay/phoenix_gi/releases/download/${VERSION_wx_bgi}/pack_builtin_wxwidg-${OS_NAME}-latest.tar.gz"
)
FetchContent_MakeAvailable(phoenix_gi)

set(PHOENIX_GI_HEADERS_ARCHIVE
    "${phoenix_gi_SOURCE_DIR}/wx_bgi_headers.tar.gz")
set(PHOENIX_GI_HEADERS_DIR
    "${FETCHCONTENT_BASE_DIR}/phoenix_gi_headers-src")

file(MAKE_DIRECTORY "${PHOENIX_GI_HEADERS_DIR}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${PHOENIX_GI_HEADERS_ARCHIVE}"
    WORKING_DIRECTORY "${PHOENIX_GI_HEADERS_DIR}"
    RESULT_VARIABLE PHOENIX_GI_HEADERS_RESULT
)
if(NOT PHOENIX_GI_HEADERS_RESULT EQUAL 0)
    message(FATAL_ERROR
        "Failed to extract phoenix_gi headers from ${PHOENIX_GI_HEADERS_ARCHIVE}")
endif()

