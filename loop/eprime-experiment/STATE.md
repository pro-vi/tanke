# E′ Experiment — Bot Harness Scaffolding (goal-archetype loop state)

```yaml
goal_version: bot-harness-v0.1
phase: iter-5-done (U1+U3+U4+U5 shipped; AC-002 + AC-003 + AC-005 PASS_PENDING_FINAL)
iter: 5
preloop_complete: yes
current_criterion: AC-001 (U6 7 bot policies next) — then U7 batch (AC-004), U8 composite (AC-006), U9 orch (AC-007)
stuck_counters: {AC-001: 0, AC-002: 0, AC-003: 0, AC-004: 0, AC-005: 0, AC-006: 0, AC-007: 0}
last_action: |
  Iter 1 shipped U1 (the AC-001 contract foundation) — 3 new type files
  scripts/bots/{BotPolicy,BotAction,BotObservation}.gd + verifier
  loop/eprime-experiment/test_bots_base.gd + Makefile targets check-bots-base
  and check-hash-anchor. Red->green proven (verifier parse-failed before the
  types existed). AC-005 verifier green (HASH_OK) AND teeth-proven (seed-99 ->
  HASH_BROKEN + exit 1; seed-42 -> HASH_OK + exit 0) WITHOUT touching forbidden
  substrate. Retired the harness' biggest risk: synthetic parse_input_event
  (both keycode + physical_keycode set) drives is_action_pressed("ui_up"/
  "ui_accept") AND is_physical_key_pressed(KEY_TAB) headless — Path B (zero
  substrate touch) confirmed viable. `make test` still green (no arc regression).
next_action: |
  U3 (BotInputDriver, scripts/bots/BotInputDriver.gd): translate BotAction ->
  InputEventKey via Input.parse_input_event. Set BOTH .keycode AND
  .physical_keycode on every event (proven needed for ui_* + physical TAB).
  PAIR every press with a release (held keys persist otherwise). Map:
  Dir.U->KEY_UP, Dir.D->KEY_DOWN, Dir.L->KEY_LEFT, Dir.R->KEY_RIGHT,
  fire->KEY_SPACE (ui_accept), shell_swap->KEY_TAB (only when target != current).
  await >=2 process_frame after parse for the action to register.

  Then (any order, all AC-001/002/003 independent):
    U4 TelemetryRecorder + TelemetrySchema + good/bad fixtures (AC-002) —
      RunRecap is NOT a file-writer; find real FileAccess/JSON.stringify
      precedent (grep scripts/ for FileAccess.open). death_cause: classify
      by nearest threat at death (projectile/melee/suicide) + timeout(30s) +
      victory(player reaches GOAL_ROW=0). shell_hit_rate via best-effort
      observable proxy. Q1 has NO victory mechanism — runner computes it.
    U5 seed bank 12 seeds 4/4/4 (AC-003) — classify via test_runner reachability
      (seed 42 = 676 reachable_cells observed; baseline).
    U6 7 bot policies (AC-001) — copy Enemy.gd heuristic primitives
      (cardinal projection Enemy.gd:853, LOS dot Enemy.gd:480, _opposite/
      _perpendicular). Then check-bots -> BOTS_OK 7/7.
  Then U7 batch (AC-004), U8 Makefile composite (AC-006), U9 orchestration (AC-007).

  IMPORTANT repo gotcha: after creating any new class_name .gd file, run
  `godot --headless --path . --import` once to register it in
  .godot/global_script_class_cache.cfg, else --script runs parse-fail with
  "Identifier X not declared". (See SKILL-HARVEST.)

  Final-verify: `make bot-harness` (emits `BOT_HARNESS_OK 84/84`). Halt with
  `criteria-met` when all 7 criteria PASS in a single final-verify.
oracle_change_notes: []
```

## Alignment Review — AR-001 (iter 1): substrate touch eliminated (Path B)

- **problem**: The blueprint's U2 specifies adding `@export var bot_controlled`
  + `bot_policy` to `scripts/PlayerTank.gd` as "the ONE substrate touch,"
  gated + hash-verified.
- **context**: (a) The PROMPT scope manifest permits the PlayerTank touch
  "only if a bot-input hook is needed AND it cannot live in a new scripts/bots/
  helper." (b) Iter-1 probe proved `Input.parse_input_event` drives all
  PlayerTank input paths headless — so a sibling BotInputDriver can drive the
  tank with ZERO PlayerTank change. (c) The entire arc-4 Q1 feature was built
  this way: `Q1ProofRoomScene.gd:20` header states "no Layer 1/2/3 substrate
  touch." The hook CAN live in a helper → the necessity test fails → the touch
  is not permitted.
- **options considered**: (A) blueprint-faithful — add the 2 exports, hash-verify;
  (B) zero substrate touch — BotInputDriver holds the policy (set by the runner),
  finds the PlayerTank sibling, builds observations from its readable fields,
  synthesizes input via Input.parse_input_event.
- **chosen contract**: Option B. The governing PROMPT scope manifest overrides
  the subordinate blueprint when they conflict. AC-005 stays meaningful: proven
  green + teeth (seed-variation) without any substrate write.
