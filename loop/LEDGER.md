# tanke — Loop Ledger

Append-only score history. Bootstrap iter has no scores.

---

## Iter 000 — BOOTSTRAP — 2026-05-10
**Focus:** scaffold dual oracle (headless + screencapture), confirm pipeline.
**Changed files:**
- `loop/test_runner.gd` (new) — SceneTree-based headless harness; instantiates ProceduralLevel, steps 30 frames, prints tile counts + Eller metrics + tile fingerprint + PASS/FAIL.
- `loop/RUBRIC.md` — populated criterion 1 (headless) and 6 (screencapture) anchors with real reference output.
- `loop/STATE.md` — preloop_complete: yes; phase: bootstrap → iter 1.

**Oracle output (headless, single seed):**
```
=== tanke headless oracle ===
brick: 380  water: 88  steel: 32  grass: 156  total: 656
eller_sets: 12  avg_size: 1.67  max_size: 5
tile_hash: e55b96e4256a8acf
PASS
```

**Oracle output (screencapture, frame00000004.png):**
```
Coverage      99.9%   score 5/5
Variety      4/4 types  score 4/4
Distribution entropy 1.216 bits  score 3.0/5.0
Tile counts  {'brick': 55034, 'steel': 1512, 'grass': 12240, 'water': 7936}
```

**gen_tile.py smoke test:**
```
$ python3 tools/gen_tile.py --tile brick --variant 0 --out tools/out
saved tools/out/brick_000.png
```

**No scores — bootstrap iter.**

**Observation:** earlier screencapture run (recorded in STATE.md baseline) showed 100% brick — that was a seed outlier, not a generation bug. With a fresh `randi()` seed, all 4 terrain types render and the screencapture oracle reads them correctly. This raises the priority of stored seeds (Level DNA, criterion 4) over distribution refactor — without seed reproducibility, every score is a snapshot of a single random draw, which is noisy.

**Weakest axis next:** Level DNA Reproducibility (criterion 4) — without a stored seed, oracle scores are non-deterministic; can't measure Δ from config changes. Iter 1 should add a stored `seed: int` on ProceduralLevel and thread it into `randi()` calls / a seeded RNG.
