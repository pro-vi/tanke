# Arc-4 breach mode: enemy HP primitive + HP-bar verifier
# (Round 9a, iter 63). Verifies:
#   - a breach-mode Enemy with max_hp > 1 builds the HPBarBG/Fg nodes
#   - the bar is hidden at full HP, visible after take_damage, with the
#     fg width tracking the damage ratio
#   - an arc-2/3 Enemy (no breach_mode_enabled on the parent) builds
#     no HP bar
#   - an Enemy with max_hp = 1 doesn't build the bar (no damaged-alive
#     state possible)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hp.gd

extends SceneTree

const EnemyScene = preload("res://scenes/Enemy.tscn")


class StubBreachLevel extends Node2D:
	var breach_mode_enabled: bool = false


func _initialize() -> void:
	# === breach-mode enemy with max_hp=3 → HP bar exists, hidden at full hp.
	var lvl := StubBreachLevel.new()
	lvl.breach_mode_enabled = true
	root.add_child(lvl)
	var enemy: Node = EnemyScene.instantiate()
	enemy.max_hp = 3
	enemy.enemy_type = "Heavy"
	lvl.add_child(enemy)
	await process_frame
	var bg: ColorRect = enemy.get_node_or_null("HPBarBG") as ColorRect
	var fg: ColorRect = enemy.get_node_or_null("HPBarFG") as ColorRect
	if bg == null or fg == null:
		push_error("FAIL — breach-mode enemy did not build HP bar"); quit(1); return
	if bg.visible or fg.visible:
		push_error("FAIL — HP bar visible at full hp"); quit(1); return
	print("  HP bar built, hidden at full HP")

	# Take 1 damage → bar visible + fg ratio 2/3.
	enemy.take_damage(1)
	await process_frame
	if not bg.visible or not fg.visible:
		push_error("FAIL — HP bar not shown after damage"); quit(1); return
	var expect_w: float = enemy.HP_BAR_WIDTH * 2.0 / 3.0
	if abs(fg.size.x - expect_w) > 0.5:
		push_error("FAIL — HP bar width %.2f, want ≈%.2f (hp=%d/max=%d)" % [fg.size.x, expect_w, enemy.hp, enemy.max_hp])
		quit(1); return
	print("  HP bar shows damaged ratio (hp=%d/%d → %.1fpx of %.0f)" % [enemy.hp, enemy.max_hp, fg.size.x, enemy.HP_BAR_WIDTH])
	lvl.queue_free()
	await process_frame

	# === arc-2/3 enemy (no breach_mode) → no HP bar.
	var lvl2 := StubBreachLevel.new()
	lvl2.breach_mode_enabled = false
	root.add_child(lvl2)
	var enemy2: Node = EnemyScene.instantiate()
	enemy2.max_hp = 2  # arc-2 Heavy default
	enemy2.enemy_type = "Heavy"
	lvl2.add_child(enemy2)
	await process_frame
	if enemy2.get_node_or_null("HPBarBG") != null:
		push_error("FAIL — arc-2 enemy built HP bar (regression)"); quit(1); return
	print("  arc-2 enemy builds no HP bar")
	lvl2.queue_free()
	await process_frame

	# === breach-mode enemy with max_hp=1 → no HP bar.
	var lvl3 := StubBreachLevel.new()
	lvl3.breach_mode_enabled = true
	root.add_child(lvl3)
	var enemy3: Node = EnemyScene.instantiate()
	enemy3.max_hp = 1
	enemy3.enemy_type = "Light"
	lvl3.add_child(enemy3)
	await process_frame
	if enemy3.get_node_or_null("HPBarBG") != null:
		push_error("FAIL — max_hp=1 enemy built HP bar (no damaged-alive state)")
		quit(1); return
	print("  max_hp=1 enemy builds no HP bar")
	lvl3.queue_free()

	print("BREACH_HP_OK enemy HP primitive + bar gated on breach_mode + max_hp>1")
	quit(0)
