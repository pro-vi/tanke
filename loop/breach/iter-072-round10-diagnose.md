# Round 10 diagnose — written iter 072 (META)

Compaction-safe per L2. The next iter that opens Round 10 (whenever the
playtest gate closes or the idle budget exhausts) reads this file.

## Where the loop stands

- **Round 9 closed at iter 71.** 4-archetype tank program shipped
  end-to-end (DEFAULT + PRISM + MORTAR + RAM) + start-of-run
  selection + mid-run event-unlock switching + concept sprites.
- **★ REVIEW-QUEUE #14 opened.** Playtest request for the
  archetype program. The C15 anchor 5 (cognitive: "user describes
  runs by archetype-verb, not archetype-as-skin") is the only
  open gate — playtest answers it.
- **REVIEW-QUEUE #13 open (decision-needed).** Integration path for
  the concept sprites — (a) downsample-and-composite, (b)
  algorithmic tint+overlay via gen_tile.py, (c) defer for human
  pass. Default if no answer: (b).
- **Score 46/75.** Effective ceiling is 75; remaining 29 points are
  the cognitive/identity-protected anchors — every one of them
  needs at least one playtest cycle to lift.
- **Substrate writes:** 41 (all gated on breach_mode_enabled,
  hash-anchor preserved through every one).
- **Test posture:** test-all 5/5; test-breach 35/35; hash anchor
  23d6a2ec3bf2821f intact across iters 0-71.

## What's the weakest rubric axis right now?

Score line: C1=3, C2=3, C3=4, C4=3, C5=2, C6=3, C7=3, C8=3, C9=2,
C10=4, C11=3, C12=3, C13=3, C14=3, C15=4.

- **C5 (Enemy role vocabulary) at 2/5** — the weakest structural
  axis. Only Light/Heavy/Fast in the breach roster; HP-bar HUD
  shipped iter 63 but the silhouette gate + canonical-answer
  documentation are unlifted. The new archetypes EXPOSE this
  weakness — PRISM/MORTAR/RAM are most interesting against
  varied enemy roles.
- **C9 (Identity / breach-roguelite singularity) at 2/5** — also
  weak, but the cognitive anchors dominate; not a SPIKE candidate
  without playtest evidence.
- **Most other axes at 3 or 4** — the structural ceilings are
  reached or one anchor away.

The honest read: **C5 is the structural axis with the most room +
the clearest line to the next playtest's verdict** (a richer roster
makes the archetype-distinctness more measurable).

## Three Round-10 candidates

### (a) Enemy roster expansion against the new archetypes

**Pitch:** propose 2-3 new enemy roles whose tactical answer DEMANDS
a specific archetype. Each role exists to make the archetype
distinctness MATTER (not just exist).

Concrete role candidates (illustrative, not committed):
- **SNIPER** — long-range slow-fire enemy that punishes PRISM
  exposure (stop-and-fire means standing still in LoS). Tactical
  answer: MORTAR (over-walls / no-LoS) or RAM (rush + crush) or
  Default-AP (precision counter-snipe).
- **SWARM** — small fast cluster that rewards MORTAR AoE / RAM
  collision-sweep. Tactical answer that's WRONG: Default-AP (one
  shot per swarm member is bullet-economy suicide).
- **HULK** — armored slow enemy that needs HEAT or RAM to break
  through. Tactical answer: HEAT (the existing AP/HE/HEAT/APCR
  grammar already covers this) or RAM (collision burst).

**Effort estimate:** 4-7 BUILD iters (one per role + integration
into BreachConfig + harness coverage). Each role needs a new enemy
script extending Enemy.gd OR via parameterization of the existing
Spawner.gd (preferred — fewer substrate writes).

**Substrate writes:** Spawner.gd (extension; already substrate ×4)
+ optionally Enemy.gd parameterization. PlayerTank.gd untouched.

**Risk:** spec'ing roles that are SUPPOSED to demand a specific
archetype but in practice get answered by Default-everything (the
"PRISM is always the safe pick" trap). Mitigation: each new role's
acceptance test cites WHICH archetype wins it, not just "an
archetype wins."

