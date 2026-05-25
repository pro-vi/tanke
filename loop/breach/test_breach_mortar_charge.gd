# Arc-4 breach mode: MORTAR charge-lob regression (iter 195).
# Verifies:
#   - Tap (release immediately at t=0) fires at MORTAR_RANGE_MIN.
#   - Full hold (t=1 charge) fires at MORTAR_RANGE_MAX.
#   - Mid-charge release lerps cleanly.
#   - Reticle is built lazily on first charge + hidden after fire.
#   - Switching archetype mid-charge cancels + frees reticle.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_mortar_charge.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _assert_eq(actual, expected, label: String) -> bool:
	if actual != expected:
		push_error("FAIL — %s: got %s, want %s" % [label, str(actual), str(expected)])
		return false
	return true


func _assert_close(actual: float, expected: float, eps: float, label: String) -> bool:
	if absf(actual - expected) > eps:
		push_error("FAIL — %s: got %f, want %f (eps %f)" % [label, actual, expected, eps])
		return false
	return true


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Case 1: tap (release at t=0) → range = MORTAR_RANGE_MIN ===
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.MORTAR
	holder.add_child(pt)
	await process_frame
	await process_frame

	# Simulate just_pressed via direct state poke (no Input action map in headless).
	pt._mortar_charging = true
	pt._mortar_charge_t = 0.0
	# Compute the target the tank would lob to at t=0.
	var tap_target: Vector2 = pt._mortar_reticle_target()
	var muzzle_pos: Vector2 = pt.get_node("Muzzle").global_position
	var tap_range: float = (tap_target - muzzle_pos).length()
	if not _assert_close(tap_range, pt.MORTAR_RANGE_MIN, 0.5, "tap-range = MORTAR_RANGE_MIN"):
		quit(1); return
	print("  tap (t=0): range = %.1f px (MORTAR_RANGE_MIN)" % tap_range)

	# === Case 2: full hold (t=1) → range = MORTAR_RANGE_MAX ===
	pt._mortar_charge_t = 1.0
	var full_target: Vector2 = pt._mortar_reticle_target()
	var full_range: float = (full_target - muzzle_pos).length()
	if not _assert_close(full_range, pt.MORTAR_RANGE_MAX, 0.5, "full-charge = MORTAR_RANGE_MAX"):
		quit(1); return
	print("  full hold (t=1): range = %.1f px (MORTAR_RANGE_MAX)" % full_range)

	# === Case 3: mid-charge (t=0.5) → range ≈ midpoint ===
	pt._mortar_charge_t = 0.5
	var mid_target: Vector2 = pt._mortar_reticle_target()
	var mid_range: float = (mid_target - muzzle_pos).length()
	var expected_mid: float = (pt.MORTAR_RANGE_MIN + pt.MORTAR_RANGE_MAX) * 0.5
	if not _assert_close(mid_range, expected_mid, 0.5, "mid-charge = midpoint"):
		quit(1); return
	print("  mid-charge (t=0.5): range = %.1f px ≈ midpoint %.1f" % [mid_range, expected_mid])

	# === Case 4: reticle built lazily + hidden after cancel ===
	pt._mortar_reticle_show()
	if not _assert_eq(pt._mortar_reticle != null, true, "reticle exists after show()"):
		quit(1); return
	if not _assert_eq(pt._mortar_reticle.visible, true, "reticle visible after show()"):
		quit(1); return
	pt._mortar_cancel_charge()
	if not _assert_eq(pt._mortar_reticle.visible, false, "reticle hidden after cancel"):
		quit(1); return
	print("  reticle: lazy-built on show; hidden on cancel")

	# === Case 5: archetype switch frees the reticle ===
	pt._mortar_reticle_show()  # rebuild it
	if not _assert_eq(pt._mortar_reticle.visible, true, "reticle re-shown"):
		quit(1); return
	pt.switch_archetype(PlayerTankT.TankArchetype.DEFAULT)
	await process_frame
	if not _assert_eq(pt._mortar_reticle, null, "reticle freed on switch from MORTAR"):
		quit(1); return
	print("  reticle: freed on switch MORTAR→DEFAULT")

	holder.queue_free()
	print("BREACH_MORTAR_CHARGE_OK 5 cases verified: tap-range + full-charge + mid + reticle lifecycle + switch-cleanup")
	quit(0)
