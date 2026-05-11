extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var max_spawn_attempts: int = 8
@export var map_x_margin: float = 4.0
@export var map_width: float = 320.0
@export var spawn_top_edge_offset: float = 8.0  # spawn this many px INSIDE the visible viewport top, so user sees enemies "driving in" from the edge (BC-style)
# Ascender pressure (iter 12)
@export var ascent_lookahead_seconds: float = 1.5  # spawn this many seconds-of-ascent further ahead
@export var stall_threshold: float = 0.3  # rows/sec; below this counts as stalling
@export var stall_pressure_after: float = 4.0  # seconds of stall before pressure kicks in
@export var stall_interval_multiplier: float = 0.5  # spawn_interval × this when stalled (faster)
@export var telegraph_lead_time: float = 0.5  # seconds the warning marker shows before spawn
@export var velocity_ema_alpha: float = 2.0  # EMA smoothing factor; higher = more responsive

# Enemy type table (iter 16; behavioral split iter 24 Heavy + iter 26 Light).
# Per Pro Consult 004 H2 recipe: Light = "lane-invader, advances aggressively,
# fires rarely"; Heavy = "corridor-denier, pauses, fires bursts."
# direction_commit_time per type — Light commits to a lane longer (3.0s);
# Heavy stays at 0.8s for responsiveness to player movement.
const ENEMY_TYPES: Array = [
	{
		"name": "Light",
		"weight": 0.7,
		"base_frame": 8,
		"speed": 24.0,
		"max_hp": 1,
		"fire_cooldown": 3.5,  # iter 26: fires rarely (was 1.5)
		"direction_commit_time": 3.0,  # iter 26: commits to a lane (was 0.8)
	},
	{
		"name": "Heavy",
		"weight": 0.3,
		"base_frame": 32,
		"speed": 14.0,
		"max_hp": 2,
		"fire_cooldown": 0.8,
		"direction_commit_time": 0.8,
	},
]

# Ascent director (iter 22 scaffold; iter 27 adds per-band max_alive +
# guarantee_first_type encounter rules). Each band differs in:
# - depth_max: upper bound for band membership
# - type_weights: spawn pool override
# - interval_mult: spawn cadence multiplier on base spawn_interval
# - max_alive: cap on simultaneously-alive enemies (overrides global)
# - guarantee_first_type: first spawn after entering this band is this type
#   (sets the tone before random weights take over)
const DEPTH_BANDS: Array = [
	{
		"name": "warmup",
		"depth_max": 8,
		"type_weights": {"Light": 1.0, "Heavy": 0.0},
		"interval_mult": 1.25,
		"max_alive": 4,  # onboarding density
		"guarantee_first_type": null,
	},
	{
		"name": "first_push",
		"depth_max": 20,
		"type_weights": {"Light": 0.7, "Heavy": 0.3},
		"interval_mult": 1.0,
		"max_alive": 10,
		"guarantee_first_type": null,
	},
	{
		"name": "heavy_gate",
		"depth_max": 40,
		"type_weights": {"Light": 0.4, "Heavy": 0.6},
		"interval_mult": 0.85,
		"max_alive": 8,  # fewer but heavier — denial pressure
		"guarantee_first_type": "Heavy",  # band-marker
	},
	{
		"name": "rush",
		"depth_max": 9999,
		"type_weights": {"Light": 0.85, "Heavy": 0.15},
		"interval_mult": 0.7,
		"max_alive": 16,
		"guarantee_first_type": "Light",  # signal the rush phase
	},
]

# Graduated stall pressure (iter 27, replacing binary multiplier):
# stall_time < stall_pressure_after  → mult = 1.0 (no pressure)
# stall_time = stall_pressure_after  → mult = 1.0 (start ramp)
# stall_time = stall_full_pressure_at → mult = stall_min_multiplier (capped)
@export var stall_full_pressure_at: float = 12.0  # seconds for full pressure
@export var stall_min_multiplier: float = 0.4  # floor (max 2.5× spawn rate)

var _player: Node2D
var _camera: Camera2D
var _enemies_alive: int = 0
var _viewport_half_height: float = 120.0

# Spawn accumulator (replaces Timer; allows live spawn_interval modulation)
var _spawn_accumulator: float = 0.0

# Ascent tracking (iter 12 + iter 22 depth bands)
var _last_player_y: float = 0.0
var _player_start_y: float = 0.0  # iter 22: depth = (start - current) / 16
var _max_depth_reached: int = 0   # iter 22: peak depth in rows
var _ascent_velocity: float = 0.0  # rows/sec, positive = ascending
var _stall_time: float = 0.0
var _last_band_name: String = ""  # log when band changes
var _band_first_spawn_pending: bool = false  # iter 27: trigger guarantee_first_type on band entry

