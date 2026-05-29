# LEDGER — bot-harness-v0.1 (append-only, one entry per iteration)

Per PROMPT.md § Artifacts. Each accepted change cites ≥1 criterion ID.

---

## iter 1 — 2026-05-28 — U1 contract foundation + AC-005 verifier + risk retirement

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-001 | no scripts/bots/ types exist | a BotPolicy/Action/Observation contract unblocks all downstream units | 3 new files under scripts/bots/ + a verifier | rm the new files (no substrate touch)`

**Selection**: U1 first per blueprint implementation order (foundation, no deps, cheapest verifier feedback).

**Did**:
- Pre-flight: confirmed Godot 4.6.2 + python3 + jq available; baseline hash anchor = `23d6a2ec…4024291` (seed 42, 676 reachable_cells) bit-identical before any edit.
- Parallel subsystem map (10-agent understand workflow) over PlayerTank substrate, SceneTree runner pattern, Q1ProofRoom scene, Dir/Bullet enums, Enemy heuristics, HUD reads, RunRecap, arc-3 input synthesis, Makefile composite style, Resource/RefCounted convention.
- **Red→green (oracle principle #2)**: wrote `loop/eprime-experiment/test_bots_base.gd` first → ran RED (parse-fail: BotAction/BotObservation/BotPolicy not declared). Created `scripts/bots/{BotAction,BotObservation,BotPolicy}.gd` → ran GREEN (`BOTS_BASE_OK`). Verifier has teeth: malformed actions (move_dir=99, shell_swap_to=7) are rejected by `BotAction.is_valid()`.
- Wired Makefile arc-5 section: `check-bots-base` (AC-001 foundation) + `check-hash-anchor` (AC-005) + `HASH_ANCHOR` var.
- **AC-005 teeth proof** (no forbidden substrate edit): seed-99 → `HASH_BROKEN c777…` + exit 1; seed-42 → `HASH_OK 23d6…` + exit 0. Verifier responds to changed procedural output.
- **Risk retirement** (throwaway probe, not committed): synthetic `Input.parse_input_event` with both `keycode`+`physical_keycode` set drives `is_action_pressed("ui_up")`/`("ui_accept")` AND `is_physical_key_pressed(KEY_TAB)` headless; release event clears the action. → Path B (zero substrate touch) confirmed viable.

**Decision**: AR-001 (in STATE.md) — eliminated the blueprint's U2 substrate touch. The PROMPT scope manifest's necessity test ("only if it cannot live in a scripts/bots/ helper") fails because input is Godot-singleton-mediated; the governing PROMPT overrides the subordinate blueprint. BotInputDriver (U3) holds the policy; PlayerTank untouched.

**Verified / accepted**:
- `make test` → exit 0 (cheap channel; no arc-3 regression from new files).
- `make check-bots-base` → `BOTS_BASE_OK` (exit 0).
- `make check-hash-anchor` → `HASH_OK 23d6a2ec…4024291` (exit 0); teeth proven.

**Status moves**: AC-005 OPEN → PASS_PENDING_FINAL (own verifier green + teeth). AC-001 stays OPEN (foundation green; `make check-bots` 7/7 pending U6).

**Next**: U3 BotInputDriver → then U4/U5/U6 (independent) → U7 batch → U8 composite → U9 orchestration → final-verify `make bot-harness`.

---

## iter 2 — 2026-05-28 — U3 BotInputDriver + shared ObservationBuilder

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-001 | no driver translates BotAction -> PlayerTank input | a sibling BotInputDriver (keycode+physical, held-key mgmt) drives the tank zero-touch | scripts/bots/{ObservationBuilder,BotInputDriver}.gd + verifier | rm new files`

**Did**:
- `scripts/bots/ObservationBuilder.gd` — static `build(player, level, iter_n, time_sec) -> BotObservation`, the shared observation factory (U3 driver + U4 recorder both use it). Reads screen-visible PlayerTank state (hp/shell/reload/reserves/cards/speed/pos) + scene-tree spatial state (enemies in group "enemy"; bullets = Area2D children with start()+source_label; brick/steel StaticBody2D obstacles). Defensive `.get()` reads with fallbacks.
- `scripts/bots/BotInputDriver.gd` — sibling Node holding `bot_policy` (Path B). Per `_physics_process`: build obs → `policy.tick(obs)` → `apply_action()`. Input synthesis sets BOTH keycode+physical_keycode; held-key state so press/release only on change (held dir keeps moving, held fire auto-fires at GunTimer cooldown); shell-swap pulses physical TAB; `release_all()` for clean teardown across U7's 84 reloads.
- Red→green: `test_bot_input_driver.gd` parse-failed (BotInputDriver undeclared) → after creating files + `--import`, `BOT_DRIVER_OK`. Teeth: case2 (dir change U→L must release ui_up) + case3 (idle must release all) catch stuck-key bugs.
- Makefile: `check-bot-driver`.

