---
title: Competent-player bot + real procedural arc harness (arc-harness-v0.2)
type: feat
status: active
date: 2026-05-29
origin: standalone (/architect deep — tanke E′ experiment, continues bot-harness-v0.1)
---

# Competent-player bot on the real procedural arc

## Addendum 2026-05-30 — Motion-primitive control (the real fix; GPT-Pro second opinion, conf 0.86)

**My "scripted heuristics can't reach endgame" verdict was wrong/premature.** A GPT-Pro
extended-thinking second opinion (dice-hook-prompted) diagnosed the real blocker:

- **False actuator abstraction (H1).** Materially different planners (reactive, BFS-frontier,
  two-tier) all collapse at the SAME shallow depth (rows 0–12) — that signature means the
  *motion layer*, not the planner, is broken. The planner commands a "tile agent," but the
  game simulates a 16px `CharacterBody2D` swept through 8px terrain with continuous collision
  resolution. A few-px lateral offset makes the swept body clip 3 tile-columns; cardinal
  "press up" can't resolve that offset → **limit cycle** (the oscillation observed). Every
  prior change tuned a strategy on an *untrusted actuator*.
- **Endgame is NOT proven infeasible.** Row 0→180 ≈ 1440px ÷ 32px/s ≈ **45s** of pure travel,
  well inside the 240s cap. The shallow plateau is a *motor-control* ceiling, not an agent one.

**The fix — footprint-aligned motion-primitive controller** (replaces the per-tick cardinal
cascade as the control layer; the planner sits on top and requests primitives, never raw keys):

- **Plan over 2×2 tank-FOOTPRINT poses**, not single 8px cells. A pose is valid only if the
  full footprint (+clearance) is traversable-or-breachable. Inflate/erode terrain by the
  footprint before planning. Snap to clean *footprint* alignment (valid every 8px, derived
  empirically from the collision shape) — NOT a blind 16px macrogrid (that rejects valid
  one-tile-shifted lanes → false "no path").
- **Primitives** the planner requests: `MOVE_TO_POSE(target)`, `BREACH_THEN_MOVE(target, bricks)`,
  `REALIGN_TO_LANE(axis)`, `ABORT_BLOCKED`. Each returns one outcome: `SUCCESS` /
  `BLOCKED_BY_IMPASSABLE` / `BLOCKED_BY_BRICK_NEEDS_BREACH` / `STUCK_COLLISION_NO_PROGRESS` /
  `INTERRUPTED_BY_THREAT` / `TIMEOUT`.
- **Execution contract:** align the perpendicular axis FIRST; advance only while lane-error
  (world-px offset from the target lane) stays within tolerance; abort the primitive if
  distance-to-target hasn't shrunk for N ticks (feeds the planner a real BLOCKED/STUCK signal).
- **Breach primitive:** stop at stand-off, face the target, shoot until the full footprint path
  is clear, then advance (not "drive into brick and grind").
- Keep `Input.parse_input_event` as the deterministic channel. Needs world-px player position
  in the observation (8px tiles are too coarse for lane-error). Per-primitive telemetry
  (start/target pose, lane_error, ticks, progress, collision ticks, result) makes the harness
  diagnostic regardless of max depth.

