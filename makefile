# usage: make run|test|benchmark|install|clean|ports
#
#  run        - build and execute program in debug mode
#  test       - build and execute tests in debug and release mode
#  benchmark  - build and execute benchmarks in release mode
#  install    - build and install program in release mode
#  clean      - remove build directory
#  ports      - install dependencies
#
MAKEFLAGS += --no-print-directory

ifeq ($(OS),Windows_NT)
SYSTEM	:= windows
SCRIPT	:= $(dir $(shell where vcpkg))scripts
else
SYSTEM	:= linux
SCRIPT	:= $(dir $(shell which vcpkg))scripts
endif

CONFIG	:= -DCMAKE_TOOLCHAIN_FILE:PATH="$(SCRIPT)/buildsystems/vcpkg.cmake"
CONFIG	+= -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE:PATH="$(SCRIPT)/toolchains/$(SYSTEM).cmake"
CONFIG	+= -DVCPKG_TARGET_TRIPLET=x64-$(SYSTEM) -DCMAKE_INSTALL_PREFIX:PATH="$(CURDIR)"

all: build/$(SYSTEM)/debug/CMakeCache.txt
	@cmake --build build/$(SYSTEM)/debug

run: build/$(SYSTEM)/debug/CMakeCache.txt
	@cmake --build build/$(SYSTEM)/debug --target run

test: build/$(SYSTEM)/debug/CMakeCache.txt build/$(SYSTEM)/release/CMakeCache.txt
	@cmake --build build/$(SYSTEM)/debug --target tests
	@cmake --build build/$(SYSTEM)/release --target tests
	@cmake --build build/$(SYSTEM)/debug --target test
	@cmake --build build/$(SYSTEM)/release --target test

benchmark: build/$(SYSTEM)/release/CMakeCache.txt
	@cmake --build build/$(SYSTEM)/release --target benchmark
	@build/$(SYSTEM)/release/benchmark

install: build/$(SYSTEM)/release/CMakeCache.txt
	@cmake --build build/$(SYSTEM)/release --target install

clean:
	@cmake -E remove_directory build/$(SYSTEM)

ports:
	@vcpkg install @ports.txt

build/$(SYSTEM)/debug/CMakeCache.txt: CMakeLists.txt
	@cmake -GNinja $(CONFIG) -DCMAKE_BUILD_TYPE=Debug -B build/$(SYSTEM)/debug

build/$(SYSTEM)/release/CMakeCache.txt: CMakeLists.txt
	@cmake -GNinja $(CONFIG) -DCMAKE_BUILD_TYPE=Release -B build/$(SYSTEM)/release

.PHONY: all run test benchmark install uninstall clean ports
