# Breach loop ledger (arc 4)

Append-only. One entry per iter. Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [STRUCTURE] / [FEEL] / [MIXED] / [STRUCTURE-DEFERRED] / [IDENTITY-PROTECTED] / [QUALITY]
- Score: NN/MM effective · NN/50 absolute   (Δ vs prior: ±N)
- Constraints respected: <list of CONSULT §9 constraints>
- Constraints risked: <list, if any>
- Hash anchor: 23d6a2ec… verified | broken | n/a (no substrate touch)
- Falsifications: F0NN added | none
- Files: <touched paths>
- Finding: <one-sentence>
```

---

## iter 002 — BUILD — DECISION (adopt path A) + first substrate hook on ProceduralLevel.gd

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **1/50 absolute · 1/50 effective** (Δ +1 vs prior — C10 anchor 1)
  - C10 (Substrate preservation): 0 → 1 (anchor 1: hash anchor verified
    iter 0 + preserved through ≥3 iters of arc-4 work — iters 0/1/2 with
    iter 2 being the first substrate-touching write)
  - All other 9 criteria still at 0 (no feature surface yet)
- Constraints respected: all 7 (substrate plumbing; flag-off codepath
  bit-identical to arc-2 baseline)
- Constraints risked: none this iter
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED bit-identical post-edit**
  (procedural oracle on seed 42 / default config). `make test` exit 0.
  `make test-all` PASS on all five arc-3 targets (ALL_LOADER_TESTS_PASS,
  CHAIN_25_OK, CHAIN_35_OK, ARC_COMPLETE_OVERLAY_OK, TITLESCREEN_NAV_OK).
- Falsifications: none
- Files: `scripts/ProceduralLevel.gd` (substrate write #1; sanctioned per
  PROMPT §SUBSTRATE FREEZE iter-1 path A + §DEFAULT-ON SUBSTRATE GATING
  TEMPLATE), `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Path A landed cleanly.** Added two `@export` vars
  (`breach_mode_enabled: bool = false`, `breach_config: Resource = null`)
  + two conditional branches after the RNG-touching baseline (after
  `force_update_scroll()` in `_ready`; after row-generation block in
  `_process`) + two stub methods at file tail. Flag-off codepath produces
  bit-identical tile_hash on seed 42. The pre-mortem's `[QUALITY]` hedge
  was conservatively pessimistic — C10's substrate-preservation anchor
  did lift on this iter, so the iter is honestly BUILD not BUILD-QUALITY.
  Next iter: BreachConfig.gd + `breach_config: BreachConfig` typed +
  first depth-band stub (lifts C4 anchor 1).

## iter 001 — SPIKE — mode-integration path A vs B

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: 0/50 (Δ 0 vs prior — SPIKE iters are investigation, not anchor lift)
- Constraints respected: all 7 (read-only investigation; no design surface touched)
- Constraints risked: none
- Hash anchor: n/a (no substrate touch; verification deferred to iter 2 BUILD)
- Falsifications: none
- Files: `loop/breach/iter-001-spike-report.md` (blueprint stash per L2),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`
- Finding: **Path A SHIP (default-on `breach_mode_enabled` flag on
  `ProceduralLevel.gd`). Path B REFINE (do not adopt as default).** Two
  parallel scouts converged independently. Load-bearing argument is
  hash-anchor bit-identicality: `ProceduralLevel.gd:42-77` (RNG-touching
  baseline) precedes any flag branch, so `tile_hash=23d6a2ec3bf2821f` is
  preserved when `breach_mode_enabled=false`. Path B's only saving is
  one default-off boolean; H1 surface burden + ProceduralStep row-regen
  fork risk make it strictly worse. Effort estimate: ~5-7 BUILD iters
  from flag-added to first end-to-end breach run.

## iter 000 — META — preloop complete + substrate verified

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: 0/50 (baseline; rubric exists, no work scored yet)
- Constraints respected: n/a (no design work this iter)
- Constraints risked: n/a
- Hash anchor: `23d6a2ec3bf2821f…` verified on seed 42 / default procedural config
- Falsifications: none
- Files: `loop/breach/STATE.md`, `loop/breach/LEDGER.md`, `loop/breach/PRE-MORTEMS.md`, `loop/breach/REVIEW-QUEUE.md`, `loop/breach/FALSIFICATIONS.md`, `loop/breach/creative-consults.md` (scaffolded)
- Finding: All three substrate layers green. `make test` exit 0. Procedural
  oracle on seed 42 reports `tile_hash=23d6a2ec3bf2821f`, `reachable=676`,
  `playable=true`. OG `check-loader` + `check-chain` (25 stages) pass.
  Preloop reads (arc-1/2/3 retros + cross-arc lessons L1-L6/R1-R4 + arc-4
  CONSULT) complete. `preloop_complete: yes`. Next iter: SPIKE on
  mode-integration path A (default-on `breach_mode_enabled` flag on
  `ProceduralLevel.tscn`) vs path B (sibling `BreachLevel.tscn`), per
  PROMPT first-iter note + L1 (spike-before-build).
