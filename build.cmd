@echo off
setlocal EnableDelayedExpansion

for %%p in (x64-debug x64-release x86-debug x86-release) do (
    echo Running cmake --workflow %%p
    cmake --workflow %%p
    if !ERRORLEVEL! neq 0 (
        echo Error: cmake --workflow %%p failed with error level !ERRORLEVEL!
        exit /b !ERRORLEVEL!
    )
)

echo All workflow presets completed successfully.
endlocal
