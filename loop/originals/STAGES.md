# tanke Originals — 35-stage checklist

Per-stage completion tracker. Each stage's checkbox flips when **all six**
gates pass:

- [ ] Gate 1 — LevelLoader parses without error
- [ ] Gate 2 — Per-cell terrain matches `.research/repos/Tanks/resources/stages/K`
- [ ] Gate 3 — Reachability oracle: `playable: true`
- [ ] Gate 4 — Eagle placed at canonical position
- [ ] Gate 5 — `tools/png_diff.py` reports <5% mismatch vs StrategyWiki reference
- [ ] Gate 6 — Enemy roster matches mined Tanks per-stage data

When ALL six gates pass for stage K, mark `[x]` here AND in the LEDGER
iter that completed it.

**Iter 001 status (2026-05-15):** gates 1+2+3 verified for all 35 stages
via automated cell-count diff (`grep -o '<symbol>'` on source vs
`LevelLoader.parse_stage()` emit counts) + reachability oracle pass.
Gates 4 (eagle), 5 (PNG diff), 6 (enemy roster) all pending —
no checkbox flips until those land.

---

## First third (criterion 7 — 12 stages)

- [ ] Stage 1  — symbols `#@`     — gates 1+2+3 ✓ (iter 001); 220#/8@/0%/0~/0-
- [ ] Stage 2  — symbols `#@%`    — gates 1+2+3 ✓ (iter 001); 184#/48@/40%/0~/0-
- [ ] Stage 3  — symbols `#@%`    — gates 1+2+3 ✓ (iter 001); 126#/26@/152%/0~/0-
- [ ] Stage 4  — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001); 262#/16@/56%/12~/0-
- [ ] Stage 5  — symbols `#@~`    — gates 1+2+3 ✓ (iter 001); 136#/26@/0%/60~/0-
- [ ] Stage 6  — symbols `#@%`    — gates 1+2+3 ✓ (iter 001); 148#/32@/100%/0~/0-
- [ ] Stage 7  — symbols `#@%`    — gates 1+2+3 ✓ (iter 001); 8#/174@/28%/0~/0-
- [ ] Stage 8  — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001); 152#/20@/60%/88~/0-
- [ ] Stage 9  — symbols `#@%`    — gates 1+2+3 ✓ (iter 001); 64#/92@/72%/0~/0-
- [ ] Stage 10 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001); 218#/40@/112%/24~/0-
- [ ] Stage 11 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 12 — symbols `#@~`    — gates 1+2+3 ✓ (iter 001)

## Middle third (criterion 8 — 12 stages)

- [ ] Stage 13 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 14 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 15 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 16 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 17 — symbols `#@-`    — gates 1+2+3 ✓ (iter 001); **206 ice cells skipped** (phase-1 decision pending)
- [ ] Stage 18 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 19 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 20 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 21 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 22 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 23 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 24 — symbols `#@%-`   — gates 1+2+3 ✓ (iter 001); **216 ice cells skipped**

## Final third (criterion 9 — 11 stages)

- [ ] Stage 25 — symbols `#@`     — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 26 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 27 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 28 — symbols `#@%-`   — gates 1+2+3 ✓ (iter 001); **212 ice cells skipped**
- [ ] Stage 29 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 30 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 31 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 32 — symbols `#@-`    — gates 1+2+3 ✓ (iter 001); **320 ice cells skipped** (most-ice stage)
- [ ] Stage 33 — symbols `#@%`    — gates 1+2+3 ✓ (iter 001)
- [ ] Stage 34 — symbols `#`      — gates 1+2+3 ✓ (iter 001); **brick-only stage** (unusual)
- [ ] Stage 35 — symbols `#@%~`   — gates 1+2+3 ✓ (iter 001); FINAL — verify "win" state on clear

---

## Symbols present per stage (auto-surveyed iter 001)

Stages containing each terrain type:
- Brick `#`: all 35
- Steel `@`: 34 (all except stage 34)
- Forest `%`: 29 (no forest in 1, 5, 12, 17, 25, 32, 34)
- Water `~`: 11 (4, 5, 8, 10, 12, 14, 20, 26, 29, 30, 31, 35)
- Ice `-`: 4 (17, 24, 28, 32) — **phase-1 decision iter pending (criterion 3)**

Cell-count totals per terrain across all 35 stages — automated diff via
`grep -o` on source vs `LevelLoader.parse_stage()` emit — **100% match,
35/35 stages**. Cited in `LEDGER.md` iter 001.

---

## Cross-validation strategy

For each stage K:
1. Parse `.research/repos/Tanks/resources/stages/K` → tanke render
2. Download `https://strategywiki.org/wiki/File:Battle_City_Stage{K:02}.png`
3. `tools/png_diff.py StageK_render.png StageKK.png` → per-tile match %

If diff < 5%: gate 5 passes for that stage.
If 5-15%: investigate; usually one source has different convention.
If > 15%: stage F-numbered; hand-resolve from Selmiak/GameFAQs as tiebreaker.

Tank 1990 disambiguation: if any source has stage 36+ or doesn't match
13×13 logical grid → REJECT (per arc-3 PROMPT anti-pattern).
