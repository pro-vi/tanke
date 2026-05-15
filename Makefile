GODOT          ?= godot
PROJECT_DIR    := $(shell pwd)
HEADLESS        = $(GODOT) --headless --path $(PROJECT_DIR)
RENDERER        = $(GODOT) --path $(PROJECT_DIR) --rendering-method forward_plus

PROC_SCENE     := scenes/ProceduralLevel.tscn
OG_SCENE       := scenes/OriginalLevel.tscn
TEST_FRAMES    ?= 120
CAPTURE_FRAMES ?= 5
NOISE_FILTER    = grep -Ev "RID allocations|resources still in use"
FRAMES_DIR      = $(PROJECT_DIR)/tools/out
REFS_DIR        = $(PROJECT_DIR)/tools/refs

.PHONY: check test screenshot analyze run diff screenshot-og png-diff-og

# Parse/load validation — catches bad scripts and missing nodes
check:
	@out=$$($(HEADLESS) --quit 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Runtime validation — runs TEST_FRAMES frames, catches _ready/_process errors
test:
	@out=$$($(HEADLESS) $(PROC_SCENE) --quit-after $(TEST_FRAMES) 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Capture frame PNGs via --write-movie (Metal renderer, window flashes briefly)
screenshot:
	@mkdir -p $(FRAMES_DIR)
	@rm -f $(FRAMES_DIR)/frame*.png $(FRAMES_DIR)/frame*.wav
	$(RENDERER) \
		--write-movie $(FRAMES_DIR)/frame.png \
		--fixed-fps 1 --quit-after $(CAPTURE_FRAMES) \
		$(PROC_SCENE) 2>/dev/null || true
	@latest=$$(ls $(FRAMES_DIR)/frame*.png 2>/dev/null | tail -1); \
	if [ -n "$$latest" ]; then echo "captured: $$latest"; else echo "ERROR: no frames written"; exit 1; fi

# PIL tile distribution oracle — reads latest frame from tools/out/
analyze:
	@latest=$$(ls $(FRAMES_DIR)/frame*.png 2>/dev/null | tail -1); \
	if [ -z "$$latest" ]; then echo "run 'make screenshot' first"; exit 1; fi; \
	python3 $(PROJECT_DIR)/tools/analyze_frame.py "$$latest"

# Diff two screencaptures: default config vs CONFIG=<name>
# Usage: make diff CONFIG=watery   (or fortress, default)
diff:
	@if [ -z "$(CONFIG)" ]; then echo "usage: make diff CONFIG=<name>"; exit 1; fi
	@mkdir -p $(FRAMES_DIR)
	@find $(FRAMES_DIR) -name "frame_a*.png" -delete 2>/dev/null; find $(FRAMES_DIR) -name "frame_b*.png" -delete 2>/dev/null; true
	@find $(FRAMES_DIR) -name "frame_a*.wav" -delete 2>/dev/null; find $(FRAMES_DIR) -name "frame_b*.wav" -delete 2>/dev/null; true
	@TANKE_SEED=42 $(RENDERER) --write-movie $(FRAMES_DIR)/frame_a.png \
		--fixed-fps 1 --quit-after $(CAPTURE_FRAMES) $(PROC_SCENE) 2>/dev/null || true
	@TANKE_SEED=42 TANKE_CONFIG=res://configs/$(CONFIG).tres $(RENDERER) \
		--write-movie $(FRAMES_DIR)/frame_b.png \
		--fixed-fps 1 --quit-after $(CAPTURE_FRAMES) $(PROC_SCENE) 2>/dev/null || true
	@a=$$(ls $(FRAMES_DIR)/frame_a*.png 2>/dev/null | tail -1); \
	 b=$$(ls $(FRAMES_DIR)/frame_b*.png 2>/dev/null | tail -1); \
	 if [ -z "$$a" ] || [ -z "$$b" ]; then echo "ERROR: capture failed"; exit 1; fi; \
	 python3 $(PROJECT_DIR)/tools/analyze_frame.py --diff "$$a" "$$b"

# Arc-3 (originals) screenshot: render OriginalLevel.tscn for STAGE=K.
# Output: $(FRAMES_DIR)/og/stage_KK_NNN.png (NNN = frame number from --write-movie).
# Stage is passed via TANKE_OG_STAGE env var (read by scripts/OriginalLevel.gd).
# Usage: make screenshot-og STAGE=1
screenshot-og:
	@if [ -z "$(STAGE)" ]; then echo "usage: make screenshot-og STAGE=K"; exit 1; fi
	@mkdir -p $(FRAMES_DIR)/og
	@rm -f $(FRAMES_DIR)/og/stage_$(STAGE)_*.png $(FRAMES_DIR)/og/stage_$(STAGE)_*.wav
	@TANKE_OG_STAGE=$(STAGE) $(RENDERER) \
		--write-movie $(FRAMES_DIR)/og/stage_$(STAGE)_.png \
		--fixed-fps 1 --quit-after $(CAPTURE_FRAMES) \
		$(OG_SCENE) 2>/dev/null || true
	@latest=$$(ls $(FRAMES_DIR)/og/stage_$(STAGE)_*.png 2>/dev/null | tail -1); \
	if [ -n "$$latest" ]; then echo "captured: $$latest"; else echo "ERROR: no frames written"; exit 1; fi

# Arc-3 PNG diff: render OG stage K, compare to tools/refs/Battle_City_Stage<KK>.png.
# Usage: make png-diff-og STAGE=1
png-diff-og: screenshot-og
	@k=$$(printf "%02d" $(STAGE)); \
	ref="$(REFS_DIR)/Battle_City_Stage$$k.png"; \
	if [ ! -f "$$ref" ]; then echo "missing reference: $$ref"; exit 1; fi; \
	latest=$$(ls $(FRAMES_DIR)/og/stage_$(STAGE)_*.png 2>/dev/null | tail -1); \
	if [ -z "$$latest" ]; then echo "no render PNG found"; exit 1; fi; \
	python3 $(PROJECT_DIR)/tools/png_diff.py --reference "$$ref" --render "$$latest" --stage $(STAGE)

# Launch the game (editor)
run:
	$(GODOT) --path $(PROJECT_DIR)
