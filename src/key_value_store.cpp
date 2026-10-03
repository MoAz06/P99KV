#include "key_value_store.h"

void KeyValueStore::set(const std::string& key, const std::string& value) {
    data_[key] = value;
}

bool KeyValueStore::contains(const std::string& key) const {
    return data_.find(key) != data_.end();
}

const std::string* KeyValueStore::get(const std::string& key) const {
    const auto it = data_.find(key);
    if (it == data_.end()) {
        return nullptr;
    }

    return &it->second;
}

bool KeyValueStore::erase(const std::string& key) {
    return data_.erase(key) > 0;
}
