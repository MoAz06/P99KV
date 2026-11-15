#!/usr/bin/env bash
# Runs the experiment pre-registered in BENCHMARKS.md, section 6.
#
#   benchmarks/experiment/run.sh <workdir-outside-the-repository> [runs]
#
# Committed under benchmarks/results/experiment/: environment, the recorded
# compiler switches, the disassembly of every condition function, the clock
# probe, the per-block output of every run, and the SHA-256 of every raw
# sample file. The raw sample files themselves stay in the workdir.
set -euo pipefail

WORK=${1:?workdir}
RUNS=${2:-10}
CORE=2
REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
RES=$REPO/benchmarks/results/experiment
BUILD=$WORK/build
SAMPLES=$WORK/samples
mkdir -p "$RES" "$BUILD" "$SAMPLES"

cmake -S "$REPO" -B "$BUILD" -DCMAKE_BUILD_TYPE=RelWithDebInfo > "$WORK/cmake.log"
cmake --build "$BUILD" --target p99kv_experiment -j > "$WORK/build.log" 2>&1
BIN=$BUILD/p99kv_experiment

{
  echo "# recorded $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# git commit: $(git -C "$REPO" rev-parse HEAD) (dirty: $(git -C "$REPO" status --porcelain | wc -l) paths)"
  echo "# core: taskset -c $CORE"
  echo; echo "## compile command (compile_commands.json)"
  python3 -c "import json,sys; print(next(e['command'] for e in json.load(open(sys.argv[1])) if e['file'].endswith('latency_experiment.cpp')))" "$BUILD/compile_commands.json"
  echo; echo "## recorded switches (readelf -p .GCC.command.line)"; readelf -p .GCC.command.line "$BIN"
  echo; echo "## build id"; readelf -n "$BIN" | grep "Build ID"
  echo; echo "## g++ -v"; g++ -v 2>&1
  echo; echo "## predefined macros of interest"; g++ -dM -E -x c++ /dev/null -O2 -std=c++20 | grep -E "GLIBCXX_ASSERTIONS|FORTIFY|__OPTIMIZE__" || true
  echo; echo "## ldd"; ldd "$BIN"
  echo; echo "## glibc"; /lib/x86_64-linux-gnu/libc.so.6 | head -1
  echo; echo "## libstdc++ package"; dpkg -s libstdc++6 2>/dev/null | grep -E "^Version" || true
  echo; echo "## uname -a"; uname -a
  echo; echo "## lscpu"; lscpu
  echo; echo "## /proc/cpuinfo flags (cpu0)"; grep -m1 "^flags" /proc/cpuinfo
  echo; echo "## clocksource"; cat /sys/devices/system/clocksource/clocksource0/current_clocksource
  echo; echo "## kernel tsc"; dmesg 2>/dev/null | grep -i tsc || echo "(dmesg not readable)"
} > "$RES/environment.txt"

objdump -d -C --no-show-raw-insn "$BIN" > "$WORK/full.asm"
python3 "$REPO/benchmarks/experiment/extract_asm.py" "$WORK/full.asm" "$RES/conditions.asm" > "$RES/conditions-summary.txt"

taskset -c $CORE "$BIN" --probe > "$RES/clock_probe.txt"

for r in $(seq 1 "$RUNS"); do
  taskset -c $CORE "$BIN" --run "$r" --out "$SAMPLES" > "$RES/run$(printf %02d "$r").txt"
done

(cd "$SAMPLES" && sha256sum *.u64) > "$RES/samples.sha256"
echo "done: $RES"
