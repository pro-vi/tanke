# tanke loop

Greenfield development loop for the tanke Godot 4 tank game.

## How to fire

```
/loop Read ./loop/PROMPT.md and follow its instructions exactly.
```

Paste that into a Claude Code session at the repo root.

## Before firing — preloop

The loop will halt at iter 0 until you complete the preloop checklist in `loop/STATE.md`.
The critical step: **open the project in the Godot 4 editor once** so it can migrate the
TileSet data from Godot 3 packed format to Godot 4 sources. Without this, the `set_cell`
calls in ProceduralLevel.gd will use wrong source_id/atlas_coords.

After migration, fill in the `tile_source_ids` section in STATE.md and flip the gate.

## Files

| File | Purpose |
|------|---------|
| `PROMPT.md` | The self-contained loop instruction — the loop reads this every iteration |
| `RUBRIC.md` | 10 scored criteria with anchors — revised as the artifact reveals itself |
| `STATE.md` | Phase, iteration count, open seams, next action — replaced each iteration |
| `LEDGER.md` | Append-only score history — created at iter 0 |
| `ASSET-MANIFEST.md` | Provenance for every generated asset — created when first asset is generated |
| `creative-consults.md` | Consult iteration logs — created at iter 10 |
| `test_runner.gd` | Headless GDScript feedback signal — created at iter 0 bootstrap |

## How to tune the rubric

Edit `loop/RUBRIC.md` directly. The loop re-reads it each iteration. When raising a
ceiling, update the anchor for score 4 or 5 and note the revision in the Revision Log
at the bottom of RUBRIC.md.

## How to halt

Either:
- Write "stop" or "halt" in the session
- Set `Next action: HALT` in STATE.md

## Milestones

| Milestone | Meaning |
|-----------|---------|
| Total ≥ 20/50 | Core loop works (destruction + basic enemies) |
| Total ≥ 35/50 | If hit before iter 15, rubric was too easy — raise ceilings |
| Total ≥ 45/50 | Ship candidate — run user-look gate before claiming done |

## Asset pipeline

```bash
# Generate a tile variant
python3 tools/gen_tile.py --tile brick --variant 42 --out tools/out --scale 8

# Assemble a spritesheet
python3 tools/compose_sheet.py --dir tools/out/enemy --cols 8 --frame-w 16 --frame-h 16 --out img/EnemyTank.png

# Generate a novel sprite (requires mlx-stable-diffusion)
python3 tools/gen_sprite.py --prompt "pixel art top-down tank enemy 8bit" --palette img/sprites_0.png --out tools/out/enemy_raw.png
```
