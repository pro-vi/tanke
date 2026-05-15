#!/usr/bin/env python3
"""Arc-3 PNG-diff oracle for Battle City stage cross-validation.

Compares two PNGs at tile-classification granularity (not pixel-level), since
tanke's sprite art differs from the NES original by design but the terrain
layout per cell should match exactly.

Workflow:
1. Read REFERENCE PNG (StrategyWiki 208x208 NES screenshot).
2. Read RENDER PNG (tanke screenshot of OriginalLevel.tscn, 320x240).
3. Crop the render to the play area (56,16)-(264,224) = 208x208.
4. For each of 676 (= 26x26) 8-px sub-brick cells, classify both images
   to one of {empty, brick, steel, forest, water, ice} via per-palette
   nearest-color match.
5. Report: per-cell mismatches, total mismatch %, per-class confusion.

CLI:
    python3 tools/png_diff.py --reference REF.png --render RND.png [--stage K]
                              [--ascii-source PATH]
                              [--mask-player]
                              [--json]

The --ascii-source option (optional) lets the tool also report mismatch
against the canonical Tanks ASCII grid as an independent check; useful when
the reference PNG is itself suspect.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("png_diff.py requires Pillow (pip install Pillow)")

# Play-area crop in tanke's 320x240 render (matches OriginalLevel.tscn
# col_offset=7, row_offset=2 → 56 px left margin, 16 px top margin).
RENDER_OFFSET_X = 56
RENDER_OFFSET_Y = 16
PLAY_W = 208
PLAY_H = 208
TILE = 8           # 8-px sub-brick resolution
COLS = 26
ROWS = 26

# Terrain classes; index used in the mismatch table.
TERRAIN_EMPTY = "empty"
TERRAIN_BRICK = "brick"
TERRAIN_STEEL = "steel"
TERRAIN_FOREST = "forest"
TERRAIN_WATER = "water"
TERRAIN_ICE = "ice"
TERRAINS = (TERRAIN_EMPTY, TERRAIN_BRICK, TERRAIN_STEEL, TERRAIN_FOREST, TERRAIN_WATER, TERRAIN_ICE)

# Anchor colors per palette. Derived empirically from sample stages 1/4/7/17.
# The NES palette is the canonical BC palette as encoded by StrategyWiki PNGs.
# The tanke palette comes from the iter-2 reference render of stage 1+4+7+17.
NES_ANCHORS = {
    TERRAIN_EMPTY:  (0, 0, 0),
    TERRAIN_BRICK:  (160, 48, 0),
    TERRAIN_STEEL:  (255, 255, 255),
    TERRAIN_FOREST: (152, 232, 0),
    TERRAIN_WATER:  (64, 64, 255),
    TERRAIN_ICE:    (127, 127, 127),
}

TANKE_ANCHORS = {
    TERRAIN_EMPTY:  (77, 77, 77),
    TERRAIN_BRICK:  (107, 8, 0),
    TERRAIN_STEEL:  (173, 173, 173),
    # tanke doesn't yet render forest/water/ice at canonical center-pixel; these
    # are placeholder anchors derived from the asset texture (iter 2 minimum;
    # iter 3+ refines via more sample stages).
    TERRAIN_FOREST: (24, 200, 24),
    TERRAIN_WATER:  (64, 64, 255),
    TERRAIN_ICE:    (200, 200, 200),
}

# Player-tank mask: at stage (col 13, row 26) in OriginalLevel.tscn the
# PlayerTank sits at screen y=220, which corresponds to play-area row 25-26.
# Conservatively mask a 3x3 cell area at (col 12-14, row 24-26) when
# --mask-player is set. The reference image has no tank, so these cells
# will mis-classify against the reference; masking suppresses that noise.
PLAYER_MASK_CELLS = {(c, r) for c in (12, 13, 14) for r in (24, 25)}

ASCII_LEGEND = {
    ".": TERRAIN_EMPTY,
    "#": TERRAIN_BRICK,
    "@": TERRAIN_STEEL,
    "%": TERRAIN_FOREST,
    "~": TERRAIN_WATER,
    "-": TERRAIN_ICE,
}


def _color_dist_sq(a: tuple[int, int, int], b: tuple[int, int, int]) -> int:
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def _classify(rgb: tuple[int, int, int], anchors: dict[str, tuple[int, int, int]]) -> str:
    best = None
    best_d = 1 << 30
    for terrain, anchor in anchors.items():
        d = _color_dist_sq(rgb, anchor)
        if d < best_d:
            best_d = d
            best = terrain
    return best


def _detect_palette(img: Image.Image, region: tuple[int, int, int, int]) -> str:
    """Detect NES vs tanke palette. Primary signal: image mode (NES references
    from StrategyWiki are 8-bit indexed-color P-mode; tanke --write-movie
    output is RGB). Fallback: count cells matching pure black, since NES
    backgrounds are (0,0,0) — if even one play-area cell sample is pure
    black the palette is NES.

    iter 005 fix: prior version sampled a single pixel at (x+1, y+1), which
    falsely classified stage 32 (top-left cell is ice gray, not empty black)
    as tanke palette → 311-cell steel-vs-ice confusion."""
    if img.mode == "P":
        return "nes"
    if img.mode in ("RGBA", "L"):
        return "tanke"
    # mode == "RGB" or other: fall back to content sampling.
    rgb = img.convert("RGB")
    x, y, _w, _h = region
    # Sample 16 cell-centers spread across the play area.
    for r in range(0, ROWS, max(1, ROWS // 4)):
        for c in range(0, COLS, max(1, COLS // 4)):
            px = rgb.getpixel((x + c * TILE + TILE // 2, y + r * TILE + TILE // 2))
            if max(px) < 30:
                return "nes"
    return "tanke"


def _classify_grid(img: Image.Image, region: tuple[int, int, int, int], anchors) -> list[list[str]]:
    rgb = img.convert("RGB")
    ox, oy, _, _ = region
    grid = []
    for r in range(ROWS):
        row = []
        for c in range(COLS):
            px = rgb.getpixel((ox + c * TILE + TILE // 2, oy + r * TILE + TILE // 2))
            row.append(_classify(px, anchors))
        grid.append(row)
    return grid


def _grid_from_ascii(path: Path) -> list[list[str]]:
    text = path.read_text().splitlines()
    lines = [ln for ln in text if ln.strip()]
    if len(lines) < ROWS:
        raise ValueError(f"ASCII source {path} has {len(lines)} non-empty rows; need {ROWS}")
    out = []
    for r in range(ROWS):
        line = lines[r]
        if len(line) < COLS:
            raise ValueError(f"ASCII source {path} row {r} has {len(line)} chars; need {COLS}")
        out.append([ASCII_LEGEND.get(line[c], "unknown") for c in range(COLS)])
    return out


def _diff_grids(ref: list[list[str]], rnd: list[list[str]], mask: set[tuple[int, int]] = None) -> dict:
    mask = mask or set()
    total = 0
    matched = 0
    mismatches = []
    confusion = {}
    for r in range(ROWS):
        for c in range(COLS):
            if (c, r) in mask:
                continue
            total += 1
            a = ref[r][c]
            b = rnd[r][c]
            if a == b:
                matched += 1
            else:
                mismatches.append({"col": c, "row": r, "ref": a, "render": b})
                key = (a, b)
                confusion[key] = confusion.get(key, 0) + 1
    mismatch_pct = 100.0 * (total - matched) / total if total else 0.0
    return {
        "tiles_total": total,
        "tiles_matched": matched,
        "tiles_mismatched": total - matched,
        "mismatch_pct": round(mismatch_pct, 3),
        "confusion": [
            {"ref": k[0], "render": k[1], "count": v}
            for k, v in sorted(confusion.items(), key=lambda kv: -kv[1])
        ],
        "mismatches": mismatches,
    }


def _auto_region(img: Image.Image) -> tuple[int, int, int, int]:
    """Pick the play-area region by image size. 208x208 -> no offset (NES ref);
    320x240 -> (56,16) offset (tanke --write-movie render); raise on other sizes."""
    w, h = img.size
    if (w, h) == (PLAY_W, PLAY_H):
        return (0, 0, PLAY_W, PLAY_H)
    if (w, h) == (320, 240):
        return (RENDER_OFFSET_X, RENDER_OFFSET_Y, PLAY_W, PLAY_H)
    raise ValueError(f"unsupported image size {w}x{h}; expected 208x208 (NES ref) or 320x240 (tanke render)")


def diff(reference_path: Path, render_path: Path, stage: int = None,
         ascii_source: Path = None, mask_player: bool = True) -> dict:
    if not reference_path.exists():
        raise FileNotFoundError(f"reference PNG not found: {reference_path}")
    if not render_path.exists():
        raise FileNotFoundError(f"render PNG not found: {render_path}")
    ref_img = Image.open(reference_path)
    rnd_img = Image.open(render_path)
    ref_region = _auto_region(ref_img)
    rnd_region = _auto_region(rnd_img)

    ref_palette = _detect_palette(ref_img, ref_region)
    rnd_palette = _detect_palette(rnd_img, rnd_region)

    ref_anchors = NES_ANCHORS if ref_palette == "nes" else TANKE_ANCHORS
    rnd_anchors = NES_ANCHORS if rnd_palette == "nes" else TANKE_ANCHORS

    ref_grid = _classify_grid(ref_img, ref_region, ref_anchors)
    rnd_grid = _classify_grid(rnd_img, rnd_region, rnd_anchors)

    mask = PLAYER_MASK_CELLS if mask_player else set()
    result = _diff_grids(ref_grid, rnd_grid, mask=mask)
    result["stage"] = stage
    result["reference"] = str(reference_path)
    result["render"] = str(render_path)
    result["ref_palette"] = ref_palette
    result["rnd_palette"] = rnd_palette
    result["mask_player"] = mask_player

    if ascii_source is not None:
        ascii_grid = _grid_from_ascii(ascii_source)
        ascii_vs_ref = _diff_grids(ascii_grid, ref_grid, mask=mask)
        ascii_vs_rnd = _diff_grids(ascii_grid, rnd_grid, mask=mask)
        result["ascii_vs_ref"] = {
            "mismatch_pct": ascii_vs_ref["mismatch_pct"],
            "tiles_mismatched": ascii_vs_ref["tiles_mismatched"],
        }
        result["ascii_vs_render"] = {
            "mismatch_pct": ascii_vs_rnd["mismatch_pct"],
            "tiles_mismatched": ascii_vs_rnd["tiles_mismatched"],
        }
    return result


def _format_human(result: dict) -> str:
    lines = []
    stage = result.get("stage")
    lines.append(f"=== png_diff stage {stage} ===" if stage else "=== png_diff ===")
    lines.append(f"reference: {result['reference']} ({result['ref_palette']} palette)")
    lines.append(f"render:    {result['render']} ({result['rnd_palette']} palette)")
    lines.append(f"tiles:     {result['tiles_total']} ({'masked player' if result['mask_player'] else 'no mask'})")
    lines.append(f"matched:   {result['tiles_matched']}")
    lines.append(f"MISMATCH:  {result['tiles_mismatched']} ({result['mismatch_pct']}%)")
    if result["confusion"]:
        lines.append("confusion (top 10):")
        for c in result["confusion"][:10]:
            lines.append(f"  {c['ref']:>6} -> {c['render']:<6} : {c['count']}")
    if "ascii_vs_ref" in result:
        lines.append(f"ascii_vs_ref:    {result['ascii_vs_ref']['mismatch_pct']}% ({result['ascii_vs_ref']['tiles_mismatched']} cells)")
        lines.append(f"ascii_vs_render: {result['ascii_vs_render']['mismatch_pct']}% ({result['ascii_vs_render']['tiles_mismatched']} cells)")
    return "\n".join(lines)


def main(argv=None):
    p = argparse.ArgumentParser(description="Arc-3 BC stage PNG diff.")
    p.add_argument("--reference", required=True, help="Path to canonical NES reference PNG (208x208).")
    p.add_argument("--render", required=True, help="Path to tanke render PNG (320x240, --write-movie output).")
    p.add_argument("--stage", type=int, default=None, help="Stage number (for report header + auto ASCII lookup).")
    p.add_argument("--ascii-source", default=None, help="Optional: path to Tanks ASCII grid for triple-diff.")
    p.add_argument("--no-mask-player", action="store_true", help="Disable the 3x2 PlayerTank mask.")
    p.add_argument("--json", action="store_true", help="Emit JSON instead of human-readable report.")
    args = p.parse_args(argv)

    ascii_path = None
    if args.ascii_source:
        ascii_path = Path(args.ascii_source)
    elif args.stage is not None:
        # Auto-pick the canonical Tanks ASCII source if --stage K given.
        candidate = Path(f".research/repos/Tanks/resources/stages/{args.stage}")
        if candidate.exists():
            ascii_path = candidate

    try:
        result = diff(
            Path(args.reference),
            Path(args.render),
            stage=args.stage,
            ascii_source=ascii_path,
            mask_player=not args.no_mask_player,
        )
    except (FileNotFoundError, ValueError) as exc:
        print(f"png_diff ERROR: {exc}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(_format_human(result))
    # Exit code reflects mismatch < 5% threshold (criterion 7/8/9 floor).
    return 0 if result["mismatch_pct"] < 5.0 else 1


if __name__ == "__main__":
    sys.exit(main())
