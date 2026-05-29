# Arc-4 breach mode: band-aware enemy roster verifier (C5 anchor 1).
# Verifies:
#   1. all 5 breach bands declare non-empty enemy_weights with valid
#      role names (Light/Heavy/Fast — the Spawner ENEMY_TYPES roster)
#   2. Spawner._pick_enemy_type, in breach mode, picks band-appropriate
#      enemy types from the active BreachBand's enemy_weights
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_enemies.gd

extends SceneTree

const BreachConfigT = preload("res://scripts/BreachConfig.gd")
const SpawnerT = preload("res://scripts/Spawner.gd")
const VALID_ROLES := ["Light", "Heavy", "Fast"]


# Stub level exposing the two properties Spawner._breach_band_weights
# reads. Script-declared vars so the `in` checks resolve.
class StubLevel extends Node:
	var breach_mode_enabled: bool = true
	var _current_breach_band = null


func _initialize() -> void:
	var cfg: BreachConfigT = load("res://configs/breach_default.tres")
	if cfg == null:
		push_error("FAIL — breach_default.tres did not load"); quit(1); return

	# === Test 1: every band declares a valid non-empty roster.
	for band in cfg.bands:
		var w: Dictionary = band.enemy_weights
		if w.is_empty():
			push_error("FAIL — band %s has empty enemy_weights" % band.band_name)
			quit(1); return
		var total: float = 0.0
		for role in w:
			if not (role in VALID_ROLES):
				push_error("FAIL — band %s has invalid role '%s'" % [band.band_name, role])
				quit(1); return
			total += float(w[role])
		if total <= 0.0:
			push_error("FAIL — band %s roster weights sum to 0" % band.band_name)
			quit(1); return
		print("  band %-16s roster=%s" % [band.band_name, w])

	# === Test 2: Spawner picks band-appropriate types in breach mode.
	var spawner = SpawnerT.new()
	var stub := StubLevel.new()
	stub.add_child(spawner)
	root.add_child(stub)
	await process_frame

	# tutorial_choke: Light-only → 30 picks must ALL be Light.
	stub._current_breach_band = cfg.bands[0]  # tutorial_choke
	for i in 30:
		var picked: Dictionary = spawner._pick_enemy_type()
		if picked.name != "Light":
			push_error("FAIL — tutorial_choke picked '%s', expected Light" % picked.name)
			quit(1); return

	# bunker_zone: {Heavy 0.75, Light 0.25} → Heavy must dominate, no Fast.
	stub._current_breach_band = cfg.bands[2]  # bunker_zone
	var heavy_n: int = 0
	for i in 200:
		var picked: Dictionary = spawner._pick_enemy_type()
		if picked.name == "Fast":
			push_error("FAIL — bunker_zone picked Fast (weight 0)")
			quit(1); return
		if picked.name == "Heavy":
			heavy_n += 1
	if heavy_n < 100:  # expect ~150/200; floor well below for variance
		push_error("FAIL — bunker_zone Heavy share too low: %d/200" % heavy_n)
		quit(1); return

	# === Test 3: role coverage — each of the 3 roles appears in >=1 band
	# roster (C5 anchor 2 clause b — "harness verifies presence in band
	# rosters"; per-role canonical answers are documented in BANDS.md).
	var seen: Dictionary = {}
	for band in cfg.bands:
		for role in band.enemy_weights:
			if float(band.enemy_weights[role]) > 0.0:
				seen[role] = true
	for role in VALID_ROLES:
		if not seen.has(role):
			push_error("FAIL — role '%s' appears in no band roster" % role)
			quit(1); return
	print("  role coverage: %s — all appear in >=1 band" % str(seen.keys()))

	print("BREACH_ENEMIES_OK 5 bands rostered; 3 roles covered; Spawner picks band-appropriate types")
	quit(0)
