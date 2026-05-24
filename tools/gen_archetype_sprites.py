"""
arc-4 iter 142 — SPIKE — concept-art palette extraction +
arc-4 iter 143+ — BUILD — H5 motif-first procedural atlas (TBD).

Per Consult 011 (GPT Pro extended thinking, same thread as Consult
008): the AI concept art (img/archetype_*_concept.png) is NOT used
as gameplay sprite source. Instead, this tool:
  (a) extracts a 4-color palette per archetype (transparent / outline
      / body / accent), clamped to arcade-readable NES values; and
  (b) drives a motif-first procedural mask generator (iter 143+) that
      emits 8x8 (actually 16x16 cell) atlas sprites per direction.

PALETTES dict below is the SOURCE OF TRUTH. Re-run `--extract` to
re-inspect raw concept dominants; clamping is manual + documented.

Run:
    uv run --with pillow tools/gen_archetype_sprites.py --palettes
    uv run --with pillow tools/gen_archetype_sprites.py --extract
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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--palettes", action="store_true",
                        help="write clamped PALETTES dict to JSON + preview swatches")
    parser.add_argument("--extract", action="store_true",
                        help="re-extract raw dominant colors from concept PNGs (for tuning the clamped PALETTES dict)")
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


if __name__ == "__main__":
    main()
