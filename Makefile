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

.PHONY: check test screenshot analyze run diff screenshot-og png-diff-og og-metrics check-loader check-chain check-chain-35 og-band-check check-titlescreen-nav test-all check-breach-config check-breach-shells check-breach-depot check-breach-he-blast check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive test-breach

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

# Arc-3 LevelLoader edge-case test harness (C1 anchor 5). Exercises 4
# failure-mode shapes: happy path, missing file, short row, unknown char.
# Uses /tmp fixtures via the iter-13 stages_dir_override path.
check-loader:
	@$(HEADLESS) --script res://loop/test_loader.gd 2>&1 | grep -E "^\[test_loader|^  (PASS|FAIL)|^ALL_LOADER_TESTS_PASS|^LOADER_TEST_FAILURES"; \
	$(HEADLESS) --script res://loop/test_loader.gd 2>&1 | grep -q "^ALL_LOADER_TESTS_PASS"

# Arc-3 25-stage advance-chain test (RUBRIC C10 anchor 4). Each stage:
# OriginalLevel instantiates; Eagle present + valid; Spawner.stage_number
# matches; no script errors. Cites code-side that "stages 1-25 reachable;
# eagle gameplay survives the full progression".
check-chain:
	@$(HEADLESS) --script res://loop/test_chain_25.gd 2>&1 | grep -E "^  (ok|FAIL)|^CHAIN_25"; \
	$(HEADLESS) --script res://loop/test_chain_25.gd 2>&1 | grep -q "^CHAIN_25_OK"

# Arc-3 35-stage chain + ARC COMPLETE overlay assertion (C10 anchor 5).
# Extends check-chain to all 35 stages, then triggers stage-35 advance and
# verifies the ARC COMPLETE Label under a CanvasLayer materializes.
check-chain-35:
	@$(HEADLESS) --script res://loop/test_chain_35.gd 2>&1 | grep -E "^  (ok|FAIL|overlay)|^CHAIN_35|^ARC_COMPLETE"; \
	$(HEADLESS) --script res://loop/test_chain_35.gd 2>&1 | grep -q "^ARC_COMPLETE_OVERLAY_OK"

# Arc-3 → arc-2 band-overlap auto-check (C12 anchor 5 structural sub-clause).
# Runs procedural oracle at og_calibrated.tres across 5 seeds; asserts
# each metric falls inside OG empirical [min, max] band per og-metrics.json.
# Excludes reachable_cells + rows_climbed as documented scale artifacts.
# Threshold: >=80% in-band pairs.
og-band-check:
	python3 $(PROJECT_DIR)/tools/band_check.py --quiet

# Arc-3 TitleScreen navigation auto-verification (C6 anchor 5). Drives
# headless input synthesis to verify both ORIGINALS and PROCEDURAL
# launch paths work mechanically; also verifies UI affordances present.
check-titlescreen-nav:
	@$(HEADLESS) --script res://loop/test_titlescreen_nav.gd 2>&1 | grep -E "^\[titlescreen-nav|^  (ok|FAIL)|^TITLESCREEN"; \
	$(HEADLESS) --script res://loop/test_titlescreen_nav.gd 2>&1 | grep -q "^TITLESCREEN_NAV_OK"

# Combined test target. Runs procedural + LevelLoader edge cases +
# 25-stage chain + 35-stage chain + TitleScreen nav.
# (RUBRIC C1/5 + C6/5 + C10/4 + C10/5 verification.)
test-all: test check-loader check-chain check-chain-35 check-titlescreen-nav

# Arc-4 breach mode: verify configs/breach_default.tres loads cleanly
# with >=2 distinct bands and per-band terrain-weight overrides (C4
# anchor 1 structural cite).
check-breach-config:
	@$(HEADLESS) --script res://loop/breach/test_breach_config.gd 2>&1 | grep -E "^(band_count|  band\[|BREACH_CONFIG_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_config.gd 2>&1 | grep -q "^BREACH_CONFIG_OK"

# Arc-4 breach mode: verify scripts/Bullet.gd exposes 3 distinct shell
# classes (AP/HE/HEAT) and default = AP (preserves arc-2 baseline).
# C3 anchor 1 structural cite.
check-breach-shells:
	@$(HEADLESS) --script res://loop/breach/test_breach_shells.gd 2>&1 | grep -E "^(shell_classes|BREACH_SHELLS_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_shells.gd 2>&1 | grep -q "^BREACH_SHELLS_OK"

