# P99KV

A C++/Linux performance lab built around an in-memory key-value store. The store
is deliberately simple. The point is the measurement around it.

## What this is

I use this repository to learn performance engineering from first principles:
what a change actually costs, how to measure it without lying to myself, and how
much of a measurement turns out to be the measuring.

It is not a database and it is not trying to become one. There is no network
layer, no persistence, no concurrency and no eviction. A single
`std::unordered_map` behind a small API is enough surface to ask the questions
I am interested in.

## Build and run

Requires CMake 3.20 and a C++20 compiler.

```sh
cmake -B build
cmake --build build -j
```

When you do not pick a build type, this defaults to `RelWithDebInfo` (`-O2 -g`).
That is deliberate: an unoptimised benchmark mostly measures the absence of
optimisation, and `-g` keeps the binaries readable under `perf`.

Correctness tests:

```sh
./build/p99kv_tests
```

Full benchmark:

```sh
./build/p99kv_bench
```

A single isolated workload, for running under `perf`:

```sh
./build/p99kv_perf get-hit
./build/p99kv_perf get-miss
./build/p99kv_perf set-overwrite
```

## What the benchmark does

50,000 entries, 32-byte values, 200,000 operations per measurement, across three
workloads: GET hit, GET miss and SET overwrite.

- The access pattern comes from a fixed-seed xorshift, so every run touches the
  same keys in the same order.
- 10,000 untimed operations warm each workload before anything is recorded.
- Throughput and latency are measured in separate loops. The throughput loop
  contains no clock calls at all, and the latency loop takes one timestamp pair
  per 25 operations rather than per operation.
- A checksum derived from the returned values is printed, so the optimiser
  cannot delete the work being measured.

## Reading the output

The `ops/s` column comes from total elapsed time around the throughput loop.
The loop includes index access, the operation, result consumption and loop
overhead, with no clock calls inside it. Its reciprocal is an average elapsed
time per operation, not an individual-operation median or percentile.

The `p50 / p95 / p99` columns come from a separate pass. One pair of
`steady_clock::now()` calls covers 25 operations, and elapsed batch time divided
by 25 becomes one sample. These are percentiles of batch means. Agreement with
the throughput average does not validate an individual-operation latency
distribution.

The empty-clock diagnostic takes the median interval between consecutive
`steady_clock::now()` calls and divides by 25. It measures neither the complete
execution cost of both clock calls nor the total distortion caused by timing
the workload.

### Exploratory batch-size sweep

The following GET-hit results summarize five runs with 200,000 operations per
measurement on an AMD Ryzen 9 8940HX, Ubuntu under WSL2, g++ 15.2.0, `-O2`,
pinned to one core with `taskset`.

The p50 column is the median of the five run p50s. The mean column is the median
of the five run means. The control column is the median of the five throughput
averages, 63.2 ns/op. The difference column subtracts that median control from
the median run mean; it is not a p50 difference or the median of paired run
differences.

| batch | median run p50 | median run mean | median control | difference of medians | samples per run |
|---|---|---|---|---|---|
| 1 | 151.0 ns | 184.6 ns | 63.2 ns/op | +121.4 ns | 200,000 |
| 5 | 76.2 ns | 87.4 ns | 63.2 ns/op | +24.2 ns | 40,000 |
| 10 | 63.1 ns | 69.3 ns | 63.2 ns/op | +6.1 ns | 20,000 |
| **25** | **57.7 ns** | **66.0 ns** | **63.2 ns/op** | **+2.8 ns** | **8,000** |
| 50 | 56.7 ns | 68.2 ns | 63.2 ns/op | +5.0 ns | 4,000 |
| 100 | 55.5 ns | 62.2 ns | 63.2 ns/op | -1.0 ns | 2,000 |
| 250 | 54.1 ns | 61.1 ns | 63.2 ns/op | -2.1 ns | 800 |
| 1000 | 53.5 ns | 58.6 ns | 63.2 ns/op | -4.6 ns | 200 |

The execution order was fixed: the control ran once first, followed by increasing
batch sizes, with `std::chrono` before bare `rdtsc` at each size. Method and order
were therefore confounded. These are exploratory comparisons, not isolated
measurements of clock bias or proof that batch 25 is optimal. For example, at
batch 25 the median paired mean difference is +1.5 ns, while the difference of
medians shown above is +2.8 ns.

Batch 25 remains the current setting. It yields four times as many samples as
batch 100. Changing batch size also changes the distribution of batch means;
sample count alone does not explain changes in p99 or determine its uncertainty.

From batch 25 upward, the two clocks' median run p50s differ by at most 2 ns.
This agreement applies to that summary statistic, not to all means, tails or
individual runs, and does not establish equivalent accuracy. The benchmark
retains the portable clock.

The earlier per-operation clock experiment is discussed in
**[A Timer Is Not a Measurement](https://moaz06.com/writing/a-timer-is-not-a-measurement)**,
published on 3 October 2026.

### What batch means cannot establish

An extra stall of S nanoseconds in one batch raises that batch's per-operation
mean by S/25 nanoseconds. It is diluted, not erased, and can still affect the
batch tail. Individual-operation percentiles cannot be recovered from these
batch means.

With independent stalls occurring once per 10,000 operations, about 0.25% of
25-operation batches contain a stall. Such events can appear in the batch
p99.9 or maximum, even though they need not determine batch p99. An
individual-operation p99 also need not expose a stall occurring in only 0.01%
of operations.

Measuring individual-operation latency requires a separate experiment that
accounts for timestamp overhead, ordering and sampling error. This benchmark
does not establish that hardware sampling is required.

## Reproducing the published numbers
The 59% GET-path improvement in that post was measured as:

- commit `51ae8fd`, compared against its parent
- `-O2`
- five interleaved runs of each build, medians compared
- one pinned core
- AMD Ryzen 9 8940HX, WSL2, g++ 15.2.0

Interleaving the runs matters more than the number of them: it is what stops a
slow minute on the machine from landing entirely on one of the two builds.

Note that `-DCMAKE_BUILD_TYPE=Release` compiles at `-O3`, not `-O2`, and will not
reproduce those numbers exactly.

## Status

Early, and measured. The store does what the tests say it does. Everything past
that is in progress.

MIT licensed. Built by Mohamed Azahrioui ([@MoAz06](https://github.com/MoAz06)),
with notes at [moaz06.com](https://moaz06.com).
