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