**Verified / accepted**:
- `make check-bot-driver` → `BOT_DRIVER_OK` (exit 0).
- Impact guards green: `make test` exit 0, `make check-bots-base` exit 0, `make check-hash-anchor` → HASH_OK (no substrate perturbation; new files are siblings).

**Status moves**: none (AC-001 needs U6's 7 bots for `check-bots`; AC-002 needs U4). U3 unblocks U6/U7.

**Next**: U4 TelemetryRecorder + schema + good/bad fixtures (AC-002) — reuse ObservationBuilder; death_cause by nearest-threat heuristic + timeout + victory; find FileAccess/JSON.stringify precedent. Then U5 seeds, U6 bots, U7 batch.

---

## iter 3 — 2026-05-28 — U4a telemetry schema contract + fixtures (AC-002)

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-002 | no telemetry schema/validator exists | a TelemetrySchema.validate() + good/bad fixtures define + enforce the contract; bad must fail first (teeth) | scripts/telemetry/TelemetrySchema.gd + tests/fixtures/telemetry_{good,bad}.json + verifier | rm new files`

**Decision**: split U4 into U4a (schema + fixtures = AC-002's actual verifier `check-telemetry-schema`) and U4b (TelemetryRecorder producer, gated transitively by AC-004's 84 conforming runs). Lets AC-002 reach PASS_PENDING_FINAL on the schema oracle without prematurely building U7's scene machinery.

**Did**:
- `scripts/telemetry/TelemetrySchema.gd` — `validate(t) -> Array` (empty = valid) for all 11 AC-002 fields (survival_time_sec, damage_taken, shells_fired_per_class{AP,HE,HEAT,APCR}, shell_hit_rate[0,1], reload_cancel_events, time_exposed_pct[0,1], death_cause enum, ui_action_correlation{reload_bar,shell_chip,ribbon_visible}, seed, bot_id, schema_version=="v0.1"). `_is_int_like` tolerates JSON int-as-float so the SAME validator passes disk fixtures + the recorder's in-memory ints.
- `tests/fixtures/telemetry_good.json` (valid) + `telemetry_bad.json` (8 deliberate violations).
- Red→green: `test_telemetry_schema.gd` parse-failed (TelemetrySchema undeclared) → after create + `--import`, `TELEMETRY_OK 2/2 fixtures conform`. Teeth: bad fixture REJECTED (8 violations) — a rubber-stamp validator fails this case.
- Makefile: `check-telemetry-schema`.

**Verified / accepted**: `make check-telemetry-schema` → `TELEMETRY_OK 2/2 fixtures conform` (exit 0). Impact guards green: `make test`, `check-bot-driver`, `check-hash-anchor` all pass.

**Status moves**: AC-002 OPEN → PASS_PENDING_FINAL (own verifier green + teeth).

**Next**: U4b TelemetryRecorder (producer; reuse ObservationBuilder; signals shoot/hp_changed/died/lives_changed; death_cause by nearest-threat heuristic + timeout(30s) + victory(GOAL_ROW=0); shell_hit_rate via run_recap if present; reads BotInputDriver.last_action for ui_action_correlation). Then U5 seeds, U6 7 bots, U7 batch.

---

## iter 4 — 2026-05-28 — U4b TelemetryRecorder (producer for AC-002/AC-004)

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-002 | no producer emits conforming telemetry | a sibling TelemetryRecorder subscribing to PlayerTank signals + sampling ObservationBuilder emits a schema-valid JSON per run | scripts/telemetry/TelemetryRecorder.gd + smoke test + BotInputDriver.last_action | rm new files + revert the 2-line driver edit`

**Did**:
- `scripts/telemetry/TelemetryRecorder.gd` — sibling Node. _ready connects + ASSERTS shoot/hp_changed/died/lives_changed exist (fails loud if a refactor drops one). Per tick samples obs (exposure via nearest-enemy ≤12 tiles; reload_cancel = fire while reload<0.8; ui_action_correlation = fraction of UI-state flips [reload-ready / shell-chip / ribbon-visible] followed by an action change within 30 ticks, action read from driver.last_action). On_shoot tallies shells_fired_per_class; on_hp_changed accumulates damage_taken; on_died classifies death_cause by nearest threat (projectile/melee/suicide); victory (tile.y≤GOAL_ROW=0) + timeout (30s) self-finalize. shell_hit_rate from player.run_recap hit accounting when present (Q1 wires it), else 0.0. build_record() -> validate -> JSON.stringify(dict,"  ") -> FileAccess write (make_dir_recursive_absolute first).
- BotInputDriver: +`last_action` field (set in apply_action) for the recorder.
- Red→green: smoke test used an inner StubPlayer; first run exposed a real bug-in-test (stub at world origin tripped the y≤0 victory instantly → 0 tallies). Fixed stub start pos to (80,232) ~ row 29. Then `RECORDER_OK`: schema-conforms + shells(AP=2,HE=1) + damage(2) + identity all OK; JSON write/read roundtrip verified.
- Makefile: `check-telemetry-recorder`.

**Verified / accepted**: `make check-telemetry-recorder` → `RECORDER_OK`. Impact guards: check-telemetry-schema, check-bot-driver, check-bots-base, test, check-hash-anchor all green.

**Status moves**: none (AC-002 already PASS_PENDING_FINAL from U4a; recorder's live correctness is AC-004's gate). U4 complete; unblocks U7.

**Next**: U5 seed bank — author data/seed_bank/seeds.json (12 seeds, 4 easy / 4 medium / 4 hard-or-bug), classify via test_runner reachability (seed 42 = 676 cells baseline), + check-seed-bank with tier-mutation teeth. Then U6 7 bots, U7 batch.

---

## iter 5 — 2026-05-28 — U5 seed bank 12 seeds 4/4/4 (AC-003)

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-003 | no seed bank | 12 seeds partitioned 4/4/4 by reachable_cells, re-validated against test_runner.gd | data/seed_bank/seeds.json + tools/check_seed_bank.py + Makefile | rm new files`

**Did**:
- Swept ~47 seeds via test_runner.gd to find clean extremes (reachable_cells ranged 256-904). Picked 4/4/4 with margin from the 500/800 boundaries: easy {1234,888,1111,1500} (836-904); medium {13,314,42,5} (608-724, 42 = hash-anchor baseline → correctly medium); hard {9,100,3000,21} (256-464).
- `data/seed_bank/seeds.json` — 12 entries {seed, tier, reason, expected_band, reachable_cells, bug_id}.
- `tools/check_seed_bank.py` — re-measures each seed against the canonical oracle (test_runner.gd), validates count(12) + partition(4/4/4) + declared-tier==measured-tier + declared-rc==measured-rc + playable. Tier formula: bug_id→hard; rc>800→easy; 500-800→medium; <500→hard. Also `--classify <seed>` mode (subsumes the architect's separate classify_seed.gd — tier formula kept in ONE place, DRY).
- Green: `SEED_BANK_OK 12/12`. Teeth: flipped seed 1234 easy→hard in a temp copy → `SEED_BANK_FAIL` exit 1 (tier + partition violations); real file → exit 0.
- Makefile: `check-seed-bank`.

**Verified / accepted**: `make check-seed-bank` → `SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)`. `make check-hash-anchor` still HASH_OK.

**Status moves**: AC-003 OPEN → PASS_PENDING_FINAL.

**Deviation**: architect listed tools/classify_seed.gd; implemented `--classify` in check_seed_bank.py instead (DRY — single tier formula). No separate GDScript.

**Next**: U6 — 7 bot policies under scripts/bots/ + .tres instances, copying Enemy.gd heuristic primitives (cardinal projection Enemy.gd:853, LOS dot Enemy.gd:480, _opposite/_perpendicular). check-bots -> BOTS_OK 7/7 (mutation teeth: a tick() returning null fails). Then U7 batch.

---

## iter 6 — 2026-05-28 — U6 seven bot policies (AC-001)

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-001 | no bot policies exist (only the base contract) | 7 pure-function policies + a registry, each returning a valid + behaviourally-correct action | scripts/bots/{BotHeuristics,BotRegistry,7 bots}.gd + verifier | rm new files`

