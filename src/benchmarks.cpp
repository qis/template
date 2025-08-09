#include <benchmark/benchmark.h>
#include <company/random.hpp>

static void random(benchmark::State& state)
{
  for (auto _ : state) {
    auto str = company::random();
    benchmark::DoNotOptimize(str);
  }
}

BENCHMARK(random);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
