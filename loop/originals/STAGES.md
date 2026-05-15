# tanke Originals — 35-stage checklist

Per-stage completion tracker. Each stage's checkbox flips when:
- [ ] LevelLoader parses without error
- [ ] Per-cell terrain matches `.research/repos/Tanks/resources/stages/K`
- [ ] Reachability oracle: `playable: true`
- [ ] Eagle placed at canonical position
- [ ] `tools/png_diff.py` reports <5% mismatch vs StrategyWiki reference
- [ ] Enemy roster matches mined Tanks per-stage data

When ALL six gates pass for stage K, mark `[x]` here AND in the LEDGER
iter that completed it.

---

## First third (criterion 7 — 12 stages)

- [ ] Stage 1 — iter ___ ; diff ___% ; notes:
- [ ] Stage 2 — iter ___ ; diff ___% ; notes:
- [ ] Stage 3 — iter ___ ; diff ___% ; notes:
- [ ] Stage 4 — iter ___ ; diff ___% ; notes: contains water (`~`)
- [ ] Stage 5 — iter ___ ; diff ___% ; notes:
- [ ] Stage 6 — iter ___ ; diff ___% ; notes:
- [ ] Stage 7 — iter ___ ; diff ___% ; notes:
- [ ] Stage 8 — iter ___ ; diff ___% ; notes:
- [ ] Stage 9 — iter ___ ; diff ___% ; notes:
- [ ] Stage 10 — iter ___ ; diff ___% ; notes:
- [ ] Stage 11 — iter ___ ; diff ___% ; notes:
- [ ] Stage 12 — iter ___ ; diff ___% ; notes:

## Middle third (criterion 8 — 12 stages)

- [ ] Stage 13 — iter ___ ; diff ___% ; notes:
- [ ] Stage 14 — iter ___ ; diff ___% ; notes:
- [ ] Stage 15 — iter ___ ; diff ___% ; notes:
- [ ] Stage 16 — iter ___ ; diff ___% ; notes:
- [ ] Stage 17 — iter ___ ; diff ___% ; notes:
- [ ] Stage 18 — iter ___ ; diff ___% ; notes:
- [ ] Stage 19 — iter ___ ; diff ___% ; notes:
- [ ] Stage 20 — iter ___ ; diff ___% ; notes:
- [ ] Stage 21 — iter ___ ; diff ___% ; notes:
- [ ] Stage 22 — iter ___ ; diff ___% ; notes:
- [ ] Stage 23 — iter ___ ; diff ___% ; notes:
- [ ] Stage 24 — iter ___ ; diff ___% ; notes:

## Final third (criterion 9 — 11 stages)

- [ ] Stage 25 — iter ___ ; diff ___% ; notes:
- [ ] Stage 26 — iter ___ ; diff ___% ; notes:
- [ ] Stage 27 — iter ___ ; diff ___% ; notes:
- [ ] Stage 28 — iter ___ ; diff ___% ; notes:
- [ ] Stage 29 — iter ___ ; diff ___% ; notes:
- [ ] Stage 30 — iter ___ ; diff ___% ; notes:
- [ ] Stage 31 — iter ___ ; diff ___% ; notes:
- [ ] Stage 32 — iter ___ ; diff ___% ; notes:
- [ ] Stage 33 — iter ___ ; diff ___% ; notes:
- [ ] Stage 34 — iter ___ ; diff ___% ; notes:
- [ ] Stage 35 — iter ___ ; diff ___% ; notes: FINAL — verify "win" state on clear

---

## Symbols present per stage (from quick survey)

Verified during research synthesis:
- Stage 1: `#@` (brick + steel only)
- Stage 4: `@#%~` (steel + brick + forest + water)
- Stage 18: `@#%` (steel + brick + forest; no water/ice)

Stages with `-` (ice) — unknown until parsed. The first iter that
encounters ice triggers the phase-1 ice-physics decision iter (criterion 3).

---

## Cross-validation strategy

For each stage K:
1. Parse `.research/repos/Tanks/resources/stages/K` → tanke render
2. Download `https://strategywiki.org/wiki/File:Battle_City_Stage{K:02}.png`
3. `tools/png_diff.py StageK_render.png StageKK.png` → per-tile match %

If diff < 5%: mark complete.
If 5-15%: investigate; usually one source has different convention.
If > 15%: stage F-numbered; hand-resolve from Selmiak/GameFAQs as tiebreaker.

Tank 1990 disambiguation: if any source has stage 36+ or doesn't match
13×13 logical grid → REJECT (per arc-3 PROMPT anti-pattern).
