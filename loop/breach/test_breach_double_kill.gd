# Arc-4 breach mode: Enemy double-kill idempotency regression
# (P1-1 from code-review-iter-090.md, fixed in iter 090).
#
# Verifies: a same-frame second take_damage on an already-dying
# enemy does NOT re-emit killed. Without the guard, MORTAR AoE +
# RAM swing + beam tick overlap can double-emit and corrupt
# Spawner kill counts / XP / drops.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_double_kill.gd

extends SceneTree

const EnemyT = preload("res://scripts/Enemy.gd")
const EnemyScene = preload("res://scenes/Enemy.tscn")


func _initialize() -> void:
	# === Spawn an enemy, simulate it taking lethal damage twice
	# in the same physics frame.
	var holder := Node2D.new()
	root.add_child(holder)
	var enemy: Node = EnemyScene.instantiate()
	enemy.max_hp = 2
	holder.add_child(enemy)
	await process_frame

	# Listen for killed emissions. GDScript lambdas can't mutate
	# outer scope vars; use a mutable Array reference.
	var counter: Array = [0]
	enemy.killed.connect(func(): counter[0] += 1)

	# First damage source: 2 dmg → hp goes from 2 to 0 → killed emits.
	enemy.take_damage(2)
	if counter[0] != 1:
		push_error("FAIL — first lethal damage: kill_count %d, want 1" % counter[0])
		quit(1); return
	if enemy.hp != 0:
		push_error("FAIL — after lethal damage: hp %d, want 0" % enemy.hp)
		quit(1); return
	print("  first lethal damage: kill_count=1, hp=0 (killed emitted once)")

	# queue_free is deferred — enemy still in tree this frame.
	# Second damage source same frame: 2 dmg → idempotency guard
	# returns early, kill_count stays 1.
	enemy.take_damage(2)
	if counter[0] != 1:
		push_error("FAIL — second damage on dying enemy: kill_count %d, want 1 (double-kill bug recurred)" % counter[0])
		quit(1); return
	if enemy.hp != 0:
		push_error("FAIL — second damage modified hp: %d, want 0 (guard didn't early-return)" % enemy.hp)
		quit(1); return
	print("  second damage on dying enemy: kill_count still 1, hp unchanged (idempotency guard works)")

	# Third damage source same frame (defensive triple-check).
	enemy.take_damage(99)
	if counter[0] != 1:
		push_error("FAIL — third damage on dying enemy: kill_count %d, want 1" % counter[0])
		quit(1); return
	print("  triple damage on dying enemy: kill_count still 1 (no late re-emission)")

	# Allow deferred queue_free to run.
	await process_frame
	await process_frame
	print("  enemy queue_free'd cleanly after frame deferral")

	holder.queue_free()
	print("BREACH_DOUBLE_KILL_OK Enemy.take_damage idempotency holds — no double-kill on same-frame overlapping damage")
	quit(0)
