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

struct BenchResult {
    double ops_per_second;
    std::uint64_t p50_ns;
    std::uint64_t p95_ns;
    std::uint64_t p99_ns;
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

std::uint64_t percentile(const std::vector<std::uint64_t>& sorted, std::size_t percent) {
    const std::size_t index = (sorted.size() - 1) * percent / 100;
    return sorted[index];
}

BenchResult benchmark_get(KeyValueStore& store,
                          const std::vector<std::string>& keys,
                          const std::vector<std::size_t>& indices) {
    std::size_t checksum = 0;

    for (std::size_t i = 0; i < 10000; ++i) {
        const auto value = store.get(keys[indices[i]]);
        if (value) {
            checksum += value->size();
        }
    }

    const auto throughput_start = Clock::now();
    for (const std::size_t index : indices) {
        const auto value = store.get(keys[index]);
        if (value) {
            checksum += value->size();
        }
    }
    const auto throughput_end = Clock::now();

    std::vector<std::uint64_t> latencies;
    latencies.reserve(indices.size());

    for (const std::size_t index : indices) {
        const auto start = Clock::now();
        const auto value = store.get(keys[index]);
        const auto end = Clock::now();

        if (value) {
            checksum += value->size();
        }

        latencies.push_back(static_cast<std::uint64_t>(
            std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count()));
    }

    std::sort(latencies.begin(), latencies.end());

    const double seconds = std::chrono::duration<double>(throughput_end - throughput_start).count();
    const double ops_per_second = static_cast<double>(indices.size()) / seconds;

    return {
        ops_per_second,
        percentile(latencies, 50),
        percentile(latencies, 95),
        percentile(latencies, 99),
        checksum,
    };
}

BenchResult benchmark_get_missing(KeyValueStore& store,
                                  const std::vector<std::string>& keys,
                                  const std::vector<std::size_t>& indices) {
    std::size_t checksum = 0;

    for (std::size_t i = 0; i < 10000; ++i) {
        checksum += store.get(keys[indices[i]]) != nullptr;
    }

    const auto throughput_start = Clock::now();
    for (const std::size_t index : indices) {
        checksum += store.get(keys[index]) != nullptr;
    }
    const auto throughput_end = Clock::now();

    std::vector<std::uint64_t> latencies;
    latencies.reserve(indices.size());

    for (const std::size_t index : indices) {
        const auto start = Clock::now();
        const auto value = store.get(keys[index]);
        const auto end = Clock::now();

        checksum += value != nullptr;
        latencies.push_back(static_cast<std::uint64_t>(
            std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count()));
    }

    std::sort(latencies.begin(), latencies.end());

    const double seconds = std::chrono::duration<double>(throughput_end - throughput_start).count();
    const double ops_per_second = static_cast<double>(indices.size()) / seconds;

    return {
        ops_per_second,
        percentile(latencies, 50),
        percentile(latencies, 95),
        percentile(latencies, 99),
        checksum,
    };
}

BenchResult benchmark_set(KeyValueStore& store,
                          const std::vector<std::string>& keys,
                          const std::vector<std::size_t>& indices,
                          const std::string& value) {
    for (std::size_t i = 0; i < 10000; ++i) {
        store.set(keys[indices[i]], value);
    }

    const auto throughput_start = Clock::now();
    for (const std::size_t index : indices) {
        store.set(keys[index], value);
    }
    const auto throughput_end = Clock::now();

    std::vector<std::uint64_t> latencies;
    latencies.reserve(indices.size());

    for (const std::size_t index : indices) {
        const auto start = Clock::now();
        store.set(keys[index], value);
        const auto end = Clock::now();

        latencies.push_back(static_cast<std::uint64_t>(
            std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count()));
    }

    std::size_t checksum = 0;
    const auto final_value = store.get(keys[indices.back()]);
    if (final_value) {
        checksum = final_value->size();
    }

    std::sort(latencies.begin(), latencies.end());

    const double seconds = std::chrono::duration<double>(throughput_end - throughput_start).count();
    const double ops_per_second = static_cast<double>(indices.size()) / seconds;

    return {
        ops_per_second,
        percentile(latencies, 50),
        percentile(latencies, 95),
        percentile(latencies, 99),
        checksum,
    };
}

void print_result(std::string_view name, const BenchResult& result) {
    std::cout << std::left << std::setw(16) << name
              << std::right << std::fixed << std::setprecision(0)
              << std::setw(12) << result.ops_per_second << " ops/s"
              << "  p50 " << result.p50_ns << " ns"
              << "  p95 " << result.p95_ns << " ns"
              << "  p99 " << result.p99_ns << " ns"
              << '\n';
}

int main() {
    constexpr std::size_t entry_count = 50000;
    constexpr std::size_t operation_count = 200000;

    const auto keys = make_strings("key-", entry_count);
    const auto missing_keys = make_strings("missing-", entry_count);
    const auto indices = make_indices(operation_count, entry_count);
    const std::string initial_value(32, 'a');
    const std::string updated_value(32, 'b');

    KeyValueStore store;
    for (const auto& key : keys) {
        store.set(key, initial_value);
    }

    std::cout << "entries: " << entry_count << '\n';
    std::cout << "operations per measurement: " << operation_count << '\n';

    const auto get_hit = benchmark_get(store, keys, indices);
    const auto get_miss = benchmark_get_missing(store, missing_keys, indices);
    const auto set_overwrite = benchmark_set(store, keys, indices, updated_value);

    print_result("GET hit", get_hit);
    print_result("GET miss", get_miss);
    print_result("SET overwrite", set_overwrite);

    std::cout << "checksum: "
              << get_hit.checksum + get_miss.checksum + set_overwrite.checksum
              << '\n';

    return 0;
}
