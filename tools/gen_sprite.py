"""
MLX Stable Diffusion sprite generator — for novel character/enemy sprites.
Requires: uv tool install mlx-stable-diffusion (first run installs model ~2GB)

Usage:
    uv run tools/gen_sprite.py --prompt "pixel art enemy tank top-down 8bit" --out tools/out/enemy_raw.png
    uv run tools/gen_sprite.py --prompt "..." --palette img/sprites_0.png --out tools/out/sprite.png

The --palette flag extracts the dominant colors from an existing sprite and
quantizes the output to that palette for visual consistency.
"""

import argparse
import sys
from pathlib import Path


def extract_palette(palette_img_path: Path, n_colors: int = 16):
    from PIL import Image
    img = Image.open(palette_img_path).convert("RGBA")
    quantized = img.quantize(colors=n_colors)
    palette_data = quantized.getpalette()[:n_colors * 3]
    colors = [(palette_data[i], palette_data[i+1], palette_data[i+2]) for i in range(0, len(palette_data), 3)]
    return colors


def quantize_to_palette(img, palette_colors):
    from PIL import Image
    palette_img = Image.new("P", (1, 1))
    flat = []
    for r, g, b in palette_colors:
        flat += [r, g, b]
    flat += [0] * (768 - len(flat))
    palette_img.putpalette(flat)
    return img.convert("RGB").quantize(palette=palette_img, dither=0).convert("RGBA")


def generate_mlx(prompt: str, width: int, height: int, steps: int, seed: int):
    try:
        from mlx_stable_diffusion import StableDiffusionPipeline
    except ImportError:
        print("mlx-stable-diffusion not installed. Run: uv tool install mlx-stable-diffusion")
        sys.exit(1)

    pipe = StableDiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-2-1-base")
    result = pipe(
        prompt=prompt,
        negative_prompt="blurry, realistic, 3d, photograph",
        width=width,
        height=height,
        num_inference_steps=steps,
        seed=seed,
    )
    return result.images[0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--palette", type=Path, help="extract palette from this image")
    ap.add_argument("--width", type=int, default=64)
    ap.add_argument("--height", type=int, default=64)
    ap.add_argument("--steps", type=int, default=20)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--scale", type=int, default=1, help="nearest-neighbor upscale for preview")
    args = ap.parse_args()

    print(f"generating: {args.prompt!r}")
    img = generate_mlx(args.prompt, args.width, args.height, args.steps, args.seed)

    if args.palette:
        print(f"quantizing to palette from {args.palette}")
        colors = extract_palette(args.palette)
        img = quantize_to_palette(img, colors)

    if args.scale > 1:
        from PIL import Image
        img = img.resize((args.width * args.scale, args.height * args.scale), Image.NEAREST)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    img.save(args.out)
    print(f"saved {args.out}")


if __name__ == "__main__":
    main()
