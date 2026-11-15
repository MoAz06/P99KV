# Benchmarks

This file records what has been measured on this project, under what conditions,
and what those measurements do and do not establish. It exists because
[A Timer Is Not a Measurement](https://moaz06.com/writing/a-timer-is-not-a-measurement)
(3 October 2026) promised it, alongside two other changes that have since
landed: batched sampling, and a default build type in `CMakeLists.txt`.

Numbers here are from one machine. They are not a claim about this key-value
store in general, and they are not comparable to numbers from any other machine.

Three data sets appear below. Only the first is committed with a header. The
other two were produced on 15 November 2026 in the same working session as the
first, by two standalone harnesses outside this repository, and their raw
outputs carry no header at all. Where this file says "same machine" or "same
day" about them, that rests on the author's record of the session, not on
anything in the files.

## Environment

Recorded for section 1, in the hand-written header of its raw output file. The
rows are transcribed, not program output: `p99kv_bench` prints none of them,
and no `lscpu`, `uname -r` or `g++ --version` capture is committed.

| | |
|---|---|
| CPU | AMD Ryzen 9 8940HX, 32 logical cores, as seen from the WSL2 guest |
| OS | Ubuntu 26.04.1 LTS under WSL2, kernel 6.18.33.2-microsoft-standard-WSL2 |
| Compiler | g++ (Ubuntu 15.2.0-16ubuntu1) 15.2.0 |
| Build | `CMAKE_BUILD_TYPE=RelWithDebInfo`, whose GNU defaults are `-O2 -g -DNDEBUG`; the compile command itself was not captured |
| Pinning | `taskset -c 2`, which under WSL2 pins to a guest vCPU; the hypervisor decides which host core runs it |

For sections 2 and 3 none of this is recorded in the raw outputs. The
section 3 harness carries a build line in its own header, `g++ -O2 -std=c++20`,
invoked directly and without CMake. The section 2 harness carries none. Pinning
is recorded for neither. The TSC flags `constant_tsc`, `nonstop_tsc` and
`rdtscp` were read from `/proc/cpuinfo` during the session but not saved to any
file; the only file-level support is that instrument D in section 3 executed
`__rdtscp` in all seven runs.

The CPU frequency is governed by the Windows host, not by anything readable in
the guest, and SMT sibling activity and vCPU placement are likewise outside the
guest's view. None of these were fixed or observed for any run below.

## Reproducing section 1

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build -j
for i in 1 2 3 4 5 6 7; do taskset -c 2 ./build/p99kv_bench; done
```

This reproduces the section 1 procedure only: seven consecutive runs on one
pinned vCPU. Report the median and the min-max range of each column across the
runs, as the section 1 table does. The header and the `--- run N ---`
separators in the committed raw file were added by a shell wrapper that is not
in this repository. Expect the spread, not the medians: on this evidence a
single run differs from another by tens of percent in some columns, so matching
any one number is not reproduction, and no pass/fail threshold is defined. The
source revision of the committed runs is the commit that added the raw file.

Sections 2 and 3 cannot be reproduced from this repository. Their harnesses are
not committed.

## 1. Current benchmark, 7 consecutive runs

200,000 operations per measurement against 50,000 entries, batch size 25,
8,000 samples per measurement. Each measurement executes 10,000 untimed warmup
operations, then the throughput loop, then the batched loop, over the same
fixed-seed index sequence, in that fixed order; the three operations run in the
fixed order GET hit, GET miss, SET overwrite. All seven runs started within two
seconds of each other. Raw output:
[`benchmarks/results/2026-11-15-ryzen9-8940hx-wsl2.txt`](benchmarks/results/2026-11-15-ryzen9-8940hx-wsl2.txt).

Every percentile in this table is a percentile of per-operation means over
batches of 25, not of individual operations. "Median p50" is the median over
the seven runs of each run's p50, where a run's p50 is the 4,000th of its 8,000
sorted batch means; likewise for the other columns.

| operation | median ops/s | ops/s range | median p50 | p50 range | median p95 | median p99 | p99 range |
|---|---|---|---|---|---|---|---|
| GET hit | 12.50M | 8.44-13.25M | 76.6 ns | 72.2-77.3 ns | 101.0 ns | 117.0 ns | 97.0-205.2 ns |
| GET miss | 10.60M | 9.43-14.89M | 69.7 ns | 65.7-73.0 ns | 89.4 ns | 109.8 ns | 89.0-216.0 ns |
| SET overwrite | 10.32M | 7.09-10.73M | 86.2 ns | 83.8-89.0 ns | 116.2 ns | 152.3 ns | 142.7-164.3 ns |

The instrument is `std::chrono::steady_clock`. The empty-clock diagnostic the
benchmark prints, the median interval between two consecutive `now()` calls
divided by 25, was 1.60 ns/op in six runs and 1.64 in one: 40 and 41 ns per
pair.

### Run-to-run spread

The fastest GET hit run was 57% faster than the slowest, measured as
(max - min) / min; the slowest was 36% below the fastest. GET hit p99 varied by
a factor of 2.12. That holds for the throughput and GET p99 columns. The p50
columns reproduced to within 6-11% across the same seven runs, and SET p99 to
within 15%. So on this evidence a single run of the benchmark does not
reproduce its throughput or GET p99 to better than tens of percent, while its
p50 of batch means moved far less. No change to this project should be
accepted or rejected on the strength of one run.

The slow runs are not the same runs for every operation. By reciprocal
throughput, GET hit is slow in runs 4 and 5 (118.5 and 116.6 ns/op against
75.5-81.3 in the others); GET miss is slow in runs 1, 4, 5 and 7; SET overwrite
is slow in runs 1 and 7 and at its fastest in run 5. Since the three operations
execute one after another inside each run, the slow stretches do not coincide
with run boundaries. They have not been explained.

For GET hit, reciprocal throughput exceeds the run's p50 of batch means by
1.5 to 4.7 ns in five runs and by 41.2 and 39.3 ns in runs 4 and 5, where it
also exceeds those runs' batch p95 (107.8 and 107.0 ns). That compares an
average with percentiles, and an average can exceed a p95 on the strength of
the top 5% alone. The benchmark does not print the batched pass's mean or
total time, so whether the batched pass of runs 4 and 5 escaped the slow
stretch or carried it in its tail is not established.

The `ops/s` and percentile columns measure different things, in a fixed order,
and agreement between them validates neither. Reciprocal median GET hit
throughput, 80.0 ns/op, is an average over a loop containing index access, the
operation, result consumption and loop overhead, with no clock inside it. The
median run p50 of 76.6 ns is the middle of a distribution of batch means from a
separate, later pass.

## 2. Exploratory batch-size sweep

Harness: `batch_sweep.cpp`, a standalone program outside this repository. Five
runs, GET hit only, 200,000 operations per measurement, 15 November 2026. Raw
output is not committed, and carries no header. Build flags, pinning and the
TSC calibration constant are not recorded; the README states `-O2` and
`taskset` for it. Its `__rdtsc` readings are converted to nanoseconds with a
constant calibrated against `steady_clock` over a 200 ms spin, so the two
clocks in this table share a time base by construction, and the constant the
harness used was not printed.

Execution order within a run was fixed: an untimed warmup, then the control
once, then batch sizes 1, 5, 10, 25, 50, 100, 250, 1000 in that order, with
`std::chrono` before `__rdtsc` at each size. The control is the throughput
loop, which contains no clock. Its five values, in run order, were 60.1, 63.2,
63.7, 70.4 and 59.8 ns/op; median 63.2.

In the batch-1 rows each sample is one timed operation, so the percentiles are
of individually timed operations with the clock pair inside the interval. In
every other row each sample is a batch mean. One label covers both below.
"Median p50" is the median over five runs of each run's p50.

| batch | clock | median p50 | p50 range | median p99 | median mean | diff of medians | median paired diff | samples/run |
|---|---|---|---|---|---|---|---|---|
| 1 | chrono | 151.0 ns | 150.0-160.0 ns | 430.0 ns | 184.6 ns | +121.4 ns | +123.1 ns | 200,000 |
| 1 | rdtsc | 60.1 ns | 60.1-80.2 ns | 350.7 ns | 95.1 ns | +31.9 ns | +31.6 ns | 200,000 |
| 5 | chrono | 76.2 ns | 72.0-84.2 ns | 162.2 ns | 87.4 ns | +24.2 ns | +24.9 ns | 40,000 |
| 5 | rdtsc | 58.1 ns | 56.1-80.2 ns | 132.3 ns | 72.5 ns | +9.3 ns | +9.3 ns | 40,000 |
| 10 | chrono | 63.1 ns | 62.1-69.1 ns | 110.2 ns | 69.3 ns | +6.1 ns | +9.0 ns | 20,000 |
| 10 | rdtsc | 58.1 ns | 55.1-68.1 ns | 104.2 ns | 61.9 ns | -1.3 ns | +1.9 ns | 20,000 |
| 25 | chrono | 57.7 ns | 57.3-59.7 ns | 99.4 ns | 66.0 ns | +2.8 ns | +1.5 ns | 8,000 |
| 25 | rdtsc | 55.7 ns | 54.9-56.5 ns | 104.2 ns | 63.4 ns | +0.2 ns | +2.0 ns | 8,000 |
| 50 | chrono | 56.7 ns | 56.1-57.5 ns | 105.0 ns | 68.2 ns | +5.0 ns | +8.0 ns | 4,000 |
| 50 | rdtsc | 54.7 ns | 53.7-57.1 ns | 95.8 ns | 58.4 ns | -4.8 ns | -2.0 ns | 4,000 |
| 100 | chrono | 55.5 ns | 54.7-56.7 ns | 108.3 ns | 62.2 ns | -1.0 ns | -1.5 ns | 2,000 |
| 100 | rdtsc | 55.1 ns | 53.4-56.4 ns | 96.8 ns | 61.5 ns | -1.7 ns | -2.9 ns | 2,000 |
| 250 | chrono | 54.1 ns | 53.7-58.7 ns | 169.9 ns | 61.1 ns | -2.1 ns | -1.4 ns | 800 |
| 250 | rdtsc | 55.5 ns | 53.2-58.1 ns | 169.8 ns | 67.5 ns | +4.3 ns | +4.9 ns | 800 |
| 1000 | chrono | 53.5 ns | 53.4-58.4 ns | 121.1 ns | 58.6 ns | -4.6 ns | -1.5 ns | 200 |
| 1000 | rdtsc | 54.5 ns | 53.2-55.8 ns | 130.9 ns | 63.0 ns | -0.2 ns | -3.2 ns | 200 |

The *difference of medians* subtracts the median control from the median run
mean; it answers "how far apart are the typical values". The *median paired
difference* takes mean minus control within each run and reports the median of
those five; it answers "how far apart were they in a typical run". Neither is a
difference of p50s: the control is a single average and has no p50.

### Per-run paired differences

The five values behind each median, taken from the harness's own column:

| batch | clock | mean minus that run's control, runs 1-5 | min | max |
|---|---|---|---|---|
| 1 | chrono | +123.1 +124.4 +127.8 +114.3 +109.7 | +109.7 | +127.8 |
| 1 | rdtsc | +31.2 +50.4 +31.6 +14.9 +35.3 | +14.9 | +50.4 |
| 5 | chrono | +24.9 +24.0 +27.4 +24.3 +27.5 | +24.0 | +27.5 |
| 5 | rdtsc | +6.9 +9.3 +14.0 -7.9 +29.0 | -7.9 | +29.0 |
| 10 | chrono | +9.0 +20.3 +13.7 -1.1 +8.8 | -1.1 | +20.3 |
| 10 | rdtsc | -0.7 +6.0 +17.6 -8.4 +1.9 | -8.4 | +17.6 |
| 25 | chrono | +5.9 +10.4 +1.5 -4.2 +1.1 | -4.2 | +10.4 |
| 25 | rdtsc | +7.5 +2.4 -0.3 -8.5 +2.0 | -8.5 | +7.5 |
| 50 | chrono | +8.0 +11.7 -1.6 -6.8 +9.4 | -6.8 | +11.7 |
| 50 | rdtsc | -2.0 -3.8 +3.8 -12.8 -1.4 | -12.8 | +3.8 |
| 100 | chrono | -0.1 -4.2 -1.5 -4.5 +7.1 | -4.5 | +7.1 |
| 100 | rdtsc | +1.4 -7.3 -2.9 -6.3 +6.5 | -7.3 | +6.5 |
| 250 | chrono | +6.0 -6.7 +0.2 -9.2 -1.4 | -9.2 | +6.0 |
| 250 | rdtsc | +7.4 -5.4 +4.9 -12.1 +15.9 | -12.1 | +15.9 |
| 1000 | chrono | -1.5 -5.6 +3.2 +0.2 -3.8 | -5.6 | +3.2 |
| 1000 | rdtsc | +3.3 -7.6 -0.7 -4.9 -3.2 | -7.6 | +3.3 |

### What this sweep does and does not support

From batch 10 onward the five values straddle zero in every row, so the sign of
the difference is not determined for those rows. That boundary is not a property
of the rows. One control reading is shared by all sixteen rows of a run, and
run 4's control, 70.4 ns/op, sits 6.7 ns above every other; run 4 holds the
minimum paired difference in 11 of the 16 rows, and for batch 5 `__rdtsc`,
batch 10 `std::chrono` and batch 25 `std::chrono` it is the only negative
value. No uncertainty has been computed for any of these differences, and none
is claimed. Under the rule fixed in section 6, five runs sharing a sign would
be p = 0.0625, so nothing in this sweep counts as resolved by that rule either.

Two features of the design limit even that reading. The control was measured
once, at the start of each run, and every other row ran after it in a fixed
order, so a drift within a run falls differently on the control and on each row
and is not cancelled by pairing. And because method and position are
confounded, a row whose differences do not straddle zero still cannot have its
difference attributed to the method.

Three rows do not straddle zero: batch 1 and batch 5 with `std::chrono`, and
batch 1 with `__rdtsc`. The batch-1 `std::chrono` setup reported a mean 109.7
to 127.8 ns above the control in each of the five runs. That is an observed
difference between two setups that differ in method, in position, and in loop
structure: the control is one range-for over the index vector calling
`store.get(keys[i])`, while every timed row runs a counted inner loop over
`keys[idx[base + j]]` inside the timestamp pair, with a `duration_cast`, a
division and a `push_back` per sample outside it. That loop overhead is paid
once per sample and amortises with batch size exactly as the clock cost does,
so the fall of the difference from batch 1 to batch 25 cannot be read as the
clock's share alone. How much of the batch-1 difference is the clock has not
been established here. The October essay's figure for the instrument came from
a different measurement, two clock calls around an empty statement, and no
measurement here connects that figure to this difference.

The October essay also described the alternative. Its 59% GET-path result came
from "five interleaved runs of each build, medians", and the README, in a
section added on 15 November 2026 (commit `bbdfa7f`), says that "interleaving
the runs matters more than the number of them". The sweep and the experiment in
section 3 were run on that same day and followed neither.

Batch 25 remains the setting in the benchmark. The October essay specified
batching over a block of N operations and named no size; 25 was chosen on
15 November 2026 from this sweep, which does not justify it.
It yields four times as many samples as batch 100, which bears on how finely
the p99 of batch means in section 1 is resolved, and on no individual-operation
percentile. Changing batch size also changes the distribution being sampled,
and sample count alone does not determine the uncertainty of a p99.

## 3. Per-operation clock experiment

Harness: `latency_experiment.cpp`, a standalone program outside this
repository, built with `g++ -O2 -std=c++20` per its own header. Seven runs, GET
hit only, 200,000 operations against 50,000 entries, 15 November 2026, before
the sweep. Raw output is not committed and carries no header; pinning is not
recorded. Each run prints its TSC calibration, 2.395 ticks/ns in all seven.

Execution order was fixed in every run: an untimed warmup, the control once,
then instruments A, B, D, C. The control is the throughput loop, which contains
no clock; its values in run order were 61.6, 55.8, 64.9, 73.9, 85.0, 57.0 and
63.6 ns/op, median 63.6.

Rows A, B and D take one timestamp pair around each `store.get`, so their
percentiles are of 200,000 individually timed operations per run, with the
instrument inside the interval. Row C takes one `__rdtsc` pair per 100
operations, so its percentiles are of 2,000 batch means per run. One set of
column headers covers both kinds.

| instrument | samples/run | median p50 | p50 range | median p95 | median p99 | median mean | mean minus that run's control, runs 1-7 | median; range |
|---|---|---|---|---|---|---|---|---|
| A `steady_clock` per op | 200,000 ops | 150.0 ns | 150.0-151.0 | 240.0 ns | 361.0 ns | 170.3 ns | +107.5 +105.1 +103.3 +103.2 +85.5 +113.3 +112.2 | +105.1; +85.5 to +113.3 |
| B `__rdtsc` per op | 200,000 ops | 30.1 ns | 30.1-30.1 | 170.3 ns | 250.5 ns | 63.3 ns | +5.0 +3.8 +3.2 -3.4 -26.4 +6.3 -0.8 | +3.2; -26.4 to +6.3 |
| C `__rdtsc` per 100 ops | 2,000 batch means | 54.1 ns | 53.0-58.6 | 70.2 ns | 89.5 ns | 57.5 ns | -4.2 -1.0 -3.8 -1.0 -29.4 +2.0 -6.1 | -3.8; -29.4 to +2.0 |
| D `__rdtscp`+`lfence` per op | 200,000 ops | 160.3 ns | 160.3-180.3 | 240.5 ns | 350.7 ns | 182.8 ns | +137.9 +117.5 +124.9 +136.6 +90.0 +125.8 +112.8 | +124.9; +90.0 to +137.9 |

The last two columns are not like-for-like differences and are not the cost of
the instrument. The control's timed region contains the lookup, `if (v)
checksum += v->size()` and the loop step, timed once around all 200,000
operations. A, B and D take their second timestamp immediately after
`store.get`, before `v->size()` and the checksum addition, so their intervals
contain the lookup and the instrument and exclude result consumption and the
loop step. C keeps consumption and the inner loop inside its pair and indexes
through `keys[idx[base + j]]`, the sweep's shape. A negative value in those
columns, as for B and C, is consistent with work excluded from the timed region
and says nothing about the instrument being free.

### What the raw values show

Every per-operation percentile from a TSC-based instrument, in every run, is an
integer multiple of 24 TSC ticks, 10.02 ns at this calibration: B's p50 is
72 ticks in all seven runs, its p95 and p99 range over 360-456 and 480-696
ticks, and D's values are likewise multiples of 24. A's per-operation
percentiles, from `steady_clock`, are all within 1 ns of a multiple of 10 ns
(150, 151, 220, 240, 260, 281, 311, 330, 331, 361, 370, 411). No reported
per-operation percentile between grid points occurs in either raw file, and
the sweep's batch-1 `__rdtsc` p50s are 6, 8, 6, 6 and 7 times 24 ticks. The batched rows (C here,
batch 5 and up in section 2) do not sit on the grid, since each sample is
divided by its batch size. The raw files hold rounded percentiles and
means, not samples, so this is a pattern in the reported percentiles; it does
not show that intermediate sample values were absent or impossible. This file
asserts nothing about what produces the pattern. It is recorded because every
reported per-operation percentile lies on it.

A fixed p50 with a moving mean is not specific to instrument B. A's p50 was
150.0 ns in six runs and 151.0 in one, with its mean ranging 160.9-177.1; D's
p50 was 160.3 in six runs and 180.3 in one, with its mean ranging 173.3-210.5.
The batched row C does not show it. B's upper tail did move between runs: its
p95 ranged 150.3-190.4 ns and its p99 200.4-290.5 ns while its p50 stayed at
72 ticks. None of this has been explained, and this file does not choose
between a skewed distribution whose tail varies and an artefact of the
instrument; nothing measured here distinguishes those.

In run 5 the control, measured once at the start, was at its highest, 85.0 ns,
and the paired difference of every instrument was at its lowest in that run:
A +85.5, B -26.4, C -29.4, D +90.0. That singles out that run's control block,
not any instrument. In the other six runs B's mean and the control rank almost
alike.

## 4. The two harnesses report different p50s, and their timed regions differ in the source

Instrument B above reports a p50 of 30.1 ns in all seven runs, 72 ticks. The
sweep at batch 1 with `__rdtsc` reports run p50s of 60.1, 80.2, 60.1, 60.1 and
70.1 ns: 144, 192, 144, 144 and 168 ticks, median 144. The per-run ratio to B
is 2.0, 2.66, 2.0, 2.0 and 2.33. The tick figures for the sweep assume its
unrecorded calibration equalled the other harness's 2.395 ticks/ns.

In the source, the two per-operation `__rdtsc` loops differ in what sits
between the two reads in program order:

- `latency_experiment.cpp`, instruments A, B and D, close the timestamp
  *before* `v->size()` and the checksum addition. In program order the region
  between the reads is `keys[i]` and the lookup. Instrument C in the same file
  does not do this; it keeps consumption inside, like the sweep.
- `batch_sweep.cpp` keeps `v->size()`, the checksum addition and the loop step
  inside the timestamps, and indexes through `keys[idx[base + j]]` rather than
  a loop variable.

Program order is all the source fixes. `__rdtsc` is not serialising and the
closing read has no data dependence on `v`, so whether the pair brackets the
lookup is not established by either file; instrument D, which pins the same
source region as B with `__rdtscp` + `lfence`, reports a p50 of 160.3 ns where
B reports 30.1.

The source difference is a candidate explanation for a gap in this direction:
more work inside the timestamps would be expected to raise the reading. What
that work costs has not been measured, so how much of the 72-tick gap it
accounts for, if any, is unknown, and the same two raw files give a reason for
doubt. Instrument A and the sweep's batch-1 `std::chrono` row differ in exactly
the same way in the source, yet their median run p50s are 150.0 and 151.0 ns
and their median means 170.3 and 184.6 ns. The same extra work producing a
1 ns p50 shift under one clock and a 30 ns shift under the other is hard to
reconcile with the work being the main term. That is a reason for doubt, not a
measurement of either term. The readings also come from two binaries built
from different source in separate sessions, and nothing here excludes build or
session differences.

One pair of conditions in the two harnesses does time the same work in program
order: instrument C and the sweep's batch-100 `__rdtsc` row, each one
`__rdtsc` pair around 100 lookups with consumption inside, indexed through
`keys[idx[base + j]]`. They report median run p50s of 54.1 and 55.1 ns and
median means of 57.5 and 61.5 ns.

The current benchmark, `benchmarks/kv_benchmark.cpp`, is a different case. There
`checksum += op(...)` sits inside both the control loop and the timed loop, so
result consumption is present in both. What differs is loop structure: the
control is a single range-for over `indices` with a runtime trip count, and the
timed pass is a nested loop that indexes `indices[base + j]` with a
compile-time inner trip count of `BATCH = 25`, which `-O2` may unroll. Whether
the compiler emits different code for the two has not been checked. Section 6
disassembles the loops of its own experiment binary, not `p99kv_bench`;
checking these two loops is a separate step, listed under *Open*.

## 5. What none of this establishes

- **An individual-operation latency distribution.** In section 1, and in the
  batched rows of sections 2 and 3, the percentiles are of per-operation means
  over batches: 25 in the benchmark, 5 to 1000 in the sweep, 100 for
  instrument C. A stall of S ns in one batch raises that batch mean by S/B. It
  is diluted, not erased, and can still move the batch tail. Individual-
  operation percentiles cannot be recovered from batch means. The batch-1 rows
  of section 2 and instruments A, B and D of section 3 do time operations
  individually, but their intervals include the instrument, are not established
  to bracket the lookup when the clock is bare `__rdtsc`, and every reported
  percentile of them lies on a ~10 ns grid; they do not give one either.
- **That hardware sampling is required.** Measuring individual-operation
  latency needs an experiment that accounts for the instrument's own cost,
  for CPU reordering around a non-serialising read, for execution-order
  confounding, and for the error of a finite sample. No experiment here does
  all of that.
- **An optimal batch size.** See section 2.
- **That the two clocks are equivalent, or that they differ.** The medians of
  their run p50s differ by at most 2 ns from batch 25 onward. Per run, the
  `std::chrono` p50 exceeded the `__rdtsc` p50 in all five runs at batch 25
  (by 2.0 to 3.6 ns), in four of five at batch 50 (-0.2 to +2.8 ns), and with
  varying sign from batch 100. `std::chrono` ran before `__rdtsc` at every
  batch size, so a consistent sign is also consistent with position. The two
  also share a time base, since the `__rdtsc` readings are scaled by a
  constant calibrated against `steady_clock`. The portable clock is kept
  because it is portable.
- **The clock's share of the batch-1 difference, the cause of the fixed
  per-operation p50s and the 24-tick grid, the cause of the 72-versus-144-tick
  gap, or the cause of the section 1 spread.** Each is described above and
  none is explained.
- **Anything about other hardware, other allocators, or concurrent access.**
  Every measurement is single-threaded on one laptop, pinned to a guest vCPU
  for section 1 and by unrecorded means, if at all, for sections 2 and 3.

## 6. Planned experiment

Written before the experiment is built, so that what was known in advance stays
separable from what the measurements add. Everything in this section is fixed
now; a departure from it after the data exist is reported as a departure.

### Questions

1. How much does reported latency differ between a per-operation clock and a
   batched clock, when execution order is not confounded with method?
2. What does each placement of result consumption, inside or outside the
   timestamps, report, under each per-operation clock? For bare `__rdtsc`
   placement is a statement about program order only. The serialised pair
   reports what placement yields under an instrument that orders the reads;
   it also changes instruction cost, overlap and register use, so it does not
   decompose the bare `__rdtsc` difference into causes.
3. Once batched, do `std::chrono::steady_clock` and `__rdtsc` differ?
4. What is the spread of the control when it is measured repeatedly within a
   run, rather than once at the start?

### Conditions

- **Control**: the same nested-loop code as the batched conditions, with the
  clock compiled out through a policy type that emits no instructions, so that
  the only intended difference from a batched condition is the clock
  instructions. It runs once per block over all 200,000 indices and is timed
  once around the whole block.
- **Per-operation**: a `steady_clock` pair, a `__rdtsc` pair, and a
  `__rdtscp` + `lfence` pair. Each in two variants, result consumption inside
  the timestamps and outside them, with the placement pinned by
  `asm volatile("" : "+r"(checksum) :: "memory")` on the intended side of the
  closing read. One further `__rdtsc` variant uses the sweep's indexing,
  `keys[idx[base + j]]` with a one-iteration inner loop, so that placement,
  indexing and loop shape can be separated one factor at a time.
- **Batched**: `steady_clock` and `__rdtsc`, at batch sizes 1, 5, 10, 25, 50
  and 100, with result consumption inside the timestamps. Batch size is a
  runtime argument to one function per clock, so all sizes share one machine-
  code loop.

Every condition runs over the same 200,000 indices against the same 50,000
entries, GET hit only, as one `[[gnu::noinline, gnu::noipa]]` function per
condition dispatched through a function-pointer table, so no condition can be
inlined into the driver. All sample storage is allocated and touched before the
first block; per-operation conditions store raw ticks, and conversion to
nanoseconds happens after the run. Each block is preceded by an untimed warmup
of 10,000 operations over the same indices.

### Order

A run is a block list in which every non-control condition appears once and a
control block precedes and follows it, so that each condition block has an
adjacent control on both sides. The order of the conditions is shuffled with
the run number as seed; the realised block order is printed, with each block's
condition, start and end tick, and checksum. Exactly ten runs, numbered 1 to
10, pinned with `taskset -c 2`, same binary throughout. No run and no block is
excluded for any reason; a block whose whole-block time exceeds three times
the median of its condition is flagged in the output and reported as such.

A frequency-probe block, a dependent chain of integer adds timed with
`__rdtsc`, runs at the start and end of every run and once inside the shuffle.
Its value is recorded per block as adds per tick, and only as that. The
disassembly shows which instructions and dependencies were generated, not
how long they took to execute, so a conversion to core cycles would need
evidence this design does not collect, and none is attempted.

### Machine code

Identical source does not guarantee identical machine code. Before any result
is read, the benchmark binary is disassembled with
`objdump -d -C --no-show-raw-insn`, and the body of every condition's function
is committed under `benchmarks/results/`. "Matched" means: the instruction
sequence from the index load through the checksum add is identical to the
control's, with the clock instructions and their result handling as the only
insertions. The clock instructions are enumerated per clock in advance:
`rdtsc; shl; or` and the surrounding moves for `__rdtsc`; the same plus the
`aux` store for `__rdtscp`, and `lfence`; a `call ...now@plt` for
`steady_clock`, whose register saves and reloads count as part of that
instrument's cost and are reported, not treated as a mismatch. A condition
whose body differs otherwise is reported as *not matched* beside its results.
An inside/outside pair whose disassembly does not differ in the placement of
the `size()` load and the add is reported as *contrast void* and question 2 is
left unanswered for that clock. `-g` does not alter code generation; `-DNDEBUG`
and the distribution's default flags can, so the recorded flags are the ones
the compiler reports, not the ones on the command line.

### Evidence saved

- The realised block list and per-block whole-block ticks of every run.
- Raw per-sample ticks of every block, saved outside the repository with their
  SHA-256 recorded in the committed summary, together with a per-block
  histogram of tick values committed in the repository.
- The output of `clock_probe` from the same session, extended to print the
  observed gcd of consecutive `__rdtsc` read deltas, a property of the reads
  that does not establish the counter's resolution, and to time an
  empty `__rdtscp` + `lfence` pair against an empty `__rdtsc` pair.
- `/sys/devices/system/clocksource/clocksource0/current_clocksource`, the
  kernel's detected TSC frequency, `/proc/cpuinfo` flags, `g++ -v`, the exact
  compile and link commands, the compiler's recorded switches via
  `-frecord-gcc-switches`, the predefined macros from `g++ -dM -E`, `ldd` of
  the binary with libstdc++ and glibc versions, the binary's build ID, and the
  git commit of the source. No LTO, no `-march=native`, `-std=c++20`,
  `RelWithDebInfo`.
- The disassembly excerpts.

### Analysis, fixed in advance

- Two per-operation means are defined for every block and both are recorded.
  The *whole-block mean* is the block's elapsed time, taken once around the
  whole block, divided by 200,000; it includes everything the block does,
  sample storage and the untimed halves of every clock call included. The
  *reported mean* is the sum of the block's timed intervals divided by
  200,000; the control has none. Primary statistics, per condition and run:
  the condition's whole-block mean minus the mean whole-block mean of its two
  adjacent control blocks, which is the total cost of instrumenting that
  block; and the condition's reported mean minus the same control reference,
  which is the inflation of the reading. Their difference reduces to the
  whole-block mean minus the reported mean, and is reported under that name.
  It contains loop administration, indexing, result consumption placed
  outside the timestamps, any interruptions there and the untimed parts of the
  clock calls; it does not isolate an instrument component. Secondary
  reference: the run-wide median of the control blocks. All ten values are
  reported per statistic and condition, with median and range.
- Units. `steady_clock` in this libstdc++ counts nanoseconds; `__rdtsc` and
  `__rdtscp` count TSC ticks. A contrast within one clock is computed in that
  clock's unit. A contrast across clocks, and every whole-block statistic, is
  computed in nanoseconds, with ticks converted by one constant calibrated at
  the start of each run against `steady_clock` over a one-second spin, printed
  in the run header and applied after the run.
- Pre-registered contrasts, each as a per-run paired difference of block means
  and each under the rule below: per-operation clock X with consumption inside
  minus batch-1 clock X, and minus batch-25 clock X, for X in {`steady_clock`,
  `__rdtsc`} (question 1); inside minus outside for each of the three
  per-operation clocks, on both means, and the sweep-indexed `__rdtsc` variant
  minus the plain inside variant (question 2); `steady_clock` minus `__rdtsc`
  at each batch size (question 3).
- Per run: every control block value with its position, the within-run range
  and standard deviation, the across-run median of the within-run standard
  deviation, and the between-run standard deviation of the per-run control
  means (question 4). The within-run control spread is reported as a
  description of drift. It is not a bound on any paired difference; the rule
  below is the only criterion.
- Descriptive, per condition and run: p50, p95 and p99 with the estimator
  fixed as the value at index floor((n - 1) p) of the sorted samples, no
  interpolation. Per-operation conditions yield percentiles of instrumented
  single-operation intervals, batched conditions yield percentiles of batch
  means; they are labelled separately, shown side by side, and never
  differenced. The observed gcd of consecutive `__rdtsc` read deltas from
  `clock_probe` is printed beside the per-operation percentiles. A percentile
  that is identical across runs is reported as identical, without
  interpretation.
- A difference is reported as *resolved* only if its ten paired values share a
  sign, with a tie counted as not sharing. That is a two-sided sign test at
  p = 0.002 per contrast. About thirty contrasts are tested without
  multiplicity correction, so a single resolved row among the small-effect
  contrasts is weaker evidence than its nominal p. A difference that is not
  resolved is reported as "not resolved at n = 10, observed range [a, b]" and
  never as "no difference". The sensitivity of the rule depends on the
  distribution of each contrast's own paired differences, which includes the
  variation of the condition and its covariance with the controls; the control
  spread from question 4 does not set it. The only sensitivity statement made
  is the reported range of the ten values. For reference, under normal paired
  differences an effect of two standard deviations shares a sign in all ten
  runs with about 79% probability; that is a reference figure, not a minimum
  detectable effect. The sign test also assumes the ten runs are independent,
  which consecutive runs on one machine need not be.
- The condition-minus-control difference is called the *reported-minus-control
  difference* throughout. Its components, the clock calls' own cost, lost
  overlap across iterations, code-generation differences, sample storage and
  residual position effects, are not separated by this design.
- No individual-operation percentile will be derived from any batched
  condition. No batch size will be called optimal; the batched rows are a
  reading of the trade between the reported-minus-control difference and
  sample count, under the rule above.

### Build findings, recorded before the comparative runs

The harness is `benchmarks/experiment/latency_experiment.cpp`, built as
`p99kv_experiment`; `run.sh` records the environment, disassembles the
binary, runs the clock probe and the ten runs, and hashes the raw samples;
`analyze.py` computes exactly the statistics above and applies the rule only
at n = 10. Building it changed the protocol in the following ways, all fixed
here before any comparative run.

1. **Two controls, one per loop shape.** A per-operation loop is a different
   loop from the batched loop, and the disassembly showed its body cannot be
   matched to the batched control: counter-indexed addressing instead of a
   pointer walk, and a different loop step. So there are two controls, each
   the condition's own loop with the clock compiled out: `control_batched`
   (`batched<NoClock>`, batch 25) and `control_flat` (`per_op<NoClock>`). Every
   condition block sits between two control blocks of its own shape, and the
   adjacent-control reference is taken from those. The whole-block difference
   between the two controls is reported as the loop-shape cost.
2. **The sweep-indexed `__rdtsc` variant is the batch-1 row** of the batched
   family: `keys[idx[base + j]]` with a one-iteration inner loop is exactly
   `batched<TscClock>` at batch 1. It is not a separate function.
3. **Assembly check, batched family.** The inner loop body of
   `batched<NoClock>`, `batched<TscClock>` and `batched<ChronoClock>` is the
   same opcode sequence with registers renamed: index load, context move,
   shift, key address, `call get`, null test, `size` load and add, pointer
   step, compare, branch. The control keeps its sample store. Outside the
   inner loop, per batch: the `__rdtsc` version spills four registers to the
   stack before the inner loop and reloads them after it, plus two register
   moves, because `rdtsc` clobbers `rax` and `rdx`; the `steady_clock` version
   spills one and reloads it around each `call now@plt`. These are per-batch
   costs of the instrument and are reported as such; the batched conditions
   are *matched*.
4. **Assembly check, per-operation family.** The body of all six per-op
   conditions is the same opcode sequence as `control_flat`'s with two
   differences. In every per-op condition the key base is reloaded from a
   stack slot once per operation (`add 0x10(%rsp),%rsi` against `add
   %r12,%rsi` in the control), and `per_op<ChronoClock, false>` also reloads
   the context pointer; both are register pressure from the clock and count as
   instrument cost. `control_flat` itself carries two register moves per
   operation that the conditions do not, forced by the barrier, which biases
   the flat control slower by that amount. Placement is as specified in all
   six: in the *inside* variants the null test, `size` load and add precede
   the closing read; in the *outside* variants they follow it. The two
   `__rdtscp` variants carry a stack-protector canary in prologue and epilogue
   only, because the address of `aux` is taken; nothing in their loops. The
   per-op conditions are reported as *matched up to the reloads named here*.
5. **Frequency probe.** Its loop compiled to `mov, add, mov, cmp, jbe` per
   add, five instructions, not the add alone. It is reported as adds per tick
   with that loop body on record.
6. **Flags the compiler actually used**, from `.GCC.command.line`:
   `-D_FORTIFY_SOURCE=3 -mtune=generic -march=x86-64 -g -O2 -std=c++20
   -fasynchronous-unwind-tables -fstack-protector-strong
   -fstack-clash-protection -fcf-protection -fzero-init-padding-bits=all`.
   `_GLIBCXX_ASSERTIONS` is not defined. glibc 2.43, libstdc++ package
   16-20260322-1ubuntu1.
7. **Evidence.** Whole-block time is taken under both clocks around every
   block. Raw samples are written outside the repository, one file per block,
   and their SHA-256 list is committed; the per-block histograms named above
   are not produced by the harness and are derivable from those files. A run
   is 57 blocks and takes about three seconds.
8. **Clock probe during the build**, pinned, not part of the data set: the
   observed gcd of one million consecutive `__rdtsc` read deltas was 24, with
   minimum non-zero delta 24 and p50 24; the empty `__rdtsc` pair had p50 24
   ticks, the empty `__rdtscp` + `lfence` pair p50 72 ticks, the empty
   `steady_clock` pair p50 40 ns; consecutive `steady_clock` reads had gcd
   1 ns. The probe is re-run by `run.sh` and that output is the committed one.
9. **Smoke runs.** The harness was executed three times with seed 1 while
   checking that it builds, runs, writes samples and that the analysis
   parses. Their numbers were looked at only to see that the three primary
   statistics compute and differ from one another. They are not committed and
   are not part of the data set, which `run.sh` produces fresh.

### Not covered

Other hardware, other allocators, concurrent access, GET miss and SET. Host
frequency management, SMT sibling activity and vCPU placement under WSL2 are
not controlled by this design; the frequency-probe blocks are the only
observable of them it records. The experiment is scoped to the one operation
the earlier experiments measured.

## 7. Results of the section 6 experiment

Ten runs, seeds 1 to 10, 15 November 2026, pinned to vCPU 2, binary built from
commit `b9ca0be`. No run or block was excluded and no block exceeded three
times its condition's median. Everything in this section is read from
[`benchmarks/results/experiment/analysis.md`](benchmarks/results/experiment/analysis.md),
produced by `analyze.py` from the committed per-run output; the environment,
recorded compiler switches, disassembly, clock probe and sample hashes are in
the same directory. "Resolved" means all ten paired values share a sign, as
fixed in section 6; "not resolved" means they do not, and says nothing about
whether a difference exists. Medians are given with the range of the ten
values. Nothing here is explained.

### Against the control of the same loop shape (ns per operation)

| condition | whole-block minus control | reported minus control | whole-block minus reported |
|---|---|---|---|
| per-op `steady_clock`, inside | +156 (135 to 240) resolved | +119 (98 to 195) resolved | +37.0 (36.5 to 45.0) resolved |
| per-op `steady_clock`, outside | +159 (135 to 222) resolved | +121 (97 to 184) resolved | +37.4 (37.0 to 39.6) resolved |
| per-op `__rdtscp`+`lfence`, inside | +163 (127 to 259) resolved | +122 (88 to 217) resolved | +39.6 (38.4 to 42.6) resolved |
| per-op `__rdtscp`+`lfence`, outside | +176 (151 to 226) resolved | +135 (113 to 184) resolved | +38.8 (37.9 to 42.5) resolved |
| per-op `__rdtsc`, inside | +24.9 (17.5 to 95.4) resolved | -1.1 (-8.5 to +64.3) not resolved | +26.9 (23.9 to 33.2) resolved |
| per-op `__rdtsc`, outside | +31.9 (24.9 to 49.8) resolved | +2.5 (-15.1 to +11.6) not resolved | +29.1 (25.1 to 40.2) resolved |
| batched `steady_clock` 1 | +151 (131 to 359) resolved | +113 (94 to 316) resolved | +37.7 resolved |
| batched `steady_clock` 5 | +23.5 (13.9 to 32.9) resolved | +16.1 (6.4 to 25.6) resolved | +7.4 resolved |
| batched `steady_clock` 10 | +13.2 (-8.6 to +32.0) not resolved | +9.2 (-12.3 to +28.3) not resolved | +3.7 resolved |
| batched `steady_clock` 25 | +6.2 (0.9 to 22.4) resolved | +4.7 (-0.5 to +20.9) not resolved | +1.5 resolved |
| batched `steady_clock` 50 | +0.4 (-12.3 to +45.2) not resolved | -0.3 (-13.0 to +44.3) not resolved | +0.7 resolved |
| batched `steady_clock` 100 | +0.0 (-8.3 to +3.1) not resolved | -0.3 (-8.7 to +2.8) not resolved | +0.4 resolved |
| batched `__rdtsc` 1 | +31.1 (17.3 to 36.3) resolved | +16.5 (2.7 to 21.5) resolved | +14.8 resolved |
| batched `__rdtsc` 5 | +5.0 (0.6 to 10.8) resolved | +2.1 (-2.3 to +7.8) not resolved | +2.9 resolved |
| batched `__rdtsc` 10 | +2.0 (-3.6 to +8.8) not resolved | +0.5 (-5.1 to +7.3) not resolved | +1.5 resolved |
| batched `__rdtsc` 25 | +1.6 (-62.6 to +9.1) not resolved | +1.0 (-63.2 to +8.5) not resolved | +0.6 resolved |
| batched `__rdtsc` 50 | -0.3 (-23.2 to +10.2) not resolved | -0.6 (-23.5 to +9.9) not resolved | +0.3 resolved |
| batched `__rdtsc` 100 | -1.0 (-10.5 to +1.4) not resolved | -1.1 (-10.7 to +1.3) not resolved | +0.2 resolved |

The whole-block-minus-reported column is resolved for every condition and is
nearly constant within each: for the per-operation conditions 27 to 40 ns per
operation, and for the batched conditions it falls with batch size (38, 7.4,
3.7, 1.5, 0.7, 0.4 ns for `steady_clock` at batch 1, 5, 10, 25, 50, 100; 14.8,
2.9, 1.5, 0.6, 0.3, 0.2 for `__rdtsc`). It is the time inside the block that
the timestamps do not cover, and section 6 lists what it contains.

### The pre-registered contrasts

- **Question 1.** Per-op `steady_clock` (inside) minus batched `steady_clock`
  at 25: reported +116 ns (93 to 195), whole-block +152 (128 to 238), both
  resolved. Per-op `__rdtsc` (inside) minus batched `__rdtsc` at 25:
  whole-block +26.5 (15.8 to 97.1) resolved; reported +0.9 (-10.3 to +66.6)
  not resolved. Per-op against batch 1 of the same clock: not resolved for
  either clock on either statistic.
- **Question 2.** Inside minus outside is not resolved for any of the three
  per-operation clocks, on the reported mean or on the whole-block mean.
  Batched `__rdtsc` at 1 minus per-op `__rdtsc` inside, the loop-shape
  contrast on the reported mean: +41 ticks (-139 to +61), not resolved.
- **Question 3.** `steady_clock` minus `__rdtsc`, reported mean, same batch
  size: +98 ns at batch 1 (84 to 398), +13.3 at batch 5 (7.1 to 24.7), +12.8
  at batch 10 (0.1 to 42.8), all resolved; +3.9 at batch 25, +4.1 at 50, +0.5
  at 100, not resolved.
- **Question 4.** `control_flat`: within-run standard deviation, median over
  runs, 7.1 ns; between-run standard deviation of the per-run means 6.3 ns.
  `control_batched`: 9.7 and 3.3 ns. In seven of ten runs the first control
  block of the run was its highest or near it (73 to 216 ns per operation
  against 54 to 65 for most blocks). These describe drift and bound nothing.

### Descriptive percentiles

Per-operation `__rdtsc` reported a median run p50 of 72 ticks with consumption
inside and 72 with it outside; batched `__rdtsc` at 1 reported 144. All three
are in one binary, one session, with the disassembly in section 6. The
section 4 candidate, placement of result consumption, does not distinguish
them: both placements report 72. The loop shape does, in the p50; the
corresponding mean contrast is not resolved, as stated under question 2.
Per-operation `steady_clock` reported a median run p50 of 150 to 150.5 ns in
both placements, and `__rdtscp` + `lfence` 384 and 396 ticks. The clock probe
in this session again reported an observed gcd of 24 for consecutive
`__rdtsc` read deltas.

### What this does and does not settle

- Timing single operations with `steady_clock` or with `__rdtscp` + `lfence`
  makes the block 155 to 176 ns per operation slower than the same loop with
  no clock, and the readings they report are 119 to 135 ns per operation
  above the control, on an operation the control runs in about 60 ns. Those
  are resolved under the rule, with the ranges shown.
- A bare `__rdtsc` pair per operation makes the block 25 to 32 ns per
  operation slower, resolved; the readings it reports are not resolved as
  different from the control. The 27 to 29 ns per operation that the block
  pays and the reading does not show is resolved.
- Batching with `steady_clock` reduces the reported inflation from +113 ns at
  batch 1 and +16 at batch 5, both resolved, to values that ten runs do not
  resolve at batch 10 and above. The whole-block cost at batch 25 is resolved
  at +6.2 ns per operation (0.9 to 22.4). "Not resolved" is not "zero".
- Nothing here establishes an individual-operation latency distribution, a
  cause for any number above, an optimal batch size, or that the two clocks
  agree beyond batch 10; it establishes that they differ at batch 1, 5 and 10.
- One machine, one operation, one session, ten consecutive runs.

## Open

- Disassemble the control loop and the timed loop of `p99kv_bench` itself and
  record whether they differ beyond the clock calls.
- Explain the run-to-run spread in section 1 before treating any single-run
  number as a result.
