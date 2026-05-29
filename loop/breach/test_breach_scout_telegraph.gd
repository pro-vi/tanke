# Arc-4 breach mode: Round 13 Phase 2 — SCOUT_TELEGRAPH upgrade
# (iter 113, closes C8 anchor 3's tutorial_choke band-coverage gap
# surfaced by iter-112 audit).
#
# The upgrade gives the player a perceptual affordance: when owned,
# Light enemies spawn with a warm yellow self_modulate tint, making
# them easier to spot and pre-aim. Sentence-test compliant:
# "helps me climb tutorial_choke by changing how I see Light scouts."
#
# Verifies:
#   1. Loadout has has_scout_telegraph default false.
#   2. Depot.apply_upgrade(SCOUT_TELEGRAPH) sets has_scout_telegraph = true.
#   3. Depot.UpgradeKind.SCOUT_TELEGRAPH exists + is distinct from prior
#      kinds.
#   4. Depot._upgrade_pool includes SCOUT_TELEGRAPH at every tier (no
#      meta-gate — it's a low-tier perceptual aid).
#   5. Depot._label_for_kind returns the sentence-test-compliant label
#      for SCOUT_TELEGRAPH (verb phrasing — "see Light scouts earlier").
#   6. Enemy with `scout_telegraph_outline = true` set pre-_ready
#      applies the warm yellow self_modulate (overrides per-type
#      sprite_tint).
#   7. Enemy without the flag retains its per-type sprite_tint
#      (regression — arc-2/3 baseline behavior preserved).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_scout_telegraph.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const EnemyScene = preload("res://scenes/Enemy.tscn")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Test 1: Loadout has has_scout_telegraph default false.
	var lo: LoadoutT = LoadoutT.new()
	if lo.has_scout_telegraph:
		push_error("FAIL — Loadout.has_scout_telegraph default should be false")
		quit(1); return
	print("  Loadout.has_scout_telegraph default = false")

	# === Test 2: apply_upgrade(SCOUT_TELEGRAPH) flips the flag.
	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame
	depot.apply_upgrade(depot.UpgradeKind.SCOUT_TELEGRAPH, lo)
	if not lo.has_scout_telegraph:
		push_error("FAIL — apply_upgrade(SCOUT_TELEGRAPH) did not set has_scout_telegraph")
		quit(1); return
	print("  apply_upgrade(SCOUT_TELEGRAPH) sets has_scout_telegraph = true")

	# === Test 3: enum has SCOUT_TELEGRAPH distinct from prior kinds.
	var UK = depot.UpgradeKind
	var prior_kinds: Array = [
		UK.HE_REFILL_2, UK.HEAT_REFILL_1, UK.HE_MAX_EXPAND_2,
		UK.HEAT_MAX_EXPAND_2, UK.FULL_RESUPPLY, UK.BREACH_DIVIDEND,
		UK.OVERDRIVE, UK.QUICK_SWAP, UK.STEEL_SALVAGE,
		UK.SWITCH_TO_PRISM, UK.SWITCH_TO_MORTAR, UK.SWITCH_TO_RAM,
	]
	if UK.SCOUT_TELEGRAPH in prior_kinds:
		push_error("FAIL — SCOUT_TELEGRAPH enum value collides with prior kind")
		quit(1); return
	print("  SCOUT_TELEGRAPH enum value distinct from all 12 prior kinds")

	# === Test 4: pool includes SCOUT_TELEGRAPH at every tier.
	for best in [0, 20, 40, 60, 80, 999]:
		var pool: Array = depot._upgrade_pool(best)
		if not (UK.SCOUT_TELEGRAPH in pool):
			push_error("FAIL — SCOUT_TELEGRAPH not in pool@%d (best_depth)" % best)
			quit(1); return
	print("  SCOUT_TELEGRAPH in pool at every tier (0/20/40/60/80/999)")

	# === Test 5: label is sentence-test-compliant.
	var label: String = depot._label_for_kind(UK.SCOUT_TELEGRAPH)
	if not ("Scout Telegraph" in label) or not ("see Light scouts" in label):
		push_error("FAIL — SCOUT_TELEGRAPH label does not name the affordance: '%s'" % label)
		quit(1); return
	print("  SCOUT_TELEGRAPH label: '%s' (verb-style; sentence-test-compliant)" % label)

	# === Test 6: Enemy with scout_telegraph_outline = true gets warm
	# yellow self_modulate (overrides per-type sprite_tint).
	var enemy_a: Node2D = EnemyScene.instantiate()
	enemy_a.scout_telegraph_outline = true
	enemy_a.sprite_tint = Color(0.5, 0.5, 0.5, 1.0)  # arbitrary per-type tint
	holder.add_child(enemy_a)
	await process_frame
	await process_frame
	var sprite_a: Sprite2D = enemy_a.get_node("Sprite2D") as Sprite2D
	if sprite_a == null:
		push_error("FAIL — enemy_a sprite not found")
		quit(1); return
	if sprite_a.self_modulate.r < 0.95 or sprite_a.self_modulate.g < 0.9 or sprite_a.self_modulate.b > 0.5:
		push_error("FAIL — scout_telegraph_outline enemy did not get warm-yellow tint: %s" % str(sprite_a.self_modulate))
		quit(1); return
	print("  enemy with scout_telegraph_outline=true → warm yellow self_modulate (overrides per-type tint)")
	enemy_a.queue_free()

	# === Test 7: Enemy WITHOUT the flag keeps per-type sprite_tint
	# (regression — arc-2/3 baseline behavior preserved).
	var enemy_b: Node2D = EnemyScene.instantiate()
	enemy_b.scout_telegraph_outline = false
	enemy_b.sprite_tint = Color(0.5, 0.5, 0.5, 1.0)
	holder.add_child(enemy_b)
	await process_frame
	await process_frame
	var sprite_b: Sprite2D = enemy_b.get_node("Sprite2D") as Sprite2D
	# Per-type tint preserved (not the warm yellow).
	if absf(sprite_b.self_modulate.r - 0.5) > 0.01 \
			or absf(sprite_b.self_modulate.g - 0.5) > 0.01 \
			or absf(sprite_b.self_modulate.b - 0.5) > 0.01:
		push_error("FAIL — enemy without flag did not retain per-type sprite_tint: %s" % str(sprite_b.self_modulate))
		quit(1); return
	print("  enemy without scout_telegraph_outline → per-type sprite_tint preserved (arc-2/3 baseline)")
	enemy_b.queue_free()

	depot.queue_free()
	print("BREACH_SCOUT_TELEGRAPH_OK 7 cases verified: Loadout flag + Depot enum/label/pool/apply + Enemy tint override + baseline regression")
	quit(0)
