#include <iostream>
#include <unordered_map>
#include <string>
#include <optional>

class KeyValueStore {
    private:
        std::unordered_map<std::string, std::string> data_;
    public:
        void set(const std::string& key, const std::string& value){
            data_[key] = value;
        }

        bool contains(const std::string& key) const {
            return data_.find(key) != data_.end();
        }
        std::optional<std::string> get(const std::string& key) const {
            auto it = data_.find(key);
            if (it == data_.end()) {
                return std::nullopt;
            } else{
                return it->second;
            }
        }
};

int main() {
    KeyValueStore store;
    store.set("naam", "mohamed");
    std::optional<std::string> results = store.get("naam");
    if(results.has_value()) {
        std::cout << results.value() << '\n';
    } else{
        std::cout << "found nothing\n";
    }
    std::optional<std::string> missing = store.get("leeftijd");
    if(missing.has_value()) {
        std::cout << missing.value() << '\n';
    } else{
        std::cout << "found nothing\n";
    }
}
