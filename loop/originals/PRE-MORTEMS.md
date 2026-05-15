# tanke — Originals Loop PRE-MORTEMS (arc 3)

Append-only. One block per iter. H2 RULE v2 tags mandatory (carried from arc 2):
`[STRUCTURE]` / `[FEEL]` / `[MIXED]` / `[STRUCTURE-DEFERRED]`.

A pre-mortem is a falsifiable claim *written before acting* about what the
iter will achieve and what will most likely break. Successful iters retire
the pre-mortem with "verified"; failed predictions get an F-number in
`FALSIFICATIONS.md`.

---

## Iter 001 — BUILD / CAPABILITY (scaffolding)

**Mode:** BUILD (with CAPABILITY sub-focus on test_runner extension).

**Weakest axis:** criterion 1 (Loader correctness) and criterion 10 (End-to-end playable run) are both at 0. Criterion 4 (PNG-diff oracle) also 0 but deferred to iter 2-3 because it's not on the unblock path. The IMPORT mode is blocked until LevelLoader exists.

**Plan:**
1. `scripts/LevelLoader.gd` — static parse_stage(level, stage_n, col_offset, row_offset) reading `.research/repos/Tanks/resources/stages/N` as text; emits `set_cell` for `#@%~`; `-` (ice) skipped pending phase-1 decision; `.` no-op.
2. `scenes/OriginalLevel.tscn` — parallel to ProceduralLevel.tscn (same 4 TileMapLayers, player, camera, walls; no Spawner; no Spawner.gd reference yet — eagle + enemy roster are iter 2+).
3. `scripts/OriginalLevel.gd` — extends `Level.gd`; `_ready` connects shoot, calls `LevelLoader.parse_stage(self, stage, 7, 2)` then inherited `_replace_blocks()` (converts Brick/Water TileMapLayer cells to BrickBlock/WaterBlock instances — same machinery the procedural scene uses).
4. `loop/test_runner.gd` — add `--scene PATH` and `--og-stage K` flags. **Extend, don't refactor** (substrate rule).

**Falsifiable claim:**

Running `godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --json` (no new flags) on the procedural scene must still produce `tile_hash: 23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`. AND running it with `--scene res://scenes/OriginalLevel.tscn --og-stage 1 --json` must produce a JSON dict with `brick > 0`, `steel > 0`, and `playable: true`. Both verified in one iter.

**Most-likely failure modes (pre-mortem):**

- **F1 [STRUCTURE]**: Godot's `res://` filesystem may not expose `.research/` files because Godot's import filter ignores dotfile-prefixed paths. *Detection*: `FileAccess.open(".research/repos/Tanks/resources/stages/1", READ)` returns null. *Mitigation*: fall back to `OS.get_executable_path()`-relative or `ProjectSettings.globalize_path("res://")` + concatenation, which goes through the OS layer and bypasses Godot's resource filter. Test both before committing.
- **F2 [STRUCTURE]**: Tanks's grid is 26×26 but the stage 1 ASCII (per synthesis) is 26 *rows* of 26 *chars*. If my parser does `for line in lines: for char in line:`, off-by-one (CRLF line endings, trailing newline) could shift cells. *Detection*: count `#` cells in stage 1 source by external `grep -o '#' | wc -l` and compare to TileMapLayer's `get_used_cells().size()` after parse. *Mitigation*: strip on each line, assert `len(line) == 26` per row, assert `len(lines_after_strip) == 26`.
- **F3 [STRUCTURE]**: Off-by-one on tile coordinates. ProceduralLevel uses 8-px tiles; if I pass `col + 7, row + 0` as tile coords but Tanks's grid is 0-indexed from the top while procedural's row 0 is at the top too, *and* Godot's `set_cell` takes `Vector2i(col, row)` — should be straightforward, but I've been bit by row=Y, col=X swap before. *Detection*: render headless, look at where bricks land relative to player spawn.
- **F4 [STRUCTURE]**: `Level.gd`'s `_replace_blocks()` clears `brickTileMap` after instantiating BrickBlocks. Reachability oracle uses the spawn position derived from `level.player.global_position`. PlayerTank in OriginalLevel.tscn must NOT overlap a placed brick or the player gets stuck inside a wall. *Detection*: player spawn at (160, 232) = tile (20, 29); Tanks stage 1 row 29 has no chars (only 26 rows) so spawn lands in the HUD border — but row 29 from top-of-viewport corresponds to row 27 from start-of-stage if I offset by 2. Need to think this through. *Mitigation for iter 1*: spawn at a known-empty cell; defer per-stage canonical spawn to iter 2 alongside eagle placement.

