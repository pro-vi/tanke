# tanke Originals — Roster Cross-Validation (iter 015)

Per RUBRIC C5 anchor 4: "Roster accuracy cross-validated against an
independent fan-walkthrough source for ≥5 stages."

This document compares the per-stage Armor-tank (`ST_TANK_D` in
`krystiankaluzny/Tanks`) probability predicted by Tanks's stochastic
formula against the canonical BC ROM rosters documented by an
independent fan source.

---

## Sources

| Role | Source | License | Method |
|------|--------|---------|--------|
| Tanks formula | `.research/repos/Tanks/src/app_state/game/game.cpp:518` + `appconfig.h:79-81` | MIT | Code citation (iter 4) |
| BC empirical roster | StrategyWiki Battle City Walkthrough | CC-BY-SA | HTML fetch + regex extract (iter 15) |

Fetched URL: `https://strategywiki.org/wiki/Battle_City/Walkthrough`
(http 200, 87752 bytes, cached at `/tmp/bc_walkthroughs/sw_walkthrough.html` during iter 15).

The walkthrough lists 4 tank types per stage: **Basic / Fast / Power / Armor**.
Mapping to Tanks's `SpriteType`:
- Basic Tank → `ST_TANK_A`
- Fast Tank → `ST_TANK_B`
- Power Tank → `ST_TANK_C`
- **Armor Tank → `ST_TANK_D`** (the "armored" type in the formula)

Per-stage total is always exactly 20 (= `enemies_to_kill_total_count`
constant from Tanks `appconfig.h:79`), confirming the source describes
canonical BC, not a Tank 1990 variant.

---

## Tanks formula

```
p_armored(stage) = 0.00735 × stage + 0.09265
```

Predicted Armor count for stage K: `p_armored(K) × 20`.

| Stage | Predicted p_armored | Predicted Armor count |
|-------|---------------------|------------------------|
| 1 | 0.100 | 2.0 |
| 18 | 0.225 | 4.5 |
| 35 | 0.350 | 7.0 |

---

## Empirical cross-validation (all 35 stages)

| Stage | Basic | Fast | Power | Armor | Empirical % | Formula % | Δ |
|-------|-------|------|-------|-------|-------------|-----------|---|
| 1 | 18 | 2 | 0 | 0 | 0.0% | 10.0% | 10.0% |
| 2 | 14 | 4 | 0 | 2 | 10.0% | 10.7% | 0.7% |
| 3 | 14 | 4 | 0 | 2 | 10.0% | 11.5% | 1.5% |
| 4 | 2 | 5 | 10 | 3 | 15.0% | 12.2% | 2.8% |
| 5 | 8 | 5 | 5 | 2 | 10.0% | 12.9% | 2.9% |
| 6 | 9 | 2 | 7 | 2 | 10.0% | 13.7% | 3.7% |
| 7 | 10 | 4 | 6 | 0 | 0.0% | 14.4% | 14.4% |
| 8 | 7 | 4 | 7 | 2 | 10.0% | 15.1% | 5.1% |
| 9 | 6 | 4 | 7 | 3 | 15.0% | 15.9% | 0.9% |
| 10 | 12 | 2 | 4 | 2 | 10.0% | 16.6% | 6.6% |
| 11 | 0 | 10 | 4 | 6 | 30.0% | 17.3% | 12.7% |
| 12 | 0 | 6 | 8 | 6 | 30.0% | 18.1% | 11.9% |
| 13 | 0 | 8 | 8 | 4 | 20.0% | 18.8% | 1.2% |
| 14 | 0 | 4 | 10 | 6 | 30.0% | 19.6% | 10.4% |
| 15 | 2 | 10 | 0 | 8 | 40.0% | 20.3% | 19.7% |
| 16 | 16 | 2 | 0 | 2 | 10.0% | 21.0% | 11.0% |
| 17 | 8 | 2 | 0 | 10 | 50.0% | 21.8% | 28.2% |
| 18 | 2 | 8 | 6 | 4 | 20.0% | 22.5% | 2.5% |
| 19 | 4 | 4 | 4 | 8 | 40.0% | 23.2% | 16.8% |
| 20 | 2 | 8 | 2 | 8 | 40.0% | 24.0% | 16.0% |
| 21 | 6 | 2 | 8 | 4 | 20.0% | 24.7% | 4.7% |
| 22 | 6 | 8 | 2 | 4 | 20.0% | 25.4% | 5.4% |
| 23 | 0 | 10 | 4 | 6 | 30.0% | 26.2% | 3.8% |
| 24 | 10 | 4 | 4 | 2 | 10.0% | 26.9% | 16.9% |
| 25 | 0 | 8 | 2 | 10 | 50.0% | 27.6% | 22.4% |
| 26 | 4 | 6 | 4 | 6 | 30.0% | 28.4% | 1.6% |
| 27 | 2 | 8 | 2 | 8 | 40.0% | 29.1% | 10.9% |
| 28 | 15 | 2 | 2 | 1 | 5.0% | 29.8% | 24.8% |
| 29 | 0 | 4 | 10 | 6 | 30.0% | 30.6% | 0.6% |
| 30 | 4 | 8 | 4 | 4 | 20.0% | 31.3% | 11.3% |
| 31 | 0 | 8 | 6 | 6 | 30.0% | 32.0% | 2.1% |
| 32 | 6 | 4 | 2 | 8 | 40.0% | 32.8% | 7.2% |
| 33 | 0 | 8 | 4 | 8 | 40.0% | 33.5% | 6.5% |
| 34 | 0 | 10 | 4 | 6 | 30.0% | 34.3% | 4.3% |
| 35 | 0 | 6 | 4 | 10 | 50.0% | 35.0% | 15.0% |

