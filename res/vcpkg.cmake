include_guard(GLOBAL)
# Visual Studio
set(VSWHERE_ROOT "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
cmake_path(CONVERT "${VSWHERE_ROOT}" TO_CMAKE_PATH_LIST VSWHERE_ROOT NORMALIZE)

find_program(VSWHERE NAMES vswhere REQUIRED PATHS "${VSWHERE_ROOT}")
list(APPEND VSWHERE -nologo -nocolor -utf8 -latest -property resolvedInstallationPath -format value)
execute_process(COMMAND ${VSWHERE} ENCODING UTF-8 OUTPUT_VARIABLE VS_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
cmake_path(CONVERT "${VS_ROOT}" TO_CMAKE_PATH_LIST VS_ROOT NORMALIZE)

# Vcpkg
find_program(VCPKG NAMES vcpkg REQUIRED PATHS "${VS_ROOT}/VC/vcpkg")
get_filename_component(VCPKG_ROOT "${VCPKG}" DIRECTORY)

set(VCPKG_INSTALL_OPTIONS "--x-no-default-features")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--clean-buildtrees-after-build")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--clean-packages-after-build")
set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS};--no-print-usage")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchain.cmake")

if(NOT DEFINED ENV{VCPKG_BINARY_SOURCES})
  set(ENV{VCPKG_BINARY_SOURCES} "clear;files,${CMAKE_SOURCE_DIR}/.cache/vcpkg/binaries,readwrite")
endif()

include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")

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

# Directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
