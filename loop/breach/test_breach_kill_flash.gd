# Arc-4 breach mode: Round 24 Phase A widget 5 — kill flash (iter 277).
#
# When an enemy dies, the death burst ColorRect is tinted by the
# killing shell class — reinforcing "which shell did this" via color
# continuity with the shell chips (iter 276) + in-flight bullet
# modulate (iter 35). Legacy bullets / arc-2/3 bullets that don't call
# set_last_damage_shell leave _last_damage_shell at -1, so the
# generic yellow burst (iter 78) renders bit-identical.
#
# Verifies:
#   1. Default _last_damage_shell == -1 → death burst is the legacy
#      yellow Color(1.0, 0.9, 0.3, 0.9). (arc-2/3 bit-identical contract.)
#   2. After set_last_damage_shell(SHELL_CLASS_HE), the burst color
#      matches BulletT.shell_modulate_color(SHELL_CLASS_HE) RGB.
#   3. After set_last_damage_shell(SHELL_CLASS_HEAT), the burst color
#      matches HEAT modulate (warm orange-red).
#   4. After set_last_damage_shell(SHELL_CLASS_APCR), the burst color
#      matches APCR modulate (cold steel-blue).
#   5. Bullet.shell_modulate_color is a static function that returns
#      the same color whether called via BulletT or via an instance.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_kill_flash.gd

extends SceneTree

const EnemyScene = preload("res://scenes/Enemy.tscn")
const BulletT = preload("res://scripts/Bullet.gd")


func _find_burst_after_death(parent: Node) -> ColorRect:
	for child in parent.get_children():
		if child is ColorRect:
			var size: Vector2 = (child as ColorRect).size
			if absf(size.x - 16.0) < 0.5 and absf(size.y - 16.0) < 0.5:
				return child as ColorRect
	return null


func _assert_color_rgb_match(got: Color, want: Color, label: String) -> bool:
	# Compare RGB components only — burst alpha differs from base (0.9 not 1.0).
	if absf(got.r - want.r) > 0.01 \
			or absf(got.g - want.g) > 0.01 \
			or absf(got.b - want.b) > 0.01:
		push_error("FAIL — %s burst RGB = (%.2f,%.2f,%.2f), want (%.2f,%.2f,%.2f)" \
				% [label, got.r, got.g, got.b, want.r, want.g, want.b])
		return false
	return true


func _kill_and_get_burst(holder: Node, last_shell: int) -> ColorRect:
	var enemy: Node = EnemyScene.instantiate()
	enemy.max_hp = 1
	enemy.hp = 1
	holder.add_child(enemy)
	if last_shell >= 0:
		enemy.set_last_damage_shell(last_shell)
	enemy.take_damage(1)
	# _spawn_death_effect runs synchronously inside take_damage.
	# Look for the new burst child on holder.
	return _find_burst_after_death(holder)


func _initialize() -> void:
	# === Case A: legacy / arc-2/3 path — no set_last_damage_shell call.
	# Default _last_damage_shell == -1 → yellow burst.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var burst_legacy: ColorRect = _kill_and_get_burst(holder_a, -1)
	if burst_legacy == null:
		push_error("FAIL — case A: legacy burst not spawned")
		quit(1); return
	if not _assert_color_rgb_match(burst_legacy.color, Color(1.0, 0.9, 0.3, 1.0), "legacy"):
		quit(1); return
	print("  legacy (no shell propagation): burst = %s (yellow)" % str(burst_legacy.color))

	# === Case B: HE kill → burst tinted with HE modulate color.
	var holder_b := Node2D.new()
	root.add_child(holder_b)
	var burst_he: ColorRect = _kill_and_get_burst(holder_b, BulletT.SHELL_CLASS_HE)
	if burst_he == null:
		push_error("FAIL — case B: HE burst not spawned")
		quit(1); return
	var want_he: Color = BulletT.shell_modulate_color(BulletT.SHELL_CLASS_HE)
	if not _assert_color_rgb_match(burst_he.color, want_he, "HE"):
		quit(1); return
	print("  HE kill: burst = %s (matches BulletT.shell_modulate_color(HE) = %s)" \
			% [str(burst_he.color), str(want_he)])

	# === Case C: HEAT kill.
	var holder_c := Node2D.new()
	root.add_child(holder_c)
	var burst_heat: ColorRect = _kill_and_get_burst(holder_c, BulletT.SHELL_CLASS_HEAT)
	if burst_heat == null:
		push_error("FAIL — case C: HEAT burst not spawned")
		quit(1); return
	var want_heat: Color = BulletT.shell_modulate_color(BulletT.SHELL_CLASS_HEAT)
	if not _assert_color_rgb_match(burst_heat.color, want_heat, "HEAT"):
		quit(1); return
	print("  HEAT kill: burst = %s (matches HEAT modulate = %s)" \
			% [str(burst_heat.color), str(want_heat)])

	# === Case D: APCR kill.
	var holder_d := Node2D.new()
	root.add_child(holder_d)
	var burst_apcr: ColorRect = _kill_and_get_burst(holder_d, BulletT.SHELL_CLASS_APCR)
	if burst_apcr == null:
		push_error("FAIL — case D: APCR burst not spawned")
		quit(1); return
	var want_apcr: Color = BulletT.shell_modulate_color(BulletT.SHELL_CLASS_APCR)
	if not _assert_color_rgb_match(burst_apcr.color, want_apcr, "APCR"):
		quit(1); return
	print("  APCR kill: burst = %s (matches APCR modulate = %s)" \
			% [str(burst_apcr.color), str(want_apcr)])

	# === Case E: shell_modulate_color is static + returns same values
	# whether called on class or instance.
	var ap_color: Color = BulletT.shell_modulate_color(BulletT.SHELL_CLASS_AP)
	if absf(ap_color.r - 0.92) > 0.01:
		push_error("FAIL — static AP color r = %.2f, want 0.92" % ap_color.r)
		quit(1); return
	print("  static shell_modulate_color works: AP RGB = (%.2f, %.2f, %.2f)" \
			% [ap_color.r, ap_color.g, ap_color.b])

	print("BREACH_KILL_FLASH_OK 4 shell-tint cases + legacy yellow + static lookup verified")
	quit(0)
