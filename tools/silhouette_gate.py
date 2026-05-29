#!/usr/bin/env python3
"""
Arc-4 silhouette-grammar gate (C7 anchor 2).

The reusable PASS/FAIL gate enforcing CONSULT §9 constraint 4 — "no
generated asset enters the game unless its role is readable from
silhouette, palette, facing, and one-frame intent". Any arc-4 BUILD
that ships a generated asset routes it through this gate.

Checks, for a set of PNGs that are meant to be visually distinct:
  1. each is a valid RGBA PNG of the expected size
  2. each has a non-trivial opaque footprint (>= MIN_OPAQUE cells)
  3. every pair is silhouette-distinct (>= MIN_SILHOUETTE_DIFF cells
     where one is opaque and the other is not)
  4. every pair is palette-distinct (mean opaque-pixel color differs)

Library use:
    from silhouette_gate import gate
    result = gate([path1, path2, ...])      # -> {"passed": bool, ...}

CLI use:
    python3 tools/silhouette_gate.py a.png b.png c.png
    -> prints per-asset + per-pair lines, then SILHOUETTE_GATE_PASS/FAIL
"""

import itertools
import sys
from pathlib import Path

from PIL import Image

MIN_OPAQUE = 4
MIN_SILHOUETTE_DIFF = 8
MIN_PALETTE_DIFF = 20.0   # min mean-channel distance between opaque means


def _opaque_cells(im: Image.Image) -> list[int]:
    return [1 if p[3] > 0 else 0 for p in im.getdata()]


def _opaque_mean(im: Image.Image) -> tuple[float, float, float]:
    rs = gs = bs = n = 0
    for p in im.getdata():
        if p[3] > 0:
            rs += p[0]; gs += p[1]; bs += p[2]; n += 1
    if n == 0:
        return (0.0, 0.0, 0.0)
    return (rs / n, gs / n, bs / n)


def gate(paths, expect_size=(8, 8)) -> dict:
    """Run the silhouette-grammar gate. Returns {passed, lines}."""
    lines: list[str] = []
    imgs: dict[str, Image.Image] = {}
    for p in paths:
        path = Path(p)
        if not path.exists():
            return {"passed": False, "lines": [f"FAIL — {path} missing"]}
        im = Image.open(path).convert("RGBA")
        if im.size != expect_size:
            return {"passed": False,
                    "lines": [f"FAIL — {path.name} is {im.size}, expected {expect_size}"]}
        opaque = sum(_opaque_cells(im))
        if opaque < MIN_OPAQUE:
            return {"passed": False,
                    "lines": [f"FAIL — {path.name} footprint {opaque} < {MIN_OPAQUE}"]}
        imgs[path.name] = im
        lines.append(f"  {path.name}: {expect_size[0]}x{expect_size[1]}  {opaque} opaque px")

    names = list(imgs)
    for a, b in itertools.combinations(names, 2):
        da, db = _opaque_cells(imgs[a]), _opaque_cells(imgs[b])
        sil_diff = sum(1 for x, y in zip(da, db) if x != y)
        ma, mb = _opaque_mean(imgs[a]), _opaque_mean(imgs[b])
        pal_diff = sum(abs(x - y) for x, y in zip(ma, mb)) / 3.0
        if sil_diff < MIN_SILHOUETTE_DIFF:
            return {"passed": False,
                    "lines": lines + [f"FAIL — {a} vs {b} silhouette diff {sil_diff} < {MIN_SILHOUETTE_DIFF}"]}
        if pal_diff < MIN_PALETTE_DIFF:
            return {"passed": False,
                    "lines": lines + [f"FAIL — {a} vs {b} palette diff {pal_diff:.1f} < {MIN_PALETTE_DIFF}"]}
        lines.append(f"  {a} vs {b}: silhouette {sil_diff}px / palette {pal_diff:.0f} — distinct")

    return {"passed": True, "lines": lines}


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: silhouette_gate.py <png> <png> [<png> ...]")
        return 2
    result = gate(sys.argv[1:])
    for ln in result["lines"]:
        print(ln)
    if result["passed"]:
        print("SILHOUETTE_GATE_PASS %d assets — silhouette + palette distinct" % (len(sys.argv) - 1))
        return 0
    print("SILHOUETTE_GATE_FAIL")
    return 1


if __name__ == "__main__":
    sys.exit(main())
