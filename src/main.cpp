#include "key_value_store.h"

#include <iostream>

int main() {
    KeyValueStore store;

    store.set("naam", "mohamed");

    const auto result = store.get("naam");
    if (result.has_value()) {
        std::cout << result.value() << '\n';
    }

    return 0;
}
