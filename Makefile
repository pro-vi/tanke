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

.PHONY: check test screenshot analyze run diff screenshot-og png-diff-og og-metrics check-loader check-chain check-chain-35 og-band-check check-titlescreen-nav test-all check-breach-config check-breach-shells check-breach-depot check-breach-depot-unpause check-breach-he-blast check-breach-he-blast-friendly-fire check-breach-mortar-friendly-fire check-breach-momentum-ram-compose check-breach-rear-guard-dead check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive check-breach-hud check-breach-reload-bar check-breach-speed-meter check-breach-shell-chips check-breach-kill-flash check-breach-active-cards-ribbon check-breach-q1-proof check-breach-run-recap-routes check-breach-route-gate-wiring check-breach-q1-proof-parser check-breach-q1-proof-scene check-breach-q1-proof-playthrough check-breach-route-currency-summary check-breach-h6-pressure-fade check-breach-q1-proof-fire-e2e check-breach-hud-z-stack check-breach-card-pickup-toast check-breach-card-pick-e2e check-breach-apcr check-breach-codex check-breach-shuffle check-breach-depot-roll check-breach-rulechangers check-breach-stakes check-breach-meta check-breach-route check-breach-xp check-breach-ammo check-breach-shield check-breach-hp check-breach-archetype check-breach-prism check-breach-mortar check-breach-ram check-breach-archetype-select check-breach-archetype-switch check-breach-distinctness-audit check-breach-pressure-probes check-breach-band-shape check-breach-band-shape-analyzer check-breach-swarm-spike check-breach-double-kill check-breach-archetype-select-pause test-breach

