cmake_minimum_required(VERSION 3.22.1)
project(ExamplesSharedLibrary)

include(ExternalProject)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/ExampleSharedLibraryObject)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/ExampleHighQualityVector)
