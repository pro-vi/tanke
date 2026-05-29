# Arc-4 breach mode: P1-3 + P1-5 regression — switch_archetype
# value validation + Depot._player is_instance_valid guard
# (iter 093, fixing iter-90 /code-review P1-3 and P1-5).
#
# P1-3: switch_archetype(99) used to silently put the tank in
#   undefined state. Now rejects out-of-range values with a
#   push_warning.
# P1-5: Depot.apply_upgrade SWITCH_TO_* used to crash if _player
#   was a freed Node. Now wraps the call with is_instance_valid.
#
# Verifies:
#   P1-3:
#   - switch_archetype(-1) → no change
#   - switch_archetype(99) → no change
#   - switch_archetype(current) → no change (existing no-op)
#   - switch_archetype(PRISM) when current == DEFAULT → archetype becomes PRISM
#   - switch_archetype(TankArchetype.RAM) → valid, archetype changes
#   P1-5:
#   - Depot apply_upgrade(SWITCH_TO_PRISM, lo) with _player == null → no-op
#   - Depot apply_upgrade(SWITCH_TO_PRISM, lo) with _player freed → no crash, no-op
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_switch_archetype_validation.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")
const DepotT = preload("res://scripts/Depot.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === P1-3: switch_archetype out-of-range validation.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — fresh archetype %d, want DEFAULT (0)" % pt.archetype)
		quit(1); return

	# Negative value rejected.
	pt.switch_archetype(-1)
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — switch_archetype(-1): archetype changed to %d, want unchanged DEFAULT" % pt.archetype)
		quit(1); return
	print("  switch_archetype(-1): archetype unchanged (DEFAULT) — rejected")

	# Out-of-enum value rejected.
	pt.switch_archetype(99)
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — switch_archetype(99): archetype changed to %d, want unchanged DEFAULT" % pt.archetype)
		quit(1); return
	print("  switch_archetype(99): archetype unchanged (DEFAULT) — rejected")

	# Just-above-range rejected.
	pt.switch_archetype(PlayerTankT.TankArchetype.RAM + 1)
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — switch_archetype(RAM+1): archetype changed to %d, want unchanged DEFAULT" % pt.archetype)
		quit(1); return
	print("  switch_archetype(TankArchetype.RAM+1): rejected")

	# Same-value no-op.
	pt.switch_archetype(PlayerTankT.TankArchetype.DEFAULT)
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — switch_archetype(DEFAULT) same-value: archetype %d, want DEFAULT" % pt.archetype)
		quit(1); return
	print("  switch_archetype(DEFAULT) same-value: no-op")

	# Valid value works.
	pt.switch_archetype(PlayerTankT.TankArchetype.PRISM)
	if pt.archetype != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — switch_archetype(PRISM) valid: archetype %d, want PRISM" % pt.archetype)
		quit(1); return
	print("  switch_archetype(PRISM) valid: archetype = PRISM")

	# Boundary: RAM = max valid.
	pt.switch_archetype(PlayerTankT.TankArchetype.RAM)
	if pt.archetype != PlayerTankT.TankArchetype.RAM:
		push_error("FAIL — switch_archetype(RAM) boundary: archetype %d, want RAM" % pt.archetype)
		quit(1); return
	print("  switch_archetype(RAM) boundary: archetype = RAM")

	# === P1-5: Depot._player is_instance_valid guard.
	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame

	# _player == null case — apply_upgrade SWITCH_TO_PRISM is no-op.
	depot._player = null
	var pt_archetype_before: int = pt.archetype
	depot.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_PRISM, pt.loadout)
	if pt.archetype != pt_archetype_before:
		push_error("FAIL — depot SWITCH_TO_PRISM with _player==null mutated pt.archetype (was %d, now %d)" % [pt_archetype_before, pt.archetype])
		quit(1); return
	print("  depot SWITCH_TO_PRISM with _player==null: no-op (no crash)")

	# _player freed case — set _player to a Node, free it, then apply.
	var ghost := Node2D.new()
	holder.add_child(ghost)
	depot._player = ghost
	ghost.queue_free()
	await process_frame
	await process_frame
	# ghost is now freed; is_instance_valid(ghost) should be false.
	if is_instance_valid(ghost):
		push_error("FAIL — ghost still valid after queue_free + 2 frames")
		quit(1); return
	# apply_upgrade must NOT crash; archetype must NOT change.
	pt_archetype_before = pt.archetype
	depot.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_PRISM, pt.loadout)
	if pt.archetype != pt_archetype_before:
		push_error("FAIL — depot SWITCH_TO_PRISM with freed _player mutated pt.archetype")
		quit(1); return
	print("  depot SWITCH_TO_PRISM with freed _player: no-op (no crash, is_instance_valid guard works)")

	holder.queue_free()
	print("BREACH_SWITCH_ARCHETYPE_VALIDATION_OK P1-3 (value validation) + P1-5 (is_instance_valid guard) both verified")
	quit(0)
