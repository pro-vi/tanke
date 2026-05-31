#!/usr/bin/env python3
"""AC-003 verifier — validate data/seed_bank/seeds.json against the canonical
reachability oracle (loop/test_runner.gd).

Checks, in order:
  1. exactly 12 entries,
  2. partition is 4 easy / 4 medium / 4 hard-or-bug,
  3. every entry is `playable` and its DECLARED tier matches the tier MEASURED
     by re-running test_runner.gd --seed N --json (mutation teeth: flip a
     declared tier and this fails),
  4. declared reachable_cells matches the measured value (catches stale data).

Tier formula (matches the observed natural breakpoints):
  bug_id set            -> hard-or-bug   (flagged regression seed, any rc)
  reachable_cells > 800 -> easy
  500 <= rc <= 800      -> medium
  rc < 500              -> hard-or-bug

Emits `SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)` and exits 0 on
full pass; prints SEED_BANK_FAIL and exits 1 otherwise.

Usage:
  python3 tools/check_seed_bank.py [--godot godot] [--project .] [--seeds PATH]
  python3 tools/check_seed_bank.py --classify 42      # print measured tier
"""
import argparse
import json
import subprocess
import sys

TIERS = ("easy", "medium", "hard-or-bug")


def measure(godot, project, seed):
    """Return (reachable_cells:int, playable:bool) from test_runner.gd."""
    out = subprocess.run(
        [godot, "--headless", "--path", project,
         "--script", "res://loop/test_runner.gd", "--", "--seed", str(seed), "--json"],
        capture_output=True, text=True, timeout=120,
    ).stdout
    for line in out.splitlines():
        line = line.strip()
        if line.startswith("{"):
            d = json.loads(line)
            return int(d["reachable_cells"]), bool(d.get("playable", False))
    raise RuntimeError("no JSON line from test_runner for seed %d" % seed)


def tier_of(rc, bug_id):
    if bug_id is not None:
        return "hard-or-bug"
    if rc > 800:
        return "easy"
    if rc >= 500:
        return "medium"
    return "hard-or-bug"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--godot", default="godot")
    ap.add_argument("--project", default=".")
    ap.add_argument("--seeds", default="data/seed_bank/seeds.json")
    ap.add_argument("--classify", type=int, default=None)
    args = ap.parse_args()

    if args.classify is not None:
        rc, playable = measure(args.godot, args.project, args.classify)
        print("seed %d: reachable_cells=%d playable=%s tier=%s"
              % (args.classify, rc, playable, tier_of(rc, None)))
        return 0

    with open(args.seeds) as f:
        seeds = json.load(f)

    failures = []

    if len(seeds) != 12:
        failures.append("expected 12 seeds, found %d" % len(seeds))

    counts = {t: 0 for t in TIERS}
    for e in seeds:
        t = e.get("tier")
        if t not in counts:
            failures.append("seed %s: unknown tier %r" % (e.get("seed"), t))
        else:
            counts[t] += 1
    for t in TIERS:
        if counts[t] != 4:
            failures.append("partition: %s has %d (expected 4)" % (t, counts[t]))

    for e in seeds:
        seed = e["seed"]
        declared = e["tier"]
        bug_id = e.get("bug_id")
        rc, playable = measure(args.godot, args.project, seed)
        measured = tier_of(rc, bug_id)
        status = "OK"
        if not playable:
            failures.append("seed %d: not playable" % seed); status = "FAIL(unplayable)"
        if measured != declared:
            failures.append("seed %d: declared %s but measured %s (rc=%d)"
                            % (seed, declared, measured, rc)); status = "FAIL(tier)"
        if int(e.get("reachable_cells", -1)) != rc:
            failures.append("seed %d: declared rc=%s but measured %d"
                            % (seed, e.get("reachable_cells"), rc)); status = "FAIL(stale-rc)"
        print("  seed %-5d rc=%-4d declared=%-11s measured=%-11s %s"
              % (seed, rc, declared, measured, status))

    if failures:
        for fmsg in failures:
            print("  FAIL — " + fmsg)
        print("SEED_BANK_FAIL %d failures" % len(failures))
        return 1
    print("SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