**Validation gate (the second opinion's named next step):** on empty/lightly-obstructed real-arc
starts, the bot must execute adjacent footprint-pose transitions with HIGH success + explicit
failure labels — *before* any further planner tuning. Expected: ceiling rises from ~12 to ~30–60+,
proving it was a motor ceiling. Only then revisit bounded brick-cost planning.

**Status:** terrain-vision fixes + composite bot + NavMemory + arc schema/recorder/helper are
built, unit-green, and Q1-regression-safe (HASH_OK, 84/84). The motion-primitive controller is
the next build; U5–U8 (batch/oracle/Makefile/acceptance) follow on top of the improved bot.

## Context & motive

`bot-harness-v0.1` (PR #5, PASS) ships 7 single-verb bots playing the **fixed**
`Q1ProofRoom`. The user's goal: let the loop *autonomously gather playtest-grade
signal* — "the closer it is to playtesting the better." Chosen direction: **run
the REAL procedural arc** (`BreachLevel.tscn`), scope **Full: per-band + depot
picks**, victory = reached endgame band.

Empirical finding (this session, committed `1fbe44a`+`acce8a3`): terrain vision +
BFS climb are **necessary but not sufficient**. On the arc, `objective-rush`
stays at depth 0 because an **enemy physically blocks its lane and it never fires
on it**; `approach-enemy` reaches depth ~5 only because it shoots. The arc
demands all four verbs *at once* — navigate + clear blocking enemies + breach +
climb. No single-verb probe can traverse it. **The fix is one composite,
playtest-faithful bot.** That is the gating piece; the runner + telemetry drop in
on top of it.

## Architecture Decision

**Approach:** *Additive arc lane beside the frozen Q1 lane.* A new composite bot
(`CompetentBot`), a new BreachLevel batch runner (`arc_runner.gd`), a new
telemetry recorder + schema (v0.2-arc, superset of v0.1), a shared single-run
helper, and new `make arc-*` verifier targets — **all new files**. The Q1 harness
(`BotRegistry`, `bot_runner.gd`, `TelemetryRecorder/Schema`, `make bot-harness`,
the 7 bots) is left **bit-identical**.

**Rationale (criterion: Consistency + the frozen-contract constraint):**
- `scenes/BreachLevel.tscn`, `ProceduralLevel.gd`, and all Layer 1-3 substrate are
  **FORBIDDEN edits** (PROMPT.md scope manifest) → archetype-skip and depot-drive
  must be **runtime, code-side** (set `player.force_archetype_select=false` before
  `add_child`; call `depot.apply_choice(1)` while paused), never scene edits.
- Adding `CompetentBot` to `BotRegistry.ORDER`/`SCRIPTS` would flip the Q1 matrix
  to 8×12=96 and break the frozen `RUNS_OK 84/84` + `BOTS_OK 7/7` sentinels →
  **`CompetentBot` is resolved by the arc runner directly, never via `BotRegistry`.**
- The arc victory is band-based, not `y<=0` like Q1 → a **separate recorder**, not a
  mutation of the frozen `TelemetryRecorder` (subclass it to reuse ~90%).

**Trade-offs accepted:** Modest duplication (arc recorder/schema mirror v0.1
field-checks) bought in exchange for **zero regression risk** to the frozen,
PASS, merge-clean Q1 harness. The composite bot is deterministic + stateless
(pure `tick(obs)`), matching the other 7 — so it stays unit-testable and
reproducible, at the cost of no cross-tick memory (acceptable; the cascade is
fully observation-driven).

## High-Level Technical Design

### Composite tick — priority cascade (stateless, pure function of `obs`)

```
tick(obs):
  blocked = blocked_set(obs.visible_obstacles)        # brick|steel|water tiles
  # 1. SURVIVE — dodge an enemy shell about to hit
  inc = obs.incoming_projectile()
  if inc and close(inc):  return move(perpendicular_to(inc.dir))     # no fire
  # 2. ENGAGE — a threat blocking the climb lane (same-ish column, above, in range)
  e = lane_blocking_enemy(obs)            # nearest enemy ~above within ENGAGE_ROWS
  if e:
     want = HEAT if e.type=="Heavy" and reserve(HEAT)>0 else AP
     if current_shell != want and want!=AP:  return swap(want)       # cycle first
     if clear_shot(player, e.tile, blocked):  return move(climb_or_hold), fire=true
     return move(step toward e's column)    # line up
  # 3. BREACH — obstacle directly above in the climb path
  o = obstacle_directly_above(obs, BREACH_LOOKAHEAD)
  if o.type=="brick":  return move(climb), fire=true                 # AP breaches brick
  if o.type=="steel" and step_climb==NONE and reserve(APCR)>0:       # only if boxed in
     if current_shell!=APCR: return swap(APCR)
     return move(NONE), fire=true                                    # APCR breaches steel
     # (water / blocked steel with a BFS detour → just route around, no fire)
  # 4. CLIMB — BFS upward, greedy fallback; gentle depot-column bias when a depot looms
  m = step_climb(obs.player_pos_tile, blocked, NAV_RADIUS)
  if m==NONE: m = step_toward(player, (player.x, 0), blocked)
  m = depot_bias(m, obs.visible_depots)   # nudge toward depot x when within reach
  return move(m), fire=false
```

### Run lifecycle (`ArcRunHelper.run_one(tree, bot, seed, out_path)`)

```
set TANKE_SEED=seed (level determinism) + seed(seed) (enemy stagger)
level = BreachLevel.instantiate()
level.get_node("PlayerTank").force_archetype_select = false   # BEFORE add_child → no modal
tree.root.add_child(level); await 4 frames
attach BotInputDriver(policy) + ArcTelemetryRecorder as PlayerTank siblings
recorder.connect(level.breach_band_changed)        # per-band segmentation + endgame victory
for each child with depot_picked signal: connect → recorder.on_depot_pick
loop:
   await tree.process_frame                         # advances even while paused
   if tree.paused:  drive active depot → apply_choice(1)   # auto-pass safe-gate
   until recorder._ended or frames>ARC_MAX_FRAMES
driver.release_all(); tree.paused=false; read recorder._result; validate; write
queue_free(level); await 2 frames
```

### Telemetry v0.2-arc (superset of v0.1)

All v0.1 fields **+** `max_depth:int`, `final_band:str`, `bands_reached:[str]`,
`band_segments:[{band, entered_sec, duration_sec, shells_fired:{AP,HE,HEAT,APCR},
damage_taken}]`, `depot_picks:[{depot, kind:int, band_next}]`,
`reached_endgame:bool`; `death_cause` reuses the v0.1 enum (`victory` = reached
endgame band); `schema_version="v0.2-arc"`.

## Implementation Units

### U1. CompetentBot — composite playtester + depot/observation awareness
- **Goal:** One deterministic bot that navigates, clears lane-blocking enemies
  (HEAT vs Heavy), breaches (AP brick / APCR steel-when-boxed, never water),
  dodges imminent shells, and climbs — plus the observation fields it needs.
- **Dependencies:** None
- **Files:**
  - Create: `scripts/bots/CompetentBot.gd` (`bot_id="competent"`, `extends BotPolicy`)
  - Modify: `scripts/bots/BotObservation.gd` (+`var visible_depots: Array[Dictionary] = []`)
  - Modify: `scripts/bots/ObservationBuilder.gd` (populate `visible_depots` from level
    children duck-typed by `depot_name`/`apply_choice`; within `VISION_TILES`)
  - Modify: `scripts/bots/BotHeuristics.gd` (only if a new shared primitive is needed,
    e.g. `lane_blocking_enemy` — prefer composing existing `step_climb`/`clear_shot`)
  - Test: `loop/eprime-experiment/test_competent_bot.gd`
- **Approach:** Priority cascade above; pure `tick(obs)`. Shell swap is expressed
  via `action.shell_swap_to` (driver pulses TAB, stops when `current_shell` matches)
  — so the bot re-decides each tick from `obs.current_shell_class` (stateless).
  Only swap to a shell with reserve>0 (AP=-1 unlimited). **Do NOT touch `BotRegistry`.**
- **Patterns to follow:** `ObjectiveRushBot.gd:16-32` (climb+breach), `ApproachEnemyBot`
  (engage+clear_shot+reload-gate), `DodgeShellBot` (perpendicular dodge),
  `BotHeuristics.step_climb:120` / `clear_shot:158`. Q1 adds no depots → `visible_depots`
  stays `[]` for the 7 bots (additive, zero Q1 behavior change).
- **Test scenarios:**
  - *Happy:* clear lane → returns an upward climb `move`, `fire=false`.
  - *Engage:* enemy directly above in range + clear_shot → `fire=true`; Heavy + HEAT
    reserve>0 → `shell_swap_to==HEAT`.
  - *Breach:* brick directly above → `fire=true` (AP); steel above + BFS boxed +
    APCR>0 → `shell_swap_to==APCR`; water above → **no fire**.
  - *Dodge:* incoming enemy projectile aligned & close → perpendicular `move`, `fire=false`.
  - *Edge:* APCR reserve 0 + steel above → no APCR swap, routes around (or holds), no crash.
  - *Validity:* `tick()` returns `is_valid()` BotAction for every synthetic obs (teeth:
    a mutation returning `null` fails the verifier before any behavioral assert).
- **Verification:** `test_competent_bot.gd` → `COMPETENT_OK`; each behavior case
  asserted; null-tick mutation → `COMPETENT_FAIL` (teeth).

### U2. ArcTelemetrySchema (v0.2-arc) + fixtures
- **Goal:** The arc telemetry contract: v0.1 superset + arc fields, with teeth.
- **Dependencies:** None
- **Files:**
  - Create: `scripts/telemetry/ArcTelemetrySchema.gd` (`SCHEMA_VERSION="v0.2-arc"`,
    `validate(t)->Array`)
  - Create: `tests/fixtures/arc_telemetry_good.json`, `tests/fixtures/arc_telemetry_bad.json`
  - Test: `loop/eprime-experiment/test_arc_telemetry_schema.gd`
- **Approach:** Validate all v0.1 fields (reuse the `_is_num`/`_is_int_like` shape)
  **plus** `max_depth`(int≥0), `final_band`(str), `bands_reached`([str]),
  `band_segments`([obj] with band/entered_sec/duration_sec/shells_fired{4 keys}/damage_taken),
  `depot_picks`([obj] depot/kind/band_next), `reached_endgame`(bool),
  `schema_version=="v0.2-arc"`. Standalone (does not delegate `schema_version` to v0.1).
- **Test scenarios:**
  - *Happy:* `arc_telemetry_good.json` (a competent endgame run) → `[]`.
  - *Teeth:* `arc_telemetry_bad.json` (missing `band_segments`, wrong `schema_version`,
    `max_depth<0`) → non-empty violations; a rubber-stamp validator fails this fixture.
- **Verification:** `test_arc_telemetry_schema.gd` → `ARC_TELEMETRY_OK 2/2`.

### U3. ArcTelemetryRecorder — band segmentation + depot picks + arc victory
- **Goal:** Subclass `TelemetryRecorder`; arc victory = endgame band; scaled timeout;
  per-band segments; depot picks; `max_depth` from `obs.rows_climbed`.
- **Dependencies:** U2
- **Files:**
  - Create: `scripts/telemetry/ArcTelemetryRecorder.gd` (`extends TelemetryRecorder`)
  - Test: covered by U3's slice of `test_arc_telemetry_schema.gd` or a stub in the
    recorder test (stub PlayerTank + emit band signals)
- **Approach:** Override `_physics_process` (same sampling, but run-end = endgame
  band reached OR `ARC_TIMEOUT_SEC`, not `y<=0`) and `build_record` (call
  `super.build_record(cause)`, merge arc fields, set `schema_version="v0.2-arc"`).
  `_on_band_changed(band)` closes the current segment (deltas vs segment-start
  accumulators), opens a new one, appends `band.band_name` to `bands_reached`, and
  if `band_name=="endgame_mixed"` calls `finalize("victory")`. `_on_depot_pick(depot,
  kind)` appends `{depot_name, kind, band_name_next}`. Reuses inherited
  `finalize/_write_json/_on_shoot/_on_hp_changed/_classify_death/_corr_*`. **Does not
  modify `TelemetryRecorder.gd`.**
- **State-Action notes (run-end transitions, synchronous):**
  | trigger | run-end cause | record |
  |---|---|---|
  | enter `endgame_mixed` band | `victory` | `reached_endgame=true` |
  | `died` signal (max_lives=1) | `_classify_death()` | `reached_endgame=false` |
  | `ARC_TIMEOUT_SEC` elapsed | `timeout` | last segment closed |
  - Invariant: `reached_endgame==true  iff  death_cause=="victory"`.
  - Invariant: `sum(band_segments.duration) ≈ survival_time_sec` (within one tick).
  - `finalize()` is idempotent (`_ended` latch, inherited) — a band signal after
    victory is a no-op.
- **Test scenarios:** *Happy:* stub level emits choke→maze→…→endgame → record has
  ordered `bands_reached`, ≥1 `band_segments`, `reached_endgame=true`,
  `death_cause=="victory"`, validates against ArcTelemetrySchema. *Depot:* emit a
  `depot_picked` → `depot_picks` has the entry. *Death:* `died` before endgame →
  `victory` not set, segments closed.
- **Verification:** stub-driven record validates v0.2-arc; invariants hold.

### U4. ArcRunHelper — single BreachLevel run (archetype-skip + depot auto-drive)
- **Goal:** One reusable headless run of one bot×seed on BreachLevel, hang-proof.
- **Dependencies:** U1, U3
- **Files:**
  - Create: `loop/eprime-experiment/arc_run_helper.gd` (`class_name ArcRunHelper`,
    `extends RefCounted`; `run_one(tree, bot_id, seed_v, out_path) -> Dictionary`)
- **Approach:** Lifecycle above. Bot resolution: `competent`→preload CompetentBot.new();
  else `BotRegistry.make()`. Set `force_archetype_select=false` on PlayerTank BEFORE
  `add_child`. Per frame, if `tree.paused`, find the active depot (child with
  `depot_picked` signal where `not _picked and _player_loadout!=null`) → `apply_choice(1)`.
  Always reset `tree.paused=false` + `release_all()` + `queue_free` in cleanup (a run
  ending mid-pause must not leak pause into the next run).
- **Test scenarios:** *Happy:* `competent` on one easy seed → dict `{ok, cause,
  max_depth>0, final_band, frames}`, scene freed, tree unpaused after. *Hang-proof:*
  no run exceeds `ARC_MAX_FRAMES`; archetype modal never blocks; every depot entered
  is auto-passed. *Determinism:* same seed → same `max_depth`/`final_band`.
- **Verification:** exercised by U5 + U6; a one-seed smoke returns `max_depth>0` with
  no SCRIPT ERROR and `tree.paused==false` on exit.

### U5. arc_runner.gd — the arc batch (integration proof)
- **Goal:** Headless batch over the arc bot roster × 12 seeds; conforming v0.2-arc JSON
  per run; loud failure on empty/unknown bot.
- **Dependencies:** U4
- **Files:**
  - Create: `loop/eprime-experiment/arc_runner.gd` (`extends SceneTree`)
- **Approach:** Mirror `bot_runner.gd` CLI/guards (`--bots`/`--seeds`/`--out`; empty
  or unknown bot → fail, no silent skip). Default roster = `["competent"] +
  BotRegistry.ids()` (8). Per run via `ArcRunHelper`; validate via
  `ArcTelemetrySchema` + re-read from disk. Emit `ARC_RUNS_OK <N>/<N> (victory: V,
  death: D, timeout: T; competent max_depth: <d>)`; `ARC_RUNS_FAIL`+`quit(1)` on any
  non-conforming/missing run or crash. Wall budget <5 min (most single-verb bots die
  fast; only `competent` runs long).
- **Test scenarios:** *Happy:* full roster×12 all conform, no crash, deterministic
  re-run identical. *Error:* `--bots no-such` → non-zero, no summary; empty `--bots`
  → fail loud. *Edge:* a bot that dies at depth 0 still emits a valid record (death).
- **Verification:** `ARC_RUNS_OK 96/96` (or roster size×12); all JSON parse + conform.

### U6. test_arc_climb.gd — competence oracle (the disconfirming-evidence gate)
- **Goal:** Prove `competent` actually traverses — the whole point.
- **Dependencies:** U1, U4
- **Files:**
  - Create: `loop/eprime-experiment/test_arc_climb.gd` (`extends SceneTree`)
- **Approach:** Run `competent` × 12 seed-bank seeds via `ArcRunHelper`; collect
  `max_depth`/`final_band`. Assert: (a) median `max_depth` ≥ **T** and (b) ≥1 seed
  reaches `endgame_mixed`. **T is calibrated from the real first measurement, floored
  to prove real traversal** — must clear `tutorial_choke` (depth ≥ 30 / reach band[1])
  on a majority of seeds, decisively beating the depth-0 stuck baseline. Emit
  `ARC_CLIMB_OK depth=<median> endgame=<k>/12`.
- **Probe gate (disconfirming evidence):** Teeth — `objective-rush` (single-verb) run
  through the SAME oracle must **fail** the threshold (it stalls at depth ~0). If
  `competent` cannot clear `tutorial_choke` even after bot iteration, that is a
  **reported finding** (the cascade needs more work), NOT a lowered threshold. Record
  the measured distribution honestly in the acceptance doc.
- **Test scenarios:** *Pass:* competent median ≥ T and endgame≥1 → `ARC_CLIMB_OK`.
  *Teeth:* objective-rush median ≈0 → `ARC_CLIMB_FAIL` (proves the oracle bites).
- **Verification:** `ARC_CLIMB_OK`; documented teeth run shows the stuck baseline fails.

### U7. Makefile arc targets + `arc-harness` composite
- **Goal:** Wire the verifiers; compose the arc final-verify; leave Q1 untouched.
- **Dependencies:** U1–U6
- **Files:**
  - Modify: `Makefile` (NEW targets only: `check-competent-bot`,
    `check-arc-telemetry-schema`, `check-arc-runs`, `check-arc-climb`, `arc-harness`)
- **Approach:** Same house style (visible run + `grep -q` positive sentinel).
  `arc-harness: check-hash-anchor check-competent-bot check-arc-telemetry-schema
  check-arc-climb check-arc-runs` → `@echo "ARC_HARNESS_OK"`. **Do not edit any
  existing target.**
- **Test scenarios:** none (build wiring) — proven by U8 final-verify.
- **Verification:** `make arc-harness` → `ARC_HARNESS_OK`; `make bot-harness` still
  `BOT_HARNESS_OK 84/84`; `make test-all` 5/5; `make check-hash-anchor` HASH_OK.

### U8. Acceptance inventory + state artifacts (final-verify)
- **Goal:** Freeze the arc acceptance + prove the whole inventory in one repo state.
- **Dependencies:** U7
- **Files:**
  - Create: `loop/eprime-experiment/ACCEPTANCE-arc.md` (`arc-harness-v0.2`, AC-A1..A4)
  - Modify: `loop/eprime-experiment/STATE.md`, `LEDGER.md`, `SKILL-HARVEST.md` (if a
    lesson surfaces), and write the arc `VERIFY` matrix section
- **Approach:** AC-A1 competent bot ships + valid (`check-competent-bot`); AC-A2
  arc telemetry contract (`check-arc-telemetry-schema`); AC-A3 competent traverses
  (`check-arc-climb`, threshold recorded honestly); AC-A4 arc batch clean +
  regression intact (`make arc-harness` ∧ `make bot-harness` ∧ `make test-all` ∧
  HASH_OK in one repo state). Record the measured depth distribution.
- **Verification:** all AC-A* PASS in one `make arc-harness` invocation alongside the
  Q1 regression guards green; matrix written.

## Scope Boundaries
- **Non-goal:** modifying `BreachLevel.tscn`, `ProceduralLevel.gd`, or any Layer 1-3
  substrate (FORBIDDEN). All archetype/depot driving is runtime, code-side.
- **Non-goal:** changing the frozen Q1 harness — `BotRegistry`, `bot_runner.gd`,
  `TelemetryRecorder/Schema`, the 7 bots, `make bot-harness`, AC-001..007 stay
  bit-identical. The composite bot is **never** in `BotRegistry`.
- **Non-goal:** LLM-in-the-frame-loop (forbidden) — `competent` is scripted GDScript.
- **Non-goal:** scoring consult predictions / asset gen / new game content.

### Deferred to Follow-Up Work
- **Band-aware depot picks:** picking the upgrade matching the *next* band's
  `canonical_answer` (vs. fixed `apply_choice(1)`) — a smarter playtester, separate iter.
- **Endgame survival depth:** continuing past endgame entry to measure how deep the
  bot survives (current spec: reached-endgame = victory, run ends there).
- **Adaptive shell economy across a run:** HEAT-budget planning for bunker_zone.

## System-Wide Impact
- **Interaction graph:** new files only + `Makefile` new targets. `BotObservation`/
  `ObservationBuilder` gain an additive `visible_depots` field (empty in Q1 → no Q1
  behavior change; the 7 bots never read it).
- **Error propagation:** `arc_runner`/`ArcRunHelper` fail loud (quit≠0, no summary)
  on unknown/empty bot, non-conforming JSON, or missing file — same discipline as
  `bot_runner.gd`. Headless hang risks (archetype modal, depot pause) are
  pre-empted in `ArcRunHelper`; a stuck run hits `ARC_MAX_FRAMES` and is recorded
  as `timeout`, never crashes the batch.
- **State lifecycle risks:** `tree.paused` MUST be reset every run (mid-pause run-end
  else leaks into the next run) — explicit cleanup. Held keys released via
  `driver.release_all()`. Fresh recorder/driver/level per run (no cross-run leak).
- **Unchanged invariants:** hash anchor `23d6a2ec…4024291` bit-identical (no
  substrate write; arc adds sibling nodes + new files only). `make bot-harness`
  84/84 and `make test-all` 5/5 unchanged.

## Risks & Dependencies
| Risk | Mitigation |
|------|------------|
| Composite still can't clear a band (cascade insufficient) | U6 is the probe gate; iterate the bot; report honestly, never lower the threshold to triviality |
| Depots don't trigger (bot avoids x=160 lane) | Depots stack on the central lane (x=160/tile 20); light depot-column bias + `visible_depots`; if still sparse, `depot_picks=[]` is a valid record (note as calibration finding) |
| Headless hang (archetype modal / depot pause) | `force_archetype_select=false` pre-`add_child`; `apply_choice(1)` while paused; `ARC_MAX_FRAMES` safety cap |
| Arc batch wall-time >5 min | single-verb bots die fast; only `competent` runs long; `--fixed-fps 60`; scale roster if needed (log any cap, no silent truncation) |
| Editing `BotObservation`/`ObservationBuilder` regresses Q1 | additive field only, empty in Q1; gate on `make bot-harness` 84/84 after every edit |
| Subclass coupling to `TelemetryRecorder` internals | reuse only documented inherited members; re-run `check-telemetry-recorder` to confirm base untouched |

## Disconfirming evidence → tests
- **Claim:** the composite traverses the arc. **Probe:** U6 `test_arc_climb.gd` with
  an explicit teeth run of single-verb `objective-rush` through the same oracle —
  it must FAIL where `competent` passes. If `competent` also fails, that falsifies
  the cascade design and is reported, not masked.
- **Claim:** Q1 is untouched. **Probe:** `make bot-harness` → `BOT_HARNESS_OK 84/84`
  and `make check-hash-anchor` → `HASH_OK` after every unit.

## Acceptance (build-till target)
`make arc-harness` → `ARC_HARNESS_OK` **and** `make bot-harness` → `BOT_HARNESS_OK
84/84` **and** `make test-all` → 5/5 **and** `make check-hash-anchor` → `HASH_OK`,
all in one repo state.
