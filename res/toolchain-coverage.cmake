# Coverage
include_guard(GLOBAL)
set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_MT mt)

set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "Embedded" CACHE STRING "")
include(${CMAKE_CURRENT_LIST_DIR}/toolchain.cmake)

foreach(LANG IN ITEMS C CXX)
  string(APPEND CMAKE_${LANG}_FLAGS_DEBUG_INIT " -fprofile-instr-generate -fcoverage-mapping")
endforeach()

find_program(LLVM_PROFDATA NAMES llvm-profdata REQUIRED)
find_program(LLVM_COV NAMES llvm-cov REQUIRED)

file(WRITE ${CMAKE_BINARY_DIR}/report.ps1
"$profile  = \"${LLVM_PROFDATA}\"\n"
"$report   = \"${LLVM_COV}\"\n"
[=[
$data     = "default.profdata"
$raw      = "default.profraw"
$exe      = "bin/tests.exe"

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (!(Test-Path $exe)) { Write-Error "$exe not found" }
if (!(Test-Path $raw) -or ((Get-Item $exe).LastWriteTime -gt (Get-Item $raw).LastWriteTime)) {
  try { &$exe } catch { Remove-Item $raw -ErrorAction Ignore; exit 1 }
}
if (!(Test-Path $data) -or ((Get-Item $data).LastWriteTime -lt (Get-Item $raw).LastWriteTime)) {
  try { &$profile merge -sparse $raw -o $data } catch { Remove-Item $data -ErrorAction Ignore; exit 1 }
}
&$report show $exe "-instr-profile=$data" @args
]=])

file(WRITE ${CMAKE_BINARY_DIR}/report.cmd [=[
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0report.ps1" %*
exit /b %errorlevel%
]=])
