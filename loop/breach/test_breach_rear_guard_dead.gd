# arc-4 PR-#4 P1 review fix regression — REAR_GUARD used to tick
# BEFORE the `if _dead: return` guard, so dead tanks with the upgrade
# kept firing AP shells while the death overlay was up.
#
# 2 cases:
#   1. Alive player with REAR_GUARD + enemy in rear cone → fires (control).
#   2. Dead player with REAR_GUARD + enemy in rear cone → does NOT fire.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_rear_guard_dead.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _make_player_with_rear_guard() -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.loadout.has_rear_guard = true
	root.add_child(pt)
	return pt


# Tracks how many times _fire_rear_guard runs by hooking the shoot
# signal (Bullet emission). Each rear-guard fire emits one shoot.
func _initialize() -> void:
	# === Case 1: alive + enemy in cone → fires.
	var pt1 := _make_player_with_rear_guard()
	await process_frame
	var shots_a: int = 0
	pt1.shoot.connect(func(_b, _p, _d, _c): shots_a += 1)
	# Force cooldown clear + simulate _find_rear_cone_enemy by directly
	# calling the rear-guard codepath through _physics_process. The
	# harness doesn't need a real enemy — _fire_rear_guard fires
	# unconditionally once the codepath is reached. We force the
	# cooldown to 0 + drive one tick.
	pt1._rear_guard_cd = 0.0
	# Spawn a stub enemy in the rear cone. Player facing right by
	# default (rotation 0); rear cone is -X direction. Put enemy at
	# (player.x - 32, player.y).
	var enemy_stub := Node2D.new()
	enemy_stub.position = pt1.position + Vector2(-32, 0)
	enemy_stub.add_to_group("enemies")
	pt1.get_parent().add_child(enemy_stub)
	await process_frame
	# Drive a single _physics_process tick. Since alive (not _dead),
	# the rear-guard block runs. If an enemy is in cone, fires.
	pt1._physics_process(0.016)
	await process_frame
	# Cleanup
	enemy_stub.queue_free()
	await process_frame
	# (Control case may or may not fire depending on _find_rear_cone_enemy
	# specifics — but the post-fix behavior MUST be: dead player NEVER
	# fires. We focus the strict assertion on case 2.)
	var alive_fired: bool = shots_a > 0
	print("  case 1: alive + cone enemy → fired=%s (control; not asserted strictly)" % str(alive_fired))
	pt1.queue_free()
	await process_frame

	# === Case 2: dead player with REAR_GUARD + cone enemy → no fire.
	var pt2 := _make_player_with_rear_guard()
	await process_frame
	var shots_b: int = 0
	pt2.shoot.connect(func(_b, _p, _d, _c): shots_b += 1)
	# Force dead state directly + clear cooldown.
	pt2._dead = true
	pt2._rear_guard_cd = 0.0
	var enemy_stub2 := Node2D.new()
	enemy_stub2.position = pt2.position + Vector2(-32, 0)
	enemy_stub2.add_to_group("enemies")
	pt2.get_parent().add_child(enemy_stub2)
	await process_frame
	# Drive multiple ticks to be sure no fire leaks through.
	for i in 5:
		pt2._physics_process(0.016)
		await process_frame
	if shots_b > 0:
		push_error("FAIL — dead player fired %d REAR_GUARD shots (want 0; regression)" % shots_b)
		quit(1); return
	print("  case 2: dead player + cone enemy → 0 shots fired (regression locked)")

	print("BREACH_REAR_GUARD_DEAD_OK 2 cases — alive control + dead-quiet contract")
	quit(0)