**Did**:
- `scripts/bots/BotHeuristics.gd` — shared cardinal primitives (manhattan, cardinal_toward/away, aligned_dir, opposite, perpendicular_cardinal), the reusable form of Enemy.gd's inline projection/LOS.
- 7 policies: MoveToCover (hug nearest obstacle), DodgeShell (orthogonal to incoming projectile), ApproachEnemy (toward + fire when aligned & reloaded), FireWhenLinedUp (stationary turret), ReloadAwareWait (kite while reloading, fire only when ready — probes consult P2), PanicRandom (deterministic-hash flail below 25% HP — reproducible, not RNG), ObjectiveRush (rush UP, breach blocking obstacle).
- `scripts/bots/BotRegistry.gd` — bot_id->script map + `make()` (.new(), no .tres) + `ids()`/`has()`. make(unknown)->null (no silent skip, AC-007 precondition). Single source of truth for U7/U9.
- Red→green: `test_bots.gd` — generic validity (all 7 return valid BotAction) + 11 behavioural assertions. `BOTS_OK 7/7`. Teeth: injected `return null` into approach-enemy.tick -> `BOTS_FAIL 1 failures` exit 1 (caught), restored -> BOTS_OK.
- Makefile: `check-bots`.

**Bug found + fixed (in-test)**: the first teeth attempt HUNG headless — a null-returning tick is caught by the generic loop, but a later behavioural assertion then dereferenced the null action, aborting _initialize before quit() (SceneTree never exits). Fix: the verifier now bails (quit(1)) right after the generic validity loop if any bot is broken, so it can never reach the null-deref. (See SKILL-HARVEST SH-002.)

