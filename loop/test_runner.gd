extends SceneTree

const ProceduralLevelScene = preload("res://scenes/ProceduralLevel.tscn")
const LevelDNAT = preload("res://scripts/LevelDNA.gd")
const FRAMES_TO_STEP := 30
const DEFAULT_SEED := 42


func _initialize() -> void:
	var test_seed := DEFAULT_SEED
	var config_path := ""
	var dna_path := ""
	var roundtrip_path := ""
	var biome_path := ""
	var scene_path := ""           # iter 001 (arc 3): --scene PATH for OG-mode oracle
	var og_stage := -1             # iter 001 (arc 3): --og-stage K (originals stage number)
	var json_output := false
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seed" and i + 1 < args.size():
			test_seed = int(args[i + 1])
		elif args[i] == "--config" and i + 1 < args.size():
			config_path = args[i + 1]
		elif args[i] == "--dna" and i + 1 < args.size():
			dna_path = args[i + 1]
		elif args[i] == "--dna-roundtrip" and i + 1 < args.size():
			roundtrip_path = args[i + 1]
		elif args[i] == "--biome" and i + 1 < args.size():
			biome_path = args[i + 1]
		elif args[i] == "--scene" and i + 1 < args.size():
			scene_path = args[i + 1]
		elif args[i] == "--og-stage" and i + 1 < args.size():
			og_stage = int(args[i + 1])
		elif args[i] == "--json":
			json_output = true

	if roundtrip_path != "":
		_dna_roundtrip(roundtrip_path)
		quit()
		return

	# Default: procedural scene (preserves arc-2 hash anchor 23d6a2ec…).
	# --scene swaps to OriginalLevel or any other Level.gd-subclass scene.
	var level: Node
	if scene_path != "":
		var packed: PackedScene = load(scene_path)
		level = packed.instantiate()
		# OriginalLevel exposes stage_number as @export; set before _ready.
		if og_stage > 0 and "stage_number" in level:
			level.stage_number = og_stage
	else:
		level = ProceduralLevelScene.instantiate()
		if dna_path != "":
			var dna = load(dna_path)
			level.level_seed = dna.level_seed
			level.config = dna.config
			# iter 101 (review-fix): biome rides on DNA when present so biomed
			# levels are actually reproducible from saved DNA.
			if "biome" in dna and dna.biome != null:
				level.biome = dna.biome
		else:
			level.level_seed = test_seed
			if config_path != "":
				level.config = load(config_path)
				# iter 101 (Codex P1): scene bakes a default biome which would
				# override `config` via _active_config(). Clear biome when caller
				# requested a flat-config oracle run.
				if biome_path == "":
					level.biome = null
		if biome_path != "":
			level.biome = load(biome_path)
	root.add_child(level)

	# Let _ready and a few _process iterations run
	for i in FRAMES_TO_STEP:
		await process_frame

	var report := _collect(level)
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit()


