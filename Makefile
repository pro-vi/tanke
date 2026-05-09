GODOT       ?= godot
PROJECT_DIR := $(shell pwd)
HEADLESS     = $(GODOT) --headless --path $(PROJECT_DIR)

.PHONY: check run export

# Run headless parse/load check — filters noise, exits non-zero on errors
check:
	@out=$$($(HEADLESS) --quit 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | grep -Ev "RID allocations|resources still in use"); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Launch the game (editor mode)
run:
	$(GODOT) --path $(PROJECT_DIR)

# Headless scene test (pass scene=path/to/Scene.tscn)
scene:
	$(HEADLESS) $(scene) --quit
