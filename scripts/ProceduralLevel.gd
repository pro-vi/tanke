extends "res://scripts/Level.gd"

const ProceduralStep = preload("res://scripts/ProceduralStep.gd")
const DebugBlock: PackedScene = preload("res://scenes/DebugBlock.tscn")
const SteelBlockScene: PackedScene = preload("res://scenes/SteelBlock.tscn")
const LevelConfigT = preload("res://scripts/LevelConfig.gd")
const BiomeConfigT = preload("res://scripts/BiomeConfig.gd")
const BreachConfigT = preload("res://scripts/BreachConfig.gd")
const BreachBandT = preload("res://scripts/BreachBand.gd")
const DefaultConfig: Resource = preload("res://configs/default.tres")
@export var debug: bool = false
@export var level_seed: int = 0  # 0 = random; any other value = deterministic Level DNA
@export var config: LevelConfigT
@export var biome: BiomeConfigT  # optional; when set, depth-modulates per-row config
# arc-4 breach mode (PATTERN 2 — default-on substrate gating). When
# false, code path is bit-identical to arc-2 procedural baseline. Hash
# anchor 23d6a2ec3bf2821f… (seed 42 / default config) must remain
# preserved on the flag-off codepath. New behavior fires only when the
# flag is overridden by a sibling launcher scene (e.g. BreachLevel.tscn).
@export var breach_mode_enabled: bool = false
@export var breach_config: BreachConfigT = null  # depth-band roadmap (iter 3)

# algo variables
var osn: FastNoiseLite
var ps: ProceduralStep
var verts: Dictionary
var next_row: int = 0
var grid_size: int = 16


func _ready() -> void:
	# Connect player shoot signal — Level._ready() isn't called when this
	# subclass overrides _ready, so we wire the signal here directly.
	player.shoot.connect(_on_PlayerTank_shoot)
	# iter 101 (Codex P2): env-var override applies regardless of scene
	# default — scene now bakes config/biome, but `make diff` workflow swaps
	# captures via TANKE_CONFIG/TANKE_BIOME and needs the env var to win.
	# iter 101 (Codex follow-up P1): TANKE_CONFIG without TANKE_BIOME also
	# clears scene-default biome, mirroring test_runner's --config behavior;
	# `make diff` only sets TANKE_CONFIG, so leaving biome intact would let
	# the baked banded-biome override the requested config.
	var override_path: String = OS.get_environment("TANKE_CONFIG")
	var biome_override: String = OS.get_environment("TANKE_BIOME")
	if override_path != "":
		config = load(override_path)
		if biome_override == "":
			biome = null
	elif config == null:
		config = DefaultConfig.duplicate()
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
	var first_row: int = height / grid_size
	ps = ProceduralStep.new(width / grid_size, 0, _active_config(first_row).merge_probability)
	verts = ps.generate_step()
	for row in range(height / grid_size, -1, -1):
		if row == height / grid_size - 1:
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
	if breach_mode_enabled:
		_init_breach_mode()

func _process(_delta: float) -> void:
	var player_pos: Vector2 = player.position
	var next_row_h: int = next_row * grid_size

	if player_pos.y - next_row_h < height / 2 + grid_size:
		_generate_next_row_for(next_row)

		for sid in ps.sets:
			_pave_set(sid, next_row)
			if debug:
				_pave_debug(sid, next_row)
		_replace_blocks()

		next_row -= 1

	if breach_mode_enabled:
		_process_breach_depth(player_pos.y)


# Returns the LevelConfig active at the given row — biome-interpolated if biome
# is set, otherwise the flat config.
# arc-4: when breach mode is on AND the row falls inside a BreachBand that
# carries a level_config override, that band config wins. This is what
# makes each depth band a *specific climb problem* (CONSULT §9 constraint
# 5). When breach_mode_enabled is false the branch is skipped entirely —
# hash anchor 23d6a2ec3bf2821f on the flag-off codepath is preserved.
func _active_config(row: int) -> LevelConfigT:
	if breach_mode_enabled and breach_config != null:
		var band: BreachBandT = breach_config.band_for_depth(_rows_climbed_at(row))
		if band != null and band.level_config != null:
			return band.level_config
	if biome != null:
		return biome.config_at(row)
	return config


# arc-4: map a procedural row index to "rows climbed from start". Row
# height/grid_size is the start (rows_climbed 0); rows decrease as the
# player climbs, so rows_climbed grows. Negative rows (deep climb) yield
# rows_climbed > height/grid_size.
func _rows_climbed_at(row: int) -> int:
	return (height / grid_size) - row


# populate the next procedural step using verts; merge_probability is sampled
# from the active config at this row.
func _generate_next_row_for(row: int) -> void:
	var row_cfg: LevelConfigT = _active_config(row)
	ps = ProceduralStep.new(width / grid_size, ps.set_count, row_cfg.merge_probability)
	for sid in verts:
		for c in verts[sid]:
			ps.add_cell(c, sid)
	verts = ps.generate_step()


