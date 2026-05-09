GODOT       ?= godot
PROJECT_DIR := $(shell pwd)
HEADLESS     = $(GODOT) --headless --path $(PROJECT_DIR)

PROC_SCENE  := scenes/ProceduralLevel.tscn
TEST_FRAMES ?= 120
NOISE_FILTER = grep -Ev "RID allocations|resources still in use"

.PHONY: check test screenshot run

# Parse/load validation — catches bad scripts and missing nodes
check:
	@out=$$($(HEADLESS) --quit 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Runtime validation — runs TEST_FRAMES frames, catches _ready/_process errors
test:
	@out=$$($(HEADLESS) $(PROC_SCENE) --quit-after $(TEST_FRAMES) 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Capture a frame as PNG for PIL/oracle analysis
screenshot:
	@mkdir -p $(PROJECT_DIR)/tools/out
	$(HEADLESS) $(PROC_SCENE) --quit-after $(TEST_FRAMES) 2>/dev/null; \
	echo "screenshot saved to tools/out/frame.png if capture script is wired"

# Launch the game (editor)
run:
	$(GODOT) --path $(PROJECT_DIR)
