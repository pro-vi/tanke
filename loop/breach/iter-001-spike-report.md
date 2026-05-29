# Iter 001 — SPIKE report — mode-integration path A vs B

Compaction-safe blueprint per L2. Iter 2 DECISION reads this; iter 2 does
NOT need to re-dispatch scouts.

**Date:** 2026-05-19
**Scouts dispatched:** 2 parallel general-purpose subagents (read-only).
**Convergence:** Both scouts recommend Path A. Decision should be obvious in iter 2.

---

## SCOUT A — Path A (default-on `breach_mode_enabled` flag on `ProceduralLevel`)

**Verdict: SHIP.**

### Gating sketch (`scripts/ProceduralLevel.gd`)

After existing `@export` block (~line 11):
```gdscript
@export var breach_mode_enabled: bool = false
@export var breach_config: Resource = null   # BreachConfig.gd; null when disabled
```

After `_ready()` baseline (after line 79, `camera.force_update_scroll()`):
```gdscript
if breach_mode_enabled:
    _init_breach_mode()   # depot spawn-points, depth-band tracker, shell-loadout init
```

After `_process()` row-generation block (after line 94):
```gdscript
if breach_mode_enabled:
    _process_breach_depth(player_pos.y)   # depth-band transitions, depot triggers
```

`scenes/ProceduralLevel.tscn`: untouched on path A. New `scenes/BreachLevel.tscn`
can `[ext_resource]` the same `ProceduralLevel.gd` script + override
`breach_mode_enabled = true` and `breach_config = <breach.tres>` — zero
substrate cost for the launch wiring.

### Hash-anchor bit-identicality

RNG-touching path is fully contained in lines 42-77 (`seed(level_seed)` →
`ProceduralStep.new()` → `verts = ps.generate_step()` → `_pave_set()` per row
→ `_replace_blocks()`). None of these check `breach_mode_enabled` or
consume from `breach_config` under path A. The new `if breach_mode_enabled:`
branches sit **after** the stochastic source, so they cannot reorder
`randf()` calls inside `generate_step()` (the only feed to `tile_hash`).

Verified safe:
- `_ready` ordering — new branch runs *after* baseline
- Child node addition — depot spawn-points only added under flag
- Signal connections — `player.shoot.connect(...)` unchanged
- `_pave_debug` precedent (lines 141-147) already does conditional `add_child`
  without affecting hash → pattern is hash-safe

### MVP substrate cost (path A)

To reach "flag added + one shell wired + one depot spawned":

| # | File | Why | Sanctioned? |
|---|------|-----|-------------|
| 1 | `scripts/ProceduralLevel.gd` | flag + 2 branches | YES (PROMPT §SUBSTRATE FREEZE iter-1 path A) |
| 2 | `scripts/Bullet.gd` | `@export var shell_class: int = 0` + branch in `start()` | YES (PROMPT §DEFAULT-ON SUBSTRATE GATING TEMPLATE) |
| 3 | `scenes/ProceduralLevel.tscn` | OPTIONAL — defer to `BreachLevel.tscn` to keep base scene byte-clean | path A keeps procedural scene untouched; depot Marker2D goes in the sibling launcher scene |

Loadout, BreachConfig, Depot, RunRecap are net-new files (zero substrate cost).

### Effort: ~5-7 BUILD iters to end-to-end breach run

- iter 2: DECISION + ProceduralLevel.gd flag + skeletal `BreachLevel.tscn` launcher + hash-anchor recheck
- iter 3: `BreachConfig.gd` + depth-band tracking in `_process_breach_depth`
- iter 4: `Bullet.gd` shell-class extension + `Loadout.gd` + one shell swap
- iter 5: `Depot.gd` + `Depot.tscn` + one depot spawn at depth-band transition
- iter 6: `test_breach_harness.gd` extension + hash anchor + `make test` green
- iter 7: integration debugging + first observable run

### Risks named (path A)

1. **`TANKE_SEED` / `TANKE_CONFIG` / `TANKE_BIOME` env overrides**: breach
   probably wants its own config resource path. Adding `TANKE_BREACH=1`
   is clean, but layering breach onto a `--config` swap mid-run is the
   tangle — `make diff` assumes config swaps don't change *mode*. Iter-2
   DECISION should resolve: is breach orthogonal to config, or mutually
   exclusive with arc-2 biome flow?
2. **`PlayerTank.tscn` hardcoded at scene line 5/77**: breach likely wants
   different starting HP / loadout / lives. Extend via PlayerTank
   `@export` flags (arc-3 `max_lives` + arc-2 `show_ascender_hud`
   precedent) rather than swapping the scene. **PlayerTank substrate
   write looming** once Loadout matures.