**Rubric lift:** C5 from 2 → 4 plausible (anchor 4 needs
silhouettes for the new roles → loops back to silhouette grammar
gate + C7).

### (b) Roster import from arc-3 OG mode

**Pitch:** lift enemy variants already shipped in arc-3 originals
mode (per Roster.gd / stage configs) into the breach
BreachConfig. Cheaper than (a) — most of the work is already done.

**Effort estimate:** 2-4 SPIKE iters to measure the fit, then 3-5
BUILD iters to wire and tune.

**Substrate writes:** BreachConfig.gd (arc-4-owned) + possibly
Spawner.gd (already substrate). The OG enemy types are
Layer-3 substrate (Roster.gd) — they can be READ but not modified;
the BreachConfig calls into them as-is.

**Risk:** OG enemies were tuned for the arc-3 Battle-City fidelity
goal, not breach-economy verb-distinctness. The HP/damage curves
may not match the iter-63 HP primitive cleanly. Mitigation: SPIKE
measures fit first; BUILD only commits if SPIKE shows ≥3 of N
imports map to a distinct tactical answer.

**Rubric lift:** C5 from 2 → 3 plausible (anchor 3 requires
silhouette+palette+facing; OG enemies already have these, so the
import gets it for free); anchor 4 is still playtest-gated.

### (c) Defer to playtest verdict (idle heartbeat)

**Pitch:** REVIEW-QUEUE #14 is a ★ playtest gate. The historical
arc-4 pattern: every Round (5/6/7/8/9) was direction-set by a user
playtest, not the loop's own diagnosis. The loop running 5+ iters
of (a) or (b) before the user playtests risks chasing the wrong
axis — playtest 5 might surface "the archetypes feel great but
shells are overwhelming" or "I want a save system" or something
the rubric doesn't cover at all.

**Cost:** loop sits idle (1800s heartbeats, then 3600s if no signal,
then pause per the iter-61 pattern). The diagnose blueprint (this
file) is the immediately-readable artifact when the user returns.

**Risk:** user momentum dies if the loop idle-pauses without
producing something they can react to. The diagnose blueprint
mitigates by giving them a single page that lists the candidates +
recommendations + asks them to pick.

## Recommendation — pick at iter 73

**The loop should: write the diagnose (this file, iter 72), idle
at 1800s, and let the playtest gate close before committing to
(a) or (b).** Rationale:

1. The 4 prior playtests EACH redirected the round. Playtest 5 has
   a >50% prior of doing the same. Building speculative SPIKE
   work before then is high-variance.
2. The diagnose blueprint is the artifact a returning user wants —
   "what's the loop thinking?" answered on one page.
3. The idle heartbeat budget (1800s → 3600s → pause) is the
   established arc-4 reconciliation between PROMPT's "non-stop"
   and CONSULT's "don't pile speculative structure." It worked at
   iter 54 (Round 7 close) and iter 61 (Round 8 close).

If the user playtests and chooses (a) or (b) or surfaces a new
direction: the next iter reads this blueprint + the playtest
verdict and BOOTSTRAPS Round 10 from the user's chosen axis.

If the user does not return within the heartbeat budget: the loop
proceeds with the default — **(b) algorithmic tint+overlay** for
REVIEW-QUEUE #13 (the cheap sprite-integration default) THEN **(a)
or (b) of this diagnose**, scored against effort-to-impact.

## Open questions the user may want to answer

When the user playtests (or reads this file):
1. Do the 4 archetypes FEEL distinct, or just mechanically distinct?
   (C15 anchor 5 — the only thing a hands-on session can verify.)
2. Which Round-10 axis would they prefer: roster expansion, OG
   import, sprite-integration first, or a direction not named here?
3. Is REVIEW-QUEUE #13 (sprite integration path) urgent enough to
   come BEFORE Round 10, or can it wait?

## Next-iter handoff

The loop wakes at iter 73 (1800s after iter 72 commit). If the user
returned in that window — read their input, read this file, choose
the round. If they did NOT — fire a second heartbeat at iter 74
(longer cadence per iter-61 pattern). If they did NOT by iter 75 —
proceed with default direction (REVIEW-QUEUE #13 default-b + Round
10 default-a) at SPIKE cadence.
