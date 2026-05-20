"""
Algorithmic pixel art tile generator — PIL only, no ML required.
Generates 8x8 terrain tile variants for Brick, Steel, Grass, Water.
Output: PNG files compatible with Godot 4 TileSet.

Usage:
    python3 tools/gen_tile.py [--tile TILE] [--variant N] [--out DIR]
    python3 tools/gen_tile.py --tile grass --variant 7 --from-sheet img/sprites_1.png

When --from-sheet is given, the palette is extracted from the canonical 8x8
region for that tile in the sheet (margins per SHEET_MARGINS below); the
hardcoded PALETTES are used as fallback. Generated tiles will then sit within
the analyze_frame.py classifier window.
"""

import argparse
import random
from collections import Counter
from pathlib import Path
from PIL import Image, ImageDraw

# Hardcoded palettes (fallback if no --from-sheet)
PALETTES = {
    "brick": [(180, 80, 60), (160, 60, 40), (200, 180, 140), (120, 50, 30)],
    "steel": [(160, 170, 180), (120, 130, 140), (200, 210, 220), (80, 90, 100)],
    "grass": [(80, 140, 60), (60, 120, 40), (100, 160, 80), (40, 100, 30)],
    "water": [(60, 100, 180), (40, 80, 160), (80, 130, 200), (20, 60, 140)],
}

# Canonical positions in sprites_1.png — must match analyze_frame.py TILE_DEFS
SHEET_MARGINS = {
    "brick": (40, 0),
    "steel": (16, 0),
    "grass": (24, 0),
    "water": (24, 8),
}

TILE_SIZE = 8


def extract_palette(sheet_path: Path, margins: tuple[int, int]) -> list[tuple]:
    """Read top-4 most frequent non-near-black colors from an 8x8 region."""
    img = Image.open(sheet_path).convert("RGB")
    mx, my = margins
    colors = []
    for dy in range(TILE_SIZE):
        for dx in range(TILE_SIZE):
            px = img.getpixel((mx + dx, my + dy))
            if sum(px) > 30:  # skip near-black
                colors.append(px)
    counter = Counter(colors)
    top = [c for c, _ in counter.most_common(4)]
    while len(top) < 4:
        top.append(top[-1] if top else (0, 0, 0))
    return top


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


# --- arc-4 iter 17: shell-class HUD icons -----------------------------
# Algorithmic 8x8 icons for the 3 breach shell classes. Designed for the
# CONSULT §9 constraint 4 silhouette grammar: each icon is readable by
# SILHOUETTE (AP = narrow dart, HE = fat ellipse, HEAT = angular diamond)
# and PALETTE (AP = pale steel, HE = warm yellow, HEAT = crimson —
# matching the Bullet.gd modulate colors from iters 4/7). One-frame
# intent: thin=precise, round=splash, pointed=armor-focus.

SHELL_PALETTES = {
    "ap": [(235, 235, 240), (175, 178, 190), (110, 112, 125)],   # pale steel
    "he": [(255, 217, 64), (228, 168, 30), (148, 100, 20)],      # warm yellow
    "heat": [(255, 92, 64), (220, 52, 40), (138, 32, 30)],       # crimson
}


def _gen_shell(kind: str) -> Image.Image:
    p = SHELL_PALETTES[kind]
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE))
    draw = ImageDraw.Draw(img)
    if kind == "ap":
        # THIN TALL DART — single-column spine, full height. One-frame
        # intent: precise / piercing. Occupies only the centre column.
        draw.line([(4, 0), (4, 7)], fill=p[0])
        img.putpixel((4, 1), p[1])
        img.putpixel((4, 4), p[1])
        img.putpixel((4, 7), p[2])
    elif kind == "he":
        # FAT ROUND BLOB — wide filled ellipse, mid-height. One-frame
        # intent: splash / area. Occupies a broad rounded mass.
        draw.ellipse([1, 2, 6, 6], fill=p[0])
        draw.ellipse([3, 3, 4, 5], fill=p[1])
        img.putpixel((3, 1), p[0])
        img.putpixel((4, 1), p[0])
    elif kind == "heat":
        # WIDE CHEVRON — two diagonals meeting at the top apex, splayed
        # to the base corners. One-frame intent: focused armor-pierce.
        # Occupies the diagonals + a short stem — distinct from both the
        # AP centre-spine and the HE round mass.
        for i in range(4):
            img.putpixel((4 - i, 1 + i), p[0])  # left diagonal
            img.putpixel((4 + i, 1 + i), p[0])  # right diagonal
        draw.line([(4, 1), (4, 4)], fill=p[1])  # stem
        img.putpixel((4, 0), p[2])              # apex tip
    return img


def gen_shell_ap(seed: int = 0) -> Image.Image:
    return _gen_shell("ap")


def gen_shell_he(seed: int = 0) -> Image.Image:
    return _gen_shell("he")


def gen_shell_heat(seed: int = 0) -> Image.Image:
    return _gen_shell("heat")


GENERATORS = {
    "brick": gen_brick,
    "steel": gen_steel,
    "grass": gen_grass,
    "water": gen_water,
    "shell_ap": gen_shell_ap,
    "shell_he": gen_shell_he,
    "shell_heat": gen_shell_heat,
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tile", choices=list(GENERATORS), default="brick")
    ap.add_argument("--variant", type=int, default=0, help="seed offset for variation")
    ap.add_argument("--out", type=Path, default=Path("tools/out"))
    ap.add_argument("--scale", type=int, default=1, help="pixel scale for preview")
    ap.add_argument(
        "--from-sheet",
        type=Path,
        default=None,
        help="Extract palette from this sheet at the tile's canonical margins instead of using hardcoded values.",
    )
    args = ap.parse_args()

    args.out.mkdir(parents=True, exist_ok=True)

    if args.from_sheet is not None and args.tile in SHEET_MARGINS:
        margins = SHEET_MARGINS[args.tile]
        extracted = extract_palette(args.from_sheet, margins)
        # Mutate the in-memory palette so generators pick it up.
        PALETTES[args.tile] = extracted
        print(f"palette extracted from {args.from_sheet} at {margins}: {extracted}")

    img = GENERATORS[args.tile](args.variant)
    if args.scale > 1:
        img = img.resize((TILE_SIZE * args.scale, TILE_SIZE * args.scale), Image.NEAREST)
    out_path = args.out / f"{args.tile}_{args.variant:03d}.png"
    img.save(out_path)
    print(f"saved {out_path}")


if __name__ == "__main__":
    main()
