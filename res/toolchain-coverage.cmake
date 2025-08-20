# Coverage
include_guard(GLOBAL)
set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_MT mt)

function(enable_coverage)
  foreach(source IN LISTS ARGN)
    get_source_file_property(COMPILE_FLAGS ${source} COMPILE_FLAGS)
    if(COMPILE_FLAGS)
      if(NOT COMPILE_FLAGS MATCHES "-fprofile-instr-generate")
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -fprofile-instr-generate")
      endif()
      if(NOT COMPILE_FLAGS MATCHES "-fcoverage-mapping")
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -fcoverage-mapping")
      endif()
    else()
      set(COMPILE_FLAGS "-fprofile-instr-generate -fcoverage-mapping")
    endif()
    set_source_files_properties(${source} PROPERTIES COMPILE_FLAGS "${COMPILE_FLAGS}")
  endforeach()
endfunction()

set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "Embedded" CACHE STRING "")
include(${CMAKE_CURRENT_LIST_DIR}/toolchain.cmake)

find_program(LLVM_PROFDATA NAMES llvm-profdata REQUIRED)
find_program(LLVM_COV NAMES llvm-cov REQUIRED)

file(WRITE ${CMAKE_BINARY_DIR}/report.cmd
"@echo off\n"
"set profile=${LLVM_PROFDATA}\n"
"set report=${LLVM_COV}\n"
[=[
for %%q IN ("%~dp0.") DO SET "build=%%~fq"
echo.
cmake -E chdir "%build%" "bin\tests.exe"
echo.
cmake -E chdir "%build%" "%profile%" merge -sparse default.profraw -o default.profdata
cmake -E chdir "%build%" "%report%" show "bin\tests.exe" -instr-profile=default.profdata %*
]=])
