"""
Spritesheet assembler — takes individual frame PNGs, outputs a sheet
matching Godot 4 TileSet or TankSprite.gd frame layout.

Usage:
    uv run tools/compose_sheet.py --frames a.png b.png ... --cols 4 --out sheet.png
    uv run tools/compose_sheet.py --dir tools/out/tank --cols 8 --frame-w 16 --frame-h 16 --out img/TankNew.png
"""

import argparse
from pathlib import Path
from PIL import Image


def compose(frames: list[Image.Image], cols: int, frame_w: int, frame_h: int) -> Image.Image:
    rows = (len(frames) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * frame_w, rows * frame_h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        frame = frame.resize((frame_w, frame_h), Image.NEAREST)
        x = (i % cols) * frame_w
        y = (i // cols) * frame_h
        sheet.paste(frame, (x, y))
    return sheet


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--frames", nargs="*", type=Path, default=[])
    ap.add_argument("--dir", type=Path, help="load all PNGs from directory, sorted")
    ap.add_argument("--cols", type=int, default=4)
    ap.add_argument("--frame-w", type=int, default=8)
    ap.add_argument("--frame-h", type=int, default=8)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()

    paths: list[Path] = []
    if args.dir:
        paths = sorted(args.dir.glob("*.png"))
    paths += list(args.frames)

    if not paths:
        print("no input frames")
        return

    frames = [Image.open(p).convert("RGBA") for p in paths]
    sheet = compose(frames, args.cols, args.frame_w, args.frame_h)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.out)
    print(f"saved {args.out} ({sheet.width}x{sheet.height}, {len(frames)} frames)")


if __name__ == "__main__":
    main()
