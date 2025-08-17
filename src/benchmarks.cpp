#include <core/random.hpp>
#include <benchmark/benchmark.h>

void random(benchmark::State& state) {
  for (auto _ : state) {
    auto str = core::random();
    benchmark::DoNotOptimize(str);
  }
}

BENCHMARK(random);

int main(int argc, char** argv) {
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
