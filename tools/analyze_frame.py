#!/usr/bin/env python3
"""
Tile distribution oracle for tanke procedural levels.

Single-frame mode: classifies every pixel by nearest tile color,
reports coverage, variety, and distribution entropy as oracle scores.

Diff mode: compares two frames, reports per-terrain pixel deltas and
whether a shift was detected (>=5% relative or >=500 absolute on any terrain).

Usage:
    python3 tools/analyze_frame.py <frame.png>
    python3 tools/analyze_frame.py          # uses latest tools/out/frame*.png
    python3 tools/analyze_frame.py --diff <a.png> <b.png>
    make analyze
"""
import sys
import json
import math
from pathlib import Path
from collections import Counter

try:
    from PIL import Image
except ImportError:
    print("ERROR: pip install Pillow", file=sys.stderr)
    sys.exit(1)

PROJECT     = Path(__file__).parent.parent
SPRITE_SHEET = PROJECT / "img" / "sprites_1.png"
FRAMES_DIR  = PROJECT / "tools" / "out"

VIEWPORT_W, VIEWPORT_H = 320, 240

# Tile definitions: name -> (margin_x, margin_y) in sprites_1.png (8x8 tiles)
TILE_DEFS = {
    "brick": (40, 0),
    "steel": (16, 0),
    "grass": (24, 0),
    "water": (24, 8),
}

# Distance threshold — pixels further than this from any tile color are background
CLASSIFY_THRESHOLD = 70


def extract_palette(sheet_path: Path) -> dict[str, list[tuple]]:
    """Read all non-black pixels from each tile region; return palette per tile."""
    sheet = Image.open(sheet_path).convert("RGB")
    palette: dict[str, list[tuple]] = {}
    for name, (mx, my) in TILE_DEFS.items():
        colors = []
        for dy in range(8):
            for dx in range(8):
                px = sheet.getpixel((mx + dx, my + dy))
                if sum(px) > 30:  # skip near-black
                    colors.append(px)
        # Keep top-3 most frequent distinct colors for this tile
        top = [c for c, _ in Counter(colors).most_common(3)]
        palette[name] = top
    return palette


def color_dist(a: tuple, b: tuple) -> float:
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def classify(rgb: tuple, palette: dict[str, list[tuple]]) -> str:
    best_label, best_dist = "background", float("inf")
    for label, refs in palette.items():
        for ref in refs:
            d = color_dist(rgb, ref)
            if d < best_dist:
                best_dist = d
                best_label = label
    return best_label if best_dist < CLASSIFY_THRESHOLD else "background"


def entropy(counts: dict) -> float:
    total = sum(counts.values())
    if total == 0:
        return 0.0
    result = 0.0
    for v in counts.values():
        if v > 0:
            p = v / total
            result -= p * math.log2(p)
    return result


def analyze(frame_path: Path) -> dict:
    palette = extract_palette(SPRITE_SHEET)

    frame = Image.open(frame_path).convert("RGB")
    if frame.size != (VIEWPORT_W, VIEWPORT_H):
        frame = frame.resize((VIEWPORT_W, VIEWPORT_H), Image.NEAREST)

    pixels = frame.load()
    counts: dict[str, int] = {name: 0 for name in TILE_DEFS}
    counts["background"] = 0

    for y in range(VIEWPORT_H):
        for x in range(VIEWPORT_W):
            label = classify(pixels[x, y], palette)
            counts[label] = counts.get(label, 0) + 1

    total     = VIEWPORT_W * VIEWPORT_H
    terrain   = total - counts["background"]
    coverage  = terrain / total

    tile_only = {k: counts[k] for k in TILE_DEFS}
    variety   = sum(1 for v in tile_only.values() if v > 0)
    tile_ent  = entropy(tile_only)
    max_ent   = math.log2(len(TILE_DEFS))  # 4 types → 2.0 bits max

    # Rubric-aligned scores (0–5)
    score_coverage     = min(5, round(coverage * 10))       # 50% = 5
    score_variety      = variety                             # 0–4 (of 4 types)
    score_distribution = round((tile_ent / max_ent) * 5, 1) if tile_ent > 0 else 0.0

    return {
        "frame": frame_path.name,
        "coverage_pct": round(coverage * 100, 1),
        "variety_types": variety,
        "tile_entropy_bits": round(tile_ent, 3),
        "tile_entropy_normalized": round(tile_ent / max_ent, 3),
        "counts": counts,
        "palette_refs": {k: [list(c) for c in v] for k, v in palette.items()},
        "scores": {
            "coverage":     score_coverage,
            "variety":      score_variety,
            "distribution": score_distribution,
        },
    }


