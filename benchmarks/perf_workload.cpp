#include "key_value_store.h"

#include <cstdint>
#include <iostream>
#include <string>
#include <string_view>
#include <vector>

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

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "usage: p99kv_perf <get-hit|get-miss|set-overwrite>\n";
        return 1;
    }

    constexpr std::size_t entry_count = 50000;
    constexpr std::size_t index_count = 200000;
    constexpr std::size_t rounds = 25;

    const auto keys = make_strings("key-", entry_count);
    const auto missing_keys = make_strings("missing-", entry_count);
    const auto indices = make_indices(index_count, entry_count);
    const std::string initial_value(32, 'a');
    const std::string updated_value(32, 'b');

    KeyValueStore store;
    for (const auto& key : keys) {
        store.set(key, initial_value);
    }

    const std::string_view mode = argv[1];
    std::size_t checksum = 0;

    if (mode == "get-hit") {
        for (std::size_t round = 0; round < rounds; ++round) {
            for (const std::size_t index : indices) {
                const auto value = store.get(keys[index]);
                if (value) {
                    checksum += value->size();
                }
            }
        }
    } else if (mode == "get-miss") {
        for (std::size_t round = 0; round < rounds; ++round) {
            for (const std::size_t index : indices) {
                checksum += store.get(missing_keys[index]) != nullptr;
            }
        }
    } else if (mode == "set-overwrite") {
        for (std::size_t round = 0; round < rounds; ++round) {
            for (const std::size_t index : indices) {
                store.set(keys[index], updated_value);
            }
        }

        const auto value = store.get(keys[indices.back()]);
        if (value) {
            checksum = value->size();
        }
    } else {
        std::cerr << "unknown workload\n";
        return 1;
    }

    std::cout << "operations: " << index_count * rounds << '\n';
    std::cout << "checksum: " << checksum << '\n';

    return 0;
}
