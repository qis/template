# Toolchain
include_guard(GLOBAL)

# Visual Studio
set(VSWHERE_ROOT "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
cmake_path(CONVERT "${VSWHERE_ROOT}" TO_CMAKE_PATH_LIST VSWHERE_ROOT NORMALIZE)

find_program(VSWHERE NAMES vswhere REQUIRED PATHS "${VSWHERE_ROOT}")
list(APPEND VSWHERE -nologo -nocolor -utf8 -format value -property resolvedInstallationPath)
list(APPEND VSWHERE -products "*" -requires Microsoft.VisualStudio.Component.Vcpkg -latest)
execute_process(COMMAND ${VSWHERE} ENCODING UTF-8 OUTPUT_VARIABLE VS_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
cmake_path(CONVERT "${VS_ROOT}" TO_CMAKE_PATH_LIST VS_ROOT NORMALIZE)

# Vcpkg
find_program(VCPKG NAMES vcpkg REQUIRED PATHS "${VS_ROOT}/VC/vcpkg")
get_filename_component(VCPKG_ROOT "${VCPKG}" DIRECTORY)

set(VCPKG_INSTALL_OPTIONS "--x-no-default-features")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--clean-buildtrees-after-build")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--clean-packages-after-build")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--no-print-usage")

if(NOT DEFINED ENV{VCPKG_DOWNLOADS})
  set(ENV{VCPKG_DOWNLOADS} "${CMAKE_SOURCE_DIR}/.cache/vcpkg/downloads")
endif()

if(NOT DEFINED ENV{VCPKG_BINARY_SOURCES})
  set(ENV{VCPKG_BINARY_SOURCES} "clear;files,${CMAKE_SOURCE_DIR}/.cache/vcpkg/binaries,readwrite")
endif()

set(ENV{VCPKG_FORCE_SYSTEM_BINARIES} "ON")
set(ENV{VCPKG_DISABLE_METRICS} "ON")

include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
include("${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/toolchain.cmake")

# Triplet
string(REGEX MATCH "-windows-(x86|x64)-(debug|release)$" _ "${VCPKG_TARGET_TRIPLET}")
if(NOT CMAKE_MATCH_COUNT EQUAL 2)
  message(FATAL_ERROR "Invalid VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}")
endif()
if(CMAKE_MATCH_2 STREQUAL debug)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "")
else()
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "")
endif()

# Standard
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_SCAN_FOR_MODULES OFF CACHE BOOL "")

# Warnings
cmake_policy(SET CMP0092 NEW)
string(APPEND CMAKE_C_FLAGS_INIT " /W4")
string(APPEND CMAKE_CXX_FLAGS_INIT " /W4")

# Debug Information
cmake_policy(SET CMP0141 NEW)
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<CONFIG:Debug>:EditAndContinue>" CACHE STRING "" FORCE)

# Runtime Library
cmake_policy(SET CMP0091 NEW)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:DLL>" CACHE STRING "" FORCE)

# Interprocedural Optimization
cmake_policy(SET CMP0069 NEW)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF CACHE BOOL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON CACHE BOOL "" FORCE)

# Configurations
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)
set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG ";Release" CACHE STRING "")

# Libraries
file(GLOB TOOLCHAIN_DLLS "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/bin/*.dll")
foreach(TOOLCHAIN_DLL ${TOOLCHAIN_DLLS})
  get_filename_component(TOOLCHAIN_DLL_NAME "${TOOLCHAIN_DLL}" NAME)
  configure_file(${TOOLCHAIN_DLL} "${CMAKE_BINARY_DIR}/bin/${TOOLCHAIN_DLL_NAME}" COPYONLY)
endforeach()

# Cache
find_program(CCACHE NAMES ccache PATHS ENV PATH NO_DEFAULT_PATH)
if(CCACHE)
  set(CMAKE_CXX_COMPILER_LAUNCHER "ccache;cache_dir=${CMAKE_SOURCE_DIR}/.cache/ccache" CACHE STRING "")
  set(CMAKE_C_COMPILER_LAUNCHER "ccache;cache_dir=${CMAKE_SOURCE_DIR}/.cache/ccache" CACHE STRING "")
endif()

# Build Directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
