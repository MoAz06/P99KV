// What this measures, and what it does not.
//
// Throughput comes from a loop with no clock calls inside it. Its reciprocal
// is average elapsed time per operation, including index access, result
// consumption and loop overhead. It is not an individual-operation percentile.
//
// Each distribution sample is elapsed batch time divided by BATCH. The
// reported percentiles describe batch means, not individual operations.
// An extra S ns in one batch raises its sample by S / BATCH ns: a stall is
// diluted, not erased, and can still affect the batch tail.
//
// BATCH = 25 gives 8,000 samples for 200,000 operations. In the exploratory
// five-run GET-hit sweep, the median run p50 was 151.0 ns at batch 1 and
// 57.7 ns at batch 25. The corresponding medians of run means were 184.6 ns
// and 66.0 ns, versus a median throughput control of 63.2 ns/op. Their
// differences, +121.4 ns and +2.8 ns, are not p50 errors or median paired
// differences. The sweep used a fixed execution order, so these comparisons
// do not isolate clock overhead or establish an optimal batch size.
//
// std::chrono::steady_clock is retained. Agreement between median p50s from
// this clock and bare rdtsc does not establish either instrument's accuracy.

#include "key_value_store.h"

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <string>
#include <string_view>
#include <vector>

using Clock = std::chrono::steady_clock;

namespace {

constexpr std::size_t ENTRY_COUNT = 50000;
constexpr std::size_t OPERATION_COUNT = 200000;
constexpr std::size_t WARMUP = 10000;
constexpr std::size_t BATCH = 25;

struct BenchResult {
    double ops_per_second;
    double p50_ns;
    double p95_ns;
    double p99_ns;
    std::size_t samples;
    std::size_t checksum;
};

std::vector<std::string> make_strings(std::string_view prefix, std::size_t count) {
    std::vector<std::string> values;
    values.reserve(count);
    for (std::size_t i = 0; i < count; ++i) {
        values.push_back(std::string(prefix) + std::to_string(i));
    }
    return values;
}

std::vector<std::size_t> make_indices(std::size_t count, std::size_t key_count) {
    std::vector<std::size_t> indices;
    indices.reserve(count);

    std::uint64_t state = 0x123456789abcdefULL;
    for (std::size_t i = 0; i < count; ++i) {
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        indices.push_back(static_cast<std::size_t>(state % key_count));
    }

    return indices;
}

double percentile(const std::vector<double>& sorted, std::size_t percent) {
    const std::size_t index = (sorted.size() - 1) * percent / 100;
    return sorted[index];
}

double ns_since(Clock::time_point start, Clock::time_point end) {
    return static_cast<double>(
        std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count());
}

// Runs `op` over every index: once untimed to warm up, once in a bare loop for
// throughput, and once in batches for the distribution. `op` returns a value
// derived from its result for the printed checksum.
template <typename Op>
BenchResult measure(const std::vector<std::size_t>& indices, Op op) {
    std::size_t checksum = 0;

    for (std::size_t i = 0; i < WARMUP && i < indices.size(); ++i) {
        checksum += op(indices[i]);
    }

    const auto throughput_start = Clock::now();
    for (const std::size_t index : indices) {
        checksum += op(index);
    }
    const auto throughput_end = Clock::now();

    std::vector<double> samples;
    samples.reserve(indices.size() / BATCH + 1);

    for (std::size_t base = 0; base + BATCH <= indices.size(); base += BATCH) {
        const auto start = Clock::now();
        for (std::size_t j = 0; j < BATCH; ++j) {
            checksum += op(indices[base + j]);
        }
        const auto end = Clock::now();
        samples.push_back(ns_since(start, end) / static_cast<double>(BATCH));
    }

    std::sort(samples.begin(), samples.end());

    const double seconds =
        std::chrono::duration<double>(throughput_end - throughput_start).count();

    return {
        static_cast<double>(indices.size()) / seconds,
        percentile(samples, 50),
        percentile(samples, 95),
        percentile(samples, 99),
        samples.size(),
        checksum,
    };
}

void print_result(std::string_view name, const BenchResult& result) {
    std::cout << std::left << std::setw(16) << name << std::right << std::fixed
              << std::setprecision(0) << std::setw(12) << result.ops_per_second << " ops/s"
              << std::setprecision(1) << "  p50 " << std::setw(6) << result.p50_ns << " ns"
              << "  p95 " << std::setw(6) << result.p95_ns << " ns" << "  p99 " << std::setw(6)
              << result.p99_ns << " ns" << '\n';
}

// Median empty timestamp interval divided by BATCH. This diagnostic is not
// the complete cost of both clock calls or total measurement distortion.
double empty_clock_interval_per_op_ns() {
    constexpr std::size_t probes = 20000;
    std::vector<double> costs;
    costs.reserve(probes);

    for (std::size_t i = 0; i < 2000; ++i) {
        (void)Clock::now();
    }
    for (std::size_t i = 0; i < probes; ++i) {
        const auto a = Clock::now();
        const auto b = Clock::now();
        costs.push_back(ns_since(a, b));
    }

    std::sort(costs.begin(), costs.end());
    return percentile(costs, 50) / static_cast<double>(BATCH);
}

}  // namespace

int main() {
    const auto keys = make_strings("key-", ENTRY_COUNT);
    const auto missing_keys = make_strings("missing-", ENTRY_COUNT);
    const auto indices = make_indices(OPERATION_COUNT, ENTRY_COUNT);
    const std::string initial_value(32, 'a');
    const std::string updated_value(32, 'b');

    KeyValueStore store;
    for (const auto& key : keys) {
        store.set(key, initial_value);
    }

    const auto get_hit = measure(indices, [&](std::size_t i) -> std::size_t {
        const auto* value = store.get(keys[i]);
        return value ? value->size() : 0;
    });

    const auto get_miss = measure(indices, [&](std::size_t i) -> std::size_t {
        return store.get(missing_keys[i]) != nullptr ? 1 : 0;
    });

    const auto set_overwrite = measure(indices, [&](std::size_t i) -> std::size_t {
        store.set(keys[i], updated_value);
        return 1;
    });

    std::cout << "entries: " << ENTRY_COUNT << '\n';
    std::cout << "operations per measurement: " << OPERATION_COUNT << '\n';
    std::cout << "batch: " << BATCH << " operations per sample, " << get_hit.samples
              << " samples\n";
    std::cout << std::fixed << std::setprecision(2)
              << "median empty clock interval / batch: "
              << empty_clock_interval_per_op_ns() << " ns/op (diagnostic)\n\n";

    print_result("GET hit", get_hit);
    print_result("GET miss", get_miss);
    print_result("SET overwrite", set_overwrite);

    std::cout << "\npercentiles are of per-operation means over batches of " << BATCH
              << ",\nnot of individual operations. A stall is diluted across its batch"
              << "\nand can still affect the tail. Individual-operation percentiles"
              << "\ncannot be recovered from these batch means.\n";

    std::cout << "checksum: "
              << get_hit.checksum + get_miss.checksum + set_overwrite.checksum << '\n';

    return 0;
}