- **alignment cost**: Diverges from the blueprint's stated U2 design; AC-005's
  literal "edit a Layer-1 file" mutation test is replaced by the safe
  seed-variation teeth proof (Layer-1 files are FORBIDDEN edits).
- **rollback trigger**: If a later unit genuinely needs an in-tank seam that
  cannot be synthesized through the Input singleton (none found so far), revert
  to Option A with the default-off gating + hash verification per blueprint.
- **review question for human**: Confirm zero-substrate-touch is preferred over
  the blueprint's inspector-assignable `@export bot_policy` ergonomics. (The
  exports are additive later if desired.)

## Provenance

Composed by `/loopgen` 2026-05-28, pure goal archetype, no divergences. See PROMPT.md header preamble for full provenance.

## Frontload audit results

| Item | Status | Resolution |
|---|---|---|
| Motive | Resolved | Ship bot-harness scaffolding for E′ experiment |
| Acceptance inventory | Resolved | 7 criteria in ACCEPTANCE.md, all OPEN |
| Cheap channel | Resolved | `make test` |
| Final-verify | Resolved | `make bot-harness` (NEW Makefile target — part of AC-006) |
| Scope manifest | Resolved | See PROMPT.md § Scope manifest (allowed / substrate-touching / forbidden) |
| Forbidden shortcuts | Resolved | No C#, no MLX-SD, no LLM-in-frame-loop, no `--no-verify`, no mocked Godot |
| Stuck-attempt-N | Defaulted | 3 (standard) |
| Consult capability | Resolved | tier-2 (`mcp__agentify-desktop__*` available; PAL not in env) |
| Authority sources | Resolved | /agentify Pro 2026-05-27 consult (queryId 939b4880-880a-42aa-aa22-5760f54a4830) + consult-001 in `loop/breach/CONSULT-LEDGER.md` + arc-3 session-learnings L5 input-synthesis pattern |
| Artifact locations | Resolved | `loop/eprime-experiment/*` + `data/telemetry/*` + `data/seed_bank/*` + `scripts/bots/*` + `scenes/BotHarness*.tscn` + `tools/bot_runner.*` |
| Open gaps | none | — |

## Dependency topology (from ACCEPTANCE.md)

```
AC-001 (bot policies)     ┐
AC-002 (telemetry schema) ├─→ AC-004 (84 runs clean) ─→ AC-006 (make bot-harness green) ─→ AC-007 (orchestration entry)
AC-003 (seed bank)        ┘                          ↑
                                                     │
AC-005 (hash anchor preserved) ──────────────────────┘  (cross-cutting; gates every substrate touch)
```

Selection order for first iter: AC-001, AC-002, AC-003 (all independent, no dependencies). Suggest AC-003 first (smallest scope: just 12 JSON entries + reachability test) to validate the verification mechanism before larger criteria.

## Halt-cause history

(none yet — iter 0)

## Skill harvest

(none yet — see PROMPT.md § Skill Harvest format)

## Arc-4 operational continuity (inherited disciplines, NOT primitive divergences)

These carry from `loop/breach/PROMPT.md` lineage as operational disciplines — they're not architectural divergences from the goal archetype (which has its own oracle discipline). Listed here for context:

- **Hash-anchor cross-arc invariant** (arc-1 PATTERN 1) — enforced via AC-005 (made a first-class criterion in this loop)
- **Default-on substrate gating template** (arc-2 PATTERN 2 + arc-4 carry) — required for any substrate touch
- **Visual-verification discipline** (arc-4 iter 301) — N/A for this scaffolding (bot harness produces JSON, not visual artifacts; if a screenshot becomes part of telemetry, this discipline activates)
- **Same-family admissibility** (arc-4 iter 273) — less critical here because goal-archetype's criteria-completion gate prevents the no-signal-family drift it was designed to catch; OK to leave dormant unless the loop starts cycling without progress
- **Adversarial-consult discipline** (arc-4 iter 273) — N/A for this scaffolding (no [FEEL] anchors; pure [STRUCTURE])
- **Sentence test for upgrades** — N/A (no upgrades; this is instrumentation)

## Read-on-first-iter (MANDATORY before any code change)

1. This file (`STATE.md`) — orientation + next_action
2. `loop/eprime-experiment/PROMPT.md` — the protocol (10-step iteration ritual + oracle discipline + halt classifier)
3. `loop/eprime-experiment/ACCEPTANCE.md` — the 7 frozen criteria with verifiers + pass_evidence + fail_evidence
4. `loop/eprime-experiment/iter-0-architect.md` — Deep blueprint with 9 implementation units (U1..U9), 9 decisive architectural choices, substrate-touch checklist, bug-trace cross-check, risks
5. `/Users/provi/Development/_projs/tanke/loop/originals/iter027-meta-arc3-ceiling.md` — arc-3 PATTERN 5 (input-synthesis via `Input.parse_input_event`) — precedent for U2 + U3 implementation
6. `loop/breach/CONSULT-LEDGER.md` — consult-001 §3 bot-playtester architecture rationale + P2+P3 predictions the harness measures structurally
