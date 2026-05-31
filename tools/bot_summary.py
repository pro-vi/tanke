#!/usr/bin/env python3
"""AC-007 helper — aggregate per-run telemetry JSONs into one summary JSON the
outer loop reads to decide its next iteration.

  python3 tools/bot_summary.py --in <telemetry_dir> --out <summary.json>

Reads every seed_*_bot_*.json in --in and emits:
  run_count       : number of runs aggregated
  runs            : one entry per run (bot_id, seed, death_cause, survival,
                    damage_taken, shells_fired_total, shell_hit_rate, file)
  per_bot         : per-bot aggregates (runs, avg survival, total shells, avg
                    hit rate, death-cause counts)
  per_seed        : per-seed aggregates (runs, avg survival, death-cause counts)
  death_causes    : overall death-cause histogram
  files           : the source filenames
"""
import argparse
import glob
import json
import os


def shells_total(t):
    sf = t.get("shells_fired_per_class", {})
    return sum(int(sf.get(k, 0)) for k in ("AP", "HE", "HEAT", "APCR"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="in_dir", required=True)
    ap.add_argument("--out", dest="out_path", required=True)
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.in_dir, "seed_*_bot_*.json")))
    runs = []
    per_bot = {}
    per_seed = {}
    death_causes = {}

    for path in files:
        with open(path) as f:
            t = json.load(f)
        bot = t.get("bot_id", "?")
        seed = int(t.get("seed", -1))
        cause = t.get("death_cause", "?")
        survival = float(t.get("survival_time_sec", 0.0))
        dmg = int(t.get("damage_taken", 0))
        st = shells_total(t)
        hit = float(t.get("shell_hit_rate", 0.0))

        runs.append({
            "bot_id": bot, "seed": seed, "death_cause": cause,
            "survival_time_sec": survival, "damage_taken": dmg,
            "shells_fired_total": st, "shell_hit_rate": hit,
            "file": os.path.basename(path),
        })

        b = per_bot.setdefault(bot, {"runs": 0, "survival_sum": 0.0,
                                     "shells_total": 0, "hit_sum": 0.0, "death_causes": {}})
        b["runs"] += 1
        b["survival_sum"] += survival
        b["shells_total"] += st
        b["hit_sum"] += hit
        b["death_causes"][cause] = b["death_causes"].get(cause, 0) + 1

        s = per_seed.setdefault(str(seed), {"runs": 0, "survival_sum": 0.0, "death_causes": {}})
        s["runs"] += 1
        s["survival_sum"] += survival
        s["death_causes"][cause] = s["death_causes"].get(cause, 0) + 1

        death_causes[cause] = death_causes.get(cause, 0) + 1

    for b in per_bot.values():
        n = max(b["runs"], 1)
        b["avg_survival_sec"] = round(b.pop("survival_sum") / n, 3)
        b["avg_hit_rate"] = round(b.pop("hit_sum") / n, 3)
    for s in per_seed.values():
        n = max(s["runs"], 1)
        s["avg_survival_sec"] = round(s.pop("survival_sum") / n, 3)

    summary = {
        "run_count": len(runs),
        "runs": runs,
        "per_bot": per_bot,
        "per_seed": per_seed,
        "death_causes": death_causes,
        "files": [os.path.basename(p) for p in files],
    }

    os.makedirs(os.path.dirname(os.path.abspath(args.out_path)), exist_ok=True)
    with open(args.out_path, "w") as f:
        json.dump(summary, f, indent=2)
    print("bot_summary: aggregated %d runs -> %s" % (len(runs), args.out_path))


if __name__ == "__main__":
    main()
