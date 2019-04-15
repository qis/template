#include <fmt/format.h>
#include <lib/test.hpp>
#include <filesystem>
#include <cstdio>

int main(int argc, char* argv[])
{
  std::puts(fmt::format("Test: {}", lib::test()).data());
  std::puts(std::filesystem::current_path().u8string().data());
}
