#include <benchmark/benchmark.h>
#include <core/test.hpp>
#include <algorithm>
#include <random>
#include <vector>

static void benchmark_core(benchmark::State& state)
{
  thread_local std::random_device rd;
  thread_local std::uniform_int_distribution<int> dist(0, std::numeric_limits<int>::max());
  std::vector<int> v(10000);
  for (auto _ : state) {
    std::generate(
      v.begin(), v.end(), []() { return dist(rd) + static_cast<int>(core::test().size()); });
  }
}

BENCHMARK(benchmark_core);
