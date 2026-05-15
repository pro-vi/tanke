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
