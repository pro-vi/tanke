#!/usr/bin/env python3
"""Iter 026: OG empirical-band overlap auto-check (C12 anchor 5 structural).

Runs the arc-2 procedural oracle at `configs/og_calibrated.tres` across 5
seeds and verifies each output metric falls inside the OG empirical
[min, max] band from `loop/originals/og-metrics.json`.

Excluded by design (per spike-3 + REVIEW-QUEUE #5):
- reachable_cells: arc-2 BFS is viewport-bounded (40x30=1200 cells); OG BFS
  is stage-bounded (26x26=676 cells). Not band-comparable without a
  normalization re-derivation.
- rows_climbed: arc-2 player spawns at scene row 29 (max climb ≈ 29);
  OG spawns at row 24 (max climb ≈ 24 within stage). Absolute scale differs.

Checked (10 metrics):
- vert_persistence, vert_iid_expected, vert_structure_lift
- cc_count, cc_max, cc_avg
- density_brick, density_steel, density_grass, density_water
  (arc-2 counts / 1200 vs OG counts / 676 — fraction-comparable)

Sentinel: BAND_CHECK_OK on success (>=80% in-band threshold).

CLI:
    python3 tools/band_check.py [--config CONFIG] [--seeds N N N...] [--quiet]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

# arc-2 procedural grid for density normalization (40 wide × 30 tall).
ARC2_GRID_TOTAL = 1200

# Metrics we band-check (must exist in both arc-2 oracle JSON and OG
# og-metrics.json summary).
SCALAR_METRICS = [
    "vert_persistence",
    "vert_iid_expected",
    "vert_structure_lift",
    "cc_count",
    "cc_max",
    "cc_avg",
]

DENSITY_METRICS = ["brick", "steel", "grass", "water"]

DEFAULT_SEEDS = [42, 100, 314, 1000, 31337]
DEFAULT_CONFIG = "res://configs/og_calibrated.tres"
BAND_PASS_THRESHOLD = 0.80  # 80% of metric-seed pairs must be in-band


def load_og_bands(path: Path) -> dict[str, dict[str, float]]:
    """Returns {metric_name: {min, max}} flattened from og-metrics.json summary."""
    data = json.loads(path.read_text())
    bands: dict[str, dict[str, float]] = {}
    for metric in SCALAR_METRICS:
        stats = data["summary"]["per_metric"].get(metric)
        if not stats:
            print(f"WARN: metric '{metric}' missing from og-metrics summary", file=sys.stderr)
            continue
        bands[metric] = {"min": stats["min"], "max": stats["max"]}
    for terrain in DENSITY_METRICS:
        stats = data["summary"]["per_density"].get(terrain)
        if not stats:
            print(f"WARN: density '{terrain}' missing from og-metrics summary", file=sys.stderr)
            continue
        bands[f"density_{terrain}"] = {"min": stats["min"], "max": stats["max"]}
    return bands


def run_oracle(seed: int, config: str) -> dict:
    """Run godot --headless test_runner.gd with seed + config; return JSON dict."""
    cmd = [
        "godot", "--headless", "--path", ".",
        "--script", "res://loop/test_runner.gd",
        "--", "--seed", str(seed), "--config", config, "--json",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    for line in proc.stdout.split("\n"):
        if line.startswith("{"):
            return json.loads(line)
    raise RuntimeError(f"no JSON output from oracle seed={seed}: {proc.stdout[-300:]}")


def metric_values_from_oracle(d: dict) -> dict[str, float]:
    """Extract band-checkable metric values from oracle JSON. Densities
    derived from counts / ARC2_GRID_TOTAL to match OG's fraction format."""
    out: dict[str, float] = {}
    for m in SCALAR_METRICS:
        if m in d:
            out[m] = float(d[m])
    for t in DENSITY_METRICS:
        if t in d:
            out[f"density_{t}"] = float(d[t]) / ARC2_GRID_TOTAL
    return out


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description="OG band-overlap auto-check for C12 anchor 5.")
    p.add_argument("--config", default=DEFAULT_CONFIG,
                   help="Godot resource path to LevelConfig (default: og_calibrated).")
    p.add_argument("--seeds", nargs="+", type=int, default=DEFAULT_SEEDS,
                   help="Procedural seeds to sweep.")
    p.add_argument("--og-metrics", default="loop/originals/og-metrics.json",
                   help="OG empirical-bands artifact (default: iter-12 og-metrics.json).")
    p.add_argument("--quiet", action="store_true", help="Suppress per-seed detail.")
    args = p.parse_args(argv)

    og_path = Path(args.og_metrics)
    if not og_path.exists():
        print(f"ERROR: og-metrics file not found: {og_path}", file=sys.stderr)
        return 2

    bands = load_og_bands(og_path)
    if not args.quiet:
        print(f"OG bands loaded ({len(bands)} metrics): {sorted(bands.keys())}")

    in_band_count = 0
    total_pairs = 0
    per_metric_pass: dict[str, int] = {m: 0 for m in bands}

    for seed in args.seeds:
        if not args.quiet:
            print(f"\n[seed={seed}] running oracle...")
        d = run_oracle(seed, args.config)
        values = metric_values_from_oracle(d)
        for metric, band in bands.items():
            if metric not in values:
                continue
            v = values[metric]
            in_band = band["min"] <= v <= band["max"]
            if in_band:
                in_band_count += 1
                per_metric_pass[metric] += 1
            total_pairs += 1
            if not args.quiet:
                marker = "✓" if in_band else "✗"
                print(f"  {marker} {metric:>22}: {v:>10.4f}  band [{band['min']:.4f}, {band['max']:.4f}]")

    print()
    print(f"=== Band-overlap summary ===")
    print(f"  Total metric-seed pairs: {total_pairs}")
    print(f"  In-band: {in_band_count} ({100 * in_band_count / total_pairs:.1f}%)")
    print(f"  Threshold for PASS: {int(BAND_PASS_THRESHOLD * 100)}%")
    print()
    print(f"  Per-metric pass rate (of {len(args.seeds)} seeds):")
    for metric in sorted(bands):
        n = per_metric_pass[metric]
        status = "SOLID" if n == len(args.seeds) else ("PARTIAL" if n > 0 else "OUT")
        print(f"    {metric:>22}: {n}/{len(args.seeds)} [{status}]")

    pass_rate = in_band_count / total_pairs if total_pairs else 0.0
    if pass_rate >= BAND_PASS_THRESHOLD:
        print()
        print(f"BAND_CHECK_OK  ({100*pass_rate:.1f}% >= {int(BAND_PASS_THRESHOLD*100)}% threshold)")
        return 0
    print()
    print(f"BAND_CHECK_FAIL  ({100*pass_rate:.1f}% < {int(BAND_PASS_THRESHOLD*100)}% threshold)")
    return 1


if __name__ == "__main__":
    sys.exit(main())
