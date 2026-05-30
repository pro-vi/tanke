# Handover — arc-harness-v0.2: build U10 (motion-primitive controller) → finish

Resuming the **tanke** Godot 4.6 game (`~/Development/_projs/tanke`), branch
**arc-5-bot-harness**. Fresh session — the in-memory task list is likely gone;
reconstruct it from this doc + the plan.

## Read first
1. `docs/plans/2026-05-29-001-feat-arc-competent-bot-plan.md` — the plan.
   **Especially the "Addendum 2026-05-30"** = the motion-primitive controller
   blueprint (your spec for U10).
2. `git log --oneline -6` on arc-5-bot-harness — `b0d79ea5` (U5 batch runner),
   `564f52e8` (arc harness + bot WIP). Nothing pushed; PR #5 is the clean Q1 harness.

## Goal
A deterministic composite bot ("competent") that autonomously PLAYTESTS the REAL
procedural arc (`scenes/BreachLevel.tscn`) — climbing 5 bands (tutorial_choke
0–30 → shuffled brick_maze/bunker_zone/open_killbox → endgame_mixed 180–260) —
emitting per-band telemetry. The harness IS the autonomous-playtest instrument.

## State (built, unit-green, committed)
- `scripts/bots/CompetentBot.gd` — composite cascade (dodge/climb/breach/fire) +
  stateful `NavMemory` (accumulated-terrain frontier planner; escapes water/steel
  local minima). **NOT in BotRegistry** (keeps Q1 7-bot/84-run frozen).
- `scripts/bots/NavMemory.gd` — the planner.
- `scripts/telemetry/ArcTelemetrySchema.gd` (v0.2-arc, strict v0.1 superset) +
  `ArcTelemetryRecorder.gd` (per-band segments, depot picks, victory = endgame band).
- `loop/eprime-experiment/arc_run_helper.gd` — one BreachLevel run (code-side
  archetype-skip + depot auto-drive; fails loud on unknown bot / unreadable file).
- `loop/eprime-experiment/arc_runner.gd` — batch (U5 DONE): `ARC_RUNS_OK N/N`.
- Verifiers: `test_competent_bot.gd` (COMPETENT_OK), `test_arc_telemetry_schema.gd`
  (ARC_TELEMETRY_OK 2/2), `test_arc_telemetry_recorder.gd` (ARC_RECORDER_OK).
- Untracked validation probes: `test_arc_diag.gd` (per-tick trajectory/action
  trace), `test_arc_smoke.gd` (one competent run → depth/band/cause).

**Capability now:** out-climbs every single-verb baseline (early-arc rows ~4–12
vs 0; survives full runs) but CAPS early. Q1 intact: `make bot-harness` →
BOT_HARNESS_OK 84/84, `make check-hash-anchor` → HASH_OK, `make test-all` 5/5.

## Key finding — do NOT re-derive (GPT-Pro second opinion, conf 0.86)
The depth ceiling is a **MOTOR-CONTROL abstraction problem, NOT pathfinding.**
Tell: three different planners all stalled at the same depth → the *actuator* is
broken, not the search. The planner commands a "tile agent," but physics is a
16px CharacterBody2D swept through 8px terrain — a few px of lateral drift clips a
flank, and cardinal "press up" can't correct the offset → limit cycle (the
oscillation). Endgame is NOT proven infeasible (1440px ÷ 32px/s ≈ 45s ≪ 240s cap).

## U10 — THE NEXT BUILD (gating; validate BEFORE tuning)
Replace the cascade's CLIMB step with a **footprint-aligned motion-primitive controller**:
- Plan over **2×2 tank-footprint poses** (not single 8px cells); inflate
  impassable by the footprint (NavMemory already inflates water/steel by 1).
- **Phase-based primitive** — NOT a per-tick realign-or-advance toggle (that
  REGRESSED, row 6→0). Align the perpendicular axis FULLY first (REALIGN; lane-error
  in world px via `obs.player_pos_px`), THEN advance (ADVANCE) while holding lane
  tolerance; ABORT the primitive if distance-to-target hasn't shrunk for N ticks.
- Outcomes fed back to the planner: SUCCESS / BLOCKED_BY_IMPASSABLE /
  BLOCKED_BY_BRICK_NEEDS_BREACH / STUCK_COLLISION_NO_PROGRESS /
  INTERRUPTED_BY_THREAT / TIMEOUT.
