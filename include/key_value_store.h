#pragma once

#include <string>
#include <unordered_map>

class KeyValueStore {
public:
    void set(const std::string& key, const std::string& value);
    bool contains(const std::string& key) const;
    const std::string* get(const std::string& key) const;
    bool erase(const std::string& key);

private:
    std::unordered_map<std::string, std::string> data_;
};
