# Arc-4 breach mode: HEAT armor-bypass verifier (C3 anchor 3).
# Verifies the iter-23 armor rule (CONSULT 002): bodies in the
# "armored" group take ARMOR_MITIGATION less damage from AP + HE;
# HEAT ignores armor. Non-armored bodies take full damage from all 3.
#
# Drives Bullet._on_body_entered directly against stub bodies that
# track take_damage calls (the arc-3 harness pattern).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_armor.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")


class StubTarget extends Node2D:
	var damage_taken: int = 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


func _initialize() -> void:
	# Each case: (shell_class, armored?, expected damage on the stub).
	# Bullet @export damage defaults to 1. HEAT deals 2x. ARMOR_MITIGATION
	# is 1 → armored AP/HE: max(0, 1-1) = 0; armored HEAT: 2 (bypass).
	var cases := [
		[BulletT.SHELL_CLASS_AP, false, 1, "AP vs unarmored"],
		[BulletT.SHELL_CLASS_HE, false, 1, "HE vs unarmored"],
		[BulletT.SHELL_CLASS_HEAT, false, 2, "HEAT vs unarmored"],
		[BulletT.SHELL_CLASS_AP, true, 0, "AP vs armored (blocked)"],
		[BulletT.SHELL_CLASS_HE, true, 0, "HE vs armored (blocked)"],
		[BulletT.SHELL_CLASS_HEAT, true, 2, "HEAT vs armored (bypass)"],
	]
	for c in cases:
		var shell: int = c[0]
		var armored: bool = c[1]
		var expect: int = c[2]
		var label: String = c[3]

		var stub := StubTarget.new()
		if armored:
			stub.add_to_group("armored")
		var bullet: Node = BulletScene.instantiate()
		root.add_child(bullet)
		root.add_child(stub)
		await process_frame
		bullet.shell_class = shell
		bullet._on_body_entered(stub)
		await process_frame

		if stub.damage_taken != expect:
			push_error("FAIL — %s: damage = %d, want %d" % [label, stub.damage_taken, expect])
			quit(1); return
		print("  %s — damage=%d" % [label, stub.damage_taken])
		stub.queue_free()

	print("BREACH_ARMOR_OK AP/HE blocked vs armored; HEAT bypasses")
	quit(0)
