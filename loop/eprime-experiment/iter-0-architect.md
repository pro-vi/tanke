---
title: Bot-Harness Scaffolding — Implementation Blueprint
type: feat
status: active
date: 2026-05-28
origin: loop/eprime-experiment/{PROMPT,ACCEPTANCE,STATE}.md (composed by /loopgen 2026-05-28)
parent_consult: /agentify Pro 2026-05-27 (queryId 939b4880-880a-42aa-aa22-5760f54a4830)
---

# Bot-Harness Scaffolding — Implementation Blueprint

Decisive architecture + 8-unit decomposition for the tanke E′ experiment shared scaffolding. Closes ACCEPTANCE.md AC-001..AC-007 in `loop/eprime-experiment/`. Depth: **Deep** (cross-cutting, single substrate touch with hash-anchor risk, probe-gated architecture, instrumentation contract).

## Architecture Decision

**Approach**: Single base class `BotPolicy` (Resource subclass) returning structured `Action` dicts → translated to synthetic input by a sibling `BotInputDriver` → consumed by PlayerTank via a default-off `bot_controlled` flag (the one substrate touch). Telemetry capture lives in a sibling `TelemetryRecorder` node subscribing to existing PlayerTank signals (zero substrate touch). Batch runner is a single-process GDScript SceneTree extension that reloads `scenes/Q1ProofRoom.tscn` 84 times with clean state asserts between runs.

