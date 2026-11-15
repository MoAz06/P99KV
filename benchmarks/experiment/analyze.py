"""Analysis fixed in BENCHMARKS.md, section 6. Reads benchmarks/results/experiment/run*.txt.

usage: analyze.py benchmarks/results/experiment > benchmarks/results/experiment/analysis.md
"""
import glob, os, re, statistics as st, sys

OPS = 200000
RES = sys.argv[1]
runs = []
for path in sorted(glob.glob(os.path.join(RES, "run*.txt"))):
    txt = open(path, encoding="utf-8").read()
    h = re.search(r"run=(\d+) seed=(\d+).*?ticks_per_ns=([\d.]+)", txt)
    blocks = []
    for m in re.finditer(r"block pos=(\d+) cond=(\S+) batch=(\d+) unit=(\S+) wb_ns=(\d+) wb_ticks=(\d+) reported_sum=(\d+) samples=(\d+) p50=(\d+) p95=(\d+) p99=(\d+)", txt):
        g = m.groups()
        blocks.append(dict(pos=int(g[0]), cond=g[1], batch=int(g[2]), unit=g[3], wb_ns=int(g[4]), wb_ticks=int(g[5]),
                           reported=int(g[6]), samples=int(g[7]), p50=int(g[8]), p95=int(g[9]), p99=int(g[10])))
    runs.append(dict(no=int(h.group(1)), tpn=float(h.group(3)), blocks=blocks))
if not runs:
    sys.exit("no run files")
N = len(runs)

def key(b): return b["cond"] + ("@%d" % b["batch"] if b["batch"] and not b["cond"].startswith("control") else "")
def to_ns(v, unit, tpn): return v / tpn if unit == "ticks" else float(v)

# per run: per condition, whole-block mean (ns/op), reported mean (native and ns), adjacent control reference
per = {}   # key -> list over runs of dict
ctrl = {"control_flat": [], "control_batched": []}   # per run: list of (pos, wb mean ns)
for r in runs:
    bl = r["blocks"]; tpn = r["tpn"]
    byname = {}
    for b in bl:
        if b["cond"].startswith("control"):
            ctrl.setdefault(b["cond"], [])
    cf = {"control_flat": [], "control_batched": []}
    for b in bl:
        if b["cond"] in cf: cf[b["cond"]].append((b["pos"], b["wb_ns"] / OPS))
    for k in cf: ctrl[k].append(cf[k])
    for i, b in enumerate(bl):
        if b["cond"].startswith("control") or b["cond"] == "freq_probe": continue
        prev, nxt = bl[i - 1], bl[i + 1]
        assert prev["cond"].startswith("control") and nxt["cond"].startswith("control") and prev["cond"] == nxt["cond"], (r["no"], b)
        ref = (prev["wb_ns"] + nxt["wb_ns"]) / 2 / OPS
        rep_native = b["reported"] / OPS
        per.setdefault(key(b), []).append(dict(
            run=r["no"], unit=b["unit"], wb=b["wb_ns"] / OPS, rep=rep_native, rep_ns=to_ns(rep_native, b["unit"], tpn),
            ref=ref, ctrl=prev["cond"], p50=b["p50"], p95=b["p95"], p99=b["p99"], wb_raw=b["wb_ns"], samples=b["samples"]))
    byname = None

def sign_rule(vals):
    if len(vals) != 10: return "rule needs n=10, have n=%d" % len(vals)
    s = set((v > 0) - (v < 0) for v in vals)
    if len(s) == 1 and 0 not in s: return "resolved"
    return "not resolved at n=10"

def row(vals, unit=""):
    return "%s | %+.2f | %+.2f to %+.2f | %s" % (" ".join("%+.1f" % v for v in vals), st.median(vals), min(vals), max(vals), sign_rule(vals))

print("# Analysis of the section 6 experiment\n")
print("%d runs. Values per run are listed in run order; median; range; rule outcome.\n" % N)
print("Flags (whole-block time above three times the median of its condition across runs):\n")
flagged = 0
for k, v in per.items():
    med = st.median(x["wb_raw"] for x in v)
    for x in v:
        if x["wb_raw"] > 3 * med:
            print("- run %d, %s: %.1f ns/op against median %.1f" % (x["run"], k, x["wb"], med / OPS)); flagged += 1
if not flagged: print("- none")

