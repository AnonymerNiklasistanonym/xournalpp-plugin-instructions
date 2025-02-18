cmake_minimum_required(VERSION 3.22.1)
project(ExampleHighQualityVector)

# Options
set(CMAKE_INSTALL_PREFIX_PLUGIN ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME})
set(CMAKE_INSTALL_PREFIX_ICONS "" CACHE PATH "Installation path for icons")

# Global variables
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(PLUGIN_DIR ${CMAKE_CURRENT_SOURCE_DIR}/plugin)
message(STATUS "SRC_DIR: ${SRC_DIR}")
message(STATUS "HEADER_DIR: ${HEADER_DIR}")
message(STATUS "PLUGIN_DIR: ${PLUGIN_DIR}")

if(UNIX AND NOT APPLE)
    # For dynamic libraries enabling a -fPIC (Position-Independent Code) flag is
    # required when compiling code into shared libraries
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# Find necessary dependencies
# > Same Lua version as the current xournal++ project
find_package(Lua 5.4 REQUIRED)
message(STATUS "LUA_INCLUDE_DIR: ${LUA_INCLUDE_DIR}")
message(STATUS "LUA_LIBRARIES: ${LUA_LIBRARIES}")
# > LibrSVG, Cairo
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBRSVG REQUIRED librsvg-2.0)
pkg_check_modules(CAIRO REQUIRED cairo)

# Register local sources
file(GLOB_RECURSE SRC_FILES ${SRC_DIR}/*.cpp)
message(STATUS "SRC_FILES: ${SRC_FILES}")

# Create shared library
add_library(${PROJECT_NAME} SHARED ${SRC_FILES})
# > Add C++20 flag to use std::filesystem
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)
# > Add all header files
target_include_directories(${PROJECT_NAME} PRIVATE ${HEADER_DIR})
# > Link with Lua
target_link_libraries(${PROJECT_NAME} PRIVATE ${LUA_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${LUA_INCLUDE_DIR})
# > Link with LibrSVG, Cairo
target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE ${LIBRSVG_LIBRARIES} ${CAIRO_LIBRARIES}
)
target_include_directories(
    ${PROJECT_NAME}
    PRIVATE ${LIBRSVG_INCLUDE_DIRS} ${CAIRO_INCLUDE_DIRS}
)

# Install
install(
    TARGETS ${PROJECT_NAME}
    RUNTIME
        DESTINATION
            ${CMAKE_INSTALL_PREFIX_PLUGIN} # For executables and DLLs
    LIBRARY
        DESTINATION
            ${CMAKE_INSTALL_PREFIX_PLUGIN} # For shared libraries (.so, .dylib)
)
# > Copy plugin directory files to the install prefix
install(
    DIRECTORY ${PLUGIN_DIR}/
    DESTINATION ${CMAKE_INSTALL_PREFIX_PLUGIN}
    FILES_MATCHING
    PATTERN "*"
)
# > Copy icon files directory to the install prefix for icons
if(CMAKE_INSTALL_PREFIX_ICONS)
    install(
        DIRECTORY ${PLUGIN_DIR}/
        DESTINATION ${CMAKE_INSTALL_PREFIX_ICONS}
        FILES_MATCHING
        PATTERN "*.svg"
    )
endif()

# If cross compiling to Windows distribute library dependent DLLs
if(CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
    # > Copy MinGW DLLs that this project depends on
    set(MINGW_SHARED_LIBRARIES_DIR ${CMAKE_CURRENT_BINARY_DIR}/lib_mingw)
    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${MINGW_SHARED_LIBRARIES_DIR}
        COMMAND
            ldd ${CMAKE_CURRENT_BINARY_DIR}/lib${PROJECT_NAME}.dll | grep
            mingw64 | awk "{ print \$3 }" | xargs -I {} cp {}
            ${MINGW_SHARED_LIBRARIES_DIR}
        COMMENT "Copying ${PROJECT_NAME} dependent MinGW DLLs"
        VERBATIM
    )
    install(
        DIRECTORY ${MINGW_SHARED_LIBRARIES_DIR}/
        DESTINATION ${CMAKE_INSTALL_PREFIX_PLUGIN}
        FILES_MATCHING
        PATTERN "*.dll"
    )
endif()
