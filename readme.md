# Template
C++20 project template that uses:

* [`https://github.com/qis/vcpkg`](https://github.com/qis/vcpkg) - a mirrored vcpkg repository
* [`https://github.com/qis/ports`](https://github.com/qis/ports) - a custom ports overlay

## CMake
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

## Compiler Cache
Uses a local compiler cache in `.cache/ccache` if the `ccache` executable is in `PATH`.

## Vcpkg Binary Sources
Uses a local cache in `.cache/vcpkg/binaries` if the environment variable `VCPKG_BINARY_SOURCES` is not set.

To use a remote cache, set the following environment variable:

```cmd
set VCPKG_BINARY_SOURCES=clear;http,http://localhost:80/vcpkg/cache/{name}/{version}/{sha},readwrite
```

The server has to support `GET` and `PUT` operations. A:

```nginx
worker_processes 1;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;
  keepalive_timeout 65;
  sendfile on;

  map $time_iso8601 $timestamp {
    ~^([0-9-]+)T([0-9:]+) "$1 $2";
  }

  map $remote_addr $address {
    ~^(..............) "$1 ";
    ~^(.............) "$1  ";
    ~^(............) "$1   ";
    ~^(...........) "$1    ";
    ~^(..........) "$1     ";
    ~^(.........) "$1      ";
    ~^(........) "$1       ";
    ~^(.......) "$1        ";
    default $remote_addr;
  }

  log_format access '[$timestamp] $address $status "$request" $body_bytes_sent';

  server {
    listen 80;
    server_name localhost;

    access_log logs/access.log access;

    location /vcpkg/cache {
      alias vcpkg/cache/;
      dav_methods PUT;
      dav_access user:rw group:rw all:rw;
      create_full_put_path on;
      client_max_body_size 0;
      autoindex on;
    }
  }
}
```

## Vcpkg Downloads
Uses a local cache in `.cache/vcpkg/downloads` if the environment variable `VCPKG_DOWNLOADS` is not set.

## Visual Studio Code
Tested with the following "CMake Tools" user configuration:

```json
"cmake.buildBeforeRun": true,
"cmake.configureOnOpen": false,
"cmake.copyCompileCommands": "${workspaceFolder}/build/compile_commands.json",
"cmake.ctest.testExplorerIntegrationEnabled": true,
"cmake.deleteBuildDirOnCleanConfigure": true,
"cmake.enableAutomaticKitScan": false,
"cmake.ignoreCMakeListsMissing": true,
"cmake.launchBehavior": "breakAndReuseTerminal",
"cmake.showConfigureWithDebuggerNotification": false,
"cmake.showNotAllDocumentsSavedQuestion": false,
"cmake.showOptionsMovedNotification": false,
"cmake.useCMakePresets": "always",
"cmake.pinnedCommands": [
  "workbench.action.tasks.configureTaskRunner",
  "workbench.action.tasks.runTask",
  "workbench.action.tasks.debug"
]
```

Tested with "C/C++" and "clangd" intellisense extensions.
