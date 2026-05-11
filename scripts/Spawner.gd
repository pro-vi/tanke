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

# Enemy type table (iter 16; behavioral split planned iter 24-26 per Pro
# Consult 004 H2). Currently stats-only difference — Light/Heavy will
# diverge behaviorally in future iters.
const ENEMY_TYPES: Array = [
	{
		"name": "Light",
		"weight": 0.7,
		"base_frame": 8,
		"speed": 24.0,
		"max_hp": 1,
		"fire_cooldown": 1.5,
	},
	{
		"name": "Heavy",
		"weight": 0.3,
		"base_frame": 32,
		"speed": 14.0,
		"max_hp": 2,
		"fire_cooldown": 0.8,
	},
]

# Ascent director (iter 22, per Pro Consult 004 sharpest recommendation):
# depth bands change spawn texture as player ascends. Crude is fine —
# player should feel "I reached a different kind of problem" within 1 min.
# Each band specifies depth threshold + type weight overrides + interval.
# (Bands tuned further in iters 23/27/29.)
const DEPTH_BANDS: Array = [
	{
		"name": "warmup",
		"depth_max": 8,
		"type_weights": {"Light": 1.0, "Heavy": 0.0},
		"interval_mult": 1.25,  # slower spawns — onboarding
	},
	{
		"name": "first_push",
		"depth_max": 20,
		"type_weights": {"Light": 0.7, "Heavy": 0.3},
		"interval_mult": 1.0,
	},
	{
		"name": "heavy_gate",
		"depth_max": 40,
		"type_weights": {"Light": 0.4, "Heavy": 0.6},  # Heavy-heavy
		"interval_mult": 0.85,
	},
	{
		"name": "rush",
		"depth_max": 9999,
		"type_weights": {"Light": 0.85, "Heavy": 0.15},
		"interval_mult": 0.7,  # fast spawns, mostly Light
	},
]

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
	# iter 22: band's interval_mult modulates base spawn_interval; stall
	# pressure still applies on top.
	var band: Dictionary = _current_band()
	var base: float = spawn_interval * float(band.get("interval_mult", 1.0))
	if _stall_time > stall_pressure_after:
		return base * stall_interval_multiplier
	return base


func _try_spawn() -> void:
	ticks_total += 1
	if enemy_scene == null or _enemies_alive >= max_enemies:
		return
	# iter 22: detect band transition for debug visibility
	var band: Dictionary = _current_band()
	if band.name != _last_band_name:
		print("[spawner] band ENTER %s at depth %d" % [band.name, _max_depth_reached])
		_last_band_name = band.name
	var spawn_pos: Variant = _find_valid_spawn()
	if spawn_pos == null:
		rejections_total += 1
	else:
		_telegraph_then_spawn(spawn_pos)
		spawns_total += 1
	if ticks_total % 5 == 0:
		print("[spawner] tick %d: spawns=%d rejections=%d alive=%d depth=%d band=%s ascent=%.2f stall=%.1fs interval=%.2fs" % [ticks_total, spawns_total, rejections_total, _enemies_alive, _max_depth_reached, band.name, _ascent_velocity, _stall_time, _current_spawn_interval()])


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
	enemy.set("sprite_base_frame", type_data.base_frame)
	enemy.set("speed", type_data.speed)
	enemy.set("max_hp", type_data.max_hp)
	enemy.set("fire_cooldown", type_data.fire_cooldown)
	enemy.global_position = pos
	enemy.tree_exited.connect(_on_enemy_freed)
	parent_node.add_child(enemy)
	_enemies_alive += 1


# Weighted random selection from ENEMY_TYPES, weighted by the current
# DEPTH BAND's type_weights override (iter 22). Type weights in the band
# replace the type's default weight; types absent from the band are weight 0.
func _pick_enemy_type() -> Dictionary:
	var band: Dictionary = _current_band()
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


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
