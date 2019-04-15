cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)
project(lib DESCRIPTION "Lib" VERSION 0.1.0 LANGUAGES CXX)

# Config
set(PROJECT_VENDOR "Xiphos")
set(PROJECT_COPYRIGHT "2016 Alexej Harm")

# Settings
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
  add_definitions(-D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN -DNOMINMAX -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
  add_definitions(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER build)
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT main)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/res/cmake)

# Library
configure_file(src/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp LF)

file(GLOB_RECURSE sources CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/*.hpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/*.hpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/*.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp)

add_library(${PROJECT_NAME} ${sources})
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)

# Dependencies
find_package(fmt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)

# Resources
if(WIN32 AND BUILD_SHARED_LIBS)
  target_sources(${PROJECT_NAME} PRIVATE src/main.rc)
endif()

# Precompiled Header
#include(cotire)
#set_target_properties(${PROJECT_NAME} PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT src/common.hpp)
#set_target_properties(${PROJECT_NAME} PROPERTIES COTIRE_ADD_UNITY_BUILD OFF)
#cotire(${PROJECT_NAME})

# Install
install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

install(DIRECTORY include/ DESTINATION include)

# Executable
add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE ${PROJECT_NAME})

# Benchmark
if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/benchmark)
  file(GLOB_RECURSE benchmark_sources CONFIGURE_DEPENDS src/benchmark/*.hpp src/benchmark/*.cpp)
  add_executable(benchmark EXCLUDE_FROM_ALL ${benchmark_sources})
  target_link_libraries(benchmark PRIVATE ${PROJECT_NAME})

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PRIVATE benchmark::benchmark_main)
endif()

# Tests
if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/tests)
  file(GLOB_RECURSE tests_sources CONFIGURE_DEPENDS src/tests/*.hpp src/tests/*.cpp)
  add_executable(tests EXCLUDE_FROM_ALL ${tests_sources})
  target_link_libraries(tests PRIVATE ${PROJECT_NAME})

  enable_testing()
  find_package(GTest MODULE REQUIRED)
  target_link_libraries(tests PRIVATE GTest::Main)
  gtest_add_tests(TARGET tests SOURCES ${tests_sources} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Format
find_program(CLANG_FORMAT NAMES clang-format DOC "Clang-Format executable." HINTS "$ENV{ProgramFiles\(x86\)}")
if(CLANG_FORMAT)
  add_custom_target(format
    COMMAND ${CLANG_FORMAT} -i src/main.cpp ${sources} ${benchmark_sources} ${tests_sources}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Debug
set_target_properties(main PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

# Source Groups
source_group(TREE ${CMAKE_SOURCE_DIR} PREFIX "" FILES src/main.cpp ${sources} ${benchmark_sources} ${tests_sources})
source_group(build\\rules REGULAR_EXPRESSION "\\.rule$")
