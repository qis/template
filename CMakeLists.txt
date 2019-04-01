cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
project(core VERSION 0.1.0 LANGUAGES CXX)

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

# Library
file(GLOB_RECURSE headers CONFIGURE_DEPENDS include/*.hpp)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.hpp src/${PROJECT_NAME}/*.cpp)

add_library(objects OBJECT ${headers} ${sources})
target_include_directories(objects PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>$<INSTALL_INTERFACE:include>)

find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

# Executable
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

if(WIN32)
  configure_file(src/main.rc.in ${CMAKE_CURRENT_BINARY_DIR}/src/main.rc CRLF)
  target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src/main.rc src/main.manifest)
endif()

# Install
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)

if(WIN32)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ DESTINATION bin
    FILES_MATCHING PATTERN "*.dll"
    PATTERN "CMakeFiles" EXCLUDE
    PATTERN "Testing" EXCLUDE
    PATTERN "gtest*" EXCLUDE
    PATTERN "res" EXCLUDE
    PATTERN "src" EXCLUDE)
endif()

# Run
if(ENABLE_RUN_TARGET OR CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  add_custom_target(run COMMAND $<TARGET_FILE:${PROJECT_NAME}> DEPENDS ${PROJECT_NAME}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} USES_TERMINAL)
endif()

# Benchmark
if(CMAKE_BUILD_TYPE MATCHES Release)
  add_executable(benchmark EXCLUDE_FROM_ALL src/benchmark.cpp)
  target_link_libraries(benchmark PRIVATE objects)

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PRIVATE benchmark::benchmark_main)
endif()

# Tests
add_executable(tests EXCLUDE_FROM_ALL src/tests.cpp)
target_link_libraries(tests PRIVATE objects)

enable_testing()
find_package(GTest MODULE REQUIRED)
target_link_libraries(tests PRIVATE GTest::Main)
gtest_add_tests(TARGET tests SOURCES src/tests.cpp WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
