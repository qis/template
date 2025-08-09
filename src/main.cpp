#include <company/random.hpp>
#include <format>
#include <cstdio>
#include <cstdlib>

int main()
{
  try {
    std::fputs(std::format("{}\r\n", company::random()).data(), stdout);
    company::test();
  }
  catch (const std::exception& e) {
    std::fputs(std::format("error: {}\r\n", e.what()).data(), stderr);
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
