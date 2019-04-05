cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
project(core VERSION 0.1.0 LANGUAGES CXX)

# Config
set(PROJECT_TEXT "Core")
set(COMPANY_NAME "Xiphos")
set(COPYING_TEXT "2016 Alexej Harm")
configure_file(src/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp LF)

# Settings
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
  add_definitions(-D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN -DNOMINMAX -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
  add_definitions(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)
endif()

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/res/cmake)

# Objects
file(GLOB_RECURSE headers CONFIGURE_DEPENDS include/*.hpp)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.hpp src/${PROJECT_NAME}/*.cpp)

add_library(objects OBJECT ${headers} ${sources} ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp)
target_include_directories(objects PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>$<INSTALL_INTERFACE:include>)

find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

find_package(fmt CONFIG REQUIRED)
target_link_libraries(objects PUBLIC fmt::fmt)

# Precompiled Header
include(cotire)
set_target_properties(objects PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT src/common.hpp)
set_target_properties(objects PROPERTIES COTIRE_ADD_UNITY_BUILD OFF)
cotire(objects)

# Executable
add_executable(${PROJECT_NAME} src/main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

if(WIN32)
  target_sources(${PROJECT_NAME} PRIVATE src/main.rc src/main.manifest)
endif()

# Install
install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

if(WIN32)
  install(CODE [[
    file(GLOB libraries ${CMAKE_CURRENT_BINARY_DIR}/*.dll)
    file(INSTALL ${libraries} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin PATTERN "gtest*.dll" EXCLUDE)
  ]])
endif()

# Benchmark
if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/benchmark)
  file(GLOB_RECURSE benchmark_sources CONFIGURE_DEPENDS src/benchmark/*.hpp src/benchmark/*.cpp)
  add_executable(benchmark EXCLUDE_FROM_ALL ${benchmark_sources})
  target_link_libraries(benchmark PRIVATE objects)

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PRIVATE benchmark::benchmark_main)
endif()

# Tests
if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/tests)
  file(GLOB_RECURSE tests_sources CONFIGURE_DEPENDS src/tests/*.hpp src/tests/*.cpp)
  add_executable(tests EXCLUDE_FROM_ALL ${tests_sources})
  target_link_libraries(tests PRIVATE objects)

  enable_testing()
  find_package(GTest MODULE REQUIRED)
  target_link_libraries(tests PRIVATE GTest::Main)
  gtest_add_tests(TARGET tests SOURCES ${tests_sources} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Format
find_program(CLANG_FORMAT NAMES clang-format DOC "Clang-Format executable." HINTS "$ENV{ProgramFiles\(x86\)}")
if(CLANG_FORMAT)
  add_custom_target(format
    COMMAND ${CLANG_FORMAT} -i ${sources} src/main.cpp ${benchmark_sources} ${tests_sources}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()
