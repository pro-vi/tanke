# Arc-4 breach reachability oracle (PROMPT §REACHABILITY FLOOR).
# Instantiates scenes/BreachLevel.tscn at a fixed seed, lets the
# generator run, then flood-fills from the player spawn to confirm the
# breach-mode procedural layout is playable (rows_climbed >= MIN).
#
# Iter 11 scope: covers the region the generator produces in
# FRAMES_TO_STEP frames without player input — that is band 1
# (tutorial_choke). A deeper multi-band climb-sim is iter-12 CAPABILITY
# work; for now this proves band 1's terrain config does not produce an
# impassable spawn area.
#
# Flood-fill logic mirrors loop/test_runner.gd:_collect (lines 245-296)
# — the arc-1/2/3 reachability oracle. Kept as a separate file per
# PROMPT §SUBSTRATE FREEZE ("loop/test_runner.gd — extend, never
# refactor"); this harness is arc-4-owned.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_harness.gd -- --seed 42 --json

extends SceneTree

const BreachLevelScene = preload("res://scenes/BreachLevel.tscn")
const FRAMES_TO_STEP := 30
const MIN_ROWS_CLIMBED := 10


func _initialize() -> void:
	var test_seed := 42
	var json_output := false
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seed" and i + 1 < args.size():
			test_seed = int(args[i + 1])
		elif args[i] == "--json":
			json_output = true

	var level: Node = BreachLevelScene.instantiate()
	level.level_seed = test_seed
	root.add_child(level)
	for i in FRAMES_TO_STEP:
		await process_frame

	var report := _reachability(level)
	report["seed"] = test_seed
	report["breach_mode"] = level.breach_mode_enabled

	if json_output:
		print(JSON.stringify(report))
	else:
		print("=== breach reachability oracle ===")
		print("seed: %d  breach_mode: %s" % [test_seed, str(level.breach_mode_enabled)])
		print("reachable: %d cells  rows_climbed: %d  playable: %s" % [
			report.reachable_cells, report.rows_climbed, str(report.playable)
		])
		print("terrain cells: steel=%d grass=%d brick_bodies=%d" % [
			report.steel, report.grass, report.brick_bodies
		])

	if report.playable:
		print("BREACH_HARNESS_OK playable=true rows_climbed=%d" % report.rows_climbed)
		quit(0)
	else:
		print("BREACH_HARNESS_FAIL playable=false rows_climbed=%d" % report.rows_climbed)
		quit(1)


# Flood-fill reachability over the breach-generated grid. Mirrors
# test_runner.gd:_collect — passable = empty OR grass/ice (no collision);
# impassable = brick/steel/water.
func _reachability(level: Node) -> Dictionary:
	var grid: Dictionary = {}
	var steel: int = level.steelTileMap.get_used_cells().size()
	var grass: int = level.grassTileMap.get_used_cells().size()
	for cell in level.steelTileMap.get_used_cells():
		grid[Vector2i(cell.x, cell.y)] = "steel"
	for cell in level.grassTileMap.get_used_cells():
		grid[Vector2i(cell.x, cell.y)] = "grass"
	var brick_bodies: int = 0
	for child in level.get_children():
		if child is StaticBody2D:
			if child.name == "Eagle":
				continue
			var col: int = int(child.position.x / 8)
			var row: int = int(child.position.y / 8)
			if child.has_node("Sprite2D"):
				grid[Vector2i(col, row)] = "brick"
				brick_bodies += 1
			elif child.has_node("AnimatedSprite2D"):
				grid[Vector2i(col, row)] = "water"

	var spawn_px: Vector2 = level.player.global_position
	var spawn_tile := Vector2i(int(spawn_px.x) / 8, int(spawn_px.y) / 8)
	var map_w: int = int(level.width) / 8
	var map_h: int = int(level.height) / 8

	var reach: Dictionary = {}
	var q: Array = [spawn_tile]
	while not q.is_empty():
		var cur: Vector2i = q.pop_back()
		if reach.has(cur):
			continue
		if cur.x < 0 or cur.x >= map_w or cur.y < 0 or cur.y >= map_h:
			continue
		if grid.has(cur) and grid[cur] != "grass" and grid[cur] != "ice":
			continue
		reach[cur] = true
		q.push_back(Vector2i(cur.x + 1, cur.y))
		q.push_back(Vector2i(cur.x - 1, cur.y))
		q.push_back(Vector2i(cur.x, cur.y + 1))
		q.push_back(Vector2i(cur.x, cur.y - 1))

	var min_row: int = map_h
	for cell in reach:
		if cell.y < min_row:
			min_row = cell.y
	var rows_climbed: int = spawn_tile.y - min_row
	return {
		"reachable_cells": reach.size(),
		"rows_climbed": rows_climbed,
		"playable": rows_climbed >= MIN_ROWS_CLIMBED,
		"steel": steel,
		"grass": grass,
		"brick_bodies": brick_bodies,
	}
