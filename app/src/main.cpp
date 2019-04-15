#include <app/test.hpp>
#include <config.hpp>
#include <fmt/format.h>
#include <chrono>
#include <filesystem>
#include <thread>
#include <cstdio>

int main(int argc, char* argv[])
{
  std::puts("Name: " PROJECT_NAME);
  std::puts("Description: " PROJECT_DESCRIPTION);
  std::puts("Vendor: " PROJECT_VENDOR);
  std::puts("Copyright: " PROJECT_COPYRIGHT);
  std::puts(fmt::format("Version: {} ({}.{}.{})", PROJECT_VERSION, PROJECT_VERSION_MAJOR, PROJECT_VERSION_MINOR, PROJECT_VERSION_PATCH).data());
  std::puts(fmt::format("Path: {}", std::filesystem::current_path().u8string()).data());
  std::puts(fmt::format("Library: {}", app::test()).data());

#ifdef _MSC_VER
  while (true) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::puts(fmt::format("Library: {}", app::test()).data());
  }
#endif
}
