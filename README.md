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

Both columns now agree, which was not true before.

The `ops/s` column comes from a loop with no clock inside it. That is the
control.

The `p50 / p95 / p99` column used to wrap every single operation in a pair of
`steady_clock::now()` calls. On this machine that pair costs around 40 ns
against an operation of around 60 ns, and it also forces ordering that the
processor would otherwise avoid. Measured against the control over five runs,
that method reported a p50 of 151 ns where the truth was 63: a bias of
**+121 ns**. I found that out after publishing a throughput result and wrote it
up in **[A Timer Is Not a Measurement](https://moaz06.com/writing/a-timer-is-not-a-measurement)**.

One clock pair now covers 25 operations and the sample is the mean of the batch.
The instrument is amortised 25-fold, from about 40 ns per sample down to
**1.6 ns**, and the two columns now land within a few nanoseconds of each other
instead of a factor of three apart.

Batch size 25 came from a sweep against the control:

| batch | p50 | mean bias vs control | samples |
|---|---|---|---|
| 1 | 151.0 ns | +121.4 ns | 200,000 |
| 10 | 63.1 ns | +6.1 ns | 20,000 |
| **25** | **57.7 ns** | **+2.8 ns** | **8,000** |
| 100 | 55.5 ns | −1.0 ns | 2,000 |
| 250 | 54.1 ns | −2.1 ns | 800 |

Larger batches reduce the bias a little further and cost samples quickly. At 250
the p99 of the samples starts drifting on noise, because only 800 are left. This
project is named after a tail percentile, so 25 is the trade I took: under three
nanoseconds of bias, with four times the tail resolution of 100.

The same sweep answered a second question. From batch 25 upward, `std::chrono`
and `__rdtsc` agreed within 2 ns, so there is no reason to carry a platform
intrinsic. Batching makes the portable clock cheap enough.

### What this still cannot see

The percentiles are percentiles **of batch means**, not of individual
operations. A single slow operation is averaged with the 24 around it, so a
one-in-ten-thousand stall does not reach the tail. This column describes how the
cost of a run of operations is distributed. That is a weaker claim than a true
per-operation p99, and the benchmark prints the distinction on every run rather
than leaving it here.

Recovering a real per-operation tail needs a different instrument, not a smaller
batch: at 60 ns per operation there is no software clock cheap enough to sit on
both sides of one without changing what it measures.

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
