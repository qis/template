#include <benchmark/benchmark.h>
#include <core/random.hpp>

static void core_random(benchmark::State& state) {
  for (auto _ : state) {
    auto str = core::random();
    benchmark::DoNotOptimize(str);
  }
}

BENCHMARK(core_random);
