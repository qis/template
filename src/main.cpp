#include <company/random.hpp>
#include <iostream>
#include <cstdlib>

int main() {
  try {
    std::cout << company::random() << "\r\n";
    std::cout << company::test() << std::endl;
  }
  catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