def diff(path_a: Path, path_b: Path) -> dict:
    """Compute per-terrain pixel delta between two frames."""
    a = analyze(path_a)
    b = analyze(path_b)
    deltas = {}
    for k in TILE_DEFS:
        ca, cb = a["counts"][k], b["counts"][k]
        delta = cb - ca
        pct = (delta / ca * 100.0) if ca > 0 else (float("inf") if cb > 0 else 0.0)
        deltas[k] = {
            "before": ca,
            "after": cb,
            "delta": delta,
            "pct_change": round(pct, 2),
        }
    # "Significant" shift: any terrain moved by >= 5% relative or 500 absolute pixels
    significant = any(
        abs(d["delta"]) >= 500 or abs(d["pct_change"]) >= 5
        for d in deltas.values()
    )
    return {
        "before_frame": path_a.name,
        "after_frame": path_b.name,
        "before_entropy_bits": a["tile_entropy_bits"],
        "after_entropy_bits": b["tile_entropy_bits"],
        "entropy_delta_bits": round(b["tile_entropy_bits"] - a["tile_entropy_bits"], 3),
        "deltas": deltas,
        "shift_detected": significant,
    }


def _print_diff(d: dict) -> None:
    print(f"\n=== Frame Diff: {d['before_frame']} → {d['after_frame']} ===")
    print(f"{'terrain':<8} {'before':>7} {'after':>7} {'Δ pixels':>10} {'Δ %':>8}")
    print("-" * 44)
    for k, v in d["deltas"].items():
        print(f"{k:<8} {v['before']:>7} {v['after']:>7} {v['delta']:>+10} {v['pct_change']:>+7.1f}%")
    print(f"entropy: {d['before_entropy_bits']:.3f} → {d['after_entropy_bits']:.3f} bits  "
          f"(Δ {d['entropy_delta_bits']:+.3f})")
    print(f"shift_detected: {d['shift_detected']}")


def main():
    if len(sys.argv) >= 4 and sys.argv[1] == "--diff":
        path_a = Path(sys.argv[2])
        path_b = Path(sys.argv[3])
        for p in (path_a, path_b):
            if not p.exists():
                print(f"ERROR: {p} not found", file=sys.stderr)
                sys.exit(1)
        result = diff(path_a, path_b)
        print(json.dumps(result, indent=2))
        _print_diff(result)
        return

    if len(sys.argv) > 1:
        frame_path = Path(sys.argv[1])
        if not frame_path.exists():
            print(f"ERROR: {frame_path} not found", file=sys.stderr)
            sys.exit(1)
    else:
        frames = sorted(FRAMES_DIR.glob("frame*.png"))
        if not frames:
            print("ERROR: no frames in tools/out/ — run 'make screenshot' first", file=sys.stderr)
            sys.exit(1)
        frame_path = frames[-1]

    result = analyze(frame_path)
    print(json.dumps(result, indent=2))

    s = result["scores"]
    print(f"\n=== Oracle: {result['frame']} ===")
    print(f"Coverage     {result['coverage_pct']:5.1f}%   score {s['coverage']}/5")
    print(f"Variety      {result['variety_types']}/4 types  score {s['variety']}/4")
    print(f"Distribution entropy {result['tile_entropy_bits']:.3f} bits  score {s['distribution']}/5.0")
    print(f"Tile counts  {dict((k,v) for k,v in result['counts'].items() if k != 'background')}")


if __name__ == "__main__":
    main()
