# Template
C++20 project template that uses:

* [qis/vcpkg](https://github.com/qis/vcpkg) - a mirrored vcpkg repository
* [qis/ports](https://github.com/qis/ports) - a custom ports overlay

```cmd
:: Build project and run tests.
cmake --workflow x64-debug

:: Build project and create package.
cmake --workflow x64-release

:: Manually test package.
7z t build\x64-release\template.7z

:: Manually run benchmarks.
build\x64-release\bin\benchmarks.exe
```
