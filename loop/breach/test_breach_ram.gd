# Arc-4 breach mode: RAM Tank verifier (Round 9e, iter 67).
# Verifies:
#   - archetype=RAM bumps base speed (+RAM_SPEED_BONUS over the default)
#   - _ram_swing damages a forward in-range sibling; spares a behind
#     sibling AND a far (forward but out-of-range) sibling
#   - the swing uses take_damage on any sibling (enemy / brick / etc.)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_ram.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


class StubTarget extends Node2D:
	var damage_taken: int = 0
	func take_damage(amount: int) -> void:
		damage_taken += amount


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt)
	await process_frame
	await process_frame  # iter-50 deferred RoutePanel build

	# === RAM gets a speed bonus (faster base movement).
	if pt.speed <= 32:
		push_error("FAIL — RAM speed = %d, want > 32 (base + RAM_SPEED_BONUS)" % pt.speed)
		quit(1); return
	print("  RAM speed: %d (base 32 + %d bonus)" % [pt.speed, pt.RAM_SPEED_BONUS])

	# === _ram_swing: damage forward-in-range; spare behind + far.
	pt.global_position = Vector2(0, 0)
	pt.rotation = 0.0  # facing +X
	var forward := StubTarget.new()
	forward.position = Vector2(10, 0)  # in front, within RAM_SWING_RANGE (18)
	holder.add_child(forward)
	var behind := StubTarget.new()
	behind.position = Vector2(-10, 0)  # behind
	holder.add_child(behind)
	var far := StubTarget.new()
	far.position = Vector2(100, 0)  # in front but out of range
	holder.add_child(far)
	await process_frame

	pt._ram_swing()
	if forward.damage_taken != pt.RAM_SWING_DAMAGE:
		push_error("FAIL — swing missed forward target (got %d, want %d)" % [forward.damage_taken, pt.RAM_SWING_DAMAGE])
		quit(1); return
	if behind.damage_taken != 0:
		push_error("FAIL — swing hit behind target (got %d, want 0)" % behind.damage_taken)
		quit(1); return
	if far.damage_taken != 0:
		push_error("FAIL — swing hit out-of-range target (got %d, want 0)" % far.damage_taken)
		quit(1); return
	print("  swing: forward +%d, behind 0, far 0 (forward-cone + range gate works)" % forward.damage_taken)

	holder.queue_free()
	print("BREACH_RAM_OK RAM speed bonus + forward swing")
	quit(0)
