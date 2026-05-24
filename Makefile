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

.PHONY: check test screenshot analyze run diff screenshot-og png-diff-og og-metrics check-loader check-chain check-chain-35 og-band-check check-titlescreen-nav test-all check-breach-config check-breach-shells check-breach-depot check-breach-he-blast check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive check-breach-hud check-breach-apcr check-breach-codex check-breach-shuffle check-breach-depot-roll check-breach-rulechangers check-breach-stakes check-breach-meta check-breach-route check-breach-xp check-breach-ammo check-breach-shield check-breach-hp check-breach-archetype check-breach-prism check-breach-mortar check-breach-ram check-breach-archetype-select check-breach-archetype-switch check-breach-distinctness-audit check-breach-pressure-probes check-breach-band-shape check-breach-band-shape-analyzer check-breach-swarm-spike check-breach-double-kill check-breach-archetype-select-pause test-breach

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
	@$(HEADLESS) --script res://loop/breach/test_breach_meta.gd 2>&1 | grep -E "^(  (unlock|depot)|BREACH_META_OK|FAIL|ERROR|SCRIPT ERROR)"; \
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

# Arc-4 breach mode: Round-11 Phase-2 SWARM SPIKE harness (iter 85).
# Compares α/β/γ variants empirically; emits hierarchy verdict +
# recommendation per Pro's H2 critique (best/costly/bad answer
# across multiple archetypes — no shared-worst).
check-breach-swarm-spike:
	@$(HEADLESS) --script res://loop/breach/test_breach_swarm_spike.gd 2>&1 | grep -E "^(== |  |BREACH_SWARM_SPIKE_OK|FAIL|ERROR|SCRIPT ERROR)"; \
	$(HEADLESS) --script res://loop/breach/test_breach_swarm_spike.gd 2>&1 | grep -q "^BREACH_SWARM_SPIKE_OK"

# Arc-4 breach mode: all breach harnesses in one target.
test-breach: check-breach-config check-breach-shells check-breach-depot check-breach-he-blast check-breach-loadout check-breach-depot-choice check-breach-level check-breach-harness check-breach-recap check-breach-enemies check-breach-assets check-silhouette-gate check-breach-armor check-breach-dividend check-breach-swap check-breach-overdrive check-breach-hud check-breach-apcr check-breach-codex check-breach-shuffle check-breach-depot-roll check-breach-rulechangers check-breach-stakes check-breach-meta check-breach-route check-breach-xp check-breach-ammo check-breach-shield check-breach-hp check-breach-archetype check-breach-prism check-breach-mortar check-breach-ram check-breach-archetype-select check-breach-archetype-switch check-breach-distinctness-audit check-breach-pressure-probes check-breach-band-shape check-breach-band-shape-analyzer check-breach-swarm-spike check-breach-double-kill check-breach-archetype-select-pause check-breach-xp-reload-persistence check-breach-switch-archetype-validation

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
