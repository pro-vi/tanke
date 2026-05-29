# arc-4 PR-#4 P1 review fix regression — MortarShell._explode used to
# AoE-damage the firing player (sibling of bricks/enemies under Level).
# Tap-fire a close target → self-hit; AOE_DAMAGE_UP cards make it worse.
#
# 3 cases:
#   1. Firing player (via lvl.player) NOT damaged when within AoE radius.
#   2. Player-group sibling NOT damaged when within AoE radius.
#   3. Non-player sibling WITHIN radius still takes damage (no overshoot).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_mortar_friendly_fire.gd

extends SceneTree

const MortarShellScene = preload("res://scenes/MortarShell.tscn")


class MockLevel extends Node2D:
	var player: MockTarget = null

	func _init() -> void:
		player = MockTarget.new()
		player.add_to_group("player")
		add_child(player)


class MockTarget extends Node2D:
	var dmg_taken: int = 0

	func take_damage(amount: int) -> void:
		dmg_taken += amount


func _explode_at(parent: Node, target: Vector2) -> Node:
	var shell = MortarShellScene.instantiate()
	shell.target_pos = target
	parent.add_child(shell)
	shell._explode()
	return shell


func _initialize() -> void:
	# === Case 1: firing player not damaged.
	var lvl1 := MockLevel.new()
	root.add_child(lvl1)
	await process_frame
	lvl1.player.position = Vector2(8, 0)  # within default AOE_RADIUS=18
	_explode_at(lvl1, Vector2(0, 0))
	if lvl1.player.dmg_taken != 0:
		push_error("FAIL — firing player took %d MORTAR AoE damage (want 0)" % lvl1.player.dmg_taken)
		quit(1); return
	print("  case 1: firing player not damaged by MORTAR AoE (lvl.player ref skip)")

	# === Case 2: player-group sibling not damaged.
	var lvl2 := MockLevel.new()
	root.add_child(lvl2)
	await process_frame
	lvl2.player.position = Vector2(999, 999)
	var second_player := MockTarget.new()
	second_player.add_to_group("player")
	second_player.position = Vector2(8, 0)
	lvl2.add_child(second_player)
	await process_frame
	_explode_at(lvl2, Vector2(0, 0))
	if second_player.dmg_taken != 0:
		push_error("FAIL — player-group sibling took %d MORTAR AoE (want 0)" % second_player.dmg_taken)
		quit(1); return
	print("  case 2: player-group sibling not damaged (group filter)")

	# === Case 3: non-player sibling within radius DOES take damage.
	var lvl3 := MockLevel.new()
	root.add_child(lvl3)
	await process_frame
	lvl3.player.position = Vector2(999, 999)
	var enemy := MockTarget.new()  # NOT in "player" group
	enemy.position = Vector2(8, 0)
	lvl3.add_child(enemy)
	await process_frame
	_explode_at(lvl3, Vector2(0, 0))
	# Default AOE_DAMAGE = 2.
	if enemy.dmg_taken < 2:
		push_error("FAIL — enemy within AoE took only %d damage (want >=2 AOE_DAMAGE default)" % enemy.dmg_taken)
		quit(1); return
	print("  case 3: non-player sibling within radius takes AoE damage (no overshoot of filter)")

	print("BREACH_MORTAR_FRIENDLY_FIRE_OK 3 cases — MORTAR AoE friendly-fire skip")
	quit(0)
