extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var max_spawn_attempts: int = 8
@export var map_x_margin: float = 4.0
@export var map_width: float = 320.0
@export var top_off_screen_margin: float = 24.0  # spawn this many px above viewport top
# Ascender pressure (iter 12)
@export var ascent_lookahead_seconds: float = 1.5  # spawn this many seconds-of-ascent further ahead
@export var stall_threshold: float = 0.3  # rows/sec; below this counts as stalling
@export var stall_pressure_after: float = 4.0  # seconds of stall before pressure kicks in
@export var stall_interval_multiplier: float = 0.5  # spawn_interval × this when stalled (faster)
@export var telegraph_lead_time: float = 0.5  # seconds the warning marker shows before spawn
@export var velocity_ema_alpha: float = 2.0  # EMA smoothing factor; higher = more responsive

var _player: Node2D
var _camera: Camera2D
var _enemies_alive: int = 0
var _viewport_half_height: float = 120.0

# Spawn accumulator (replaces Timer; allows live spawn_interval modulation)
var _spawn_accumulator: float = 0.0

# Ascent tracking (iter 12)
var _last_player_y: float = 0.0
var _ascent_velocity: float = 0.0  # rows/sec, positive = ascending
var _stall_time: float = 0.0

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


func _update_stall_time(delta: float) -> void:
	if _ascent_velocity < stall_threshold:
		_stall_time += delta
	else:
		_stall_time = maxf(0.0, _stall_time - delta * 2.0)  # decay faster than build


func _current_spawn_interval() -> float:
	if _stall_time > stall_pressure_after:
		return spawn_interval * stall_interval_multiplier
	return spawn_interval


func _try_spawn() -> void:
	ticks_total += 1
	if enemy_scene == null or _enemies_alive >= max_enemies:
		return
	var spawn_pos: Variant = _find_valid_spawn()
	if spawn_pos == null:
		rejections_total += 1
	else:
		_telegraph_then_spawn(spawn_pos)
		spawns_total += 1
	if ticks_total % 5 == 0:
		print("[spawner] tick %d: spawns=%d rejections=%d alive=%d ascent=%.2f rows/s stall=%.1fs interval=%.2fs" % [ticks_total, spawns_total, rejections_total, _enemies_alive, _ascent_velocity, _stall_time, _current_spawn_interval()])


# Compute spawn position: above the visible viewport, scaled further up
# by current ascent velocity so faster ascent gets earlier warning.
# Falls back to player position if camera missing.
func _find_valid_spawn() -> Variant:
	var reference_y: float = _player.global_position.y
	if _camera != null and is_instance_valid(_camera):
		reference_y = _camera.global_position.y
	# rows-ahead lookahead: at 0 velocity → no extra offset; at N rows/sec
	# → N * lookahead_seconds rows further up
	var lookahead_px: float = maxf(0.0, _ascent_velocity) * 16.0 * ascent_lookahead_seconds
	var spawn_y: float = reference_y - _viewport_half_height - top_off_screen_margin - lookahead_px
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
	enemy.global_position = pos
	enemy.tree_exited.connect(_on_enemy_freed)
	parent_node.add_child(enemy)
	_enemies_alive += 1


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
