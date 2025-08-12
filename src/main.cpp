#include <company/random.hpp>
#include <iostream>
#include <cstdlib>

int main() {
  try {
    std::cout << company::test() << "\r\n";
    std::cout << company::random() << std::endl;
  }
  catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