**Rationale** (priority criterion: consistency + testability):
- BotPolicy-as-Resource matches Godot's `@export var bot_policy: Resource` pattern → editor-inspectable + serializable + swappable per-bot without code change
- Sibling TelemetryRecorder mirrors existing arc-3 pattern (`test_runner.gd` extends SceneTree + observes a level node's children) → zero hash-anchor risk
- Single-process batch reuses the existing `test_runner.gd` pattern + fits the <5min wall budget (84 × 1sec process-launch overhead = 84sec lost; not acceptable)
- Default-off `bot_controlled` flag follows the default-on substrate gating template from arc-2 PATTERN 2 (every arc-4 substrate write used this; 96 writes preserved hash)

**Trade-offs**:
- BotPolicy-as-Resource means each bot is a `.gd` file extending the base + each gets a `.tres` instance for export; slightly more files than a flat function-per-bot, but enables clean per-bot config overrides
- Single-process batch needs robust scene reset (memory leak across 84 runs = silent failure); mitigated by explicit `change_scene_to_packed()` + post-load state assert per iteration
- Sibling TelemetryRecorder requires PlayerTank to keep emitting its existing signals — it already does, but a future refactor that drops a signal silently breaks telemetry (counter-mitigation: TelemetryRecorder asserts all required signals are connected on `_ready()`)

## High-Level Technical Design

### Component layout

```
┌─────────────────────────────────────────────────────────────────────┐
│ tools/bot_runner.sh   (CLI wrapper: --bots --seeds --out)           │
│   └─→ godot --headless --script loop/eprime-experiment/bot_runner.gd │
│            -- --bots <list> --seeds <list> --out <path>             │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│ loop/eprime-experiment/bot_runner.gd  (extends SceneTree)           │
│   - parses CLI args                                                  │
│   - loops N×M (bots×seeds), each iter:                              │
│     1. change_scene_to_packed(Q1ProofRoom)                           │
│     2. instantiate TelemetryRecorder + BotInputDriver                │
│     3. set PlayerTank.bot_controlled = true; .bot_policy = <bot>    │
│     4. await PlayerTank.died OR victory OR timeout                   │
│     5. write data/telemetry/seed_NN_bot_X.json                       │
│     6. assert clean state, repeat                                    │
│   - emits summary JSON aggregating telemetry                         │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                ┌─────────────────┴─────────────────┐
                ▼                                   ▼
┌────────────────────────────┐    ┌──────────────────────────────────┐
│ scripts/bots/BotPolicy.gd  │    │ scripts/telemetry/               │
│ (abstract Resource)        │    │   TelemetryRecorder.gd           │
│   - tick(observation)      │    │   (Node, sibling of PlayerTank)  │
│     → Action               │    │   - subscribes:                  │
│   - _get_observation()     │    │     PlayerTank.shoot              │
│     → constrained view     │    │     PlayerTank.hp_changed         │
│                            │    │     PlayerTank.died               │
│ Subclasses:                │    │     PlayerTank.lives_changed      │
│   MoveToCoverBot.gd        │    │     (and existing signals)        │
│   DodgeShellBot.gd         │    │   - samples observation per tick │
│   ApproachEnemyBot.gd      │    │   - emits telemetry JSON on death │
│   FireWhenLinedUpBot.gd    │    └──────────────────────────────────┘
│   ReloadAwareWaitBot.gd    │
│   PanicRandomBot.gd        │
│   ObjectiveRushBot.gd      │
└────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│ scripts/bots/BotInputDriver.gd  (sibling Node)                      │
│   - reads BotPolicy.tick() output                                    │
│   - translates Action {move_dir, fire, shell_swap_to} into          │
│     InputEventKey events via Input.parse_input_event                 │
│   - awaits process_frame before next tick (arc-3 L5 pattern)        │
└─────────────────────────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│ scripts/PlayerTank.gd  (LAYER-2 SUBSTRATE — ONE GATED TOUCH ONLY)   │
│   + @export var bot_controlled: bool = false                         │
│   + @export var bot_policy: Resource = null                          │
│   _physics_process input section:                                    │
│     if bot_controlled and bot_policy != null:                       │
│         <BotInputDriver-synthesized input has already populated      │
│          Input state via parse_input_event; existing keyboard        │
│          reads transparently consume it>                              │
│     else:                                                            │
│         <existing arc-2/3/4 keyboard read codepath UNCHANGED>       │
│   Hash anchor: 23d6a2ec… verifies bit-identical on flag-off          │
│   (Input.parse_input_event is exactly the arc-3 L5 pattern)         │
└─────────────────────────────────────────────────────────────────────┘
```

### Action contract (the API the LLM-between-runs reads)

```text
Action ::= {
  move_dir: Constants.Dir,    # L | D | U | R | NONE (NONE = stationary)
  fire: bool,                  # SPACE-equivalent
  shell_swap_to: int,          # -1 = no swap; 0=AP, 1=HE, 2=HEAT, 3=APCR
}
```

Single struct. No nested objects. Clean to interpret post-run; clean to compare across iterations.

### Observation contract (what the bot SEES — constrained per consult §3)

```text
Observation ::= {
  # SCREEN-VISIBLE state (what a human would see):
  player_hp: int,                      # current HP value (matches HP label)
  player_hp_max: int,
  reload_bar_value: float,             # [0.0, 1.0] (matches reload bar fill)
  current_shell_class: int,            # 0..3 (matches shell chip highlight)
  shell_reserves: {AP, HE, HEAT, APCR}, # matches shell chip counts
  active_card_count: int,              # matches ribbon visible chip count
  speed_meter_normalized: float,       # matches speed meter display

  # SPATIAL state (what the rendered tiles reveal — pixel-equivalent):
  player_pos_tile: Vector2i,           # tank's tile coord
  visible_enemies: Array[{pos_tile, hp, type}],  # only enemies in player's visible region
  visible_obstacles: Array[{pos_tile, type}],    # bricks/steel/water/grass within sight

  # PROJECTILES the player can see (rendered, in viewport):
  visible_projectiles: Array[{pos_tile, dir, shell_class, owner}],

  # TIMING:
  iter_n: int,                          # physics tick count since run start
  time_sec: float,                      # wall time since run start
}
```

**Critical decision per consult §3**: Observation does NOT expose internal level state, enemy AI plans, future spawn schedules, exact bullet collision targets, or "ground truth" outside the rendered viewport. Bots can only see what the screen shows. This is what makes `ui_action_correlation` a meaningful proxy for consult-001 P2+P3 predictions.

A debug mode (`OMNISCIENT_BOTS = false` constant, flip in code for debugging) can expose full state for tier-classification scripted runs (AC-003) — but the 84-run batch uses constrained observation by default.

### State-Action contract (PlayerTank.bot_controlled gating)

| Action | PlayerTank state | bot_controlled = false | bot_controlled = true |
|---|---|---|---|
| `_physics_process(delta)` | alive | reads `Input.is_action_pressed("ui_*")` → moves keyboard-driven | same code reads Input state; BotInputDriver has pre-populated it via `parse_input_event` |
| keyboard event arrives | alive | Godot updates Input state; PlayerTank reads it | Godot updates Input state; bot input also writes; LAST WRITER WINS within a frame |
| bot_policy = null AND bot_controlled = true | alive | n/a | PlayerTank reads Input state (empty if no real keyboard) → tank stationary; warning logged |
| signal `shoot` emitted | alive | TelemetryRecorder (if connected) logs it | same — recorder doesn't care about source |

**Invariant**: `bot_controlled == true iff bot_policy != null` (BotInputDriver also gated by both). Enforced by an assert in PlayerTank's `_ready()`: if `bot_controlled and bot_policy == null: push_warning("bot_controlled flag set without bot_policy assigned; will be stationary")`.

**Hash-anchor invariant**: `bot_controlled == false → procedural baseline tile_hash == 23d6a2ec3bf2821f…`. Verified post-write via `make check-hash-anchor` (AC-005).

## Implementation Units

### U1. BotPolicy base class + Action/Observation types

- **Goal**: Define the bot contract — base Resource class, Action struct, Observation struct. No bot implementations yet, just the interface.
- **Requirements**: AC-001 (contract foundation)
- **Dependencies**: None
- **Files**:
  - Create: `scripts/bots/BotPolicy.gd` (abstract base, extends Resource)
  - Create: `scripts/bots/Action.gd` (struct, RefCounted)
  - Create: `scripts/bots/Observation.gd` (struct, RefCounted)
- **Approach**: BotPolicy is `class_name BotPolicy extends Resource` with a virtual `func tick(obs: Observation) -> Action: assert(false, "subclass must override"); return null`. Action + Observation are RefCounted with `@export` fields for inspector visibility.
- **Patterns to follow**: `scripts/LevelConfig.gd` (Resource with @export pattern) — mirror the class_name + Resource + @export shape.
- **Test scenarios**:
  - *Happy path*: instantiate Action with valid field values → field reads return expected values
  - *Edge case*: instantiate Observation with empty visible_enemies array → array.size() == 0, no error
  - *Error path*: instantiate BotPolicy directly + call tick(obs) → assertion fires (subclass override mandatory)
- **Verification**: 3 new files; `make test` passes; harness `check-bots-base` exits 0 with stdout `BOTS_BASE_OK`.
- **Substrate-touch**: NONE
- **Size**: S

### U2. PlayerTank bot-input hook (the ONE substrate touch)

- **Goal**: Add default-off `bot_controlled` + `bot_policy` exports to PlayerTank. When flag-on, bot drives via Input.parse_input_event upstream (no in-tank code change beyond the exports). When flag-off, ZERO code path change vs arc-4-close. Hash anchor verified bit-identical post-write.
- **Requirements**: AC-001 (depended on by bot implementations), AC-005 (hash anchor preservation)
- **Dependencies**: U1
- **Files**:
  - Modify: `scripts/PlayerTank.gd` (add 2 @export vars near top of class; add 1 assertion in `_ready()`; NO change to `_physics_process` input-reading section — the BotInputDriver writes to the shared Input state via `parse_input_event` and the existing `Input.is_action_pressed` reads it transparently)
  - Test: `loop/eprime-experiment/test_player_tank_bot_hook.gd` (verifies: flag-off → tile_hash unchanged; flag-on with mock bot_policy → tank receives bot input)
- **Approach**: Two `@export` vars only. The existing `_physics_process` input-reading code (lines 569+ ui_action_pressed checks) stays IDENTICAL — Input.parse_input_event injects events into Godot's Input singleton, and `Input.is_action_pressed("ui_up")` reads from that singleton transparently. This is the arc-3 L5 pattern: the bot driver synthesizes input, PlayerTank reads input, no awareness of source needed.
- **Patterns to follow**: arc-3 input synthesis precedent in `loop/originals/iter027-meta-arc3-ceiling.md` § PATTERN 5; default-on substrate gating per arc-4 STATE.md `hash_anchor_at_iter_274` (PlayerTank reload bar added inside `if loadout != null:` block).
- **Test scenarios**:
  - *Happy path (flag-off)*: PlayerTank with `bot_controlled = false` runs in `scenes/ProceduralLevel.tscn` seed 42 → `loop/test_runner.gd` reports `tile_hash == 23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`. **Mutation test**: temporarily remove the `if bot_controlled and bot_policy != null` guard → tile_hash mismatch detected.
  - *Happy path (flag-on)*: PlayerTank with `bot_controlled = true`, mock `bot_policy` returning `{move_dir: UP, fire: true}` → after BotInputDriver synthesizes KEY_UP + SPACE via parse_input_event, tank moves up + shoots within 3 frames.
  - *Edge case*: `bot_controlled = true` AND `bot_policy = null` → `_ready()` pushes warning (not crash); tank stationary.
  - *Integration*: full Q1ProofRoom load with ApproachEnemyBot → tank reaches and engages first enemy within 5 sec.
- **Verification**: hash anchor verifies bit-identical via `make check-hash-anchor`; `make test-all` stays 5/5 green; bot-hook harness exits 0.
- **Substrate-touch**: YES (Layer 2: scripts/PlayerTank.gd). Default-on gating verified: flag-off codepath bit-identical. Hash anchor post-write verification: MANDATORY before commit.
- **Size**: S (small surgical change; the BIG cost is verification carefulness)

### U3. BotInputDriver (action → input synthesis)

- **Goal**: Translate Action structs into InputEventKey events via `Input.parse_input_event`. Sibling node, no substrate touch.
- **Requirements**: AC-001 (action contract execution)
- **Dependencies**: U1
- **Files**:
  - Create: `scripts/bots/BotInputDriver.gd` (Node, sibling-of-PlayerTank in scene tree)
  - Test: `loop/eprime-experiment/test_bot_input_driver.gd` (verifies action → input event mapping)
- **Approach**: Node attached as sibling of PlayerTank in the bot-controlled scene. Per-`_physics_process` tick: read `bot_policy.tick(observation)`, translate Action to InputEventKey events, await `process_frame`. Cardinal moves → `KEY_LEFT/RIGHT/UP/DOWN` (matching `ui_left/right/up/down` action bindings). Fire → `KEY_SPACE` (matching `ui_accept`). Shell swap → `KEY_TAB` if shell_swap_to differs from current shell.
- **Patterns to follow**: `loop/test_titlescreen_nav.gd` (arc-3 iter 25 input synthesis pattern — exact precedent for parse_input_event + await process_frame).
- **Test scenarios**:
  - *Happy path*: Action {move_dir: L, fire: false, shell_swap_to: -1} → after 1 frame, `Input.is_action_pressed("ui_left") == true` AND other directions false
  - *Edge case*: Action {move_dir: NONE} → no movement key pressed
  - *Error path*: bot_policy.tick() returns null → driver logs warning, emits empty Action (no input), continues
  - *Integration*: 10 consecutive ticks with alternating move dirs → tank position changes monotonically in declared direction
- **Verification**: harness `check-bot-driver` exits 0; integration test with ApproachEnemyBot in Q1ProofRoom shows tank movement matching bot output
- **Substrate-touch**: NONE
- **Size**: S

### U4. TelemetryRecorder (signal subscriber + per-tick observation sampler)

- **Goal**: Record telemetry per run by subscribing to PlayerTank signals + sampling observation each tick. Emit JSON conforming to AC-002 schema on death/victory/timeout.
- **Requirements**: AC-002 (telemetry contract)
- **Dependencies**: U1 (Observation struct), U2 (must work alongside bot-controlled PlayerTank; can also work in human play for debug)
- **Files**:
  - Create: `scripts/telemetry/TelemetryRecorder.gd` (Node)
  - Create: `scripts/telemetry/TelemetrySchema.gd` (validation helper, RefCounted)
  - Create: `tests/fixtures/telemetry_good.json` (hand-crafted VALID fixture)
  - Create: `tests/fixtures/telemetry_bad.json` (hand-crafted INVALID — for oracle independence per goal principle #2)
  - Test: `loop/eprime-experiment/test_telemetry_recorder.gd` + `loop/eprime-experiment/test_telemetry_schema.gd`
- **Approach**: TelemetryRecorder attaches as sibling of PlayerTank, finds it via `get_parent().get_node("PlayerTank")` (matches arc-3/4 sibling-lookup pattern per arc-3 PATTERN 7 sibling-via-tiles-parent). Subscribes in `_ready()`: `player.shoot.connect(_on_shoot)`, `player.hp_changed.connect(_on_hp_changed)`, `player.died.connect(_on_died)`, `player.lives_changed.connect(_on_lives_changed)`. Asserts all 4 signals exist (`assert(player.has_signal("shoot"))` etc.) — fails fast if PlayerTank refactor drops one. Per-`_physics_process`: samples `_build_observation()` + appends UI-state snapshot. On `_on_died`: computes telemetry dict, validates via TelemetrySchema.validate(), writes to `data/telemetry/seed_NN_bot_X.json`.
- **UI-action correlation algorithm**: keep a rolling window of `(tick, observation_snapshot, action_taken)` tuples (window size 60 ticks = 1 sec at 60fps). When a watched UI state field changes between tick N and tick N+1, look forward N+1..N+30 for action changes. Compute `correlation = (sum of |Δaction| in window) / window_length`. Report per UI field: `{reload_bar_change_count, action_delta_avg_post_reload_change, ...}`.
- **Patterns to follow**: arc-3 `scripts/StageDirector.gd` (signal subscription + sibling-lookup pattern); arc-4 `scripts/RunRecap.gd` (telemetry-on-death JSON write pattern).
- **Test scenarios**:
  - *Happy path*: instantiate TelemetryRecorder as sibling of PlayerTank in Q1ProofRoom, run 5 sec, trigger PlayerTank.died → JSON file exists at `data/telemetry/seed_42_bot_test.json` AND parses AND validates against schema.
  - *Edge case*: PlayerTank fires 0 shots → shells_fired_per_class = {AP:0, HE:0, HEAT:0, APCR:0}, shell_hit_rate = 0.0 (NOT NaN)
  - *Error path*: PlayerTank lacks `shoot` signal (mock with missing signal) → `_ready()` assertion fails immediately with clear error
  - *Oracle independence*: `TelemetrySchema.validate(telemetry_good.json) == true` AND `validate(telemetry_bad.json) == false` — both fixtures required to exist BEFORE the validator passes (this is the "verifier you author must first fail" check)
  - *Integration*: full 10-sec run with ApproachEnemyBot + TelemetryRecorder → telemetry JSON shows shots fired, damage taken, ui_action_correlation populated for at least 2 fields
- **Verification**: harness `check-telemetry-schema` exits 0 with `TELEMETRY_OK 2/2 fixtures conform`; harness `check-telemetry-recorder` exits 0 with `RECORDER_OK <N> events captured`
- **Substrate-touch**: NONE
- **Size**: M

### U5. Seed bank (12 seeds + tier classifier)

- **Goal**: Author 12 fixed seeds partitioned 4/4/4, ship reachability-tested + tier-classified.
- **Requirements**: AC-003
- **Dependencies**: U2 (bot-controlled PlayerTank needed for tier validation via baseline-bot survival rate) — though initial reachability-only classification could come from U1 directly via existing `loop/test_runner.gd`
- **Files**:
  - Create: `data/seed_bank/seeds.json` (12 entries, schema below)
  - Create: `tools/classify_seed.gd` (helper: given seed, runs reachability + optional baseline-bot pass, emits tier)
  - Test: `loop/eprime-experiment/test_seed_bank.gd`
- **Approach**: Tier classifier formula (decisive per architectural question 8):
  - **easy**: `reachable_cells > 800` AND (optional cross-check) ApproachEnemyBot survives ≥80% of 5 sample runs
  - **medium**: `reachable_cells ∈ [500, 800]` OR ApproachEnemyBot survives 40-80%
  - **hard-or-bug**: `reachable_cells < 500` OR seed is a known-regression seed (manually flagged with `bug_id` field)
- **seeds.json schema**:
  ```json
  [
    {"seed": 42, "tier": "easy", "reason": "baseline procedural", "expected_band": "warmup", "reachable_cells": 676, "bug_id": null},
    ...
  ]
  ```
- **Bootstrapping**: start with seed 42 (the historical baseline — tier classification should yield "medium"). Pick 11 more via systematic sampling (e.g. seeds 1, 13, 100, 256, 999, 1000, 2026, plus 4 hand-picked from arc-4 LEDGER's reported reachability data). Run classify_seed.gd on each, accept the classification, manually adjust if a seed lands in the wrong tier band by sampling another.
- **Patterns to follow**: `data/stages/` (arc-3 vendored stage files, JSON-equivalent structure pattern); `loop/test_runner.gd --seed N --json` (reachability oracle output format).
- **Test scenarios**:
  - *Happy path*: load `data/seed_bank/seeds.json` → exactly 12 entries; counts: 4 easy, 4 medium, 4 hard-or-bug
  - *Happy path*: for each seed, `classify_seed.gd <seed>` → emits same tier as declared in JSON (mutation: change a declared tier → check-seed-bank fails)
  - *Edge case*: seed = 0 (a known-edge-case value) → classifier doesn't crash; tier reported
  - *Error path*: malformed seeds.json (missing field) → check-seed-bank exits non-zero with clear error
- **Verification**: `make check-seed-bank` exits 0 with `SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)`; tier mutation detected.
- **Substrate-touch**: NONE
- **Size**: M

### U6. 7 bot policy implementations

- **Goal**: Implement the 7 bot policies, each a 30-100 line GDScript file extending BotPolicy.
- **Requirements**: AC-001 (the 7 policies)
- **Dependencies**: U1, U2, U3, U4 (need full bot loop running to test each policy)
- **Files**:
  - Create: `scripts/bots/MoveToCoverBot.gd`
  - Create: `scripts/bots/DodgeShellBot.gd`
  - Create: `scripts/bots/ApproachEnemyBot.gd`
  - Create: `scripts/bots/FireWhenLinedUpBot.gd`
  - Create: `scripts/bots/ReloadAwareWaitBot.gd`
  - Create: `scripts/bots/PanicRandomBot.gd`
  - Create: `scripts/bots/ObjectiveRushBot.gd`
  - Create: `scripts/bots/<each>.tres` (Resource instance for each, for `@export var bot_policy: Resource`)
  - Test: `loop/eprime-experiment/test_bots.gd` (7 cases, one per bot — synthetic observation in, expected action class out)
- **Approach**: Each bot is a pure function of observation → action. No internal mutable state between ticks (deterministic + testable). Implementation outlines:
  - **MoveToCoverBot**: scan visible_obstacles for nearest STEEL/BRICK; compute perpendicular hug vector; move_dir = that vector's cardinal projection; fire = false
  - **DodgeShellBot**: scan visible_projectiles where owner != player AND dir vector intercepts player_pos_tile; compute orthogonal dodge vector; move_dir = that; fire = false
  - **ApproachEnemyBot**: scan visible_enemies; pick closest by Manhattan distance; move_dir = sign(enemy.pos - player.pos) cardinal projection; fire = (enemy aligned in cardinal axis AND reload_bar_value >= 0.8)
  - **FireWhenLinedUpBot**: same enemy scan; fire = (closest enemy in cardinal axis); move_dir = NONE (stationary fire bot)
  - **ReloadAwareWaitBot**: same fire-eligibility check as ApproachEnemyBot; fire ONLY if reload_bar_value >= 0.8 (no premature fires); else move_dir = AWAY from nearest enemy
  - **PanicRandomBot**: if player_hp / player_hp_max < 0.25 → move_dir = random_cardinal(); fire = false; else fall back to ApproachEnemyBot logic
  - **ObjectiveRushBot**: assume exit is at "north" of room (y = 0); move_dir = UP; fire = (visible_obstacle in cardinal path that requires breach)
- **Patterns to follow**: minimal — these are pure heuristic policies. Reference `scripts/Enemy.gd` AI tree for enemy-side heuristic patterns (cardinal projection logic + line-of-sight checks).
- **Test scenarios** (per bot — happy path + edge):
  - *Happy path (each bot)*: synthetic observation matching the bot's trigger → assertions about returned Action (e.g. ApproachEnemyBot given visible enemy at (10,5) and player at (5,5) → action.move_dir == R)
  - *Edge case (each bot)*: empty observation (no enemies, no projectiles, full HP) → action is well-defined (each bot has a fallback)
  - *Integration*: each bot runs in Q1ProofRoom for 10 sec → emits telemetry; no crashes; reasonable behavior (e.g. PanicRandomBot triggers only when HP drops)
- **Verification**: `make check-bots` exits 0 with `BOTS_OK 7/7`; each bot's harness case passes
- **Substrate-touch**: NONE
- **Size**: L (7 bots × moderate logic each; expect 2-4 hours total)

### U7. Batch runner (loop/eprime-experiment/bot_runner.gd)

- **Goal**: Single-process headless batch that runs 84 (bots × seeds) combos cleanly with state reset between runs.
- **Requirements**: AC-004 (84 runs complete clean)
- **Dependencies**: U2, U3, U4, U5, U6 (everything must work for batch to succeed)
- **Files**:
  - Create: `loop/eprime-experiment/bot_runner.gd` (extends SceneTree, mirrors test_runner.gd pattern)
  - Test: `loop/eprime-experiment/test_batch_runner.gd` (small N×M subset to verify reset logic before full 84-run)
- **Approach**: Extends SceneTree per arc-3 `test_runner.gd` precedent. CLI args: `--bots <comma-list>` (default: all 7), `--seeds <comma-list>` (default: all 12 from seeds.json), `--out <dir>` (default: `data/telemetry/`). For each (bot, seed) combo:
  1. Load `scenes/Q1ProofRoom.tscn` via `change_scene_to_packed`
  2. Wait 1 frame for `_ready()` chain
  3. Get PlayerTank node; set `bot_controlled = true` + `bot_policy = load("res://scripts/bots/<bot>.tres")`
  4. Add BotInputDriver + TelemetryRecorder as siblings
  5. Await `PlayerTank.died` OR timeout (30 sec hard cap → death_cause = "timeout")
  6. Read telemetry from TelemetryRecorder; write to `<out>/seed_<NN>_bot_<X>.json`
  7. Assert clean state for next iter (no orphaned nodes, no leftover signals)
  8. Loop
- **Wall time discipline**: 84 × ~2.5 sec/run = ~3.5 min total target; alert if >5 min
- **Patterns to follow**: `loop/test_runner.gd` (SceneTree extension + headless scene loading); `loop/test_chain_35.gd` (arc-3 35-stage chain test — the gold-standard for clean per-iter state reset across many scene loads)
- **Test scenarios**:
  - *Happy path*: small batch (2 bots × 2 seeds = 4 runs) → 4 JSON files emit, all parse, all conform to schema
  - *Edge case*: bot crashes mid-run (synthetic broken bot) → batch logs error + records `death_cause: "crash"` (or similar) + continues to next combo; final emit is `RUNS_OK 3/4 (crashed: 1)`
  - *Error path*: missing seed in seeds.json → exits non-zero with clear error
  - *Integration*: full 84-run batch from clean state → `RUNS_OK 84/84` AND total wall time <5 min
- **Verification**: `make check-84-runs` exits 0 with `RUNS_OK 84/84 (timeout: <N>, death: <M>, victory: <K>; N+M+K=84)`
- **Substrate-touch**: NONE
- **Size**: M

### U8. Makefile targets + final-verify composite

- **Goal**: New Makefile targets gating each criterion + composite `bot-harness` final-verify.
- **Requirements**: AC-006 (make test/test-all/bot-harness all green)
- **Dependencies**: U1..U7 (every prior unit needs its `make check-*` target wired)
- **Files**:
  - Modify: `Makefile` (add targets: `check-bots-base`, `check-bots`, `check-bot-driver`, `check-telemetry-recorder`, `check-telemetry-schema`, `check-seed-bank`, `check-84-runs`, `check-hash-anchor`, `check-orchestration`, `bot-harness` composite)
  - Test: `Makefile` itself — `make -n bot-harness` shows expected sub-command chain
- **Approach**: Composite `bot-harness` target depends on (in order): check-hash-anchor (gate-first; fail fast if substrate broke) → check-bots-base → check-bots → check-bot-driver → check-telemetry-schema → check-telemetry-recorder → check-seed-bank → check-84-runs → check-orchestration. Each sub-target prints a `<NAME>_OK ...` sentinel on success. Composite prints final `BOT_HARNESS_OK 84/84` only when ALL sub-checks exit 0.
- **Patterns to follow**: existing Makefile targets `test`, `test-all`, `test-breach` (the composite pattern — chained sub-checks with sentinel grep on stderr).
- **Test scenarios**:
  - *Happy path*: `make bot-harness` from clean state with all units shipped → exits 0, stdout contains `BOT_HARNESS_OK 84/84`
  - *Edge case*: one sub-check (e.g. check-seed-bank) fails → composite exits non-zero, no `BOT_HARNESS_OK` emitted
  - *Error path*: missing sub-target (rename or typo) → make errors with target-not-found
- **Verification**: `make bot-harness` end-to-end exits 0; `make test` + `make test-all` remain 5/5 green
- **Substrate-touch**: NONE
- **Size**: S

### U9. Orchestration entry point (tools/bot_runner.sh + summary JSON)

- **Goal**: Shell-wrapper CLI for outer-loop integration. Calls bot_runner.gd, aggregates per-run telemetry into a summary JSON.
- **Requirements**: AC-007
- **Dependencies**: U7
- **Files**:
  - Create: `tools/bot_runner.sh` (shell wrapper with arg parsing + godot invocation)
  - Create: `tools/bot_summary.py` (Python aggregator: reads N telemetry JSONs → emits summary JSON)
  - Test: `loop/eprime-experiment/test_orchestration.gd`
- **Approach**: Shell wrapper takes `--bots <list> --seeds <list> --out <path>` args, invokes `godot --headless --script loop/eprime-experiment/bot_runner.gd -- --bots <list> --seeds <list>`, waits for completion, runs `bot_summary.py --in <out_dir> --out <summary_path>`. Summary JSON aggregates: per-bot aggregate metrics (avg survival, avg shells fired, etc.), per-seed difficulty validation, full telemetry file list. Outer loops (whether /loop, /goal, or future arms) read summary JSON to decide next iteration.
- **Patterns to follow**: existing `tools/screenshot-q1.sh` or `tools/png_diff.py` (shell/python wrapper precedent for Godot orchestration).
- **Test scenarios**:
  - *Happy path*: `tools/bot_runner.sh --bots move-to-cover,panic-random --seeds 1,7 --out /tmp/bot_run/` → 4 telemetry JSONs + `/tmp/bot_run/summary.json` exists + parses
  - *Edge case*: `--bots nonexistent_bot` → fails loudly (NOT silent skip per AC-007 fail_evidence)
  - *Error path*: Godot exits non-zero → shell wrapper exits non-zero, no summary JSON written
  - *Integration*: `tools/bot_runner.sh --bots all --seeds all --out data/telemetry/` → equivalent to `make check-84-runs` (84 JSONs + 1 summary)
- **Verification**: `make check-orchestration` exits 0 with `ORCHESTRATION_OK`; mutation test (`--bots invalid`) fails loudly
- **Substrate-touch**: NONE
- **Size**: S

## Implementation order

```
1. U1 (BotPolicy base + Action/Observation)          [foundation; no deps]
2. U2 (PlayerTank bot-input hook)                    [SUBSTRATE TOUCH; hash anchor verified post-write]
3. U3 (BotInputDriver) || U4 (TelemetryRecorder)     [parallel; both depend only on U1]
4. U5 (Seed bank)                                    [needs U2 for bot-validated tier check; can start with reachability-only]
5. U6 (7 bot implementations)                        [needs U1+U2+U3+U4 for end-to-end testing per bot]
6. U7 (Batch runner)                                 [needs U2+U3+U4+U5+U6]
7. U8 (Makefile targets) || U9 (Orchestration)       [parallel; both depend on U7]
```

Total estimated effort: ~20-30 hours single-dev wall-clock (mix of S/M/L units; the L unit U6 dominates).

## Substrate-touch checklist

Only ONE substrate touch in this whole blueprint: **U2 (PlayerTank.gd)**.

| Pre-commit gate | Check |
|---|---|
| Default-on flag added | `@export var bot_controlled: bool = false` (defaults to false, arc-2/3/4 behavior preserved) |
| Companion flag added | `@export var bot_policy: Resource = null` (defaults to null) |
| Hash anchor verified bit-identical | `godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --json | jq -r .tile_hash` returns `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` |
| Arc-3 regression preserved | `make test-all` exits 0 with 5/5 PASS |
| Existing arc-4 behavior preserved | `make test-breach` (if still relevant after arc-4 merge) exits 0 |
| STATE.md hash_anchor_at_iter_NNN entry written | with explanation of why flag-off path is bit-identical |

If hash anchor breaks: revert immediately; investigate why parse_input_event injection differs from keyboard input at the Input singleton layer; reconsider whether the bot-input pathway needs a wholly different mechanism (e.g. signal-based override instead of Input synthesis).

## Bug-trace cross-check (consult-001 predictions → harness measurement)

| Consult-001 prediction | TelemetryRecorder mechanism | Test that locks it in |
|---|---|---|
| **P2**: "Top-left reload bar will be read AFTER combat, not USED during combat" | `ui_action_correlation.reload_bar_value`: tracks (reload_bar value changes per tick) → (action changes within next 30 ticks). If correlation is high → bot uses reload bar to time shots. If low → reload bar is post-hoc info. Bot-equivalent of "during pressure player attends elsewhere" | `test_telemetry_recorder.gd::test_reload_correlation_tracked` |
| **P3**: "Bottom-left 3-strip stacking will be IGNORED under pressure" | `ui_action_correlation.ribbon_visible`: tracks (active card chip count changes) → (action delta). Combined with HP < 50% pressure filter — if bot's action doesn't shift when ribbon updates AND HP is low → ribbon is being ignored under pressure | `test_telemetry_recorder.gd::test_ribbon_correlation_pressure_filter` |
| **P1**: "Active build legibility will FAIL" (active cards readable in <5s during combat) | NOT measurable by bot (active card "legibility" requires human cognition per consult §3); bot can measure correlation between card pickup and action change, but NOT whether the card's MEANING was understood. Listed in `what_cannot_be_known_from_consult` | n/a — telemetry records the correlation; legibility itself remains [FEEL] cap-5 / playtest-only |

The harness scores 2 of 3 predictions structurally → enables `[FEEL-CONSULT]` calibration credit per CONSULT-LEDGER rules (≥2 hits AND hit rate ≥50% → cap may rise to 4 for those signal classes). Real playtest scoring still required for the human-cognition prediction P1.

## Scope Boundaries

- This blueprint covers ONLY the bot-harness scaffolding. NOT the arm-loops (Arm 1 subtraction loop + Arm 2 E′ loop) — those get their own /loopgen runs after scaffolding ships.
- NOT in scope: scoring consult-001 predictions (the harness ENABLES scoring; the user/loop scores them after running 84-batch + analyzing summary).
- NOT in scope: Round 25 visual identity (a separate loop concern; bot harness is instrumentation only).
- NOT in scope: bot improvements beyond the 7 named (future arms may add more; this scaffolding is the 7-bot baseline).

### Deferred to Follow-Up Work

- **Replay capture**: emitting Godot --write-movie alongside telemetry JSON per run, for visual review of representative runs. Defer to Arm 1/2 loop work if predictive prediction-scoring lands and a deeper bot-vs-human comparison is useful.
- **RL/learned bot policies**: deliberately deferred per consult §3 — scripted heuristic policies are the safe foundation. Defer until n=2 evidence shows scripted policies cap out.
- **Bot pixel-view (true pixel-input)**: current observation is "screen-visible structured fields" (proxy for what a human sees). True pixel-input would require frame capture + CV. Deferred — current proxy is good enough for consult-001 P2+P3 calibration.
- **Multi-scenario host**: bots only play Q1ProofRoom in this scaffolding. Adding BreachLevel.tscn or other scenes is straightforward but deferred to arm loops.

## System-Wide Impact

- **Interaction graph**: BotInputDriver writes to Input singleton via `parse_input_event`; PlayerTank reads it. TelemetryRecorder subscribes to PlayerTank signals + samples Observation each `_physics_process`. bot_runner.gd orchestrates scene load + cleanup. NO touch of LevelConfig / ProceduralLevel / OriginalLevel / Spawner / Enemy / Bullet — these substrate files stay frozen.
- **Error propagation**: bot crash → caught in BotInputDriver's `_physics_process` try-or-warn; logged + telemetry death_cause = "crash"; batch continues to next combo. Telemetry write failure → logged but doesn't crash batch (best-effort). Schema validation failure → batch records but doesn't abort.
- **State lifecycle risks**: per-run scene reload via `change_scene_to_packed` MUST garbage-collect prior scene's nodes; TelemetryRecorder + BotInputDriver must not survive scene reset (no autoload). Tested by U7 batch runner test scenarios.
- **API surface parity**: PlayerTank gains 2 @export fields (visible in editor inspector). All other code reading PlayerTank's input is unchanged (input is Godot-singleton-mediated).
- **Integration coverage**: per-unit tests cover unit boundaries; U7's batch test covers integration (84 runs from clean state) which IS the integration proof for the whole harness.
- **Unchanged invariants**: hash anchor `23d6a2ec…` bit-identical on procedural baseline (AC-005); arc-3 OG mode behavior (make test-all 5/5); arc-4 breach mode behavior (Q1ProofRoom + Round 25 work) preserved.

## Risks & Dependencies

| Risk | Mitigation |
|---|---|
| `parse_input_event` injection behaves subtly different from real keyboard at the Input singleton layer (e.g. timing of `is_action_pressed` polling vs event arrival) | Test scenarios in U3 explicitly verify movement key-press → tank moves within N frames; integration test in U6 verifies 7 bots all produce expected movement. If divergence detected: switch to signal-based override (PlayerTank exposes `bot_input_received(action)` signal, BotInputDriver emits) — requires larger U2 substrate touch. |
| Per-run scene reset leaks state across 84 runs → silent failures | U7 batch test includes mid-batch state assertion: after `change_scene_to_packed`, no orphan nodes named TelemetryRecorder / BotInputDriver from prior run; PlayerTank starts at default HP/position/shells. If leak found: explicit `queue_free()` + `await process_frame` cycle before next iter. |
| 84-run total wall time exceeds 5 min | Profile early (after U7 ships). If >5 min: reduce per-run timeout (currently 30 sec hard cap), or reduce scene-reload cycle overhead by reusing the same scene instance + resetting state in-place instead of full reload. |
| TelemetryRecorder schema drifts from telemetry JSONs produced | U4 oracle-independence test: hand-crafted INVALID fixture MUST fail validator; hand-crafted VALID fixture MUST pass. Both fixtures committed; any schema change requires updating both fixtures + re-passing the test (mutation guard). |
| Bot policies produce nonsense (e.g. ApproachEnemyBot can't actually reach enemies in Q1ProofRoom because of room geometry) | U6 integration tests run each bot for 10 sec in Q1ProofRoom — manually inspect telemetry. If a bot is dead-on-arrival useless, revise its policy. NOT a release blocker — even useless bots produce valid telemetry; downstream analysis judges policy quality. |
| Substrate touch in U2 breaks hash anchor (highest-risk event in whole blueprint) | U2 includes mutation test + bit-identical verification BEFORE commit. If breaks: revert + investigate. Pattern is well-precedented (96 substrate writes through arc 4 preserved hash) — but caution warranted. |

## Open questions deferred

- Should TelemetryRecorder ALSO record a frame snapshot (PNG) per N ticks, for post-run visual review? Useful for arm-loop debugging but defers per "Replay capture" in Deferred section.
- Should the orchestration entry point ALSO emit a comparison JSON when given a prior `summary.json` baseline (so arm-loops can A/B)? Useful but defers to arm-loop blueprint.
- Should bot policies have access to a "bot memory" struct (carry state across ticks)? Currently NO — bots are pure functions. Future arms may want simple memory (e.g. "remember which lane I tried last"). Defer.

## Confidence cross-check (high-risk checklist — substrate touch + cross-cutting)

- [x] Decision rationale explicit — every architectural choice cited the priority criterion that decided it
- [x] Data flow traced end-to-end — bot_runner.gd → BotPolicy.tick → BotInputDriver → Input singleton → PlayerTank → signals → TelemetryRecorder → JSON
- [x] Integration scenarios named — U7 batch test IS the integration proof for the whole harness; per-bot integration tests in U6
- [x] Unchanged invariants stated — hash anchor `23d6a2ec…`; arc-3 test-all 5/5; arc-4 breach mode behavior
- [x] Failure modes enumerated for each external boundary — bot crash / scene reset leak / wall time overrun / schema drift / nonsense policy / substrate hash break
- [x] Files-to-touch list grounded in actual code investigation — PlayerTank.gd input section at line 569+ verified; test_runner.gd SceneTree pattern verified; existing signals (shoot, hp_changed, died, lives_changed) verified

Blueprint ready for `/build` consumption. The goal loop's iter 1 should start at U1.
