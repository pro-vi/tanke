# PRESSURES.md — per-archetype × per-pressure tactical matrix

Round 10 Phase 2, iter 76. Per Consult 008's H2/H3 critique, this
matrix documents which pressure dimensions the existing game
expresses + what each archetype's tactical answer is. **Empty or
weak cells = pressures the current roster does not express → Round
11 roster-expansion candidates.**

The matrix is the GATE before adding any new enemy: a candidate is
worth adding only if it fills an empty cell (covers a pressure no
existing role expresses) AND produces a best-answer/costly-backup/
bad-answer hierarchy across multiple archetypes (NOT "this enemy
demands one archetype" — that makes start-pick a coin flip, per
Pro's H2 critique).

## Sources

Grounded in code reads of:
- `scripts/Spawner.gd` (Light/Heavy/Fast roster + DEPTH_BANDS)
- `scripts/Enemy.gd` (per-role tick logic + take_damage)
- `scripts/BreachConfig.gd` (per-band weights + HP bonus)
- `scripts/PlayerTank.gd` (per-archetype fire paths)
- The per-archetype harnesses (test_breach_{prism,mortar,ram})

Current roster (3 enemy roles):
- **Light** — 1hp (+1 in breach mode), 24 speed, lane-invader,
  3.5s fire cooldown, commits to a lane for 3s
- **Heavy** — 2hp (+1 breach), 14 speed, AP/HE-armored
  (HEAT/APCR bypass), 0.8s fire cooldown, 2 damage bullets,
  corridor-denier
- **Fast** — 1hp (+1 breach), 32 speed, cyan tint, continuous fire
  (1.0s cooldown), no aim/telegraph, harassment rusher

Bands (DEPTH_BANDS): warmup (Light only), first_push (mixed +
Heavy guarantee at entry), etc.

## Cell legend

- **best**: this archetype's strongest answer to the pressure
- **costly backup**: a workable but suboptimal answer (commits a
  resource the archetype would rather conserve)
- **bad**: this archetype struggles or pays too much
- **—**: this archetype has no clear answer; the pressure is
  poorly served (Round 11 candidate)

## The matrix

| Pressure                  | DEFAULT                                                      | PRISM                                                                                  | MORTAR                                                                                | RAM                                                                                |
|---------------------------|--------------------------------------------------------------|----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|
| **long-LoS threat**       | best — AP precision shot at range                            | best — beam reaches 160px instantly, kills at-LoS via continuous DPS                  | costly backup — lob over walls bypasses LoS but slow cadence (1.5s)                  | bad — 18px swing range, must close under fire                                      |
| **dense swarm (multi-target)** | costly backup — discrete bullets pick off one-by-one      | weak — beam stops at first body hit; only line-of-multiples kills > 1 per beam        | best — AoE on impact hits cluster (current MORTAR has no cluster threat to test on)   | best — collision sweep + 18px cone catches multiple bodies in lane                 |
| **armor (Heavy-class)**   | best — HEAT/APCR shells bypass; AP/HE blocked                | costly backup — beam deals 1/tick, slow against 3+ hp Heavy                            | best — AoE on impact damages armored bodies (no armor bypass logic for beam/lob/melee yet — needs verification) | best — collision + swing pierce armor (no armor-bypass logic in PlayerTank for RAM either — needs verification) |
| **narrow corridors**      | best — discrete bullet fires straight down lane              | best — beam shoots clean line down corridor                                            | weak — parabolic arc requires open vertical space; corridor walls block trajectory   | costly backup — collision works but takes return fire to close                     |
| **moving targets**        | best — aim leads target, single shot                         | costly backup — beam aim must track + commit (stop-and-fire) — exposed during chase   | weak — slow travel time, target moves out of impact zone                              | best — sprint + collision catches movers; cone swing covers area                   |
| **brick obstruction**     | best — HE single-shot zone clears bricks                     | costly backup — beam burns brick line at 4Hz (slow but works); APCR-style steel: NO   | best — AoE on impact destroys brick cluster (impact crater verified iter 66)         | best — collision smashes brick on contact (verified iter 67); RAM_SWING also hits  |
| **depot timing (when to commit)** | best — shell economy depth lets player save/spend across band | best — beam continuous DPS makes long-fight depots tempting; "save energy" not a thing | costly backup — slow cadence means low-DPS-per-fight; depot pickups matter more   | best — collision + sprint = burn-down approach; depot picks (heal/shield) high value |
| **kiting + retreat**      | best — fire while moving                                     | bad — stop-and-fire violates retreat; beam fires lock player in place                 | best — lob arcs over wall while moving                                                 | weak — must close to deal damage; can't fight while retreating                     |
| **single-target burst**   | best — APCR/HEAT shell                                       | weak — beam DPS too slow for instant burst                                             | best — AoE on impact = burst damage                                                    | best — swing damage 2 + collision 1 = 3 burst                                      |
| **suppression (return fire density)** | costly backup — discrete fire rate limits suppression | best — continuous beam IS suppression (4Hz)                                            | weak — single shell every 1.5s leaves long gaps                                       | weak — must be in melee range; vulnerable to ranged return fire                    |

## Coverage analysis

10 pressure rows × 4 archetypes = 40 cells.

**Per-pressure coverage**:

| Pressure                    | Best count | Empty count | Notes                                                       |
|-----------------------------|------------|-------------|-------------------------------------------------------------|
| long-LoS threat             | 2          | 0           | covered                                                     |
| dense swarm                 | 2          | 0           | covered, BUT current roster has NO swarm enemy              |
| armor                       | 3          | 0           | covered (uneven — PRISM has the weakest answer)             |
| narrow corridors            | 2          | 0           | covered (mortar weak by geometry, RAM via collision close)  |
| moving targets              | 2          | 0           | covered                                                     |
| brick obstruction           | 3          | 0           | covered (universal)                                          |
| depot timing                | 3          | 0           | every archetype has a depot relationship; differences are nuanced |
| kiting + retreat            | 2          | 0           | covered                                                     |
| single-target burst         | 3          | 0           | covered                                                     |
| suppression                 | 1          | 0           | weakly covered — only PRISM is a true suppressor             |

## Round 11 candidate gaps (where pressure exists but roster underserves it)

The matrix above is the PER-ARCHETYPE answer to each pressure
GIVEN A PRESSURE EXISTS. But several pressures lack roster
representation:

1. **DENSE SWARM** — the current roster has no swarm enemy. Fast
   is the closest (continuous fire, 32 speed) but is single-spawn.
   PRISM's "beam stops at first body" + MORTAR's "AoE rewards
   clusters" + RAM's "cone sweep rewards clusters" are all
   under-tested. **Round 11 candidate: a SWARM enemy that spawns
   in groups of 3-5.**

2. **LONG-LOS THREAT** — Heavy "aim+fire" is the closest, but its
   range is bullet-class, not the dedicated long-LoS sniper Pro
   named. PRISM's stop-and-fire exposure is currently undertested
   because no enemy has the range to punish it specifically.
   **Round 11 candidate: a SNIPER enemy (long-range, slow fire,
   high damage, slow movement).**

3. **HEAVY ARMOR (beyond 2hp Heavy)** — the breach-mode bonus
   gives Heavy 3hp. With HEAT/APCR bypass, the ceiling holds. But
   the matrix above flagged that PRISM/MORTAR/RAM may NOT have
   correct armor-bypass logic — needs verification (see "Armor
   bypass gaps" below).

4. **TRUE SUPPRESSION** — the matrix surfaced that only PRISM is a
   suppressor archetype, and no enemy currently rewards suppression
   play. **Round 11 candidate: a SUMMONER or BARRIER enemy that
   punishes the player for stopping to fire? (would interact with
   PRISM exposure)** — speculative; needs validation.

## Armor bypass gaps (matrix surfaced — needs verification)

The matrix flagged uncertainty about whether PRISM beam / MORTAR
shell / RAM collision/swing respect Heavy's `armored: true` flag.
Reading the code:
- Bullet.gd (DEFAULT bullets) — checks `actual_shell` class against
  `armored` enemies; AP/HE blocked, HEAT/APCR bypass.
- PRISM `_apply_beam_to_body` — calls `take_damage(1)` unconditionally.
- MORTAR `_explode` — applies AoE damage; no armor check.
- RAM collision + swing — `take_damage(RAM_COLLISION_DAMAGE)` and
  `take_damage(RAM_SWING_DAMAGE)` — no armor check.

**This is a real gap** — the matrix above marked PRISM as "costly
backup" against Heavy, but in fact PRISM CAN damage Heavy through
armor (the armor logic is only in Bullet.gd, not enforced at
take_damage). For arc-4-spine integrity ("every archetype must buy
passage differently"), armor probably SHOULD apply uniformly. This
is a Round 11 / Round 12 design decision (not a Round 10 build —
documenting only).

Either:
- (a) Move the armor check into Enemy.take_damage, so all
  archetypes respect Heavy armor → PRISM has to grind beam, MORTAR
  needs a "shaped charge" upgrade, RAM gets a collision-bypass
  pass. Forces design symmetry.
- (b) Leave it — PRISM/MORTAR/RAM bypass armor by mechanism (the
  beam burns through, the shell explodes, the tank rams through).
  Each archetype's "verb" implicitly includes armor-bypass. Forces
  asymmetric design where DEFAULT's shell-class economy is the ONLY
  archetype that has to think about armor.

The (b) reading aligns with Pro's first-principles note: *"every
archetype must buy passage differently."* DEFAULT buys passage with
SHELLS; PRISM buys passage with EXPOSURE; MORTAR buys passage with
SLOW DPS; RAM buys passage with HP cost (close-fire trade).

Worth a Round-11 user-direction question.

## What this round did NOT do

- Did not add any enemy
- Did not modify archetype mechanics
- Did not modify armor logic
- Did not run play-sim probes per cell (a Phase-2 continuation
  would; iter 77 could ship a "probe harness" that validates each
  best/costly-backup/bad cell empirically)

## Iter 77 handoff

Two paths for iter 77 (Phase 2 continuation):

(α) **Probe harness** — `loop/breach/test_breach_pressure_probes.gd`:
    one micro-scenario per matrix cell (place player + appropriate
    enemy in the test scene, drive the archetype's fire input,
    measure outcome — kill/hit/miss). Validates the matrix
    empirically. Cost: ~1 iter; the new harness becomes the
    matrix's verification layer.

(β) **Skip to Phase 3** — playtest instrumentation. The matrix is
    a DESIGN doc; the probe harness extends to STRUCTURAL but it
    won't catch experiential issues. Phase 3 (death prompts +
    PLAYTEST-5-BRIEF) is the actual highest-leverage pre-playtest
    work.

**Recommendation: α** — the probe harness extends test-breach
count by ~1, costs one iter, and gives the matrix a verifiable
backing. Phase 3 follows in iter 78. If iter 77 starts and the
probe harness is more involved than expected, abort to (β) early.
