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
