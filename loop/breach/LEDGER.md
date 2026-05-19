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