3. **`Spawner.gd` already arc-3-extended** (`stage_number`). Depth-band-
   driven enemy selection per `BANDS.md` is one more substrate write:
   `breach_depth_band: int = -1` flag.

---

## SCOUT B — Path B (sibling `scenes/BreachLevel.tscn`)

**Verdict: REFINE (do NOT SHIP as default).**

Structurally feasible — `ProceduralStep.gd` is `RefCounted` with zero scene
coupling — and `OriginalLevel.tscn` is a working precedent. But substrate-
write savings are illusory.

### Substrate writes for path B

Identical to path A on Bullet + PlayerTank + Spawner. Saves exactly **one**
flag (`breach_mode_enabled` on ProceduralLevel.gd). Net saving: 1 default-off
boolean.

### H1 burden (real, recurring)

If BreachLevel.tscn ships:
- New `make check-breach-*` target per band (reachability floor applies)
- `check-titlescreen-nav` must add a 3rd menu entry + selection-flow test
- Possible `make test-all` extension to load BreachLevel for 120 frames
- Risk: forking `ProceduralStep` row-generation logic between
  `ProceduralLevel.gd:107-113` and `BreachLevel.gd` — drift risk on
  Eller invariants

Same shape of harness debt arc-3 incurred when adding `OriginalLevel.tscn`
(png_diff, og_metrics, band_check, chain-25, chain-35, og-stage extension
— six harness extensions over 27 iters).

### Risk surface (path B)

1. ProceduralStep row-regen logic forks between two scenes — Eller
   invariant drift risk.
2. Spawner global-state collision: NONE (Spawner reads `_player`/`_camera`
   from `get_parent()`, scoped per-scene-instance).
3. Title-screen nav fork: arc-3 iter-25 nav harness was non-trivial; path A
   keeps menu at 2 entries.
4. `scripts/Level.gd:36` `_on_PlayerTank_shoot` instantiates AP bullets;
   BreachLevel.gd must override (or Level.gd extend) for shell-class
   routing — same write count, different file.

### Effort (path B): ~5-6 BUILD iters

Comparable to path A. Substrate writes are the bulk of work, not the
scene wrapper.

### Scout B's recommendation: stay path A

> "Path B works and isolates breach divergence cleanly, but the only
> substrate write it saves is the `breach_mode_enabled` flag on
> ProceduralLevel.gd. In exchange you pay one permanent H1 surface…
> Recommend path A unless iter-1 BUILD on path A hits a concrete blocker."

---

## Convergent finding

Both scouts independently arrive at **path A as the cleaner choice**. The
hash-anchor preservation argument (Scout A) is the load-bearing finding:
the RNG-touching code in `ProceduralLevel.gd:42-77` is structurally
isolatable, so the default-on flag template lands cleanly.

## Iter 2 DECISION inputs (pre-staged)

When iter 2 fires:
1. Adopt path A.
2. Pre-mortem the iter 2 BUILD as the gating diff sketched by Scout A
   above — single ProceduralLevel.gd edit, no `.tscn` changes, no other
   substrate touched.
3. Stash an `iter-002-NNN-architect.md` blueprint covering the next 3-5
   BUILD iters per Scout A's effort estimate (BreachConfig → Bullet
   shell-class → Depot → harness extension).
4. Hash-anchor verify post-edit; commit only if `tile_hash` first 16 chars
   = `23d6a2ec3bf2821f` and `make test` exits 0.
5. Resolve Scout A's risk #1 (TANKE_BREACH env layering vs TANKE_CONFIG
   mutually-exclusive mode flag).

## Unresolved by spike (push to DECISION or later iter)

- **Risk #1 from Scout A**: `TANKE_BREACH=1` env vs mutually-exclusive
  mode. Quick to resolve; DECISION-eligible.
- **PlayerTank scene swap vs flag extension**: deferred to whenever
  Loadout lands (~iter 5+).
- **Spawner band-driven spawn**: deferred to whenever BANDS.md begins
  shipping (~iter 3-4).

## Files inspected (no writes)

Scout A + Scout B together touched (read-only):
`scenes/ProceduralLevel.tscn`, `scenes/OriginalLevel.tscn`,
`scripts/ProceduralLevel.gd`, `scripts/OriginalLevel.gd`,
`scripts/ProceduralStep.gd`, `scripts/Level.gd`, `scripts/LevelLoader.gd`,
`scripts/Spawner.gd`, `scripts/PlayerTank.gd`, `scripts/Bullet.gd`,
`loop/test_runner.gd`, `loop/breach/PROMPT.md`, `Makefile`.