**Verified / accepted**: `make check-bots` -> `BOTS_OK 7/7`. All arc-5 checks (check-bots-base, check-bot-driver, check-telemetry-schema, check-telemetry-recorder, check-seed-bank) + `make test` + `check-hash-anchor` green.

**Status moves**: AC-001 OPEN -> PASS_PENDING_FINAL (own verifier check-bots green + teeth).

**Deviation**: architect listed per-bot .tres; used a code-driven BotRegistry (.new()) instead (Path B is code-driven; fewer files, no import fragility). Reversible.

**Next**: U7 batch runner (loop/eprime-experiment/bot_runner.gd, extends SceneTree) — load Q1ProofRoom 84× (7 bots × 12 seeds), attach BotInputDriver + TelemetryRecorder, run to death/victory/timeout, emit telemetry JSON each, clean state reset between (test_chain_35 queue_free+await pattern). check-84-runs -> RUNS_OK 84/84. Watch: Q1 stats.cfg write-on-death (user://) + 30s timeout cap + wall <5min.

---

## iter 7 — 2026-05-28 — U7 batch runner: 84 runs clean (AC-004)

**criterion-id | failing-evidence | hypothesis | edit-surface | rollback**
`AC-004 | no batch runner | a SceneTree runner loads Q1ProofRoom 84×, drives each bot×seed, emits conforming telemetry, no crash, <5min | loop/eprime-experiment/bot_runner.gd + recorder frame-timing fix + Makefile + .gitignore | rm runner, revert recorder`

**Did**:
- **Timing fix (decisive)**: headless physics is wall-synced by default → a 30s-game run would take 30 wall-sec → 84 runs ≈ 42min. Fix: run with `--fixed-fps 60` (decouples from wall clock, runs at CPU speed) AND switch the recorder's timeout/survival to FRAME-based game-time (`_elapsed_sec = _tick/60`). Result: 84 runs in ~14s wall.
- **Probe first**: a throwaway 1-run probe validated the whole pipeline (scene loads, player spawns, bot drives the tank via Input singleton — moved (16,232)→(35,132), enemies kill it, run_recap hit-accounting works hit_rate=1.0, telemetry schema-valid). Wall 116ms/run.
- `loop/eprime-experiment/bot_runner.gd` (extends SceneTree): CLI --bots/--seeds/--out; per combo seed(seed) → load Q1 → 4 frames → find PlayerTank → attach BotInputDriver(policy) + TelemetryRecorder(siblings) → step to recorder finalize (death/victory/timeout) → release_all → read rec._result → re-read JSON from disk + schema-validate → queue_free + 2 frames. RUNS_OK only if all 84 conform; unknown bot → RUNS_FAIL (no silent skip).
- **Bug found + fixed**: first batch reported "no telemetry emitted" for all 84 yet wrote 84 files — GDScript lambdas capture LOCALS by value, so `recorded.connect(func(t): captured=t)` no-ops the outer local (the probe worked only because its capture var was a MEMBER). Fix: recorder stores `_result`; runner reads `rec._result` directly. (SKILL-HARVEST candidate.)
- Makefile `check-84-runs` (single-run capture, expensive); `.gitignore` data/telemetry/*.json (generated).

**Verified / accepted**: `make check-84-runs` → `RUNS_OK 84/84 (timeout: 13, death: 69, victory: 2)` exit 0, 0 SCRIPT ERROR, ~14s, all 84 disk JSONs conform, deterministic across re-runs. `make check-hash-anchor` HASH_OK; `make test` green.

**Status moves**: AC-004 OPEN → PASS_PENDING_FINAL.

**Next**: U8 — Makefile `bot-harness` composite (final-verify): check-hash-anchor → check-bots-base → check-bots → check-bot-driver → check-telemetry-schema → check-telemetry-recorder → check-seed-bank → check-84-runs, emit `BOT_HARNESS_OK 84/84`. Then U9 orchestration (tools/bot_runner.sh + bot_summary.py + check-orchestration). Then run the final-verify → criteria-met.