# Arc-4 breach mode: verify scenes/Depot.tscn pauses the scene tree on
# player entry and resumes on exit. Combat-pause contract per CONSULT §9
# constraint 1. C2 anchor 1 structural cite.
check-breach-depot:
	@$(HEADLESS) --script res://loop/breach/test_breach_depot.gd 2>&1 | grep -E "^(BREACH_DEPOT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_depot.gd 2>&1 | grep -q "^BREACH_DEPOT_OK"

# Arc-4 breach mode: verify per-shell-class combat behavior is distinct
# (AP=1x single-hit, HE=1x + radius brick-blast, HEAT=2x single-hit).
# C3 anchor 2 structural cite. Sentence-test eligible for HE.
check-breach-he-blast:
	@$(HEADLESS) --script res://loop/breach/test_breach_he_blast.gd 2>&1 | grep -E "^(  (AP|HE|HEAT)|BREACH_HE_BLAST_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_he_blast.gd 2>&1 | grep -q "^BREACH_HE_BLAST_OK"

# Arc-4 breach mode: verify Loadout.gd finite-reserve schema +
# PlayerTank.gd consume-on-fire wiring. Default null loadout preserves
# arc-2/3 baseline. CONSULT 001 "atomic verb" cite. C1 anchor 1 + C3
# trail toward anchor 4 structural cite.
check-breach-loadout:
	@$(HEADLESS) --script res://loop/breach/test_breach_loadout.gd 2>&1 | grep -E "^(BREACH_LOADOUT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_loadout.gd 2>&1 | grep -q "^BREACH_LOADOUT_OK"

# Arc-4 breach mode: verify Depot 3-choice upgrade catalog applies
# distinct loadout effects (HE refill / HEAT refill / HE max expand) +
# exposes next_band_hint preview field. C2 anchor 2 + C8 anchor 1
# structural cites.
check-breach-depot-choice:
	@$(HEADLESS) --script res://loop/breach/test_breach_depot_choice.gd 2>&1 | grep -E "^(  (he|heat)|BREACH_DEPOT_CHOICE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_depot_choice.gd 2>&1 | grep -q "^BREACH_DEPOT_CHOICE_OK"

# Arc-4 breach mode: verify scenes/BreachLevel.tscn — the first
# end-to-end breach scene — instantiates with breach_mode_enabled,
# breach_config, a player Loadout, and a Depot placement; runs 30
# frames clean. Integration smoke test.
check-breach-level:
	@$(HEADLESS) --script res://loop/breach/test_breach_level.gd 2>&1 | grep -E "^(BREACH_LEVEL_OK|FAIL|ERROR|SCRIPT ERROR)" | grep -v "RID alloc"; \
	$(HEADLESS) --script res://loop/breach/test_breach_level.gd 2>&1 | grep -q "^BREACH_LEVEL_OK"

# Arc-4 breach reachability oracle (PROMPT §REACHABILITY FLOOR).
# Pure-data per-band local reachability: for each band, generate that
# band's config + flood-fill from spawn, require >= 10 tile-rows climbed
# treating brick/steel/water as walls. Runs the canonical seed 42 deep
# (all 3 bands). Stochastic generation has irreducible variance — the
# rigorous floor is >=80% of a 10-seed sweep (see test_breach_harness.gd
# header); seed 42 is the per-iter smoke check.
check-breach-harness:
	@$(HEADLESS) --script res://loop/breach/test_breach_harness.gd -- --seed 42 --deep 2>&1 | grep -E "^(  band|BREACH_HARNESS)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_harness.gd -- --seed 42 --deep 2>&1 | grep -q "^BREACH_HARNESS_OK"

# Arc-4 breach mode: verify RunRecap.gd death attribution — captures
# depth + killing band + per-type shell consumption + reserves; formats
# a recap. C6 anchors 1+2 structural cite.
check-breach-recap:
	@$(HEADLESS) --script res://loop/breach/test_breach_recap.gd 2>&1 | grep -E "^(RUN RECAP|  |BREACH_RECAP_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_recap.gd 2>&1 | grep -q "^BREACH_RECAP_OK"

