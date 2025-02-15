cmake_minimum_required(VERSION 3.22.1)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
project(ExampleSharedLibraryObject)

# Options:
set(CMAKE_INSTALL_PREFIX_ICONS "" CACHE PATH "Installation path for icons")

# Global variables:
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(PLUGIN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/${PROJECT_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PLUGIN_OUTPUT_DIR})
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

# Register local sources
file(GLOB_RECURSE SRC_FILES ${SRC_DIR}/*.cpp)
file(GLOB_RECURSE PLUGIN_FILES ${CMAKE_CURRENT_SOURCE_DIR}/plugin/*)
message(STATUS "SRC_FILES: ${SRC_FILES}")
message(STATUS "PLUGIN_FILES: ${PLUGIN_FILES}")

# Create shared library
add_library(${PROJECT_NAME} SHARED ${SRC_FILES})
# > Add all header files
target_include_directories(${PROJECT_NAME} PRIVATE
	${HEADER_DIR}
	${LUA_INCLUDE_DIR}
)
# > Link with Lua
target_link_libraries(${PROJECT_NAME} PRIVATE ${LUA_LIBRARIES})

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
