# Benchmarks

This file records what has been measured on this project, under what conditions,
and what those measurements do and do not establish. It exists because
[A Timer Is Not a Measurement](https://moaz06.com/writing/a-timer-is-not-a-measurement)
(3 October 2026) promised it, alongside two other changes that have since
landed: batched sampling, and a default build type in `CMakeLists.txt`.

Numbers here are from one machine. They are not a claim about this key-value
store in general, and they are not comparable to numbers from any other machine.

## Environment

| | |
|---|---|
| CPU | AMD Ryzen 9 8940HX, 32 logical cores |
| OS | Ubuntu 26.04.1 LTS under WSL2, kernel 6.18.33.2-microsoft-standard-WSL2 |
| Compiler | g++ (Ubuntu 15.2.0-16ubuntu1) 15.2.0 |
| Build | `-O2 -g -DNDEBUG` via `CMAKE_BUILD_TYPE=RelWithDebInfo` |
| Pinning | `taskset -c 2` |
| TSC flags | `constant_tsc`, `nonstop_tsc`, `rdtscp` present |

The CPU frequency governor is not readable under WSL2. Clock behaviour during
these runs was neither fixed nor observed. That limitation applies to every
number below.

## Reproducing

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build -j
taskset -c 2 ./build/p99kv_bench
```

## 1. Current benchmark, 7 consecutive runs

200,000 operations per measurement against 50,000 entries, batch size 25,
8,000 samples per measurement. Raw output:
[`benchmarks/results/2026-11-15-ryzen9-8940hx-wsl2.txt`](benchmarks/results/2026-11-15-ryzen9-8940hx-wsl2.txt).

| operation | median ops/s | ops/s range | median p50 | p50 range | median p95 | median p99 | p99 range |
|---|---|---|---|---|---|---|---|
| GET hit | 12.50M | 8.44-13.25M | 76.6 ns | 72.2-77.3 ns | 101.0 ns | 117.0 ns | 97.0-205.2 ns |
| GET miss | 10.60M | 9.43-14.89M | 69.7 ns | 65.7-73.0 ns | 89.4 ns | 109.8 ns | 89.0-216.0 ns |
| SET overwrite | 10.32M | 7.09-10.73M | 86.2 ns | 83.8-89.0 ns | 116.2 ns | 152.3 ns | 142.7-164.3 ns |

**The run-to-run spread is the most important column.** GET hit throughput
varied by 57% across seven consecutive runs of the same binary on a pinned
core, and its p99 varied by more than a factor of two. A single run of this
benchmark is not reproducible to better than tens of percent, and no change to
this project should be accepted or rejected on the strength of one.

The spread is not a monotone ramp. In this set, runs 4 and 5 are slow and runs
6 and 7 recover. A separate five-run set earlier the same day did decline
monotonically. Neither pattern has been explained.

The `ops/s` and percentile columns measure different things, and agreement
between them validates neither. The reciprocal of median GET hit throughput is
80.0 ns/op, an average elapsed time over a loop containing index access, the
operation, result consumption and loop overhead. The median p50 of 76.6 ns is
the middle of a distribution of per-operation means over batches of 25, taken
in a separate pass. They are close. That is not evidence that either is correct.

## 2. Exploratory batch-size sweep

Five runs, GET hit only, 200,000 operations per measurement, same machine. Raw
output lives in a separate working repository and is not committed here.

The control is the throughput loop, which contains no clock. Its median across
the five runs is 63.2 ns/op, from individual runs of 60.1, 63.2, 63.7, 70.4 and
59.8 ns/op.

Two difference columns are given because they answer different questions. The
*difference of medians* subtracts the median control from the median run mean.
The *median paired difference* computes mean minus control within each run and
takes the median of those five values. Neither is a difference of p50s: the
control has no p50, because it is a single average.

| batch | clock | median p50 | median p99 | median mean | diff of medians | median paired diff | samples/run |
|---|---|---|---|---|---|---|---|
| 1 | chrono | 151.0 ns | 430.0 ns | 184.6 ns | +121.4 ns | +123.1 ns | 200,000 |
| 1 | rdtsc | 60.1 ns | 350.7 ns | 95.1 ns | +31.9 ns | +31.6 ns | 200,000 |
| 5 | chrono | 76.2 ns | 162.2 ns | 87.4 ns | +24.2 ns | +24.9 ns | 40,000 |
| 5 | rdtsc | 58.1 ns | 132.3 ns | 72.5 ns | +9.3 ns | +9.3 ns | 40,000 |
| 10 | chrono | 63.1 ns | 110.2 ns | 69.3 ns | +6.1 ns | +9.0 ns | 20,000 |
| 10 | rdtsc | 58.1 ns | 104.2 ns | 61.9 ns | -1.3 ns | +2.0 ns | 20,000 |
| **25** | **chrono** | **57.7 ns** | **99.4 ns** | **66.0 ns** | **+2.8 ns** | **+1.5 ns** | **8,000** |
| 25 | rdtsc | 55.7 ns | 104.2 ns | 63.4 ns | +0.2 ns | +2.0 ns | 8,000 |
| 50 | chrono | 56.7 ns | 105.0 ns | 68.2 ns | +5.0 ns | +8.1 ns | 4,000 |
| 50 | rdtsc | 54.7 ns | 95.8 ns | 58.4 ns | -4.8 ns | -2.0 ns | 4,000 |
| 100 | chrono | 55.5 ns | 108.3 ns | 62.2 ns | -1.0 ns | -1.5 ns | 2,000 |
| 100 | rdtsc | 55.1 ns | 96.8 ns | 61.5 ns | -1.7 ns | -2.9 ns | 2,000 |
| 250 | chrono | 54.1 ns | 169.9 ns | 61.1 ns | -2.1 ns | -1.4 ns | 800 |
| 250 | rdtsc | 55.5 ns | 169.8 ns | 67.5 ns | +4.3 ns | +4.9 ns | 800 |
| 1000 | chrono | 53.5 ns | 121.1 ns | 58.6 ns | -4.6 ns | -1.5 ns | 200 |
| 1000 | rdtsc | 54.5 ns | 130.9 ns | 63.0 ns | -0.2 ns | -3.1 ns | 200 |

### What this sweep does and does not support

The control varied from 59.8 to 70.4 ns/op across the five runs, a range of
10.6 ns. **From batch 10 onward, every difference in the table is smaller than
that range.** The sweep therefore cannot rank batch sizes from 10 upward, and
the apparent minimum at 25 is not established.

Execution order was fixed: the control once, then increasing batch sizes, with
`std::chrono` before `__rdtsc` at each size. Method and execution order are
confounded, so differences cannot be attributed to the instruments.

This repository already specified the alternative. Under *Reproducing the
published numbers*, the README has said since October that the 59% GET-path
result came from "five interleaved runs of each build, medians compared", and
that "interleaving the runs matters more than the number of them". Neither the
sweep nor the instrument comparison in section 3 followed it.

What the sweep does support, because the effect is an order of magnitude larger
than the control spread, is that at batch 1 the per-operation clock dominates:
`std::chrono` reports a mean roughly 120 ns above a control of about 63 ns, and
a p50 of 151 ns. That is the finding the October essay was written about, and
it survives the ordering problem on size alone.

Batch 25 remains the setting in the benchmark. It is a choice carried forward
from the October essay, which this sweep does not refute and does not justify.
It yields four times as many samples as batch 100, which matters for a project
named after a tail percentile. Changing batch size also changes the
distribution being sampled, and sample count alone does not determine the
uncertainty of a p99.

## 3. Per-operation clock experiment

Seven runs, GET hit only, same machine, run before the sweep. Control median
63.6 ns/op, from runs of 61.6, 55.8, 64.9, 73.9, 85.0, 57.0 and 63.6 ns/op.

| instrument | median p50 | median p95 | median p99 | median mean | p50 range | median paired mean diff | runs |
|---|---|---|---|---|---|---|---|
| A `steady_clock` per op | 150.0 ns | 240.0 ns | 361.0 ns | 170.3 ns | 150.0-151.0 ns | +105.1 ns | 7 |
| B `__rdtsc` per op | 30.1 ns | 170.3 ns | 250.5 ns | 63.3 ns | 30.1-30.1 ns | +3.2 ns | 7 |
| C `__rdtsc` per 100 ops | 54.1 ns | 70.2 ns | 89.5 ns | 57.5 ns | 53.0-58.6 ns | -3.8 ns | 7 |
| D `__rdtscp`+`lfence` per op | 160.3 ns | 240.5 ns | 350.7 ns | 182.8 ns | 160.3-180.3 ns | +124.9 ns | 7 |

Execution order was fixed at A, B, D, C in every run, so this experiment
carries the same confound as the sweep.

Instrument B reported a p50 of exactly 30.1 ns in all seven runs. At the
calibrated 2.395 ticks/ns that is 72 TSC ticks. A statistic that does not move
at all across seven runs, while the control moved by 29 ns, reflects the
counter resolution and the instrument rather than a precise measurement of the
operation. The same instrument has a median mean of 63.3 ns, within noise of
the control, so its p50 and its mean are not describing the same thing.

## 4. The two harnesses disagree, and the reason is in the source

For the same operation on the same machine, instrument B above reports a p50 of
30.1 ns, while the sweep at batch 1 with `__rdtsc` reports 60.1 ns. At
2.395 ticks/ns those are 72 and 144 ticks.

They do not time the same work:

- `latency_experiment.cpp` closes the timestamp *before* `v->size()` and the
  checksum addition. The timed region is the lookup alone.
- `batch_sweep.cpp` keeps `v->size()`, the checksum addition and the loop step
  inside the timestamps, and indexes through `keys[idx[base + j]]` rather than
  a loop variable.

This is read from the source, not measured. It is a sufficient candidate
explanation for a difference in this direction; it has not been shown to
account for the full factor of two. The same defect appears inside the current
benchmark, where the control loop and the timed region do not contain identical
work either. That is a known flaw in section 1.

## 5. What none of this establishes

- **An individual-operation latency distribution.** The percentiles here are
  percentiles of per-operation means over batches of 25. A stall of S ns in one
  batch raises that batch mean by S/25. It is diluted, not erased, and can still
  move the batch tail. Individual-operation percentiles cannot be recovered from
  batch means.
- **That hardware sampling is required.** Measuring individual-operation latency
  needs an experiment that accounts for timestamp overhead, ordering and
  sampling error. No such experiment has been run here.
- **An optimal batch size.** See section 2.
- **That the two clocks are equivalent.** From batch 25 onward their median run
  p50s differ by at most 2 ns, which is a statement about one summary statistic
  under a confounded ordering, not about accuracy. The portable clock is kept
  because it is portable.
- **Anything about other hardware, other allocators, or concurrent access.**
  Every measurement is single-threaded, on one pinned core, on one laptop.

## Open

- Re-run the sweep and the instrument comparison with runs interleaved and
  repeated, so method is not confounded with execution order.
- Match the work inside the control loop to the work inside the timed region.
- Quantify how much of the 72-versus-144-tick gap in section 4 the source
  difference accounts for.
- Explain the run-to-run spread in section 1 before treating any single-run
  number as a result.
