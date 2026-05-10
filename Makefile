GODOT          ?= godot
PROJECT_DIR    := $(shell pwd)
HEADLESS        = $(GODOT) --headless --path $(PROJECT_DIR)
RENDERER        = $(GODOT) --path $(PROJECT_DIR) --rendering-method forward_plus

PROC_SCENE     := scenes/ProceduralLevel.tscn
TEST_FRAMES    ?= 120
CAPTURE_FRAMES ?= 5
NOISE_FILTER    = grep -Ev "RID allocations|resources still in use"
FRAMES_DIR      = $(PROJECT_DIR)/tools/out

.PHONY: check test screenshot analyze run

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

# Launch the game (editor)
run:
	$(GODOT) --path $(PROJECT_DIR)
