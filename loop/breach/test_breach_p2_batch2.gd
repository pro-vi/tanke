# Arc-4 breach mode: P2 sweep batch 2 regression (iter 097).
# Verifies:
#   P2-4: PlayerTank._die calls _stop_beam when archetype == PRISM
#   P2-6: Depot._upgrade_pool filters SWITCH_TO_X matching
#         _player.archetype (no-op picks excluded)
#
# P2-2 (enum pin) is verified by an extension to test_breach_meta
# rather than this file.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_p2_batch2.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")
const DepotT = preload("res://scripts/Depot.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === P2-4: PRISM death hides beam.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt.archetype != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — P2-4 setup: archetype %d, want PRISM" % pt.archetype)
		quit(1); return
	if pt._beam_line == null:
		push_error("FAIL — P2-4 setup: BeamLine not built")
		quit(1); return

	# Make beam visible (simulate firing).
	pt._beam_line.visible = true
	# Trigger death.
	pt._die()
	# After P2-4: _beam_line.visible should be false.
	if pt._beam_line.visible:
		push_error("FAIL — P2-4: _beam_line still visible after _die (beam left drawn on death screen)")
		quit(1); return
	print("  P2-4 PRISM _die: BeamLine.visible = false (beam stopped)")

	# === P2-6: Depot _upgrade_pool filters same-archetype SWITCH_TO_*.
	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame

	# At best_depth >= 60 (where all SWITCH_TO_* are unlocked), filter
	# by current_archetype.
	# With current_archetype = PRISM (1): pool excludes SWITCH_TO_PRISM,
	# includes SWITCH_TO_MORTAR + SWITCH_TO_RAM.
	var pool_prism: Array = depot._upgrade_pool(60, PlayerTankT.TankArchetype.PRISM)
	if pool_prism.has(DepotT.UpgradeKind.SWITCH_TO_PRISM):
		push_error("FAIL — P2-6: pool with current_archetype=PRISM contains SWITCH_TO_PRISM")
		quit(1); return
	if not pool_prism.has(DepotT.UpgradeKind.SWITCH_TO_MORTAR):
		push_error("FAIL — P2-6: pool with current_archetype=PRISM missing SWITCH_TO_MORTAR")
		quit(1); return
	if not pool_prism.has(DepotT.UpgradeKind.SWITCH_TO_RAM):
		push_error("FAIL — P2-6: pool with current_archetype=PRISM missing SWITCH_TO_RAM")
		quit(1); return
	print("  P2-6 pool(current=PRISM): excludes SWITCH_TO_PRISM, includes SWITCH_TO_MORTAR + SWITCH_TO_RAM")

	# With current_archetype = RAM (3): pool excludes SWITCH_TO_RAM.
	var pool_ram: Array = depot._upgrade_pool(60, PlayerTankT.TankArchetype.RAM)
	if pool_ram.has(DepotT.UpgradeKind.SWITCH_TO_RAM):
		push_error("FAIL — P2-6: pool with current_archetype=RAM contains SWITCH_TO_RAM")
		quit(1); return
	if not pool_ram.has(DepotT.UpgradeKind.SWITCH_TO_PRISM):
		push_error("FAIL — P2-6: pool with current_archetype=RAM missing SWITCH_TO_PRISM")
		quit(1); return
	print("  P2-6 pool(current=RAM): excludes SWITCH_TO_RAM, includes SWITCH_TO_PRISM + SWITCH_TO_MORTAR")

	# Without current_archetype (default -1): pool includes all 3.
	var pool_default: Array = depot._upgrade_pool(60, -1)
	if not pool_default.has(DepotT.UpgradeKind.SWITCH_TO_PRISM):
		push_error("FAIL — P2-6: default pool missing SWITCH_TO_PRISM (filter shouldn't fire when current_archetype=-1)")
		quit(1); return
	if not pool_default.has(DepotT.UpgradeKind.SWITCH_TO_MORTAR):
		push_error("FAIL — P2-6: default pool missing SWITCH_TO_MORTAR")
		quit(1); return
	if not pool_default.has(DepotT.UpgradeKind.SWITCH_TO_RAM):
		push_error("FAIL — P2-6: default pool missing SWITCH_TO_RAM")
		quit(1); return
	print("  P2-6 pool(no current_archetype): all 3 SWITCH_TO_* included (filter inactive on default)")

	holder.queue_free()
	print("BREACH_P2_BATCH2_OK P2-4 (PRISM death stops beam) + P2-6 (Depot filters same-archetype SWITCH_TO_*) both verified")
	quit(0)
