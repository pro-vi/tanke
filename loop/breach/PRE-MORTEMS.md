# Breach loop pre-mortems (arc 4)

Append-only. One block per iter, written **before** ACT. H2 RULE v2 tags
mandatory: `[STRUCTURE]` / `[FEEL]` / `[MIXED]` / `[STRUCTURE-DEFERRED]` /
`[IDENTITY-PROTECTED]`.

Every entry cites which of the seven CONSULT §9 constraints the iter
respects or risks. Falsifiable claim required.

Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [<tag>]
- CONSULT constraints respected: <list>
- CONSULT constraints risked: <list, if any>
- Predicted failure: <where this iter might fail>
- Falsifiable claim: <a concrete observable that would prove the prediction>
- Sentence test (if upgrade-touching): "This upgrade helps me climb through ___ by changing how I use ___"
- Substrate touched: <files, if Layer 1/2/3>
- Hash-anchor verification plan: <pre-/post-edit check, or n/a>
```

---

## iter 061 — SWEEP — post-Round-8 verification grid

- Date: 2026-05-21
- Tag: [STRUCTURE-DEFERRED]
- Round 8 closed at iter 60; the user has not yet playtested. Per the
  iter-60 next_action, iter 61 is a non-speculative iter — a SWEEP over
  the post-Round-8 build, NOT a speculative Round 9 (CONSULT 006).
- The grid: (a) reachability sweep — test_breach_harness --deep across
  12 seeds (42-53), all 5 bands; (b) test-breach 28/28; (c) test-all
  5/5; (d) hash anchor seed 42.
- CONSULT constraints respected: 5 (every band reachability-checked).
  None risked — verification only.
- Predicted failure: Round 8 touched PlayerTank ×2 (XP, shield) +
  Spawner ×1 (ammo drops) — none touch level geometry — so
  reachability should be unchanged from the iter-54 12/12.
- Falsifiable claim: post-sweep — all 5 bands reachable on >=80% of
  the 12 seeds; test-breach 28/28; test-all 5/5; hash anchor
  23d6a2ec3bf2821f.
- Sentence test: n/a (verification iter).
- Substrate touched: none (SWEEP).
- Hash-anchor verification plan: seed 42 procedural baseline, part of
  the grid.

## iter 060 — CONSULT/QUEUE — Round 8-close

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8-close — the CONSULT + QUEUE + RUBRIC phase of the iter-055
  blueprint. Round 8's build phase (8a-8d, iters 56-59) shipped the
  iter-55 playtest-3 override in full.
- This iter: CONSULT 006 (written self-pre-mortem) on whether the
  roguelite overhaul cohered; RUBRIC.md +C14 "in-run progression" (per
  the blueprint — the iter-39 incremental pattern); REVIEW-QUEUE #11
  (the Round-8 playtest request).
- CONSULT constraints: n/a (a process iter). The C14 addition records
  that constraint 7 (verbs not stats) is relaxed for Round 8's surface
  per the user override.
- Predicted failure: the honest CONSULT finding is that Round 8 is
  harness-verified to EXIST but its coherence ("one game, not two
  bolted systems") is entirely playtest-gated — so C14 scores 3 (the
  structural ceiling), anchors 4-5 playtest-locked.
- Falsifiable claim: post-iter — RUBRIC.md has C14 (14 criteria, 70-pt
  ceiling), score 42/70; creative-consults.md has CONSULT 006;
  REVIEW-QUEUE.md has #11. No code touched → hash anchor + harnesses
  unchanged (23d6a2ec3bf2821f; test-all 5/5; test-breach 28/28).
- Sentence test: n/a.
- Substrate touched: none (docs only).
- Hash-anchor verification plan: n/a — no code this iter.

## iter 059 — BUILD — Round 8d: longer shields / defensive pickups

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8d of the iter-055 blueprint — the last build piece. Playtest-3:
  "make shields longer or something."
- The change (scripts/PlayerTank.gd, breach-mode only):
  - apply_shield: in breach mode (loadout != null) the shield lasts at
    least BREACH_SHIELD_DURATION (6s) — 3× the old 2s pickup shield.
    arc-2/3 keeps the passed duration.
  - A "SHIELD" HUD indicator (breach HUD) — visible only while the
    shield is active (toggled in _physics_process next to the existing
    blue-tint cue).
- The shield already drops from Light enemies (Enemy._spawn_shield_
  pickup, 10%) — 8d does NOT touch Enemy.gd (unsanctioned); it
  lengthens what apply_shield grants, so the existing drop is longer.
- CONSULT constraints: none risked — a defensive-pickup tuning + a HUD
  cue.
- Predicted failure modes:
  - Hash anchor: both changes gate on loadout != null; an arc-2/3
    PlayerTank's apply_shield + HUD are bit-identical.
  - apply_shield's only caller passes 2.0; maxf(2.0, 6.0) = 6.0 in
    breach mode, = 2.0 (the passed value) in arc-2/3.
- Falsifiable claim: post-edit — test_breach_shield shows a breach
  PlayerTank's apply_shield(2.0) sets _shield_timer to 6s + a HUD
  ShieldLabel shows while shielded; an arc-2/3 PlayerTank's
  apply_shield(2.0) stays 2s + builds no ShieldLabel. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 28/28.
- Sentence test: n/a (a defensive pickup tuning).
- Substrate touched: PlayerTank.gd (apply_shield + HUD — sanctioned,
  gated on loadout != null).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 058 — BUILD — Round 8c: enemy ammo drops

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8c of the iter-055 blueprint — playtest-3's "does enemy drop
  ammo?"
- Investigation finding: the pickup-drop pattern already lives in
  Enemy.gd (`_spawn_hp_pickup` / `_spawn_shield_pickup`, arc-2 iters
  78/82). Enemy.gd is NOT sanctioned substrate. Per the blueprint, 8c
  hooks via Spawner.gd instead (sanctioned) — the Spawner already
  connects to each enemy's `killed` signal for kill-counting.
- The change:
  - New scripts/AmmoPickup.gd + scenes/AmmoPickup.tscn (arc-4-owned):
    an Area2D that on `_ready` picks a random droppable shell
    (HE/HEAT/APCR — never AP, which is unlimited) + tints a chip; on
    the player driving over it, +AMOUNT to that shell's loadout
    reserve + a toast; despawns after LIFETIME (8s).
  - scripts/Spawner.gd (sanctioned): `enemy.killed.connect(
    _on_enemy_killed.bind(enemy))` passes the dying enemy;
    `_try_ammo_drop` spawns an AmmoPickup at its position with
    AMMO_DROP_CHANCE. The breach-mode gate (player has a Loadout) is
    checked BEFORE randf() — an arc-2/3 run consumes zero RNG here.
- CONSULT constraints: constraint 1 respected (a pickup is collected
  by driving, not a modal).
- Predicted failure modes:
  - Hash anchor: Spawner.gd is substrate. `_try_ammo_drop` returns at
    the breach-mode gate before any randf() in arc-2/3 mode → no RNG
    consumed → the seed-42 procedural baseline is bit-identical.
  - The pickup is a no-op against a body with no loadout (arc-2/3
    player) — defensive duck-typing.
- Falsifiable claim: post-edit — test_breach_ammo shows an AmmoPickup
  picks a droppable shell + on collection adds AMOUNT to that shell's
  reserve + frees; a no-loadout body does not collect. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 27/27.
- Sentence test: n/a (a resupply pickup, not a depot upgrade).
- Substrate touched: Spawner.gd (the kill-signal hook — sanctioned;
  arc-2/3 bit-identical via the pre-randf breach gate).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 057 — BUILD — Round 8b: per-phase upgrade-card pick

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8b of the iter-055 blueprint — "a pick-1-of-3 upgrade screen
  at every band boundary" + the reward-beat framing.
- 8b DECISION: extend the depot system (blueprint Option A), not a new
  band-clear screen (Option B duplicates the depot's whole pick
  machinery). The depots ALREADY are per-boundary picks — 8b makes
  them (a) complete and (b) read as rewards.
- The change:
  - scenes/BreachLevel.tscn — add Depot4 at depth 180 (the
    open_killbox→endgame boundary), so there is a pick after every one
    of the 4 completable phases (was 3 depots / 3 picks). The endgame
    finale stays depot-less.
  - scripts/Depot.gd — `_show_panel` reframes the depot as a reward
    beat: the Title names the band just cleared (`_resolve_cleared_
    band_name` — a phase becomes a named milestone, the real fix for
    "phases don't read"); choices are a numbered "[1]/[2]/[3]" pick.
  - scenes/Depot.tscn — Title default text → "— PHASE CLEARED —".
- CONSULT constraints: constraint 1 respected — the depot pauses the
  tree; the pick is at a safe gate, never in combat.
- Predicted failure modes:
  - test_breach_level asserts >=3 depots — tightened to >=4 for the
    per-phase deliverable.
  - test_breach_depot opens the panel + checks ChoiceA contains
    choice_a_label — the "[1]  " prefix keeps it a substring match.
  - No substrate touched (BreachLevel.tscn / Depot.tscn / Depot.gd are
    all arc-4-owned) — hash anchor trivially preserved.
- Falsifiable claim: post-edit — test_breach_level reports depots=4;
  test_breach_depot shows the panel Title reads "...CLEARED". Hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 26/26.
- Sentence test: n/a (the depot offers the existing catalog; the
  per-phase cadence + framing is the change).
- Substrate touched: none (arc-4-owned scenes/scripts).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 056 — BUILD — Round 8a: XP + level-up core

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8a, the first build of the iter-055 blueprint — the headline
  playtest-3 ask, "where is the roguelite element like level ups?"
- The change (scripts/PlayerTank.gd, breach-mode only — gated on
  loadout != null): the tank earns XP from enemy kills (via the
  Spawner's enemies_killed) + depth climbed; at scaling thresholds it
  levels up; each level-up applies an AUTOMATIC stat boost rotated
  across max HP / reload speed (GunTimer.wait_time) / shell capacity.
  A HUD XP bar + LEVEL readout. No mid-combat modal — level-ups are
  automatic, so CONSULT constraint 1 holds.
- CONSULT constraints: constraint 7 (verbs not stats) is relaxed for
  Round 8 by the user override (STATE §Arc-4 amendments); constraint 1
  (no choice in combat) respected — level-ups are automatic.
- Predicted failure modes:
  - Hash anchor: the XP system is fully gated on loadout != null; an
    arc-2/3 PlayerTank never earns XP, builds no XP HUD — bit-identical.
  - GunTimer.wait_time: the .tscn leaves it at the 1.0s default
    (gun_cooldown the @export is unused). The reload boost mutates
    wait_time directly; floored at RELOAD_MIN.
  - Score: per the iter-055 blueprint, the rubric criterion for in-run
    progression (C14) is added at round close — iter 56 is a Δ-0
    structural BUILD (the surface exists + is harness-cited; C14 lands
    with the round).
- Falsifiable claim: post-edit — test_breach_xp shows a breach
  PlayerTank builds the XP HUD, granting XP crosses level thresholds
  (_level rises), and the level-up rotation boosts max HP + reload +
  shell capacity; an arc-2/3 PlayerTank builds none + cannot level.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach
  26/26 (new check-breach-xp).
- Sentence test: n/a — the user override relaxes constraint 7; stat
  level-ups are now sanctioned.
- Substrate touched: PlayerTank.gd (XP/level system + HUD —
  sanctioned, gated on loadout != null; arc-2/3 bit-identical).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 055 — PLAYTEST — playtest-3 integrated; Round 8 opened

- Date: 2026-05-21
- Tag: [STRUCTURE-DEFERRED]
- The user playtested after Round 7 (the iter-53 / REVIEW-QUEUE #9
  gate) and delivered a direction-changing verdict: the 5 phases still
  do not read; enemies should drop ammo; "where is the roguelite
  element like level ups?" — the user does not perceive the breach
  economy as roguelite progression.
- Via AskUserQuestion (user override authority — PROMPT §USER-LOOK):
  progression = BOTH (XP level-ups + per-phase upgrade-card picks);
  enemy ammo drops = YES; "+ make shields longer."
- This iter: integrate the playtest, record the override in STATE
  §Arc-4 amendments, open Round 8 (the roguelite-progression
  overhaul), write the blueprint iter-055-round8-architect.md, append
  REVIEW-QUEUE #10.
- CONSULT constraints: the user's "XP + stats" pick RELAXES constraint
  7 (verbs not passive stats) for Round 8 — a sanctioned override.
  Constraint 1 (no choice during combat) is PRESERVED — level-ups are
  automatic; picks happen at paused safe gates.
- Predicted failure: Round 8 is a big round (4 sub-rounds) layering a
  conventional power curve onto the breach economy. The risk is the
  two progression systems (breach-economy shells + XP/levels) feeling
  bolted-together rather than one game. The 8-close CONSULT must check
  coherence, and may need a RUBRIC reframe (the rubric is built around
  "breach economy" — the override shifts the stone).
- Falsifiable claim: post-iter — iter-055-round8-architect.md exists
  with the 8a-8d sequence; STATE §Arc-4 amendments records the
  playtest-3 override; REVIEW-QUEUE #9 CLOSED, #10 opened. No code
  touched → hash anchor + harnesses unchanged (23d6a2ec3bf2821f;
  test-all 5/5; test-breach 25/25).
- Sentence test: n/a (a planning iter).
- Substrate touched: none (planning only).
- Hash-anchor verification plan: n/a — no code this iter.

## iter 054 — SWEEP — post-Round-7 verification grid

- Date: 2026-05-20
- Tag: [STRUCTURE-DEFERRED]
- Round 7 closed at iter 53; the user has not yet playtested. Per the
  iter-53 next_action, iter 54 is a non-speculative iter — a SWEEP
  verification grid over the post-Round-7 build (30 substrate writes
  across 7 rounds), NOT a speculative new mechanic round.
- The grid: (a) reachability sweep — test_breach_harness --deep across
  12 seeds (42-53), all 5 bands per seed; (b) test-breach 25/25; (c)
  test-all 5/5; (d) hash anchor seed 42. A holistic "is the build
  still coherent after Round 7" check.
- CONSULT constraints respected: 5 (every band reachability-checked).
  None risked — verification only, no code touched.
- Predicted failure: Round 7 touched Bullet / PlayerTank / Depot /
  MetaProgress — none touch level geometry — so reachability should be
  structurally unchanged from the iter-26-era 9/10 sweep. If a seed
  blocks a band, that is a pre-existing procedural-generation edge,
  not a Round-7 regression.
- Falsifiable claim: post-sweep — all 5 bands reachable on >=80% of
  the 12 seeds (the REACHABILITY FLOOR); test-breach 25/25; test-all
  5/5; hash anchor 23d6a2ec3bf2821f. If reachability drops below the
  iter-26 baseline (9/10 = 90%), that is a finding.
- Sentence test: n/a (verification iter).
- Substrate touched: none (SWEEP — no code).
- Hash-anchor verification plan: seed 42 procedural baseline, part of
  the grid.

## iter 053 — CONSULT/QUEUE — Round 7-close

- Date: 2026-05-20
- Tag: [STRUCTURE-DEFERRED]
- Round 7-close — the CONSULT + QUEUE phase of the iter-047 blueprint.
  Round 7's build phase (7a-7e, iters 48-52) shipped a fix for all 5
  of playtest-2's findings.
- This iter: CONSULT 005 (written self-pre-mortem — the established
  arc-4 mode; cf. CONSULT 003/004) reviewing whether Round 7's 5
  builds actually address the 5 findings, + the 3 permanent questions;
  then REVIEW-QUEUE #9 (the Round-7 playtest request).
- CONSULT constraints respected: n/a (a process iter — no mechanic
  built, no constraint touched). None risked.
- Predicted failure: the CONSULT's honest finding is that 4 of 5
  Round-7 fixes are playtest-gated and F003 is live — so this iter
  produces no rubric lift and recommends a playtest. The risk is the
  loop treating "Round 7 shipped" as "Round 7 worked" without the
  playtest. The CONSULT exists to name that.
- Falsifiable claim: post-iter — creative-consults.md has CONSULT 005;
  REVIEW-QUEUE.md has #9 (playtest request). No code touched → hash
  anchor + harnesses unchanged from iter 52 (23d6a2ec3bf2821f;
  test-all 5/5; test-breach 25/25). Score Δ 0 (39/65 — a process
  iter).
- Sentence test: n/a (no upgrade).
- Substrate touched: none (docs only).
- Hash-anchor verification plan: n/a — no code touched this iter.

## iter 052 — BUILD — Round 7e: HE explosion visual

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7e, the last build piece of the iter-047 blueprint. Fixes
  playtest finding 5 — "HE should have an explosion effect."
- The change (scripts/Bullet.gd): HE already applies a radius blast
  mechanically (_apply_he_blast); this gives it a visual. On an HE
  detonation `_spawn_he_explosion` spawns two ColorRect layers — a warm
  outer bloom sized to the full blast diameter + a bright inner core —
  that expand from small to full and fade over ~0.28s. The proven
  `_spawn_impact_spark` pattern, scaled up. Algorithmic, no MLX-SD.
- CONSULT constraints respected: none risked — a visual for an existing
  mechanic, no economy/identity surface touched.
- Predicted failure modes:
  - Hash anchor: the explosion is inside `_on_body_entered`'s HE branch
    — the seed-42 procedural baseline fires AP only → never reached →
    bit-identical.
  - Visual-verification caveat (per the blueprint): the harness can
    confirm the explosion NODES spawn, not that the blast LOOKS right —
    the look is playtest-gated (cf. F003).
- Falsifiable claim: post-edit — test_breach_he_blast Test 4 shows an
  HE hit spawns >=2 "HEBlast" ColorRect layers and an AP hit spawns 0.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach
  25/25.
- Sentence test: n/a (a visual for an existing mechanic).
- Substrate touched: Bullet.gd (HE branch of _on_body_entered —
  sanctioned, flag-off AP path bit-identical).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 051 — BUILD — Round 7d: meta-progression legibility

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7d, piece 4 of the iter-047 blueprint. Fixes playtest finding 3
  — "what can be unlocked?"
- The change, two parts:
  - Tiers: the unlock ladder goes from 2 rungs to 4. MetaProgress now
    gates 4 upgrades — Breach Dividend @20, Overdrive @40, Quick Swap
    @60, Steel Salvage @80. The 5 core economy upgrades (refills /
    expands / resupply) stay always-available. Depot's _upgrade_pool
    widens 5→6→7→8→9 with best-depth (was 7→8→9).
  - Legibility: the codex's single (vague) iter-45 meta line is
    replaced by a 4-cell unlock ladder — one cell per tier, green when
    the player's best depth has reached it, dark when locked — under a
    "best depth N" header. The player sees the whole ladder + where
    they stand on it.
- CONSULT constraints respected: 7 (options, not power — the 5 core
  economy upgrades cover the baseline; the 4 gated ones are earned
  OPTIONS). None risked.
- Predicted failure: F003 recurs — the iter-45 meta line is exactly a
  legibility surface that existed but did not communicate (→ finding
  3). A clearer codex ladder is harness-verified to EXIST; only the
  next playtest confirms it LANDS. Moving Breach Dividend + Overdrive
  out of the always-on core shrinks the fresh randomized pool (5, was
  7) — intentional (meta-progression), but test_breach_overdrive /
  test_breach_meta must stay green.
- Falsifiable claim: post-edit — test_breach_meta shows a 4-rung
  ascending ladder + pool sizes 5/6/7/8/9; test_breach_codex shows the
  codex renders the ladder (UNLOCKS + 4 tier names). Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 25/25.
- Sentence test: n/a (a meta-progression retier + legibility surface).
- Substrate touched: PlayerTank.gd (HUD codex only — gated on
  loadout != null). MetaProgress.gd + Depot.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 050 — BUILD — Round 7c: run-route legibility

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7c, piece 3 of the iter-047 blueprint. Fixes playtest finding 2
  — "no idea what band shuffle means."
- The change: surface the run's shuffled band sequence.
  - A persistent HUD route strip (PlayerTank breach-mode HUD): one cell
    per depth band, named in THIS run's order, the current band's cell
    highlighted, passed bands tinted 'cleared'. Built deferred (the
    level's _init_breach_mode shuffles the order in the level's _ready,
    after this child's _ready). Updated on each band crossing.
  - A run-route line in the shell codex naming the concept ("5 depth
    bands; the middle 3 reshuffle each run") so the word lands on run 1.
- The strip is hidden behind the run-start codex, revealed on dismiss.
- CONSULT constraints respected: 5 (each band is a specific climb
  problem — the strip names all 5, making the per-band structure
  legible). None risked.
- Predicted failure: build order — PlayerTank._ready runs before the
  level's _ready, so breach_config is pre-shuffle at _ready time.
  Mitigated by call_deferred. F003 recurs: a legibility surface is
  harness-verified to EXIST, not to LAND — the next playtest must
  confirm finding 2 is fixed.
- Falsifiable claim: post-edit — test_breach_route shows the strip
  names the 5 bands in run order, the highlight tracks crossings, the
  strip hides behind the codex; arc-2/3 PlayerTank builds none. Hash
  anchor 23d6a2ec3bf2821f preserved (HUD-only; gated on loadout);
  test-all 5/5; test-breach 25/25 (new check-breach-route).
- Sentence test: n/a (a legibility surface, not an upgrade).
- Substrate touched: PlayerTank.gd (HUD only — sanctioned, gated on
  loadout != null; arc-2/3 builds nothing).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 049 — BUILD — Round 7b: APCR penetrate-steel redesign

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7b, piece 2 of the iter-047 blueprint. Fixes playtest finding 4
  — the user-confirmed APCR redesign.
- The change: APCR no longer does a radius cluster-breach (iter 34).
  APCR now PENETRATES steel — on hitting a steel block it breaks that
  ONE block (like AP breaks one brick) and does NOT queue_free; the
  bullet flies on, drilling a 1-wide tunnel through the wall until its
  lifetime ends. `_apply_apcr_breach` + APCR_BREACH_RADIUS_PX deleted;
  the APCR-steel branch in `_on_body_entered` is handled first + returns.
  STEEL_SALVAGE retunes — it now counts blocks DRILLED by one shot
  (`_steel_drilled`); >=3 → refund 1 APCR.
- CONSULT constraints respected: 3 (APCR keeps one crisp job — the
  steel penetrator). The iter-34 radius design is superseded per the
  user (STATE §Arc-4 amendments).
- Predicted failure modes:
  - The penetrate must NOT queue_free the bullet on steel — the
    APCR-steel branch returns before the `_spawn_impact_spark;
    queue_free` tail. AP/HE/HEAT + APCR-vs-non-steel still fall through
    + free.
  - test_breach_apcr (`_test_steel_breach`) expects the radius design;
    test_breach_rulechangers (`_run_salvage`) expects one-call cluster
    salvage. Both rewritten for the drill model.
  - Hash anchor: APCR-steel is inside `_on_body_entered`'s APCR branch;
    the procedural baseline fires AP → never reached → bit-identical.
- Falsifiable claim: post-edit — test_breach_apcr shows APCR breaks
  only the hit steel block (no radius), penetrates (bullet survives),
  and drills the next block; test_breach_rulechangers shows STEEL_SALVAGE
  fires after drilling >=3. Hash anchor 23d6a2ec3bf2821f preserved;
  test-all 5/5; test-breach 24/24.
- Sentence test: n/a (shell redesign, not an upgrade).
- Substrate touched: Bullet.gd (`_on_body_entered` + APCR funcs —
  sanctioned, breach-only path).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 048 — BUILD — Round 7a: shell-economy retune (starter reserves + caps)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7a (the iter-46 playtest fix-round), piece 1. Blueprint:
  iter-047-round7-architect.md. Fixes playtest finding 1 — "shells too
  few to manage."
- The change: configs/breach_starter_loadout.tres — starter reserves
  HE 2→6, HEAT 1→4, APCR 2→5; caps max_he 6→12, max_heat 3→8,
  max_apcr 4→10. The starter total goes 5 → 15 finite shells; the
  economy becomes a managed handful, not "two shots and done." Still
  finite + spendable — scarcity (the breach-economy identity) holds.
- Δ note: a tuning change; C3's structural tier is maxed → Δ 0. The
  value is [FEEL]-gated (the next playtest re-checks finding 1).
- CONSULT constraints respected: 7 (reserves are the economy, not a
  %stat). The retune respects the scarcity identity — finite, spendable.
- Predicted failure modes:
  - A harness asserts the .tres's exact reserve values. Checked:
    test_breach_level only asserts he_reserve > 0 (passes); no other
    harness reads the .tres values (they build LoadoutT.new() with
    explicit values). The retune is harness-safe.
  - Over-correction — too generous → no economy. Mitigation: 3× the
    starter (5→15) is a managed handful; the next playtest tunes
    further if needed.
- Falsifiable claim: post-edit — make test-all 5/5; make test-breach
  24/24; test_breach_level reports he_reserve=6. Hash anchor
  23d6a2ec3bf2821f preserved (the .tres is the breach starter, off the
  procedural baseline).
- Sentence test: n/a (tuning, no new upgrade).
- Substrate touched: none — breach_starter_loadout.tres is arc-4-owned.
  Loadout.gd's bare-Resource default maxes are left as-is (harness-
  relevant only; the .tres governs the gameplay starter).
- Hash-anchor verification plan: regression guard — the breach starter
  loadout is not on the procedural hash path.

## iter 047 — PLAYTEST — integrate the iter-46-gate playtest; open Round 7

- Date: 2026-05-20
- Tag: [FEEL] (the iter's input is a human playtest)
- The event: the user playtested after Round 6 (the iter-46 playtest
  gate) and gave 5 findings; 2 clarified via AskUserQuestion. The loop
  re-engages, opens Round 7 (the fix-round).
- CONSULT constraints respected: all 7 (integration/planning iter). The
  Round-7 blueprint is written to respect them — APCR keeps one crisp
  job (constraint 3), the HE explosion is algorithmic (constraint 4 /
  no MLX-SD).
- Prior-design overridden: the iter-34 APCR design (breaches steel via
  an 18px radius cluster) is superseded by the user's confirmed
  redesign — APCR penetrates steel, drilling 1 block per hit. Recorded
  STATE §Arc-4 amendments.
- Predicted failure: the Round-7 plan under-scopes the legibility
  findings (2, 3) — building MORE surface that still does not land
  (F003 recurring). Mitigation: 7c/7d are explicitly "make it
  communicate," and the next playtest re-checks all 5.
- Falsifiable claim: this iter commits the Round-7 blueprint +
  REVIEW-QUEUE (#7 closed, #8 appended) + STATE unpaused to RUNNING.
  No code change → no hash risk. iter 48 begins Round 7 BUILD (7a).
- Sentence test: n/a (no upgrade this iter).
- Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 046 — CONSULT — Round 6 close (CONSULT 004) + playtest gate / pause

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6 (roguelite feel) close iter. Mode: CONSULT — written
  self-pre-mortem (iter 46 is the playtest-handoff; the user playtest
  is THE creative check and it is next, so a frontier CONSULT is
  redundant — CONSULT 003 precedent).
- CONSULT constraints respected: all 7 (review iter, no design surface).
- Predicted failure: the CONSULT rubber-stamps Rounds 5-6, or the loop
  spins Round 7 on unverified structure. Mitigation: CONSULT 004 names
  the seductive-but-hollow risk (the core economy's felt depth is still
  unverified after 13 autonomous iters) and the loop PAUSES rather than
  pile more — the iter-32 judgement, the F003 lesson.
- Falsifiable claim: this iter writes CONSULT 004 + REVIEW-QUEUE #7
  (playtest request) + STATE → paused. No code change → no hash risk.
  The loop pauses; no wakeup scheduled.
- Sentence test: n/a. Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 045 — BUILD — Round 6e: meta-progression (depot-pool widening)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e (meta-progression), the last Round-6 sub-round. Blueprint:
  iter-043-round6e-architect.md (Option A).
- The build: climbing deep across runs unlocks advanced depot upgrade
  kinds into the depot offer pool. A fresh save: 7 core upgrades; best
  depth 40 → +Quick Swap; 80 → +Steel Salvage. Options-not-power
  (CONSULT 003) — an unlocked rule-changer adds a build path, not a
  stat. Standard roguelite meta (the Slay-the-Spire card-unlock shape).
- New `scripts/MetaProgress.gd` — reads best_depth from the existing
  user://stats.cfg; pure unlock predicates. Depot `_upgrade_pool()`
  consults it; the codex surfaces the unlock state.
- CONSULT constraints respected: 7 (unlocks are options/affordances,
  never raw power), 1 (no combat-time surface).
- Predicted failure modes:
  - The depot pool now depends on ambient stats.cfg → test_breach_depot_roll
    could become flaky. Mitigation: `_upgrade_pool(best)` takes an
    explicit-best param (default -1 = live); the new harness passes
    explicit depths; depot-roll's assertions (3 distinct, ≥2 sets)
    hold for any pool ≥4.
  - The 2 iter-41 rule-changers become depth-gated — a fresh save sees
    7 depot kinds, not 9. This is the meta-progression curve, not a
    regression; apply_upgrade still applies any kind directly
    (test_breach_rulechangers unaffected).
  - Codex crowding — the meta line + a taller codex panel.
- Falsifiable claim: post-edit — a new check-breach-meta harness shows
  the unlock predicates gate at 40/80 and the depot pool widens 7→8→9
  with best-depth. Hash anchor 23d6a2ec3bf2821f preserved; test-all
  5/5; test-breach 24/24. RUBRIC +C13, C13 → 3.
- Sentence test: meta-unlocks are not depot upgrades themselves — they
  unlock the existing rule-changers (each already sentence-tested).
- Substrate touched: PlayerTank.gd (codex meta line — sanctioned, HUD).
  MetaProgress.gd is new; Depot.gd arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — MetaProgress + Depot are off the procedural hash path; the codex
  is loadout-gated. Verify before commit.

## iter 044 — BUILD — loadout-lifecycle fix (F004: shared-Resource run leak)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e, piece 1 (a correctness fix the iter-43 SPIKE surfaced —
  Finding 1). Blueprint: iter-043-round6e-architect.md.
- The bug (F004): the breach loadout is a shared Resource —
  breach_starter_loadout.tres baked into BreachLevel.tscn, no
  resource_local_to_scene, never duplicated. consume() + depot upgrades
  mutate it in place; Godot's resource cache reuses the instance across
  reload_current_scene → run 2+ of a session starts with run 1's
  depleted reserves + purchased upgrades. The restart loop — core to a
  roguelite — was quietly broken.
- The fix: PlayerTank `_ready`, when loadout != null, `loadout =
  loadout.duplicate()` — each run gets a private copy from the .tres
  template; the template is never mutated.
- CONSULT constraints respected: all 7 (a correctness fix; no design
  surface).
- Predicted failure modes:
  - The duplicate breaks harnesses that assume pt.loadout IS the object
    they passed + mutate it post-_ready. Analysis: test_breach_loadout
    (Test 5) + test_breach_hud (the refresh spot) break — both updated
    to read pt.loadout. test_breach_swap / overdrive / rulechangers /
    stakes / codex set loadout flags BEFORE add_child (the dup copies
    them) and never read the passed object after → unaffected.
  - duplicate() must be a complete copy — Loadout has no sub-resources,
    so a shallow duplicate() copies every @export field.
- Falsifiable claim: post-edit — test_breach_loadout's new Test 6 shows
  a PlayerTank duplicates its loadout (pt.loadout != the passed
  resource; values copied; spending the run loadout does NOT mutate the
  template). Hash anchor 23d6a2ec3bf2821f preserved (dup is breach-only,
  loadout-gated). test-all 5/5; test-breach 23/23.
- Sentence test: n/a (bug fix).
- Substrate touched: PlayerTank.gd (`_ready` loadout duplicate —
  sanctioned; loadout-gated so arc-2/3 untouched).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the dup is inside `if loadout != null`; the procedural baseline
  PlayerTank has no loadout → bit-identical.

## iter 043 — SPIKE — Round 6e: meta-progression design + loadout-lifecycle probe

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e (meta-progression), the last Round-6 sub-round. Mode: SPIKE
  — meta-progression is the most design-uncertain sub-round (what to
  unlock, how to surface, whether it touches loadouts). A blind BUILD
  snowballed in pre-mortem analysis (the loadout-lifecycle question
  below) — the scope-too-broad signal — so this iter SPIKEs: investigate,
  verdict, blueprint; no code commit (iter-1 / iter-38 SPIKE precedent).
- CONSULT constraints respected: all 7 (read-only investigation).
- Predicted failure: the SPIKE picks a meta design without seeing a
  blocking entanglement. Known candidate already surfaced: the breach
  loadout is a SHARED resource (breach_starter_loadout.tres — no
  resource_local_to_scene, no duplicate()) — `consume()` mutates it,
  and reload_current_scene reuses the cache → run 2+ likely starts with
  run 1's depleted reserves + purchased upgrades. Any loadout-touching
  meta design is entangled with this.
- Falsifiable claim: this iter writes loop/breach/iter-043-round6e-architect.md
  — a verdict across >=2 meta-progression options + the loadout-
  lifecycle finding + the iter-44+ sequence. No code change → no hash
  risk.
- Sentence test: n/a (SPIKE).
- Substrate touched: none (investigation + blueprint doc).
- Hash-anchor verification plan: n/a (no code change).

## iter 042 — BUILD — Round 6d: stakes & escalation (band banner + live best-depth)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6d (stakes & escalation), piece 1. Blueprint: iter-038-round6-architect.md.
- DIAGNOSE: the arc-2 ascender already gives breach mode a lot of
  "stakes" — a DEPTH/TIME HUD, depth-milestone flashes, a run-framed
  death recap with best-depth, persistent best tracking, the [R]-restart
  loop. The genuine GAP for the breach roguelite: (a) band transitions
  are silent — nothing marks the escalation beat; (b) best-depth shows
  only on death, not live. iter 42 fills both.
- CONSULT constraints respected: 5 (the banner names each band's
  specific pressure — reinforces "each band is a climb problem"), 1
  (HUD readout, no combat-time decision).
- Predicted failure modes:
  - The band banner needs a breach_band_changed source. The signal
    exists only on ProceduralLevel + fires only in breach mode — the
    connect is gated on loadout != null + has_signal, so arc-2/3 never
    wires it.
  - The best-depth label must be breach-gated (loadout != null) so the
    arc-2 procedural HUD stays bit-identical — NOT placed in the
    show_ascender_hud block (which arc-2 shares).
  - A missing-glyph risk in the banner — kept ASCII ("ENTERING:").
- Falsifiable claim: post-edit — a new check-breach-stakes harness shows
  a breach PlayerTank builds a BestLabel + raises a BandBanner naming
  the band on a breach_band_changed emit; an arc-2/3 PlayerTank builds
  neither. Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5;
  test-breach 23/23. RUBRIC +C12, C12 → 3.
- Sentence test: n/a (HUD/stakes, no upgrade).
- Substrate touched: PlayerTank.gd (HUD + the band-signal connect —
  sanctioned; all new HUD gated on loadout != null).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the new HUD is loadout-gated; the procedural baseline PlayerTank
  has no loadout → HUD path bit-identical.

## iter 041 — BUILD — Round 6c: depot rule-changers (Quick Swap + Steel Salvage)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6c (build divergence), piece 1. Blueprint: iter-038-round6-architect.md.
  Answers CONSULT 003 Q2 — "depots need more rule-changers; the player
  chooses quantity, not doctrine." The catalog was 5 stock-refills + 2
  rule-changers; this iter adds 2 more rule-changers → 5 + 4.
- Δ note: the structural anchors C1 (build identity) + C8 (sentence
  test) are already maxed; rule-changers deepen the build-divergence
  AXIS but the lift is [FEEL]-gated. Expect Δ 0 — a real BUILD.
- The 2 rule-changers (both CONSULT-§9-#7 verbs, conditional
  doctrine-definers, low-risk — reuse existing patterns):
  - QUICK_SWAP — shell swaps cost no reload beat. The "adaptive
    generalist" doctrine vs the committed-specialist default.
  - STEEL_SALVAGE — an APCR shot opening a steel cluster (>=3 blocks)
    refunds 1 APCR. The APCR analogue of Breach Dividend; the "steel
    breacher" doctrine. Mirrors _try_breach_dividend exactly.
- CONSULT constraints respected: 7 (both are affordance verbs, not
  %stats — sentence-tested in Loadout's UPGRADE CATALOG), 1 (granted
  at depots), 2 (still 4 shells — no new shell).
- Predicted failure modes:
  - test_breach_overdrive.gd hard-asserts UK.size()==7 → adding 2 kinds
    breaks it. Mitigation: update it to 9.
  - QUICK_SWAP reads loadout.quick_swap in _cycle_shell — must not
    affect arc-2/3 (loadout null → _cycle_shell early-returns before
    the read).
  - STEEL_SALVAGE must be gated on a real steel-CLUSTER breach, not a
    stray block — threshold 3 (mirror of the HE-dividend's 4).
- Falsifiable claim: post-edit — a new check-breach-rulechangers harness
  shows QUICK_SWAP suppresses the swap reload beat (control still arms
  it), STEEL_SALVAGE refunds APCR only with the upgrade + only on a
  >=3-cluster, apply_upgrade sets both flags. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 22/22.
- Sentence test: QUICK_SWAP — "...climb through pressure-mixed bands by
  changing how I use shell-swapping — free swaps to adapt mid-fight."
  STEEL_SALVAGE — "...climb through steel-walled bunkers by changing how
  I use APCR — opening a steel cluster refunds its own shell."
- Substrate touched: Bullet.gd (_apply_apcr_breach returns a count +
  _try_steel_salvage — sanctioned, breach-only path), PlayerTank.gd
  (_cycle_shell quick_swap gate — sanctioned). Loadout.gd + Depot.gd
  are arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — both substrate edits are inside breach-only paths (APCR shells /
  loadout-gated _cycle_shell); flag-off baseline bit-identical.

## iter 040 — BUILD — Round 6b: depot-offer randomization

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6b (deeper variety), piece 1. Blueprint: iter-038-round6-architect.md.
- Δ note: C11's structural tier (anchors 1-3) was maxed by iter 39's
  band-shuffle; depot-offer randomization deepens the run-variety AXIS
  but cannot lift the integer (C11 anchors 4-5 are [FEEL]). Δ 0 — a real
  BUILD (a new mechanic the playtest's roguelite-feel ask demands), not
  BUILD-QUALITY. The lift is [FEEL]-gated. Today the 3 BreachLevel
  depots all offer the IDENTICAL fixed 3 choices every run; this makes
  each depot draw a different 3-of-7 per run.
- CONSULT constraints respected: 1 (offers shown only at the safe gate),
  7 (every rolled label is an economy verb, not a %stat).
- Predicted failure modes:
  - Randomization breaks test_breach_depot_choice.gd, which drives
    apply_choice(1/2/3) expecting the @export defaults. Mitigation:
    randomize_offers defaults FALSE — bare/harness depots keep the fixed
    choices; only the BreachLevel depots (flag set true in the .tscn)
    randomize.
  - The roll runs before level_seed is resolved. Mitigation: lazy roll
    on first need (_ensure_rolled) — by then the level's _ready has
    resolved the seed.
  - A depot rolls duplicate kinds. Mitigation: Fisher-Yates over the
    7-kind pool, take the first 3 — distinct by construction.
- Falsifiable claim: post-edit — a new check-breach-depot-roll harness
  shows randomize_offers=true depots roll 3 distinct kinds with >=2
  distinct sets across seeds, and a randomize_offers=false depot uses
  the @export defaults; test_breach_depot_choice still green; hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 21/21.
- Sentence test: the 7 catalog entries are unchanged (all pass — Loadout
  UPGRADE CATALOG block); this iter only changes WHICH 3 are offered.
- Substrate touched: none — Depot.gd + BreachLevel.tscn are arc-4-owned.
- Hash-anchor verification plan: Depot.gd is not on the procedural hash
  path; flag-off baseline unaffected. Verified as a regression guard.

## iter 039 — BUILD — Round 6a: per-run band-order shuffle + dynamic depot preview

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6a (run-to-run variety), piece 1. Blueprint: iter-038-round6-architect.md.
- CONSULT constraints respected: 5 (each band stays its own specific
  climb problem — shuffling ORDER does not blur a band's pressure; the
  level_config travels with the archetype), 1 (depot still a safe gate).
- Predicted failure modes:
  - The shuffle mutates the shared breach_default.tres Resource → leaks
    across runs / other instances. Mitigation: _shuffled_breach_config
    duplicates every band + returns a NEW BreachConfig; the source is
    never touched. The harness asserts the source is unmutated.
  - Band-order shuffle moves band boundaries → fixed-y depots drift off
    transitions. Mitigation: fixed-SLOT shuffle — the 3 middle archetypes
    permute into the 3 fixed depth slots (30-70 / 70-120 / 120-180), so
    boundaries (hence depot alignment) are invariant.
  - The shuffle's RNG perturbs procedural generation. Mitigation: a
    separate RandomNumberGenerator instance — the global seed() used by
    tile generation is untouched; and _init_breach_mode runs AFTER all
    generation anyway.
  - Reachability: a band-archetype in a different-span slot. The oracle
    is per-band-LOCAL + density-based (span-independent) — verified safe.
- Falsifiable claim: post-edit — hash anchor flag-off = 23d6a2ec3bf2821f
  (the shuffle is inside breach-only _init_breach_mode); a new
  check-breach-shuffle harness shows >=2 distinct middle-band orders
  across 7 seeds, tutorial+endgame pinned, fixed slots, source
  unmutated; make test-all 5/5; make test-breach 20/20.
- Sentence test: n/a (no upgrade).
- Substrate touched: ProceduralLevel.gd (_init_breach_mode + new
  _shuffled_breach_config — sanctioned; inside the breach-gated path).
  Depot.gd is arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the shuffle is unreachable when breach_mode_enabled=false; flag-off
  baseline bit-identical. Verify before commit.

## iter 038 — SPIKE — Round 6 open: run-to-run variety investigation

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6 (roguelite feel) opens. Mode: SPIKE — investigate the
  highest-leverage run-variety option, output a verdict + the Round 6
  blueprint. No code commits this iter (SPIKE = scouting; iter-1
  precedent).
- CONSULT constraints respected: all 7 (investigation, no design surface
  committed). The blueprint is written to respect 5 (each band stays a
  specific climb problem — shuffling order does not blur pressures).
- Predicted failure: the SPIKE picks band-order shuffle without seeing a
  hidden coupling cost. Known candidate: depot next-band previews are
  static @exports — shuffling bands makes them wrong; the blueprint must
  account for dynamic depot previews.
- Falsifiable claim: this iter writes loop/breach/iter-038-round6-architect.md
  — a Round 6 blueprint with (a) a run-variety verdict across >=2
  investigated options, (b) the Round-6 sub-round sequence, (c) a RUBRIC
  extension proposal for the roguelite axes. No code change -> no hash
  risk. iter 39 begins Round 6 BUILD.
- Sentence test: n/a (SPIKE).
- Substrate touched: none (investigation + blueprint doc).
- Hash-anchor verification plan: n/a (no code change).

## iter 037 — CONSULT — Round 5 close (CONSULT 003, written) + QUEUE

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 5 (shell legibility), close iter. Blueprint: iter-033-round5-architect.md.
- Mode: CONSULT — done as a written self-pre-mortem (the arc-1/arc-3
  sanctioned fallback), NOT an external /agentify call. Rationale: the
  iter-33 USER PLAYTEST is Round 5's real creative check — a human
  played the actual game and gave concrete findings that drove every
  Round-5 iter; it literally fulfilled CONSULT 002's closing "5-person
  smoke test" recommendation. A frontier CONSULT now would be a weaker,
  redundant second-order check, and its sharpest question ("do the 4
  shells read as economy choices?") is playtest-gated. If Round 6 —
  which runs autonomously, no fresh playtest — needs outside
  perspective, fire a real /agentify CONSULT then.
- CONSULT constraints respected: all 7 (review iter, no design surface).
- Predicted failure: the written self-critique rubber-stamps Round 5
  instead of stress-testing it. Mitigation: the critique MUST surface
  at least one concrete seductive-but-hollow risk and one Round-6
  course-correction, or it has failed its purpose.
- Falsifiable claim: this iter writes CONSULT 003 to creative-consults.md
  (4 questions answered with teeth), appends REVIEW-QUEUE #6, updates
  STATE + LEDGER. No code change → no hash risk. iter 38 bootstraps
  Round 6.
- Sentence test: n/a.
- Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 036 — BUILD-QUALITY — shell codex / run-start tutorial (Round 5)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 5 (shell legibility), piece 3. Blueprint: iter-033-round5-architect.md.
  Answers iter-33 playtest findings 2-3 ("no tutorial" + "I don't
  understand when to use HE vs HEAT vs AP").
- Cap note: this is the 2nd consecutive BUILD-QUALITY (iters 35, 36),
  exceeding the L3/R4 "1 per 3 BUILDs" cap. This is NOT the drift the cap
  guards against. The cap catches score-creep / busywork; here the score
  is flat (Δ 0) and the work is a direct, on-blueprint response to a human
  playtest (F003). The cap fires only because the rubric — written
  pre-playtest — has no integer for legibility, so all of Round 5's
  mandated legibility work scores BUILD-QUALITY. That rubric gap is real;
  it is flagged for the iter-37 Round-5 close.
- CONSULT constraints respected: 1 (the codex is read at a safe gate —
  run start, before any threat; never during combat), 3 (it states each
  shell's readable role), CONSULT 002 (legibility).
- CONSULT constraints risked: none. The codex does NOT pause the tree —
  pausing from PlayerTank._ready would corrupt cross-harness state (the
  Depot owns the pause contract); band 1 (tutorial_choke) is gentle
  enough to read in.
- Predicted failure modes:
  - The codex must be gated on loadout != null — arc-2/3 builds none.
  - The codex must not interfere with the iter-35 ShellPanel or other
    HUD nodes (it is a separate node, "ShellCodex").
  - Dismiss-on-input both hides the codex and acts on the same input the
    same frame — acceptable, standard for intro tooltips.
- Falsifiable claim: post-edit — a new check-breach-codex harness verifies
  a breach PlayerTank builds a visible ShellCodex naming all 4 shells +
  BRICK/STEEL roles, hidden by _dismiss_codex(); arc-2/3 builds none.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 19/19.
- Sentence test: n/a (tutorial overlay, no upgrade).
- Substrate touched: PlayerTank.gd (HUD — sanctioned).
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd seed
  42 — the codex is gated on loadout != null; the procedural baseline
  PlayerTank has no loadout → HUD path bit-identical.

## iter 035 — BUILD-QUALITY — shell UI panel + APCR icon (Round 5 legibility)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 5 (shell legibility), piece 2. Blueprint: iter-033-round5-architect.md.
  Directly answers iter-33 playtest finding 1 ("no shell UI") + finding 3
  (illegible shell roles). Legibility craft — no [STRUCTURE] integer lift
  (the playtest's lift is the [FEEL] tier); BUILD-QUALITY per the iter-29/30
  precedent (depot UI + shell HUD were also BUILD-QUALITY). Last
  BUILD-QUALITY was iter 30 — well within the L3/R4 1-per-3 cap.
- CONSULT constraints respected: 3 (a readable shell relationship needs the
  shell + reserve visible at a glance), 4 (the gen_shell_apcr icon is routed
  through the silhouette-grammar gate before commit), CONSULT 002
  (legibility in <5s).
- CONSULT constraints risked: none.
- Predicted failure modes:
  - The shell panel replaces the iter-30 `_shell_label`; test_breach_hud.gd
    asserts a "ShellLabel" node — it must be rewritten for the new panel
    or it fails.
  - The panel must stay gated on `loadout != null` — arc-2/3 HUD must be
    bit-identical (no panel built, no update branch).
  - The APCR icon must be silhouette-distinct from AP/HE/HEAT or the gate
    rejects it (MIN_SILHOUETTE_DIFF=8, MIN_PALETTE_DIFF=20).
- Scope note: in-flight bullet shape-differentiation (beyond the iter-34
  per-shell modulate colour) is DEFERRED — a sprite-scale change cannot be
  visually verified by a headless loop, and the F003 lesson says do not
  ship an unverifiable visual. The legibility win this iter is the panel +
  colour consistency (chip colours match the Bullet modulate).
- Falsifiable claim: post-edit — `make check-silhouette-gate` passes with
  4 icons; `make check-breach-assets` reports "4 shell icons"; the rewritten
  test_breach_hud verifies a 4-slot ShellPanel reflecting current_shell +
  per-shell reserves + selection highlight, and arc-2/3 PlayerTank has
  none; hash anchor `23d6a2ec3bf2821f` preserved; `make test-all` 5/5;
  `make test-breach` 18/18.
- Sentence test: n/a (UI/asset iter, no upgrade).
- Substrate touched: PlayerTank.gd (HUD — sanctioned). gen_tile.py is
  extendable per PROMPT. check_shell_icons.py / Makefile / test_breach_hud
  are loop tooling.
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd seed 42
  — the panel is gated on loadout != null; the procedural baseline's
  PlayerTank has no loadout, so the HUD path is bit-identical. Verify
  before commit.

## iter 034 — BUILD — APCR 4th shell + steel as a destroyable band pressure

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 5 (shell legibility), piece 1. Blueprint: iter-033-round5-architect.md.
- CONSULT constraints respected: 3 (APCR gets one crisp job — the steel
  breacher — distinct from HEAT's anti-armor burst), 5 (bunker_zone's
  dominant pressure becomes a *specific* climb problem: steel walls
  answered by APCR), 7 (APCR is a verb-shell, not a passive stat).
- CONSULT constraints overridden: 2 ("no more than three shell classes
  at first") — overridden by the user in the iter-33 playtest; recorded
  STATE.md §Arc-4 amendments. APCR is the sanctioned 4th shell.
- Predicted failure modes:
  - Steel is a TileMapLayer in arc-2/3 (Level._replace_blocks converts
    only brick + water). Converting steel → SteelBlock nodes could
    (a) break the hash anchor if the conversion runs on the flag-off
    codepath, or (b) change collision so tanks/bullets pass through.
  - The reachability oracle treats steel as a wall (test_breach_harness
    line 9). APCR makes steel breachable — the oracle must NOT change:
    a band stays playable WITHOUT forced breaching; APCR opens an
    optional faster lane.
  - APCR vs HEAT collapse — if APCR also did burst armor damage it would
    duplicate HEAT. Mitigation: APCR pierces armor at 1× (HEAT 2×);
    APCR's identity is steel terrain, HEAT's is the armored-enemy kill.
- Falsifiable claim: post-edit — hash anchor flag-off codepath =
  `23d6a2ec3bf2821f`; `make test-all` 5/5; `make test-breach` 18/18
  (incl. new check-breach-apcr); the new harness proves APCR breaches a
  SteelBlock and AP/HE/HEAT do NOT, and APCR pierces an armored stub at
  full damage while AP is mitigated to 0. If the hash breaks the iter
  HALTS (correctness violation).
- Sentence test: APCR is a shell, not a depot upgrade — the per-shell
  grammar is the cite: "APCR helps me climb through steel-walled bunkers
  by changing how I use my shell reserve — the only key to a steel lane."
- Substrate touched: Bullet.gd (SHELL_CLASS_APCR + steel-breach +
  armor-pierce — sanctioned, PROMPT §DEFAULT-ON "Bullet.gd multi-shell
  support"), ProceduralLevel.gd (_replace_blocks override, breach-gated
  — sanctioned), PlayerTank.gd (4-shell cycle — sanctioned). Loadout.gd
  + Depot.gd are arc-4-owned (not substrate). SteelBlock.gd/.tscn new.
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd on
  seed 42 / default config; the _replace_blocks override returns after
  super on the flag-off codepath (steel stays a TileMapLayer), so the
  baseline is bit-identical. Verify before commit.

## iter 033 — PLAYTEST — integrate user playtest; F003; bootstrap Round 5

- Date: 2026-05-20
- Tag: [FEEL] (the iter's input is a human playtest — the FEEL tier's
  evidence source; the iter integrates that evidence)
- Round: between rounds. Round 4 closed iter 30; the loop paused iter 32;
  the user playtest re-opens it. This iter integrates the playtest and
  bootstraps Round 5.
- CONSULT constraints respected: all 7 — this is an integration/planning
  iter, no design surface touched. The Round-5 blueprint is written to
  RESPECT them: constraint 1 (tutorial at safe gates, never combat),
  constraint 3 (each shell keeps one readable relationship), constraint 4
  (the APCR icon is silhouette-gated).
- CONSULT constraints risked: constraint 2 ("no more than three primary
  shell classes at first") — the user EXPLICITLY OVERRODE it; APCR is
  sanctioned as the 4th shell. Not a loop violation: the PROMPT grants
  the user override authority over cadence/direction. Recorded in
  STATE.md §Arc-4 amendments.
- Predicted failure: the Round-5 plan may under-scope finding 5 ("doesn't
  feel like a roguelite") — that is a multi-round program, not a Round-5
  piece. Mitigation: Round 5 is explicitly findings 1-4 (legibility);
  finding 5 is bootstrapped as the Round 6+ program in the blueprint tail.
- Falsifiable claim: this iter commits F003 + `iter-033-round5-architect.md`
  + STATE unpaused to `loop_state: RUNNING` + REVIEW-QUEUE #3 closed and
  #5 appended. No code changes → no hash-anchor risk. iter 34 begins the
  Round-5 BUILD.
- Sentence test: n/a (no upgrade this iter)
- Substrate touched: none (loop docs only)
- Hash-anchor verification plan: n/a (no code change)

## iter 030 — BUILD-QUALITY — shell HUD (round-4 piece 2)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 4 (pre-playtest legibility), piece 2. Breach-economy state —
  which shell is selected, how much HE/HEAT reserve remains — is
  currently invisible. A playtester can't see their breach budget. The
  shell HUD surfaces it.
- CONSULT constraints respected: 3 (the readable shell relationship
  needs the shell to be *visible*), CONSULT 002 (legibility)
- CONSULT constraints risked: none
- Predicted failure modes:
  - PlayerTank `_setup_hud` builds a CanvasLayer. The shell label must
    be gated on `loadout != null` — arc-2/3 HUD stays bit-identical
    (no shell label, no `_update_run_hud` shell branch fires).
  - `_update_run_hud` runs each frame (cheap text update).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS (arc-2/3 HUD unchanged —
  no loadout → no shell label), `make test-breach` PASS, new
  `make check-breach-hud` verifies a breach PlayerTank (loadout set)
  has a ShellLabel reflecting current_shell + he/heat reserves, and an
  arc-2/3 PlayerTank (no loadout) has none.
- Sentence test: n/a (HUD)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned; `_setup_hud` + `_update_run_hud` extension, breach-gated).
- Hash-anchor verification plan: post-edit, before commit.

## iter 029 — BUILD-QUALITY — depot UI panel (round-3 close, round-4 open)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- DIAGNOSE: round 3's structural anchors are done (C3/4 + C8/3); C5/3
  is substrate-blocked. The loop is at the 30/50 structural ceiling.
  Per the parity-drift /meta, the playtest is the gate — but a playtest
  is only meaningful if breach mode is LEGIBLE. The depot is currently
  invisible: `Depot.tscn` is an Area2D + a blue marker rect; the
  3-choice upgrade flow (KEY_1/2/3 → apply_choice) has NO on-screen UI.
  CONSULT 002 Q2: depots must be "legible in under five seconds" — they
  aren't legible at all. Round 4 = pre-playtest legibility; iter 29 is
  piece 1: the depot UI panel. This is the bridge to the playtest, not
  grinding past the ceiling.
- Tag rationale: BUILD-QUALITY — a visible depot panel is craft that
  makes the playtest possible but lifts no [STRUCTURE] anchor (C2
  anchors 4-5 are playtest-gated). Last BUILD-QUALITY iter 24; iters
  25-28 were META/AUDIT/BUILD/BUILD — within the 1-per-3 cap.
- CONSULT constraints respected: 1 (depot UI shows only at the
  safe-gate, never during combat — the tree is paused), CONSULT 002 Q2
  (legibility)
- CONSULT constraints risked: depot dwell <30s — the panel must be
  fast-readable; iter 29 ships a compact 4-line panel (hint + 3
  choices). Playtest tunes.
- Predicted failure modes:
  - The panel must be a CanvasLayer (screen-space, not world-space) so
    it renders as HUD regardless of camera. Depot is a world Area2D;
    the CanvasLayer is a child of Depot, shown/hidden on entry/exit.
  - process_mode: the panel's CanvasLayer must run while the tree is
    paused (Depot already has PROCESS_MODE_ALWAYS — children inherit).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  the depot UI panel populates its Labels from choice_a/b/c_label +
  next_band_hint on entry and hides on pick/exit — verified by
  extending `check-breach-depot` or a new harness assertion.
- Sentence test: n/a (UI)
- Substrate touched: none — Depot.tscn + Depot.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 028 — BUILD — OVERDRIVE sprint upgrade (C8 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- DIAGNOSE: round-3 anchor 2. Two candidates — C5 anchor 3 (4th enemy
  role) and C8 anchor 3 (depot catalog covers all 5 band pressures).
  **C5/3 is substrate-blocked** — a genuine 4th role needs an Enemy.gd
  behavior branch, and Enemy.gd is NOT in the sanctioned-write list
  (iter-23 finding); a stat-only variant violates CONSULT constraint 3
  ("no canonical answer = decorative complexity = cut it"). So iter 28
  takes **C8 anchor 3**: the open_killbox band has no depot upgrade —
  its pressure ("wide sightlines, fast scouts, rear-flank patrols";
  answer "facing-aware positioning") has no shell-economy upgrade
  because AP (its answer) is the deliberately-unupgradeable baseline.
  The honest fix: add a *positioning* verb — OVERDRIVE, a sprint burst.
- CONSULT constraints respected: 7 (OVERDRIVE is a movement VERB —
  "burst to break a flanker's sightline" — not a passive +speed%; it
  has a cost: a burst window then a cooldown), 1
- CONSULT constraints risked: 2 — OVERDRIVE is a non-shell upgrade, the
  first one. But it is NOT shell-class bloat (still 3 shells); it is a
  chassis/positioning affordance, which CONSULT 000 §7 explicitly
  endorses ("verbs and affordances"). Acceptable.
- Predicted failure modes:
  - The sprint multiplies `velocity` in `_physics_process` line 195.
    Gated on `loadout != null and loadout.has_overdrive` → arc-2/3
    never sprint → movement bit-identical.
  - Burst→cooldown transition: detect `_overdrive_timer` crossing >0→≤0
    and arm `_overdrive_cd` once.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-overdrive` verifies: OVERDRIVE upgrade sets
  `has_overdrive`; a SHIFT burst (when owned) raises effective speed
  for `overdrive_burst` s then cools down; arc-2/3 PlayerTank never
  sprints. The 7-entry catalog now maps an upgrade to each of the 5
  band pressures (HE-economy / HEAT-economy / positioning / recovery).