# Parse/load validation — catches bad scripts and missing nodes
check:
	@out=$$($(HEADLESS) --quit 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Runtime validation — runs TEST_FRAMES frames, catches _ready/_process errors
test:
	@out=$$($(HEADLESS) $(PROC_SCENE) --quit-after $(TEST_FRAMES) 2>&1 | grep -E "^(ERROR|SCRIPT ERROR)" | $(NOISE_FILTER)); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi

# Arc-4 iter 301 (visual-verification discipline): drive Q1ProofRoom,
# dismiss codex, render a few frames, save the final frame to a known
# path. Used by visual-verification convention added to PROMPT.md.
# Invoke before claiming any HUD/visual change "ships clean."
.PHONY: screenshot-q1
screenshot-q1:
	@mkdir -p tools/out
	@rm -f tools/out/q1_frame*.png 2>/dev/null || true
	@$(RENDERER) --write-movie tools/out/q1_frame.png --fixed-fps 1 \
		--quit-after 8 --script res://tools/q1_screenshot.gd 2>/dev/null || true
	@latest=$$(ls -t tools/out/q1_frame*.png 2>/dev/null | head -1); \
	if [ -z "$$latest" ]; then echo "ERROR: no screenshot captured"; exit 1; fi; \
	cp "$$latest" tools/out/q1_latest.png; \
	echo "captured: tools/out/q1_latest.png (was $$latest)"

# Arc-4 iter 304 (visual-verification of iter-302 toast): captures Q1
# room with HP_PLUS_1 picked so the iter-302 pickup toast + iter-278
# ribbon chip both render. Output: tools/out/q1_post_pick_latest.png.
.PHONY: screenshot-q1-post-pick
screenshot-q1-post-pick:
	@mkdir -p tools/out
	@rm -f tools/out/q1_frame*.png 2>/dev/null || true
	@Q1_PICK_CARD=1 $(RENDERER) --write-movie tools/out/q1_frame.png \
		--fixed-fps 1 --quit-after 8 \
		--script res://tools/q1_screenshot.gd 2>/dev/null || true
	@latest=$$(ls -t tools/out/q1_frame*.png 2>/dev/null | head -1); \
	if [ -z "$$latest" ]; then echo "ERROR: no screenshot captured"; exit 1; fi; \
	cp "$$latest" tools/out/q1_post_pick_latest.png; \
	echo "captured: tools/out/q1_post_pick_latest.png (was $$latest)"

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

# Arc-4 breach mode: verify scripts/Bullet.gd exposes 4 distinct shell
# classes (AP/HE/HEAT/APCR) and default = AP (preserves arc-2 baseline).
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

# Arc-4 PR-#4 P0 review fix regression — depot hard-lock. Pre-fix,
# apply_choice never unpaused the tree, so every depot pick froze the
# game permanently in real-time play. This harness asserts the unpause +
# state hygiene contract.
check-breach-depot-unpause:
	@$(HEADLESS) --script res://loop/breach/test_breach_depot_unpause.gd 2>&1 | grep -E "^(  case|BREACH_DEPOT_UNPAUSE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_depot_unpause.gd 2>&1 | grep -q "^BREACH_DEPOT_UNPAUSE_OK"

# Arc-4 PR-#4 P1 review fix regression — Bullet._apply_he_blast had
# 3 converging bugs: friendly-fire player, armor-bypass on splash,
# attribution miscredit. This harness locks the fixed contract.
check-breach-he-blast-friendly-fire:
	@$(HEADLESS) --script res://loop/breach/test_breach_he_blast_friendly_fire.gd 2>&1 | grep -E "^(  case|BREACH_HE_BLAST_FRIENDLY_FIRE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_he_blast_friendly_fire.gd 2>&1 | grep -q "^BREACH_HE_BLAST_FRIENDLY_FIRE_OK"

# Arc-4 PR-#4 P1 review fix regression — MortarShell._explode used to
# AoE the firing player (sibling under Level). Locks the skip contract.
check-breach-mortar-friendly-fire:
	@$(HEADLESS) --script res://loop/breach/test_breach_mortar_friendly_fire.gd 2>&1 | grep -E "^(  case|BREACH_MORTAR_FRIENDLY_FIRE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_mortar_friendly_fire.gd 2>&1 | grep -q "^BREACH_MORTAR_FRIENDLY_FIRE_OK"

# Arc-4 PR-#4 P1 review fix regression — MOMENTUM card + RAM speed
# bonus used to compound multiplicatively-then-additively in `speed`,
# leaving permanent inflation after RAM revert. Now derived single-
# source from _base_speed + _momentum_mult + RAM additive.
check-breach-momentum-ram-compose:
	@$(HEADLESS) --script res://loop/breach/test_breach_momentum_ram_compose.gd 2>&1 | grep -E "^(  case|BREACH_MOMENTUM_RAM_COMPOSE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_momentum_ram_compose.gd 2>&1 | grep -q "^BREACH_MOMENTUM_RAM_COMPOSE_OK"

# Arc-4 PR-#4 P1 review fix regression — REAR_GUARD used to tick before
# the dead-guard, so corpses with the upgrade kept auto-firing AP.
check-breach-rear-guard-dead:
	@$(HEADLESS) --script res://loop/breach/test_breach_rear_guard_dead.gd 2>&1 | grep -E "^(  case|BREACH_REAR_GUARD_DEAD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_rear_guard_dead.gd 2>&1 | grep -q "^BREACH_REAR_GUARD_DEAD_OK"

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
	@$(HEADLESS) --script res://loop/breach/test_breach_loadout.gd 2>&1 | grep -E "^(  loadout|BREACH_LOADOUT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
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

# Arc-4 breach mode: generate + verify the 4 shell-class HUD icons via
# gen_tile.py; routes them through the silhouette-grammar gate. C7
# anchor 1.
check-breach-assets:
	python3 $(PROJECT_DIR)/tools/check_shell_icons.py

# Arc-4 breach mode: the silhouette-grammar gate itself (C7 anchor 2) —
# run tools/silhouette_gate.py directly on the generated shell icons.
# The reusable PASS/FAIL gate for CONSULT §9 constraint 4.
check-silhouette-gate:
	@for s in shell_ap shell_he shell_heat shell_apcr; do python3 $(PROJECT_DIR)/tools/gen_tile.py --tile $$s --variant 0 >/dev/null; done
	python3 $(PROJECT_DIR)/tools/silhouette_gate.py \
		$(FRAMES_DIR)/shell_ap_000.png $(FRAMES_DIR)/shell_he_000.png $(FRAMES_DIR)/shell_heat_000.png $(FRAMES_DIR)/shell_apcr_000.png

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

# Arc-4 breach mode: verify the breach-mode shell HUD — current shell
# + HE/HEAT reserve counts; arc-2/3 HUD unaffected. Round-4 legibility.
check-breach-hud:
	@$(HEADLESS) --script res://loop/breach/test_breach_hud.gd 2>&1 | grep -E "^(  (slots|selection|panel)|BREACH_HUD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_hud.gd 2>&1 | grep -q "^BREACH_HUD_OK"

# Arc-4 breach mode: Round 24 Phase A widget 2 — reload bar visualizes
# GunTimer cooldown progress with color matching current shell. Built
# only when loadout != null (procedural baseline bit-identical). iter 274.
check-breach-reload-bar:
	@$(HEADLESS) --script res://loop/breach/test_breach_reload_bar.gd 2>&1 | grep -E "^(  (procedural|case|idle|color|mid-cooldown|color follows)|BREACH_RELOAD_BAR_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_reload_bar.gd 2>&1 | grep -q "^BREACH_RELOAD_BAR_OK"

# Arc-4 breach mode: Round 24 Phase A widget 3 — speed meter top-right
# label showing current speed / BC baseline (32). Reflects RAM init,
# MOMENTUM card, and OVERDRIVE burst with color tiers. iter 275.
check-breach-speed-meter:
	@$(HEADLESS) --script res://loop/breach/test_breach_speed_meter.gd 2>&1 | grep -E "^(  (procedural|case|MOMENTUM|overdrive|high boost)|BREACH_SPEED_METER_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_speed_meter.gd 2>&1 | grep -q "^BREACH_SPEED_METER_OK"

# Arc-4 breach mode: Round 24 Phase A widget 1 v1 — shell chips compact
# top-left row (AP/HE/HEAT/APCR) with selected highlight + reserve counts.
# Procedural V1; /agentify icon swap deferred to CAPABILITY. iter 276.
check-breach-shell-chips:
	@$(HEADLESS) --script res://loop/breach/test_breach_shell_chips.gd 2>&1 | grep -E "^(  (procedural|case|reserve|selected|cycle)|BREACH_SHELL_CHIPS_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_shell_chips.gd 2>&1 | grep -q "^BREACH_SHELL_CHIPS_OK"

# Arc-4 breach mode: Round 24 Phase A widget 5 — kill-flash tints the
# enemy death-burst ColorRect by killing shell class (HE/HEAT/APCR/AP).
# Legacy / arc-2/3 path falls back to the iter-78 yellow burst. iter 277.
check-breach-kill-flash:
	@$(HEADLESS) --script res://loop/breach/test_breach_kill_flash.gd 2>&1 | grep -E "^(  (legacy|HE kill|HEAT kill|APCR kill|static)|BREACH_KILL_FLASH_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_kill_flash.gd 2>&1 | grep -q "^BREACH_KILL_FLASH_OK"

# Arc-4 breach mode: Round 24 Phase A widget 4 v1 — active cards ribbon
# bottom-left strip showing picked upgrades as category-tinted chips
# with 2-letter abbreviations. Closes Phase A. iter 278.
check-breach-active-cards-ribbon:
	@$(HEADLESS) --script res://loop/breach/test_breach_active_cards_ribbon.gd 2>&1 | grep -E "^(  (procedural|case|1 pick|3 picks|_applied)|BREACH_ACTIVE_CARDS_RIBBON_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_active_cards_ribbon.gd 2>&1 | grep -q "^BREACH_ACTIVE_CARDS_RIBBON_OK"

# Arc-4 Round 24 reframe (iter 284 per user-direction iter 283 Option B):
# Q1 breach-economy proof-room design-verification harness. Asserts the
# 4-lane shell-gated structure encoded in configs/bands/q1_proof.tres +
# loop/breach/q1_proof_layout.txt. Playable scene integration is iter 285+.
check-breach-q1-proof:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_proof.gd 2>&1 | grep -E "^(  (band|layout|gate|solvability|sentence)|BREACH_Q1_PROOF_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_proof.gd 2>&1 | grep -q "^BREACH_Q1_PROOF_OK"

# Arc-4 Q1 reframe iter 285: RunRecap route-currency metrics — data + API.
# Verifies the diagnostic half of consult-001 Q3 verdict 0.92. Per-class
# breakdown of shells_spent_on_routes vs shells_spent_on_combat. Wiring
# from Bullet/level scenes lands iter 286.
check-breach-run-recap-routes:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_routes.gd 2>&1 | grep -E "^(  (init|HE route|AP combat|accumulation|record_shot|defensive)|BREACH_RUN_RECAP_ROUTES_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_routes.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_ROUTES_OK"

# Arc-4 Q1 sprint 3/4 (iter 286): Bullet → PlayerTank → RunRecap wiring.
# Verifies record_shot_hit fires with the right kind based on body's
# is_route_gate meta; procedural baseline path is silent (no crash, no record).
check-breach-route-gate-wiring:
	@$(HEADLESS) --script res://loop/breach/test_breach_route_gate_wiring.gd 2>&1 | grep -E "^(  case|BREACH_ROUTE_GATE_WIRING_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_route_gate_wiring.gd 2>&1 | grep -q "^BREACH_ROUTE_GATE_WIRING_OK"

# Arc-4 Q1 sprint mid-correction (iter 287): Q1ProofRoom parser module.
# Verifies the embedded TILE_GRID is well-formed + lane helpers expose
# the right gate cells per lane. Scaffold for the playable scene (iter 288+).
check-breach-q1-proof-parser:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_parser.gd 2>&1 | grep -E "^(  (grid|player|gate|goal|out-of-bounds|grid_to_pixel)|BREACH_Q1_PROOF_PARSER_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_parser.gd 2>&1 | grep -q "^BREACH_Q1_PROOF_PARSER_OK"

# Arc-4 Q1 sprint 5/7 (iter 288): Q1ProofRoom.tscn playable scene.
# Verifies the scene instantiates + spawns the expected gate-row
# composition (5B / 5S / 1H / 2L) + is_route_gate meta + PlayerTank at HE start.
check-breach-q1-proof-scene:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_scene.gd 2>&1 | grep -E "^(  case|BREACH_Q1_PROOF_SCENE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_scene.gd 2>&1 | grep -q "^BREACH_Q1_PROOF_SCENE_OK"

# Arc-4 Q1 sprint 6/7 (iter 289): per-lane gate-clearance + route-currency
# playthrough harness. The CRITICAL "shells are route currency" claim at
# runtime: AP CANNOT pass steel (cross-pollination), only APCR drills it.
# Plus HE blasts brick / HEAT 2x armored Heavy / AP combat-records cleanly.
check-breach-q1-proof-playthrough:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_playthrough.gd 2>&1 | grep -E "^(  (HE lane|APCR lane|HEAT lane|AP combat)|BREACH_Q1_PROOF_PLAYTHROUGH_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_playthrough.gd 2>&1 | grep -q "^BREACH_Q1_PROOF_PLAYTHROUGH_OK"

# Arc-4 iter 291 (consult-001 Q3 verdict 0.92 — recap surfacing):
# RunRecap.route_currency_summary() format verification — compact 2-line
# "ROUTE: ... \n COMBAT: ..." for the death overlay. Zero entries dropped.
check-breach-route-currency-summary:
	@$(HEADLESS) --script res://loop/breach/test_breach_route_currency_summary.gd 2>&1 | grep -E "^(  (empty|1 HE|1 AP|HE route|2HE|worst case|    sample)|BREACH_ROUTE_CURRENCY_SUMMARY_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_route_currency_summary.gd 2>&1 | grep -q "^BREACH_ROUTE_CURRENCY_SUMMARY_OK"

# Arc-4 iter 294 (consult-001 H6 conf 0.81 — visibility classes):
# Pressure-fade for run-context HUD strips (active-cards ribbon +
# route panel). FADE_ALPHA during HIGH_PRESSURE_WINDOW seconds after
# firing; FULL_ALPHA otherwise. Combat-critical widgets stay full.
check-breach-h6-pressure-fade:
	@$(HEADLESS) --script res://loop/breach/test_breach_h6_pressure_fade.gd 2>&1 | grep -E "^(  case|BREACH_H6_PRESSURE_FADE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_h6_pressure_fade.gd 2>&1 | grep -q "^BREACH_H6_PRESSURE_FADE_OK"

# Arc-4 iter 296 (playtest-fix end-to-end): drives the full input →
# PlayerTank._fire() → shoot signal → handler → Bullet instantiated
# → bullet collides → body damaged + route-currency ticks path.
# Exists because iter 289's "playthrough" harness skipped the
# shoot-signal wiring and the scene shipped without it.
check-breach-q1-proof-fire-e2e:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_fire_end_to_end.gd 2>&1 | grep -E "^(  case|BREACH_Q1_PROOF_FIRE_E2E_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_proof_fire_end_to_end.gd 2>&1 | grep -q "^BREACH_Q1_PROOF_FIRE_E2E_OK"

# Arc-4 iter 298 (z-index audit per user feedback #2): verifies the
# HUD z-stack contract — constants ordered, panels carry the right
# z_index, popups + toasts respect the hierarchy.
check-breach-hud-z-stack:
	@$(HEADLESS) --script res://loop/breach/test_breach_hud_z_stack.gd 2>&1 | grep -E "^(  (constants|built|lazy|pickup)|BREACH_HUD_Z_STACK_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_hud_z_stack.gd 2>&1 | grep -q "^BREACH_HUD_Z_STACK_OK"

# Arc-4 iter 302 (consult-001 H5 sub-recommendation): verifies that
# picking an upgrade card spawns a transient toast with the FULL
# UpgradeCatalog label + sentence-test description, so the ribbon's
# 2-letter token functions as a reminder not the first explanation.
check-breach-card-pickup-toast:
	@$(HEADLESS) --script res://loop/breach/test_breach_card_pickup_toast.gd 2>&1 | grep -E "^(  case|BREACH_CARD_PICKUP_TOAST_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_card_pickup_toast.gd 2>&1 | grep -q "^BREACH_CARD_PICKUP_TOAST_OK"

# Arc-4 iter 303 (e2e card-flow integration test, parallel to iter-296
# fire e2e): drives the FULL pick path — _show_levelup_pick → _pick_
# levelup_card → _apply_card → toast + ribbon + match-arm effect.
check-breach-card-pick-e2e:
	@$(HEADLESS) --script res://loop/breach/test_breach_card_pick_end_to_end.gd 2>&1 | grep -E "^(  case|BREACH_CARD_PICK_E2E_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_card_pick_end_to_end.gd 2>&1 | grep -q "^BREACH_CARD_PICK_E2E_OK"

# Arc-4 iter 307 (Round 25 Probe 1): bot-driven Q1 proof room run with 3
# fixed shell-selection policies. Calibration data — does the proof room
# meaningfully differentiate policies via shells_spent_on_routes?
check-breach-q1-bot-run:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_bot_run.gd 2>&1 | grep -E "^(  case|BREACH_Q1_BOT_RUN_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_bot_run.gd 2>&1 | grep -q "^BREACH_Q1_BOT_RUN_OK"

# Run the bot driver itself + commit per-policy JSON to tools/out/.
# Used by Probe 1 report generation; NOT part of test-breach aggregate.
q1-bot-run:
	@$(HEADLESS) --script res://tools/q1_bot_run.gd

# Arc-4 iter 308 (Round 25 Probe 2): shell × target pressure matrix
# locks in the canonical per-cell mechanics (armor mitigation, HEAT 2x,
# APCR drill, AP-bounces-steel, HE-per-cell-equals-AP).
check-breach-shell-pressure-matrix:
	@$(HEADLESS) --script res://loop/breach/test_breach_shell_pressure_matrix.gd 2>&1 | grep -E "^(  case|BREACH_SHELL_PRESSURE_MATRIX_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_shell_pressure_matrix.gd 2>&1 | grep -q "^BREACH_SHELL_PRESSURE_MATRIX_OK"

# Run the Probe 2 matrix driver itself + write tools/out/shell_pressure_matrix.json.
# Used by Probe 2 report generation; NOT part of test-breach aggregate.
shell-pressure-matrix:
	@$(HEADLESS) --script res://tools/shell_pressure_matrix.gd

# Arc-4 iter 309 (Round 25 Probe 3): HUD coverage math + label-size audit.
# Enforces PROMPT § blueprint "HUD area ≤ 25% of viewport" + iter-299
# typography floor (≥8pt for HUD labels).
check-breach-hud-coverage:
	@$(HEADLESS) --script res://loop/breach/test_breach_hud_coverage.gd 2>&1 | grep -E "^(  case|BREACH_HUD_COVERAGE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_hud_coverage.gd 2>&1 | grep -q "^BREACH_HUD_COVERAGE_OK"

# Arc-4 iter 313 (Round 26 Phase A — visual identity sprint): BrickBlock
# variant_texture override capability. Default null → arc-2/3 baseline
# preserved (sprites_1.png frame 5); override set → standalone 8×8 tile.
check-breach-brick-variant:
	@$(HEADLESS) --script res://loop/breach/test_breach_brick_variant.gd 2>&1 | grep -E "^(  case|BREACH_BRICK_VARIANT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_brick_variant.gd 2>&1 | grep -q "^BREACH_BRICK_VARIANT_OK"

# Arc-4 iter 315 (Round 26 Phase B — activation): BrickBlock self-
# discovers player.loadout.brick_variant via group lookup + post-pass.
# 4 cases: no-player baseline + null-variant baseline + self-discovery
# + Q1ProofRoom end-to-end variant rendering.
check-breach-brick-variant-activation:
	@$(HEADLESS) --script res://loop/breach/test_breach_brick_variant_activation.gd 2>&1 | grep -E "^(  case|BREACH_BRICK_VARIANT_ACTIVATION_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_brick_variant_activation.gd 2>&1 | grep -q "^BREACH_BRICK_VARIANT_ACTIVATION_OK"

# Arc-4 iter 318 (Round 27 Probe 5): Q1 replay capture — event-indexed
# timeseries of synthetic-fire dominant_per_lane bot run. Verifies
# driver constants + structural invariants + HE radius temporal evidence.
check-breach-q1-replay-capture:
	@$(HEADLESS) --script res://loop/breach/test_breach_q1_replay_capture.gd 2>&1 | grep -E "^(  case|BREACH_Q1_REPLAY_CAPTURE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_q1_replay_capture.gd 2>&1 | grep -q "^BREACH_Q1_REPLAY_CAPTURE_OK"

# Run the replay capture driver itself + write tools/out/q1_replay_*.json.
# Used by Probe 5 report generation; NOT part of test-breach aggregate.
q1-replay-capture:
	@$(HEADLESS) --script res://tools/q1_replay_capture.gd

# Arc-4 breach mode: verify the APCR 4th shell — breaches SteelBlock
# terrain (AP/HE/HEAT cannot), pierces armor at 1x, finite reserve.
# Round 5 (iter 34); user override of CONSULT constraint 2.
check-breach-apcr:
	@$(HEADLESS) --script res://loop/breach/test_breach_apcr.gd 2>&1 | grep -E "^(  (APCR|AP|HE|HEAT|loadout)|BREACH_APCR_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_apcr.gd 2>&1 | grep -q "^BREACH_APCR_OK"

# Arc-4 breach mode: verify the shell codex — a run-start primer naming
# all 4 shells + their BRICK/STEEL terrain roles; dismissable. Round 5
# (iter 36) — answers playtest findings 2-3 (no tutorial; illegible).
check-breach-codex:
	@$(HEADLESS) --script res://loop/breach/test_breach_codex.gd 2>&1 | grep -E "^(  (codex|_dismiss)|BREACH_CODEX_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_codex.gd 2>&1 | grep -q "^BREACH_CODEX_OK"

# Arc-4 breach mode: verify per-run band-order shuffle (Round 6a) —
# 5 bands, tutorial+endgame pinned, the 3 middle bands permute into
# fixed reachability-safe slots; >=2 distinct orders; source unmutated.
check-breach-shuffle:
	@$(HEADLESS) --script res://loop/breach/test_breach_shuffle.gd 2>&1 | grep -E "^(  (distinct|source)|BREACH_SHUFFLE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_shuffle.gd 2>&1 | grep -q "^BREACH_SHUFFLE_OK"

# Arc-4 breach mode: verify depot-offer randomization (Round 6b) —
# randomize_offers depots draw 3 distinct upgrade kinds per run with
# >=2 distinct sets across seeds; the fixed-choice default is preserved.
check-breach-depot-roll:
	@$(HEADLESS) --script res://loop/breach/test_breach_depot_roll.gd 2>&1 | grep -E "^(  (randomize|[0-9])|BREACH_DEPOT_ROLL_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_depot_roll.gd 2>&1 | grep -q "^BREACH_DEPOT_ROLL_OK"

# Arc-4 breach mode: verify the Round 6c depot rule-changers — QUICK_SWAP
# (shell swaps cost no reload beat) + STEEL_SALVAGE (APCR steel-cluster
# breach refunds APCR). Both via the depot apply_upgrade catalog.
check-breach-rulechangers:
	@$(HEADLESS) --script res://loop/breach/test_breach_rulechangers.gd 2>&1 | grep -E "^(  (QUICK|control|salvage|apply)|BREACH_RULECHANGERS_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_rulechangers.gd 2>&1 | grep -q "^BREACH_RULECHANGERS_OK"

# Arc-4 breach mode: verify Round 6d stakes & escalation — a breach
# PlayerTank surfaces a live best-depth readout + a band-arrival banner;
# arc-2/3 build neither.
check-breach-stakes:
	@$(HEADLESS) --script res://loop/breach/test_breach_stakes.gd 2>&1 | grep -E "^(  (BestLabel|band)|BREACH_STAKES_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_stakes.gd 2>&1 | grep -q "^BREACH_STAKES_OK"

# Arc-4 breach mode: verify Round 6e meta-progression — MetaProgress
# unlock predicates gate at depth 40/80; the depot offer pool widens
# 7→8→9 with best-depth (options earned by climbing, not power).
check-breach-meta:
	@$(HEADLESS) --script res://loop/breach/test_breach_meta.gd 2>&1 | grep -E "^(  (unlock|depot|P2-)|BREACH_META_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_meta.gd 2>&1 | grep -q "^BREACH_META_OK"

# Arc-4 breach mode: verify Round 7c run-route legibility — a breach
# PlayerTank surfaces a persistent route strip naming the run's shuffled
# band order, the highlight tracks crossings; arc-2/3 build none.
check-breach-route:
	@$(HEADLESS) --script res://loop/breach/test_breach_route.gd 2>&1 | grep -E "^(  (route|cell|highlight)|BREACH_ROUTE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_route.gd 2>&1 | grep -q "^BREACH_ROUTE_OK"

# Arc-4 breach mode: verify Round 8a XP + level-up core — a breach
# PlayerTank earns XP, levels up, and each level-up applies a rotated
# automatic stat boost (HP / reload / shell capacity); arc-2/3 build none.
check-breach-xp:
	@$(HEADLESS) --script res://loop/breach/test_breach_xp.gd 2>&1 | grep -E "^(  (XP|level)|BREACH_XP_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_xp.gd 2>&1 | grep -q "^BREACH_XP_OK"

# Arc-4 breach mode: verify Round 8c enemy ammo drops — an AmmoPickup
# picks a droppable shell + the player collects it to the loadout
# reserve; arc-2/3 bodies do not collect.
check-breach-ammo:
	@$(HEADLESS) --script res://loop/breach/test_breach_ammo.gd 2>&1 | grep -E "^(  (pickup|collected|no-loadout)|BREACH_AMMO_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_ammo.gd 2>&1 | grep -q "^BREACH_AMMO_OK"

# Arc-4 breach mode: verify Round 8d longer shields — a breach
# PlayerTank's apply_shield extends to BREACH_SHIELD_DURATION + a HUD
# indicator shows while shielded; arc-2/3 keeps the passed duration.
check-breach-shield:
	@$(HEADLESS) --script res://loop/breach/test_breach_shield.gd 2>&1 | grep -E "^(  (breach|shield|arc-2)|BREACH_SHIELD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_shield.gd 2>&1 | grep -q "^BREACH_SHIELD_OK"

# Arc-4 breach mode: verify Round 9a enemy HP primitive + HP bars —
# a breach-mode Enemy with max_hp > 1 builds a visible HP bar that
# tracks damage; arc-2/3 enemies build none.
check-breach-hp:
	@$(HEADLESS) --script res://loop/breach/test_breach_hp.gd 2>&1 | grep -E "^(  (HP|arc-2|max_hp)|BREACH_HP_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_hp.gd 2>&1 | grep -q "^BREACH_HP_OK"

# Arc-4 breach mode: verify Round 9b archetype framework — the
# TankArchetype enum + @export state field; DEFAULT preserves the
# existing breach behavior bit-identically.
check-breach-archetype:
	@$(HEADLESS) --script res://loop/breach/test_breach_archetype.gd 2>&1 | grep -E "^(  (TankArchetype|default|archetype)|BREACH_ARCHETYPE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_archetype.gd 2>&1 | grep -q "^BREACH_ARCHETYPE_OK"

# Arc-4 breach mode: verify Round 9c PRISM Tank — archetype=PRISM
# builds the BeamLine; _apply_beam_to_body applies the per-body-type
# damage rule (brick burns fast, enemy on cooldown, steel blocks).
check-breach-prism:
	@$(HEADLESS) --script res://loop/breach/test_breach_prism.gd 2>&1 | grep -E "^(  (PRISM|DEFAULT|brick|enemy|steel)|BREACH_PRISM_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_prism.gd 2>&1 | grep -q "^BREACH_PRISM_OK"

# Arc-4 breach mode: verify Round 9d MORTAR Tank — archetype=MORTAR
# slows GunTimer + _fire_mortar spawns a MortarShell + the shell's AoE
# damages in-radius siblings and spares out-of-radius.
check-breach-mortar:
	@$(HEADLESS) --script res://loop/breach/test_breach_mortar.gd 2>&1 | grep -E "^(  (MORTAR|_fire|AoE)|BREACH_MORTAR_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_mortar.gd 2>&1 | grep -q "^BREACH_MORTAR_OK"

# Arc-4 breach mode: verify Round 9e RAM Tank — archetype=RAM gets a
# speed bonus + _ram_swing damages forward-in-range siblings, spares
# behind and far.
check-breach-ram:
	@$(HEADLESS) --script res://loop/breach/test_breach_ram.gd 2>&1 | grep -E "^(  (RAM|swing)|BREACH_RAM_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_ram.gd 2>&1 | grep -q "^BREACH_RAM_OK"

# Arc-4 breach mode: verify Round 9f archetype start-pick — Meta unlock
# tiers, _show_archetype_select builds the panel + arms the flag,
# _pick_archetype sets state + fires per-archetype init.
check-breach-archetype-select:
	@$(HEADLESS) --script res://loop/breach/test_breach_archetype_select.gd 2>&1 | grep -E "^(  (unlock|_show|_pick|force)|BREACH_ARCHETYPE_SELECT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_archetype_select.gd 2>&1 | grep -q "^BREACH_ARCHETYPE_SELECT_OK"

# Arc-4 breach mode: verify Round 9g mid-run archetype switching —
# 3 new SWITCH_TO_* UpgradeKinds gated by MetaProgress tiers; depot
# apply_upgrade calls PlayerTank.switch_archetype; multi-switch keeps
# speed clean.
check-breach-archetype-switch:
	@$(HEADLESS) --script res://loop/breach/test_breach_archetype_switch.gd 2>&1 | grep -E "^(  (UpgradeKind|switch|apply|multi-switch|S[123])|BREACH_ARCHETYPE_SWITCH_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_archetype_switch.gd 2>&1 | grep -q "^BREACH_ARCHETYPE_SWITCH_OK"

# Arc-4 breach mode: iter 146 (Pro Consult 011 step 4/5) — verifies
# PlayerTank archetype → sprite-atlas swap; loadout-gated so arc-2/3
# keep sprites_0.png + vframes=18 bit-identically.
check-breach-archetype-sprite:
	@$(HEADLESS) --script res://loop/breach/test_breach_archetype_sprite.gd 2>&1 | grep -E "^(  (arc-2/3|DEFAULT|PRISM|MORTAR|RAM|switch|chain)|BREACH_ARCHETYPE_SPRITE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_archetype_sprite.gd 2>&1 | grep -q "^BREACH_ARCHETYPE_SPRITE_OK"

# Arc-4 breach mode: iter 195 — MORTAR charge-lob mechanic
# (tap = short range, hold = up to MORTAR_RANGE_MAX; reticle glides).
check-breach-mortar-charge:
	@$(HEADLESS) --script res://loop/breach/test_breach_mortar_charge.gd 2>&1 | grep -E "^(  (tap|full|mid|reticle)|BREACH_MORTAR_CHARGE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_mortar_charge.gd 2>&1 | grep -q "^BREACH_MORTAR_CHARGE_OK"

# Arc-4 breach mode: iter 197 — UpgradeCatalog data module (Round 23
# Phase 1: pool sizes + pool_for + fallback + metadata coverage).
check-breach-upgrade-catalog:
	@$(HEADLESS) --script res://loop/breach/test_breach_upgrade_catalog.gd 2>&1 | grep -E "^(  (pools|pool_for|metadata)|BREACH_UPGRADE_CATALOG_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_upgrade_catalog.gd 2>&1 | grep -q "^BREACH_UPGRADE_CATALOG_OK"

# Arc-4 breach mode: iter 198 — pick-1-of-3 card UI (Round 23 Phase 2:
# panel + card-pool gating + HP+1/HP+2 apply paths + arc-2/3 skip).
check-breach-levelup-pick:
	@$(HEADLESS) --script res://loop/breach/test_breach_levelup_pick.gd 2>&1 | grep -E "^(  (DEFAULT|pick|HP_PLUS|arc-2|PRISM)|BREACH_LEVELUP_PICK_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_levelup_pick.gd 2>&1 | grep -q "^BREACH_LEVELUP_PICK_OK"

# Arc-4 breach mode: iter 199 — Round 23 Phase 3 card apply branches
# (PRISM: BEAM_DPS/RANGE/PIERCE; MORTAR: AOE_DAMAGE/RADIUS, COOLDOWN).
check-breach-card-apply-p3:
	@$(HEADLESS) --script res://loop/breach/test_breach_card_apply_p3.gd 2>&1 | grep -E "^(  (BEAM_|AOE_|MORTAR_)|BREACH_CARD_APPLY_P3_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_card_apply_p3.gd 2>&1 | grep -q "^BREACH_CARD_APPLY_P3_OK"

# Arc-4 breach mode: iter 200 — Round 23 Phase 4 card apply branches
# (RAM: SWING/COLLISION/SPRINT; DEFAULT: RELOAD/SHELLS/MOMENTUM) +
# level-up wiring feature flag (default off preserves test compat).
check-breach-card-apply-p4:
	@$(HEADLESS) --script res://loop/breach/test_breach_card_apply_p4.gd 2>&1 | grep -E "^(  (SWING_|COLLISION_|SPRINT_|FASTER_|SHELL_|MOMENTUM|level-up)|BREACH_CARD_APPLY_P4_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_card_apply_p4.gd 2>&1 | grep -q "^BREACH_CARD_APPLY_P4_OK"

# Arc-4 breach mode: iter 156 (CAPABILITY) — wire the iter-144
# silhouette/readability gate into the test pipeline. Catches any
# regression on the procedural archetype sprite atlas (palette codes,
# fill ratio, front-half accent, motif-region pairwise distinctness).
check-archetype-sprite-silhouettes:
	@python3 $(PROJECT_DIR)/tools/gen_archetype_sprites.py --check

# Arc-4 breach mode: Round-10 Phase-1 distinctness-audit harness.
# Per Consult 008's H4 reframe — "experientially homogeneous despite
# mechanically distinct" is structurally detectable. Phase-1 compares
# per-archetype STRUCTURAL signal vectors (6 axes); FAILS with a
# convergence warning if any pair shares more than 3 of 6 signals.
check-breach-distinctness-audit:
	@$(HEADLESS) --script res://loop/breach/test_breach_distinctness_audit.gd 2>&1 | grep -E "^(  (DEFAULT|PRISM|MORTAR|RAM|min|max|NOTE|CALIBRATION)|  [A-Z]+↔[A-Z]+|BREACH_DISTINCTNESS_AUDIT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_distinctness_audit.gd 2>&1 | grep -q "^BREACH_DISTINCTNESS_AUDIT_OK"

# Arc-4 breach mode: Round-10 Phase-2 pressure-probe harness. Empirically
# verifies the PRESSURES.md matrix's most uncertain claim: per-archetype
# armor-bypass asymmetry. DEFAULT respects armor via shell class
# (Bullet.gd); PRISM/MORTAR/RAM bypass by mechanism (no armor check in
# their damage paths).
check-breach-pressure-probes:
	@$(HEADLESS) --script res://loop/breach/test_breach_pressure_probes.gd 2>&1 | grep -E "^(  (DEFAULT|PRISM|MORTAR|RAM)|BREACH_PRESSURE_PROBES_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_pressure_probes.gd 2>&1 | grep -q "^BREACH_PRESSURE_PROBES_OK"

# Arc-4 breach mode: Round-11 Phase-1 band-shape recorder verifier
# (iter 82). Verifies the RunRecap extension that captures per-band
# visit telemetry for CONSULT-009 band-shape post-hoc analysis.
check-breach-band-shape:
	@$(HEADLESS) --script res://loop/breach/test_breach_band_shape.gd 2>&1 | grep -E "^(  (schema|enter_band|4-band|re-entry|band_signature|format|empty-log)|BREACH_BAND_SHAPE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_band_shape.gd 2>&1 | grep -q "^BREACH_BAND_SHAPE_OK"

# Arc-4 breach mode: Round-11 Phase-1 band-shape ANALYZER verifier
# (iter 83). Verifies RunRecapAnalyzer.compare_signatures pairwise
# sequence/time distance logic across mock signatures.
check-breach-band-shape-analyzer:
	@$(HEADLESS) --script res://loop/breach/test_breach_band_shape_analyzer.gd 2>&1 | grep -E "^(  (identical|reorder|different|4-archetype|verdict|all-divergent)|BREACH_BAND_SHAPE_ANALYZER_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_band_shape_analyzer.gd 2>&1 | grep -q "^BREACH_BAND_SHAPE_ANALYZER_OK"

# Arc-4 breach mode: Enemy double-kill idempotency regression (P1-1
# from code-review-iter-090.md, fixed iter 090). Without the
# `if hp <= 0: return` guard at the top of take_damage, same-frame
# second damage sources (MORTAR AoE + RAM swing + beam tick) double-
# emit killed and corrupt downstream counts.
check-breach-double-kill:
	@$(HEADLESS) --script res://loop/breach/test_breach_double_kill.gd 2>&1 | grep -E "^(  (first|second|triple|enemy)|BREACH_DOUBLE_KILL_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_double_kill.gd 2>&1 | grep -q "^BREACH_DOUBLE_KILL_OK"

# Arc-4 breach mode: P0-1 regression — archetype-select must pause
# the world (iter 091). Without the pause, enemies spawn/shoot at
# the stationary player while they read the pick screen.
check-breach-archetype-select-pause:
	@$(HEADLESS) --script res://loop/breach/test_breach_archetype_select_pause.gd 2>&1 | grep -E "^(  (tree|PlayerTank|stub|_pick_archetype|dead-during)|BREACH_ARCHETYPE_SELECT_PAUSE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_archetype_select_pause.gd 2>&1 | grep -q "^BREACH_ARCHETYPE_SELECT_PAUSE_OK"

# Arc-4 breach mode: P0-2 regression — FASTER_RELOAD XP bonus must
# survive archetype switches (iter 092). Cumulative _reload_reduction
# tracks the XP-earned reduction; archetype-specific wait_time =
# archetype_base − reduction (floored at RELOAD_MIN).
check-breach-xp-reload-persistence:
	@$(HEADLESS) --script res://loop/breach/test_breach_xp_reload_persistence.gd 2>&1 | grep -E "^(  (base|DEFAULT|after|switch|2nd)|BREACH_XP_RELOAD_PERSISTENCE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_xp_reload_persistence.gd 2>&1 | grep -q "^BREACH_XP_RELOAD_PERSISTENCE_OK"

# Arc-4 breach mode: P1-3 + P1-5 regression — switch_archetype
# value validation + Depot._player is_instance_valid guard
# (iter 093). switch_archetype(99) used to silently put the tank
# in undefined state; Depot apply_upgrade used to crash on freed
# _player.
check-breach-switch-archetype-validation:
	@$(HEADLESS) --script res://loop/breach/test_breach_switch_archetype_validation.gd 2>&1 | grep -E "^(  (switch|depot)|BREACH_SWITCH_ARCHETYPE_VALIDATION_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_switch_archetype_validation.gd 2>&1 | grep -q "^BREACH_SWITCH_ARCHETYPE_VALIDATION_OK"

# Arc-4 breach mode: P1-2 + P1-6 regression — _pick_archetype now
# routes through switch_archetype (reverts old archetype mods),
# and MortarShell._explode guards against freed parents (iter 094).
check-breach-pick-archetype-and-mortar-guard:
	@$(HEADLESS) --script res://loop/breach/test_breach_pick_archetype_and_mortar_guard.gd 2>&1 | grep -E "^(  (RAM|_pick_archetype|MortarShell|no)|BREACH_PICK_ARCHETYPE_AND_MORTAR_GUARD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_pick_archetype_and_mortar_guard.gd 2>&1 | grep -q "^BREACH_PICK_ARCHETYPE_AND_MORTAR_GUARD_OK"

# Arc-4 breach mode: P1-4 regression — RunRecap.archetype must
# reflect the RUN-START archetype, not the latest switch (iter
# 095). Before fix: _on_breach_band_changed reassigned archetype
# on every crossing, polluting cross-archetype distinctness
# analysis.
check-breach-run-recap-archetype-contract:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_archetype_contract.gd 2>&1 | grep -E "^(  (fresh|after|_pick_archetype|switch_archetype)|BREACH_RUN_RECAP_ARCHETYPE_CONTRACT_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_archetype_contract.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_ARCHETYPE_CONTRACT_OK"

# Arc-4 breach mode: P2 sweep batch 1 — P2-1 + P2-3 + P2-8 paired
# (iter 096). Analyzer "insufficient_data" verdict + MORTAR init
# hygiene + MortarShell t clamp.
check-breach-p2-batch1:
	@$(HEADLESS) --script res://loop/breach/test_breach_p2_batch1.gd 2>&1 | grep -E "^(  (P2-)|BREACH_P2_BATCH1_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_p2_batch1.gd 2>&1 | grep -q "^BREACH_P2_BATCH1_OK"

# Arc-4 breach mode: P2 sweep batch 2 — P2-4 + P2-6 paired (iter 097).
# Death overlay no longer leaves PRISM beam drawn; Depot pool no
# longer offers no-op same-archetype SWITCH_TO_*.
check-breach-p2-batch2:
	@$(HEADLESS) --script res://loop/breach/test_breach_p2_batch2.gd 2>&1 | grep -E "^(  (P2-)|BREACH_P2_BATCH2_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_p2_batch2.gd 2>&1 | grep -q "^BREACH_P2_BATCH2_OK"

# Arc-4 breach mode: P2 sweep batch 3 — P2-7 + P2-9 + P2-5 paired
# (iter 098). Universal beam cooldown + archetype ladder + HEAT/Heavy
# doc clarification.
check-breach-p2-batch3:
	@$(HEADLESS) --script res://loop/breach/test_breach_p2_batch3.gd 2>&1 | grep -E "^(  (P2-)|BREACH_P2_BATCH3_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_p2_batch3.gd 2>&1 | grep -q "^BREACH_P2_BATCH3_OK"

# Arc-4 breach mode: P0-A regression — Depot re-entry must NOT
# allow a second pick from the same depot (iter 100). Without this,
# player can unboundedly pick HE_REFILL_2 / HE_MAX_EXPAND_2 /
# FULL_RESUPPLY by exiting + re-entering the depot.
check-breach-depot-lifetime-pick:
	@$(HEADLESS) --script res://loop/breach/test_breach_depot_lifetime_pick.gd 2>&1 | grep -E "^(  (first|apply_choice|re-enter|2nd)|BREACH_DEPOT_LIFETIME_PICK_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_depot_lifetime_pick.gd 2>&1 | grep -q "^BREACH_DEPOT_LIFETIME_PICK_OK"

# Arc-4 breach mode: P1-A regression — APCR Steel Salvage threshold
# must use `>=` + once-per-shot latch (iter 101, code-review-iter-100).
# Without this, a frame-skip increment past THRESHOLD would skip the
# refund (old `==` bug); a 6-block drill would double-refund (no latch);
# inert steel without breach() would falsely tick the counter.
check-breach-steel-salvage-threshold:
	@$(HEADLESS) --script res://loop/breach/test_breach_steel_salvage_threshold.gd 2>&1 | grep -E "^(  (baseline|overshoot|latch|inert-guard)|BREACH_STEEL_SALVAGE_THRESHOLD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_steel_salvage_threshold.gd 2>&1 | grep -q "^BREACH_STEEL_SALVAGE_THRESHOLD_OK"

# Arc-4 breach mode: P1-C regression — BandBanner Labels must NOT
# stack on Y-boundary oscillation (iter 102, code-review-iter-100).
# Without _band_banner tracking + cleanup, each band crossing leaks
# a Label on the HUD layer until its 2.2s tween chain completes.
check-breach-band-banner-stacking:
	@$(HEADLESS) --script res://loop/breach/test_breach_band_banner_stacking.gd 2>&1 | grep -E "^(  (after|surviving)|BREACH_BAND_BANNER_STACKING_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_band_banner_stacking.gd 2>&1 | grep -q "^BREACH_BAND_BANNER_STACKING_OK"

# Arc-4 breach mode: P1-D regression — fire-while-swap rejection
# must produce a visible UX cue (iter 102, code-review-iter-100).
# Verifies _fire() rejected by _swap_cooldown > 0 flashes the
# shell-panel BG warm-orange, while preserving the iter-27 swap-
# cost behavior (no shell consumed, no GunTimer armed).
check-breach-fire-while-swap:
	@$(HEADLESS) --script res://loop/breach/test_breach_fire_while_swap.gd 2>&1 | grep -E "^(  (initial|after|rejected|panel|control|.skipping))|BREACH_FIRE_WHILE_SWAP_OK|FAIL|ERROR|SCRIPT ERROR"; \
	$(HEADLESS) --script res://loop/breach/test_breach_fire_while_swap.gd 2>&1 | grep -q "^BREACH_FIRE_WHILE_SWAP_OK"

# Arc-4 breach mode: P1-E + P1-F regression — _apply_level_boost
# must clamp max_hp / max_*_reserve at ceilings (iter 103,
# code-review-iter-100). Without this, long runs inflate stats
# unboundedly — passive-stat-soup drift (CONSULT constraint 7).
check-breach-level-up-ceilings:
	@$(HEADLESS) --script res://loop/breach/test_breach_level_up_ceilings.gd 2>&1 | grep -E "^(  (max_|at-cap)|BREACH_LEVEL_UP_CEILINGS_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_level_up_ceilings.gd 2>&1 | grep -q "^BREACH_LEVEL_UP_CEILINGS_OK"

# Arc-4 breach mode: P2-A regression — AmmoPickup must NOT silently
# no-op when chosen shell is at cap (iter 103, code-review-iter-100).
# Re-rolls to an under-cap shell at collect time; if all at cap,
# silently consumes (honest "you're topped" signal).
check-breach-ammo-pickup-no-waste:
	@$(HEADLESS) --script res://loop/breach/test_breach_ammo_pickup_no_waste.gd 2>&1 | grep -E "^(  (HE-|all-)|BREACH_AMMO_PICKUP_NO_WASTE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_ammo_pickup_no_waste.gd 2>&1 | grep -q "^BREACH_AMMO_PICKUP_NO_WASTE_OK"

# Arc-4 breach mode: P2-B regression — _show_pickup_toast must
# stagger Y so multi-level-up bursts don't pile toasts at the same
# position (iter 104, code-review-iter-100). Tagged toasts + live-
# count formula; cap at TOAST_STAGGER_MAX so they don't push off HUD.
check-breach-toast-stagger:
	@$(HEADLESS) --script res://loop/breach/test_breach_toast_stagger.gd 2>&1 | grep -E "^(  (3 rapid|Y diffs|after)|BREACH_TOAST_STAGGER_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_toast_stagger.gd 2>&1 | grep -q "^BREACH_TOAST_STAGGER_OK"

# Arc-4 breach mode: P2-C regression — route-strip cleared tint
# must survive non-monotonic Y motion (iter 104, code-review-iter-100).
# _route_max_cleared_idx tracks the high-water idx; retreats don't
# revoke the cleared tint on cells already visited.
check-breach-route-strip-max-cleared:
	@$(HEADLESS) --script res://loop/breach/test_breach_route_strip_max_cleared.gd 2>&1 | grep -E "^(  (climb|retreat)|BREACH_ROUTE_STRIP_MAX_CLEARED_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_route_strip_max_cleared.gd 2>&1 | grep -q "^BREACH_ROUTE_STRIP_MAX_CLEARED_OK"

# Arc-4 breach mode: Round 12 Phase 2 — RunRecap.verdict_sentence
# (iter 108, γ shape from iter-107 SPIKE). One-sentence verdict
# replaces the arc-2 ASCENDER stat block on death; surfaces the
# killing band's canonical_answer as a diagnosis. Lifts C9 from
# 2/5 → 3/5.
check-breach-run-recap-verdict-sentence:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_verdict_sentence.gd 2>&1 | grep -E "^(  (standard|comfortable|missing|long|em-dash|meta)|BREACH_RUN_RECAP_VERDICT_SENTENCE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_verdict_sentence.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_VERDICT_SENTENCE_OK"

# Arc-4 breach mode: Round 12 Phase 3 — RunRecap.killer must
# reflect actual damage source, not "shell impact" placeholder
# (iter 109, Gap 2 from iter-106 diagnosis). Bullet.source_label
# set by Enemy._fire; PlayerTank.set_last_damage_source stores it;
# _die stamps it into run_recap.killer. Lifts C9 from 3/5 → 4/5.
check-breach-run-recap-killer:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_killer.gd 2>&1 | grep -E "^(  (light|heavy|legacy)|BREACH_RUN_RECAP_KILLER_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_killer.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_KILLER_OK"

# Arc-4 breach mode: Round 12 Phase 4 — RunRecap.resource_sentence
# (iter 110, Gap 3 from iter-106 diagnosis). The verdict now names
# the dry-vs-canonical relationship as a learning-moment clause:
# "Dry on HE — the band's canonical answer" (match) OR "Dry on HE;
# band wanted APCR" (mismatch). Word-boundary regex prevents "AP"
# matching "APCR" or "HE" matching "HEAT". Lifts C9 from 4/5 → 5/5
# effective (absolute 5/5 still gated on playtest cite per R3).
check-breach-run-recap-resource-sentence:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_resource_sentence.gd 2>&1 | grep -E "^(  (match|mismatch|comfortable|no-canonical|word-boundary)|BREACH_RUN_RECAP_RESOURCE_SENTENCE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_resource_sentence.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_RESOURCE_SENTENCE_OK"

# Arc-4 breach mode: Round 13 Phase 2 — SCOUT_TELEGRAPH upgrade
# (iter 113, closes C8 anchor 3's tutorial_choke band-coverage gap
# from iter-112 audit). Verifies Loadout flag + Depot enum/label/
# pool/apply + Enemy tint override + baseline regression.
check-breach-scout-telegraph:
	@$(HEADLESS) --script res://loop/breach/test_breach_scout_telegraph.gd 2>&1 | grep -E "^(  (Loadout|apply_upgrade|SCOUT|enemy)|BREACH_SCOUT_TELEGRAPH_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_scout_telegraph.gd 2>&1 | grep -q "^BREACH_SCOUT_TELEGRAPH_OK"

# Arc-4 breach mode: Round 14 Phase 2 — REAR_GUARD upgrade
# (iter 116, closes open_killbox C8 anchor-3 gap deferred from
# Round 13). Auto-fires AP at rear-cone enemies; 90° cone within
# REAR_GUARD_RANGE; cooldown REAR_GUARD_COOLDOWN.
check-breach-rear-guard:
	@$(HEADLESS) --script res://loop/breach/test_breach_rear_guard.gd 2>&1 | grep -E "^(  (Loadout|apply_upgrade|rear-cone|front-only|far enemy|_fire_rear_guard)|BREACH_REAR_GUARD_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_rear_guard.gd 2>&1 | grep -q "^BREACH_REAR_GUARD_OK"

# Arc-4 breach mode: Round 16 BUILD-QUALITY — RunRecap.route_
# diff_clause (iter 121, Gap 4 from iter-106 diagnosis). Names
# the path-not-taken in the post-death breach-prompt label.
check-breach-run-recap-route-diff:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_route_diff.gd 2>&1 | grep -E "^(  (partial|full|empty|out-of-order)|BREACH_RUN_RECAP_ROUTE_DIFF_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_route_diff.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_ROUTE_DIFF_OK"

# Arc-4 breach mode: Round 17 BUILD-QUALITY — RunRecap.regret_
# quote_candidate (iter 123, Gap 5 from iter-106 — LAST iter-106
# backlog item). Auto-generated CANDIDATE QUESTION for playtest
# debrief; question-form per anti-pattern note.
check-breach-run-recap-regret-quote:
	@$(HEADLESS) --script res://loop/breach/test_breach_run_recap_regret_quote.gd 2>&1 | grep -E "^(  (match|mismatch|comfortable|not captured|underscore)|BREACH_RUN_RECAP_REGRET_QUOTE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_run_recap_regret_quote.gd 2>&1 | grep -q "^BREACH_RUN_RECAP_REGRET_QUOTE_OK"

# Arc-4 breach mode: Round-11 Phase-2 SWARM SPIKE harness (iter 85).
# Compares α/β/γ variants empirically; emits hierarchy verdict +
# recommendation per Pro's H2 critique (best/costly/bad answer
# across multiple archetypes — no shared-worst).
check-breach-swarm-spike:
	@$(HEADLESS) --script res://loop/breach/test_breach_swarm_spike.gd 2>&1 | grep -E "^(== |  |BREACH_SWARM_SPIKE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_swarm_spike.gd 2>&1 | grep -q "^BREACH_SWARM_SPIKE_OK"

# Arc-4 breach mode: all breach harnesses in one target.
test-breach: check-breach-config check-breach-shells check-breach-depot check-breach-depot-unpause check-breach-he-blast check-breach-he-blast-friendly-fire check-breach-mortar-friendly-fire check-breach-momentum-ram-compose check-breach-rear-guard-dead check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive check-breach-hud check-breach-reload-bar check-breach-speed-meter check-breach-shell-chips check-breach-kill-flash check-breach-active-cards-ribbon check-breach-q1-proof check-breach-run-recap-routes check-breach-route-gate-wiring check-breach-q1-proof-parser check-breach-q1-proof-scene check-breach-q1-proof-playthrough check-breach-route-currency-summary check-breach-h6-pressure-fade check-breach-q1-proof-fire-e2e check-breach-hud-z-stack check-breach-card-pickup-toast check-breach-card-pick-e2e check-breach-q1-bot-run check-breach-shell-pressure-matrix check-breach-hud-coverage check-breach-brick-variant check-breach-brick-variant-activation check-breach-q1-replay-capture check-breach-apcr check-breach-codex check-breach-shuffle check-breach-depot-roll check-breach-rulechangers check-breach-stakes check-breach-meta check-breach-route check-breach-xp check-breach-ammo check-breach-shield check-breach-hp check-breach-archetype check-breach-prism check-breach-mortar check-breach-ram check-breach-archetype-select check-breach-archetype-switch check-breach-distinctness-audit check-breach-pressure-probes check-breach-band-shape check-breach-band-shape-analyzer check-breach-swarm-spike check-breach-double-kill check-breach-archetype-select-pause check-breach-xp-reload-persistence check-breach-switch-archetype-validation check-breach-pick-archetype-and-mortar-guard check-breach-run-recap-archetype-contract check-breach-p2-batch1 check-breach-p2-batch2 check-breach-p2-batch3 check-breach-depot-lifetime-pick check-breach-steel-salvage-threshold check-breach-band-banner-stacking check-breach-fire-while-swap check-breach-level-up-ceilings check-breach-ammo-pickup-no-waste check-breach-toast-stagger check-breach-route-strip-max-cleared check-breach-run-recap-verdict-sentence check-breach-run-recap-killer check-breach-run-recap-resource-sentence check-breach-scout-telegraph check-breach-rear-guard check-breach-run-recap-route-diff check-breach-run-recap-regret-quote check-breach-archetype-sprite check-archetype-sprite-silhouettes check-breach-mortar-charge check-breach-upgrade-catalog check-breach-levelup-pick check-breach-card-apply-p3 check-breach-card-apply-p4

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