**Carry-from-arc-2 tags:** all four pre-mortem items are `[STRUCTURE]` — arc 3 is mostly structurally verifiable (terrain parse, coordinate math). The only `[FEEL]` items in arc 3 will be criteria 2/6/10 anchors at score ≥4 (eagle, mode-select, end-to-end). Iter 1 touches none of those.

**Substrate guards:** no edits to `scripts/Level.gd`, `scripts/ProceduralLevel.gd`, `scripts/ProceduralStep.gd`, `scripts/LevelConfig.gd`, `scripts/BiomeConfig.gd`, `scripts/LevelDNA.gd`, `scripts/Bullet.gd`, `scripts/Enemy*.gd`, `scripts/Spawner.gd`, `scripts/PlayerTank.gd`, `scripts/BrickBlock.gd`, `configs/playable.tres`, or anything in `.research/repos/Tanks/`. Only additions: 3 new files + 1 *extension* to test_runner.gd.

**What would count as "iter 1 failed":**

If after this iter:
- The procedural hash anchor has drifted, OR
- LevelLoader.gd can't load stage 1, OR
- OriginalLevel.tscn crashes on headless boot, OR
- Any of the above forces a substrate edit to fix

→ then iter 1 was an F (assign F001), revert the substrate-touching change, and the iter-2 pre-mortem starts from the lesson.

**Anti-Goodhart guard:** criterion 7 (Stages 1-12) does NOT get a score bump from "stage 1 loads in headless." Anchor 2 requires "every cell correct (manual diff vs Tanks source)" *for criterion 1*, and criterion 7 only counts after both reachability AND PNG-diff. Iter 1 cannot honestly score above 0 on criterion 7; if I find myself tempted, that's the Goodhart anti-pattern firing.

---

## Iter 002 — BUILD / CAPABILITY (PNG-diff oracle)

**Carry from iter 001 meta-nat-13 (`/meta` Stop-hook fire):**

> Iter-1 pre-mortem's falsifiable claim was "stage 1 loads"; iter 1 delivered "all 35 stages load." The claim verified trivially while the actually-interesting risk (generalization) was tested only after the fact by curiosity. *Pattern: parity drift at the prediction layer.* **Cure for iter 2+: the falsifiable claim must include a generalization clause — N > 1 test cases drawn from the actual variation space, not just the example case.**

This iter applies the cure.

**Mode:** BUILD (with CAPABILITY sub-focus on `tools/png_diff.py`).

**Weakest axis:** criterion 4 (PNG-diff oracle) at 0. Criteria 7/8/9 are floor-blocked behind it — they can't lift until C4 ≥ ~2 (tool exists, reads reference PNGs, classifies tiles). Criterion 2 (eagle) is also 0 but the eagle entity is iter-3 work; C4 is the unblock-path dependency.

**Plan:**

1. Try to fetch StrategyWiki `Battle_City_Stage01.png` (and 2-3 others) via `curl` with a reasonable user-agent. Synthesis says anti-bot blocked the agent-survey fetch, but a local curl with a browser UA may work. Fallback chain: GameFAQs Selmiak mirror → cite "real-reference deferred to iter 3." (Note: anti-pattern is "defer eagle to after all stages" — the analogous risk here is "defer real-reference cross-validation to after the tool exists"; mitigation is to deliver tool + at least one real diff in this iter if the network cooperates.)
2. Add `make screenshot-og STAGE=K` Makefile target — extends existing `screenshot` pattern without touching procedural target.
3. Build `tools/png_diff.py`: PIL pipeline. Input: two PNG paths. For each, classify each 16×16 tile (NES resolution) to {empty, brick, steel, forest, water, ice} via palette match (mean RGB → nearest of 6 canonical colors). Compare classifications. Output: `{tiles_total: N, matched: M, mismatch_pct: P, mismatched_coords: [(row,col,expected,got), ...]}`.

**Falsifiable claim (with generalization clause — Nat-13 cure):**

