cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)
project(app DESCRIPTION "App" VERSION 0.1.0 LANGUAGES CXX)

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

if(MSVC)
  string(REGEX REPLACE "/Z[7Ii]" "/ZI" CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
  string(REGEX REPLACE "/Z[7Ii]" "/ZI" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /EDITANDCONTINUE")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /EDITANDCONTINUE")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER build)
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/res/cmake)

# Executable
configure_file(src/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp LF)

file(GLOB_RECURSE sources CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/src/config.hpp)

add_executable(${PROJECT_NAME} ${sources})
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src src)

# Dependencies
find_package(fmt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)

# Resources
if(WIN32)
  target_sources(${PROJECT_NAME} PRIVATE src/main.rc src/main.manifest)
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

if(WIN32)
  install(CODE [[
    file(GLOB libraries ${CMAKE_CURRENT_BINARY_DIR}/*.dll)
    file(INSTALL ${libraries} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin PATTERN "gtest*.dll" EXCLUDE)
  ]])
endif()

# Format
find_program(CLANG_FORMAT NAMES clang-format DOC "Clang-Format executable." HINTS "$ENV{ProgramFiles\(x86\)}")
if(CLANG_FORMAT)
  add_custom_target(format
    COMMAND ${CLANG_FORMAT} -i ${sources}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Debug
set_target_properties(${PROJECT_NAME} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

# Source Groups
source_group(TREE ${CMAKE_SOURCE_DIR} PREFIX "" FILES ${sources} src/main.rc src/main.manifest)
source_group(build\\rules REGULAR_EXPRESSION "\\.rule$")
