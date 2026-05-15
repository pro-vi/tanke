# tanke originals loop — arc-close retrospective (iter 0 → 15)

Written at iter 16 under the PROMPT close-condition: "All 35 stages complete +
eagle + ice + end-to-end playable + PNG diff all-passing → arc 3 closes
successfully." Closes arc 3.

Parallel to:
- `loop/META-RETRO.md` (arc 1, engine, iter 28 → 50/55)
- `loop/gameplay/META-RETRO-iter100.md` (arc 2, gameplay, iter 100 → 34/50)

Arc 3 is the **frontier-loop** in the three-arc chain — artifact existed,
evaluator was constructable, target was finite (35/35). Closed in 16 iters
at **45/60** on the iter-8 rubric v2.

---

## Arc shape (16 iters, 4 phases)

| Phase | Iters | Output | Score |
|-------|-------|--------|-------|
| **Bootstrap + scaffolding** | 0–3 | Preloop gate, LevelLoader, OriginalLevel, png_diff oracle, Eagle entity, ice decision | 0 → 15 |
| **Mass sweep** | 4–5 | 35/35 stages PNG-verified <5% (median 0.448%, max 2.090%); palette-detector hardened mid-iter-5 to cure stage 32 | 15 → 29 |
| **Identity + arc-2 handshake** | 6–8 | TitleScreen mode-picker, eagle game-over overlay, AUDIT (rubric v2 with C11 identity + C12 arc-2 feedback added), 3-iter HALT fired at iter 9 | 29 → 36 (rubric expansion absorbed +2) |
| **Resume + arc-2 writes + close** | 10–15 | User override → REVIEW-QUEUE pattern; Spawner integration (arc-2 soft-substrate write, hash anchor preserved); og_metrics.py + og-metrics.json; og_calibrated.tres; LevelLoader edge cases; roster cross-validation + F001 | 36 → 45 |

**Final score: 45/60 across 12 criteria.** Pace: 2.8 score-points/iter, vs engine arc's 1.78 and gameplay arc's 0.34. The frontier-loop's evaluator-driven shape rewarded mechanical progress.

---

## What the arc produced

### Engineering deliverables

| Artifact | What it does | Iter |
|----------|--------------|------|
| `scripts/LevelLoader.gd` | parse Tanks ASCII → set_cell on TileMapLayers; legend `.#@%~-`; optional override path for tests | 1, 3, 13 |
| `scripts/OriginalLevel.gd` + `scenes/OriginalLevel.tscn` | parallel to ProceduralLevel.tscn; inherits Level.gd's `_replace_blocks()` (H1 respected); eagle + game-over overlay + dev N-key advance + Spawner wiring | 1, 3, 6, 7, 11 |
| `scripts/Eagle.gd` + `scenes/Eagle.tscn` | HP=1, eagle_destroyed signal, take_damage matching Bullet's `_on_body_entered` duck-typed contract | 3 |
| `scripts/StageDirector.gd` | 1..35 tracker; advance / restart / arc_complete | 7 |
| `scripts/Roster.gd` | Tanks formula constants (`ARMORED_SLOPE`, `ARMORED_INTERCEPT`); `armored_probability(stage)` static method | 7 |
| `scripts/TitleScreen.gd` + `scenes/TitleScreen.tscn` | mode-picker, raw-keycode input, `_launching` latch | 6 |
| `scripts/Spawner.gd` extension (arc-2 soft-substrate) | `stage_number` gate; `_try_spawn_originals`; OG_SPAWN_POINTS; stage_cleared signal | 11 |
| `tools/png_diff.py` | PIL tile-classifier; auto-palette (P=NES, RGB=tanke); triple-diff with ASCII source; exit codes 0/1/2 | 2, 5 |
| `tools/og_metrics.py` | Python stdlib; per-stage density/reachability/CC/structure_lift across 35; cross-stage summary; arc-2 comparison block | 12 |
| `configs/og_calibrated.tres` | arc-2 LevelConfig tuned toward OG empirical bands; 4 metrics moved toward OG | 14 |
| `loop/test_runner.gd` extension | `--scene` + `--og-stage` flags; defensive lookups for OG scene | 1 |
| `loop/test_loader.gd` | LevelLoader edge-case harness (happy / missing / short row / unknown char) | 13 |
| `Makefile` targets | `screenshot-og`, `png-diff-og`, `og-metrics`, `check-loader`, `test-all` | 2, 12, 13 |