- Sentence test: OVERDRIVE passes — "This upgrade helps me climb
  through open killboxes by changing how I use positioning — a speed
  burst to break flanker sightlines."
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd` arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 027 — BUILD — shell-swap reload cost (C3 anchor 4)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 3, anchor 1 of 3. C3 anchor 4 (de-bundled iter 26): "Shell-swap
  has a reload cost (≥0.5s) — pre-commitment under reload pressure".
- CONSULT constraints respected: 7 (the swap cost is a *verb-cost* — a
  pre-commitment beat — not a passive stat; CONSULT 000 §2 named this
  "the interesting WoT idea ... swapping takes a short reload beat"),
  2, 1
- CONSULT constraints risked: none
- Predicted failure modes:
  - The cooldown must be breach-gated: `_cycle_shell` already
    early-returns when `loadout == null`, so `_swap_cooldown` is only
    ever set in breach mode — arc-2/3 `_fire` never sees a nonzero
    cooldown. Bit-identical baseline.
  - `_cycle_shell` arms the cooldown only on a REAL swap (when
    `current_shell` actually changes) — cycling onto the same class
    (all others empty) must not impose a cost.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-swap` verifies: a real `_cycle_shell` arms
  `_swap_cooldown` to `shell_swap_cost` (≥0.5); `_fire` is blocked
  while `_swap_cooldown > 0`; once it elapses `_fire` emits again; an
  arc-2/3 PlayerTank (no loadout) never arms the cooldown.