- Separate **breach primitive**: stand off → face → shoot until the full footprint
  path clears → advance (not drive-into-brick-and-grind).
- Snap to clean **footprint** alignment (valid poses may be every 8px — derive
  empirically from the collision shape), NOT a blind 16px macrogrid (rejects
  valid one-tile-shifted lanes).
- Scaffolding already staged: `obs.player_pos_px`, `NavMemory.current_target()`,
  `CompetentBot.CELL_PX`/`LANE_TOL`.

**Validation gate (FIRST, before any planner tuning):** on empty/lightly-obstructed
real-arc starts the bot must execute adjacent footprint-pose transitions with HIGH
success + explicit failure labels. Measure with `test_arc_diag.gd` /
`test_arc_smoke.gd` (run via `godot --headless --path . --fixed-fps 60 --script
res://loop/eprime-experiment/test_arc_smoke.gd`). Target: ceiling rises ~12 → ~30–60+.

**Discipline:** bounded build → measure → fix. This chaotic-physics tuning spiraled
THREE times last session when rushed. Build the proper phase machine, measure once,
fix deliberately, don't whack-a-mole. Commit when the ceiling lifts.

## Remaining units (DAG): U10 → U6 → U7 → U8  (U5 done)
- **U6** `loop/eprime-experiment/test_arc_climb.gd` — competence oracle calibrated to
  DEMONSTRATED capability: competent decisively out-climbs baseline (teeth:
  objective-rush ≈0) + median depth ≥ T (T from real measurement AFTER U10) +
  conforming per-band telemetry across the 12 seeds. Assert endgame-reach ONLY if
  U10 achieves it — don't bake victory=endgame in beforehand.
- **U7** `Makefile` — NEW targets only (check-competent-bot, check-arc-telemetry-schema,
  check-arc-runs, check-arc-climb) + `arc-harness` composite → `ARC_HARNESS_OK`.
  Mirror the arc-5 `check-*` house style; do NOT edit existing targets.
- **U8** `loop/eprime-experiment/ACCEPTANCE-arc.md` (arc-harness-v0.2) + final-verify in
  ONE repo state (`make arc-harness` ∧ `make bot-harness` 84/84 ∧ `make test-all` ∧
  HASH_OK). **PRODUCT FORK — the human decides the bar:** (a) endgame-victory if U10
  reaches it, else (b) honest capability-acceptance (out-climbs baseline + per-band
  failure-localization signal — independently rated a valuable deliverable, 0.9).
  Record the real depth distribution truthfully.

## Hard constraints (non-negotiable)
- FORBIDDEN edits: `scenes/*.tscn` (incl BreachLevel — that's why archetype-skip +
  depot-drive live in code in arc_run_helper), `scripts/ProceduralLevel.gd` +
  Layer 1–3 substrate, C#. Don't break `make test-all`.
- CompetentBot stays OUT of BotRegistry. After ANY shared-file edit
  (ObservationBuilder/BotObservation/BotHeuristics/BotInputDriver), re-run
  `make bot-harness` (BOT_HARNESS_OK 84/84) + `make check-hash-anchor` (HASH_OK).
- New `class_name` files → `godot --headless --path . --import` before running (SH-001).
- Determinism per seed. Commit only when asked; you're on arc-5-bot-harness (not
  default). End commit messages with:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

## Terrain cheat-sheet
16px tank on 8px tiles. brick = breakable by shooting (AP; HE opens wide lanes),
steel = breakable by APCR only, water = impassable (collision layer 512).
Procedural blocks auto-name `@StaticBody2D@N` → ObservationBuilder classifies brick
by SCRIPT path + water by LAYER 512 (already fixed; don't regress it).

## First actions
1. Recreate the task list: U10 (in_progress) → U6 → U7 → U8 with the DAG above.
2. Read the plan Addendum + skim CompetentBot.gd / NavMemory.gd / arc_run_helper.gd.
3. Build U10 per the blueprint; run the validation gate (test_arc_diag/smoke) FIRST;
   iterate deliberately; commit when the ceiling lifts.
4. Then U6 → U7 → U8. Make the U8 acceptance-bar call with the human.