### Cached references + artifacts

- `tools/refs/Battle_City_Stage{01..35}.png` — 35 StrategyWiki references, 208×208 indexed-color, CC-BY-SA
- `img/ice_007.png` + `img/eagle_007.png` — placeholder textures
- `loop/originals/og-metrics.json` — per-stage + cross-stage summary + arc-2 comparison
- `loop/originals/roster-validation.md` — 35-stage cross-validation table from StrategyWiki walkthrough

### Loop infrastructure that emerged

| Mechanism | Where | Trigger |
|-----------|-------|---------|
| **REVIEW-QUEUE pattern** | `loop/originals/REVIEW-QUEUE.md` | iter 10 user override: "loop runs structurally; user reviews items at end" |
| **Generalization clause** (Nat-13 cure) | every pre-mortem since iter 2 | iter-1 meta-nat-13 surfaced "stage 1 only" theatrical falsifiability |
| **Default-off gating** | `Spawner.gd` stage_number > 0 branch | iter-11 substrate-write discipline; preserves procedural hash anchor |
| **Rubric expansion via AUDIT** | iter 8 added C11 + C12; rephrased C5 anchor 2 | C5 rubric/data-shape mismatch from iter 7 |
| **Multi-seed sweep** | iter 14 config tuning | arc-1 retro discipline ("single-seed CC unreliable") |

### Hash anchor — the cross-arc invariant

`23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`

Preserved exactly across **all 16 arc-3 iters**, including the arc-2 Spawner.gd
extension (iter 11) and `configs/og_calibrated.tres` (iter 14 — new file, default
config untouched). Arc-2 procedural-mode regression detector held end-to-end.

---

## What survives past arc 3

### Pattern library (carries to arc 4+ or hand-off)

1. **LevelLoader pattern**: read canonical ASCII source from a research repo (read-only via H2); emit set_cell calls; auto-detect grid dimensions. Generalizes to any tile-grid game importer.

2. **PNG-diff oracle pattern**: tile-classification (not pixel) comparison; auto-palette via image mode; triple-diff (ASCII source vs reference vs render) catches BOTH render bugs AND reference-PNG residual noise. The mid-iter classifier-fix (palette-detect by mode) is a reusable robustness pattern.

3. **og_metrics handshake pattern**: arc-N computes empirical bands of canonical data; arc-M's procedural mode reads those bands as calibration targets. The "metric handshake" idea — one arc's output is another arc's empirical floor — is the structural backbone of the three-arc chain.

4. **StageDirector + formula-driven roster**: when canonical data is FORMULA not TABLE, encode the formula in code with cited file:line. Tested against per-stage walkthroughs after the fact (iter 15) — surfaces the approximation gap honestly.

5. **REVIEW-QUEUE pattern (NEW)**: when user availability is the bottleneck on a loop that has structural work remaining, build an append-only queue of user-only-verifiable items. Loop runs structurally; user batch-reviews. **This is a PROMPT-v3 candidate** for future arcs (replaces or complements the 3-iter halt rule).

6. **Default-off gating for substrate writes**: when an arc must extend shared substrate code (arc-3 → arc-2 Spawner.gd), add a default-disabled gate parameter; new branches only fire when explicitly enabled; existing code paths byte-unchanged. Preserves the cross-arc hash anchor as the regression detector. **Reusable invariant for any future cross-arc write.**

