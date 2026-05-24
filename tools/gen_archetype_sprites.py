"""
arc-4 iter 142 — SPIKE — concept-art palette extraction.
arc-4 iter 143 — BUILD — H5 motif-first procedural masks (Pro Consult 011).

Per Consult 011 (GPT Pro extended thinking, same thread as Consult
008): the AI concept art (img/archetype_*_concept.png) is NOT used
as gameplay sprite source. Instead, this tool:
  (a) extracts a 4-color palette per archetype (transparent / outline
      / body / accent), clamped to arcade-readable NES values; and
  (b) drives a motif-first procedural mask generator that emits
      16x16 cells per direction. Identity beats survive as SYMBOLS
      (cyan aperture / olive offset tube / red plow), not illustrations.

PALETTES dict below is the SOURCE OF TRUTH. Re-run `--extract` to
re-inspect raw concept dominants; clamping is manual + documented.

Run:
    uv run --with pillow tools/gen_archetype_sprites.py --palettes
    uv run --with pillow tools/gen_archetype_sprites.py --extract
    uv run --with pillow tools/gen_archetype_sprites.py --sprites
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from typing import Dict, List, Tuple

REPO = Path(__file__).resolve().parent.parent
CONCEPTS = {
    "prism":  REPO / "img" / "archetype_prism_concept.png",
    "mortar": REPO / "img" / "archetype_mortar_concept.png",
    "ram":    REPO / "img" / "archetype_ram_concept.png",
}
OUT_DIR = REPO / "tools" / "out"

# Per Consult 011: each archetype gets a 4-color palette assigned to
# logical roles. Hue families pulled from concept art via --extract;
# colors then clamped to arcade-readable NES-style values. These are
# the SOURCE OF TRUTH for downstream mask generators (iter 143+).
ROLES = ["transparent", "outline", "body", "accent"]
PALETTES = {
    "prism": {
        "transparent": [0, 0, 0, 0],
        "outline":     [4, 18, 48],
        "body":        [80, 157, 237],
        "accent":      [180, 230, 255],
        "_hue_source": "extracted [80,157,237] mid blue; concept dominant",
    },
    "mortar": {
        "transparent": [0, 0, 0, 0],
        "outline":     [38, 36, 24],
        "body":        [128, 120, 60],
        "accent":      [220, 200, 120],
        "_hue_source": "extracted [128,120,98] olive-tan; concept dominant",
    },
    "ram": {
        "transparent": [0, 0, 0, 0],
        "outline":     [40, 12, 12],
        "body":        [180, 40, 40],
        "accent":      [240, 200, 160],
        "_hue_source": "extracted [135,47,45] red; concept dominant",
    },
}

CELL = 16  # px per sprite cell (matches atlas geometry)

# Role codes used inside the 16x16 grid arrays:
T = 0  # transparent
O = 1  # outline
B = 2  # body
A = 3  # accent


def extract_palette(png_path: Path, n: int = 4) -> List[Tuple[int, int, int]]:
    """Extract the n most-common opaque colors from a PNG. Background
    transparency is excluded; only the actual painted pixels count."""
    from PIL import Image
    img = Image.open(png_path).convert("RGBA")
    pixels = [(r, g, b) for r, g, b, a in img.getdata() if a > 128]
    rgb_img = Image.new("RGB", img.size)
    rgb_img.putdata([(r, g, b) for r, g, b in pixels[: img.size[0] * img.size[1]]])
    quantized = rgb_img.quantize(colors=n, method=Image.Quantize.MEDIANCUT)
    pal = quantized.getpalette()[: n * 3]
    return [(pal[i], pal[i + 1], pal[i + 2]) for i in range(0, n * 3, 3)]


def write_preview(name: str, palette: List[Tuple[int, int, int]], out: Path) -> None:
    """Write an 8x scaled palette swatch — N cells × 64x64 px each.
    Easy-to-eye verification of the clamped palette."""
    from PIL import Image
    cell = 64
    img = Image.new("RGB", (cell * len(palette), cell), (0, 0, 0))
    for i, color in enumerate(palette):
        for y in range(cell):
            for x in range(cell):
                img.putpixel((i * cell + x, y), color)
    img.save(out)


# ============================================================
# Iter 143 — motif-first procedural sprite masks
# ============================================================
#
# Each archetype is drawn as a 16x16 grid in UP-facing orientation
# (front = top edge). L / D / R variants are derived via 90/180/270
# rotation. This keeps the silhouette identity beat intact at all
# directions while restricting iter 143 to ONE mask per archetype.
#
# Iter 144 may refine with per-direction handcrafted masks if the
# rotational symmetry reads weirdly (especially for MORTAR's
# offset tube and RAM's asymmetric plow).

def _blank_grid() -> List[List[int]]:
    return [[T for _ in range(CELL)] for _ in range(CELL)]


def _fill_rect(grid: List[List[int]], r0: int, c0: int, r1: int, c1: int, code: int) -> None:
    """Fill grid[r0:r1, c0:c1] with code (half-open ranges)."""
    for r in range(max(0, r0), min(CELL, r1)):
        for c in range(max(0, c0), min(CELL, c1)):
            grid[r][c] = code


def _outline_rect(grid: List[List[int]], r0: int, c0: int, r1: int, c1: int) -> None:
    """Stroke a 1-px outline rect (outer cells only) with code O."""
    for c in range(max(0, c0), min(CELL, c1)):
        if 0 <= r0 < CELL: grid[r0][c] = O
        if 0 <= r1 - 1 < CELL: grid[r1 - 1][c] = O
    for r in range(max(0, r0), min(CELL, r1)):
        if 0 <= c0 < CELL: grid[r][c0] = O
        if 0 <= c1 - 1 < CELL: grid[r][c1 - 1] = O


def _add_chassis_and_treads(grid: List[List[int]]) -> None:
    """Common chassis + tread layout (UP-facing). Body rows 6..14,
    cols 3..13; treads cols 1..3 and 13..15."""
    # Chassis body (filled)
    _fill_rect(grid, 6, 4, 14, 12, B)
    # Chassis outline
    _outline_rect(grid, 6, 4, 14, 12)
    # Left tread
    _fill_rect(grid, 6, 1, 14, 4, B)
    _outline_rect(grid, 6, 1, 14, 4)
    # Tread cleats (alternating pixels on outer column)
    for r in range(7, 13, 2):
        grid[r][1] = O
        grid[r][2] = B
    # Right tread (mirror)
    _fill_rect(grid, 6, 12, 14, 15, B)
    _outline_rect(grid, 6, 12, 14, 15)
    for r in range(7, 13, 2):
        grid[r][14] = O
        grid[r][13] = B


def make_prism_up() -> List[List[int]]:
    """PRISM: compact chassis + bright cyan lens aperture at front.
    Identity: 2x2 bright accent cluster at top center = beam emitter."""
    g = _blank_grid()
    _add_chassis_and_treads(g)
    # Turret base on top center (chassis row 5)
    _fill_rect(g, 4, 6, 7, 10, B)
    _outline_rect(g, 4, 6, 7, 10)
    # Lens core — 2x2 bright accent (the "aperture")
    g[4][7] = A
    g[4][8] = A
    g[5][7] = A
    g[5][8] = A
    # Flare pixels above lens (single accent dots — readable as "glow")
    g[2][7] = A
    g[2][8] = A
    g[3][7] = A
    g[3][8] = A
    return g


def make_mortar_up() -> List[List[int]]:
    """MORTAR: chassis + stubby angled tube offset to right-front.
    Identity: ASYMMETRIC silhouette + accent at tube tip = lobber, not gun."""
    g = _blank_grid()
    _add_chassis_and_treads(g)
    # Tube base mount (slightly right of center)
    _fill_rect(g, 4, 7, 7, 11, B)
    _outline_rect(g, 4, 7, 7, 11)
    # Stubby angled tube going up-and-right from mount
    # Diagonal pixels: (3,9), (3,10), (2,10), (2,11), (1,11)
    for r, c in [(3, 9), (3, 10), (2, 10), (2, 11), (1, 11)]:
        g[r][c] = B
    # Tube outline (left edge + cap edge)
    for r, c in [(3, 8), (4, 8), (1, 10), (0, 11), (2, 12)]:
        if 0 <= r < CELL and 0 <= c < CELL:
            g[r][c] = O
    # Mortar cup opening (accent at muzzle tip)
    g[1][11] = A
    g[0][11] = A
    return g


def make_ram_up() -> List[List[int]]:
    """RAM: chassis + oversized front plow (wedge wider than chassis).
    Identity: silhouette WIDER at front than rear = unmistakable plow."""
    g = _blank_grid()
    _add_chassis_and_treads(g)
    # Plow extends forward of the chassis, wider with each row toward
    # the leading edge. Row 5 = chassis top edge (already drawn as
    # outline by _add_chassis_and_treads).
    # Row 4: cols 2..14 (wider than chassis)
    _fill_rect(g, 4, 2, 6, 14, B)
    # Row 3: cols 1..15 (widest)
    _fill_rect(g, 3, 1, 4, 15, B)
    # Row 2: cols 2..14 (taper — "blade" thinness)
    _fill_rect(g, 2, 2, 3, 14, B)
    # Plow outline (top + sides)
    for c in range(2, 14):
        g[2][c] = O
    g[3][0] = O if False else g[3][0]  # leave edges
    g[3][1] = O
    g[3][15] = O if 15 < CELL else g[3][15]
    # Use cells safely
    g[3][14] = O
    g[4][2] = O
    g[4][13] = O
    # Bright leading-edge accent stripe (one row of bright pixels)
    for c in range(3, 13):
        g[1][c] = A
    return g


ARCHETYPE_BUILDERS = {
    "prism": make_prism_up,
    "mortar": make_mortar_up,
    "ram": make_ram_up,
}


def rotate_grid(grid: List[List[int]], direction: str) -> List[List[int]]:
    """Rotate a UP-facing 16x16 grid to L/D/U/R orientation.
    Direction codes match Constants.Dir: L=0, D=1, U=2, R=3."""
    n = len(grid)
    if direction == "U":
        return [row[:] for row in grid]
    if direction == "D":
        return [row[::-1] for row in grid[::-1]]
    if direction == "L":  # 90 CCW
        return [[grid[c][n - 1 - r] for c in range(n)] for r in range(n)]
    if direction == "R":  # 90 CW
        return [[grid[n - 1 - c][r] for c in range(n)] for r in range(n)]
    raise ValueError(f"unknown direction: {direction}")


def render_cell(grid: List[List[int]], palette: dict, scale: int = 8):
    """Render a 16x16 grid to a scaled RGBA PIL image using the palette."""
    from PIL import Image
    n = len(grid)
    img = Image.new("RGBA", (n * scale, n * scale), (0, 0, 0, 0))
    role_to_rgba = {
        T: (0, 0, 0, 0),
        O: tuple(palette["outline"]) + (255,),
        B: tuple(palette["body"]) + (255,),
        A: tuple(palette["accent"]) + (255,),
    }
    px = img.load()
    for r in range(n):
        for c in range(n):
            rgba = role_to_rgba[grid[r][c]]
            if rgba[3] == 0:
                continue
            for dy in range(scale):
                for dx in range(scale):
                    px[c * scale + dx, r * scale + dy] = rgba
    return img


def write_sprite_preview(out_path: Path, scale: int = 8) -> None:
    """3 archetypes (rows) × 4 directions (cols) preview sheet."""
    from PIL import Image, ImageDraw
    cell_px = CELL * scale
    gap = 12
    label_h = 18
    archetypes = ["prism", "mortar", "ram"]
    dirs = ["L", "D", "U", "R"]
    sheet_w = label_h + len(dirs) * (cell_px + gap) + gap
    sheet_h = label_h + len(archetypes) * (cell_px + gap) + gap
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (28, 28, 36, 255))
    draw = ImageDraw.Draw(sheet)

    # Column labels (directions across the top)
    for di, d in enumerate(dirs):
        x = label_h + gap + di * (cell_px + gap) + cell_px // 2 - 6
        draw.text((x, 2), d, fill=(220, 220, 230, 255))
    # Row labels + cells
    for ai, arch in enumerate(archetypes):
        y = label_h + gap + ai * (cell_px + gap)
        draw.text((2, y + cell_px // 2 - 6), arch[0].upper(), fill=(220, 220, 230, 255))
        base = ARCHETYPE_BUILDERS[arch]()
        for di, d in enumerate(dirs):
            x = label_h + gap + di * (cell_px + gap)
            rotated = rotate_grid(base, d)
            cell_img = render_cell(rotated, PALETTES[arch], scale=scale)
            sheet.paste(cell_img, (x, y), cell_img)
    sheet.save(out_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--palettes", action="store_true",
                        help="write clamped PALETTES dict to JSON + preview swatches")
    parser.add_argument("--extract", action="store_true",
                        help="re-extract raw dominant colors from concept PNGs (for tuning the clamped PALETTES dict)")
    parser.add_argument("--sprites", action="store_true",
                        help="iter 143: write motif-first procedural sprite preview sheet (3 archetypes x 4 directions, 8x scaled)")
    args = parser.parse_args()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if args.extract:
        for name, path in CONCEPTS.items():
            raw = extract_palette(path, n=4)
            print(f"[{name}] raw extracted: {raw}")
    if args.palettes:
        for name, pal_dict in PALETTES.items():
            outline = tuple(pal_dict["outline"])
            body = tuple(pal_dict["body"])
            accent = tuple(pal_dict["accent"])
            preview = OUT_DIR / f"palette_preview_{name}.png"
            write_preview(name, [outline, body, accent], preview)
            print(f"[{name}] clamped palette → {preview}")
        out_json = OUT_DIR / "archetype_palettes.json"
        out_json.write_text(json.dumps(PALETTES, indent=2))
        print(f"\nwrote {out_json}")
    if args.sprites:
        out_path = OUT_DIR / "archetype_sprites_preview.png"
        write_sprite_preview(out_path, scale=8)
        print(f"wrote {out_path} (3 archetypes x 4 directions, 8x scaled)")


if __name__ == "__main__":
    main()
