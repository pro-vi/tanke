# tanke — Originals Loop FALSIFICATIONS (arc 3)

Append-only. F-numbered findings where a prediction or assumption was
empirically refuted. Tag with [STRUCTURE] / [FEEL] / [MIXED] /
[STRUCTURE-DEFERRED] per arc-2 H2 RULE v2.

Parallel to `loop/FALSIFICATIONS.md` (arc 1, engine — F001-F004) and
`loop/gameplay/FALSIFICATIONS.md` (arc 2, gameplay — F001-F014).

---

## F001 — Tanks roster formula approximates mean but loses per-stage variance

**Iter:** 015
**Tag:** [STRUCTURE]
**Predicted:** Iter-4 cited the Tanks formula (`p_armored(stage) = 0.00735 × stage + 0.09265`) as the canonical BC enemy-roster representation. iter-7's `scripts/Roster.gd` and iter-11's Spawner integration both treat the formula as faithful.

**Observed:** Iter-15 cross-validation against StrategyWiki's per-stage walkthrough revealed:
- **Mean armor fraction matches**: 24.1% empirical vs 22.5% predicted (Δ 1.6%).
- **Trend direction matches**: empirical and predicted both rise monotonically with stage number.
- **Per-stage variance diverges**: empirical range [0%, 50%] vs formula [10%, 35%]. Specific stages mismatch by >20%:
  - Stage 17: 50% empirical vs 21.8% predicted (Δ 28.2%)
  - Stage 25: 50% empirical vs 27.6% predicted (Δ 22.4%)
  - Stage 28: 5% empirical vs 29.8% predicted (Δ 24.8%) — opposite direction
- BC's roster has specific "spike" stages (17, 25, 35) and "breather" stages (1, 7, 28); the formula smooths through these.

**Implication:**
- The formula is a faithful AGGREGATE approximation; **not** a per-stage table replica.
- For arc-3 v1, the formula is sufficient for the "increasing difficulty curve" feel.
- For full BC fidelity (arc-3 v2 or future), the per-stage roster from `loop/originals/roster-validation.md` could be promoted to a `configs/og_rosters.tres` artifact and `Roster.gd` extended to read per-stage data.