`tools/png_diff.py REFERENCE_PNG OUR_RENDER_PNG` must:
- Run without error on **stages 1, 4, 7, and 17** rendered from OriginalLevel (4 stages chosen for terrain variety: 1 = brick+steel only, 4 = brick+steel+forest+water, 7 = steel-heavy / 174 steel cells, 17 = first ice-bearing stage). *This is the generalization clause — single-stage success would be theatrical.*
- Output a coherent mismatch report (numeric percent + at least one of: per-tile coordinates, terrain-type confusion matrix, or visualization).
- When given a self-diff (same PNG as both args), return **0% mismatch** on at least one stage as a sanity baseline.
- When given a real reference (if fetch succeeds), report a *plausibly small* mismatch — definition of plausibly small: <30% (stricter <5% target is C4 anchor 3 / criterion 7 unblock, not iter-2 minimum).

**Most-likely failure modes:**

- **F1 [STRUCTURE]**: Reference PNG fetch blocked by anti-bot. *Detection*: curl returns HTML or 403. *Mitigation*: scope iter 2 to "tool built + self-diff sanity + 4-stage generalization on internal renders only"; cite the failed fetch in LEDGER; iter 3 handles the fetch via alternate source. **Crucially: this does NOT block C4 anchor 1 (Tool exists; runs on one stage; reports mismatch %), because "tool runs on one stage" can be satisfied by self-diff. Anchor 2 (reads StrategyWiki PNG) requires a real reference and is iter 3+.**
- **F2 [STRUCTURE]**: Palette classifier confuses adjacent tile colors. tanke's brick is red, steel is gray, forest is green, water is blue — high contrast — but anti-aliased edges between tiles could throw the mean-RGB classifier. *Detection*: self-diff > 0% mismatch. *Mitigation*: classify center pixel instead of mean; or sample a 4×4 inner region of each 16×16 tile.
- **F3 [STRUCTURE]**: Render-resolution mismatch. tanke renders at 8 px/cell, 320×240 viewport; OG stage is 26×26 cells = 208×208 px centered in viewport at col-offset 7 (56 px left border). StrategyWiki references are 208×208 px exactly. So either I crop tanke's 320×240 PNG to the 208×208 play area before diffing, or the diff tool understands offset. *Detection*: tile coords don't align. *Mitigation*: hard-code crop offset (56, 16) and crop size 208×208 in the tool, OR rescale via `--play-area "56,16,208,208"` flag.
- **F4 [STRUCTURE]**: tanke's tile graphics are not pixel-identical to NES tiles (different sprite art). A `<5% mismatch` target on raw pixel-diff is unachievable; the diff must be at *tile-classification* level, not pixel level. *Detection*: pixel diff returns 80%+ mismatch on a known-correct stage. *Mitigation*: tool already designed to compare classifications, not pixels — this was the design choice. Document in tool docstring.

**Substrate guards:** no edits to hard substrate (Layer 1) or gameplay substrate (Layer 2). Only additions: `tools/png_diff.py` + `tools/refs/` (for cached reference PNGs; will need `.gitignore` entry if large). Makefile gets a NEW target; existing targets unchanged.

**Anti-Goodhart guard:** criteria 7/8/9 stay at 0 even if iter 2 sees a clean self-diff for stages 1+4+7+17. C7+ require *real-reference* PNG diff < 5% per stage. Self-diff is necessary but not sufficient.

**What would count as "iter 2 failed":**

- Tool crashes on any of the 4 generalization stages → F-number, fix or revert.
- Self-diff returns > 0% on stage 1 (sanity-check baseline) → F-number, classifier bug.
- C4 doesn't lift to at least 1/5 → iter was scaffolding-without-substance (the very anti-pattern Nat-13 surfaced).
- Procedural hash anchor drifts → substrate violation, halt.

**Generalization clause check (the Nat-13 discipline):**

| Stage | Why this test case |
|-------|-------------------|
| 1 | Minimum terrain variety (brick + steel) — baseline |
| 4 | All four arc-2 terrains present (brick + steel + forest + water) |
| 7 | Steel-heavy (174 steel cells out of 228 total) — palette stress |
| 17 | First ice-bearing stage — exercise the "skip ice" path through the classifier |

Tool must run on all four without modification (no per-stage flags). If any single stage requires a tool tweak, the tool is not generalized.

---

## Iter 003 — BUILD (ice pass-through decision + Eagle entity)

**Carry from iter 002:** Generalization clause holds. Iter 3 applies it to both axes — ice decision verified by re-diffing stage 17, eagle placement verified across stages 1, 4, 35 (canonical fortress pattern confirmed identical: `#..#` at cols 11-14 of rows 24-25 across all three).

