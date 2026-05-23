# Round 11 diagnose — written iter 080 (META, post-Round-10-close)

Compaction-safe per L2. The next iter that opens Round 11 (whenever
playtest 5 closes or the idle budget exhausts) reads this file.

## Where the loop stands

- **Round 10 closed at iter 79.** Three phases shipped: distinctness
  audit (Phase 1), PRESSURES matrix + pressure-probe harness
  (Phase 2), on-death prompt + PLAYTEST-5-BRIEF (Phase 3).
- **★ REVIEW-QUEUE #14 OPEN + UPGRADED.** Playtest 5 gate, now
  layered with the structured brief + on-death overlay + open
  design questions.
- **Score: 47/75** (C5 lifted 2→3 at iter 76).
- **Substrate writes: 42** (PlayerTank.gd ×24 after iter 78 HUD
  addition; flag-off bit-identical; hash 23d6a2ec3bf2821f intact).
- **Test posture:** test-all 5/5; test-breach 37/37.

## What's open

Three user-direction questions, surfaced across the round:
- **REVIEW-QUEUE #15** — archetypes-as-RUN-IDENTITIES vs
  archetypes-as-WEAPONS. The shape of the next playtest's regret-
  quote settles this.
- **PRESSURES.md armor asymmetry** — DEFAULT respects armor via
  shell class; PRISM/MORTAR/RAM bypass by mechanism. Universal vs
  per-archetype-bypass-as-verb is a design call.
- **CONSULT 009 band-shape blind spot** — Round 10's instrumentation
  tests single moments, not multi-band run-shape. A structural gap
  if the playtest exposes it.

Four roster gaps from PRESSURES.md:
- **SWARM** (no spawn cluster — Fast is single-spawn)
- **SNIPER** (long-LoS to punish PRISM exposure — Heavy is
  bullet-range)
- **heavier armor** (beyond Heavy's 3hp; current breach bonus
  caps at 3hp)
- **suppression-target** (no enemy currently rewards PRISM
  suppression style)

## Five Round-11 candidates

### (a) Band-shape recorder — addresses CONSULT 009 blind spot

**Pitch:** the structural analog of the Round-10 distinctness
audit, but at the RUN scale. A harness that records per-archetype
per-seed: damage-delivered curve over time, path traveled, depot
picks taken, kills per band, time-in-band. Compare across the 4
archetypes on the same seeds — do their RUNS look different, or
just their MOMENTS?

**Effort estimate:** ~3-5 BUILD iters. Needs RunRecap or sibling
to write per-frame snapshots; analyzer to compute per-archetype
run signatures.

**Substrate writes:** RunRecap.gd or sibling (arc-4-owned; not
substrate). PlayerTank.gd may need a per-frame hook (gated).

**Risk:** auto-play sim quality — if the "playthrough" is a stub
input loop, the comparison only captures mechanical differences
already known. The recorder is best PAIRED with the actual
playtest 5 data (post-hoc analysis of real user runs).

**Rubric lift:** none directly (no rubric criterion for run-shape).
But it would justify a +C16 "Run-shape distinctness" criterion at
Round 11 close, mirroring the +C15 iter-39 incremental pattern.

### (b) Enemy roster expansion — fills the 4 PRESSURES.md gaps

**Pitch:** add SWARM / SNIPER / heavier-armor / suppression-target
roles (or a subset). Each role earns its slot if it creates a
best/costly-backup/bad answer hierarchy across archetypes — NOT
"this enemy demands one archetype" per Pro's H2.

**Effort estimate:** 4-7 BUILD iters per role; pick 1-2 for the
round.

**Substrate writes:** Spawner.gd (already substrate ×4) + possibly
new Enemy*.gd files (arc-4-owned).

**Risk:** rubric-chasing per CONSULT 008's H2 — adding roles
without verifying they fix the BAND-SHAPE feel. The pressure
matrix's "best answer / costly backup / bad answer" requirement
mitigates this.

**Rubric lift:** C5 from 3 → 4 (anchor 4: silhouette + palette +
facing differ) if silhouette gate passes; later anchor 5 (cited
canonical answer) playtest-gated.

### (c) Armor-asymmetry resolution

