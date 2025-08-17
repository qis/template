# Visual Studio
cmake_policy(VERSION 3.31)
set(VSWHERE_ROOT "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
cmake_path(CONVERT "${VSWHERE_ROOT}" TO_CMAKE_PATH_LIST VSWHERE_ROOT NORMALIZE)

find_program(VSWHERE NAMES vswhere REQUIRED PATHS "${VSWHERE_ROOT}")
list(APPEND VSWHERE -nologo -nocolor -utf8 -format value -property resolvedInstallationPath)
list(APPEND VSWHERE -products "*" -requires Microsoft.VisualStudio.Component.VC.Llvm.Clang -latest)
execute_process(COMMAND ${VSWHERE} ENCODING UTF-8 OUTPUT_VARIABLE VS_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
cmake_path(CONVERT "${VS_ROOT}" TO_CMAKE_PATH_LIST VS_ROOT NORMALIZE)

# Clang-Format
find_program(CLANG_FORMAT NAMES clang-format REQUIRED PATHS "${VS_ROOT}/VC/Tools/Llvm/x64/bin")

# Sources
cmake_path(GET CMAKE_SCRIPT_MODE_FILE PARENT_PATH SCRIPT_DIR)
cmake_path(CONVERT "${SCRIPT_DIR}/.." TO_CMAKE_PATH_LIST PROJECT_DIR NORMALIZE)
file(GLOB_RECURSE SOURCES "${PROJECT_DIR}/src/*.cpp" "${PROJECT_DIR}/src/*.hpp")

# Format
foreach(SOURCE IN LISTS SOURCES)
  file(READ "${SOURCE}" SOURCE_DATA)
  string(MD5 SOURCE_HASH_TMP "${SOURCE_DATA}")
  execute_process(COMMAND ${CLANG_FORMAT} -i "${SOURCE}")
  file(READ "${SOURCE}" SOURCE_DATA)
  string(MD5 SOURCE_HASH_CMP "${SOURCE_DATA}")
  if(NOT "${SOURCE_HASH_TMP}" STREQUAL "${SOURCE_HASH_CMP}")
    cmake_path(RELATIVE_PATH SOURCE BASE_DIRECTORY "${PROJECT_DIR}")
    message(STATUS "${SOURCE}")
  endif()
endforeach()
