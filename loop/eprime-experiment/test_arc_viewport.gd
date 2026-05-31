extends SceneTree

# Regression guard for PR#5 Codex P2 — arc-scoped camera-rect enemy bounds.
# Stands up the REAL BreachLevel headless, lets the bottom-clamped camera settle,
# then asserts that ObservationBuilder.build() bounds enemy visibility by the LIVE
# camera rect (not the player-centered box). Without the fix the arc camera is
# BOTTOM-CLAMPED (ProceduralLevel limit_bottom=240, player start y=232), so a
# top-of-screen enemy >15 tiles above the player is on-screen yet dropped — this
# test's "top-of-screen enemy is visible" case fails on the pre-fix code (teeth).
#
# Emits `ARC_VIEWPORT_OK` on full pass; quit(1) otherwise.

const BREACH := preload("res://scenes/BreachLevel.tscn")
const CELL_PX := 8.0
const OLD_HALF_X := 20   # the pre-fix player-centered box half-extents
const OLD_HALF_Y := 15


func _initialize() -> void:
	OS.set_environment("TANKE_SEED", "1234")
	seed(1234)
	var level: Node = BREACH.instantiate()
	var pre: Node = level.get_node_or_null("PlayerTank")
	if pre != null:
		pre.set("force_archetype_select", false)  # skip the archetype modal before _ready
	get_root().add_child(level)
	# let position_smoothing converge to the bottom clamp (no driver -> player is still)
	for _i in 120:
		await process_frame

	var failures: int = 0
	var player: Node = level.get_node_or_null("PlayerTank")
	if player == null:
		print("ARC_VIEWPORT_FAIL no PlayerTank"); quit(1); return

	var vp := get_root()
	var cam: Camera2D = vp.get_camera_2d()
	failures += _expect("active Camera2D resolves headless", cam != null)
	if cam == null:
		print("ARC_VIEWPORT_FAIL no camera"); quit(1); return

	var ppos: Vector2 = player.global_position
	var center: Vector2 = cam.get_screen_center_position()
	var size: Vector2 = vp.get_visible_rect().size / cam.zoom
	var view_rect := Rect2(center - size * 0.5, size).grow(CELL_PX)
	# premise: the camera cannot follow the player to the bottom, so it sits ABOVE
	# the player and the player is in the lower screen (top of screen >15 tiles up).
	failures += _expect("arc camera is bottom-clamped (center.y < player.y)", center.y < ppos.y)

	# An enemy at the TOP of the live screen, same column as the player: genuinely
	# on-screen, but far enough up that the old per-axis box would have dropped it.
	var top_pos := Vector2(ppos.x, view_rect.position.y + 12.0)
	var top_tile := _tile(top_pos)
	var dy: int = absi(top_tile.y - _tile(ppos).y)
	failures += _expect("top-of-screen enemy is outside the old |dy|<=15 box (has teeth)", dy > OLD_HALF_Y)

	# An enemy ABOVE the visible screen: off-camera, must stay excluded (the bound
	# is a real rect, not "include everything").
	var off_pos := Vector2(ppos.x, view_rect.position.y - 40.0)

	_spawn_enemy(level, top_pos)
	_spawn_enemy(level, off_pos)
	await process_frame

	var obs = ObservationBuilder.build(player, level, 0, 1.0)
	var tiles := {}
	for ve in obs.visible_enemies:
		tiles[ve.get("pos_tile")] = true
	# THE FIX: the on-screen top enemy is surfaced by the live build path.
	failures += _expect("top-of-screen enemy IS in visible_enemies (the fix)", tiles.has(top_tile))
	# The off-screen enemy is not.
	failures += _expect("above-screen enemy is NOT in visible_enemies", not tiles.has(_tile(off_pos)))

	if failures == 0:
		print("ARC_VIEWPORT_OK")
		quit(0)
	else:
		print("ARC_VIEWPORT_FAIL %d failures" % failures)
		quit(1)


func _tile(world: Vector2) -> Vector2i:
	return Vector2i(roundi(world.x / CELL_PX), roundi(world.y / CELL_PX))


func _spawn_enemy(level: Node, pos: Vector2) -> void:
	var e := Node2D.new()
	level.add_child(e)
	e.global_position = pos
	e.add_to_group("enemy")  # group "enemy" is ObservationBuilder's enemy source


func _expect(desc: String, cond: bool) -> int:
	if cond:
		print("  case %s OK" % desc)
		return 0
	print("  FAIL — case: %s" % desc)
	return 1