func _collect(level: Node) -> Dictionary:
	var brick_count := 0
	var water_count := 0
	for child in level.get_children():
		if child is StaticBody2D:
			if child.has_node("Sprite2D"):
				brick_count += 1
			elif child.has_node("AnimatedSprite2D"):
				water_count += 1

	var steel_cells: int = level.steelTileMap.get_used_cells().size()
	var grass_cells: int = level.grassTileMap.get_used_cells().size()

	# Eller snapshot from the latest ProceduralStep.
	# iter 001 (arc 3): defensive — OriginalLevel (arc-3 OG-mode) has no ps,
	# Eller metrics report as zero rather than crashing the collector.
	var ps = level.ps if "ps" in level else null
	var sets: Dictionary = ps.sets if ps else {}
	var sizes: Array[int] = []
	for sid in sets:
		sizes.append(sets[sid].size())
	var avg_size := 0.0
	var max_size := 0
	if sizes.size() > 0:
		var total := 0
		for s in sizes:
			total += s
			if s > max_size:
				max_size = s
		avg_size = float(total) / float(sizes.size())

	# Deterministic hash of every placed tile (location + type) for reproducibility checks
	var fingerprint := ""
	for cell in level.steelTileMap.get_used_cells():
		fingerprint += "s%d,%d;" % [cell.x, cell.y]
	for cell in level.grassTileMap.get_used_cells():
		fingerprint += "g%d,%d;" % [cell.x, cell.y]
	for child in level.get_children():
		if child is StaticBody2D:
			var prefix := ""
			if child.has_node("Sprite2D"):
				prefix = "b"
			elif child.has_node("AnimatedSprite2D"):
				prefix = "w"
			if prefix != "":
				fingerprint += "%s%d,%d;" % [prefix, int(child.position.x), int(child.position.y)]
	var tile_hash: String = fingerprint.sha256_text()

	# Vertical persistence: per cell, does the cell directly below carry the same
	# terrain? Higher = more architectural structure (walls/runs persist). Lower
	# = more chaotic (each row decorrelated from the next). Sampled at TileMapLayer
	# resolution (8px per cell, the same grid set_cell uses).
	var grid: Dictionary = {}
	for cell in level.steelTileMap.get_used_cells():
		grid[Vector2i(cell.x, cell.y)] = "steel"
	for cell in level.grassTileMap.get_used_cells():
		grid[Vector2i(cell.x, cell.y)] = "grass"
	for child in level.get_children():
		if child is StaticBody2D:
			var col: int = int(child.position.x / 8)
			var row: int = int(child.position.y / 8)
			if child.has_node("Sprite2D"):
				grid[Vector2i(col, row)] = "brick"
			elif child.has_node("AnimatedSprite2D"):
				grid[Vector2i(col, row)] = "water"
	var vert_total: int = 0
	var vert_same: int = 0
	for k in grid:
		var below: Vector2i = Vector2i(k.x, k.y + 1)
		if grid.has(below):
			vert_total += 1
			if grid[below] == grid[k]:
				vert_same += 1
	var vert_persistence: float = (float(vert_same) / float(vert_total)) if vert_total > 0 else 0.0

	# Refined coherence metrics (iter 13):
	# 1. above_floor: subtracts the 0.5 floor that the 2x2 block paving guarantees.
	#    Raw persistence range ~[0.5, 1.0]; above_floor maps to [0, 1].
	# 2. iid_expected: P(two random placed cells share terrain) given the OBSERVED
	#    distribution. Computed from terrain counts directly (not config weights),
	#    so it reflects what actually got placed including biome interp.
	# 3. structure_lift: vert_persistence / iid_expected. > 1.0 means vertical
	#    pairs are MORE correlated than random; < 1.0 means LESS. Decouples
	#    spatial structure from concentration (a uniform 25/25/25/25 distribution
	#    has IID 0.25; a steel-dominant 60/15/15/10 has IID 0.42).
	var total_for_iid: int = brick_count + water_count + steel_cells + grass_cells
	var iid_expected: float = 0.0
	if total_for_iid > 0:
		var p_b := float(brick_count) / float(total_for_iid)
		var p_w := float(water_count) / float(total_for_iid)
		var p_s := float(steel_cells) / float(total_for_iid)
		var p_g := float(grass_cells) / float(total_for_iid)
		iid_expected = p_b * p_b + p_w * p_w + p_s * p_s + p_g * p_g
	var above_floor: float = max(0.0, (vert_persistence - 0.5) / 0.5)
	var structure_lift: float = (vert_persistence / iid_expected) if iid_expected > 0.0 else 0.0

	# Connected-component analysis (iter 22). Flood-fill 4-connected on the
	# (col, row) grid; record count + max + avg of contiguous same-terrain
	# regions. Captures architecture in a way pair-counting can't: a level
	# with one giant blob has cc_count=1, cc_max=large; a level with many
	# small islands has cc_count=large, cc_avg=small.
	var visited: Dictionary = {}
	var cc_sizes: Array = []
	for start in grid:
		if visited.has(start):
			continue
		var terrain_t = grid[start]
		var size: int = 0
		var queue: Array = [start]
		while not queue.is_empty():
			var cur: Vector2i = queue.pop_back()
			if visited.has(cur):
				continue
			if not grid.has(cur):
				continue
			if grid[cur] != terrain_t:
				continue
			visited[cur] = true
			size += 1
			queue.push_back(Vector2i(cur.x + 1, cur.y))
			queue.push_back(Vector2i(cur.x - 1, cur.y))
			queue.push_back(Vector2i(cur.x, cur.y + 1))
			queue.push_back(Vector2i(cur.x, cur.y - 1))
		cc_sizes.append(size)
	var cc_count: int = cc_sizes.size()
	var cc_max: int = 0
	var cc_total: int = 0
	for s in cc_sizes:
		if s > cc_max:
			cc_max = s
		cc_total += s
	var cc_avg: float = (float(cc_total) / float(cc_count)) if cc_count > 0 else 0.0

	# Reachability flood-fill (iter 28+). BFS from player spawn;
	# passable = empty cell OR grass (which has no collision); impassable = brick,
	# steel, water. Reports reachable cell count + topmost row reached. A level
	# is "playable" if the player can climb >= MIN_ROWS_CLIMBED rows above spawn.
	# iter 101 (review-fix): derive SPAWN_TILE / MAP_W / MAP_H from the actual
	# level instead of hardcoding — keeps the oracle correct under viewport or
	# spawn-position edits to the scene.
	var spawn_px: Vector2 = level.player.global_position
	var SPAWN_TILE: Vector2i = Vector2i(int(spawn_px.x) / 8, int(spawn_px.y) / 8)
	var MAP_W: int = int(level.width) / 8
	var MAP_H: int = int(level.height) / 8
	const MIN_ROWS_CLIMBED: int = 10
	var reach_visited: Dictionary = {}
	var reach_queue: Array = [SPAWN_TILE]
	while not reach_queue.is_empty():
		var cur: Vector2i = reach_queue.pop_back()
		if reach_visited.has(cur):
			continue
		if cur.x < 0 or cur.x >= MAP_W or cur.y < 0 or cur.y >= MAP_H:
			continue
		# Passable iff (no terrain placed) or (terrain is grass)
		if grid.has(cur) and grid[cur] != "grass":
			continue
		reach_visited[cur] = true
		reach_queue.push_back(Vector2i(cur.x + 1, cur.y))
		reach_queue.push_back(Vector2i(cur.x - 1, cur.y))
		reach_queue.push_back(Vector2i(cur.x, cur.y + 1))
		reach_queue.push_back(Vector2i(cur.x, cur.y - 1))
	var reachable_cells: int = reach_visited.size()
	var min_reachable_row: int = MAP_H
	for cell in reach_visited:
		if cell.y < min_reachable_row:
			min_reachable_row = cell.y
	var rows_climbed: int = SPAWN_TILE.y - min_reachable_row
	var playable: bool = rows_climbed >= MIN_ROWS_CLIMBED

	# iter 001 (arc 3): level_seed only exists on ProceduralLevel; report -1
	# for OriginalLevel since seed is meaningless when terrain is loaded from
	# a deterministic ASCII source.
	var seed_used: int = level.level_seed if "level_seed" in level else -1
	return {
		"seed_used": seed_used,
		"brick": brick_count,
		"water": water_count,
		"steel": steel_cells,
		"grass": grass_cells,
		"eller_sets": sets.size(),
		"eller_avg_size": avg_size,
		"eller_max_size": max_size,
		"tile_hash": tile_hash,
		"total_terrain": brick_count + water_count + steel_cells + grass_cells,
		"vert_persistence": vert_persistence,
		"vert_pairs_same": vert_same,
		"vert_pairs_total": vert_total,
		"vert_above_floor": above_floor,
		"vert_iid_expected": iid_expected,
		"vert_structure_lift": structure_lift,
		"cc_count": cc_count,
		"cc_max": cc_max,
		"cc_avg": cc_avg,
		"reachable_cells": reachable_cells,
		"min_reachable_row": min_reachable_row,
		"rows_climbed": rows_climbed,
		"playable": playable,
	}


