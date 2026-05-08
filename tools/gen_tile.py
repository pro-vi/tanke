"""
Algorithmic pixel art tile generator — PIL only, no ML required.
Generates 8x8 terrain tile variants for Brick, Steel, Grass, Water.
Output: PNG files compatible with Godot 4 TileSet.

Usage:
    uv run tools/gen_tile.py [--tile TILE] [--variant N] [--out DIR]
"""

import argparse
import random
from pathlib import Path
from PIL import Image, ImageDraw

PALETTES = {
    "brick": [(180, 80, 60), (160, 60, 40), (200, 180, 140), (120, 50, 30)],
    "steel": [(160, 170, 180), (120, 130, 140), (200, 210, 220), (80, 90, 100)],
    "grass": [(80, 140, 60), (60, 120, 40), (100, 160, 80), (40, 100, 30)],
    "water": [(60, 100, 180), (40, 80, 160), (80, 130, 200), (20, 60, 140)],
}

TILE_SIZE = 8


def gen_brick(seed: int) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE))
    draw = ImageDraw.Draw(img)
    p = PALETTES["brick"]
    draw.rectangle([0, 0, 7, 7], fill=p[0])
    # mortar lines
    draw.line([(0, 3), (7, 3)], fill=p[3], width=1)
    draw.line([(0, 7), (7, 7)], fill=p[3], width=1)
    draw.line([(3, 0), (3, 2)], fill=p[3], width=1)
    draw.line([(6, 4), (6, 6)], fill=p[3], width=1)
    # noise
    for _ in range(4):
        x, y = rng.randint(0, 7), rng.randint(0, 7)
        img.putpixel((x, y), p[rng.randint(1, 2)])
    return img


def gen_steel(seed: int) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE))
    p = PALETTES["steel"]
    for x in range(TILE_SIZE):
        for y in range(TILE_SIZE):
            base = p[0] if (x + y) % 2 == 0 else p[1]
            img.putpixel((x, y), base)
    # highlight corner
    img.putpixel((0, 0), p[2])
    img.putpixel((1, 0), p[2])
    img.putpixel((0, 1), p[2])
    # shadow corner
    img.putpixel((7, 7), p[3])
    # random scratches
    for _ in range(rng.randint(0, 3)):
        x = rng.randint(1, 6)
        y = rng.randint(1, 6)
        img.putpixel((x, y), p[3])
    return img


def gen_grass(seed: int) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE))
    p = PALETTES["grass"]
    for x in range(TILE_SIZE):
        for y in range(TILE_SIZE):
            img.putpixel((x, y), p[rng.randint(0, 1)])
    # blade tips
    for _ in range(rng.randint(2, 5)):
        x = rng.randint(0, 7)
        img.putpixel((x, 0), p[2])
    return img


def gen_water(seed: int, frame: int = 0) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE))
    p = PALETTES["water"]
    for x in range(TILE_SIZE):
        for y in range(TILE_SIZE):
            img.putpixel((x, y), p[0])
    # animated ripple offset by frame
    offset = frame * 2
    for x in range(TILE_SIZE):
        wave_y = (x + offset) % TILE_SIZE
        img.putpixel((x, wave_y), p[2])
        if wave_y > 0:
            img.putpixel((x, wave_y - 1), p[1])
    return img


GENERATORS = {
    "brick": gen_brick,
    "steel": gen_steel,
    "grass": gen_grass,
    "water": gen_water,
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tile", choices=list(GENERATORS), default="brick")
    ap.add_argument("--variant", type=int, default=0, help="seed offset for variation")
    ap.add_argument("--out", type=Path, default=Path("tools/out"))
    ap.add_argument("--scale", type=int, default=1, help="pixel scale for preview")
    args = ap.parse_args()

    args.out.mkdir(parents=True, exist_ok=True)
    img = GENERATORS[args.tile](args.variant)
    if args.scale > 1:
        img = img.resize((TILE_SIZE * args.scale, TILE_SIZE * args.scale), Image.NEAREST)
    out_path = args.out / f"{args.tile}_{args.variant:03d}.png"
    img.save(out_path)
    print(f"saved {out_path}")


if __name__ == "__main__":
    main()
