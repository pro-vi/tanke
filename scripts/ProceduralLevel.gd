extends "res://scripts/Level.gd"

const ProceduralStep = preload("res://scripts/ProceduralStep.gd")
const DebugBlock = preload("res://scenes/DebugBlock.tscn")
const LevelConfigT = preload("res://scripts/LevelConfig.gd")
const BiomeConfigT = preload("res://scripts/BiomeConfig.gd")
const DefaultConfig = preload("res://configs/default.tres")
@export var debug = false
@export var level_seed: int = 0  # 0 = random; any other value = deterministic Level DNA
@export var config: LevelConfigT
@export var biome: BiomeConfigT  # optional; when set, depth-modulates per-row config

# algo variables
var osn
var ps
var verts
var next_row = 0
var grid_size = 16


func _ready():
	if config == null:
		var override_path: String = OS.get_environment("TANKE_CONFIG")
		if override_path != "":
			config = load(override_path)
		else:
			config = DefaultConfig.duplicate()
	if biome == null:
		var biome_override: String = OS.get_environment("TANKE_BIOME")
		if biome_override != "":
			biome = load(biome_override)
	var override_seed: String = OS.get_environment("TANKE_SEED")
	if override_seed != "" and level_seed == 0:
		level_seed = int(override_seed)
	if level_seed == 0:
		level_seed = randi()
	seed(level_seed)
	print("level_seed: %d" % level_seed)
	# init starting area — use first row's active config for the seed step
	var first_row: int = height/grid_size
	ps = ProceduralStep.new(width/grid_size, 0, _active_config(first_row).merge_probability)
	verts = ps.generate_step()
	for row in range(height/grid_size, -1, -1):
		if row == height/grid_size - 1:
			continue
		_generate_next_row_for(row)

		for sid in ps.sets:
			_pave_set(sid, row)
			if debug:
				_pave_debug(sid, row)

		next_row = row - 1

	if false:
		# perlin noise
		osn = FastNoiseLite.new()
		osn.seed = randi()
		osn.fractal_octaves = 4
		osn.period = 15
		osn.lacunarity = 1.5
		osn.persistence = 0.75

		_generate_level_perlin()

	_replace_blocks()
	camera.global_position = player.global_position
	camera.reset_smoothing()
	camera.force_update_scroll()

func _process(_delta):
	var player_pos = player.position
	var next_row_h = next_row * grid_size

	if player_pos.y - next_row_h < height/2 + grid_size:
		_generate_next_row_for(next_row)

		for sid in ps.sets:
			_pave_set(sid, next_row)
			if debug:
				_pave_debug(sid, next_row)
		_replace_blocks()

		next_row -= 1


# Returns the LevelConfig active at the given row — biome-interpolated if biome
# is set, otherwise the flat config.
func _active_config(row: int) -> LevelConfigT:
	if biome != null:
		return biome.config_at(row)
	return config


# populate the next procedural step using verts; merge_probability is sampled
# from the active config at this row.
func _generate_next_row_for(row: int):
	var row_cfg := _active_config(row)
	ps = ProceduralStep.new(width/grid_size, ps.set_count, row_cfg.merge_probability)
	for sid in verts:
		for c in verts[sid]:
			ps.add_cell(c, sid)
	verts = ps.generate_step()


# weighted-sample tile distribution from the active LevelConfig at this row
func _pave_set(sid, row):
	var row_cfg := _active_config(row)
	var terrain: String = row_cfg.sample_terrain()
	if terrain == "":
		return
	var tilemap = _tilemap_for(terrain)
	if tilemap == null:
		return
	for c in ps.sets[sid]:
		tilemap.set_cell(Vector2i(c*2, row*2), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c*2+1, row*2), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c*2, row*2+1), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c*2+1, row*2+1), 0, Vector2i(0, 0))


func _tilemap_for(terrain: String) -> TileMapLayer:
	match terrain:
		"brick": return brickTileMap
		"steel": return steelTileMap
		"grass": return grassTileMap
		"water": return waterTileMap
		_: return null

func _pave_debug(sid, row):
	for c in ps.sets[sid]:
		var debug_block = DebugBlock.instantiate()
		debug_block.set_z_index(999)
		debug_block.get_node("Rect/Text").text = str(sid%100)
		debug_block.position = Vector2(c*grid_size+8, row*grid_size+8)
		add_child(debug_block)


func _generate_level_perlin():
	for x in width/grid_size:
		for y in height/grid_size:
			var sample = osn.get_noise_2d(float(x), float(y))
			if sample < -0.3:
				steelTileMap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			elif (sample > 0.25) or (sample > -0.033 and sample < 0.033):
				brickTileMap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))


