#!/usr/bin/env python3
"""
Arc-4 breach mode: shell-icon asset verifier (C7 anchor 1).

Generates the 3 shell-class HUD icons via gen_tile.py's shell
generators, then routes them through tools/silhouette_gate.py — the
reusable CONSULT §9 constraint-4 grammar gate (C7 anchor 2).

Reports BREACH_ASSETS_OK / FAIL.

Usage: python3 tools/check_shell_icons.py
"""

import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "tools"))
from silhouette_gate import gate  # noqa: E402

OUT = REPO / "tools" / "out"
SHELLS = ["shell_ap", "shell_he", "shell_heat"]


def main() -> int:
    paths = []
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
        paths.append(path)

    # Route the generated assets through the silhouette-grammar gate.
    result = gate(paths)
    for ln in result["lines"]:
        print(ln)
    if not result["passed"]:
        print("BREACH_ASSETS_FAIL — silhouette gate rejected the shell icons")
        return 1

    print("BREACH_ASSETS_OK 3 shell icons — passed the silhouette-grammar gate")
    return 0


if __name__ == "__main__":
    sys.exit(main())
