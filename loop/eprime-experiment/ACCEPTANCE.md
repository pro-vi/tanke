---
goal_version: bot-harness-v0.1
goal_fingerprint:
  inventory_hash: pending-first-frozen-snapshot
  authority_sources:
    - loop/breach/CONSULT-LEDGER.md (consult-001 §3 bot-playtester architecture)
    - .research-or-similar/refs/second-opinion-2026-05-25-loop-design.md (parent reframe)
    - /agentify Pro consult 2026-05-27 (queryId 939b4880-880a-42aa-aa22-5760f54a4830 — §3 bot-playtester, §8 wind-tunnel, Procgen seed-bank lesson)
  final_verify: make bot-harness
last_baseline_verify: pending
---

# ACCEPTANCE — bot-harness-v0.1

Frozen on emit. `status` and `last_verification` mutate; everything else is contract.

---

## AC-001 — 7 deterministic bot policies ship clean behavior

- id: AC-001
- statement: |
    Implement 7 deterministic bot policies as GDScript behavior trees or finite-state machines. NOT LLM-controlled per /agentify Pro 2026-05-27 §3 — "LLM operates BETWEEN runs, not inside the frame loop." Each bot is a script under `scripts/bots/` that exposes a single `tick(state) -> Action` method.
    Bots:
      1. move-to-cover (heuristic: nearest wall, hug perpendicular)
      2. dodge-shell (heuristic: orthogonal vector from incoming projectile)
      3. approach-enemy (heuristic: move toward closest, fire when aligned)
      4. fire-when-lined-up (heuristic: only fire when target in cardinal axis)
      5. reload-aware-wait (heuristic: don't fire if reload-bar < 80%)
      6. panic-random (heuristic: HP < 25% → random moves)
      7. objective-rush (heuristic: straight toward exit, fire only at blocking obstacles)
- source: /agentify Pro 2026-05-27 §8 wind-tunnel recommendation
- authority: consult-001 architecture (LLM-between-runs)
- verifier: make check-bots
- pass_evidence: |
    `make check-bots` exits 0 AND stdout contains `BOTS_OK 7/7`. Each bot's `tick()` returns a valid Action for at least one synthetic state input (mutation test confirms broken tick() fails the verifier).
- fail_evidence: |
    Less than 7 bot files exist OR any bot's tick() returns invalid Action on the synthetic test OR mutation (e.g. return null) doesn't trigger verifier fail.
- status: PASS_PENDING_FINAL
- depends_on: []
- reopen_condition: bot policy added/removed/renamed OR Action interface changes
- last_verification: |
    iter 6 (U6): `make check-bots` -> `BOTS_OK 7/7`. 7 policies ship under
    scripts/bots/ (move-to-cover, dodge-shell, approach-enemy, fire-when-lined-up,
    reload-aware-wait, panic-random, objective-rush), each extends BotPolicy with
    a pure deterministic tick() (panic-random "random" is a deterministic hash of
    the observation — reproducible). Each returns a valid BotAction + its defining
    behaviour on a triggering obs. Teeth: a tick() returning null -> BOTS_FAIL
    exit 1 (caught by the validity gate; verifier bails before behavioural asserts
    so it never hangs). Driven by BotRegistry (bot_id->script, .new()) — code-driven
    Path B, no .tres. Foundation: U1 (`check-bots-base` BOTS_BASE_OK) + U3
    (`check-bot-driver` BOT_DRIVER_OK). Live-in-Q1 behaviour is exercised by AC-004.

---

## AC-002 — Telemetry contract emits per-seed-per-bot JSON

- id: AC-002
- statement: |
    Define a stable JSON schema for telemetry, capture per-run telemetry into `data/telemetry/seed_NN_bot_X.json`, and verify schema conformance. Required fields:
      - survival_time_sec (float, ≥0)
      - damage_taken (int, ≥0)
      - shells_fired_per_class (object: {AP:int, HE:int, HEAT:int, APCR:int})
      - shell_hit_rate (float, [0,1])
      - reload_cancel_events (int, ≥0)
      - time_exposed_pct (float, [0,1])
      - death_cause (enum: "melee" | "projectile" | "suicide" | "timeout" | "victory")
      - ui_action_correlation (object: {reload_bar_state→action_delta, shell_chip_state→action_delta, ribbon_visible→action_delta} — proxy for consult-001 P2+P3 legibility predictions)
      - seed (int, the seed used)
      - bot_id (string, the bot policy name)
      - schema_version (string, e.g. "v0.1")
- source: consult-001 P2+P3 legibility predictions (CONSULT-LEDGER) + /agentify Pro 2026-05-27 §3 (telemetry contract)
- authority: consult-001 falsifiable predictions need bot-observable proxies
- verifier: make check-telemetry-schema
- pass_evidence: |
    `make check-telemetry-schema` exits 0 AND stdout contains `TELEMETRY_OK <N>/<N> files conform`. The check runs against a fixture telemetry JSON (oracle-independence: a hand-crafted INVALID fixture in `tests/fixtures/telemetry_bad.json` must fail the verifier first; a hand-crafted VALID fixture must pass).
- fail_evidence: |
    Schema validator missing OR fixture-bad passes OR fixture-good fails OR any required field missing from emitted JSON.
- status: PASS_PENDING_FINAL
- depends_on: []
- reopen_condition: schema changes (any field added/removed/renamed) OR new bot generates non-conforming JSON
- last_verification: |
    iter 3 (U4a): `make check-telemetry-schema` -> `TELEMETRY_OK 2/2 fixtures
    conform`. TelemetrySchema.validate() ACCEPTS tests/fixtures/telemetry_good.json
    and REJECTS telemetry_bad.json (8 violations) — oracle teeth proven (a
    rubber-stamp validator fails the bad-fixture case). Validator tolerates
    JSON int-as-float typing. The PRODUCER (TelemetryRecorder, U4b) is proven
    transitively by check-84-runs (AC-004): every one of the 84 emitted JSONs
    must validate against this same schema.

---

## AC-003 — Seed bank of 12 fixed seeds (4 easy / 4 medium / 4 historical-bug)

- id: AC-003
- statement: |
    Ship `data/seed_bank/seeds.json` (or equivalent) containing exactly 12 seed entries, partitioned 4/4/4:
      - 4 EASY (high reachability, low enemy density, generous shell economy — bot should consistently survive)
      - 4 MEDIUM (mid reachability, mid enemy density, tight shell budget — bot survival mixed)
      - 4 HARD-OR-HISTORICAL-BUG (low reachability OR previously-known regression seeds — these are the diversity floor per Procgen lesson)
    Each entry: {seed: int, tier: "easy"|"medium"|"hard-or-bug", reason: string, expected_band: string}.
- source: /agentify Pro 2026-05-27 §8 Procgen lesson — "preserve a seed bank: easy seeds, hard seeds, historical bug seeds, and fresh random seeds"
- authority: cross-pollination from Procgen / GVGAI literature
- verifier: make check-seed-bank
- pass_evidence: |
    `make check-seed-bank` exits 0 AND stdout contains `SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)`. Each seed is reachability-tested against `loop/test_runner.gd` and the actual tier-classification matches the declared tier (mutation test: declare an easy seed as "hard" → verifier fails).
- fail_evidence: |
    Wrong count (not 12), wrong partition (not 4/4/4), seed-not-reachable, OR declared tier doesn't match measured reachability.
- status: PASS_PENDING_FINAL
- depends_on: []
- reopen_condition: seed added/removed OR tier reclassified
- last_verification: |
    iter 5 (U5): `make check-seed-bank` -> `SEED_BANK_OK 12/12 (4 easy / 4 medium
    / 4 hard-or-bug)`. data/seed_bank/seeds.json: easy {1234,888,1111,1500} rc
    836-904; medium {13,314,42,5} rc 608-724 (42 = hash-anchor baseline); hard
    {9,100,3000,21} rc 256-464. Each re-measured against the canonical oracle
    test_runner.gd; declared tier + reachable_cells match measured. Teeth: a
    flipped tier (1234 easy->hard) -> SEED_BANK_FAIL exit 1 (tier + partition
    violations caught). NOTE: all 4 hard seeds are low-reachability (bug_id
    null) — no historical-regression seed is flagged yet; the formula admits
    bug_id-flagged seeds and the reopen_condition covers adding one later.

---

## AC-004 — All 7 bots × 12 seeds = 84 runs complete clean

- id: AC-004
- statement: |
    Headless Godot batch runs all 7 bot policies × 12 seeds = 84 separate runs. Each run loads `scenes/Q1ProofRoom.tscn`, drives the player via the bot's tick() output through `Input.parse_input_event` (per arc-3 L5 input synthesis pattern), runs until death/victory/timeout, and emits exactly one telemetry JSON conforming to AC-002 schema.
    No run crashes. No run silently fails. Timeout deaths are recorded (NOT crashes).
- source: consult-001 §3 bot-playtester architecture
- authority: consult §3 + arc-3 session-learnings L5 input-synthesis precedent
- verifier: make check-84-runs
- pass_evidence: |
    `make check-84-runs` exits 0 AND stdout contains `RUNS_OK 84/84 (timeout: <N>, death: <M>, victory: <K>; N+M+K=84)`. All 84 JSON files exist in `data/telemetry/` AND every one parses + conforms to schema. Total wall time <5 min.
- fail_evidence: |
    <84 JSON files, OR any JSON fails parse/schema, OR any run produced a Godot crash (stderr from Godot contains "SCRIPT ERROR" or "Process Killed"), OR total wall time >10 min.
- status: PASS_PENDING_FINAL
- depends_on: [AC-001, AC-002, AC-003]
- reopen_condition: bot count changes OR seed count changes OR scenario scene changes
- last_verification: |
    iter 7 (U7): `make check-84-runs` -> `RUNS_OK 84/84 (timeout: 13, death: 69,
    victory: 2; 13+69+2=84)`. loop/eprime-experiment/bot_runner.gd (extends
    SceneTree) loads scenes/Q1ProofRoom.tscn 84× (7 bots × 12 seeds), seeds the
    RNG per seed (deterministic enemy-fire stagger), attaches BotInputDriver +
    TelemetryRecorder as PlayerTank siblings, drives via Input.parse_input_event
    (NOT mocked — real headless integration), runs to death/victory/timeout,
    writes + re-reads-from-disk + schema-validates each telemetry JSON. 0 Godot
    SCRIPT ERROR; wall ~14s (<5min) via --fixed-fps 60 (frame-based game-time in
    the recorder, headless-stable). Death-cause spread (40 projectile/23 melee/6
    suicide/13 timeout/2 victory) = meaningful arm-loop signal. Deterministic:
    identical distribution on re-run. Generated JSONs gitignored (regenerable).

---

## AC-005 — Cross-arc hash anchor preserved bit-identical

- id: AC-005
- statement: |
    The procedural baseline hash anchor `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` (cross-arc invariant since arc 1 iter 0) MUST remain bit-identical on the flag-off codepath through every substrate write in this scaffolding. If any iter touches Layer 1-3 substrate, the verification runs immediately post-write and BLOCKS the commit if mismatch.
- source: arc-4 invariant (`hash_anchor_at_iter_*` in STATE.md), arc-3 PATTERN 1 (cross-arc invariant), 96 substrate writes preserved through arc-4
- authority: cross-arc invariant since arc 1 iter 0; non-negotiable
- verifier: make check-hash-anchor
- pass_evidence: |
    `make check-hash-anchor` exits 0 AND stdout contains exact line `HASH_OK 23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`. Verifier runs: `godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --json | grep '^{' | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print('HASH_OK '+d['tile_hash']) if d['tile_hash']=='23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291' else (print('HASH_BROKEN '+d['tile_hash']) or sys.exit(1))"`. Mutation test: temporarily editing a Layer-1 file to perturb the procedural output must trigger HASH_BROKEN.
- fail_evidence: |
    Hash mismatch on flag-off codepath, OR substrate file modified without default-on gating, OR verifier never ran post-substrate-write.
- status: PASS_PENDING_FINAL
- depends_on: []
- reopen_condition: any substrate write (Layer 1/2/3)
- last_verification: |
    iter 1: `make check-hash-anchor` -> HASH_OK
    23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291 (exit 0).
    Teeth proven oracle-independent: seed-99 -> HASH_BROKEN + exit 1; seed-42 ->
    HASH_OK + exit 0. The literal "edit a Layer-1 file" mutation was replaced by
    this seed-variation proof because Layer-1 files are FORBIDDEN edits (PROMPT
    scope manifest). Zero substrate writes this arc (Path B — see STATE AR-001),
    so the anchor is preserved by construction. Re-confirmed in final-verify.

---

## AC-006 — make test + make test-all + make bot-harness all green

- id: AC-006
- statement: |
    All three Makefile targets pass:
      - `make test` (existing — procedural mode smoke)
      - `make test-all` (existing — arc-3 regression guard, 5/5)
      - `make bot-harness` (NEW — composite: runs check-bots + check-telemetry-schema + check-seed-bank + check-84-runs + check-hash-anchor and emits `BOT_HARNESS_OK 84/84` on full success)
    `make bot-harness` IS the final-verify (proves AC-001+002+003+004+005 in the same repo state).
- source: arc-3 + arc-4 carries (make test-all green throughout) + this scaffolding's final-verify spec
- authority: consult §3 + repo Makefile conventions
- verifier: make bot-harness  # this IS the final-verify
- pass_evidence: |
    `make test` exits 0 AND `make test-all` exits 0 AND `make bot-harness` exits 0. `make bot-harness` stdout contains exact line `BOT_HARNESS_OK 84/84`. All 3 commands run in sequence from clean state without manual intervention.
- fail_evidence: |
    Any of the 3 commands exits non-zero, OR `make bot-harness` runs but `BOT_HARNESS_OK 84/84` not in stdout, OR any sub-check fails silently.
- status: PASS_PENDING_FINAL
- depends_on: [AC-001, AC-002, AC-003, AC-004, AC-005]
- reopen_condition: Makefile changes OR any underlying sub-target changes
- last_verification: |
    iter 8 (U8): `make bot-harness` composite wired — prereq chain (in order):
    check-hash-anchor -> check-bots-base -> check-bots -> check-bot-driver ->
    check-telemetry-schema -> check-telemetry-recorder -> check-seed-bank ->
    check-84-runs -> check-orchestration, then emits `BOT_HARNESS_OK 84/84`.
    Each sub-check green individually; full composite run is the final-verify
    (this iteration). AC-006 also requires `make test` + `make test-all` green.

---

## AC-007 — LLM-between-runs orchestration entry point exists

- id: AC-007
- statement: |
    Ship a thin orchestration script that an outer loop (whether /loop, /goal, shell, or a future E′ arm-loop) can invoke to: (a) run N bot×seed combos in batch (subset or all 84), (b) emit consolidated summary JSON aggregating telemetry, (c) exit cleanly so the outer loop can READ the summary and decide next iter. Entry: `tools/bot_runner.py` (or .gd/.sh equivalent) with CLI: `bot_runner --bots <list> --seeds <list> --out <path>`. NO LLM driving the tank — this is the scripted-bot orchestration layer the LLM uses BETWEEN runs.
- source: consult-001 §3 "LLM operates BETWEEN runs, not inside the frame loop" + the explicit need for an outer-loop hook point
- authority: consult §3 architectural division of labor
- verifier: make check-orchestration
- pass_evidence: |
    `make check-orchestration` exits 0 AND stdout contains `ORCHESTRATION_OK`. Test invocation: `tools/bot_runner --bots move-to-cover,panic-random --seeds 1,7 --out /tmp/bot_summary.json` produces a parseable summary JSON with 4 run entries. Mutation test: invoking with `--bots <nonexistent>` must fail with a clear error (not a silent skip).
- fail_evidence: |
    Entry point doesn't exist, CLI args don't work, summary JSON malformed/missing, nonexistent bot silently skipped.
- status: PASS_PENDING_FINAL
- depends_on: [AC-001, AC-002, AC-003, AC-004]
- reopen_condition: orchestration CLI surface changes OR summary JSON schema changes
- last_verification: |
    iter 8 (U9): `make check-orchestration` -> `ORCHESTRATION_OK`.
    tools/bot_runner.sh --bots move-to-cover,panic-random --seeds 1,7 --out
    <summary.json> produces a parseable summary JSON with exactly 4 run entries
    (via tools/bot_summary.py aggregating per-bot/per-seed/death-cause). Teeth:
    --bots no-such-bot exits non-zero with NO summary written (no silent skip).
    NO LLM drives the tank — scripted-bot batch layer the LLM uses BETWEEN runs.
