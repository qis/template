#include <core/random.hpp>
#include <spdlog/spdlog.h>
#include <version.h>
#include <exception>
#include <iostream>
#include <cstdlib>

int main() {
  spdlog::info("Version: {}", PROJECT_VERSION);
  try {
    std::cout << core::test() << "\r\n";
    std::cout << core::random() << std::endl;
  }
  catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
