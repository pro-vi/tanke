# Arc-4 breach mode: P0-2 regression — FASTER_RELOAD XP bonus must
# survive archetype switches (iter 092, fixing iter-90 /code-review
# P0-2).
#
# Before the fix: _revert_archetype hardcoded GunTimer.wait_time = 1.0
# (and _init_archetype MORTAR hardcoded MORTAR_GUN_COOLDOWN = 1.5),
# wiping the FASTER_RELOAD reduction every switch.
#
# After the fix: a cumulative `_reload_reduction` (float) tracks the
# XP-earned reduction; each archetype's effective wait_time =
# archetype_base − reduction (floored at RELOAD_MIN).
#
# Verifies:
#   - Fresh PlayerTank: wait_time == _base_default_gun_wait_time
#   - FASTER_RELOAD boost on DEFAULT: wait_time reduced by RELOAD_STEP
#   - Switch DEFAULT → MORTAR: wait_time = MORTAR_GUN_COOLDOWN − reduction
#   - Switch MORTAR → RAM → MORTAR: reduction preserved (not zero)
#   - Multiple FASTER_RELOAD boosts compose
#   - Floor at RELOAD_MIN
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_xp_reload_persistence.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Spawn a DEFAULT-archetype PlayerTank.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	var gt: Timer = pt.get_node("GunTimer")
	var base_default: float = pt._base_default_gun_wait_time
	print("  base default GunTimer.wait_time: %.2f" % base_default)
	if abs(gt.wait_time - base_default) > 0.001:
		push_error("FAIL — fresh DEFAULT wait_time %.2f, want %.2f" % [gt.wait_time, base_default])
		quit(1); return
	if pt._reload_reduction != 0.0:
		push_error("FAIL — fresh _reload_reduction %.2f, want 0.0" % pt._reload_reduction)
		quit(1); return
	print("  DEFAULT fresh: wait_time=%.2f, reduction=0.0" % gt.wait_time)

	# === FASTER_RELOAD boost on DEFAULT (level 3 — kind 1 = FASTER_RELOAD).
	pt._apply_level_boost(3)
	var after_first: float = gt.wait_time
	if pt._reload_reduction != PlayerTankT.RELOAD_STEP:
		push_error("FAIL — after 1 boost: reduction %.2f, want %.2f" % [pt._reload_reduction, PlayerTankT.RELOAD_STEP])
		quit(1); return
	if abs(after_first - (base_default - PlayerTankT.RELOAD_STEP)) > 0.001:
		push_error("FAIL — after 1 boost: wait_time %.2f, want %.2f" % [after_first, base_default - PlayerTankT.RELOAD_STEP])
		quit(1); return
	print("  after 1 FASTER_RELOAD on DEFAULT: wait_time=%.2f, reduction=%.2f" % [after_first, pt._reload_reduction])

	# === Switch DEFAULT → MORTAR: wait_time should be MORTAR_GUN_COOLDOWN − reduction.
	pt.switch_archetype(PlayerTankT.TankArchetype.MORTAR)
	var expected_mortar: float = PlayerTankT.MORTAR_GUN_COOLDOWN - PlayerTankT.RELOAD_STEP
	if abs(gt.wait_time - expected_mortar) > 0.001:
		push_error("FAIL — DEFAULT→MORTAR: wait_time %.2f, want %.2f (MORTAR_GUN_COOLDOWN − reduction)" % [gt.wait_time, expected_mortar])
		quit(1); return
	print("  switch DEFAULT→MORTAR: wait_time=%.2f (MORTAR_base %.2f − reduction %.2f)" % [gt.wait_time, PlayerTankT.MORTAR_GUN_COOLDOWN, PlayerTankT.RELOAD_STEP])

	# === Switch MORTAR → RAM → MORTAR: reduction preserved through the round-trip.
	pt.switch_archetype(PlayerTankT.TankArchetype.RAM)
	# wait_time is restored to DEFAULT base − reduction during _revert_archetype MORTAR.
	if abs(gt.wait_time - (base_default - PlayerTankT.RELOAD_STEP)) > 0.001:
		push_error("FAIL — switch MORTAR→RAM: wait_time %.2f, want %.2f (DEFAULT base − reduction)" % [gt.wait_time, base_default - PlayerTankT.RELOAD_STEP])
		quit(1); return
	if pt._reload_reduction != PlayerTankT.RELOAD_STEP:
		push_error("FAIL — switch MORTAR→RAM: reduction %.2f, want %.2f (preserved)" % [pt._reload_reduction, PlayerTankT.RELOAD_STEP])
		quit(1); return
	print("  switch MORTAR→RAM: wait_time=%.2f, reduction preserved (%.2f)" % [gt.wait_time, pt._reload_reduction])
	pt.switch_archetype(PlayerTankT.TankArchetype.MORTAR)
	if abs(gt.wait_time - expected_mortar) > 0.001:
		push_error("FAIL — switch RAM→MORTAR: wait_time %.2f, want %.2f (still reduced)" % [gt.wait_time, expected_mortar])
		quit(1); return
	print("  switch RAM→MORTAR: wait_time=%.2f (reduction held through round-trip)" % gt.wait_time)

	# === Multiple boosts compose. Apply FASTER_RELOAD again while MORTAR.
	pt._apply_level_boost(6)  # kind = (6 - 2) % 3 = 1 = FASTER_RELOAD
	if pt._reload_reduction != 2 * PlayerTankT.RELOAD_STEP:
		push_error("FAIL — after 2 boosts: reduction %.2f, want %.2f" % [pt._reload_reduction, 2 * PlayerTankT.RELOAD_STEP])
		quit(1); return
	if abs(gt.wait_time - (PlayerTankT.MORTAR_GUN_COOLDOWN - 2 * PlayerTankT.RELOAD_STEP)) > 0.001:
		push_error("FAIL — after 2 boosts MORTAR: wait_time %.2f, want %.2f" % [gt.wait_time, PlayerTankT.MORTAR_GUN_COOLDOWN - 2 * PlayerTankT.RELOAD_STEP])
		quit(1); return
	print("  2nd FASTER_RELOAD while MORTAR: reduction=%.2f, wait_time=%.2f" % [pt._reload_reduction, gt.wait_time])

	# === Floor at RELOAD_MIN. Apply many boosts to drive past the floor.
	for i in 20:
		pt._apply_level_boost(3 + i * 3)  # ensures kind == 1 every iter
	if gt.wait_time < PlayerTankT.RELOAD_MIN - 0.001:
		push_error("FAIL — after many boosts: wait_time %.2f below RELOAD_MIN %.2f" % [gt.wait_time, PlayerTankT.RELOAD_MIN])
		quit(1); return
	if abs(gt.wait_time - PlayerTankT.RELOAD_MIN) > 0.001:
		push_error("FAIL — after many boosts: wait_time %.2f, want exact RELOAD_MIN %.2f (floor saturation)" % [gt.wait_time, PlayerTankT.RELOAD_MIN])
		quit(1); return
	print("  after many FASTER_RELOAD boosts: wait_time=%.2f (floored at RELOAD_MIN %.2f)" % [gt.wait_time, PlayerTankT.RELOAD_MIN])

	holder.queue_free()
	print("BREACH_XP_RELOAD_PERSISTENCE_OK P0-2 fix verified — FASTER_RELOAD bonus survives archetype switches, composes additively, floors at RELOAD_MIN")
	quit(0)