- Sentence test: n/a (a combat-timing mechanic, not a depot upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write — sanctioned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 026 — AUDIT — de-bundle remaining anchors; sharpen the ceiling

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Trigger: AUDIT cadence (every 5; last iter 21). Also Mismatch-AUDIT
  (L6) — the parity-drift /meta finding flagged that the remaining
  structural anchors are bundled/mis-tagged; this AUDIT de-bundles them
  so round 3 has honest single-clause targets + a sharp ceiling number.
- CONSULT constraints respected: all (process iter)
- Predicted finding: re-score holds at 28/50 (no anchor moved since
  iter 21's AUDIT + the BUILD-QUALITY iter 24). Two anchor rephrases:
  (1) C3 anchor 4 is bundled (swap-cost + per-band-consumption-harness)
  — R1 debt; de-bundle to the swap-cost clause (the CONSULT-core
  mechanic), the consumption-measurement belongs to the [FEEL] tier.
  (2) C4 anchor 4 ("avg shell-mix differs per band — 5-seed harness")
  is mis-tagged [STRUCTURE] — shell-mix can only be measured by
  simulated/real play; re-tag [FEEL]. Net: the true structural ceiling
  is ~32/50 (C3/4 swap-cost + C5/3 4th role + C8/3 band coverage +
  C10/5 arc-close), sharper than the meta's ~8-10 estimate.
- Falsifiable claim: re-score = 28/50 unchanged; RUBRIC.md gets 2
  revision-log rows (C3/4 de-bundle, C4/4 re-tag); LEDGER AUDIT block
  states the ~32/50 structural ceiling. Identity-protected anchors
  (C1/5, C5/5, C7/5, C8/5, C9/5) untouched (R2). Hash anchor untouched.
- Sentence test: n/a
- Substrate touched: none (RUBRIC.md + loop docs)
- Hash-anchor verification plan: n/a

## iter 025 — META + QUEUE — round-2 close; parity-drift finding; playtest surfaced

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Meta-trigger: dice nat-13 /meta nudge (iter 24.5) named PARITY DRIFT
  — 24 iters, 28/50, all structural/harness-cited, zero playtests;
  ~14 of 22 remaining rubric points are playtest-gated by design.
  Round 2 (iters 7-24) is structurally complete; this iter formalizes
  the finding + closes round 2 + surfaces the playtest as critical path.
- CONSULT constraints respected: all (process iter)
- CONSULT constraints risked: none
- Predicted failure: the playtest request, once in REVIEW-QUEUE, sits
  unactioned (arc-1's user-look gate sat open 8 iters). Mitigation:
  PushNotification surfaces it directly; the loop continues round 3
  regardless (non-stop), so a stalled playtest doesn't stall the loop —
  it just caps the reachable score at ~37/50 until the user plays.
- Falsifiable claim: by end of iter, LEDGER has a META entry,
  REVIEW-QUEUE has item #3 (playtest request, prominent), a
  PushNotification fired, round 2 is marked closed, and STATE names
  round 3's opening surface. Hash anchor untouched (no code).
- Sentence test: n/a
- Substrate touched: none (LEDGER / REVIEW-QUEUE / STATE — loop docs)
- Hash-anchor verification plan: n/a

## iter 024 — BUILD-QUALITY — depot rule-changer "Breach Dividend"

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY] — CONSULT 002's #2 recommendation; a
  genuine playstyle-forking depot entry but it does NOT lift a
  [STRUCTURE] rubric anchor (C8 anchor 3 needs all-5-band coverage;
  the build-identity anchors it serves — C1/4-5, C9/3+ — are
  playtest-gated). Honest BUILD-QUALITY per L3/R4. Last BUILD-QUALITY
  was iter 10 — well within the 1-per-3-BUILDs cap.
- CONSULT 002 Q2 verbatim: "Replace one depot entry with a
  rule-changer, not a stock-changer. Breach Dividend — destroying 4+
  bricks with one HE refunds 1 HE ... creates a playstyle: precise
  cluster breaching."
- CONSULT constraints respected: 7 (a rule-changer verb — "cluster
  breaching pays for itself" — not a passive %stat), 1 (depot still
  shows 3-of-N; catalog grows to 6)
- CONSULT constraints risked: 4 — risk of farming (infinite HE from
  repeated cluster-breaches). Mitigation: `refill_he` caps at
  `max_he_reserve` — a dividend can never exceed the reserve cap, so
  it sustains efficient play but can't snowball. The CONSULT's
  "capped once per band" is a stronger guard; deferred (the
  max-reserve cap suffices for iter 24; per-band cap if playtest
  shows farming).
- Predicted failure modes:
  - The refund chain Bullet → get_parent() (the Level) → `.player` →
    `.loadout`. Level.gd has `@onready var player`. If any link is
    null (defensive duck-typed reads), the dividend silently no-ops.
  - "4+ bricks" count: `_apply_he_blast` returns radius-sibling count;
    total = radius + 1 (primary). In a brick maze the primary IS a
    brick; counting the primary unconditionally is a slight
    over-count if the HE shot's primary hit is an enemy — acceptable
    (the dividend is about cluster breaching; an HE shot that opens a
    4-tile lane qualifies regardless of what the centre cell was).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-dividend` verifies: HE blast of ≥4 bricks
  with breach_dividend ON → he_reserve +1 (capped at max); same blast
  with breach_dividend OFF → no refund; HE blast of <4 bricks → no
  refund even with the upgrade on.
- Sentence test: BREACH_DIVIDEND passes — "This upgrade helps me
  climb through brick mazes by changing how I use HE — precise
  cluster breaches refund their own shell."
- Substrate touched: `scripts/Bullet.gd` (substrate write — Bullet's
  4th; sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd`
  arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 023 — BUILD — HEAT armor-bypass (C3 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 ADOPTED. Its #1 "next 3 iters" recommendation: "make
  HEAT real with one armor-facing/bypass rule" — Q3's
  stupid-in-6-months omission ("'2× damage' is a placeholder").
- CONSULT constraints respected: 3 (every enemy type gets a readable
  shell relationship — armored Heavy now MECHANICALLY demands HEAT),
  2 (still 3 shells), 7 (HEAT becomes a verb-with-a-rule, not "+N%")
- CONSULT constraints risked: 1 — armored Heavy is HEAT-only; a
  HEAT-starved player meeting an armored Heavy is genuinely stuck on
  that enemy. That IS the breach-economy tension (death recap names
  "ran out of HEAT") — but if it softlocks (cornered, no escape) it's
  bad. Mitigation: armored enemies are killable-by-avoidance (the
  player can route around — they're not lane-blockers by terrain) and
  AP/HE still kill all non-armored roles.
- **Substrate investigation** (PROMPT §DEFAULT-ON "any other substrate
  write = halt+investigate"): HEAT-armor needs an enemy-side "armored"
  marker. Enemy.gd is Layer-2 substrate NOT in the sanctioned list
  (PlayerTank/ProceduralLevel/Spawner/Bullet). **Resolution: avoid the
  Enemy.gd touch entirely** — use a Godot group tag. Spawner.gd
  (sanctioned) calls `enemy.add_to_group("armored")` for Heavy types;
  Bullet.gd (sanctioned) checks `body.is_in_group("armored")`.
  `add_to_group` is a Node method — no Enemy.gd script property
  needed. Both substrate writes are on the sanctioned list. No
  halt-and-investigate needed; no Enemy.gd write.
- The armor rule (brutally simple, per CONSULT): armored enemies take
  `max(0, deal − ARMOR_MITIGATION)` from AP/HE; HEAT ignores armor
  (full `deal`). ARMOR_MITIGATION = 1; Heavy base-damage-1 AP/HE →
  0 (blocked), HEAT 2× → 2 (one-shots Heavy's 2 HP). Player learns:
  "armored = HEAT".
- Predicted failure modes:
  - Spawner sets enemy params via `enemy.set(...)`; `add_to_group`
    is a different call — must be placed in the same pre-add_child
    block. Heavy ENEMY_TYPES entry needs an `"armored": true` key.
  - take_damage(0) on an armored enemy hit by AP — harmless (hp -= 0),
    impact spark still fires = readable "armor blocked it" feedback.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-armor` verifies an "armored"-group stub takes
  0 from AP + 0 from HE + full (2×) from HEAT, and a non-armored stub
  takes full from all 3.
- Sentence test: n/a (combat mechanic, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #11 —
  sanctioned), `scripts/Bullet.gd` (substrate write — Bullet's 3rd;
  sanctioned). NO Enemy.gd touch (group-tag approach).
- Hash-anchor verification plan: post-edit, before commit.

## iter 022 — BUILD — 3 depots at band transitions (C2 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 still running at iter-22 start (~7 min in). Per PROMPT,
  no AWAIT for design — proceeding with a CONSULT-safe, substrate-clean
  BUILD; iter 23 reads the consult.
- DIAGNOSE: C2 (field depot) at 2/5. Anchor 3: "Depots placed at
  deterministic intervals (e.g. every band); harness verifies a full
  run hits ≥3 depots — code-cited". BreachLevel.tscn has 1 depot.
- CONSULT constraints respected: 1 (depots are the safe-gate cadence —
  one per band transition), 6 (depots = clean band-segmentation points)
- CONSULT constraints risked: none — adding depots is CONSULT-endorsed
  ("field depots at fixed/semi-fixed depth intervals")
- Predicted failure modes:
  - BreachLevel.tscn is an inherited scene — adding 2 more Depot child
    nodes must use unique `index` values + node names. If indices
    collide, the scene won't load.
  - Depot world-y placement: depth N → y = 232 - N×16. Band exits at
    depth 30/70/120 → y -248/-888/-1688. A depot placed beyond the
    generated/reachable region would be a dead node — acceptable for
    the structural cite (the harness counts depot children, not
    in-run reachability of each).
- Falsifiable claim: post-edit, BreachLevel.tscn loads clean,
  `make check-breach-level` reports ≥3 depots, `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS, `make
  test-breach` PASS.
- Sentence test: n/a (depot placement)
- Substrate touched: none — BreachLevel.tscn is an arc-4-owned scene;
  test_breach_level.gd arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved (the
  base ProceduralLevel.tscn is untouched).

## iter 021 — AUDIT + CONSULT — re-score + fire CONSULT 002

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Triggers: AUDIT (every-5 cadence; last iter 16) + CONSULT (~every-10;
  last iter 6).
- CONSULT constraints respected: all (process iter)
- Predicted finding: the rolling 25/50 is honest, but C7 anchor 3
  ("All new assets in arc 4 verified via the grammar gate before
  commit — log artifact in LEDGER") was conservatively HELD at iter 18
  ("one asset-set is thin evidence"). On AUDIT re-read, anchor 3 has no
  minimum-count clause — all 3 arc-4 generated assets (shell icons) ARE
  gated + the iter-18 LEDGER logs the SILHOUETTE_GATE_PASS artifact.
  Expect C7 2→3 (the iter-18 hold was an under-claim; AUDIT corrects).
  Total → 26/50. No over-claims expected.
- Falsifiable claim: the AUDIT re-score changes at most C7 (2→3); all
  other 9 criteria hold. CONSULT 002 fires fire-and-forget; queryId
  recorded to creative-consults.md regardless of tab status.
- Sentence test: n/a
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit)

## iter 020 — BUILD — depot upgrade catalog → 5 (C8 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C8 (sentence-test compliance) at 1/5 is joint-lowest.
  Anchor 2: "5+ upgrades; all pass; sentence cited verbatim per
  upgrade — Loadout.gd documents". Have 3 (HE_REFILL_2 / HEAT_REFILL_1
  / HE_MAX_EXPAND_2) — need 5+.
- CONSULT constraints respected: 7 (verbs/affordances not passive
  stats — the 2 new upgrades are economy verbs: HEAT capacity expand +
  full resupply, NOT "+%damage"), 1 (catalog grows; depot still shows
  3-at-a-time — no scrolling), 2 (still 3 shell classes)
- CONSULT constraints risked: 4 — 5 refill/expand variants risk
  reading as "reserve stat soup". Honest mitigation: reserve size +
  resupply are CONSULT-§2-endorsed depot upgrade axes ("Depot upgrades
  improve swap speed or reserve size"); they ARE the breach economy's
  currency, not passive %stats. Genuinely-different affordance
  upgrades (swap-speed, refund-on-kill, first-shot-pierce) need
  mechanics not yet built (swap cost, kill hooks) — scheduled later,
  not faked now.
- Predicted failure modes:
  - UpgradeKind enum 3→5 + apply_upgrade extraction — the harness must
    exercise all 5 enum values. test_breach_depot_choice currently
    tests 3.
  - "Loadout.gd documents" — the catalog enum lives in Depot.gd; I add
    a documentation block to Loadout.gd citing the 5 verbatim
    sentences (the anchor's named location).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  `make check-breach-depot-choice` verifies all 5 UpgradeKind values
  apply distinct loadout effects. All 5 upgrades pass the sentence
  test (cited verbatim in this pre-mortem + Loadout.gd).
- Sentence tests (all 5, verbatim):
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells."
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands
    by changing how I use HEAT shells."
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required stretches by changing how I use my HE economy."
  - HEAT_MAX_EXPAND_2: "This upgrade helps me climb through deep
    bunker chains by changing how I use my HEAT economy."
  - FULL_RESUPPLY: "This upgrade helps me climb through the band after
    an over-spend by changing how I use a recovery beat."
  All 5 are "changing how I use <resource/verb>" — none is "by making
  me stronger" or "+N%". Pass.
- Substrate touched: none — Depot.gd + Loadout.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 019 — BUILD — per-role canonical answers (C5 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C5 (enemy role vocabulary) at 1/5 is the lowest criterion.
  C5 anchor 2: "Each role has a documented 'canonical answer'
  shell+positioning in BANDS.md; harness verifies presence in band
  rosters — code-cited". Two clauses (R1): (a) BANDS.md documents a
  shell+positioning answer per role; (b) a harness verifies each role
  appears in ≥1 band roster.
- CONSULT constraints respected: 3 (every enemy type must have a
  readable shell/positioning relationship — this iter is the literal
  documentation of that), 5
- CONSULT constraints risked: 3 — the canonical answer is *documented*,
  not yet *enforced* in code (no enemy demands a specific shell to
  kill). Honest: C5 anchor 2 is a documentation+coverage anchor;
  mechanical enforcement is later (would need armor/HEAT-bypass — also
  C3 anchor 3 territory).
- Predicted failure modes:
  - Roster coverage: a role with no band could fail clause (b).
    Current rosters — Light in all 5, Heavy in 2, Fast in 3 — all 3
    roles covered. Low risk; the harness makes it explicit.
  - No substrate touch — BANDS.md is a doc, the harness is arc-4-owned.
- Falsifiable claim: post-edit, BANDS.md has a per-role canonical-answer
  section for Light/Heavy/Fast (shell + positioning each), and
  `make check-breach-enemies` additionally verifies all 3 roles appear
  in ≥1 band roster. `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS.
- Sentence test: n/a (enemy doc)
- Substrate touched: none (BANDS.md doc + test_breach_enemies.gd
  arc-4-owned harness).
- Hash-anchor verification plan: n/a (no code/config edit) — verify
  anyway.

## iter 018 — BUILD — C6 anchor 3 (recap band pressure) + C7 anchor 2 (grammar gate)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Two cheap lifts bundled:
  - **C6 anchor 3**: "Recap includes build identity tag + dominant
    pressure of killing band — code-cited". RunRecap already has
    build_tag() (✓ identity) + killing_band NAME. Gap: the band's
    `dominant_pressure` text. Fix: capture_death takes the BreachBand
    object (not just name) → store `killing_pressure`.
  - **C7 anchor 2**: "Silhouette-grammar check exists in
    analyze_frame.py or sibling tool; outputs PASS/FAIL — code-cited".
    Promote the iter-17 distinctness logic into a reusable
    `tools/silhouette_gate.py` gate (PASS/FAIL on any PNG set);
    check_shell_icons.py uses it.
- CONSULT constraints respected: 6 (recap now names the route pressure
  that killed the run — "steel-armored bunkers", not "got
  overwhelmed"), 4 (the grammar gate is now a reusable tool, not a
  one-off — future assets pass through it)
- CONSULT constraints risked: none
- Predicted failure modes:
  - capture_death signature change (band_name String → BreachBand
    object) — 3 call sites: PlayerTank._die, test_breach_recap.gd.
    Both must update atomically.
  - PlayerTank substrate write #10 — _die's capture_death call.
    Gated on run_recap != null (breach mode only) — arc-2/3 untouched.
  - silhouette_gate.py refactor — check_shell_icons.py must still
    report BREACH_ASSETS_OK.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS
  (check-breach-recap now also verifies killing_pressure;
  check-breach-assets routes through silhouette_gate.py), new
  `make check-silhouette-gate` reports `SILHOUETTE_GATE_PASS`.
- Sentence test: n/a
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #10 —
  _die capture_death call; gated). `scripts/RunRecap.gd` (arc-4-owned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 017 — BUILD — gen_tile.py shell-icon generator (C7 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C7 (silhouette grammar) is the only 0/5 criterion — the
  weakest axis. C7 anchor 1: "gen_tile.py extended with ≥1 new
  generator (depot tile / shell icon / chassis variant) — code-cited".
- CONSULT constraints respected: 4 (silhouette grammar — the 3 shell
  icons are designed to be readable by silhouette + palette: AP = narrow
  dart / pale, HE = fat ellipse / warm yellow, HEAT = angular diamond /
  crimson; palettes match the Bullet.gd iter-4/7 modulate colors), 2
  (still 3 shell classes — icons for exactly AP/HE/HEAT)
- CONSULT constraints risked: 4 — the FORMAL silhouette-grammar check
  tool is C7 anchor 2 (a later iter). iter 17 cites the grammar gate
  *manually* + the verifier proves the 3 icons are pixel-distinct
  (silhouette-distinct proxy). Honest: anchor 2's automated PASS/FAIL
  tool is scheduled, not done.
- Predicted failure modes:
  - PIL drawing at 8×8 is cramped — the 3 silhouettes could end up
    too similar (fail the distinctness check). Mitigation: verifier
    asserts pairwise pixel-difference above a threshold.
  - gen_tile.py is Layer-1 substrate ("extendable for new procedural
    generators" — explicitly sanctioned). Extension must not break the
    existing 4 terrain generators.
- Falsifiable claim: post-edit, the existing `make` terrain-gen path
  still works, the 3 shell icons generate as valid 8×8 PNGs, and the
  new `make check-breach-assets` reports `BREACH_ASSETS_OK` with the 3
  icons verified pairwise pixel-distinct. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f` (gen_tile.py is a build-time tool —
  doesn't touch the runtime hash anyway), `make test-all` PASS.
- Sentence test: n/a (asset generator)
- Substrate touched: `tools/gen_tile.py` (Layer-1 — extension
  explicitly sanctioned by PROMPT §SUBSTRATE FREEZE "gen_tile.py
  (extendable for new procedural generators)").
- Hash-anchor verification plan: gen_tile.py is a build-time Python
  tool; it does not run during `make test`. Hash anchor trivially
  preserved — verify anyway.

## iter 016 — AUDIT — re-score all 10 criteria + resolve C1-anchor-2 wording

- Date: 2026-05-19
- Tag: [STRUCTURE]
- AUDIT trigger: PROMPT cadence "every 5 iters" — 16 iters since the
  iter-0 baseline, no AUDIT yet. Also a Mismatch-AUDIT trigger (L6):
  C1 anchor 2's "via Loadout.gd permutations" wording doesn't match
  the actual mechanism (RunRecap.build_tag).
- CONSULT constraints respected: all (process iter, no design surface)
- CONSULT constraints risked: none
- Predicted finding: the rolling score (19/50) is mostly honest, but
  C10 anchor 4 ("Same through iter 15+; ≥3 sanctioned substrate writes
  — all verified") became satisfiable once we crossed iter 15 — a
  legitimate Surrogate-AUDIT lift. Expect C10 3→4, total → 20/50.
- Falsifiable claim: the AUDIT re-score, done criterion-by-criterion
  against the 10 green harnesses + LEDGER evidence, changes at most
  C10 (3→4); all other criteria hold their iter-15 scores. RUBRIC.md
  C1 anchor 2 is rephrased (citation clause only — score unchanged).
  Identity-protected anchors (C1/5, C5/5, C7/5, C8/5, C9/5) are NOT
  touched (R2).
- Sentence test: n/a
- Substrate touched: none. `loop/breach/RUBRIC.md` revision (anchor
  rephrase + revision-log row).
- Hash-anchor verification plan: n/a (no code edit).

## iter 015 — BUILD — band-aware enemy roster (C5 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Discovery: arc-2 Spawner.gd ALREADY has 3 distinct enemy roles
  (Light = rare-fire lane-invader, Heavy = paused-aim corridor-denier,
  Fast = continuous-fire harasser) + a `DEPTH_BANDS` table with
  per-band `type_weights`. C5 anchor 1's "≥3 enemy roles" is already
  satisfied; the gap is "each spawns in correct bands per **BreachConfig**"
  (arc-2 uses its own DEPTH_BANDS, not the arc-4 5-band BreachConfig).
- CONSULT constraints respected: 3 (each enemy role has a readable
  shell/positioning answer — the 3 roles are behaviorally distinct), 5
  (each band's enemy pressure is now declared per BreachBand)
- CONSULT constraints risked: 3 — the canonical shell answer per role
  isn't yet *enforced* (no role demands a specific shell). Honest gap;
  C5 anchor 2 ("documented canonical answer per role") is later work.
- Predicted failure modes:
  - Spawner substrate write #9 — `_pick_enemy_type()` gets a 3rd branch
    (breach). It must be gated: arc-2 procedural + arc-3 OG paths
    unchanged → hash anchor preserved.
  - Spawner reads the band via `get_parent()` → level →
    `_current_breach_band`. If the level isn't breach mode, the breach
    branch must no-op and fall through to DEPTH_BANDS.
  - BreachBand.enemy_weights Dictionary in .tres — typed-Dictionary
    .tres syntax could be fiddly; use untyped Dictionary.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2 procedural unaffected — Spawner breach
  branch gated off), `make test-all` PASS (arc-3 OG Spawner path
  unchanged), `make test-breach` PASS, new `make check-breach-enemies`
  reports `BREACH_ENEMIES_OK` verifying all 5 bands declare non-empty
  enemy_weights with valid role names + Spawner picks band-appropriate
  types in breach mode.
- Sentence test: n/a (enemy roster, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #9 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "Spawner.gd — band-aware
  spawning if iter-1 chooses path A"; gated breach branch).
  `scripts/BreachBand.gd` (add enemy_weights field — arc-4-owned, not
  substrate). `configs/breach_default.tres` (populate weights).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  Spawner substrate touch.

## iter 014 — BUILD — RunRecap.gd death attribution (C6 anchors 1+2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 000: death attribution is the "paired omission" alongside
  depots. Constraint 6: "every run produces a death reason tied to
  resource/build/route — not 'got overwhelmed'."
- CONSULT constraints respected: 6 (death recap is the literal subject),
  7 (recap reports verbs/resources — shells fired, reserves — not a
  generic score)
- CONSULT constraints risked: none — the recap is a safe-state surface
- Predicted failure modes:
  - PlayerTank substrate write #8: `_fire` + `_die` hooks. The recap
    must be created only in breach mode (`loadout != null`) so arc-2/3
    PlayerTank behaves bit-identically (no recap, no hooks fire).
  - RunRecap as RefCounted — PlayerTank owns it internally (no @export
    needed; fresh instance per run avoids Resource-sharing staleness).
  - Killer attribution: `take_damage(amount)` carries no source.
    Mitigation — capture the killing *band* (route attribution, which
    is what constraint 6 actually wants) by reading the parent level's
    `_current_breach_band`; killer string is "shell impact" generic.
    Honest: route+resource attribution is the real signal, not the
    sprite that landed the hit.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2/3 PlayerTank with loadout==null runs the
  recap-free path), `make test-all` PASS, all 8 breach harnesses PASS,
  new `make check-breach-recap` reports `BREACH_RECAP_OK` verifying
  RunRecap captures depth + killing band + per-type shell counts +
  reserves + formats a non-empty recap string.
- Sentence test: n/a (recap, not an upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #8 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"; gated on loadout != null). New file:
  `scripts/RunRecap.gd`.
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  PlayerTank substrate touch.

## iter 013 — BUILD — extend breach_default.tres to 5 bands (C4 anchor 3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band a specific climb problem
  — band 4 open killbox = sightline pressure, band 5 endgame = composed
  pressure), 7
- CONSULT constraints risked: 5's reachability flip-side — F001 lesson:
  new band configs must be reachability-verified, not eyeballed. Band 5
  (endgame_mixed) carries steel — the bunker-zone failure mode could
  recur.
- Predicted failure modes:
  - Band 5 (endgame_mixed) has steel ~0.16 + brick ~0.26 — could fail
    the per-band oracle multi-seed like bunker_zone did pre-retune.
    Mitigation: verify via the 10-seed sweep; retune within-iter.
  - Band 4 (open_killbox) is high-empty — should be trivially
    reachable; the risk is the OPPOSITE (too empty = no climb problem),
    but that's a feel concern, not a reachability one.
  - .tres load_steps must cover the 4 new sub_resources.
- Falsifiable claim: post-edit, all 5 bands pass the per-band
  reachability oracle on ≥80% of a 10-seed sweep (the codified floor).
  `make check-breach-config` reports 5 bands. `make
  check-breach-harness` (deep, seed 42) reports all 5 reachable.
  `make test` exit 0, `tile_hash` = `23d6a2ec3bf2821f`, `make
  test-all` PASS.
- Sentence test: n/a (band config, no upgrade)
- Substrate touched: none — `configs/breach_default.tres` (not
  substrate) + `loop/breach/BANDS.md` (doc).
- Hash-anchor verification plan: post-edit; config-only change, flag-off
  codepath untouched — trivially preserved, verify anyway.

## iter 012 — CAPABILITY — deep-climb reachability harness (bands 2+3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CAPABILITY justification (PROMPT MODE table — "must justify against a
  rubric axis"): the deep-climb harness is the §REACHABILITY FLOOR
  verification tool for C4. Without it, C4 anchor 2's reachability
  caveat (bands 2+3 unverified, F001) can't close, and C4 anchor 3
  ("5 bands … reachability passes on all — harness-cited") is
  unreachable. This iter directly unblocks C4.
- CONSULT constraints respected: 5 (verifies each band is a *playable*
  climb problem, not an impassable wall), 6 (harness is a clean
  band-level segmentation point for metrics)
- CONSULT constraints risked: none — verification tooling
- Predicted failure modes:
  - The climb mechanism (programmatically advancing player.position.y)
    must stay in step with ProceduralLevel._process generation (1 row
    per frame). If the player climbs faster than generation, it
    outruns the generated grid. Mitigation: climb 1 grid_size/frame.
  - F001 strongly predicts bands 2+3 will FAIL on first deep run —
    brick_maze + bunker_zone were softened blind in iter 11. If they
    fail, retune within-iter (PROMPT §HALT — reachability fail must be
    fixed same iter).
  - Node count: ~150 rows × multiple BrickBlocks/row = thousands of
    nodes over the climb. Headless should handle it; if slow, reduce
    climb depth or sample.
- Falsifiable claim: post-edit, the deep-climb harness reports, per
  seed, whether the spawn flood-fill frontier crosses each band's
  depth_max. By end of iter, bands 1/2/3 ALL report
  `playable: true` / chain-reachable across ≥5 seeds (1/7/42/100/333) —
  retuning band configs within-iter if any fail. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS.
- Sentence test: n/a (CAPABILITY iter)
- Substrate touched: none — `loop/breach/test_breach_harness.gd` is
  arc-4-owned (extend freely). `configs/breach_default.tres` may be
  retuned (not substrate).
- Hash-anchor verification plan: post-edit (only if breach_default.tres
  retuned — config changes don't touch the flag-off codepath, so
  trivially preserved; verify anyway).

## iter 011 — BUILD — wire depth-band terrain selection + 3rd band

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band has a dominant terrain
  pressure — now ENFORCED at generation time, not just declared in
  config: `_active_config` routes per-band LevelConfig into row
  generation), 7 (no stats — terrain pressure is a climb problem, not
  a number)
- CONSULT constraints risked: 5's reachability flip-side — if a band's
  LevelConfig is too dense (e.g. bunker_zone steel-heavy), the
  procedural layout could become impassable. RUBRIC C4 reachability
  floor caps C4 at 0 if any band fails. Mitigation: keep band configs
  gentle (empty_weight ≥ 0.12); a formal per-band reachability oracle
  is a scheduled CAPABILITY iter (12+) — C4 anchor 3 is gated on it.
- Predicted failure modes:
  - `_active_config` is called during BOTH `_ready` initial generation
    AND `_process` climbing generation. The breach branch must not
    break the flag-off path — when `breach_mode_enabled == false` the
    branch is skipped entirely → hash anchor `23d6a2ec3bf2821f` stays.
  - Row→depth mapping: `rows_climbed = (height/grid_size) - row`. If
    the sign is inverted, bands map backwards (player starts in band 3).
    Will verify the starting area resolves to band 1.
  - Breach band lookup per-row is O(bands) — 3 bands, negligible.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` (procedural baseline flag-off — breach branch
  skipped) AND `make test-all` PASS AND `make test-breach` PASS (all 7
  harnesses; check-breach-config now sees 3 bands) AND BreachLevel
  still instantiates clean over 30 frames.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (substrate write #7 —
  fills the iter-2 `_init_breach_mode` / `_process_breach_depth` stubs;
  extends `_active_config` with a breach branch. Sanctioned per PROMPT
  §SUBSTRATE FREEZE path A. The breach branch is gated on
  `breach_mode_enabled` — default-on gating template preserved).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  `_active_config` is on the RNG-feeding generation path; the breach
  branch MUST be flag-gated so flag-off stays bit-identical.

## iter 010 — BUILD — BreachLevel.tscn (first end-to-end breach scene)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 structurally — this iter wires
  the integration scene that lets all prior pieces (flag, BreachConfig,
  shells, Loadout, Depot) exist together in one playable surface
- CONSULT constraints risked: 5 — band-aware procedural generation
  still not wired (`_init_breach_mode` / `_process_breach_depth` stubs
  remain empty); BreachLevel generates terrain identically to arc-2
  procedural for now. The depth-band *experience* lands iter 11+ when
  the stubs route `breach_config` into per-row LevelConfig selection.
- Predicted failure modes:
  - Inherited-scene .tscn syntax: Godot 4.6 inherited scenes use
    `[node name="X" instance=ExtResource("base")]` on the root +
    child-override nodes by path. If the syntax is wrong, the scene
    won't load. Mitigation: keep it minimal; test load immediately.
  - The root node of ProceduralLevel.tscn is named "ProceduralLevel";
    inherited scene can rename to "BreachLevel". Child-override paths
    (`PlayerTank`) must match the base scene's node names exactly.
  - Depot placed at a fixed world-y may sit below/above the climbable
    region — depot reachability matters. For iter 10, depot is a
    *placement smoke test*, not yet a tuned band-transition gate.
- Falsifiable claim: post-edit, `make test` exit 0 (ProceduralLevel.tscn
  untouched) AND `tile_hash` = `23d6a2ec3bf2821f` AND `make test-all`
  PASS AND all 6 prior breach harnesses PASS AND new
  `make check-breach-level` reports `BREACH_LEVEL_OK` with: BreachLevel
  instantiates, `breach_mode_enabled == true`, `breach_config != null`,
  PlayerTank has a non-null loadout, ≥1 Depot child present, no script
  errors over 30 frames.
- Sentence test: n/a (integration iter, no new upgrade)
- Substrate touched: none — BreachLevel.tscn is a NEW inherited scene;
  ProceduralLevel.tscn / .gd untouched. configs/breach_starter_loadout
  .tres is new. The hash anchor is trivially preserved (the procedural
  baseline scene is byte-identical).
- Hash-anchor verification plan: post-edit, before commit.

## iter 009 — BUILD — Depot 3-choice upgrade catalog + next-band preview

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 Q2 implication: "Two-choice depot whose options are
  legible in under five seconds and both answer the last/next breach
  problem. No scrolling, no build tree, no stat salad." Going with **3
  choices** (still legible in <5s, lifts C2 anchor 2's "≥3 meaningful
  upgrade choices" cleanly without AUDIT-rephrase). Three is the
  smallest count that hits anchor 2 while still respecting the
  "no-scrolling, no-build-tree" CONSULT guidance.
- CONSULT constraints respected: 1 (no combat-modal — depot is the
  *safe gate* per design; key-based pick is fast), 7 (verbs not stats —
  each upgrade is an *action verb*: "refill HE", "refill HEAT", "expand
  HE capacity"; no passive +%damage cards). Sentence test: each upgrade
  must pass — verified inline in the pre-mortem below.
- CONSULT constraints risked: 1's flip-side — 30s depot dwell budget.
  Iter 9 ships no dwell timer; the harness verifies pick is *possible*
  in 1 frame. Iter 10+ adds enforcement if playtest reveals drag.
- Sentence tests per choice:
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells" ✓
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands by
    changing how I use HEAT shells" ✓
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required runs by changing how I use my shell economy" ✓
  - All three pass.
- Predicted failure modes:
  - Input-during-pause: Godot 4 still processes `Input.is_*` polls in
    nodes with PROCESS_MODE_ALWAYS even when tree is paused. Depot
    already sets PROCESS_MODE_ALWAYS (iter 5). Choice picks should fire.
  - Resource reference race: storing player.loadout on entry then
    accessing on pick — if player despawns mid-pause, loadout reference
    could be stale. Mitigation: null-check before apply.
  - Depot.tscn layout: 4 Label nodes need positioning. Simple Control
    container with VBoxContainer keeps it bounded.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND all 5 prior breach
  harnesses PASS AND new `make check-breach-depot-choice` reports
  `BREACH_DEPOT_CHOICE_OK` with all 3 choice picks verified
  (HE refill, HEAT refill, HE max expand).
- Substrate touched: none (extending existing arc-4 file Depot.gd +
  scene Depot.tscn). C2 anchor 2 target.
- Hash-anchor verification plan: post-edit, before commit. Trivially
  preserved (no engine/gameplay-substrate touch).

## iter 008 — BUILD — Loadout.gd + finite HE/HEAT reserves + shell-cycle input

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 (now returned despite tab timeout — documented arc-4
  behavior): **"no player has yet sacrificed one resource to alter one
  route. That is the atomic verb."** This iter wires that verb.
- CONSULT constraints respected: 1 (no combat-modal — shell cycle is a
  key tap, not a menu), 2 (≤3 classes), 3 (each shell already has a
  readable answer from iter 7; iter 8 adds the *commitment cost*),
  7 (verbs not stats — Loadout's `he_reserve` is a finite resource the
  player *spends*, not a passive +damage stat)
- CONSULT constraints risked: 1 — shell-cycle key chosen as raw KEY_TAB
  (no InputMap action added; project.godot stays untouched). If TAB
  conflicts with anything, will refactor to an InputMap action in
  iter 9+. Mitigation acceptable for iter 8 minimum scope.
- Predicted failure modes:
  - Signal arity mismatch: extending `shoot` to emit shell_class breaks
    any existing handler that expected 3 args. Level.gd handler must
    update in the same commit (substrate write #6).
  - Hash anchor: Level.gd and PlayerTank.gd both touched. Procedural
    `make test` doesn't fire bullets in the 120-frame window (no input
    simulated) so the new signal path doesn't engage; anchor preserved.
  - OG mode regression: arc-3 OriginalLevel.gd extends Level.gd; the
    new 4-arg signal handler must work for OG too. PlayerTank default
    current_shell = AP + loadout = null means OG fires AP bullets via
    the same path. Will be verified via `make check-chain-25` (full
    arc-3 chain).
  - Loadout cross-script type: same preload-alias pattern needed
    (arc-1 LevelConfigT precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND ALL 4 prior breach
  harnesses PASS AND new `make check-breach-loadout` reports
  `BREACH_LOADOUT_OK` with: (a) PlayerTank.loadout default null →
  arc-2 baseline preserved, (b) loadout set + HE fire → he_reserve
  decremented, (c) loadout set + HE fire at he_reserve=0 → fallback
  to AP, no decrement.
- Sentence test: applies. Loadout is the substrate for upgrades
  (depots refill it). The first upgrade card eligible to cite C8:
  "This upgrade helps me climb through brick mazes by changing how I
  use HE shells" — depot offers "+3 HE reserves" or similar. Iter 9.
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #5 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"), `scripts/Level.gd` (substrate write #6 —
  necessary for shell signal extension; same gating discipline applies
  even though Level.gd isn't named in §SUBSTRATE FREEZE — it's an arc-1
  Layer-1 file. Will use default-on gating: 4th signal arg has a
  sensible default routing).
- Hash-anchor verification plan: post-edit, before commit. Mandatory.

## iter 007 — BUILD — Bullet.gd shell-class combat behaviors (HE blast + HEAT 2x)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 2 (still 3 shell classes, no fourth),
  3 (HE has a readable shell relationship → bricks crack into rubble;
  HEAT has a readable relationship → 2x damage; AP cheap+precise stays
  the default), 7 (verbs not stats — HE is an *affordance* "creates lane
  through brick clusters", not "+18% splash damage"; HEAT is a *verb*
  "doubles damage on hit", not a passive multiplier)
- CONSULT constraints risked: constraint 5 — without depth-band
  enemy/terrain mapping wired, HEAT 2x doesn't yet pair with heavy
  bunkers. Honest scaffolding: HE behavior is the load-bearing one
  (breach economy = "spending shells to open vertical lanes"); HEAT 2x
  is the simplest distinct-behavior cite for anchor 2 closure
- Predicted failure modes:
  - HE blast radius via sibling iteration may scan too many nodes if
    bricks are deeply nested → perf hit. Mitigation: cap by distance
    check; arc-2 procedural's brick count is ≤350.
  - Hash anchor risk: `make test` runs procedural baseline for 120
    frames. If procedural baseline ever fires AP bullets that touch
    bricks, the HE-radius behavior changes outcomes only via shell_class
    routing — AP default preserves arc-2 path bit-identically. Should
    be safe but verify.
  - Harness must construct stub `BrickBlock`-like nodes with
    `take_damage` and spatial positions; SceneTree subclass + await
    process_frame pattern (arc-3 precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-{config,shells,depot}` PASS AND new
  `make check-breach-he-blast` reports `BREACH_HE_BLAST_OK` with HE
  bullet destroying ≥2 stub bricks in cluster + HEAT bullet dealing
  2x damage to single stub body + AP bullet dealing 1x baseline.
- Sentence test: applies — does HE behavior pass?
  *"This upgrade helps me climb through brick mazes by changing how I
  use HE shells."* — YES (HE-leaves-rubble-via-radius is the literal
  text of CONSULT §4 example "good upgrade")
- Substrate touched: `scripts/Bullet.gd` (substrate write #4 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; same file as iter 4 — chosen
  path, refined)
- Hash-anchor verification plan: post-edit, before commit. Defensive
  check is mandatory because Bullet.gd is a Layer 2 substrate file
  fired by both player (proc baseline) and enemies (Spawner).

## iter 006 — META + CONSULT — round 1 close + round 2 bootstrap

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat-modal UI added this iter),
  3 (no enemy without canonical answer added), 4 (no asset gen added)
- CONSULT constraints risked: none — META/process iter, no design surface
- Predicted failure: /agentify CONSULT may timeout/error like the
  arc-4 design consult did (per `creative-consults.md` consult 000).
  Mitigation: capture the queryId regardless of tab status; arc-4 has
  explicit documented protocol that tab-timeout ≠ consult-failed (the
  conversation may have completed). Next iter checks back.
- Falsifiable claim: by end of this iter, (a) a CONSULT attempt is
  recorded in `loop/breach/creative-consults.md` with queryId + status;
  (b) a round-1 finding lands in `loop/breach/REVIEW-QUEUE.md` per L3
  pattern; (c) STATE.md next_action names a concrete iter-7 BUILD or
  SPIKE target for round 2. Hash anchor preserved (no code touched).
- Sentence test: n/a (META iter)
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit). Trivially preserved.

## iter 005 — BUILD — Depot.gd + Depot.tscn + pause-on-entry

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 1 (no upgrade choices during
  active combat — depot's pause-on-entry is the *load-bearing* mechanism
  protecting this), constraint 6 (depot is a natural segmentation point
  for death recap / pre/post-band metrics — schema sets this up)
- CONSULT constraints risked: constraint 1's flip-side — depot dwell
  must stay <30s; the rubric anti-pattern for C2 is depot dwell >30s.
  This iter doesn't yet implement upgrade choice flow, so dwell is
  unbounded by design (just walk in/out). Iter 6+ adds the choice + the
  30s budget; an honest acknowledgment now.
- Predicted failure: Godot 4.6 `get_tree().paused = true` + Area2D
  body_entered may have a process_mode interaction — if Depot's own
  `process_mode` is not set to PROCESS_MODE_ALWAYS, the depot itself
  pauses and can't fire `body_exited`. The mitigation lives in the
  script. Second risk: in headless test, no actual physics tick fires;
  the test must directly invoke `_on_body_entered(stub)` rather than
  rely on collision-based emission.
- Falsifiable claim: post-edit, `make test` exits 0 AND `tile_hash`
  first 16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-config` PASS AND `make check-breach-shells` PASS
  AND new `make check-breach-depot` reports `BREACH_DEPOT_OK` with the
  pause-on-entry contract verified (get_tree().paused = true after
  entry signal, false after exit signal).
- Sentence test: n/a (depot itself is not an upgrade; iter 6+ depot
  upgrade catalog will run the sentence-test gate per RUBRIC C8).
- Substrate touched: none (Depot.gd + Depot.tscn are net-new files;
  no Layer 1/2/3 edits).
- Hash-anchor verification plan: post-edit, before commit. Should be
  trivially preserved — no engine/gameplay code touched.

## iter 004 — BUILD — Bullet.gd shell_class flag + AP/HE/HEAT constants

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 2 (≤3 primary shell classes
  at first — AP/HE/HEAT exactly), constraint 1 (no combat modal — flag
  is data-only, no UI surface), constraint 7 (verbs not stats — shell
  class will route to terrain/behavior affordances in later iters, not
  to +damage% upgrades)
- CONSULT constraints risked: constraint 3 (every enemy must have a
  readable shell/positioning relationship) is *not* satisfied yet by
  this iter — the shell_class field exists but no per-class behavior is
  wired. Later iter must implement HE=terrain-cracking,
  HEAT=anti-heavy-armor, AP=cheap-precise. The schema-only iter is
  honest scaffolding; the behavior gap is documented + scheduled.
- Predicted failure: extending Bullet.gd default-arg shape in `start()`
  may bleed across the existing callers in Level.gd or PlayerTank
  (which fire bullets without specifying shell_class) — they'd get the
  @export-default-AP behavior, which is the desired bit-identical
  baseline. If any caller passes positional args in a way that collides
  with a new positional `shell_class`, parsing or runtime breaks.
- Falsifiable claim: post-edit, `make test` exits 0 (procedural baseline
  still fires AP bullets identically to arc-2) AND `tile_hash` first
  16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS on all 5
  arc-3 targets AND `make check-breach-config` PASS AND new harness
  `make check-breach-shells` reports `BREACH_SHELLS_OK` with 3 shell
  classes (AP/HE/HEAT) verified distinct.
- Sentence test: n/a this iter (shell_class is a data field, not yet
  an upgrade). When iter 5+ adds an upgrade that grants shell-swap
  reserves, sentence will be: "This upgrade helps me climb through
  bunker bands by changing how I use HEAT" — sentence test gate.
- Substrate touched: `scripts/Bullet.gd` (substrate write #3 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; chose extend over new file
  per Scout A's spike + L5 gating template)
- Hash-anchor verification plan: post-edit, before commit. The
  Bullet.gd change is gameplay-layer (Layer 2), not engine. Hash anchor
  is bound to procedural seed-42 baseline which doesn't fire bullets
  during the 120-frame `make test` window — so the anchor should remain
  trivially preserved. But I'll verify anyway since the anchor floor on
  C10 caps everything else.

## iter 003 — BUILD — BreachConfig.gd + BreachBand.gd + sample .tres (2 bands)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 5 (each band must have a
  dominant terrain/enemy pressure — BreachBand's `dominant_pressure` +
  `canonical_answer` fields encode this), constraint 4 (BreachBand
  schema constrains future asset gen to existing silhouette roles by
  design — bands don't invent mechanics, they re-weight terrain), all
  others (no design surface changed; structural schema only)
- CONSULT constraints risked: constraint 5 if we later ship a band
  without a stated dominant pressure (defended by the schema —
  `dominant_pressure: String` field; runtime check possible later)
- Predicted failure: typed-Array Resource (`Array[BreachBand]`) syntax
  in `.tres` may have a Godot 4.6 quirk that fails to parse — falls back
  to untyped Array. Sub-resource cycles (BreachConfig → BreachBand →
  LevelConfig) may not resolve in load order — falls back to inline
  LevelConfig per band rather than ext resource.
- Falsifiable claim: post-edit, `make test` exits 0 AND
  `tile_hash` first 16 chars = `23d6a2ec3bf2821f` (procedural baseline
  preserved — `breach_mode_enabled=false`, `breach_config=null` on
  ProceduralLevel.tscn) AND `make test-all` reports all 5 arc-3 targets
  PASS AND `configs/breach_default.tres` loads cleanly via
  `ResourceLoader.load(...)` without errors.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (tighten @export type
  from `Resource` to `BreachConfig`; same flag area, sanctioned write
  scope from iter 2). New non-substrate files: `scripts/BreachBand.gd`,
  `scripts/BreachConfig.gd`, `configs/breach_default.tres`.
- Hash-anchor verification plan: post-edit, before commit.

## iter 002 — BUILD-QUALITY — DECISION (adopt path A) + first substrate hook

- Date: 2026-05-19
- Tag: [STRUCTURE] [QUALITY] (no discrete rubric anchor lift this iter;
  plumbing/foundation work per L3+R4 release-valve. First of 3
  substrate-touching iters required to hit C10 anchor 1.)
- CONSULT constraints respected: all 7 (no design surface; substrate
  plumbing only). Constraint 1 (no combat modals) is structurally
  protected by the gating template — flag-off codepath is bit-identical
  to arc-2 procedural.
- CONSULT constraints risked: none this iter; downstream iters carry
  risks (iter 3+ depth-band logic against constraint 5; iter 4+ shell
  classes against constraints 2/3; iter 5+ depot against constraint 1).
- Predicted failure: the `@export var breach_mode_enabled` + 2 conditional
  branches edit on `ProceduralLevel.gd` will subtly mutate the procedural
  baseline. Specifically, possible failure modes:
  - Branch added inside the RNG-touching window (before line 77) → hash
    breaks
  - Stub method's `_init_breach_mode()` body accidentally creates a
    child node or calls `randf()` even with flag off
  - GDScript parse-order error on the new vars (caught by pre-tool hook
    if present; pre-commit; or `make test`)
- Falsifiable claim: post-edit, `loop/test_runner.gd` on seed 42 / default
  config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND `playable: true`
  AND `make test` exits 0. If any of these fail, the iter HALTS for
  investigation per PROMPT §HALT CONDITIONS (hash anchor broken =
  correctness violation; auto-halt + investigate).
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (sanctioned per PROMPT
  §SUBSTRATE FREEZE iter-1 DECISION + §DEFAULT-ON SUBSTRATE GATING
  TEMPLATE; PATTERN 2 from arc 3)
- Hash-anchor verification plan: post-edit, before commit, run
  `loop/test_runner.gd` and verify `tile_hash: 23d6a2ec3bf2821f`. Run
  `make test` for parse + 120-frame runtime check. If both green, commit;
  if either fails, revert + investigate.

## iter 001 — SPIKE — mode-integration path A vs B

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design surface touched yet;
  this iter is structural plumbing investigation)
- CONSULT constraints risked: constraint 3 indirectly — if path A's
  default-on flag interacts with Spawner's existing band logic in a way
  that makes per-band enemy/terrain mapping harder later, we'd risk
  "decorative complexity" downstream
- Predicted failure: path A may turn out to be deeper than the PROMPT
  default-recommendation assumes. Specifically, `ProceduralLevel.tscn` +
  `ProceduralLevel.gd` may have implicit assumptions (TANKE_SEED env,
  fixed map geometry, no run-state surface) that fight against being
  gated for vertical depth-bands + depot insertion + run state. Path B
  may turn out to be cleaner than the PROMPT's H1 multiplication concern
  if `ProceduralStep` can be reused as a child node without scene
  duplication.
- Falsifiable claim: at end of iter 1, both spikes produce concrete file
  diffs (path A: minimal `@export var breach_mode_enabled` patch + 1
  conditional branch in `_ready` or `_build_level`; path B: a skeletal
  `scenes/BreachLevel.tscn` referencing `ProceduralStep` as a child).
  Each spike returns SHIP / REFINE / SKIP + lines-of-change estimate +
  hash-anchor impact statement. **Neither spike actually commits the
  diff** — they're scouts. The DECISION (iter 2) picks the winner.
- Sentence test: n/a (no upgrade in this iter)
- Substrate touched: read-only investigation
- Hash-anchor verification plan: post-spike (iter 2 DECISION's build),
  not this iter. Both spikes report whether their path could break the
  anchor in principle.

## iter 000 — META — preloop complete

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design work yet; substrate-only)
- CONSULT constraints risked: none
- Predicted failure: substrate may have drifted across the 3 modified files
  in git status (`project.godot` shows `M`) → either hash anchor breaks or
  `make test` fails.
- Falsifiable claim: `make test` exits 0 AND `loop/test_runner.gd` on seed
  42 / default config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND
  `playable: true` AND OG `check-chain` reports `CHAIN_25_OK`.
- Sentence test: n/a (no upgrade)
- Substrate touched: none (read-only verification)
- Hash-anchor verification plan: post-verification, pre-flip of
  `preloop_complete: yes`. Result: PASS (`23d6a2ec3bf2821f` confirmed).
