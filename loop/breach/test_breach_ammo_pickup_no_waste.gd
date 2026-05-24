# Arc-4 breach mode: P2-A regression — AmmoPickup must NOT silently
# no-op when the chosen shell is at cap (iter 103, code-review-iter-100).
#
# Before the fix: AmmoPickup.shell_class was randi()-picked at _ready
# without knowledge of the player's reserve state. Pickup at HE-cap
# silently no-op'd. Violates CONSULT constraint 3 ("every shell event
# must have a readable shell/positioning relationship").
#
# After the fix: at _on_body_entered time (when the player's loadout
# is known), if the chosen shell is at cap and another droppable shell
# is below cap, re-roll to a random under-cap shell. If ALL three
# are at cap, accept the no-op (player is genuinely topped).
#
# Verifies:
#   1. HE at cap + HEAT/APCR below cap → pickup refills HEAT or APCR
#      (NOT silent waste).
#   2. All 3 at cap → pickup quietly consumes itself (no crash; no
#      false refill).
#   3. HE NOT at cap → pickup refills HE as before (regression check).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_ammo_pickup_no_waste.gd

extends SceneTree

const AmmoPickupScene = preload("res://scenes/AmmoPickup.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


class StubPlayer extends CharacterBody2D:
	var loadout = null

	func _show_pickup_toast(_msg: String, _color: Color) -> void:
		pass


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Test 1: HE at cap, HEAT + APCR below cap → pickup re-rolls
	# to HEAT or APCR. Force the pickup's shell_class to HE.
	if not await _run_pickup_test("HE-at-cap re-rolls", 6, 6, 0, 3, 0, 4,
			BulletT.SHELL_CLASS_HE, [BulletT.SHELL_CLASS_HEAT, BulletT.SHELL_CLASS_APCR]):
		quit(1); return

	# === Test 2: All 3 at cap → silent no-op (no crash; nothing refilled).
	if not await _run_pickup_test("all-at-cap silent no-op", 6, 6, 3, 3, 4, 4,
			BulletT.SHELL_CLASS_HE, []):
		quit(1); return

	# === Test 3: HE below cap → refills HE as before (regression).
	if not await _run_pickup_test("HE-below-cap refills HE", 2, 6, 0, 3, 0, 4,
			BulletT.SHELL_CLASS_HE, [BulletT.SHELL_CLASS_HE]):
		quit(1); return

	print("BREACH_AMMO_PICKUP_NO_WASTE_OK pickup re-roll on cap + silent no-op when all-at-cap verified")
	quit(0)


# Build a player with the given reserve state, spawn the pickup, force
# its shell_class to `force_class`, drive `_on_body_entered`, and assert
# that exactly one of `expected_refilled_classes` had its reserve
# increment by 1 (if list empty: assert NO reserve changed).
func _run_pickup_test(label: String,
		he: int, max_he: int, heat: int, max_heat: int,
		apcr: int, max_apcr: int, force_class: int,
		expected_refilled_classes: Array) -> bool:
	var holder: Node = root.get_child(0)
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.he_reserve = he
	lo.max_he_reserve = max_he
	lo.heat_reserve = heat
	lo.max_heat_reserve = max_heat
	lo.apcr_reserve = apcr
	lo.max_apcr_reserve = max_apcr
	player.loadout = lo
	holder.add_child(player)
	var pickup: Node = AmmoPickupScene.instantiate()
	holder.add_child(pickup)
	await process_frame
	pickup.shell_class = force_class
	pickup._on_body_entered(player)
	await process_frame
	# Compute the diffs.
	var he_d: int = lo.he_reserve - he
	var heat_d: int = lo.heat_reserve - heat
	var apcr_d: int = lo.apcr_reserve - apcr
	var got_refilled: Array[int] = []
	if he_d > 0: got_refilled.append(BulletT.SHELL_CLASS_HE)
	if heat_d > 0: got_refilled.append(BulletT.SHELL_CLASS_HEAT)
	if apcr_d > 0: got_refilled.append(BulletT.SHELL_CLASS_APCR)
	if expected_refilled_classes.is_empty():
		# Expect NO refill (all-at-cap honest no-op).
		if got_refilled.size() != 0:
			push_error("FAIL %s — expected NO refill, got refills for %s (HE_d=%d HEAT_d=%d APCR_d=%d)" \
					% [label, str(got_refilled), he_d, heat_d, apcr_d])
			holder.remove_child(player); player.queue_free()
			holder.remove_child(pickup) if is_instance_valid(pickup) and pickup.get_parent() == holder else null
			return false
		print("  %s — pickup consumed silently (no false refill)" % label)
	else:
		# Expect exactly 1 refill, and that 1 must be in the expected set.
		if got_refilled.size() != 1:
			push_error("FAIL %s — expected exactly 1 refill, got %d (%s)" \
					% [label, got_refilled.size(), str(got_refilled)])
			holder.remove_child(player); player.queue_free()
			return false
		var actual: int = got_refilled[0]
		if not (actual in expected_refilled_classes):
			push_error("FAIL %s — refilled shell %d not in expected %s" \
					% [label, actual, str(expected_refilled_classes)])
			holder.remove_child(player); player.queue_free()
			return false
		print("  %s — refilled shell %d (one of %s)" \
				% [label, actual, str(expected_refilled_classes)])
	holder.remove_child(player); player.queue_free()
	await process_frame
	return true