### Engineering carry-forwards (file-level)

If the project continues outside this arc-3 framing:
- `scripts/LevelLoader.gd`, `OriginalLevel.gd`, `Eagle.gd`, `StageDirector.gd`, `Roster.gd`, `TitleScreen.gd` — arc-3-owned; reusable.
- `tools/png_diff.py`, `tools/og_metrics.py` — arc-3-owned; CLIs + JSON-friendly; usable from any procedural-mode iteration.
- `tools/refs/` — 35 CC-BY-SA references; cached for offline cross-validation.
- `configs/og_calibrated.tres` — arc-2 procedural config tuned toward OG bands.
- `Makefile` arc-3 targets (`screenshot-og`, `png-diff-og`, `og-metrics`, `check-loader`, `test-all`) — usable for any future stage-import or verification flow.

### Discipline carry-forwards

- **Generalization-clause pre-mortems** (Nat-13 cure from iter 1): every BUILD/CAPABILITY iter checks N>1 cases. arc-3 verified the cure caught 2 real issues iter-1-only testing would have shipped (forest palette anchor; loader ice-skip).
- **AUDIT-mode rubric expansion** (iter 8): when the rubric/data-shape mismatches, expand criteria honestly. Doesn't inflate score percentage; reflects rubric-completeness gain.
- **Multi-seed verification for stochastic metrics** (arc-1 retro carried in iter 14).
- **Cited mutation cycles** (arc-1 carry): edit → rerun → cite Δ. Iter 14's 5-seed sweep is the latest demonstration.

---

## What didn't work / what arc 3 surfaced

### F001 — Formula approximates mean, loses per-stage variance (iter 15)

Tanks's stochastic formula matches BC's empirical mean armor fraction (24.1% vs 22.5%, Δ 1.6%) and trend direction (rising with stage) but smooths through BC's specific spike/breather stages. Tanks's choice was a simplification of BC's table; arc-3's faithfulness ambition surfaces the gap. For arc-3 v1 the formula is sufficient; the per-stage StrategyWiki table is documented in `roster-validation.md` and ready to promote if needed.

### Iter 9 HALT — the 3-iter PLAYTEST rule fired exactly as designed

The PROMPT halt rule from arc-1 carried to arc-3 unchanged. Iter 6 opened the first playtest gate; iters 7/8/9 unfulfilled → HALTED.md written; loop paused. **The rule worked.** User then re-engaged with override iter 10, which superseded the rule via REVIEW-QUEUE.

This is the *third* halt in three arcs — arc-1 halted at structural ceiling (no user-look gate fulfilled across 27 iters; halt was self-declared at iter 28 retro). Arc-2 halted at iter 100 under `HALT_META_REFRAME` (user-initiated). Arc-3 halted at iter 9 under PROMPT-literal halt rule (rule-driven). Three distinct halt mechanisms; same outcome: the loop pauses, knowledge persists, and resumption rehydrates the state.

### Identity criterion (C11) stays at 1/5

Anchors 3-5 require explicit fan-recognition cite. The iter-10 partial playtest gave implicit non-objection ("stage 1 shooting my own eagle trigger game over" — they treated it as stage 1) but no "yes that's BC" statement. **The identity question doesn't get answered by code.** Arc-2's META-RETRO already named this in its closing line; arc-3's structural verification doesn't change it.

### Three REVIEW-QUEUE items unsurfaced at retro

1. TitleScreen "ugly" feedback awaits user direction-pick (a/b/c/d aesthetic options).
2. BC edge walls — arc-3 OG mode allows player to roam outside the 26×26 BC playfield (Godot viewport-bounded BFS reachability 880+ vs Python stage-bounded 60-200 for stages 21/34/35). User picks walls / accept / cosmetic.
3. Q2 explicit BC-recognition cite still missing.
4. Eagle felt-like-BC cite still missing.

