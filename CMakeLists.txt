cmake_minimum_required(VERSION 3.20)

project(P99KV LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(p99kv_store
    src/key_value_store.cpp
)

target_include_directories(p99kv_store PUBLIC include)

target_compile_options(p99kv_store PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Wconversion
    -Wshadow
)

add_executable(p99kv
    src/main.cpp
)

target_link_libraries(p99kv PRIVATE p99kv_store)

enable_testing()

add_executable(p99kv_tests
    tests/key_value_store_test.cpp
)

target_link_libraries(p99kv_tests PRIVATE p99kv_store)

add_test(NAME key_value_store_tests COMMAND p99kv_tests)
