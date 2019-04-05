#include <config.hpp>
#include <core/test.hpp>
#include <fmt/format.h>
#include <cstdio>

int main(int argc, char* argv[])
{
  std::puts("Project Name: " PROJECT_NAME);
  std::puts("Project Text: " PROJECT_TEXT);
  std::puts("Company Name: " COMPANY_NAME);
  std::puts("Copying Text: " COPYING_TEXT);
  std::puts("Version Text: " VERSION_TEXT);
  std::puts(fmt::format("Version Info: {}.{}.{}", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH).data());
  std::puts(fmt::format("Library Test: {}", core::test()).data());
}
