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

## iter 005 — BUILD — Depot.gd + Depot.tscn + pause-on-entry (C2 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **7/50 absolute · 7/50 effective** (Δ +3 vs prior — C2 anchor 1, C9 anchor 1, C10 anchor 3)
  - C2 (Field depot system): 0 → 1 (anchor 1: Depot.gd + Depot.tscn
    exist; combat pauses on entry — code-cited via `make
    check-breach-depot` reporting `BREACH_DEPOT_OK pause-on-entry
    contract verified`)
  - C9 (Identity / breach-roguelite singularity): 0 → 1 (anchor 1: ≥1
    mechanic with no analog in arc 2 — code-cited via three: shell-class
    schema (iter 4), depot pause-on-entry (this iter), depth-band
    structure (iter 3). Conservatively held this anchor until depots
    landed to consolidate the cite; arc-2 had no depot, no shell-class,
    no band structure)
  - C10 (Substrate preservation): 2 → 3 (anchor 3: arc-2 procedural mode
    plays identically when `breach_mode_enabled = false` — harness
    check: tile_hash 23d6a2ec3bf2821f bit-identical through all 4
    substrate writes; `make test` 120-frame runtime green at every
    iter)
  - C3=1, C4=1 unchanged; others still 0
- Constraints respected: 1 (no upgrade choices during active combat —
  depot's pause-on-entry IS the load-bearing protector of constraint 1;
  the schema *forces* upgrade flow to live at safe gates), 6 (depot is
  a natural segmentation point for death recap + pre/post-band metrics)
- Constraints risked: 1's flip-side — depot dwell must stay <30s; rubric
  anti-pattern names "depot dwell >30s OR depot UI requires reading
  during pursuit by enemies = automatic 0 on C2". This iter doesn't
  yet implement upgrade flow so dwell is unbounded by design (just
  walk in/out). Iter 6+ adds the choice + the 30s budget; honest gap.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no substrate
  touched). `make test` exit 0. `make test-all` PASS. `make
  check-breach-config` PASS. `make check-breach-shells` PASS. `make
  check-breach-depot` PASS (NEW).
- Falsifications: minor — predicted SceneTree subclass timing issue in
  the depot harness; confirmed (needed `_initialize()` + `await
  process_frame` per arc-3 `loop/test_chain_25.gd` precedent rather
  than `_init()`). Not codified — single-session lesson; pattern lives
  in arc-3's PROMPT v3 candidate pattern 5 already.
- Files: `scripts/Depot.gd` (NEW), `scenes/Depot.tscn` (NEW),
  `loop/breach/test_breach_depot.gd` (NEW verifier), `Makefile` (new
  `check-breach-depot` target), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **Depot pause-on-entry contract landed.** Depot.gd is an
  Area2D with `process_mode = PROCESS_MODE_ALWAYS` (so `body_exited`
  can fire while tree is paused). `_on_body_entered` filters to player
  via group tag (`player` group) or duck-type fallback
  (`_on_PlayerTank_shoot` method) — does NOT pause for enemies passing
  through the depot zone. Combat-pause is the structural protection of
  CONSULT constraint 1 (no upgrade choices during active combat). Iter
  6+ adds the upgrade-choice UI + the 30s dwell budget. **Next iter
  candidates**: (a) C4 anchor 2 trivial lift (add band 3 to .tres),
  (b) C5/C6/C8 schema scaffolding (Loadout / RunRecap / first upgrade
  with sentence-test cite), (c) iter-5 round-close + CONSULT.

## iter 004 — BUILD — Bullet.gd shell_class flag + AP/HE/HEAT constants

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **4/50 absolute · 4/50 effective** (Δ +2 vs prior — C3 anchor 1, C10 anchor 2)
  - C3 (Ammo as logistics): 0 → 1 (anchor 1: 3 shell types in code,
    player can fire any via @export or start() override — code-cited via
    `make check-breach-shells` reporting `BREACH_SHELLS_OK 3 distinct
    shell classes, default = AP`)
  - C10 (Substrate preservation): 1 → 2 (anchor 2: same + `make test-all`
    passes through all substrate-touching iters — iters 2, 3, 4 all
    green on 5 arc-3 targets after substrate edits)
  - C4 still at 1; others still at 0
