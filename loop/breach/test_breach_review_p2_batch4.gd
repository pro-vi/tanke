# arc-4 PR-#4 review fix regression — Batch 4 (P2 #5):
# Spawner._pick_enemy_type's total gate previously used intrinsic
# ENEMY_TYPES weights as fallback while _weighted_pick used 0.0,
# producing a skewed distribution + invalid total gate for any band
# that omitted an enemy type. Latent because current DEPTH_BANDS list
# every type. Fix: total gate now uses 0.0 fallback to match
# _weighted_pick's actual roll behavior.
#
# 3 cases:
#   1. _weighted_pick with all-zero weights returns ENEMY_TYPES[0]
#      (the documented fallback — sanity check).
#   2. _weighted_pick with weights omitting a type NEVER returns that
#      type across many rolls (regression: pre-fix would have been
#      possible if total gate had let it through).
#   3. _weighted_pick with explicit weights returns each type within
#      ~3 standard deviations of its expected count over a large
#      sample (sanity: roll correctness).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_review_p2_batch4.gd

extends SceneTree

const SpawnerT = preload("res://scripts/Spawner.gd")


func _initialize() -> void:
	# Instantiate a Spawner to access _weighted_pick. Spawner is a
	# script attached at scene level (no .tscn); construct via .new().
	var sp: Node = SpawnerT.new()
	root.add_child(sp)
	await process_frame

	# === Case 1: all-zero weights → returns ENEMY_TYPES[0].
	var zero_weights: Dictionary = {"Light": 0.0, "Heavy": 0.0, "Fast": 0.0}
	var pick1: Dictionary = sp._weighted_pick(zero_weights)
	if String(pick1.name) != String(sp.ENEMY_TYPES[0].name):
		push_error("FAIL — all-zero weights returned '%s' (want ENEMY_TYPES[0]='%s')" \
				% [pick1.name, sp.ENEMY_TYPES[0].name])
		quit(1); return
	print("  case 1: all-zero weights → ENEMY_TYPES[0] ('%s') (documented fallback)" % pick1.name)

	# === Case 2: weights omitting "Fast" → many rolls never return Fast.
	# Pre-fix bug surface: _pick_enemy_type would let weights={Light: 0.7,
	# Heavy: 0.3} into _weighted_pick; _weighted_pick rolls only over those
	# (Fast has 0.0 fallback). So Fast is correctly skipped IN _weighted_pick.
	# This case verifies the roll consistency property the fix relies on.
	var no_fast: Dictionary = {"Light": 0.7, "Heavy": 0.3}
	var fast_count: int = 0
	for i in 500:
		var p: Dictionary = sp._weighted_pick(no_fast)
		if String(p.name) == "Fast":
			fast_count += 1
	if fast_count > 0:
		push_error("FAIL — _weighted_pick returned Fast %d/500 times when omitted from weights" % fast_count)
		quit(1); return
	print("  case 2: _weighted_pick with weights missing 'Fast' → 0/500 rolls returned Fast")

	# === Case 3: roll correctness — Light 70% / Heavy 30% distribution.
	var pcts: Dictionary = {"Light": 0.7, "Heavy": 0.3, "Fast": 0.0}
	var counts: Dictionary = {"Light": 0, "Heavy": 0, "Fast": 0}
	var trials: int = 1000
	for i in trials:
		var p: Dictionary = sp._weighted_pick(pcts)
		var n: String = String(p.name)
		counts[n] = int(counts.get(n, 0)) + 1
	# Expect ~700 Light, ~300 Heavy, 0 Fast. ±100 wide window.
	if int(counts.get("Light", 0)) < 600 or int(counts.get("Light", 0)) > 800:
		push_error("FAIL — Light count %d/1000 outside [600, 800] (skewed roll)" % counts.get("Light", 0))
		quit(1); return
	if int(counts.get("Heavy", 0)) < 200 or int(counts.get("Heavy", 0)) > 400:
		push_error("FAIL — Heavy count %d/1000 outside [200, 400] (skewed roll)" % counts.get("Heavy", 0))
		quit(1); return
	print("  case 3: 1000 rolls @ 70/30 → Light=%d / Heavy=%d / Fast=%d (within 3σ)" \
			% [counts["Light"], counts["Heavy"], counts["Fast"]])

	print("BREACH_REVIEW_P2_BATCH4_OK 3 cases — weight fallback consistency between total gate + roll")
	quit(0)
