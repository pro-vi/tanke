# tanke — Loop State

## Phase

```
phase: build
iteration: 9
preloop_complete: yes
```

---

## Preloop Checklist

```
[x] Open project in Godot 4 editor — done
[x] source_id + atlas_coords resolved from scene files (see below)
[x] ProceduralLevel.tscn generates terrain without errors — make test clean
[x] Screencapture oracle working — make screenshot + make analyze produce valid oracle output
[x] Verify interactively: player tank moves, camera follows, no console errors (F5 in editor)
[x] Flip preloop_complete: yes above
```

---

## Tile Source IDs

```
tile_source_ids:
  brick:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(40,0) in sprites_1.png
  steel:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(16,0) in sprites_1.png
  grass:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(24,0) in sprites_1.png
  water:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(24,8) in sprites_1.png
```

---

## Current Scores (post iter 2)

| Criterion | Score | Notes |
|-----------|-------|-------|
| Headless oracle | 4 | seed + config-aware; reproducible hash |
| Algorithm variety | 4 | iter 7 cited single-field mutation: water_weight 0.6→0.2 → water -43% Δ |
| LevelConfig mutability | 5 | iter 7 full agent cycle: AGENTS.md → Edit → rerun → cite Δ |
| Level DNA | 5 | DNA-referenced config mutation + oracle confirmation in iter 7 |
| Tile visual coherence | 3 | 4/4 palettes render; all configs visually correct |
| Screencapture oracle | 4 | iter 8 --diff mode + make diff CONFIG=<preset>; per-terrain Δ + shift_detected |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 3 | 6-seed sweep: per-terrain variance 40–63% (>20% threshold met) |
| Pipeline completeness | 3 | gen_tile→import→TileSet→render chain verified iter 4 (brick_007) |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| **Total** | **39/50** | +1 from iter 7; iter 7 raised anchors still binding |

---

## Oracle Reading (iter 0)

```
frame: frame00000004.png
coverage:     100.0%  score 5/5
variety:      1/4     score 1/4   ← primary target
distribution: 0.000 bits  score 0.0/5.0  ← primary target
brick: 76800px  steel: 0  grass: 0  water: 0
```

Root cause: `_pave_set()` brick condition (2≤size≤7, sid%2==0) catches nearly all
sets in elif chain before steel/grass/water checks fire. First loop task: fix.

---

## Open Seams

1. `_pave_set()` distribution algorithm — brick dominates, oracle score 0/5; needs LevelConfig weights
2. LevelConfig resource doesn't exist — blocks mutability, Level DNA
3. No stored seed in ProceduralLevel — blocks Level DNA
4. BrickBlock destruction — bullet impact TODOs in BrickBlock.gd
5. Enemy tank AI not implemented
6. World rebasing — Camera2D limit_top defaults to -10,000,000 (not infinite); infinite upward scroll will eventually hit it; needs chunk recycling / world origin rebase before approaching that bound

---

## Last Action

```
Iter 8 CAPABILITY: diff oracle + env-var rendering overrides.
- analyze_frame.py --diff A.png B.png: per-terrain Δ + entropy Δ + shift_detected
- ProceduralLevel.gd: TANKE_CONFIG / TANKE_SEED env reads in _ready (non-destructive)
- Makefile: make diff CONFIG=<preset>
- AGENTS.md updated: env vars + make diff documented
- Demo: default vs watery @ seed 42 → water +95.8%, steel -67.8%, shift_detected: True
- Criterion 6: 3 → 4. Total 38 → 39/50.
```

---

## Stale Scores

None. Iter 7 already noted watery.tres state.

---

## Next Action

`Iter 9 BUILD: biome-zone weighting. Implement depth-modulated LevelConfig (e.g. interpolate between two configs as player scrolls). Targets criterion 8 (Procedural richness 3→4). Heaviest remaining build; genuine procedural-engine sophistication.`

Iter 10 = CONSULT gate. Pre-staged hollow-points: (a) no spatial coherence in terrain (iter 9 should target this), (b) merge_probability is depth-invariant, (c) entropy oracle is goodhart-able.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
