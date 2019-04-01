cmake_minimum_required(VERSION 3.13.4 FATAL_ERROR)
project(main VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
  add_definitions(-D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN -DNOMINMAX -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
  add_definitions(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)
endif()

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/res/cmake)

file(GLOB_RECURSE headers CONFIGURE_DEPENDS include/*.hpp)
file(GLOB sources CONFIGURE_DEPENDS src/*.hpp src/*.cpp)

add_executable(${PROJECT_NAME} ${headers} ${sources})
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>$<INSTALL_INTERFACE:include>)

if(WIN32)
  configure_file(src/main.rc.in ${CMAKE_CURRENT_BINARY_DIR}/src/main.rc CRLF)
  target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src/main.rc src/main.manifest)
endif()

find_package(Threads REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Threads::Threads)

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
  file(GLOB benchmark_sources CONFIGURE_DEPENDS src/benchmark/*.hpp src/benchmark/*.cpp)

  add_executable(benchmark EXCLUDE_FROM_ALL ${headers} ${sources} ${benchmark_sources})
  target_include_directories(benchmark PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src PUBLIC include)
  target_compile_definitions(benchmark PRIVATE BUILD_BENCHMARK=1)

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PUBLIC benchmark::benchmark_main)
endif()

# Tests
file(GLOB tests_sources CONFIGURE_DEPENDS src/tests/*.hpp src/tests/*.cpp)

add_executable(tests EXCLUDE_FROM_ALL ${headers} ${sources} ${tests_sources})
target_include_directories(tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src PUBLIC include)
target_compile_definitions(tests PRIVATE BUILD_TESTS=1)

enable_testing()
find_package(GTest MODULE REQUIRED)
target_link_libraries(tests PUBLIC GTest::Main)
gtest_add_tests(TARGET tests SOURCES ${tests_sources} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