# Counters for iter-4 pre-mortem prediction #2 (rejections per 10 ticks).
var spawns_total: int = 0
var rejections_total: int = 0
var ticks_total: int = 0


func _ready() -> void:
	_player = get_parent().get_node_or_null("PlayerTank")
	_camera = get_parent().get_node_or_null("Camera2D")
	_viewport_half_height = float(ProjectSettings.get_setting("display/window/size/viewport_height", 240)) * 0.5
	if _player != null:
		_last_player_y = _player.global_position.y
		_player_start_y = _player.global_position.y


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_update_ascent_velocity(delta)
	_update_stall_time(delta)

	var current_interval: float = _current_spawn_interval()
	_spawn_accumulator += delta
	if _spawn_accumulator >= current_interval:
		_spawn_accumulator -= current_interval
		_try_spawn()


func _update_ascent_velocity(delta: float) -> void:
	if delta <= 0.0:
		return
	# rows ascended this frame (player moving up = decreasing y)
	var dy_rows: float = (_last_player_y - _player.global_position.y) / 16.0
	var instant: float = dy_rows / delta
	# EMA smoothing
	var alpha: float = clampf(velocity_ema_alpha * delta, 0.0, 1.0)
	_ascent_velocity = lerpf(_ascent_velocity, instant, alpha)
	_last_player_y = _player.global_position.y
	# iter 22: track peak depth for band lookup
	var current_depth: int = int(maxf(0.0, (_player_start_y - _player.global_position.y) / 16.0))
	if current_depth > _max_depth_reached:
		_max_depth_reached = current_depth


# iter 22 ASCENT DIRECTOR: which encounter band is the player currently in?
# Returns the first band whose depth_max >= current peak depth.
func _current_band() -> Dictionary:
	for band in DEPTH_BANDS:
		if _max_depth_reached <= band.depth_max:
			return band
	return DEPTH_BANDS[-1]


func _update_stall_time(delta: float) -> void:
	if _ascent_velocity < stall_threshold:
		_stall_time += delta
	else:
		_stall_time = maxf(0.0, _stall_time - delta * 2.0)  # decay faster than build


func _current_spawn_interval() -> float:
	# iter 22: band interval_mult; iter 27: graduated stall multiplier.
	var band: Dictionary = _current_band()
	var base: float = spawn_interval * float(band.get("interval_mult", 1.0))
	return base * _current_stall_multiplier()


# iter 27: graduated stall multiplier replacing iter-12 binary stall_interval_multiplier.
# Linear ramp from 1.0 at stall_pressure_after to stall_min_multiplier at
# stall_full_pressure_at. Capped at floor. The original binary
# stall_interval_multiplier export is now interpreted as the floor target
# but kept for backward compatibility.
func _current_stall_multiplier() -> float:
	if _stall_time <= stall_pressure_after:
		return 1.0
	var span: float = maxf(stall_full_pressure_at - stall_pressure_after, 0.01)
	var t: float = clampf((_stall_time - stall_pressure_after) / span, 0.0, 1.0)
	return lerpf(1.0, stall_min_multiplier, t)


func _try_spawn() -> void:
	ticks_total += 1
	if enemy_scene == null:
		return
	# iter 22+27: band transition + first-spawn guarantee setup
	var band: Dictionary = _current_band()
	if band.name != _last_band_name:
		print("[spawner] band ENTER %s at depth %d" % [band.name, _max_depth_reached])
		_last_band_name = band.name
		_band_first_spawn_pending = true
	# iter 27: per-band max_alive override
	var band_cap: int = int(band.get("max_alive", max_enemies))
	var cap_hit: bool = _enemies_alive >= band_cap
	if not cap_hit:
		var spawn_pos: Variant = _find_valid_spawn()
		if spawn_pos == null:
			rejections_total += 1
		else:
			_telegraph_then_spawn(spawn_pos)
			spawns_total += 1
	if ticks_total % 5 == 0:
		var cap_marker: String = " CAP" if cap_hit else ""
		print("[spawner] tick %d: spawns=%d rejections=%d alive=%d/%d%s depth=%d band=%s ascent=%.2f stall=%.1fs interval=%.2fs stallMult=%.2f" % [ticks_total, spawns_total, rejections_total, _enemies_alive, band_cap, cap_marker, _max_depth_reached, band.name, _ascent_velocity, _stall_time, _current_spawn_interval(), _current_stall_multiplier()])


