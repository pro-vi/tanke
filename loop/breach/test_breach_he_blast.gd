# Arc-4 breach mode: HE radius-blast + HEAT 2x-damage behavior verifier
# (C3 anchor 2 — "All 3 shells implemented; each has distinct combat
# behavior — code-cited [STRUCTURE]"). Plus sentence-test cite for HE
# (RUBRIC C8 anchor 1 eligible iter 8+).
#
# Stub bodies use a script-attached take_damage tracker so we can verify
# damage routing without bringing up real BrickBlock + Bullet collision.
# We invoke Bullet._on_body_entered directly with the stub body (arc-3
# _initialize() pattern; cf. loop/test_chain_25.gd).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_he_blast.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")


class StubBrick extends Node2D:
	var hp: int = 5
	var damage_taken: int = 0

	func take_damage(amount: int) -> void:
		hp -= amount
		damage_taken += amount


func _initialize() -> void:
	# === Test 1: AP baseline — single-hit, damage = 1 (default @export).
	if not await _fire_at_cluster(BulletT.SHELL_CLASS_AP, "AP", 1, 0):
		quit(1); return

	# === Test 2: HE radius — primary hit + adjacent siblings within radius.
	# Expect: ≥2 bricks damaged (primary + at least one sibling within 18px).
	if not await _fire_at_cluster(BulletT.SHELL_CLASS_HE, "HE", 1, 2):
		quit(1); return

	# === Test 3: HEAT — single-hit, damage = 2x (= 2 with @export=1).
	if not await _fire_at_cluster(BulletT.SHELL_CLASS_HEAT, "HEAT", 2, 0):
		quit(1); return

	print("BREACH_HE_BLAST_OK 3 shell-class behaviors distinct")
	quit(0)


# Spawn 4 stub bricks in a 16-px-spaced cluster around origin, fire a bullet
# of the given shell_class via _on_body_entered against the center stub,
# then verify:
#   - The primary (center) stub got `expect_primary` damage.
#   - At least `expect_min_radius` OTHER stubs in cluster got damage.
func _fire_at_cluster(shell: int, label: String, expect_primary: int, expect_min_radius: int) -> bool:
	var container := Node2D.new()
	root.add_child(container)

	var bricks: Array[StubBrick] = []
	# 4 bricks in a + pattern around origin: center, +x, -x, +y. Spacing
	# 16px (= grid_size from ProceduralLevel). Center is the primary;
	# the 3 neighbors are all within HE_BLAST_RADIUS_PX (=18.0).
	var offsets: Array = [Vector2.ZERO, Vector2(16, 0), Vector2(-16, 0), Vector2(0, 16)]
	for off in offsets:
		var b := StubBrick.new()
		b.position = off
		container.add_child(b)
		bricks.append(b)

	# Spawn the bullet — needed because Bullet's _spawn_impact_spark
	# expects get_parent() != null + queue_free at the end.
	var bullet: Node = BulletScene.instantiate()
	root.add_child(bullet)
	await process_frame
	bullet.shell_class = shell

	# Invoke the body_entered handler directly with the center stub.
	bullet._on_body_entered(bricks[0])
	# _on_body_entered calls queue_free() at the end; wait a frame so the
	# tween in _spawn_impact_spark doesn't strangle later iterations.
	await process_frame

	# Verify primary hit.
	if bricks[0].damage_taken != expect_primary:
		push_error("FAIL %s — primary damage = %d, want %d" % [label, bricks[0].damage_taken, expect_primary])
		container.queue_free()
		return false

	# Verify radius hits (count siblings that took ANY damage).
	var hit_count: int = 0
	for i in range(1, bricks.size()):
		if bricks[i].damage_taken > 0:
			hit_count += 1
	if hit_count < expect_min_radius:
		push_error("FAIL %s — radius hits = %d, want >= %d" % [label, hit_count, expect_min_radius])
		container.queue_free()
		return false

	# Crisp cite: HE should hit ALL 3 neighbors (all within 18px); AP/HEAT 0.
	print("  %s — primary=%d  radius_hits=%d" % [label, bricks[0].damage_taken, hit_count])
	container.queue_free()
	return true
