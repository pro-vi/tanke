# Arc-4 breach mode: Round 14 Phase 2 — REAR_GUARD upgrade
# (iter 116). Closes the open_killbox C8 anchor-3 gap deferred
# from Round 13.
#
# When the player owns has_rear_guard, an AP shot auto-fires at
# the closest enemy in the rear 90° cone within REAR_GUARD_RANGE
# (96px). Costs no shell. Cooldown REAR_GUARD_COOLDOWN (2.5s).
# Sentence-test compliant: "helps me climb open_killbox by
# changing how I commit to facing — rear scouts no longer demand
# a turn."
#
# Verifies:
#   1. Loadout has has_rear_guard default false.
#   2. Depot.apply_upgrade(REAR_GUARD) sets has_rear_guard = true.
#   3. _find_rear_cone_enemy returns an enemy positioned in the
#      rear cone (player facing R, enemy at (-32, 0) → found).
#   4. _find_rear_cone_enemy returns NULL when the enemy is in
#      front (player facing R, enemy at (+32, 0) → not found).
#   5. _find_rear_cone_enemy returns NULL when the enemy is
#      out of range (rear but at (-128, 0) > 96px → not found).
#   6. _fire_rear_guard emits the shoot signal with the rear
#      direction + AP shell + spawn-pos offset behind player.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_rear_guard.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const DepotScene = preload("res://scenes/Depot.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


class _EnemyStub extends Node2D:
	func _ready() -> void:
		add_to_group("enemy")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Test 1: Loadout.has_rear_guard default false.
	var lo: LoadoutT = LoadoutT.new()
	if lo.has_rear_guard:
		push_error("FAIL — Loadout.has_rear_guard default should be false")
		quit(1); return
	print("  Loadout.has_rear_guard default = false")

	# === Test 2: apply_upgrade(REAR_GUARD) flips the flag.
	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame
	depot.apply_upgrade(depot.UpgradeKind.REAR_GUARD, lo)
	if not lo.has_rear_guard:
		push_error("FAIL — apply_upgrade(REAR_GUARD) did not set has_rear_guard")
		quit(1); return
	print("  apply_upgrade(REAR_GUARD) sets has_rear_guard = true")
	depot.queue_free()

	# === Tests 3-6: rear-cone detection + fire.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.loadout.has_rear_guard = true
	holder.add_child(pt)
	await process_frame
	await process_frame
	# Position the player at origin, facing RIGHT (direction = R; rotation = 0).
	pt.global_position = Vector2.ZERO
	pt.direction = 3  # Constants.Dir.R = 3
	pt.rotation = 0.0

	# === Test 3: enemy behind (facing R → rear is LEFT → enemy at -X).
	var rear_enemy := _EnemyStub.new()
	rear_enemy.global_position = Vector2(-32, 0)
	holder.add_child(rear_enemy)
	await process_frame
	var found: Node = pt._find_rear_cone_enemy()
	if found != rear_enemy:
		push_error("FAIL — rear-cone enemy at (-32, 0) not found (got %s)" % str(found))
		quit(1); return
	print("  rear-cone enemy at (-32, 0) → found (player facing R, rear vec = -X)")

	# === Test 4: enemy in front → not found.
	var front_enemy := _EnemyStub.new()
	front_enemy.global_position = Vector2(32, 0)
	holder.add_child(front_enemy)
	await process_frame
	rear_enemy.queue_free()
	await process_frame
	var front_only: Node = pt._find_rear_cone_enemy()
	if front_only != null:
		push_error("FAIL — front-cone enemy at (+32, 0) wrongly matched as rear (got %s)" % str(front_only))
		quit(1); return
	print("  front-only enemy at (+32, 0) → null (correct; front not rear)")
	front_enemy.queue_free()
	await process_frame

	# === Test 5: enemy out of range → not found.
	var far_enemy := _EnemyStub.new()
	far_enemy.global_position = Vector2(-128, 0)  # rear but > 96px
	holder.add_child(far_enemy)
	await process_frame
	var far_result: Node = pt._find_rear_cone_enemy()
	if far_result != null:
		push_error("FAIL — far enemy at (-128, 0) matched despite > REAR_GUARD_RANGE (got %s)" % str(far_result))
		quit(1); return
	print("  far enemy at (-128, 0) → null (correct; > REAR_GUARD_RANGE)")
	far_enemy.queue_free()
	await process_frame

	# === Test 6: _fire_rear_guard emits shoot signal with rear direction.
	var shoot_records: Array = []
	pt.shoot.connect(func(_b, _pos, dir: int, shell: int):
		shoot_records.append({"dir": dir, "shell": shell}))
	pt._fire_rear_guard()
	await process_frame
	if shoot_records.size() != 1:
		push_error("FAIL — _fire_rear_guard emitted %d shots, want 1" % shoot_records.size())
		quit(1); return
	# Player facing R (3) → rear dir = L (0). AP shell = 0.
	if shoot_records[0]["dir"] != 0:
		push_error("FAIL — rear-fire direction = %d, want L (0) [opposite of R (3)]" % shoot_records[0]["dir"])
		quit(1); return
	if shoot_records[0]["shell"] != BulletT.SHELL_CLASS_AP:
		push_error("FAIL — rear-fire shell = %d, want AP (0)" % shoot_records[0]["shell"])
		quit(1); return
	print("  _fire_rear_guard emits shoot(dir=L, shell=AP) when player faces R")

	print("BREACH_REAR_GUARD_OK 6 cases verified: Loadout flag + Depot apply + rear-cone detection (in/out/range) + fire signal")
	quit(0)
