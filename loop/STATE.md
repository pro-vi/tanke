# tanke — Loop State

## Phase

```
phase: build
iteration: 23
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
| Headless oracle | 5 | --json flag emits 16-field JSON; jq-based diff workflow demonstrated |
| Algorithm variety | 4 | iter 7 cited single-field mutation: water_weight 0.6→0.2 → water -43% Δ |
| LevelConfig mutability | 5 | iter 7 full agent cycle: AGENTS.md → Edit → rerun → cite Δ |
| Level DNA | 5 | DNA-referenced config mutation + oracle confirmation in iter 7 |
| Tile visual coherence | 4 | iter 17 sprite-sheet-extracted palettes; coverage 99.9%/variety 4/4/entropy 4.0 |
| Screencapture oracle | 4 | iter 8 --diff mode + make diff CONFIG=<preset>; per-terrain Δ + shift_detected |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 4 | iter 9 biome interp: visible top-vs-bottom gradient; water +20.8% Δ |
| Pipeline completeness | 4 | iter 16 all 4 terrains regenerated via gen_tile + atlas swap; full-sheet chain |
| GDScript correctness | 4 | iter 19 flattened TileMap wrappers; structurally migrated; zero deprecation warnings |
| 11. Spatial Coherence | 5 | iter 18 biome_balanced: most-dom 30% + structure_lift 2.522× (high+high quadrant filled) |
| **Total** | **49/55** | +1 from iter 18; 89.1% on expanded rubric |

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
Iter 22 BUILD: connected-component flood-fill metric in test_runner.gd.
Reports cc_count, cc_max, cc_avg. JSON schema enriched.

Survey (seed 42, post-Eller-fix):
  fortress:        cc_count 32, cc_max 256 (giant blob), s_lift 1.751×
  default:         cc_count 87, cc_max 140                s_lift 2.414×
  biome_d→w:       cc_count 47, cc_max 124                s_lift 2.601×
  balanced_steel:  cc_count 75, cc_max  96                s_lift 2.451×
  watery:          cc_count 45, cc_max  88                s_lift 2.303×
  biome_balanced:  cc_count 77, cc_max  68 (most frag)    s_lift 2.628×

CC ranking is NEARLY OPPOSITE structure_lift ranking. The two metrics
capture different architectural modes (blob vs interleave). Iter-20
self-assessment #2 partly addressed — Goodhart on either single metric
is harder when both must agree.

No score lift but rubric is now structurally harder to gimmick.
Pre-commit prediction (CC ≠ s_lift ranking) confirmed.
```

---

## Stale Scores

None.
USER-LOOK GATE STILL OPEN — 12 iters since human playtest.

---

## Next Action

`Iter 23 BUILD: try to construct an "interleave maximizer" config that
beats biome_balanced on BOTH axes (s_lift higher AND cc_max lower /
cc_count higher). Tests whether the new combined-axis has headroom.
Strategies:
  (a) biome with both endpoints near-balanced AND p_merge ≈ 0.5 (medium
      sets favor interleave)
  (b) biome with rapid depth_scale (e.g. 5) so transition is sharp
  (c) three-config biome (impl change to BiomeConfig) — too much for one iter
Lean (a). Cite predicted Δ on both metrics before measuring.`

Alternative: WAIT for user-look feedback. Two iters open without movement.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
