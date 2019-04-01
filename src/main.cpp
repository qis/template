#include <cstdio>

#if !defined(BUILD_BENCHMARK) && !defined(BUILD_TESTS)
int main(int argc, char* argv[]) {
  std::printf("test\n");
}
#endif