func _dna_roundtrip(path: String) -> void:
	print("=== LevelDNA roundtrip: %s ===" % path)
	var dna_a = load(path)
	if dna_a == null:
		print("FAIL: could not load DNA from %s" % path)
		return
	var dict_a: Dictionary = dna_a.to_dict()
	var json_str: String = JSON.stringify(dict_a)
	var dna_b = LevelDNAT.from_json(json_str)
	if dna_b == null:
		print("FAIL: from_json returned null")
		return
	var dict_b: Dictionary = dna_b.to_dict()
	var ok := true
	for k in dict_a:
		if not dict_b.has(k):
			print("FAIL: key %s missing after roundtrip" % k)
			ok = false
		elif typeof(dict_a[k]) == TYPE_FLOAT:
			if abs(dict_a[k] - dict_b[k]) > 1e-6:
				print("FAIL: %s drifted: %s != %s" % [k, dict_a[k], dict_b[k]])
				ok = false
		elif dict_a[k] != dict_b[k]:
			print("FAIL: %s differs: %s != %s" % [k, dict_a[k], dict_b[k]])
			ok = false
	print("source dict: %s" % dict_a)
	print("roundtrip:   %s" % dict_b)
	if ok:
		print("ROUNDTRIP_OK")
	else:
		print("ROUNDTRIP_FAIL")


func _print_report(r: Dictionary) -> void:
	print("=== tanke headless oracle ===")
	print("seed: %d" % r.seed_used)
	print("brick: %d  water: %d  steel: %d  grass: %d  total: %d" % [
		r.brick, r.water, r.steel, r.grass, r.total_terrain
	])
	print("eller_sets: %d  avg_size: %.2f  max_size: %d" % [
		r.eller_sets, r.eller_avg_size, r.eller_max_size
	])
	print("vert_persistence: %.3f  (%d / %d same-terrain pairs)" % [
		r.vert_persistence, r.vert_pairs_same, r.vert_pairs_total
	])
	print("vert_above_floor: %.3f   iid_expected: %.3f   structure_lift: %.3fx" % [
		r.vert_above_floor, r.vert_iid_expected, r.vert_structure_lift
	])
	print("cc_count: %d   cc_max: %d   cc_avg: %.2f" % [r.cc_count, r.cc_max, r.cc_avg])
	print("reachable: %d cells   rows_climbed: %d (min_row %d)   playable: %s" % [
		r.reachable_cells, r.rows_climbed, r.min_reachable_row, str(r.playable)
	])
	print("tile_hash: %s" % r.tile_hash.substr(0, 16))
	if r.total_terrain == 0:
		print("FAIL: zero tiles placed")
	else:
		print("PASS")
