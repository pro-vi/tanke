extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var spawn_distance: float = 120.0

var _player: Node2D
var _enemies_alive: int = 0
var _timer: Timer


func _ready() -> void:
	_player = get_parent().get_node_or_null("PlayerTank")
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


func _on_timer_timeout() -> void:
	if enemy_scene == null or _player == null or not is_instance_valid(_player):
		return
	if _enemies_alive >= max_enemies:
		return
	var angle: float = randf() * TAU
	var spawn_pos: Vector2 = _player.global_position + Vector2(spawn_distance, 0).rotated(angle)
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.tree_exited.connect(_on_enemy_freed)
	get_parent().add_child(enemy)
	_enemies_alive += 1


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
