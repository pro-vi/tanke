# Arc-4 breach reachability oracle (PROMPT §REACHABILITY FLOOR).
#
# Pure-data generation: replicates ProceduralLevel's row-generation loop
# (ProceduralStep + per-band LevelConfig sampling) WITHOUT instantiating
# the scene or any BrickBlock nodes — fast (<1s) and deterministic.
#
# Reachability model = the arc-1/2/3 precedent: *local* first-screen
# traversability. test_runner.gd checks "can the player climb >= 10
# tile-rows in the starting area treating brick/steel/water as walls".
# A single global flood-fill across 120 depth rows is the WRONG model —
# no 120-row stochastic stretch is brick-corridor-clear, and the player
# is *expected* to shoot through brick. So each breach band is checked
# the way arc-2 checks its start: generate ~START_DEPTH rows of that
# band's config, flood-fill from spawn, require >= MIN_ROWS_CLIMBED.
#
# Mirrors: ProceduralLevel._generate_next_row_for / _pave_set /
# _active_config; flood-fill mirrors test_runner.gd:_collect.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_harness.gd -- --seed 42
#   godot --headless --path . --script res://loop/breach/test_breach_harness.gd -- --seed 42 --deep

extends SceneTree

const ProceduralStepT = preload("res://scripts/ProceduralStep.gd")
const BreachConfigT = preload("res://scripts/BreachConfig.gd")
const LevelConfigT = preload("res://scripts/LevelConfig.gd")
const BREACH_CONFIG_PATH := "res://configs/breach_default.tres"

const GRID_SIZE := 16
const VIEWPORT_W := 320
const VIEWPORT_H := 240
const CELLS_PER_ROW := VIEWPORT_W / GRID_SIZE   # 20
const START_ROW := VIEWPORT_H / GRID_SIZE       # 15
const BAND_TEST_DEPTH := 22    # rows generated per band's local check
const MIN_ROWS_CLIMBED := 10   # tile-rows; matches test_runner.gd


func _initialize() -> void:
	var test_seed := 42
	var deep := false
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seed" and i + 1 < args.size():
			test_seed = int(args[i + 1])
		elif args[i] == "--deep":
			deep = true

	var cfg: BreachConfigT = load(BREACH_CONFIG_PATH)
	if cfg == null:
		print("BREACH_HARNESS_FAIL could not load breach_default.tres")
		quit(1); return
	if cfg.bands.is_empty():
		print("BREACH_HARNESS_FAIL breach_config has no bands")
		quit(1); return

	if deep:
		_check_all_bands(cfg, test_seed)
	else:
		# Shallow: band 1 only (fast smoke check).
		var rc := _band_reachability(cfg.bands[0], test_seed)
		print("=== breach reachability oracle (shallow) ===")
		print("seed: %d  band: %s  rows_climbed: %d" % [test_seed, cfg.bands[0].band_name, rc])
		if rc >= MIN_ROWS_CLIMBED:
			print("BREACH_HARNESS_OK playable=true rows_climbed=%d" % rc)
			quit(0)
		else:
			print("BREACH_HARNESS_FAIL playable=false rows_climbed=%d" % rc)
			quit(1)


func _check_all_bands(cfg: BreachConfigT, test_seed: int) -> void:
	print("=== breach reachability oracle (per-band) ===")
	print("seed: %d" % test_seed)
	var all_ok := true
	for band in cfg.bands:
		var rc := _band_reachability(band, test_seed)
		var ok: bool = rc >= MIN_ROWS_CLIMBED
		print("  band %-16s [%3d..%3d]  rows_climbed=%-3d  %s" % [
			band.band_name, band.depth_min, band.depth_max, rc,
			"reachable" if ok else "BLOCKED"
		])
		if not ok:
			all_ok = false
	if all_ok:
		print("BREACH_HARNESS_OK all %d bands locally reachable" % cfg.bands.size())
		quit(0)
	else:
		print("BREACH_HARNESS_FAIL a band failed local reachability")
		quit(1)


# Local reachability for one band: generate BAND_TEST_DEPTH rows using
# THIS band's level_config for every row (as if the player were dropped
# into the band), flood-fill from spawn, return tile-rows climbed.
func _band_reachability(band, test_seed: int) -> int:
	var lc: LevelConfigT = band.level_config
	if lc == null:
		lc = LevelConfigT.new()
	var grid: Dictionary = _generate_flat(lc, test_seed)
	return _flood_fill_rows(grid)


# Replicate ProceduralLevel generation with a single flat LevelConfig
# (one band). Skips row START_ROW-1 (the guaranteed-clear spawn row, per
# ProceduralLevel._ready). Returns grid: Vector2i(tile) -> terrain.
func _generate_flat(lc: LevelConfigT, test_seed: int) -> Dictionary:
	seed(test_seed)
	var grid: Dictionary = {}
	var ps = ProceduralStepT.new(CELLS_PER_ROW, 0, lc.merge_probability)
	var verts: Dictionary = ps.generate_step()
	for row in range(START_ROW, START_ROW - BAND_TEST_DEPTH, -1):
		if row == START_ROW - 1:
			continue  # guaranteed-clear spawn row
		ps = ProceduralStepT.new(CELLS_PER_ROW, ps.set_count, lc.merge_probability)
		for sid in verts:
			for c in verts[sid]:
				ps.add_cell(c, sid)
		verts = ps.generate_step()
		for sid in ps.sets:
			var terrain: String = lc.sample_terrain()
			if terrain == "":
				continue
			for c in ps.sets[sid]:
				grid[Vector2i(c * 2, row * 2)] = terrain
				grid[Vector2i(c * 2 + 1, row * 2)] = terrain
				grid[Vector2i(c * 2, row * 2 + 1)] = terrain
				grid[Vector2i(c * 2 + 1, row * 2 + 1)] = terrain
	return grid


# Flood-fill from the spawn tile; return tile-rows climbed above spawn.
# Passable = empty OR grass/ice. Bounded to the generated region.
func _flood_fill_rows(grid: Dictionary) -> int:
	var spawn := Vector2i(160 / 8, 232 / 8)  # (20, 29)
	var map_w: int = VIEWPORT_W / 8          # 40
	var min_tile_y: int = (START_ROW - BAND_TEST_DEPTH + 1) * 2
	var max_tile_y: int = START_ROW * 2 + 1
	var reach: Dictionary = {}
	var q: Array = [spawn]
	while not q.is_empty():
		var cur: Vector2i = q.pop_back()
		if reach.has(cur):
			continue
		if cur.x < 0 or cur.x >= map_w:
			continue
		if cur.y < min_tile_y or cur.y > max_tile_y:
			continue
		if grid.has(cur) and grid[cur] != "grass" and grid[cur] != "ice":
			continue
		reach[cur] = true
		q.push_back(Vector2i(cur.x + 1, cur.y))
		q.push_back(Vector2i(cur.x - 1, cur.y))
		q.push_back(Vector2i(cur.x, cur.y + 1))
		q.push_back(Vector2i(cur.x, cur.y - 1))
	var min_row: int = spawn.y
	for cell in reach:
		if cell.y < min_row:
			min_row = cell.y
	return spawn.y - min_row
