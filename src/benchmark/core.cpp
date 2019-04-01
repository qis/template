#include <benchmark/benchmark.h>
#include <algorithm>
#include <random>
#include <vector>

static void core(benchmark::State& state) {
  thread_local std::random_device rd;
  thread_local std::uniform_int_distribution<int> dist(0, std::numeric_limits<int>::max());
  std::vector<int> v(10000);
  for (auto _ : state) {
    std::generate(v.begin(), v.end(), [] () {
      return dist(rd);
    });
  }
}

BENCHMARK(core);
