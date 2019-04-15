@echo off
rem
rem Download make executable:
rem
rem   http://www.equation.com/servlet/equation.cmd?fa=make
rem
rem Save executable as:
rem
rem   "%ProgramFiles%\GNU\make.exe"
rem

set __SOURCE_PATH=%~dp0
set __SOURCE_PATH=%__SOURCE_PATH:~0,-1%
set __MAKE_BINARY=%ProgramFiles%\GNU\make.exe
set __VS_LOCATION=%ProgramFiles(x86)%\Microsoft Visual Studio\2019
set __VS_EDITIONS="Enterprise,Professional,Community"

if %0 EQU "%~dpnx0" (
  for /f %%i in ('where vcpkg.exe') do (
    set __SCRIPT_PATH=%%~dpiscripts
    goto :script_found
  )
  :script_found
  cmake -G "Visual Studio 16 2019" -A x64 -B "%__SOURCE_PATH%\build\msvc" ^
    -DCMAKE_TOOLCHAIN_FILE:PATH="%__SCRIPT_PATH%\buildsystems\vcpkg.cmake" ^
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE:PATH="%__SCRIPT_PATH%\toolchains\windows.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows -DCMAKE_INSTALL_PREFIX:PATH="%__SOURCE_PATH%" "%__SOURCE_PATH%"
  if %errorlevel% == 0 (
    cmake --open "%__SOURCE_PATH%\build\msvc"
  ) else (
    pause
  )
  goto :cleanup
)

if not exist "%__MAKE_BINARY%" (
  echo error: missing executable: %__MAKE_BINARY% 1>&2
  goto :cleanup
)

set __SKIP_VCVARS=0
for %%i in (%*) do (
  (echo :clean: :ports: | findstr /i ":%%i:" 1>nul 2>nul) && (
    set __SKIP_VCVARS=1
  )
)

if "%__SKIP_VCVARS%"=="1" (
  goto :skip_vcvars
)

if not "%MAKE_WRAPPER_VCVARS_INITIALIZED%"=="1" (
  for %%i in (%__VS_EDITIONS:"=%) do (
    if exist "%__VS_LOCATION:"=%\%%i\VC\Auxiliary\Build\vcvarsall.bat" (
      pushd "%__VS_LOCATION:"=%\%%i\VC\Auxiliary\Build"
      goto :vcvarsall_found
    )
  )

  echo error: missing script: "vcvarsall.bat" 1>&2
  goto :cleanup

  :vcvarsall_found
  call vcvarsall.bat x64 && goto initialized
  popd
  echo error: could not initialize vcvars 1>&2
  goto :cleanup

  :initialized
  popd
  set MAKE_WRAPPER_VCVARS_INITIALIZED=1
)

:skip_vcvars

"%__MAKE_BINARY%" %*

:cleanup
set __SKIP_VCVARS=
set __SCRIPT_PATH=
set __VS_EDITIONS=
set __VS_LOCATION=
set __MAKE_BINARY=
set __SOURCE_PATH=
