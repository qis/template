@echo off
rem
rem Download Binaries and Dependencies for make:
rem
rem   http://gnuwin32.sourceforge.net/packages/make.htm
rem
rem Extarct archives into:
rem
rem   "%ProgramFiles(x86)%\GNU"
rem

set __MAKE_BINARY="%ProgramFiles(x86)%\GNU\bin\make.exe"
set __VS_LOCATION="%ProgramFiles(x86)%\Microsoft Visual Studio\2017"
set __VS_EDITIONS="Enterprise,Professional,Community"

if not exist %__MAKE_BINARY% (
  echo error: missing executable: %__MAKE_BINARY% 1>&2
  goto :cleanup
)

if "%1"=="" (
  set __SKIP_VCVARS_INITIALIZATION=0
) else (
  set __SKIP_VCVARS_INITIALIZATION=1
)

for %%i in (%*) do (
  (echo :clean: :ports: | findstr /i ":%%i:" 1>nul 2>nul) || (
    set __SKIP_VCVARS_INITIALIZATION=0
  )
)

if "%__SKIP_VCVARS_INITIALIZATION%"=="1" (
  goto :skip_vcvars_initialization
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

:skip_vcvars_initialization

%__MAKE_BINARY% %*

:cleanup
set __VS_EDITIONS=
set __VS_LOCATION=
set __MAKE_BINARY=
