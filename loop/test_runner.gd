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

	if roundtrip_path != "":
		_dna_roundtrip(roundtrip_path)
		quit()
		return

	var level: Node = ProceduralLevelScene.instantiate()
	if dna_path != "":
		var dna = load(dna_path)
		level.level_seed = dna.level_seed
		level.config = dna.config
	else:
		level.level_seed = test_seed
		if config_path != "":
			level.config = load(config_path)
	if biome_path != "":
		level.biome = load(biome_path)
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
	print("tile_hash: %s" % r.tile_hash.substr(0, 16))
	if r.total_terrain == 0:
		print("FAIL: zero tiles placed")
	else:
		print("PASS")
