#!/usr/bin/env python3
"""
Arc-4 breach mode: shell-icon asset verifier (C7 anchor 1).

Generates the 3 shell-class HUD icons via gen_tile.py's shell generators
and applies a lightweight silhouette-grammar check (CONSULT §9
constraint 4): each icon must be a valid 8x8 RGBA PNG with a non-trivial
opaque footprint, and the 3 footprints must be pairwise distinct
(>= MIN_SILHOUETTE_DIFF differing cells) so the player can read shell
class from silhouette alone.

This is the iter-17 structural proxy for the formal grammar-check tool
(C7 anchor 2 — a later iter). Reports BREACH_ASSETS_OK / FAIL.

Usage: python3 tools/check_shell_icons.py
"""

import itertools
import subprocess
import sys
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parent.parent
OUT = REPO / "tools" / "out"
SHELLS = ["shell_ap", "shell_he", "shell_heat"]
MIN_SILHOUETTE_DIFF = 8   # min differing opaque-cells between any pair
MIN_OPAQUE = 4            # min opaque cells for a non-trivial icon


def main() -> int:
    imgs = {}
    for name in SHELLS:
        r = subprocess.run(
            [sys.executable, str(REPO / "tools" / "gen_tile.py"),
             "--tile", name, "--variant", "0"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            print(f"FAIL — gen_tile.py {name} exited {r.returncode}: {r.stderr}")
            return 1
        path = OUT / f"{name}_000.png"
        if not path.exists():
            print(f"FAIL — {path} not produced")
            return 1
        im = Image.open(path).convert("RGBA")
        if im.size != (8, 8):
            print(f"FAIL — {name} is {im.size}, expected (8, 8)")
            return 1
        opaque = sum(1 for p in im.getdata() if p[3] > 0)
        if opaque < MIN_OPAQUE:
            print(f"FAIL — {name} footprint {opaque}px < {MIN_OPAQUE}")
            return 1
        imgs[name] = im
        print(f"  {name}: 8x8  {opaque} opaque px")

    # Pairwise silhouette distinctness.
    for a, b in itertools.combinations(SHELLS, 2):
        da = [1 if p[3] > 0 else 0 for p in imgs[a].getdata()]
        db = [1 if p[3] > 0 else 0 for p in imgs[b].getdata()]
        diff = sum(1 for x, y in zip(da, db) if x != y)
        if diff < MIN_SILHOUETTE_DIFF:
            print(f"FAIL — {a} vs {b} silhouette diff {diff} < {MIN_SILHOUETTE_DIFF}")
            return 1
        print(f"  silhouette {a} vs {b}: {diff}px distinct")

    print("BREACH_ASSETS_OK 3 shell icons — valid 8x8, pairwise silhouette-distinct")
    return 0


if __name__ == "__main__":
    sys.exit(main())
