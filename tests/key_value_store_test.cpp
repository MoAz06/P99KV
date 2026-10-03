#include "key_value_store.h"

#include <iostream>
#include <string_view>

namespace {

int failures = 0;

void expect(bool condition, std::string_view message) {
    if (!condition) {
        std::cerr << "FAIL: " << message << '\n';
        ++failures;
    }
}

}  // namespace

int main() {
    KeyValueStore store;

    expect(!store.contains("name"), "new store should not contain a missing key");
    expect(!store.get("name").has_value(), "get should return nullopt for a missing key");
    expect(!store.erase("name"), "erasing a missing key should return false");

    store.set("name", "mohamed");
    expect(store.contains("name"), "set should make the key present");
    expect(store.get("name") == std::optional<std::string>{"mohamed"},
           "get should return the stored value");

    store.set("name", "ali");
    expect(store.get("name") == std::optional<std::string>{"ali"},
           "set should overwrite an existing value");

    expect(store.erase("name"), "erasing an existing key should return true");
    expect(!store.contains("name"), "erased key should no longer be present");
    expect(!store.get("name").has_value(), "get after erase should return nullopt");
    expect(!store.erase("name"), "erasing the same key twice should return false");

    if (failures != 0) {
        std::cerr << failures << " test(s) failed\n";
        return 1;
    }

    std::cout << "All key-value store tests passed\n";
    return 0;
}