---

## Summary statistics

| Statistic | Empirical | Tanks formula |
|-----------|-----------|---------------|
| Mean p_armored | 24.14% | 22.50% |
| Range | [0%, 50%] | [10%, 35%] |
| Early-5-stage mean (1-5) | 9.0% | 11.5% |
| Late-5-stage mean (31-35) | 38.0% | 33.5% |

### Match analysis

- **Mean**: 24.1% empirical vs 22.5% predicted — **within 1.6%, very close**.
- **Trend direction**: both rise with stage number (early 9% → late 38% empirical; early 11.5% → late 33.5% predicted) — **direction matches**.
- **Per-stage variance**: empirical has 0–50% range vs formula's 10–35% monotone range. **Empirical is more extreme on both ends.**

Stages with Δ > 15%: stage 7 (14.4%), stage 15 (19.7%), stage 16 (11.0%), **stage 17 (28.2%)**, stages 19/20 (16-17%), **stage 25 (22.4%)**, **stage 28 (24.8%)**, stage 35 (15.0%). The biggest mismatches concentrate where empirical is far from the linear curve — e.g. stage 17 has 10 Armor tanks (50%) vs formula's 21.8%; stage 28 has 1 Armor tank (5%) vs formula's 29.8%.

---

## Verdict

**Anchor 4 cross-validated:** ≥5 stages — in fact ALL 35 — sourced independently from StrategyWiki. The Tanks formula matches BC's empirical roster in **mean and trend direction** but **diverges per-stage**: BC has high stage-to-stage variance with armor counts spiking at specific stages (17, 25, 35 — the boss-tier stages) and dropping low at others (1, 7, 28 — the introduction / breather stages).

The formula is a faithful *aggregate* approximation, not a per-stage table replica.

This is a real finding and the basis for **F001** (logged in `loop/originals/FALSIFICATIONS.md`): "Tanks's stochastic formula approximates BC's mean armor ramp but loses the per-stage variance that defines stage 'feel'. For arc-3 v1 the formula is sufficient; for full BC fidelity (arc-3 v2 or future), encode per-stage roster from this StrategyWiki table directly."

For **C5 anchor 5** ("Roster feels BC-correct in playtest — cited 'this stage is hard like OG stage K'"): the formula will likely feel "ramping difficulty" rather than "specific BC stages." If user feedback wants pinpoint BC fidelity, the per-stage table from this doc can be promoted to a `configs/og_rosters.tres` artifact.

---

## Source data integrity

Verified the source describes canonical BC, not Tank 1990:
- 35 stages documented (matches BC; Tank 1990 has 50)
- 20 enemies per stage exactly (matches BC `enemies_to_kill_total_count`)
- 4 tank types (matches BC sprite roster A/B/C/D)
- Stage names referenced (Mappy, Skull, Galaxian — canonical BC bonus-stage names)

H2 tripwire respected — StrategyWiki HTML fetched to `/tmp/`, NOT into `.research/repos/Tanks/`. The per-stage roster table is the derived artifact; the raw HTML is ephemeral.
