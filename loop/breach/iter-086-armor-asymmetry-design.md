# Armor-asymmetry resolution — design doc (iter 086, META)

Compaction-safe per L2. Reads alongside `PRESSURES.md` (the "Armor
bypass gaps" section) and `creative-consults.md` (CONSULT 008's
first-principles framing).

## The question (surfaced iter 76, empirically confirmed iter 77)

Currently in the breach codebase, armor logic lives **only in
`Bullet.gd._on_body_entered`**:

```gdscript
if shell_class != SHELL_CLASS_HEAT and shell_class != SHELL_CLASS_APCR
        and body.is_in_group("armored"):
    deal = max(0, deal - ARMOR_MITIGATION)
```

PRISM beam (`_apply_beam_to_body`), MORTAR shell (`_explode`), and
RAM swing/collision all call `take_damage()` **unconditionally** —
they bypass armor by mechanism. The iter-77 pressure-probe harness
confirmed this empirically (PRISM=1 dmg, MORTAR AoE=2 dmg, RAM
swing=2 dmg vs armored Heavy; DEFAULT+AP=0, DEFAULT+HEAT=2).

Two readings, both internally consistent. Both correctly playable.

## Reading (a) — universal armor

**Move the armor check into `Enemy.take_damage`** (or a wrapping
guard at every damage call site). Heavy armor blocks the first
N points of damage from ALL sources unless the source is tagged
as "armor-piercing."

### Concrete consequences

1. **PRISM** would need a depot upgrade ("Focused Lens"?) that
   tags the beam as armor-piercing — otherwise PRISM is bad
   against Heavy class. The depot upgrade IS the verb-changer.
2. **MORTAR** would need an "AP Shells" upgrade to bypass armor —
   otherwise the AoE just doesn't damage Heavies (only
   un-armored enemies in the splash). The upgrade chain
   parallels DEFAULT's AP/HE/HEAT/APCR shell economy.
3. **RAM** would need an "Armor-Piercing Spike" upgrade to do
   damage on collision vs Heavies. Without it, RAM is fast at
   stripping Light/Fast but useless against the Heavy bunker.
4. New depot upgrades become MEANINGFUL — each archetype's
   armor-piercing upgrade is the "I can NOW deal with Heavies"
   moment. Strengthens depot anticipation (C2 anchor 5).
5. The 4 archetypes converge on the SAME design pattern —
   "default weapon + a shell-class economy of upgrades for
   different enemy classes." This is the Battle City / shell-
   economy spine extended.

### Tradeoffs

- **Pro**: forces design symmetry. All archetypes "buy passage"
  through Heavy armor via the depot economy. Heavies become a
  genuine class-of-enemy moment.
- **Pro**: addresses PRESSURES.md armor-asymmetry surface
  cleanly. The matrix's "best/costly/bad answer" structure works
  uniformly across archetypes.
- **Pro**: opens up new depot upgrade slots (one per archetype),
  giving the depot pool more design surface.
- **Con**: REQUIRES NEW UPGRADES per archetype. That's 3-4 new
  depot UpgradeKind values + balancing.
- **Con**: makes the archetypes feel MORE similar at the macro
  level — every archetype follows the same "main weapon + class-
  economy upgrades" pattern.
