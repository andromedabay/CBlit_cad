# cblit_cad target definitions

if(APPLE)
    add_executable(CBlit_cad MACOSX_BUNDLE
        src/main.cpp
    )
elseif(WIN32)
    add_executable(CBlit_cad WIN32
        src/main.cpp
    )
else()
    add_executable(CBlit_cad
        src/main.cpp
    )
endif()

## Mark bundled/third-party headers as SYSTEM to suppress warnings from them
## so they are not elevated to errors when /WX is used for project code.
target_include_directories(CBlit_cad SYSTEM PRIVATE
    ${WXBGI_GRAPHICS_INCLUDE_DIRS}
)

target_link_libraries(CBlit_cad PRIVATE
)

# Prefer imported targets when available (phoenix_gi::phoenix, wx::core/wx::base).
if(TARGET phoenix_gi::phoenix)
    target_link_libraries(CBlit_cad PRIVATE phoenix_gi::phoenix)
elseif(WXBGI_GRAPHICS_LIBS)
    target_link_libraries(CBlit_cad PRIVATE ${WXBGI_GRAPHICS_LIBS})
endif()

if(TARGET wx::mono)
    target_link_libraries(CBlit_cad PRIVATE wx::mono)
    if(TARGET phoenix_gi::wx_wrapper)
        target_link_libraries(CBlit_cad PRIVATE
            phoenix_gi::wx_wrapper
            phoenix_gi::glew
            OpenGL::GL
        )
    endif()
elseif(wxWidgets_LIBRARIES)
    target_link_libraries(CBlit_cad PRIVATE ${wxWidgets_LIBRARIES})
endif()

target_link_options(CBlit_cad PRIVATE)
target_compile_features(CBlit_cad PRIVATE cxx_std_20)
if(MSVC AND WXBGI_USE_BUILTIN_WX)
    set_property(TARGET CBlit_cad PROPERTY MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
    target_compile_definitions(CBlit_cad PRIVATE
        "$<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=0>"
    )
endif()
# Use MSVC-specific warning flags on Windows, otherwise use GCC/Clang flags.
if(MSVC)
    # Use /W4 warning level on MSVC; /WX treats warnings as errors.
    # External headers are marked SYSTEM; additionally use /external:W0 to
    # silence warnings coming from external includes so they are not promoted
    # to errors by /WX.
    # Use /W4 and /WX for project code and /external:W0 to silence warnings
    # from external headers. Do not try to suppress driver-level D9025 via
    # /wd (invalid), avoid masking configuration issues instead.
    target_compile_options(CBlit_cad PRIVATE /W4 /WX /external:W0)
else()
    target_compile_options(CBlit_cad PRIVATE -Wall -Wextra -Wpedantic)
endif()

set_target_properties(CBlit_cad PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# If phoenix_gi ships a runtime library (DLL/dylib/so), copy it next to the
# executable so it can be found at runtime. WXBGI_GRAPHICS_RUNTIME is set by
# the top-level CMakeLists when the FetchContent package provides platform
# specific artifacts.
if(WXBGI_GRAPHICS_RUNTIME)
    add_custom_command(TARGET CBlit_cad POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${WXBGI_GRAPHICS_RUNTIME}"
            "$<TARGET_FILE_DIR:CBlit_cad>"
    )
endif()

if(TARGET wx::mono AND WXBGI_USE_BUILTIN_WX)
    add_custom_command(TARGET CBlit_cad POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:wx::mono>"
            "$<TARGET_FILE_DIR:CBlit_cad>"
        VERBATIM
    )
endif()

message(STATUS "Checking if RPATH is defined for CBlit_cad...")
if(DEFINED WXBGI_APP_RPATH AND UNIX)
    message(STATUS "Setting rpath for CBlit_cad to ${WXBGI_APP_RPATH}")
    target_link_options(CBlit_cad PRIVATE "-Wl,-rpath,${WXBGI_APP_RPATH}")
    add_custom_command(TARGET CBlit_cad POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${WXBGI_OPENGL_LIB}"
            "$<TARGET_FILE_DIR:CBlit_cad>"
    )
endif()
message(STATUS "Completed.")