**Mode:** BUILD.

**Weakest axis (joint):**
1. Criterion 3 (Ice physics) at 0 — iter-2 PNG-diff made the gap concrete (206 ice cells dominate stage-17 mismatch). Decision iter due.
2. Criterion 2 (Eagle gameplay) at 0 — PROMPT anti-pattern explicitly names "deferring eagle to after all stages" as a failure mode. Iter 3 is the canonical eagle-build slot.

**Plan:**

1. **ICE DECISION** — choose `pass-through` for v1. Rationale: faithful slide-physics would entail a PlayerTank state-machine modification (arc-2 soft-substrate, requires regression check), and the iter-2 evidence shows the dominant stage-17 cost is the *visual* gap (ice cells render as empty), not the physics gap. Pass-through caps C3 at 2/5 per rubric — this is a deliberate ceiling. The decision is documented in LEDGER and PROMPT-RUBRIC traces.
2. **Ice texture** — `img/ice_008.png` (16×16, solid gray ~(128,128,128) to land in the existing `TANKE_ANCHORS["ice"] = (200,200,200)` classification window). Generated via PIL.
3. **Ice TileMapLayer** — add to OriginalLevel.tscn (decorative, NO physics — pass-through means tanks walk over it).
4. **LevelLoader update** — `-` symbol now writes to `iceTileMap` (currently `ice_skipped++`). No more silent skip.
5. **Eagle entity** — `scripts/Eagle.gd` (StaticBody2D; HP=1; eagle_destroyed signal; take_damage method matching Bullet's `_on_body_entered` contract). `scenes/Eagle.tscn` (16×16 sprite, CollisionShape2D, collision_layer=1 so Bullet mask=9 catches it).
6. **Eagle placement rule** — canonical: `cols 12-13, rows 24-25` of the parsed stage (= scene cols 19-20, rows 26-27 after offset). Verified identical across stages 1, 4, 35 — the BC fortress is fixed geometry. OriginalLevel.gd will instantiate Eagle at that scene position after `_replace_blocks()` runs.
7. **PlayerTank spawn** — move from (160, 220) [overlaps eagle] to (124, 220) [4 cells left of eagle, on bottom row]. Verified passable on stages 1, 4, 35.
8. **Re-diff** — render stages 1/4/7/17 and re-run `png_diff.py`. Predict: stages 1/4/7 stay under 5% (negligible delta from eagle); stage 17 drops from 32% to <5% (ice cells now render as gray).

**Falsifiable claim (with generalization clause):**

- `make screenshot-og STAGE=K` + `make png-diff-og STAGE=K` for **K in {1, 4, 7, 17}**:
  - Stage 1: mismatch_pct **<5%** AND eagle sprite visible in render at center-bottom AND eagle has collision (test by code inspection).
  - Stage 4: mismatch_pct **<5%** AND eagle present at same canonical position.
  - Stage 7: mismatch_pct **<5%** (sanity — eagle shouldn't break steel-heavy parsing).
  - Stage 17: mismatch_pct **<5%** (NEW — this is the headline cure; ice cells now render).
- Procedural hash anchor `23d6a2ec…` preserved (no arc-2 substrate writes).
- `make test` exit 0.

**Most-likely failure modes:**

- **F1 [STRUCTURE]**: Eagle's collision shape blocks the player. If `collision_mask` interplay between Eagle (layer=1) and PlayerTank (mask probably includes 1) makes the player stuck against the eagle on spawn or movement. *Detection*: render then walk — but I'm not playtesting this iter. Headless check: `make test` still exits 0 (no crash on eagle's _ready). *Mitigation*: keep PlayerTank spawn 4 cells away from eagle; eagle on layer 1 + standard 16×16 shape; deferred verification to first PLAYTEST.
- **F2 [STRUCTURE]**: Ice TileMapLayer's empty default cell color leaks gray pixels into supposedly-empty cells, causing false-positive ice classifications on tanke render. *Detection*: stages 1/4/7 mismatch_pct *rises* after this iter. *Mitigation*: TileMapLayer only renders cells that have `set_cell` called — empty cells remain transparent. Verify by self-classifying stage 1 render after ice layer added.
- **F3 [STRUCTURE]**: Eagle position rule wrong for some stage. Per inspection, stages 1/4/35 have the canonical `#..#` at cols 11-14 of rows 24-25 — but I haven't checked stages 2-34. If even one differs, the per-stage rule needs detection logic, not a hardcoded coord. *Detection*: render stages 2/3/5/6/8/9/10/11/12 etc., visually verify eagle lands in the brick "house" of each. *Mitigation*: write a quick survey: `grep` for `#..#` on rows 24-25 across all 35 stages. If 35/35 have it, hardcoded coord is fine. If <35, write fortress-detection in OriginalLevel.gd.
- **F4 [STRUCTURE]**: Ice texture color mismatch. tanke ice texture at (128,128,128) is sampled by png_diff at center → may classify as "empty" if TANKE_ANCHORS empty=(77,77,77) is closer than ice=(200,200,200) in RGB distance. Distance(128 to 77) = 51*3 = 7803 (squared); distance(128 to 200) = 72*3 = 15552 (squared). Empty wins! **Pre-mortem catches this before the build.** *Mitigation*: either change ice texture to ~(170, 170, 170) so it's closer to the ice anchor, OR update TANKE_ANCHORS["ice"] to match the actual texture color. Choose the second — more honest (anchor color reflects what we render).

**Substrate guards:**
- `scripts/Level.gd`, `Bullet.gd`, `Enemy*.gd`, `Spawner.gd`, `PlayerTank.gd`, `BrickBlock.gd`, `ProceduralLevel.gd`, `ProceduralStep.gd`, `LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`: UNTOUCHED.
- `loop/test_runner.gd`: UNTOUCHED in this iter.
- `tools/png_diff.py`: TANKE_ANCHORS["ice"] color value updated (data, not behavior — see F4 mitigation).
- `OriginalLevel.tscn`: ADD ice TileMapLayer + ADD Eagle instance + MOVE PlayerTank. All additive within the OG scene.
- `LevelLoader.gd`: `-` symbol now writes to iceTileMap. (Behavior change to the iter-1 loader, but inside the iter-1-introduced file.)
- New: `scripts/Eagle.gd`, `scenes/Eagle.tscn`, `img/ice_008.png`, `img/eagle_placeholder.png`.

**Anti-Goodhart guard:** stage 17 dropping to <5% AFTER adding ice rendering doesn't actually mean the **ice physics** is solved — only the visual gap is. Criterion 3's anchor 1 ("phase-1 decision iter: pass-through OR slide-physics chosen + ship one — cited") is the score I'm targeting, NOT anchor 3 ("Slide-physics implemented"). Decision-cite ≠ slide-physics. Cap at 2/5.

**What would count as "iter 3 failed":**
- Stage 17 still >5% mismatch after ice rendering → ice texture or anchor color wrong; iterate within the iter or F-number and revert.
- Stages 1/4/7 mismatch_pct rises above their iter-2 baselines → eagle or ice layer broke something; revert eagle/ice or fix.
- Procedural hash anchor drifts → arc-2 substrate violation; halt.
- Eagle entity is not StaticBody2D-with-take-damage → C2 anchor 2 cite is dishonest.

---

## Iter 004 — IMPORT (first-third PNG-diff sweep)

**Mode:** IMPORT (sub-mode of BUILD per PROMPT Step 3).

**Carry from iter 003:** Eagle is universal (35/35 stages share canonical position). Ice renders distinctly. Stage 17 PNG-diff regression cured. The loader + oracle + scene + eagle scaffolding produces honest <5% mismatch on stages with terrain coverage the iter-2/3 generalization clause stressed: brick-only (1), four-terrain (4), steel-heavy (7), ice-heavy (17). Iter 4 tests whether that scaffolding generalizes to the OTHER first-third stages: 2, 3, 5, 6, 8, 9, 10, 11, 12.

**Weakest axis:** criterion 7 (Stages 1-12 complete) at 2 — fastest unblock to anchor 5 ("all 12 complete") is a sweep of the remaining 9. Criterion 4 (PNG-diff oracle) at 3 — anchor 4 ("integrated into the loop's verification flow — every IMPORT iter runs it and cites result") becomes claimable in this iter precisely because this IS the first IMPORT iter.

**Plan:**

1. Fetch StrategyWiki CDN references for stages 2, 3, 5, 6, 8, 9, 10, 11, 12 (9 new PNGs into `tools/refs/`).
2. `make screenshot-og STAGE=K` for each of those 9 stages.
3. `make png-diff-og STAGE=K` against each — collect per-stage mismatch %.
4. Update `STAGES.md` per-stage gate-5 status.
5. Stretch goal (criterion 5 → 1): grep `.research/repos/Tanks/src/` for per-stage enemy spawn data; cite file:line.

**Falsifiable claim (with generalization clause):**

All 9 new first-third stages (2, 3, 5, 6, 8, 9, 10, 11, 12) produce PNG-diff mismatch <5% with current loader, current eagle, current ice rendering. *No per-stage adjustment is needed.* If any single stage requires loader or scene tweaks to pass, this iter has surfaced a real loader fragility that iter-3's 4-stage generalization clause didn't catch — F-number the failing stage and produce a structural-decoder hypothesis.

Procedural hash anchor `23d6a2ec…` preserved. `make test` exit 0.

**Most-likely failure modes:**

- **F1 [STRUCTURE]**: Stage 5 has water (60 ~ cells). Iter-2 anchor for tanke water = (64,64,255). I haven't verified our render's actual tanke-rendered water color sample. If it differs from anchor, water cells classify as "ice" or "empty" and stage 5 fails. *Mitigation*: inspect the render's center-pixel water color before scoring; update TANKE_ANCHORS["water"] if needed (anchor data, not behavior).
- **F2 [STRUCTURE]**: Stages with forest content (2, 3, 6, 8, 9, 10, 11) have the iter-3 "forest → steel" 1-cell confusion in their reference comparisons. Multiple cells could add up. *Detection*: any stage above 5% reveals the forest anchor is wrong. *Mitigation*: refine TANKE_ANCHORS["forest"] from current placeholder (24,200,24) to the actual rendered color via sample pixel inspection on one of these stages. (Same pattern as iter-3 ice fix.)
- **F3 [STRUCTURE]**: Stage layouts could have player-spawn overlap with brick cells. Currently PlayerTank at (124, 220) = scene cells (15-16, 27-28). If stage K row 25 (= scene row 27) col 8 has a `#` or `@`, the player is stuck in a wall. *Detection*: reachability oracle on that stage returns `playable: false`. *Mitigation*: defensive — pre-check stage row 25 cols 7-9 for any non-`.` chars across all 35 stages. If any conflict exists, redesign player spawn (different cell, or compute per-stage). Spot-check 5 stages by reading stage rows 25 before claiming the sweep result.
- **F4 [STRUCTURE]**: Enemy-roster mining yields nothing in `Tanks/src/` (might live in resource files or hardcoded constants nested deep). *Mitigation*: scope-reduce — the stretch goal is "located + cited," not "fully extracted." Even finding the file path that has the data counts as criterion-5 anchor 1.
- **F5 [STRUCTURE]**: Godot --headless render takes ~3-10 sec per stage. 9 stages × ~5 sec = ~45 sec. Tolerable. But if `--write-movie` hangs (as it did pre-iter-2 import), iter 4 stalls. *Detection*: monitor screenshot-og output. *Mitigation*: kill + reimport (same pattern as iter 3).

**Substrate guards:** no edits to hard substrate or arc-2 substrate. Potential edits within iter-3 artifact scope: TANKE_ANCHORS dict in `tools/png_diff.py` (data refinement, not behavior change). New cached PNGs in `tools/refs/`. No Godot scene/script changes are anticipated — the iter-3 OriginalLevel.tscn handles all 35 stages by env-var override.

**What would count as "iter 4 failed":**
- Any of the 9 stages above 5% AND no anchor-refinement fix produces <5% within the iter.
- More than one stage failing → loader has real per-stage drift, not just palette noise. Halt + investigate before scoring.
- Procedural hash anchor drift → substrate violation; halt.
- Stages 1/4/7/17 regress above their iter-3 baseline by ≥0.5% → eagle/ice integration broke something the iter-3 sweep missed.

**Anti-Goodhart guard:** if I find myself updating TANKE_ANCHORS to "fit" a high-mismatch stage rather than fixing the actual rendering or classifier issue, that's classifier-Goodhart. The anchor refinement is honest *only* when the anchor's current value disagrees with the actual rendered color (i.e., I sampled the render and the anchor's RGB is mismatched to what the renderer outputs).

**Generalization clause check (Nat-13 discipline):**

This iter's 9-stage sweep IS the generalization clause for the iter-3 scaffolding. There's no smaller "test case" subset — we're verifying the previous 3 iters' work generalizes by running it on the actual unverified majority of the first third.
