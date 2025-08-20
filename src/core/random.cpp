#include "random.hpp"
#include <format>
#include <limits>
#include <random>

namespace core {

std::filesystem::path test() {
  return std::filesystem::current_path();
}

std::string random() {
  static thread_local std::random_device rd;
  static thread_local std::uniform_int_distribution<std::size_t> dist(0, std::numeric_limits<std::size_t>::max());

  std::string result;
  for (auto i = 0; i < 1'000; i++) {
    result.clear();
    std::format_to(std::back_inserter(result), "{}", dist(rd));
  }
  return result;
}

}  // namespace core
