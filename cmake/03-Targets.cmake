# cblit_cad target definitions

add_executable(cblit_cad_app
    src/main.cpp
)

target_include_directories(cblit_cad_app PRIVATE
    ${WXBGI_GRAPHICS_INCLUDE_DIRS}
)

target_link_libraries(cblit_cad_app PRIVATE
    ${WXBGI_GRAPHICS_LIBS}
    ${wxWidgets_LIBRARIES}
)
target_link_options(cblit_cad_app PRIVATE)
target_compile_features(cblit_cad_app PRIVATE cxx_std_20)
target_compile_options(cblit_cad_app PRIVATE -Wall -Wextra -Wpedantic)

set_target_properties(cblit_cad_app PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

message(STATUS "Checking if RPATH is defined for cblit_cad_app...")
if(DEFINED WXBGI_APP_RPATH AND UNIX)
    message(STATUS "Setting rpath for cblit_cad_app to ${WXBGI_APP_RPATH}")
    target_link_options(cblit_cad_app PRIVATE "-Wl,-rpath,${WXBGI_APP_RPATH}")
    add_custom_command(TARGET cblit_cad_app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${WXBGI_OPENGL_LIB}"
            "$<TARGET_FILE_DIR:cblit_cad_app>"
    )
endif()
message(STATUS "Completed.")
