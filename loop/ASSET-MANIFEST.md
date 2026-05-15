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

## steel_007 / grass_007 / water_007

| field | value |
|-------|-------|
| **slotId** | `img/{steel,grass,water}_007.png` |
| **semanticRole** | TileSetAtlasSource textures for `SteelSrc` / `GrassSrc` / `WaterSrc` (replaces respective `sprites_1.png` regions) |
| **source** | `tools/gen_tile.py` |
| **prompt_or_params** | `--tile {steel,grass,water} --variant 7 --out img` |
| **seed** | 7 |
| **replaceability** | regenerable in <0.1s; safe to delete and rerun. Re-import via `godot --headless --import` |
| **comprehensionClaim** | "Reads as steel/grass/water at 1× zoom — but palette is hardcoded in gen_tile.py and diverges from sprites_1.png reference, so analyze_frame.py classifier loses grass entirely. Iter 17 plan: extract palettes from sprite sheet." |

**UIDs (post-import):**
- steel_007: `uid://btw4ryipmrg4n`
- grass_007: `uid://dqcyr7h1gwsw3`
- water_007: `uid://dg7td6i6nfwni`

**Iter 16 verification (hardcoded palettes):**
```
Headless (seed 42, post-swap):
  hash 6159ef2f5464edb1 (UNCHANGED — texture swap is cosmetic)
  brick 400 water 200 steel 244 grass 228  vert_persistence 0.647

Screencapture:
  coverage 93.9%, variety 3/4   ← grass classified as background!
  brick 54482, steel 3944, grass 0, water 13720
```

**Iter 17 regeneration (sprite-sheet-extracted palettes):**

`gen_tile.py --from-sheet img/sprites_1.png` extracts top-4 frequent colors
from each terrain's canonical 8×8 region (margins `(40,0)` brick, `(16,0)`
steel, `(24,0)` grass, `(24,8)` water) and uses them as the variant palette:
```
brick: [(156, 74, 0), (99, 99, 99), (107, 8, 0), (107, 8, 0)]
steel: [(173, 173, 173), (99, 99, 99), (255, 255, 255), (255, 255, 255)]
grass: [(140, 214, 0), (0, 82, 8), (8, 74, 0), (8, 74, 0)]
water: [(66, 66, 255), (181, 239, 239), (181, 239, 239), (181, 239, 239)]
```

These match `analyze_frame.py`'s reference exactly (same source). Re-screencap:
```
coverage 99.9%, variety 4/4
distribution entropy 1.581 bits  score 4.0/5.0   ← BETTER than original baseline (3.9)
brick 45638, steel 5740, grass 14080, water 11264
```

The PIL-generated tiles now sit *inside* the classifier window. Headless
hash anchor `6159ef2f5464edb1` still preserved across the regeneration.

---

## Future entries

When `tools/gen_sprite.py` (MLX-SD) generates a novel asset, add an entry with
the prompt, model, sampler, steps, and any palette-extraction params used.
