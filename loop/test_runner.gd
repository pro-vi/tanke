extends SceneTree

const ProceduralLevelScene = preload("res://scenes/ProceduralLevel.tscn")
const FRAMES_TO_STEP := 30
const DEFAULT_SEED := 42


func _initialize() -> void:
	var test_seed := DEFAULT_SEED
	var config_path := ""
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seed" and i + 1 < args.size():
			test_seed = int(args[i + 1])
		elif args[i] == "--config" and i + 1 < args.size():
			config_path = args[i + 1]

	var level: Node = ProceduralLevelScene.instantiate()
	level.level_seed = test_seed
	if config_path != "":
		level.config = load(config_path)
	root.add_child(level)

	# Let _ready and a few _process iterations run
	for i in FRAMES_TO_STEP:
		await process_frame

	var report := _collect(level)
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

	# Eller snapshot from the latest ProceduralStep
	var ps = level.ps
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

	return {
		"seed_used": level.level_seed,
		"brick": brick_count,
		"water": water_count,
		"steel": steel_cells,
		"grass": grass_cells,
		"eller_sets": sets.size(),
		"eller_avg_size": avg_size,
		"eller_max_size": max_size,
		"tile_hash": tile_hash,
		"total_terrain": brick_count + water_count + steel_cells + grass_cells,
	}


func _print_report(r: Dictionary) -> void:
	print("=== tanke headless oracle ===")
	print("seed: %d" % r.seed_used)
	print("brick: %d  water: %d  steel: %d  grass: %d  total: %d" % [
		r.brick, r.water, r.steel, r.grass, r.total_terrain
	])
	print("eller_sets: %d  avg_size: %.2f  max_size: %d" % [
		r.eller_sets, r.eller_avg_size, r.eller_max_size
	])
	print("tile_hash: %s" % r.tile_hash.substr(0, 16))
	if r.total_terrain == 0:
		print("FAIL: zero tiles placed")
	else:
		print("PASS")
