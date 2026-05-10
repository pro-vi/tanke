# tanke — Asset Provenance Manifest

Every generated asset that lives in the repo has an entry here. Generated assets
must be regenerable from `tools/` scripts; the entry records inputs (prompt /
seed / params) so any agent can reproduce or remix.

Format:
```
slotId | semanticRole | source | prompt_or_params | seed | replaceability | comprehensionClaim
```

---

## brick_007

| field | value |
|-------|-------|
| **slotId** | `img/brick_007.png` |
| **semanticRole** | TileSetAtlasSource texture for `BrickSrc` in `scenes/ProceduralLevel.tscn` (replaces sprites_1.png brick region at margins (40,0)) |
| **source** | `tools/gen_tile.py` — algorithmic PIL pixel art (no ML) |
| **prompt_or_params** | `--tile brick --variant 7 --out img` |
| **seed** | 7 (Python `random.Random(7)` inside `gen_brick`) |
| **replaceability** | regenerable in <0.1s; safe to delete and rerun. Re-import via `godot --headless --path . --import` |
| **comprehensionClaim** | "Player should read this as a destructible brick wall — warm reds, mortar gridlines visible at 1× zoom" |

**Pipeline verification (iter 4):**
```
1. python3 tools/gen_tile.py --tile brick --variant 7 --out img
   → img/brick_007.png (8×8 RGBA, 134 bytes)
2. godot --headless --path . --import
   → img/brick_007.png.import (uid://dy83met4b40yn)
3. ProceduralLevel.tscn BrickSrc.texture: ExtResource("1") → ExtResource("4")
   ProceduralLevel.tscn BrickSrc.margins: (40, 0) → (0, 0)
4. make screenshot → tools/out/frame00000004.png
5. make analyze:
   Before: brick 47410px (default config, original sprite)
   After:  brick 41194px (default config, brick_007 swap)
   Δ brick = -13.1% — confirms pixel-level swap; remaining count above 40k confirms
            new palette stays within 70-distance brick classifier window.
   Distribution entropy 1.562 → 1.718 bits (partly real shift, partly classifier
   artifact: mortar pixels reclassify as adjacent terrains).
```

Full PIL → TileSet → set_cell → rendered pixel chain verified in one iteration.

---

## Future entries

When `tools/gen_sprite.py` (MLX-SD) generates a novel asset, add an entry with
the prompt, model, sampler, steps, and any palette-extraction params used.