**Pitch:** decide between (i) universal armor in
Enemy.take_damage (all archetypes respect Heavy armor) and (ii)
per-archetype-bypass-as-verb (current — PRISM/MORTAR/RAM bypass).
The (ii) reading aligns with Pro's "every archetype must buy
passage differently" spine.

**Effort estimate:** 1-2 iters if (ii) is confirmed (just
document the design intent); 4-6 if (i) is chosen (rewrite the
armor check; may require per-archetype "armor-bypass shell"
analog upgrades).

**Substrate writes:** if (i), Enemy.gd (Layer 2; sanctioned-
extension would be needed). If (ii), no code change.

**Risk:** premature commit. This is a DESIGN call — best made
with playtest 5 evidence on whether the armor asymmetry FEELS
right.

**Rubric lift:** marginal (would clarify C3 anchor 3 but not
advance scoring).

### (d) Identity-vs-weapons design clarification

**Pitch:** REVIEW-QUEUE #15 settles via playtest-5 quote shape.
Once settled, downstream design (depot pacing, switch cost,
start-pick presentation) tunes around the answer.

**Effort estimate:** 0 iters (user decision); 2-3 iters to
implement tuning per the chosen reading.

**Substrate writes:** likely 0 — most tuning lives in arc-4-
owned files.

**Risk:** hold-not-implement. The loop can NOT settle this
without the user.

**Rubric lift:** would rephrase C15 anchor 5 once settled (per
Pro's first-principles section); awaits playtest-5.

### (e) Defer to playtest 5 verdict (this iter's choice)

**Pitch:** every prior round was direction-set by user playtest
(5/6/7/8/9/10). Building speculative SPIKE work before #14 closes
is high-variance — and post-Round-10 the loop has a particularly
HIGH cost of misdirection (PlayerTank.gd ×24, careful gating
discipline; pivoting would mean undoing).

**Cost:** loop idles 1800s → 3600s → pause per the iter-54/61/72
pattern. The diagnose blueprint (this file) is the immediate
artifact for the returning user.

**Risk:** user momentum decay. Mitigation: the diagnose names 4
SPECIFIC candidate axes + recommends order — the user has a clear
menu of choices when they return, not a fresh decision.

## Recommendation

**The loop should: write this diagnose, idle 1800s, await
playtest 5.** Two reasons distinct from iter 72:

1. The Round-10 instrumentation is COMPLETE — the playtest now
   has the BEST POSSIBLE frame (PLAYTEST-5-BRIEF + on-death
   overlay + structured questions). Adding pre-playtest work
   diminishes returns: the brief was the high-leverage piece.

2. **CONSULT 009 named the band-shape blind spot.** The DEFAULT
   choice if no signal arrives is now (a) band-shape recorder,
   NOT (b) enemy roster. This is the corrective vs iter-72.

If the user returns with playtest 5:
- "Felt similar across archetypes" → (a) band-shape recorder
  first; THEN (b) roster expansion targeting whichever gap their
  feedback names.
- "Archetypes feel distinct, but X enemy type missed" → (b)
  roster expansion on X.
- "I wanted the SWITCH_TO_* depot pick more" → tuning of
  switch availability + the identity-vs-weapons resolution (d).
- "Armor asymmetry felt wrong" → (c) universal armor.
- Something not named here → user direction overrides this
  diagnose; the loop respects the override.

If the user does NOT return within the heartbeat budget:
- Default order: **(a) band-shape recorder** (3-5 iters,
  addresses CONSULT 009 blind spot) → **(b) SWARM enemy** (the
  cleanest single PRESSURES gap; tests AoE/cone archetypes).

## What changed from iter 72

The iter-72 diagnose recommended (a) enemy roster expansion as
the default. **Round 10 invalidated that recommendation** by
shipping the distinctness audit + PRESSURES matrix WITHOUT adding
enemies — and the CONSULT 009 finding (single-moment focus blind
to band-shape) re-orders the default toward (a) **band-shape
recorder** before (b) enemy roster.

The iter-072 file is preserved as historical record; this file
supersedes its recommendation only.

## Next-iter handoff

The loop wakes at iter 81 (1800s after iter 80 commit). If the
user returned in that window — read input, read this file,
choose. If they did NOT — fire a second heartbeat at iter 82
(3600s, cache-cost-amortized per iter-54/61 pattern). If they
did NOT by iter 83 — proceed with default (a) band-shape recorder.
