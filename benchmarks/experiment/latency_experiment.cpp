// The experiment pre-registered in BENCHMARKS.md, section 6.
//
// One function per condition, none inlinable into the driver. The control is
// the batched loop with the clock compiled out. Placement of result
// consumption is pinned with empty asm barriers. Batch size is a runtime
// argument. Every block prints its whole-block time under both clocks, the sum
// of its timed intervals, and fixed-estimator percentiles, and writes its raw
// samples to a file outside the repository.
//
//   p99kv_experiment --probe                 clock probe
//   p99kv_experiment --run N --out DIR       one run, seed N

#include "key_value_store.h"

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <numeric>
#include <random>
#include <string>
#include <vector>

#include <x86intrin.h>

namespace {

using u64 = std::uint64_t;
using SteadyClock = std::chrono::steady_clock;

constexpr std::size_t ENTRIES = 50000;
constexpr std::size_t OPS = 200000;
constexpr std::size_t WARMUP = 10000;
constexpr std::size_t CONTROL_BATCH = 25;
constexpr u64 PROBE_ADDS = 50000000;

#define BARRIER() asm volatile("" ::: "memory")

struct ChronoClock {
    static constexpr const char* unit = "ns";
    static inline u64 now() {
        return static_cast<u64>(SteadyClock::now().time_since_epoch().count());
    }
};
struct TscClock {
    static constexpr const char* unit = "ticks";
    static inline u64 now() { return __rdtsc(); }
};
struct TscpClock {
    static constexpr const char* unit = "ticks";
    static inline u64 now() {
        unsigned aux;
        const u64 t = __rdtscp(&aux);
        _mm_lfence();
        return t;
    }
};
struct NoClock {
    static constexpr const char* unit = "none";
    static inline u64 now() { return 0; }
};

struct Ctx {
    KeyValueStore store;
    std::vector<std::string> keys;
    std::vector<std::size_t> idx;
    std::vector<u64> samples;  // pre-sized to OPS and touched before any block
    std::size_t batch = CONTROL_BATCH;
};

struct BlockResult {
    u64 reported_sum;
    std::size_t samples;
    std::size_t checksum;
};

// --- conditions -------------------------------------------------------------

template <class Clock, bool Inside>
[[gnu::noinline, gnu::noipa]] BlockResult per_op(Ctx& c) {
    u64 sum = 0;
    std::size_t ck = 0;
    u64* const samples = c.samples.data();
    const std::size_t* const idx = c.idx.data();
    const std::string* const keys = c.keys.data();
    const KeyValueStore& store = c.store;
    for (std::size_t i = 0; i < OPS; ++i) {
        const u64 s = Clock::now();
        BARRIER();
        const std::string* v = store.get(keys[idx[i]]);
        if constexpr (Inside) {
            ck += v ? v->size() : 0;
            asm volatile("" : "+r"(ck) : : "memory");
        } else {
            asm volatile("" : "+r"(v) : : "memory");
        }
        const u64 e = Clock::now();
        if constexpr (!Inside) {
            asm volatile("" : "+r"(v) : : "memory");
            ck += v ? v->size() : 0;
        }
        samples[i] = e - s;
        sum += e - s;
    }
    return {sum, OPS, ck};
}

template <class Clock>
[[gnu::noinline, gnu::noipa]] BlockResult batched(Ctx& c) {
    u64 sum = 0;
    std::size_t ck = 0;
    std::size_t n = 0;
    const std::size_t batch = c.batch;
    u64* const samples = c.samples.data();
    const std::size_t* const idx = c.idx.data();
    const std::string* const keys = c.keys.data();
    const KeyValueStore& store = c.store;
    for (std::size_t base = 0; base + batch <= OPS; base += batch) {
        const u64 s = Clock::now();
        BARRIER();
        for (std::size_t j = 0; j < batch; ++j) {
            const std::string* v = store.get(keys[idx[base + j]]);
            ck += v ? v->size() : 0;
        }
        asm volatile("" : "+r"(ck) : : "memory");
        const u64 e = Clock::now();
        samples[n++] = e - s;
        sum += e - s;
    }
    return {sum, n, ck};
}

// A dependent chain of adds; the chain is the loop counter, so the loop body is
// the add, a compare and a branch. Reported as adds per tick only.
[[gnu::noinline, gnu::noipa]] BlockResult freq_probe(Ctx&) {
    u64 i = 0;
    const u64 s = __rdtsc();
    BARRIER();
    while (i < PROBE_ADDS) {
        asm volatile("add $1, %0" : "+r"(i));
    }
    BARRIER();
    const u64 e = __rdtsc();
    return {e - s, 0, static_cast<std::size_t>(i)};
}

[[gnu::noinline, gnu::noipa]] std::size_t warmup(Ctx& c) {
    std::size_t ck = 0;
    for (std::size_t i = 0; i < WARMUP; ++i) {
        const std::string* v = c.store.get(c.keys[c.idx[i]]);
        ck += v ? v->size() : 0;
    }
    return ck;
}

// --- condition table --------------------------------------------------------

using CondFn = BlockResult (*)(Ctx&);

struct Cond {
    const char* name;
    CondFn fn;
    std::size_t batch;   // 0 for per-op conditions
    const char* unit;
    bool flat;           // true: bracketed by control_flat; false: by control_batched
};

// Two controls, one per loop shape. Each is the condition's own loop with the
// clock compiled out, so a condition is compared against a control of the same
// shape, and the two controls against each other measure the shape difference.
const Cond CONTROL_BATCHED{"control_batched", &batched<NoClock>, CONTROL_BATCH, "none", false};
const Cond CONTROL_FLAT{"control_flat", &per_op<NoClock, true>, 0, "none", true};
const Cond FREQ{"freq_probe", &freq_probe, 0, "adds_per_tick", false};

std::vector<Cond> conditions() {
    std::vector<Cond> v{
        {"per_op_chrono_inside", &per_op<ChronoClock, true>, 0, "ns", true},
        {"per_op_chrono_outside", &per_op<ChronoClock, false>, 0, "ns", true},
        {"per_op_rdtsc_inside", &per_op<TscClock, true>, 0, "ticks", true},
        {"per_op_rdtsc_outside", &per_op<TscClock, false>, 0, "ticks", true},
        {"per_op_rdtscp_lfence_inside", &per_op<TscpClock, true>, 0, "ticks", true},
        {"per_op_rdtscp_lfence_outside", &per_op<TscpClock, false>, 0, "ticks", true},
    };
    for (const std::size_t b : {1u, 5u, 10u, 25u, 50u, 100u}) {
        v.push_back({"batched_chrono", &batched<ChronoClock>, b, "ns", false});
        v.push_back({"batched_rdtsc", &batched<TscClock>, b, "ticks", false});
    }
    v.push_back(FREQ);
    return v;
}

// --- helpers ----------------------------------------------------------------

std::vector<std::size_t> make_indices(std::size_t count, std::size_t key_count) {
    std::vector<std::size_t> indices;
    indices.reserve(count);
    u64 state = 0x123456789abcdefULL;
    for (std::size_t i = 0; i < count; ++i) {
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        indices.push_back(static_cast<std::size_t>(state % key_count));
    }
    return indices;
}

// index floor((n - 1) p) of the sorted samples, no interpolation
u64 pct(std::vector<u64>& sorted, double p) {
    return sorted[static_cast<std::size_t>(static_cast<double>(sorted.size() - 1) * p)];
}

double calibrate_ticks_per_ns(int seconds) {
    const auto t0 = SteadyClock::now();
    const u64 c0 = __rdtsc();
    while (std::chrono::duration_cast<std::chrono::seconds>(SteadyClock::now() - t0).count() <
           seconds) {
    }
    const u64 c1 = __rdtsc();
    const auto t1 = SteadyClock::now();
    return static_cast<double>(c1 - c0) /
           static_cast<double>(std::chrono::duration_cast<std::chrono::nanoseconds>(t1 - t0).count());
}

void write_samples(const std::string& path, const u64* data, std::size_t n) {
    if (n == 0) return;
    FILE* f = std::fopen(path.c_str(), "wb");
    if (!f) {
        std::fprintf(stderr, "cannot write %s\n", path.c_str());
        std::exit(2);
    }
    std::fwrite(data, sizeof(u64), n, f);
    std::fclose(f);
}

// --- clock probe ------------------------------------------------------------

int probe() {
    constexpr std::size_t N = 1000000;
    std::vector<u64> d(N);
    for (std::size_t i = 0; i < 2000; ++i) (void)__rdtsc();
    {
        u64 prev = __rdtsc();
        for (std::size_t i = 0; i < N; ++i) {
            const u64 t = __rdtsc();
            d[i] = t - prev;
            prev = t;
        }
    }
    u64 g = 0, mn = ~0ULL;
    for (const u64 x : d) {
        g = std::gcd(g, x);
        if (x != 0 && x < mn) mn = x;
    }
    std::sort(d.begin(), d.end());
    std::printf("rdtsc consecutive read deltas: n=%zu observed_gcd=%llu min_nonzero=%llu p50=%llu p99=%llu\n",
                N, (unsigned long long)g, (unsigned long long)mn, (unsigned long long)pct(d, 0.5),
                (unsigned long long)pct(d, 0.99));

    auto empty_pair = [&](const char* name, auto clock) {
        std::vector<u64> v(OPS);
        for (std::size_t i = 0; i < 2000; ++i) (void)clock();
        for (std::size_t i = 0; i < OPS; ++i) {
            const u64 a = clock();
            BARRIER();
            const u64 b = clock();
            v[i] = b - a;
        }
        const double mean = static_cast<double>(std::accumulate(v.begin(), v.end(), u64{0})) /
                            static_cast<double>(OPS);
        std::sort(v.begin(), v.end());
        u64 gg = 0;
        for (const u64 x : v) gg = std::gcd(gg, x);
        std::printf("empty pair %-22s p50=%llu p95=%llu p99=%llu mean=%.2f observed_gcd=%llu\n", name,
                    (unsigned long long)pct(v, 0.5), (unsigned long long)pct(v, 0.95),
                    (unsigned long long)pct(v, 0.99), mean, (unsigned long long)gg);
    };
    empty_pair("rdtsc (ticks)", [] { return TscClock::now(); });
    empty_pair("rdtscp+lfence (ticks)", [] { return TscpClock::now(); });
    empty_pair("steady_clock (ns)", [] { return ChronoClock::now(); });

    std::vector<u64> ns(N);
    for (std::size_t i = 0; i < N; ++i) ns[i] = ChronoClock::now();
    u64 gn = 0;
    for (std::size_t i = 1; i < N; ++i) gn = std::gcd(gn, ns[i] - ns[i - 1]);
    std::printf("steady_clock consecutive read deltas: observed_gcd=%llu ns\n", (unsigned long long)gn);
    std::printf("calibration over 1 s: %.4f ticks/ns\n", calibrate_ticks_per_ns(1));
    return 0;
}

// --- a run ------------------------------------------------------------------

struct Block {
    Cond cond;
};

int run(unsigned run_no, const std::string& out) {
    Ctx c;
    c.keys.reserve(ENTRIES);
    for (std::size_t i = 0; i < ENTRIES; ++i) c.keys.push_back("key-" + std::to_string(i));
    c.idx = make_indices(OPS, ENTRIES);
    c.samples.assign(OPS, 1);  // allocate and touch
    const std::string value(32, 'a');
    for (const auto& k : c.keys) c.store.set(k, value);

    const double tpn = calibrate_ticks_per_ns(1);

    std::vector<Cond> conds = conditions();
    std::mt19937 rng(run_no);
    std::shuffle(conds.begin(), conds.end(), rng);

    // Every condition block sits between two control blocks of its own shape.
    std::vector<Block> blocks;
    blocks.push_back({FREQ});
    for (const Cond& k : conds) {
        if (k.fn == &freq_probe) {
            blocks.push_back({k});
            continue;
        }
        const Cond& ctrl = k.flat ? CONTROL_FLAT : CONTROL_BATCHED;
        blocks.push_back({ctrl});
        blocks.push_back({k});
        blocks.push_back({ctrl});
    }
    blocks.push_back({FREQ});

    std::printf("run=%u seed=%u entries=%zu ops=%zu warmup=%zu control_batch=%zu ticks_per_ns=%.4f\n",
                run_no, run_no, ENTRIES, OPS, WARMUP, CONTROL_BATCH, tpn);
    std::printf("order:");
    for (const Block& b : blocks) std::printf(" %s%s%zu", b.cond.name, b.cond.batch ? "@" : "", b.cond.batch);
    std::printf("\n");

    std::size_t ck_total = 0;
    std::vector<u64> sorted;
    for (std::size_t pos = 0; pos < blocks.size(); ++pos) {
        const Cond& k = blocks[pos].cond;
        c.batch = k.batch ? k.batch : CONTROL_BATCH;
        ck_total += warmup(c);

        const auto wb_ns0 = SteadyClock::now();
        const u64 wb_t0 = __rdtsc();
        const BlockResult r = k.fn(c);
        const u64 wb_t1 = __rdtsc();
        const auto wb_ns1 = SteadyClock::now();
        ck_total += r.checksum;

        const u64 wb_ns = static_cast<u64>(
            std::chrono::duration_cast<std::chrono::nanoseconds>(wb_ns1 - wb_ns0).count());
        u64 p50 = 0, p95 = 0, p99 = 0;
        if (r.samples) {
            sorted.assign(c.samples.begin(), c.samples.begin() + static_cast<std::ptrdiff_t>(r.samples));
            std::sort(sorted.begin(), sorted.end());
            p50 = pct(sorted, 0.50);
            p95 = pct(sorted, 0.95);
            p99 = pct(sorted, 0.99);
            char path[512];
            std::snprintf(path, sizeof path, "%s/run%02u_pos%03zu_%s_b%zu.u64", out.c_str(), run_no, pos,
                          k.name, k.batch);
            write_samples(path, c.samples.data(), r.samples);
        }
        std::printf(
            "block pos=%zu cond=%s batch=%zu unit=%s wb_ns=%llu wb_ticks=%llu reported_sum=%llu "
            "samples=%zu p50=%llu p95=%llu p99=%llu checksum=%zu\n",
            pos, k.name, k.batch, k.unit, (unsigned long long)wb_ns, (unsigned long long)(wb_t1 - wb_t0),
            (unsigned long long)r.reported_sum, r.samples, (unsigned long long)p50,
            (unsigned long long)p95, (unsigned long long)p99, r.checksum);
    }
    std::printf("checksum_total=%zu\n", ck_total);
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    if (argc == 2 && std::strcmp(argv[1], "--probe") == 0) return probe();
    if (argc == 5 && std::strcmp(argv[1], "--run") == 0 && std::strcmp(argv[3], "--out") == 0) {
        return run(static_cast<unsigned>(std::atoi(argv[2])), argv[4]);
    }
    std::fprintf(stderr, "usage: %s --probe | --run N --out DIR\n", argv[0]);
    return 1;
}
