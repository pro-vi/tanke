---
topic: "Headless screencapture oracle for Godot 4 on macOS"
date: 2026-05-09
projects:
  - name: htdt/godogen
    repo: github.com/htdt/godogen
    sha: eecb493ae17da38a3d8f07cf25c2717e2f330084
    license: MIT
    source: cloned
    source_quality: code-verified
  - name: godot-gdunit-labs/gdUnit4
    repo: github.com/godot-gdunit-labs/gdUnit4
    source: deepwiki
    source_quality: doc-stated
  - name: godot-proposals/offscreen-rendering
    repo: github.com/godotengine/godot-proposals/issues/5790
    source: doc-stated
    source_quality: doc-stated
hypotheses:
  - claim: "--headless fully disables renderer; get_viewport().get_texture() returns blank"
    result: confirmed — headless switches to Dummy rendering server, no pixels at all, _process() may not fire
  - claim: "SubViewport with render_target_update_mode=ALWAYS can produce pixels in headless mode"
    result: refuted — SubViewport rendering also goes through the Dummy server in headless mode
  - claim: "macOS has no Xvfb equivalent; offscreen PNG must come from GDScript or --write-movie"
    result: confirmed — no native macOS virtual display for automation; --write-movie + Metal is the path
key_findings:
  - "--headless = Dummy rendering server + disabled GPU. Cannot produce pixels. Different from Godot 3 --no-window."
  - "--write-movie PATH writes numbered PNG frames (frame00001.png etc.) using the real rendering pipeline"
  - "godogen pattern: godot --headless --import (asset import pass), then godot --rendering-method forward_plus --write-movie --fixed-fps N --quit-after N (capture pass)"
  - "On macOS --write-movie uses Metal directly (forward_plus); window briefly appears and auto-quits"
  - "On Linux/no-display: xvfb-run wraps the render pass; macOS needs no such wrapper"
  - "GUT and gdUnit4 both run headlessly for logic tests but neither supports visual/screenshot assertions"
  - "Godot offscreen rendering PR #94530 exists but not yet released as of May 2026"
  - "--quit-after N must be >= 2 for resource import to complete in headless mode (issue #77508)"
unexplored_threads:
  - "godogen's test/CaptureTask.cs pattern — SceneTree scripts for deterministic camera positioning before first captured frame"
  - "lavapipe/llvmpipe software Vulkan on macOS CI (no GPU) — godogen notes screenshots work but video capture skipped"
  - "godogen's GD.Print('ASSERT PASS/FAIL') stdout pattern — console assertions alongside visual frames"
---

# Screencapture Oracle — Synthesis

## The Core Finding

**`--headless` cannot produce pixels.** It switches Godot's rendering server to "Dummy" — no GPU required, no rendering pipeline, no viewport texture data. This is a deliberate design decision in Godot 4 (different from Godot 3's `--no-window` which kept the renderer running).

**`--write-movie` is the mechanism.** It runs the full rendering pipeline, writes every frame to a numbered PNG sequence, and auto-quits after `--quit-after N` frames. On macOS it uses Metal (`forward_plus`). A window briefly flashes and closes.

## The godogen Pattern (code-verified)

Source: `godot/hooks/capture_result.sh` and `godot/skills/godogen/capture.md`

```bash
# Pass 1: headless import (no rendering, fast)
godot --headless --import 2>&1

# Pass 2: capture (real Metal renderer, window flashes)
godot --path . --rendering-method forward_plus \
    --write-movie screenshots/frame.png \
    --fixed-fps 10 --quit-after 30 \
    --script test/CaptureTask.gd
```

