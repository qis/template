cmake_minimum_required(VERSION 3.31 FATAL_ERROR)
project(template DESCRIPTION "Template" VERSION 0.1.0 LANGUAGES CXX)

# Version
set(COMPANY_NAME "Company")
set(PRODUCT_NAME "Product")
configure_file(res/version.h.in ${CMAKE_BINARY_DIR}/src/version.h LF)

# Objects
file(GLOB_RECURSE headers CONFIGURE_DEPENDS src/core/*.hpp)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/core/*.cpp)

add_library(objects OBJECT ${sources})
target_sources(objects PUBLIC FILE_SET HEADERS FILES ${headers})
target_include_directories(objects PUBLIC ${CMAKE_BINARY_DIR}/src src)
target_compile_features(objects PUBLIC cxx_std_20)

if(WIN32)
  target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

find_package(Boost CONFIG REQUIRED COMPONENTS core
  heap bimap container circular_buffer intrusive smart_ptr lockfree
  outcome leaf asio beast json url filesystem uuid process program_options)
target_link_libraries(objects PUBLIC ${Boost_LIBRARIES})

find_package(spdlog CONFIG REQUIRED)
target_link_libraries(objects PUBLIC spdlog::spdlog)

find_package(WIL CONFIG REQUIRED)
target_link_libraries(objects PUBLIC WIL::WIL)

# Application
add_executable(main src/main.cpp src/main.manifest src/main.rc)
set_target_properties(main PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
target_link_libraries(main PRIVATE objects)

# Tests
set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
enable_testing()

add_executable(tests src/tests.cpp src/main.manifest)
target_link_libraries(tests PRIVATE objects)

find_package(GTest CONFIG REQUIRED)
target_link_libraries(tests PRIVATE GTest::gtest GTest::gmock)

include(CTest)
include(GoogleTest)
gtest_discover_tests(tests DISCOVERY_MODE POST_BUILD DISCOVERY_TIMEOUT 10)

if(NOT BUILD_TESTS)
  set_target_properties(tests PROPERTIES EXCLUDE_FROM_ALL ON)
endif()

# Benchmarks
add_executable(benchmarks src/benchmarks.cpp src/main.manifest)
target_link_libraries(benchmarks PRIVATE objects)

find_package(benchmark CONFIG REQUIRED)
target_link_libraries(benchmarks PRIVATE benchmark::benchmark)

if(NOT BUILD_BENCHMARKS)
  set_target_properties(benchmarks PROPERTIES EXCLUDE_FROM_ALL ON)
endif()

# Release
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  # Install
  install(TARGETS main RUNTIME DESTINATION .)

  # Package
  set(CPACK_GENERATOR "7Z")
  set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
  set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
  include(CPack)
endif()
