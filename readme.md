# Template
C++20 project template that uses:

* [`qis/vcpkg`](https://github.com/qis/vcpkg) - a mirrored vcpkg repository
* [`qis/ports`](https://github.com/qis/ports) - a custom ports overlay

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

## Cache
Uses a local cache in `.cache/vcpkg/binaries` if the environment variable `VCPKG_BINARY_SOURCES`
in [`CMakePresets.json`](CMakePresets.json) is not set.

The remove cache was tested on an nginx server with the following config:

```nginx
worker_processes 1;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;

  sendfile on;
  #tcp_nopush on;
  keepalive_timeout 65;
  #gzip  on;

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

    location / {
      root html;
      index index.html index.htm;
    }

    #error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
      root html;
    }

    location /vcpkg/cache {
      alias vcpkg/cache/;
      dav_methods PUT;
      dav_access user:rw group:rw all:rw;
      client_max_body_size 0;
      autoindex on;
    }
  }
}
```
