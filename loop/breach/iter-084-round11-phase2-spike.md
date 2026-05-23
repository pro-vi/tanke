# Round 11 Phase 2 SPIKE blueprint — written iter 084 (META)

Compaction-safe per L2. The iter that opens the Phase-2 SPIKE
(iter 85 if engagement continues) reads this file.

## Where the loop stands

- **Round 11 Phase 1 COMPLETE** (iters 82-83) — band-shape
  recorder (RunRecap extension) + analyzer (RunRecapAnalyzer) +
  death-screen surface. The distinctness pipeline now operates at
  BOTH the single-moment scale (iter-74-75 audit) AND the run
  scale (iter-82-83 band-shape).
- **★ REVIEW-QUEUE #14 STILL OPEN.** Playtest 5 has not happened.
  Score 47/75. Substrate writes 44.
- **iter-080 blueprint** named 5 Round-11 candidates: (a)
  band-shape recorder [DONE — Phase 1], (b) enemy roster
  expansion, (c) armor-asymmetry resolution, (d)
  identity-vs-weapons clarification, (e) defer to playtest.

## What's left in Round 11

If user engagement continues, the next non-speculative work
remaining is candidate **(b) enemy roster expansion** — but
gated by CONSULT 008's H2 critique: the enemy must produce
**best/costly-backup/bad answer hierarchy across archetypes**, NOT
"demands one archetype." Per PRESSURES.md the cleanest single
roster gap is **SWARM** — no current enemy spawns as a cluster,
which under-tests PRISM (beam stops at first body), MORTAR (AoE
shines on clusters), RAM (cone-sweep + collision rewards
multi-target).

The other candidates ((c) armor resolution, (d) identity-vs-
weapons) are gated on playtest evidence — design calls, not BUILD
work. The loop should NOT touch them pre-playtest.

## Phase 2 SPIKE — 3 SWARM variants

Per L1 (SPIKE = ≥2 parallel investigations of uncertain options),
the SPIKE compares **3 SWARM design variants** before committing.
Each variant is a different "what is a swarm?" answer:

### Variant α — "swarmlet" cluster of Light-clones

- Spawn rule: spawner emits 4-5 Light-class enemies simultaneously
  (a "swarmlet pack") instead of single Lights.
- HP/speed: same as Light (1hp, 24 speed).
- Fire rate: same as Light (3.5s — rare).
- Visual: same Light sprite, but a small chevron formation
  (3-front, 2-rear).

Strength signals:
- DEFAULT: costly backup — each Light is a discrete shot; pack
  consumes 4-5 bullets.
- PRISM: weak — beam stops at first body; chevron disperses past
  the first hit.
- MORTAR: BEST — AoE hits 3+ in the cluster.
- RAM: BEST — cone-swing covers the cluster; sprint catches strays.

Hierarchy check: DEFAULT≠PRISM≠MORTAR=RAM (3 distinct outcomes).

### Variant β — single fast multispawn "Fast-rusher pack"

- Spawn rule: 3 Fast-class enemies emit at once from the same
  edge, spread laterally.
- HP/speed: same as Fast (1hp, 32 speed).
- Fire rate: same as Fast (1.0s — continuous-while-moving).
- Visual: existing Fast cyan tint; spatial spread (~16px between).

Strength signals:
- DEFAULT: bad — by the time DEFAULT picks one off, the others
  close to melee range.
- PRISM: bad — beam can hit at most 1 of the 3; stop-and-fire
  exposes you to the other 2 closing.
- MORTAR: BEST — AoE catches the spread; slow cadence still
  works because the cluster persists at range for a moment.
- RAM: GOOD — sprint catches stragglers; cone hits the front 2.

Hierarchy check: DEFAULT=PRISM (both bad) — VIOLATES the
"hierarchy across archetypes" rule. If 2 archetypes have the same
"bad" answer the SWARM punishes 50% of the roster. SPIKE
predicts: β is the WORST variant.

### Variant γ — formation "spinet" — slow Heavy-pair

- Spawn rule: 2 Heavy-class enemies emit side-by-side, 16px apart,
  acting in unison (synchronized AIM_FIRE).
- HP/speed: same as Heavy (3hp in breach, 14 speed, armored).
- Fire rate: same as Heavy (0.8s — high return-fire density).
- Visual: existing Heavy + tighter spawn coupling.

Strength signals:
- DEFAULT: COSTLY backup — needs HEAT/APCR for armor; 2 Heavies
  doubles the shell cost.
- PRISM: bad — beam burns one slowly; the other returns 2-damage
  bullets continuously while PRISM is locked stop-and-fire.
- MORTAR: GOOD — AoE bypasses armor (per iter-77 probe) + hits
  both; positioning matters.
- RAM: GOOD — collision damage bypasses armor + sweep catches
  both; but two Heavies return-firing makes the close-fire trade
  punishing.

Hierarchy check: DEFAULT/PRISM/MORTAR/RAM all have distinct
outcomes (BEST: MORTAR; GOOD: RAM; COSTLY: DEFAULT; BAD: PRISM).
4 distinct outcomes.

## SPIKE verdict prediction

α covers the GAP best (the missing dense-swarm pressure). γ
covers a different pressure (paired armored). β fails the
hierarchy rule.

**Recommended SPIKE outcome: ship α (swarmlet) as Round 11 Phase 2
deliverable; defer γ (synchronized Heavy-pair) as a Round 12
candidate; reject β.**

If the user prefers a different ordering, the SPIKE blueprint
prepares all 3 — the user can choose.

## Phase 2 BUILD (iter 86+ if SPIKE confirms α)

Implementation outline for variant α:
1. Spawner.gd extension: when band roster picks "Swarm" type,
   spawn 4-5 Light-class enemies in a chevron formation
   (instead of 1). Use existing Light sprite/script — no new
   Enemy*.gd needed.
2. BreachConfig.gd — add a Swarm-band entry (e.g. mid-game band)
   with a swarm spawn weighted heavily.
3. Harness: spawn the swarmlet pack, verify count = 4-5,
   formation positions within tolerance, per-archetype damage
   outcomes match the matrix.

Substrate: Spawner.gd (already substrate ×4 → ×5; sanctioned).

## What this does NOT do

- Does not commit to SWARM before SPIKE verifies the hierarchy.
- Does not modify any archetype.
- Does not touch armor logic (that's candidate (c) — gated on
  playtest 5).
- Does not start work without continued user engagement signal.

## Next-iter handoff

Iter 85 fires SPIKE α/β/γ:
- Spawn each variant configuration in a headless harness
- For each variant, place a representative DEFAULT/PRISM/MORTAR/
  RAM player + drive each archetype's fire input for K ticks
- Measure damage outcomes (variant survivors after K ticks per
  archetype)
- Compute hierarchy verdict per variant
- Emit recommendation matching this blueprint's prediction (or
  flag if reality differs)

If iter 85 fires and the user has paused engagement (no /loop
ping for 1800s+), abort SPIKE and idle-heartbeat — playtest 5
still gates everything downstream.
