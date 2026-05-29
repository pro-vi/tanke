# E′ Experiment — Bot Harness Scaffolding (goal-archetype loop state)

```yaml
goal_version: bot-harness-v0.1
phase: ready-iter-1 (all preloop done; branch arc-5-bot-harness; scaffolding committed at 9426240; awaiting runner fire)
iter: 0
preloop_complete: yes
current_criterion: none (iter 1 will open U1 per blueprint implementation order)
stuck_counters: {AC-001: 0, AC-002: 0, AC-003: 0, AC-004: 0, AC-005: 0, AC-006: 0, AC-007: 0}
last_action: /architect emitted iter-0-architect.md; user committed all 4 files + pushed arc-5-bot-harness branch (9426240)
next_action: |
  Iter 1: open U1 from iter-0-architect.md (BotPolicy base class + Action +
  Observation types — 3 new files under scripts/bots/). Follow PROMPT.md
  § Iteration protocol 10-step ritual. Implementation order is:
  U1 → U2 → (U3 ‖ U4) → U5 → U6 → U7 → (U8 ‖ U9). Each U-ID maps to
  AC criteria per blueprint § Implementation Units.

  U2 is the ONE substrate touch — hash-anchor verification mandatory
  pre-commit; default-off gating template required.

  Final-verify: `make bot-harness` (emits `BOT_HARNESS_OK 84/84` on success).
  Halt with `criteria-met` when all 7 criteria PASS in single final-verify.
oracle_change_notes: []
```

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
