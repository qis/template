@echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set presets=x64-debug x64-coverage x64-release x86-debug x86-coverage x86-release
if "%*" neq "" set presets=%*
for %%p in (%presets%) do (
  cmake --workflow %%p
  if !errorlevel! neq 0 (
    echo Error: "cmake --workflow %%p" failed with error code !errorlevel!
    exit /b !errorlevel!
  )
  echo %%p | findstr /i "coverage" >nul
  if !errorlevel! equ 0 (
    call build\%%p\report.cmd
    if !errorlevel! neq 0 (
      echo Error: "build\%%p\report.cmd" failed with error code !errorlevel!
      exit /b !errorlevel!
    )
  )
)
endlocal