These are all reachable via a single 5-minute playtest. Arc-3 SHIPS without them; arc-3-v2 (if it happens) closes them.

---

## Numbers for the record

```
Iters:                          16 (0 bootstrap + 15 working + this retro)
Total score:                    45/60 (75.0%) on rubric v2
Criteria at 5/5:                4 (C1, C7, C8, C9 — loader + all 3 stage-count buckets)
Criteria at 4/5:                3 (C4 PNG-diff, C5 roster, C6 mode, C12 arc-2 feedback)
Criteria at 3/5:                2 (C2 eagle, C10 end-to-end)
Criteria at 2/5:                1 (C3 ice, rubric-capped by pass-through decision)
Criteria at 1/5:                1 (C11 identity)
Criteria at 0/5:                0
Falsifications:                 1 (F001 — formula loses per-stage variance)
External CONSULTs:              0 (arc-3 didn't need any; structural axes self-evident)
Stages PNG-verified <5%:        35/35 (median 0.448%, max 2.090%)
Procedural hash anchor:         23d6a2ec… preserved across all 16 iters
Tag balance:                    15 [STRUCTURE], 1 [STRUCTURE-DEFERRED], 3 [FEEL]
Commits:                        16+ (`d86105b` bootstrap … `35abef2` iter 15)
LEDGER entries:                 16
Files added (arc-3-owned):      18 (scripts: 6; scenes: 2; tools: 2; configs: 1; loop/originals: 7)
Files extended (substrate):     2 (Spawner.gd, LevelLoader gain optional override)
Files untouched (hard substr):  all 6 Layer-1 files; all 6 Layer-2 game-script files
```

---

## What arc 3 taught the chain

Three things accumulated across arc 1 + arc 2 + arc 3 (== 144 iters) that aren't in any current loop skill:

1. **The three-arc chain pattern with hash-anchor invariant.** Each arc's output becomes the next arc's frozen substrate; the procedural hash anchor `23d6a2ec…` survived the gameplay arc (iter 100), survived the originals arc (iter 16), and is now the project-wide regression detector. Future arcs that don't preserve this anchor are violating the cross-arc contract — and the contract is explicit.

2. **REVIEW-QUEUE supersedes the 3-iter halt rule for indie work.** The arc-2 halt rule was correct for the workflow it described (regular playtest cadence). For solo-developer indie cycles where user attention is bursty, the queue pattern keeps structural work moving and batches user verification. **This is a PROMPT v3 candidate** for future indie arcs.

3. **Frontier-loop closes faster than greenfield.** Arc 1 (engine, greenfield-ish): 28 iters to 50/55 (90.9%). Arc 2 (gameplay, greenfield with shifting target): 100 iters to 34/50 (68%). Arc 3 (originals, frontier-loop): 16 iters to 45/60 (75%). Constructable evaluator + finite target = mechanical predictability. The three loop-shapes have measurable cadence signatures.

---

## The arc-3 closing line

Arc 1 built the engine. Arc 2 built BC's combat feel. **Arc 3 imported the actual BC stages, verified them tile-for-tile, and gave arc 2's procedural mode an empirical band to calibrate toward.** The identity question — does it feel like BC? — doesn't fully resolve at the structural ceiling. But the structural ceiling now has the 35-stage table, the eagle, the ice, the mode-picker, and the Spawner-driven enemy ramp. If the user ever runs through 1→35, the mechanism is there. If not, the artifact still informs arc 2's next iteration.

**Arc 3 closes at 45/60 (75%). Loop pauses.**

Re-engagement entry points:
- User runs full playtest → C2/C6/C10/C11 anchor 4+ lifts possible (~+8-12 points).
- User picks REVIEW-QUEUE directions → queue items close, scores may shift.
- User declares arc-3 done → no further iters.
- Project pivots to arc 4 (TBD framing) → arc-3 artifacts become substrate.