- Constraints respected: 2 (exactly 3 primary shell classes — AP/HE/HEAT,
  no more), 1 (no combat modal — flag is data-only), 7 (verbs not stats
  — shell class routes to terrain/behavior affordances in later iters,
  not to +damage% upgrades), 4 (silhouette grammar — Bullet sprite gets
  modulate-only diff per shell; full silhouette work deferred to gen_tile
  pipeline)
- Constraints risked: 3 (every enemy must have readable shell/positioning
  relationship) — shell_class field exists but per-class **behavior**
  not yet wired (HE→terrain, HEAT→armor). Iter 5+ implements; honest
  scaffolding gap documented + scheduled per the iter-5 plan.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #3 (Bullet.gd). `make test` exit 0. `make test-all` PASS (all 5
  arc-3 targets). `make check-breach-config` PASS. `make
  check-breach-shells` PASS (NEW).
- Falsifications: none
- Files: `scripts/Bullet.gd` (substrate write #3 — sanctioned per PROMPT
  §SUBSTRATE FREEZE; chose extend-vs-new-Shell.gd per Scout A's spike),
  `loop/breach/test_breach_shells.gd` (NEW verifier), `Makefile` (new
  `check-breach-shells` target), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **Bullet.gd shell-class schema landed.** 3 constants
  (SHELL_CLASS_AP=0, _HE=1, _HEAT=2) + `@export var shell_class: int =
  SHELL_CLASS_AP` + `start()` extended with optional `shell: int = -1`
  override param + visual modulate hint per non-AP class. Arc-2 baseline
  bullet fires AP identically (no override); hash anchor preserved.
  Per-shell-class **behavior** (HE terrain-cracking, HEAT armor-bypass)
  is iter 5+ work. Next iter: scripts/Depot.gd + scenes/Depot.tscn (C2
  anchor 1).

## iter 003 — BUILD — BreachConfig + BreachBand + breach_default.tres (2 bands)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **2/50 absolute · 2/50 effective** (Δ +1 vs prior — C4 anchor 1)
  - C4 (Depth bands): 0 → 1 (anchor 1: BreachConfig.gd encodes ≥2
    distinct bands with different terrain weights — code-cited via
    `make check-breach-config` reporting `BREACH_CONFIG_OK 2 bands,
    distinct terrain weights`)
  - C10 (Substrate preservation): still 1 (hash anchor preserved through
    iter 3's substrate write #2 — type tightening on `breach_config`
    @export)
  - All other 8 criteria still at 0
- Constraints respected: 4 (silhouette grammar — BreachBand schema
  constrains bands to declared terrain rosters, can't invent mechanics),
  5 (each band has a dominant terrain pressure — `dominant_pressure`
  field), 7 (verbs not stats — BreachBand has no damage/stat fields, only
  terrain + canonical-answer descriptors). Others n/a (no shell, no
  depot, no enemy this iter).
- Constraints risked: 5 if future bands ship without filled
  `dominant_pressure` (schema-defended; runtime check possible)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #2. `make test` exit 0. `make test-all` PASS (all 5 arc-3
  targets). `make check-breach-config` PASS (new arc-4 target).
- Falsifications: none. Pre-mortem prediction "typed-Array .tres syntax
  may have a quirk" — confirmed quirk-free (`Array[Resource]([...])`
  works). Pre-mortem prediction "preload may be needed for cross-script
  type refs" — confirmed: 3 files needed preload+alias pattern
  (BreachBand.gd preloads LevelConfig; BreachConfig.gd preloads
  BreachBand; ProceduralLevel.gd preloads BreachConfig). Same pattern
  as arc-1 LevelConfigT precedent.
- Files: `scripts/BreachBand.gd` (NEW), `scripts/BreachConfig.gd` (NEW),
  `configs/breach_default.tres` (NEW), `scripts/ProceduralLevel.gd`
  (substrate write #2 — tightened @export type), `Makefile` (new
  `check-breach-config` target), `loop/breach/test_breach_config.gd`
  (NEW verifier), `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **BreachConfig schema landed.** Two-band sample
  (tutorial_choke @ depth 0-30 / brick_maze @ depth 30-70) with distinct
  LevelConfig sub-resources per band (brick_weight 0.55 vs 0.70,
  water_weight 0.10 vs 0.05). Schema directly mirrors BANDS.md roadmap.
  C4 anchor 1 cited via the new harness target. Depth-band runtime
  tracking (looking up the active BreachBand in `_process_breach_depth`)
  is still a stub — iter 4 or 5 will wire that. Next iter: shells.

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
