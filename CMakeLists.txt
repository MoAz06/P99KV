cmake_minimum_required(VERSION 3.20)

project(P99KV LANGUAGES CXX)

# A benchmark compiled without optimisation mostly measures the absence of
# optimisation, so pick a sane default when the caller does not. RelWithDebInfo
# is -O2 -g: -O2 matches the published measurements, and -g keeps the binaries
# readable under perf, which is the point of the repository.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
        Debug Release RelWithDebInfo MinSizeRel)
endif()

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

add_executable(p99kv_bench
    benchmarks/kv_benchmark.cpp
)

target_link_libraries(p99kv_bench PRIVATE p99kv_store)

target_compile_options(p99kv_bench PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Wconversion
    -Wshadow
)

add_executable(p99kv_perf
    benchmarks/perf_workload.cpp
)

target_link_libraries(p99kv_perf PRIVATE p99kv_store)

target_compile_options(p99kv_perf PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Wconversion
    -Wshadow
)

# The pre-registered measurement experiment (BENCHMARKS.md, section 6).
# -frecord-gcc-switches stores the flags the compiler actually used in the
# binary, readable with: readelf -p .GCC.command.line <binary>
add_executable(p99kv_experiment
    benchmarks/experiment/latency_experiment.cpp
)

target_link_libraries(p99kv_experiment PRIVATE p99kv_store)

target_compile_options(p99kv_experiment PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Wconversion
    -Wshadow
    -frecord-gcc-switches
)
