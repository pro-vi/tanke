#!/usr/bin/env python3
"""Arc-3 → arc-2 metric handshake (criterion 12).

Computes per-stage structural metrics across the 35 canonical BC stages
and emits a JSON artifact (loop/originals/og-metrics.json) that arc-2's
procedural mode can read as empirical-target bands. Metrics mirror
loop/test_runner.gd so the OG numbers are directly comparable to arc-2's
existing oracle output.

Per-stage metrics:
  - counts.{brick,steel,grass,water,ice,empty}: int
  - densities.{...}: float in [0, 1]
  - reachable_cells: BFS-reachable count from canonical Tanks spawn
  - rows_climbed: rows from spawn (canonical row 24) to highest reachable row
  - playable: bool (rows_climbed >= MIN_ROWS_CLIMBED)
  - vert_persistence: fraction of placed cells whose below-neighbor shares terrain
  - vert_iid_expected: observed-distribution P(two random cells share terrain)
  - vert_structure_lift: persistence / iid_expected (arc-2's architectural-cohesion)
  - cc_count, cc_max, cc_avg: connected-component (4-connected, same-terrain)

Cross-stage summary: mean, stdev, min, max per metric across all 35.

CLI:
    python3 tools/og_metrics.py [--out PATH] [--quiet]

Default --out is loop/originals/og-metrics.json (per RUBRIC C12 anchor 2).
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import deque
from pathlib import Path

ROWS = 26
COLS = 26
GRID_TOTAL = ROWS * COLS  # 676

# Tanks ASCII → terrain class (matches scripts/LevelLoader.gd legend).
LEGEND = {
    ".": "empty",
    "#": "brick",
    "@": "steel",
    "%": "grass",
    "~": "water",
    "-": "ice",
}

# BFS-passable: empty + grass + ice (matches arc-2 + arc-3 conventions).
# Brick / steel / water all block tank movement; ice is pass-through per
# iter-3 decision.
PASSABLE_TERRAINS = {"empty", "grass", "ice"}

# Canonical Tanks player spawn: stage col 8, row 24 (= "(8 * tile_size.w,
# 24 * tile_size.h)" from appconfig.h:39-43, iter-4 cite).
SPAWN_COL = 8
SPAWN_ROW = 24
MIN_ROWS_CLIMBED = 10  # mirrors test_runner.gd MIN_ROWS_CLIMBED


def load_stage(stage_number: int, stages_dir: Path) -> list[list[str]]:
    """Return 26×26 grid of terrain-class strings."""
    path = stages_dir / str(stage_number)
    if not path.exists():
        raise FileNotFoundError(f"missing stage source: {path}")
    text = path.read_text().splitlines()
    lines = [ln for ln in text if ln.strip()]
    if len(lines) < ROWS:
        raise ValueError(f"stage {stage_number}: {len(lines)} non-empty rows; need {ROWS}")
    grid: list[list[str]] = []
    for r in range(ROWS):
        row = lines[r]
        if len(row) < COLS:
            raise ValueError(f"stage {stage_number} row {r}: {len(row)} chars; need {COLS}")
        grid.append([LEGEND.get(row[c], "empty") for c in range(COLS)])
    return grid


def _counts(grid: list[list[str]]) -> dict[str, int]:
    counts = {k: 0 for k in ("empty", "brick", "steel", "grass", "water", "ice")}
    for row in grid:
        for cell in row:
            counts[cell] += 1
    return counts


def _densities(counts: dict[str, int]) -> dict[str, float]:
    return {k: round(v / GRID_TOTAL, 6) for k, v in counts.items()}


def _reachability(grid: list[list[str]]) -> dict[str, object]:
    """BFS from canonical Tanks spawn cell (col 8, row 24). Counts cells the
    player can reach by 4-connected moves through PASSABLE_TERRAINS only."""
    visited: set[tuple[int, int]] = set()
    queue: deque = deque([(SPAWN_COL, SPAWN_ROW)])
    while queue:
        col, row = queue.popleft()
        if (col, row) in visited:
            continue
        if not (0 <= col < COLS and 0 <= row < ROWS):
            continue
        if grid[row][col] not in PASSABLE_TERRAINS:
            continue
        visited.add((col, row))
        queue.append((col + 1, row))
        queue.append((col - 1, row))
        queue.append((col, row + 1))
        queue.append((col, row - 1))
    if not visited:
        return {"reachable_cells": 0, "rows_climbed": 0, "playable": False}
    min_row = min(r for _, r in visited)
    rows_climbed = SPAWN_ROW - min_row
    return {
        "reachable_cells": len(visited),
        "rows_climbed": rows_climbed,
        "playable": rows_climbed >= MIN_ROWS_CLIMBED,
    }


def _vert_persistence(grid: list[list[str]]) -> dict[str, float]:
    """Per cell, does the cell directly below carry the same terrain class?
    Matches arc-2 test_runner.gd impl (only considers PLACED cells, i.e.
    non-empty). Returns persistence, iid_expected, structure_lift."""
    placed: list[tuple[int, int, str]] = []
    for r in range(ROWS):
        for c in range(COLS):
            if grid[r][c] != "empty":
                placed.append((c, r, grid[r][c]))
    placed_set: dict[tuple[int, int], str] = {(c, r): t for c, r, t in placed}
    pairs_total = 0
    pairs_same = 0
    for (c, r), t in placed_set.items():
        below = (c, r + 1)
        if below in placed_set:
            pairs_total += 1
            if placed_set[below] == t:
                pairs_same += 1
    vert_persistence = (pairs_same / pairs_total) if pairs_total > 0 else 0.0
    # iid_expected: P(two random placed cells share terrain) given observed distribution
    counts: dict[str, int] = {}
    for _, _, t in placed:
        counts[t] = counts.get(t, 0) + 1
    total_placed = sum(counts.values())
    iid_expected = 0.0
    if total_placed > 0:
        for n in counts.values():
            p = n / total_placed
            iid_expected += p * p
    structure_lift = (vert_persistence / iid_expected) if iid_expected > 0 else 0.0
    return {
        "vert_pairs_total": pairs_total,
        "vert_pairs_same": pairs_same,
        "vert_persistence": round(vert_persistence, 6),
        "vert_iid_expected": round(iid_expected, 6),
        "vert_structure_lift": round(structure_lift, 6),
    }


def _cc_stats(grid: list[list[str]]) -> dict[str, float]:
    """4-connected flood-fill same-terrain regions across placed cells.
    Mirrors test_runner.gd iter-22 impl. Empty cells excluded."""
    placed: dict[tuple[int, int], str] = {}
    for r in range(ROWS):
        for c in range(COLS):
            if grid[r][c] != "empty":
                placed[(c, r)] = grid[r][c]
    visited: set[tuple[int, int]] = set()
    cc_sizes: list[int] = []
    for start in placed:
        if start in visited:
            continue
        terrain = placed[start]
        size = 0
        stack = [start]
        while stack:
            cur = stack.pop()
            if cur in visited:
                continue
            if cur not in placed or placed[cur] != terrain:
                continue
            visited.add(cur)
            size += 1
            x, y = cur
            stack.append((x + 1, y))
            stack.append((x - 1, y))
            stack.append((x, y + 1))
            stack.append((x, y - 1))
        cc_sizes.append(size)
    cc_count = len(cc_sizes)
    cc_max = max(cc_sizes) if cc_sizes else 0
    cc_avg = (sum(cc_sizes) / cc_count) if cc_count > 0 else 0.0
    return {
        "cc_count": cc_count,
        "cc_max": cc_max,
        "cc_avg": round(cc_avg, 4),
    }


def _per_stage(stage_number: int, grid: list[list[str]]) -> dict[str, object]:
    counts = _counts(grid)
    densities = _densities(counts)
    result: dict[str, object] = {
        "stage": stage_number,
        "counts": counts,
        "densities": densities,
    }
    result.update(_reachability(grid))
    result.update(_vert_persistence(grid))
    result.update(_cc_stats(grid))
    return result


def _summary(stages: list[dict[str, object]]) -> dict[str, object]:
    """Mean / stdev / min / max for each numeric metric across the 35 stages."""
    # Pick metric keys from the first stage; only include scalar numerics.
    scalar_keys: list[str] = [
        "reachable_cells", "rows_climbed",
        "vert_persistence", "vert_iid_expected", "vert_structure_lift",
        "cc_count", "cc_max", "cc_avg",
    ]
    density_keys = ["brick", "steel", "grass", "water", "ice", "empty"]
    out: dict[str, object] = {"per_metric": {}, "per_density": {}}

    def _stats(values: list[float]) -> dict[str, float]:
        if not values:
            return {"mean": 0.0, "stdev": 0.0, "min": 0.0, "max": 0.0}
        n = len(values)
        mean = sum(values) / n
        if n > 1:
            var = sum((v - mean) ** 2 for v in values) / (n - 1)
            stdev = math.sqrt(var)
        else:
            stdev = 0.0
        return {
            "mean": round(mean, 6),
            "stdev": round(stdev, 6),
            "min": round(min(values), 6),
            "max": round(max(values), 6),
        }

    for key in scalar_keys:
        out["per_metric"][key] = _stats([float(s[key]) for s in stages])
    for dk in density_keys:
        out["per_density"][dk] = _stats([float(s["densities"][dk]) for s in stages])
    return out


def _arc2_comparison(summary: dict[str, object]) -> dict[str, object]:
    """Compare OG cross-stage means to arc-2's iter-100 baseline (default
    config, seed 42) where the metric is directly comparable. Numbers from
    loop/originals/LEDGER.md iter 000 substrate baseline."""
    return {
        "vert_structure_lift": {
            "og_mean": summary["per_metric"]["vert_structure_lift"]["mean"],
            "arc2_iter100_default_seed42": 2.140729,
        },
        "cc_max": {
            "og_mean": summary["per_metric"]["cc_max"]["mean"],
            "arc2_iter100_default_seed42": 60,
        },
        "cc_count": {
            "og_mean": summary["per_metric"]["cc_count"]["mean"],
            "arc2_iter100_default_seed42": 51,
        },
        "reachable_cells": {
            "og_mean": summary["per_metric"]["reachable_cells"]["mean"],
            "arc2_iter100_default_seed42": 676,
            "note": "arc-2 oracle reports reachable BFS from PlayerTank spawn (160, 232) on procedural map; OG uses canonical Tanks spawn (col 8, row 24). Counts not 1:1 comparable but orders-of-magnitude consistent.",
        },
    }


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description="OG stage structural metrics for arc-2 handshake.")
    p.add_argument("--stages-dir", default=".research/repos/Tanks/resources/stages",
                   help="Tanks ASCII stages directory (read-only per H2 tripwire).")
    p.add_argument("--out", default="loop/originals/og-metrics.json",
                   help="Output JSON path (default per RUBRIC C12 anchor 2).")
    p.add_argument("--quiet", action="store_true", help="Suppress per-stage progress prints.")
    args = p.parse_args(argv)

    stages_dir = Path(args.stages_dir)
    if not stages_dir.is_dir():
        print(f"ERROR: stages dir not found: {stages_dir}", file=sys.stderr)
        return 2

    per_stage: list[dict[str, object]] = []
    for k in range(1, 36):
        grid = load_stage(k, stages_dir)
        entry = _per_stage(k, grid)
        per_stage.append(entry)
        if not args.quiet:
            print(f"stage {k:2d}: brick={entry['counts']['brick']:3d}"
                  f" cc_max={entry['cc_max']:3d}"
                  f" struct_lift={entry['vert_structure_lift']:.3f}"
                  f" reach={entry['reachable_cells']}"
                  f" playable={entry['playable']}")

    summary = _summary(per_stage)
    arc2 = _arc2_comparison(summary)

    artifact = {
        "stages": per_stage,
        "summary": summary,
        "arc2_comparison": arc2,
        "meta": {
            "source": str(stages_dir),
            "generated_by": "tools/og_metrics.py",
            "rubric_anchor": "C12 anchor 2 (artifact) + anchor 3 (cross-stage stats)",
        },
    }

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(artifact, indent=2) + "\n")
    print(f"wrote {out_path} ({len(per_stage)} stages)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
