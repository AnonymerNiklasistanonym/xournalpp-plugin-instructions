cmake_minimum_required(VERSION 3.22.1)
project(ExampleHighQualityVector)

# Options:
set(CMAKE_INSTALL_PREFIX_ICONS "" CACHE PATH "Installation path for icons")

# Global variables:
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(PLUGIN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/${PROJECT_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PLUGIN_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PLUGIN_OUTPUT_DIR})
message(STATUS "SRC_DIR: ${SRC_DIR}")
message(STATUS "HEADER_DIR: ${HEADER_DIR}")
message(STATUS "PLUGIN_OUTPUT_DIR: ${PLUGIN_OUTPUT_DIR}")


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
file(GLOB_RECURSE PLUGIN_FILES ${CMAKE_CURRENT_SOURCE_DIR}/plugin/*)
message(STATUS "SRC_FILES: ${SRC_FILES}")
message(STATUS "PLUGIN_FILES: ${PLUGIN_FILES}")

# Create shared library
add_library(${PROJECT_NAME} SHARED ${SRC_FILES})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)
# > Add all header files
target_include_directories(${PROJECT_NAME} PRIVATE ${HEADER_DIR} )
# > Link with Lua
target_link_libraries(${PROJECT_NAME} PRIVATE ${LUA_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${LUA_INCLUDE_DIR})
# > Link with LibrSVG, Cairo
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRSVG_LIBRARIES} ${CAIRO_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${LIBRSVG_INCLUDE_DIRS} ${CAIRO_INCLUDE_DIRS})

# > Copy plugin MinGW dependencies into the output directory
if(CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ldd ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lib${PROJECT_NAME}.dll | grep mingw64 | awk "{ print \$3 }" | xargs -I {} cp {} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
        COMMENT "Copying MinGW shared libraries"
        VERBATIM
    )
endif()


# Install step:
# > Copy the plugin files into the plugin output directory
install(FILES ${PLUGIN_FILES} DESTINATION ${PLUGIN_OUTPUT_DIR})
# > Copy plugin directory to the install prefix
install(DIRECTORY ${PLUGIN_OUTPUT_DIR} DESTINATION ${CMAKE_INSTALL_PREFIX})
# > Copy icon files directory to the install prefix for icons
if(CMAKE_INSTALL_PREFIX_ICONS)
	message(STATUS "CMAKE_INSTALL_PREFIX_ICONS: ${CMAKE_INSTALL_PREFIX_ICONS}")
	file(GLOB ICON_FILES "${PLUGIN_OUTPUT_DIR}/*.svg")
	install(FILES ${ICON_FILES} DESTINATION ${CMAKE_INSTALL_PREFIX_ICONS})
endif()