print("\n## Primary statistics, per condition (ns/op)\n")
print("| condition | control | statistic | per run | median | range | rule |\n|---|---|---|---|---|---|---|")
for k, v in per.items():
    a = [x["wb"] - x["ref"] for x in v]
    b = [x["rep_ns"] - x["ref"] for x in v]
    c = [x["wb"] - x["rep_ns"] for x in v]
    print("| %s | %s | whole-block minus control | %s |" % (k, v[0]["ctrl"], row(a)))
    print("| %s | %s | reported minus control | %s |" % (k, v[0]["ctrl"], row(b)))
    print("| %s | %s | whole-block minus reported | %s |" % (k, v[0]["ctrl"], row(c)))

def contrast(title, ka, kb, field):
    if ka not in per or kb not in per: return
    va, vb = per[ka], per[kb]
    d = [a[field] - b[field] for a, b in zip(va, vb)]
    unit = "ns" if field in ("rep_ns", "wb") else va[0]["unit"]
    print("| %s | %s minus %s | %s | %s |" % (title, ka, kb, unit, row(d)))

print("\n## Pre-registered contrasts\n")
print("| question | contrast | unit | per run | median | range | rule |\n|---|---|---|---|---|---|---|")
for X in ("chrono", "rdtsc"):
    for bsz in (1, 25):
        contrast("Q1 reported", "per_op_%s_inside" % X, "batched_%s@%d" % (X, bsz), "rep_ns")
        contrast("Q1 whole-block", "per_op_%s_inside" % X, "batched_%s@%d" % (X, bsz), "wb")
for X in ("chrono", "rdtsc", "rdtscp_lfence"):
    contrast("Q2 reported", "per_op_%s_inside" % X, "per_op_%s_outside" % X, "rep")
    contrast("Q2 whole-block", "per_op_%s_inside" % X, "per_op_%s_outside" % X, "wb")
contrast("Q2 loop shape (reported, ticks)", "batched_rdtsc@1", "per_op_rdtsc_inside", "rep")
for bsz in (1, 5, 10, 25, 50, 100):
    contrast("Q3 reported", "batched_chrono@%d" % bsz, "batched_rdtsc@%d" % bsz, "rep_ns")

print("\n## Question 4: control blocks (whole-block ns/op)\n")
for name, lst in ctrl.items():
    if not lst or not lst[0]: continue
    print("### %s\n" % name)
    print("| run | values by position | range | sd |\n|---|---|---|---|")
    sds, means = [], []
    for r, blocks in zip(runs, lst):
        vals = [v for _, v in blocks]
        sd = st.pstdev(vals) if len(vals) > 1 else 0.0
        sds.append(sd); means.append(st.mean(vals))
        print("| %d | %s | %.1f to %.1f | %.2f |" % (r["no"], " ".join("%.1f@%d" % (v, p) for p, v in blocks), min(vals), max(vals), sd))
    print("\nacross-run median of within-run sd: %.2f ns; between-run sd of per-run means: %.2f ns\n" % (st.median(sds), st.pstdev(means) if N > 1 else 0.0))
    print("The within-run spread is a description of drift and is not a bound on any paired difference.\n")

print("\n## Descriptive percentiles (native unit; per-operation rows are percentiles of instrumented single intervals, batched rows of batch means)\n")
print("| condition | unit | kind | median of run p50 | p50 range | median of run p95 | median of run p99 | p99 range |\n|---|---|---|---|---|---|---|---|")
for k, v in per.items():
    kind = "single-op" if k.startswith("per_op") else "batch mean" if k.startswith("batched") else "-"
    p50 = [x["p50"] for x in v]; p95 = [x["p95"] for x in v]; p99 = [x["p99"] for x in v]
    scale = 1.0
    if k.startswith("batched"): scale = float(k.split("@")[1])
    f = lambda a: a / scale
    print("| %s | %s | %s | %.1f | %.1f to %.1f | %.1f | %.1f | %.1f to %.1f |" % (
        k, v[0]["unit"], kind, f(st.median(p50)), f(min(p50)), f(max(p50)), f(st.median(p95)), f(st.median(p99)), f(min(p99)), f(max(p99))))

print("\n## Frequency probe (adds per tick)\n")
for r in runs:
    fp = [b for b in r["blocks"] if b["cond"] == "freq_probe"]
    print("- run %d: %s" % (r["no"], " ".join("%.3f@%d" % (50000000 / b["reported"], b["pos"]) for b in fp)))
