# Arc-4 breach mode: MORTAR Tank verifier (Round 9d, iter 66).
# Verifies:
#   - archetype=MORTAR slows GunTimer.wait_time to MORTAR_GUN_COOLDOWN
#   - _fire_mortar spawns a MortarShell into the player's parent
#   - the shell's _explode() damages in-AOE_RADIUS siblings via
#     take_damage and spares out-of-radius
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_mortar.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")
const MortarShellT = preload("res://scripts/MortarShell.gd")


class StubTarget extends Node2D:
	var damage_taken: int = 0
	func take_damage(amount: int) -> void:
		damage_taken += amount


func _initialize() -> void:
	# === archetype=MORTAR slows GunTimer + _fire_mortar spawns a shell.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.MORTAR
	holder.add_child(pt)
	await process_frame
	await process_frame  # iter-50 deferred RoutePanel build
	var gt: Timer = pt.get_node("GunTimer") as Timer
	if gt.wait_time < pt.MORTAR_GUN_COOLDOWN - 0.01:
		push_error("FAIL — MORTAR GunTimer wait_time = %.2fs, want >= %.2fs" % [gt.wait_time, pt.MORTAR_GUN_COOLDOWN])
		quit(1); return
	print("  MORTAR GunTimer slowed to %.2fs" % gt.wait_time)

	# _fire_mortar adds a MortarShell to the parent (holder).
	var shells_before: int = 0
	for child in holder.get_children():
		if child.get_script() == MortarShellT:
			shells_before += 1
	pt._fire_mortar()
	await process_frame
	var shells_after: int = 0
	for child in holder.get_children():
		if child.get_script() == MortarShellT:
			shells_after += 1
	if shells_after - shells_before != 1:
		push_error("FAIL — _fire_mortar did not spawn a MortarShell (before=%d, after=%d)" % [shells_before, shells_after])
		quit(1); return
	print("  _fire_mortar spawned 1 MortarShell into parent")
	pt.queue_free()
	await process_frame

	# === MortarShell._explode() AoE: in-radius takes damage, far spared.
	var ah := Node2D.new()
	root.add_child(ah)
	var shell: Node = MortarShellScene.instantiate()
	ah.add_child(shell)
	shell.target_pos = Vector2(80, 0)
	var in_target := StubTarget.new()
	in_target.position = Vector2(80, 5)  # within AOE_RADIUS (18)
	ah.add_child(in_target)
	var far_target := StubTarget.new()
	far_target.position = Vector2(200, 0)  # far outside radius
	ah.add_child(far_target)
	await process_frame
	shell._explode()
	if in_target.damage_taken != shell.AOE_DAMAGE:
		push_error("FAIL — AoE did not damage in-radius target (got %d, want %d)" % [in_target.damage_taken, shell.AOE_DAMAGE])
		quit(1); return
	if far_target.damage_taken != 0:
		push_error("FAIL — AoE damaged out-of-radius target (got %d, want 0)" % far_target.damage_taken)
		quit(1); return
	print("  AoE damages in-radius (+%d), spares out-of-radius (0)" % in_target.damage_taken)
	ah.queue_free()

	print("BREACH_MORTAR_OK MORTAR Tank — lobbed shell + AoE on impact")
	quit(0)
