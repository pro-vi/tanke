# tanke — Loop State

## Phase

```
phase: build
iteration: 7
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
| Algorithm variety | 3 | 3 configs (default/watery/fortress) → 3 distinct distributions @ seed 42 |
| LevelConfig mutability | 4 | `.tres` Resource; weights editable without `.gd` changes |
| Level DNA | 4 | LevelDNA.gd serializes seed+config; JSON round-trip OK; DNA-driven hash matches |
| Tile visual coherence | 3 | 4/4 palettes render; all configs visually correct |
| Screencapture oracle | 3 | analyze_frame.py classifies by palette; entropy 3.9 |
| Agent edit friction | 4 | `loop/AGENTS.md` documents all 7 mutable params |
| Procedural richness | 3 | 6-seed sweep: per-terrain variance 40–63% (>20% threshold met) |
| Pipeline completeness | 3 | gen_tile→import→TileSet→render chain verified iter 4 (brick_007) |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| **Total** | **34/50** | +1 from iter 4; ceiling check at 35 (1 to go); iter 6 AUDIT next |

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
Iter 6 AUDIT: re-scored 10 criteria with fresh evidence.
- Roundtrip OK; default DNA seed-42 hash 6159ef2f5464edb1 (iter 2 baseline preserved)
- 3-config sweep: distinct hashes per config
- Screencapture: variety 4/4, entropy 4.4/5
- Total 34/50 — unchanged. No inflation, no regressions.
- Insight: 4 criteria (2/3/4/7) all gated on same anchor — "cited end-to-end mutation cycle".
  One cited mutation in iter 7 could quad-lift to ceiling-bust.
```

---

## Stale Scores

None.

---

## Next Action

`Iter 7 BUILD: cited mutation cycle. Edit one weight on configs/watery.tres, rerun oracle, cite Δ in LEDGER. Targets quad-axis lift of criteria 2 (3→4), 3 (4→5), 4 (4→5), 7 (4→5) — anticipated +4 to total. Will trip CEILING RULE; pre-stage anchor revisions.`

CONSULT gate at iter 10 (3 iters away). Pre-staged hollow-point candidates documented in LEDGER iter 6 audit observations.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