- **Con**: undoes the iter-73 spine ("every archetype must buy
  passage differently") — they would all buy it the same way.

## Reading (b) — armor-bypass-as-verb (current behavior)

**Leave armor logic in Bullet.gd only.** Each non-DEFAULT
archetype's mechanism IS its armor-bypass — the design intent IS
asymmetric. DEFAULT pays in shell-economy; PRISM pays in time
(beam DPS is slow vs 3hp Heavy); MORTAR pays in positioning
(AoE radius requires aim); RAM pays in HP (close-fire trade).

### Concrete consequences

1. **PRISM** is genuinely SLOWER against Heavy class — the
   continuous beam at 4 Hz × 1 dmg/tick = 0.75s to kill a 3hp
   Heavy under stop-and-fire exposure. That EXPOSURE is the
   cost.
2. **MORTAR** can clear a Heavy with AoE damage (2 per shell)
   in 2 shots — but the 1.5s cadence + parabolic travel time
   means the Heavy may have moved + fired 2-3 return-fire
   bullets in the interval. The TIMING is the cost.
3. **RAM** can collision-damage a Heavy continuously, but each
   collision puts the player in melee-fire range of the
   Heavy's 0.8s-cadence return fire (2 dmg per bullet). The
   TRADE is the cost.
4. **DEFAULT** alone has the SHELL ECONOMY puzzle (AP blocked;
   need HEAT/APCR). The breach economy is the DEFAULT's verb;
   other archetypes have their own verbs that include
   armor-bypass.
5. The depot remains class-based (HE refill, HEAT refill,
   armor-piercing rule-changer for DEFAULT's loadout) — no
   per-archetype-armor-upgrades needed.
6. The 4 archetypes diverge sharply at the macro level — each
   has a DIFFERENT cost structure for "I want to take down a
   Heavy."

### Tradeoffs

- **Pro**: preserves the iter-73 spine ("every archetype must buy
  passage differently"). The asymmetry IS the design.
- **Pro**: no new upgrades needed; current depot pool covers it.
- **Pro**: each archetype "feels" mechanically distinct in the
  Heavy fight because each pays a different cost.
- **Con**: depots can't meaningfully offer "armor-piercing X" as
  a rule-changer for the non-DEFAULT archetypes — they don't
  need it. Some depot-pool design space is lost.
- **Con**: requires the playtester to UNDERSTAND that "PRISM is
  bad at Heavy" is not a bug. Discoverability hazard — the
  on-death prompt + PLAYTEST-5-BRIEF mitigate but don't fully
  resolve.
- **Con**: if Round 11 adds a roster role that PUNISHES exposure
  + has high hp (e.g. armored sniper), the (b) reading puts
  PRISM in an unfair spot — it gets BOTH the time-cost AND the
  exposure punishment.

## Worked-example test (the same encounter under both readings)

A breach scene: 2 Heavies + 3 brick walls between the player and
a depot.

### Under reading (a) — universal armor

| Archetype | Approach                                                                 |
|-----------|--------------------------------------------------------------------------|
| DEFAULT   | Pick HEAT shells; 2 shots clear each Heavy (4 HEAT total); HE for bricks |
| PRISM     | Need "Focused Lens" upgrade — if NOT owned, beam is useless vs Heavies   |
| MORTAR    | Need "AP Shells" upgrade — if NOT owned, AoE deals 0 dmg vs Heavies      |
| RAM       | Need "Armor-Piercing Spike" upgrade — without it, collision deals 0      |

The encounter becomes a depot-economy puzzle: do I have the right
upgrade for this archetype? If not, what do I have? The player's
DECISION is "which upgrades I bought." Identity = upgrade choices.

### Under reading (b) — current behavior

| Archetype | Approach                                                                 |
|-----------|--------------------------------------------------------------------------|
| DEFAULT   | Pick HEAT shells; 2 shots clear each Heavy (4 HEAT total); HE for bricks |
| PRISM     | Stop-and-fire beam, ~0.75s per Heavy = 1.5s exposed; both Heavies fire   |
|           | back during exposure (2-3 return bullets = 4-6 dmg taken)                |
| MORTAR    | Lob AoE between the Heavies (2 dmg each per shell) — 2 shells over 3s    |
|           | clears both; Heavy bullets may impact you during the 3s window           |
| RAM       | Sprint between the Heavies, swing-cone catches both — but melee range    |
|           | = both Heavies return fire at point-blank, costly HP trade               |

The encounter becomes a SKILL puzzle per archetype: can I survive
the exposure time / position the AoE / time the close-fire trade?
The player's DECISION is positioning + timing. Identity = how I
execute the same fight.

## The first-principles question

Both readings give the player meaningful decisions in the Heavy
fight. They give DIFFERENT KINDS of decisions:

- **Reading (a)**: decisions are at depots (which upgrades).
- **Reading (b)**: decisions are at fights (how to execute).

This maps directly onto Consult 008's identity-vs-weapons axis
(REVIEW-QUEUE #15):

- **Reading (a) ≈ ARCHETYPES AS WEAPONS** — switching archetypes
  is like switching shells; the upgrade economy is the meta-game;
  each archetype has its own "load-out" for different threats.
- **Reading (b) ≈ ARCHETYPES AS RUN IDENTITIES** — your archetype
  IS who you are; your skill at executing that archetype is the
  game; switching is dramatic, not routine.

If the playtest 5 quote shape says identity ("I overcommitted as
Prism"), reading (b) reinforces it. If it says weapons ("I
should have switched to Ram"), reading (a) aligns better.

**The armor question is downstream of the identity-vs-weapons
question.** Solving #15 implies the armor answer.

## Recommendation

**Pause on the armor decision until playtest 5 settles REVIEW-
QUEUE #15.** The two questions are linked:
- If #15 → identities → keep reading (b); the asymmetry is the
  point.
- If #15 → weapons → switch to reading (a); add per-archetype
  armor-piercing depot upgrades.

A premature commit to (a) or (b) right now would either:
- Add 3-4 new UpgradeKinds + balancing (a), wasted work if the
  playtest validates (b).
- Codify the asymmetry as design intent in PRESSURES.md +
  RUBRIC (b), wasted documentation if the playtest pushes (a).

This is exactly the situation Pro's H5 was about: **non-trivial
speculative production should be gated on the playtest verdict.**

## Implementation paths (when the decision arrives)

**If (a) gets picked post-playtest:**
1. Enemy.gd: add armor_check method called by take_damage
2. Bullet.gd: keep existing logic (DEFAULT shell economy)
3. PlayerTank.gd PRISM/MORTAR/RAM: NO change (they still call
   take_damage; the wrapper handles the gate)
4. Depot.gd: 3 new UpgradeKinds (FOCUSED_LENS, AP_SHELLS,
   AP_SPIKE) — one per non-DEFAULT archetype
5. Loadout.gd: 3 new flag fields
6. Harness: extend pressure-probes to verify each upgrade
   bypasses armor for its archetype only

**If (b) gets picked post-playtest:**
1. PRESSURES.md "Armor bypass gaps" section: codify the
   asymmetry as DESIGN INTENT not technical debt
2. RUBRIC.md: consider adding a C16 anchor "each archetype's
   armor-fight cost is distinct" — playtest-verifiable
3. PlayerTank.gd: no change
4. Document the design rationale in BANDS.md (cited from C5
   anchor 2)
5. No new UpgradeKinds

Either path is ~3-5 iters. Decision input: playtest 5 verdict
on REVIEW-QUEUE #15.

## What this iter does NOT do

- Does not pick the resolution
- Does not change code
- Does not modify PRESSURES.md or RUBRIC.md
- Does not require user attention NOW — readable when the playtest
  verdict is in
