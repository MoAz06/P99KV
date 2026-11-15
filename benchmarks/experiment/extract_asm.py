"""Extract each condition function from `objdump -d -C --no-show-raw-insn` output.

usage: extract_asm.py full.asm conditions.asm   (summary on stdout)
"""
import re, sys

text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
funcs = re.split(r"\n(?=[0-9a-f]+ <)", text)
keep = ("::batched<", "::per_op<", "::freq_probe(", "::warmup(")
out = []
for f in funcs:
    head = f.split("\n", 1)[0]
    if "(anonymous namespace)" not in head or not any(k in head for k in keep):
        continue
    name = re.sub(r"\(anonymous namespace\)::", "", head.split("<", 1)[1].rsplit(">", 1)[0])
    name = re.sub(r"\(Ctx&\)$", "", name).replace("BlockResult ", "")
    lines = f.rstrip("\n").split("\n")[1:]
    ins = [l for l in lines if re.match(r"\s*[0-9a-f]+:\s", l)]
    calls = sorted(set(re.sub(r".*<([^>+]*).*", r"\1", l)[:40] for l in ins if "call" in l))
    clock = sum(1 for l in ins if re.search(r"\b(rdtscp?|lfence)\b|now\(\)", l))
    out.append("=" * 78 + "\n" + f.rstrip("\n") + "\n")
    print("%-42s %4d instructions, %d clock-related, calls: %s" % (name, len(ins), clock, ", ".join(calls)))
open(sys.argv[2], "w", encoding="utf-8").write("\n".join(out))