`--write-movie path/frame.png` expands to `frame00001.png`, `frame00002.png`, etc.
`--fixed-fps` makes frame timing deterministic (important: don't use < 10 for physics scenes).
`--quit-after N` is the frame count, not seconds.

### Static scene (2D tile level like tanke)
```bash
godot --path . --rendering-method forward_plus \
    --write-movie tools/out/frame.png \
    --fixed-fps 1 --quit-after 5 \
    scenes/ProceduralLevel.tscn
```
Frame 3–5 will show the fully initialized level. `--fixed-fps 1` is fine for static 2D.

## Comparison Matrix

| Approach | Gets pixels | macOS | Headless | Notes |
|---|---|---|---|---|
| `--headless --quit` | No | Yes | Yes | Zero rendering, fast, no pixels |
| `--headless --quit-after N` | No | Yes | Yes | Same, just N frames |
| `--write-movie --fixed-fps --quit-after` | **Yes** | Yes (window flashes) | No | The real path; Metal on macOS |
| `get_viewport().get_texture().get_image()` in scene | Yes | Yes | No | Works if renderer is active; must await frame_post_draw |
| SubViewport save_png | Yes | Yes | No | Works when renderer is active |
| Xvfb virtual display | N/A | **No** | — | Linux only; macOS has no equivalent |
| BetterDisplay virtual monitor | Partial | Yes | No | GUI tool, not automatable |

## Transfer Assessment for tanke

### `--write-movie` capture pass — 🟢 Transfers directly
Exact godogen pattern works. On this M5 Max: Metal GPU available, `forward_plus` works.

```makefile
screenshot:
	@mkdir -p $(PROJECT_DIR)/tools/out
	$(GODOT) --path $(PROJECT_DIR) --rendering-method forward_plus \
		--write-movie $(PROJECT_DIR)/tools/out/frame.png \
		--fixed-fps 1 --quit-after 5 \
		$(PROC_SCENE) 2>/dev/null || true
```

The `|| true` prevents Make from failing on the RID leak noise Godot prints at exit.

### PIL analysis of frame — 🟢 Transfers directly
After capture, `tools/analyze_frame.py` reads `tools/out/frame000005.png` (last frame = most populated). Analyze:
- Color histogram vs known tile palettes (brick=brownish, steel=grey, grass=green, water=blue)
- Coverage: fraction of pixels that are terrain vs background
- Distribution uniformity: tile type entropy

### `--headless` for logic tests (`make test`) — 🟢 Keep as-is
The existing `make test` (`--quit-after 120` headless) is correct for catching GDScript runtime errors. It just can't produce screenshots. Two separate targets: `make test` (headless, logic), `make screenshot` (rendering, visual).

### Console assertions (`GD.Print("ASSERT")`) — 🟡 Needs minor adaptation
godogen uses C# `GD.Print`. For GDScript: `print("ASSERT PASS: ...")` works the same — just grep the godot output for `ASSERT FAIL`.

## Recommended tanke Makefile Addition

```makefile
CAPTURE_FRAMES ?= 5

screenshot:
	@mkdir -p $(PROJECT_DIR)/tools/out
	$(GODOT) --path $(PROJECT_DIR) --rendering-method forward_plus \
		--write-movie $(PROJECT_DIR)/tools/out/frame.png \
		--fixed-fps 1 --quit-after $(CAPTURE_FRAMES) \
		$(PROC_SCENE) 2>/dev/null || true
	@ls $(PROJECT_DIR)/tools/out/frame*.png 2>/dev/null | tail -1 || echo "no frames written"

analyze:
	python3 $(PROJECT_DIR)/tools/analyze_frame.py \
		$(shell ls $(PROJECT_DIR)/tools/out/frame*.png 2>/dev/null | tail -1)
```

## What the Loop Can Now Do

After implementing `make screenshot` + `tools/analyze_frame.py`:

1. **Edit** `_pave_set()` weights or `ProceduralStep.gd`
2. **`make test`** — catches GDScript errors (headless, ~3s)
3. **`make screenshot`** — captures frame PNG (Metal, ~5s, window flashes)
4. **`make analyze`** — PIL reads tile color histogram, reports coverage and distribution scores
5. **Score** rubric criteria: tile visual coherence, procedural richness

The loop becomes self-contained: edit → validate → visualize → score → iterate.
