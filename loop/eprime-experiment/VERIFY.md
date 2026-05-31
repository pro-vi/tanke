# VERIFY — bot-harness-v0.1 final-verify transcript

**Halt cause: `criteria-met`.** All 7 acceptance criteria reached `PASS` in a
single `make bot-harness` invocation (same repo state as `make test` +
`make test-all`), on branch `arc-5-bot-harness`, 2026-05-28.

## Final-verify trinity (one repo state, wall ~33s)

| Command | Result |
|---|---|
| `make test` | exit 0 (procedural-mode smoke; no SCRIPT ERROR) |
| `make test-all` | 5/5 — ALL_LOADER_TESTS_PASS, CHAIN_25_OK, CHAIN_35_OK, ARC_COMPLETE_OVERLAY_OK, TITLESCREEN_NAV_OK (arc-3 regression intact) |
| `make bot-harness` | **BOT_HARNESS_OK 84/84** |

## `make bot-harness` sub-check matrix (in execution order)

| Order | Sub-check | Sentinel | Criterion |
|---|---|---|---|
| 1 | check-hash-anchor | `HASH_OK 23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` | AC-005 |
| 2 | check-bots-base | `BOTS_BASE_OK` | AC-001 (foundation) |
| 3 | check-bots | `BOTS_OK 7/7` | AC-001 |
| 4 | check-bot-driver | `BOT_DRIVER_OK` | AC-001 (driver) |
| 5 | check-telemetry-schema | `TELEMETRY_OK 2/2 fixtures conform` | AC-002 |
| 6 | check-telemetry-recorder | `RECORDER_OK` | AC-002 (producer) |
| 7 | check-seed-bank | `SEED_BANK_OK 12/12 (4 easy / 4 medium / 4 hard-or-bug)` | AC-003 |
| 8 | check-84-runs | `RUNS_OK 84/84 (timeout: 13, death: 69, victory: 2; 13+69+2=84)` | AC-004 |
| 9 | check-orchestration | `ORCHESTRATION_OK` | AC-007 |
| — | composite | `BOT_HARNESS_OK 84/84` | AC-006 |

## Criterion status matrix

| ID | Statement (short) | Verifier | Status |
|---|---|---|---|
| AC-001 | 7 deterministic bot policies | `make check-bots` → BOTS_OK 7/7 | **PASS** |
| AC-002 | per-seed-per-bot telemetry JSON + schema | `make check-telemetry-schema` → TELEMETRY_OK 2/2 | **PASS** |
| AC-003 | seed bank 12 seeds (4/4/4) | `make check-seed-bank` → SEED_BANK_OK 12/12 | **PASS** |
| AC-004 | 7×12 = 84 runs complete clean | `make check-84-runs` → RUNS_OK 84/84 | **PASS** |
| AC-005 | cross-arc hash anchor preserved | `make check-hash-anchor` → HASH_OK | **PASS** |
| AC-006 | test + test-all + bot-harness all green | `make bot-harness` → BOT_HARNESS_OK 84/84 | **PASS** |
| AC-007 | LLM-between-runs orchestration entry point | `make check-orchestration` → ORCHESTRATION_OK | **PASS** |

## Oracle independence (teeth proven during the run)

- AC-005: seed-99 → `HASH_BROKEN` + exit 1; seed-42 → HASH_OK (verifier responds to changed procedural output, no forbidden-substrate edit).
- AC-001: a bot `tick()` mutated to `return null` → `BOTS_FAIL` exit 1 (caught).
- AC-002: `telemetry_bad.json` (8 violations) → REJECTED by the validator first.
- AC-003: a flipped declared tier → `SEED_BANK_FAIL` exit 1.
- AC-007: an unknown bot id → non-zero exit, NO summary written (no silent skip).

## Architecture note (AR-001)

Zero substrate touch. PlayerTank.gd (and all Layer 1–3 files) were NOT modified;
the bot-input hook lives entirely in sibling helpers (`BotInputDriver`) driving
PlayerTank through the Godot Input singleton (`Input.parse_input_event`). The
procedural hash anchor is therefore preserved by construction, not just by gating.

## Consumer-side oracle

If `make bot-harness` passes, a downstream E′ arm-loop has a working bot harness:
7 scripted policies, a stable telemetry contract (validated), a classified
12-seed bank, an 84-run headless batch producing conforming per-run JSON, and a
`tools/bot_runner.sh --bots --seeds --out` entry point emitting a consolidated
summary JSON — with the cross-arc hash anchor intact. No inference required.

## Scope honesty

- All 4 hard-or-bug seeds are low-reachability (`bug_id: null`); no historical-
  regression seed is flagged yet (none known). The tier formula admits bug-flagged
  seeds and AC-003's reopen_condition covers adding one later.
- `ui_action_correlation`, `time_exposed_pct`, and `shell_hit_rate` are honest
  observable proxies (schema-validated for type/range; values are best-effort,
  not oracle-verified for "correctness" — that is not machine-decidable).
- The 84-run host is the fixed Q1ProofRoom layout; the per-seed variation comes
  from seeding the RNG (deterministic enemy-fire stagger), not layout changes.
  The seed bank's reachability tiers are procedural-level metadata (a reusable
  asset), not Q1 difficulty.
