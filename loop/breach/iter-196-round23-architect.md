# Round 23 Architect — class-specific 3-choice upgrade cards

**Iter 196 META, written 2026-05-24 per PROMPT §COMPACTION DISCIPLINE.**

User directive (iter 195): "as game goes on i want to see class
specific 3 choices upgrade to choose from. so yeah, an upgrade system."

## Current state

Two upgrade surfaces exist:

1. **Depot upgrades** (Depot.gd): 3 hardcoded choices per .tres OR
   3 randomized draws from `_upgrade_pool()`. Already
   archetype-aware via the iter-97 P2-6 fix (filters out
   same-archetype `SWITCH_TO_*` entries). The 12 entries in
   `UpgradeKind` are universal/shell-economy ones (HE/HEAT refill,
   FULL_RESUPPLY, OVERDRIVE, etc.) + archetype switches + 2 anchors
   (SCOUT_TELEGRAPH, REAR_GUARD).

2. **Level-up boosts** (PlayerTank.gd `_apply_level_boost`): AUTOMATIC
   3-cycle (HP / FASTER_RELOAD / SHELL_CAP). NOT a pick-1-of-3 card.

The user wants **pick-1-of-3 CARDS at level-up time, class-specific
to the current archetype.** This is a substantive new surface.

## Round 23 goal

Replace the automatic 3-cycle level-up with a pick-1-of-3 class-
specific upgrade card screen. Pool of upgrades is filtered by current
archetype. Each card has a 1-line label + a 1-line "sentence test"
description.

## Phases (iters 197-201)

### Phase 1 — iter 197 BUILD — data model + pool design

- New file: `scripts/UpgradeCatalog.gd` (arc-4-owned; pure-data
  module, no scene). Holds:
    - `UpgradeKind` enum extending Depot's (or a NEW separate
      enum dedicated to level-up cards — call it `CardKind`).
    - Per-archetype pool dicts: `PRISM_POOL`, `MORTAR_POOL`,
      `RAM_POOL`, `DEFAULT_POOL` — each a List[CardKind].
    - Card metadata: label, sentence, apply-fn ref.
- DRAFT CARD POOLS (subject to playtest):
    - **DEFAULT**: HP+1, FASTER_RELOAD, SHELL_CAP+1, +1 AP REGEN,
      LUCKY_DEPOT (rerolls), MOMENTUM (move-speed +20%)
    - **PRISM**: BEAM_DPS_UP (BEAM_DAMAGE_COOLDOWN ×0.7),
      BEAM_RANGE_UP (×1.5), BEAM_PIERCE (no first-body stop),
      BEAM_THICKNESS_UP (wider hitbox), HP+1, FASTER_BEAM_REV
      (no startup), KILL_HEAL (kills restore 1 hp)
    - **MORTAR**: AOE_DAMAGE +1, AOE_RADIUS +6, MORTAR_COOLDOWN ×0.7,
      MORTAR_MAX_RANGE +48, CHARGE_TIME ×0.7, SPLIT_LOB (2 shells
      at angle), HP+1
    - **RAM**: SWING_DAMAGE +1, SWING_RANGE +4, COLLISION_DAMAGE +1,
      MAX_HP +2 (the tank), SPRINT_DURATION +0.5, ARMOR_REDUCTION
      (incoming -1)

### Phase 2 — iter 198 BUILD — pick-1-of-3 card UI

- Reuse the iter-68 `_build_archetype_panel` / `_pick_archetype`
  pattern verbatim (it already pauses tree, shows panel, handles
  KEY_1/2/3 input, exits cleanly).
- New helpers: `_show_levelup_pick(level)` / `_build_levelup_panel`
  / `_poll_levelup_pick_input` / `_pick_levelup_card`.
- Card panel: 3 rows × ~30px tall, each row = "1. NAME — sentence"
  format. KEY_1/2/3 selects.
- Pause + process_mode = ALWAYS during pick (so input still polled
  even though enemies frozen) — mirrors the iter-91 P0-1 fix.

### Phase 3 — iter 199 BUILD — content batch 1 (PRISM + MORTAR)

- Implement apply_card for all PRISM_POOL entries.
- Implement apply_card for all MORTAR_POOL entries.
- Each apply_card branch is small (1-5 lines of state mutation).
- Add toast confirmation showing the picked card name.
- Hash anchor verification (loadout-gated).

### Phase 4 — iter 200 BUILD — content batch 2 (RAM + DEFAULT)

- Implement apply_card for RAM_POOL + DEFAULT_POOL.
- Replace `_apply_level_boost` call with `_show_levelup_pick` —
  the AUTOMATIC 3-cycle behavior is REMOVED at this point in
  favor of the pick. (Existing tests that call `_apply_level_boost`
  directly continue working as a "default DEFAULT card autopick"
  fallback for harness compat.)

### Phase 5 — iter 201 META — close + REVIEW-QUEUE

- New harness `test_breach_levelup_pick`:
    - Pick screen shows 3 cards.
    - Cards come from CURRENT_ARCHETYPE pool.
    - Pick applies state change.
    - Tree pauses during pick + unpauses after.
- REVIEW-QUEUE #14 (★ playtest gate) gets a note about the new
  upgrade surface — playtest 5 now has more meaningful build
  divergence to feel.
- LEDGER round-close summary.

## Risk register

- **Scope creep**: 6+ apply_card branches per archetype could grow
  to 30+ total. Cap at 4 cards per archetype for v1; expand later
  if playtest signals appetite.
- **Tutorial confusion**: pick-1-of-3 mid-run is a NEW interruption.
  Existing depot interruption is at a clear "rest stop". Level-up
  interruption mid-combat could be jarring. **Mitigation**: pause
  tree (iter-91 P0-1 pattern); only pop at level-up event
  boundaries which are already discrete.
- **F005 reminder**: the SWARM SPIKE blueprint was falsified
  because we built before having playtest data. This round is
  DIFFERENT: the cards LIFT existing verbs (no new mechanics),
  and the user explicitly directed the surface. Pre-playtest
  build is justified.
- **Archetype switching mid-pick**: if MORTAR→PRISM swap happens
  AFTER a MORTAR-specific card was picked, the bonus may not
  apply correctly. **Mitigation**: per-archetype state already
  lives in archetype-init/revert pathway; cards modify shared
  state where possible.

## Falsifiable claims (per phase)

- Phase 1: UpgradeCatalog.gd exports per-archetype pools; pool sizes
  are all ≥ 3 and ≤ 7.
- Phase 2: harness verifies pick screen pauses tree + 3 cards
  visible + KEY_1/2/3 selects.
- Phase 3: each PRISM/MORTAR apply_card branch testably mutates the
  expected field (e.g. BEAM_DPS_UP changes BEAM_DAMAGE_COOLDOWN).
- Phase 4: each RAM/DEFAULT apply_card branch likewise.
- Phase 5: full pick flow PRISM→pick → check state → MORTAR→pick →
  check state.

## Cadence

- Iter 196 META: this doc.
- Iters 197-200 BUILD: 4 iters of focused work, expect ~1.5 hrs total wall-clock at 240s cron cadence.
- Iter 201 META: close.

If at any phase the user signals direction-change (e.g. "skip cards;
just make level-up class-aware"), pivot in place per iter-55 playtest-
override pattern.
