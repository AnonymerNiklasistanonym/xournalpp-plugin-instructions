cmake_minimum_required(VERSION 3.22.1)
project(ExampleSharedLibraryObject)

# Options
set(CMAKE_INSTALL_PREFIX_ICONS "" CACHE PATH "Installation path for icons")

# Global variables
set(CMAKE_INSTALL_PREFIX_PLUGIN ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME})
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
file(GLOB_RECURSE SRC_FILES ${SRC_DIR}/*.cpp)
set(HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(PLUGIN_DIR ${CMAKE_CURRENT_SOURCE_DIR}/plugin)
message(STATUS "SRC_DIR: ${SRC_DIR}")
message(STATUS "SRC_FILES: ${SRC_FILES}")
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

# Create shared library
add_library(${PROJECT_NAME} SHARED ${SRC_FILES})
# > Add all header files
target_include_directories(${PROJECT_NAME} PRIVATE ${HEADER_DIR})
# > Link with Lua
target_link_libraries(${PROJECT_NAME} PRIVATE ${LUA_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${LUA_INCLUDE_DIR})

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
