extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var max_spawn_attempts: int = 8
@export var map_x_margin: float = 4.0
@export var map_width: float = 320.0
@export var viewport_top_offset: float = 144.0  # player.y - this = top of viewport - 24px margin

var _player: Node2D
var _enemies_alive: int = 0
var _timer: Timer

# Counters for iter-4 pre-mortem prediction #2 (rejections per 10 ticks).
var spawns_total: int = 0
var rejections_total: int = 0
var ticks_total: int = 0


func _ready() -> void:
	_player = get_parent().get_node_or_null("PlayerTank")
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


func _on_timer_timeout() -> void:
	ticks_total += 1
	if enemy_scene == null or _player == null or not is_instance_valid(_player):
		return
	if _enemies_alive >= max_enemies:
		return
	var spawn_pos: Variant = _find_valid_spawn()
	if spawn_pos == null:
		rejections_total += 1
	else:
		var enemy: Node2D = enemy_scene.instantiate()
		enemy.global_position = spawn_pos
		enemy.tree_exited.connect(_on_enemy_freed)
		get_parent().add_child(enemy)
		_enemies_alive += 1
		spawns_total += 1
	if ticks_total % 5 == 0:
		print("[spawner] tick %d: spawns=%d rejections=%d alive=%d" % [ticks_total, spawns_total, rejections_total, _enemies_alive])


# Top-edge spawn: random x along map width, y just above viewport top.
# Validity = not inside a layer-1 collider.
func _find_valid_spawn() -> Variant:
	var spawn_y: float = _player.global_position.y - viewport_top_offset
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
	params.collision_mask = 1  # Environment layer (terrain + BrickBlock + WaterBlock)
	var results: Array = space_state.intersect_point(params, 1)
	return results.size() > 0


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