**Lesson:** stochastic formulas sourced from a derivative repo (Tanks's C++) capture *trend* but discarding *variance* matters for "this stage felt like BC Stage K" cite (C5 anchor 5, currently held at 4). The Tanks codebase's design choice — formula over table — was a simplification; arc-3's faithfulness ambition surfaces the gap.

**Action:**
- Logged here as F001 (the first arc-3 falsification).
- Documented in `loop/originals/roster-validation.md` with full per-stage table.
- REVIEW-QUEUE item NOT added — this isn't blocked on user input; it's an explicit known-approximation that the v1 formula is good enough for.
- If arc-3 v2 happens, the per-stage table is ready to promote to a config artifact.
- **Iter 17 update**: cure-path made concrete via `loop/originals/og_rosters.json` (35 entries, machine-readable, ready for any future consumer).

---

## F002 — Eagle doesn't hug bottom border (arc-3 viewport position bug)

**Iter:** 018
**Tag:** [STRUCTURE]
**Source:** user playtest 2026-05-16 reply: "the base does not hug border".

**Predicted (implicit, iter-1 design):** Centering the 26×26 BC stage in the 40×30 (320×240) tanke viewport with `col_offset=7, row_offset=2` would produce a visually-natural BC playfield. The 7-col horizontal border was deliberate (centering). The 2-row vertical offset was an arbitrary choice that left 2 rows of gray below the stage.

**Observed:** User saw the eagle fortress (stage rows 24-25 cols 11-14) at scene rows 26-27, NOT at the bottom of the viewport. Visually wrong — in actual BC the eagle is at the very bottom of the screen.

**Fix path (deferred to iter 19+ — multi-file coordinated change):**
1. `scenes/OriginalLevel.tscn`: `row_offset` export `2 → 4`; PlayerTank.position `(124, 212) → (124, 232)`; BC wall positions adjust (BCTopWall y=12→28, BCBottomWall y=228→244 OR delete since outside viewport).
2. `scripts/OriginalLevel.gd`: `EAGLE_SCREEN_POS` constant `(160, 216) → (160, 232)`.
3. `scripts/Spawner.gd`: `OG_SPAWN_POINTS` const — stage-row-1 spawn points y `28 → 44`.
4. `tools/png_diff.py`: `RENDER_OFFSET_Y` constant `16 → 32`.
5. Re-render + re-PNG-diff all 35 stages to verify <5% still holds.
6. Re-verify player passability at new spawn position (stage rows 24-25 cols 8-9 across all 35).

**Lesson:** The iter-1 row_offset=2 was an arbitrary visual choice that the user playtest caught immediately. "Eagle hugs border" is a BC-identity cue that arc-3 should preserve.

**Action:** Logged here; defer fix to next BUILD iter that the user OKs (or wraps into iter 19's general fix-iter if they continue).

**STATUS update iter 019**: FIXED. row_offset 2→4 applied across all 4 files (`OriginalLevel.tscn`, `OriginalLevel.gd`, `Spawner.gd`, `tools/png_diff.py`); PlayerTank position (124, 212) → (124, 228); EAGLE_SCREEN_POS (160, 216) → (160, 232); OG_SPAWN_POINTS y 28 → 44; RENDER_OFFSET_Y 16 → 32; BC walls re-centered to match new playfield bounds (BCLeft/Right at y=136; BCTop at y=28; BCBottom at y=244). Full 35-stage PNG-diff re-run: all 35 PASS <5% (in fact median improved from 0.448% to ~0.5-1%, likely from new cell-alignment between player/eagle/walls and the play area). Procedural hash anchor 23d6a2ec… preserved.

---

## F003 — Arc-2 ascender HUD renders in Originals mode

**Iter:** 018
**Tag:** [STRUCTURE]
**Source:** user playtest 2026-05-16: "depth somehow still applies but of course useless in this mode".

**Predicted (implicit, iter-1 design):** OriginalLevel.tscn inherits PlayerTank.tscn from the arc-2 player. The arc-2 PlayerTank.gd has a baked-in CanvasLayer HUD (DEPTH / TIME / HP / death overlay) per arc-2 iter-30+ design. iter-1 didn't think about whether that HUD should appear in OG mode.

**Observed:** The arc-2 HUD renders in Originals mode even though there's no ascent — the depth counter increments meaninglessly. Visual noise that conflicts with BC's authentic HUD-on-the-right-side layout.

**Fix path (deferred to iter 19+ — touches arc-2 substrate):**
1. `scripts/PlayerTank.gd`: gate the HUD draw on a public `show_ascender_hud: bool = true` @export. Default true preserves arc-2 procedural behavior exactly.
2. `scenes/OriginalLevel.tscn`: set the PlayerTank instance's `show_ascender_hud = false`.
3. Optional: replace with a BC-authentic HUD (LIVES / SCORE / STAGE # / remaining-enemies counter on the right side).
4. Verify procedural hash anchor `23d6a2ec…` preserved (default-off discipline like iter-11's Spawner integration).

**Lesson:** Arc-2's PlayerTank substrate has gameplay-coupled HUD baked in. Future cross-arc reuse needs HUD-modularity. Same lesson as iter-11's Spawner — substrate carries assumptions; gating extends them safely.

**Action:** Logged here; defer to iter 19+ if user OKs the arc-2 substrate write. Could also be addressed by a HUD-replacement approach (different feel, but no arc-2 substrate touch).

**STATUS update iter 019**: FIXED. Second sanctioned arc-2 soft-substrate write per PROMPT Layer-2 spec (after iter-11 Spawner). Added `@export var show_ascender_hud: bool = true` to `scripts/PlayerTank.gd`; gated DepthLabel + TimeLabel creation in `_setup_hud()` on the flag. Default value preserves arc-2 procedural behavior bit-identical. `scenes/OriginalLevel.tscn` PlayerTank instance overrides to `show_ascender_hud = false`. Verified: OG render top-right HUD region has **0 bright text pixels**; procedural render has **503** (unchanged). Procedural hash anchor 23d6a2ec… preserved.

---

## F004 — Player escapes BC playfield (queue #5 confirmed)

**Iter:** 018
**Tag:** [STRUCTURE]
**Source:** user playtest 2026-05-16: "i can drive off border".

**Predicted (queue #5 from iter 12):** arc-3 OG mode centers the 26×26 BC stage in the 40×30 viewport with empty borders all around. Player tank can drive into those borders. The iter-12 Python BFS measurement (stage-bounded) vs Godot oracle (viewport-bounded) divergence flagged this gap. Queue #5 awaited user direction (a/b/c).

**Observed:** Confirmed during playtest — player drove past the BC playfield edge into the gray border. User's flag implies (a) "walls" is the right cure.

**Fix path (CLOSED iter 18):**
1. `scenes/OriginalLevel.tscn`: added 4 invisible `StaticBody2D` walls at the BC playfield boundary — `BCLeftWall (52, 120)`, `BCRightWall (268, 120)`, `BCTopWall (160, 12)`, `BCBottomWall (160, 228)`. Two new `RectangleShape2D` sub-resources (vertical 8×216, horizontal 216×8). `collision_layer=1` so PlayerTank's mask catches them; no Sprite2D so they remain invisible.
2. Verified via headless physics point-query: walls present at expected positions; collision detected at wall center; interior of playfield uncolloided.
3. PNG-diff re-checked on 4 sample stages — all <5% (walls don't affect classifier; only player-tank/enemy artifact variance contributes to the slight uptick).

**STATUS:** CLOSED iter 018 — option (a) walls.

**Lesson:** When the implementation centers a smaller canonical area in a larger viewport, the boundary discipline must be explicit. Arc-3's iter-1 design didn't add edge walls because the original tanke walls were at viewport edges (-4 / 324); it didn't anticipate the BC-playfield-vs-viewport gap until queue #5 / F004 surfaced.