# Arc-4 breach mode: verify band-aware enemy roster — all 5 bands
# declare valid enemy_weights; Spawner picks band-appropriate types in
# breach mode. C5 anchor 1 structural cite.
check-breach-enemies:
	@$(HEADLESS) --script res://loop/breach/test_breach_enemies.gd 2>&1 | grep -E "^(  (band|role)|BREACH_ENEMIES_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_enemies.gd 2>&1 | grep -q "^BREACH_ENEMIES_OK"

# Arc-4 breach mode: generate + verify the 3 shell-class HUD icons via
# gen_tile.py; routes them through the silhouette-grammar gate. C7
# anchor 1.
check-breach-assets:
	python3 $(PROJECT_DIR)/tools/check_shell_icons.py

# Arc-4 breach mode: the silhouette-grammar gate itself (C7 anchor 2) —
# run tools/silhouette_gate.py directly on the generated shell icons.
# The reusable PASS/FAIL gate for CONSULT §9 constraint 4.
check-silhouette-gate:
	@for s in shell_ap shell_he shell_heat; do python3 $(PROJECT_DIR)/tools/gen_tile.py --tile $$s --variant 0 >/dev/null; done
	python3 $(PROJECT_DIR)/tools/silhouette_gate.py \
		$(FRAMES_DIR)/shell_ap_000.png $(FRAMES_DIR)/shell_he_000.png $(FRAMES_DIR)/shell_heat_000.png

# Arc-4 breach mode: verify HEAT armor-bypass — armored-group bodies
# take AP/HE mitigated (blocked at base damage 1); HEAT bypasses.
# C3 anchor 3 structural cite.
check-breach-armor:
	@$(HEADLESS) --script res://loop/breach/test_breach_armor.gd 2>&1 | grep -E "^(  (AP|HE|HEAT)|BREACH_ARMOR_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_armor.gd 2>&1 | grep -q "^BREACH_ARMOR_OK"

# Arc-4 breach mode: verify the "Breach Dividend" depot rule-changer —
# an HE breach of >=4 bricks refunds 1 HE only when the upgrade is
# owned (CONSULT 002 #2). Capped at max_he_reserve.
check-breach-dividend:
	@$(HEADLESS) --script res://loop/breach/test_breach_dividend.gd 2>&1 | grep -E "^(  dividend|BREACH_DIVIDEND_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_dividend.gd 2>&1 | grep -q "^BREACH_DIVIDEND_OK"

# Arc-4 breach mode: verify the shell-swap reload cost — a real swap
# arms a >=0.5s cooldown that blocks _fire; arc-2/3 unaffected.
# C3 anchor 4 structural cite.
check-breach-swap:
	@$(HEADLESS) --script res://loop/breach/test_breach_swap.gd 2>&1 | grep -E "^(  (swap|fire)|BREACH_SWAP_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_swap.gd 2>&1 | grep -q "^BREACH_SWAP_OK"

# Arc-4 breach mode: verify the OVERDRIVE sprint upgrade — grants the
# positioning verb; the 7-entry catalog covers all 5 band pressures.
# C8 anchor 3 structural cite.
check-breach-overdrive:
	@$(HEADLESS) --script res://loop/breach/test_breach_overdrive.gd 2>&1 | grep -E "^(  (catalog|sprint)|BREACH_OVERDRIVE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_overdrive.gd 2>&1 | grep -q "^BREACH_OVERDRIVE_OK"

# Arc-4 breach mode: all breach harnesses in one target.
test-breach: check-breach-config check-breach-shells check-breach-depot check-breach-he-blast check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive

# Arc-3 → arc-2 metric handshake: compute per-stage structural metrics
# across all 35 BC stages and emit loop/originals/og-metrics.json.
# Usage: make og-metrics
og-metrics:
	python3 $(PROJECT_DIR)/tools/og_metrics.py --quiet
	@echo "summary preview:"
	@python3 -c "import json; d=json.load(open('loop/originals/og-metrics.json')); [print(f'  {k}: mean={s[\"mean\"]:.3f}  stdev={s[\"stdev\"]:.3f}  range=[{s[\"min\"]:.3f}, {s[\"max\"]:.3f}]') for k, s in d['summary']['per_metric'].items()]"

# Launch the game (editor)
run:
	$(GODOT) --path $(PROJECT_DIR)