# weighted-sample tile distribution from the active LevelConfig at this row
func _pave_set(sid: int, row: int) -> void:
	var row_cfg: LevelConfigT = _active_config(row)
	var terrain: String = row_cfg.sample_terrain()
	if terrain == "":
		return
	var tilemap: TileMapLayer = _tilemap_for(terrain)
	if tilemap == null:
		return
	for c in ps.sets[sid]:
		tilemap.set_cell(Vector2i(c * 2, row * 2), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c * 2 + 1, row * 2), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c * 2, row * 2 + 1), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(c * 2 + 1, row * 2 + 1), 0, Vector2i(0, 0))


func _tilemap_for(terrain: String) -> TileMapLayer:
	match terrain:
		"brick": return brickTileMap
		"steel": return steelTileMap
		"grass": return grassTileMap
		"water": return waterTileMap
		_: return null


func _pave_debug(sid: int, row: int) -> void:
	for c in ps.sets[sid]:
		var debug_block: Node2D = DebugBlock.instantiate()
		debug_block.set_z_index(999)
		debug_block.get_node("Rect/Text").text = str(sid % 100)
		debug_block.position = Vector2(c * grid_size + 8, row * grid_size + 8)
		add_child(debug_block)


func _generate_level_perlin() -> void:
	for x in width / grid_size:
		for y in height / grid_size:
			var sample: float = osn.get_noise_2d(float(x), float(y))
			if sample < -0.3:
				steelTileMap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			elif (sample > 0.25) or (sample > -0.033 and sample < 0.033):
				brickTileMap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))


# arc-4 iter 34: in breach mode, steel becomes destroyable. Level's
# _replace_blocks converts brick + water TileMapLayer cells into nodes
# but leaves steel as an inert TileMapLayer. This override additionally
# converts steel cells into SteelBlock nodes — destroyable ONLY by APCR
# (Bullet._apply_apcr_breach). When breach_mode_enabled is false the
# override runs super only → arc-2/3 terrain is bit-identical and the
# hash anchor 23d6a2ec3bf2821f on the flag-off codepath is preserved.
func _replace_blocks() -> void:
	super._replace_blocks()
	if not breach_mode_enabled:
		return
	for cell in steelTileMap.get_used_cells():
		var steel_block: Node2D = SteelBlockScene.instantiate()
		steel_block.global_position = steelTileMap.map_to_local(cell)
		add_child(steel_block)
	steelTileMap.clear()


# arc-4 breach mode entry points. Never called when breach_mode_enabled
# is false (gating preserves arc-2 baseline + hash anchor on flag-off).

signal breach_band_changed(band: BreachBandT)

var _current_breach_band: BreachBandT = null


# Called once from _ready when breach mode is on. Resolves the starting
# band so _current_breach_band is populated before the first depth tick.
func _init_breach_mode() -> void:
	if breach_config == null:
		return
	# arc-4 iter 39 (Round 6a): per-run band-order shuffle — the 3 middle
	# bands permute into fixed depth slots; tutorial_choke + endgame_mixed
	# stay pinned. Deterministic from level_seed (a run is reproducible);
	# builds a private config so breach_default.tres is never mutated.
	breach_config = _shuffled_breach_config(breach_config)
	_current_breach_band = breach_config.band_for_depth(_rows_climbed_at_y(player.position.y))


# arc-4 iter 39: return a NEW BreachConfig with the 3 middle bands
# shuffled into the 3 fixed middle depth slots. tutorial_choke (first)
# and endgame_mixed (last) are pinned; the slot ranges are fixed so
# depot placements stay aligned to band boundaries and the per-band
# reachability oracle (density-based, span-independent) is unaffected.
# Bands are duplicated — the source resource is never mutated. Configs
# without exactly 5 bands pass through unshuffled.
func _shuffled_breach_config(src: BreachConfigT) -> BreachConfigT:
	if src == null or src.bands.size() != 5:
		return src
	var slots: Array = [
		[src.bands[1].depth_min, src.bands[1].depth_max],
		[src.bands[2].depth_min, src.bands[2].depth_max],
		[src.bands[3].depth_min, src.bands[3].depth_max],
	]
	var middle: Array = [src.bands[1], src.bands[2], src.bands[3]]
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	for i in range(middle.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = middle[i]
		middle[i] = middle[j]
		middle[j] = tmp
	var out_bands: Array[BreachBandT] = []
	out_bands.append(src.bands[0].duplicate())
	for i in middle.size():
		var nb: BreachBandT = middle[i].duplicate()
		nb.depth_min = slots[i][0]
		nb.depth_max = slots[i][1]
		out_bands.append(nb)
	out_bands.append(src.bands[4].duplicate())
	var cfg: BreachConfigT = BreachConfigT.new()
	cfg.bands = out_bands
	return cfg


# Called every _process tick when breach mode is on. Tracks which
# BreachBand the player is currently inside; emits breach_band_changed
# when they cross a band boundary. Iter 12+ wires HUD + death recap off
# this signal.
func _process_breach_depth(player_y: float) -> void:
	if breach_config == null:
		return
	var band: BreachBandT = breach_config.band_for_depth(_rows_climbed_at_y(player_y))
	if band != _current_breach_band:
		_current_breach_band = band
		breach_band_changed.emit(band)


# Map a world-space y to "rows climbed from start". The player begins
# near y = height (bottom) and climbs upward (decreasing y).
func _rows_climbed_at_y(world_y: float) -> int:
	return int((float(height) - world_y) / float(grid_size))