# Compute spawn position: at the EFFECTIVE viewport top (just inside the
# screen edge), scaled further up by current ascent velocity so faster
# ascent gets earlier warning. Uses Camera2D.get_screen_center_position()
# which accounts for limit_bottom clamping; raw _camera.global_position.y
# can lie when the camera is clamped against limit_bottom (iter-14 bug).
func _find_valid_spawn() -> Variant:
	var camera_center_y: float = _player.global_position.y
	if _camera != null and is_instance_valid(_camera):
		camera_center_y = _camera.get_screen_center_position().y
	var screen_top: float = camera_center_y - _viewport_half_height
	# rows-ahead lookahead: at 0 velocity → spawn at screen top + small offset
	# (enemy visible "driving in"); at N rows/sec → N * lookahead_seconds rows
	# further up (off-screen, gives player advance warning).
	var lookahead_px: float = maxf(0.0, _ascent_velocity) * 16.0 * ascent_lookahead_seconds
	var spawn_y: float = screen_top + spawn_top_edge_offset - lookahead_px
	for i in max_spawn_attempts:
		var x: float = randf_range(map_x_margin, map_width - map_x_margin)
		var candidate: Vector2 = Vector2(x, spawn_y)
		if _is_blocked(candidate):
			continue
		return candidate
	return null


func _is_blocked(pos: Vector2) -> bool:
	var world: World2D = get_world_2d()
	if world == null:
		return false
	var space_state: PhysicsDirectSpaceState2D = world.direct_space_state
	if space_state == null:
		return false
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = 513  # Environment (1) + Water (512); both block tank traversal
	var results: Array = space_state.intersect_point(params, 1)
	return results.size() > 0


# Battle-City-style spawn telegraph: brief warning marker at spawn position,
# then enemy instantiates after telegraph_lead_time. Uses a ColorRect since
# we don't have sprite assets for the telegraph in the current sheet.
func _telegraph_then_spawn(pos: Vector2) -> void:
	var marker: ColorRect = ColorRect.new()
	marker.size = Vector2(8, 4)
	marker.color = Color(1.0, 0.85, 0.2, 0.9)  # yellow warning
	marker.position = pos - Vector2(4, 2)  # center
	marker.z_index = 100
	get_parent().add_child(marker)
	await get_tree().create_timer(telegraph_lead_time).timeout
	if is_instance_valid(marker):
		marker.queue_free()
	# Bail if enemy_scene cleared or cap hit mid-await
	if enemy_scene == null or _enemies_alive >= max_enemies:
		return
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var enemy: Node2D = enemy_scene.instantiate()
	# Apply enemy type stats BEFORE add_child so _ready sees the right values
	var type_data: Dictionary = _pick_enemy_type()
	enemy.set("enemy_type", type_data.name)  # iter 24: behavioral switch in Enemy.gd
	enemy.set("sprite_base_frame", type_data.base_frame)
	enemy.set("speed", type_data.speed)
	enemy.set("max_hp", type_data.max_hp)
	enemy.set("fire_cooldown", type_data.fire_cooldown)
	enemy.set("direction_commit_time", type_data.direction_commit_time)  # iter 26
	enemy.global_position = pos
	enemy.tree_exited.connect(_on_enemy_freed)
	parent_node.add_child(enemy)
	_enemies_alive += 1


# Weighted random selection from ENEMY_TYPES, weighted by the current
# DEPTH BAND's type_weights override (iter 22). iter 27: also honors
# band's guarantee_first_type when entering a new band — first spawn
# uses that type to set the band's tone before random weights take over.
func _pick_enemy_type() -> Dictionary:
	var band: Dictionary = _current_band()
	# iter 27: band-entry guarantee
	if _band_first_spawn_pending:
		_band_first_spawn_pending = false
		var guar = band.get("guarantee_first_type", null)
		if guar != null:
			var forced: Dictionary = _get_type_by_name(guar)
			if not forced.is_empty():
				return forced
	var weights: Dictionary = band.get("type_weights", {})
	var total: float = 0.0
	for t in ENEMY_TYPES:
		total += float(weights.get(t.name, t.weight))
	if total <= 0.0:
		return ENEMY_TYPES[0]
	var roll: float = randf() * total
	var accum: float = 0.0
	for t in ENEMY_TYPES:
		accum += float(weights.get(t.name, t.weight))
		if roll <= accum:
			return t
	return ENEMY_TYPES[0]


# iter 27: helper for guarantee_first_type lookup
func _get_type_by_name(type_name: String) -> Dictionary:
	for t in ENEMY_TYPES:
		if t.name == type_name:
			return t
	return {}


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
