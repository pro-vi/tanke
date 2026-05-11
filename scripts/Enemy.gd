extends CharacterBody2D

@export var speed: float = 24.0
@export var max_hp: int = 1
@export var fire_cooldown: float = 1.5
@export var direction_commit_time: float = 0.8
@export var bullet_scene: PackedScene
@export var bullet_target_mask: int = 3  # Environment (1) + Player (2)
@export var grid: float = 8.0  # half-cell snap on turn
# Visual: which sprite-sheet base frame for this enemy + per-direction frame offsets.
# Order follows Constants.Dir enum (L=0, D=1, U=2, R=3).
# Sprite layout per row: U(0,1), L(2,3), D(4,5), R(6,7) — matches TankSprite.gd.
@export var sprite_base_frame: int = 8   # row 0 col 8 — white enemy tank, distinct from yellow player
@export var sprite_dir_offsets: Array[int] = [2, 4, 0, 6]

var hp: int = max_hp
var direction: int = Constants.Dir.D  # start facing down (comes from top)
var _player: Node2D
var _fire_timer: float = 0.0
var _direction_timer: float = 0.0
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	_player = get_tree().get_root().find_child("PlayerTank", true, false)
	_fire_timer = randf() * fire_cooldown  # stagger initial volleys
	_choose_direction_toward_player()
	_update_sprite_for_direction()


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	_fire_timer -= delta
	_direction_timer -= delta

	if _direction_timer <= 0.0:
		_choose_direction_toward_player()
		_direction_timer = direction_commit_time

	var dir_vec: Vector2 = _direction_vector(direction)
	velocity = dir_vec * speed
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		# Try perpendicular alternates. If both blocked, fall back to reverse.
		var alternates: Array = _perpendicular(direction)
		alternates.shuffle()
		for alt in alternates:
			if _try_step(_direction_vector(alt) * speed * delta):
				_turn_to(alt)
				_direction_timer = direction_commit_time
				return
		_turn_to(_opposite(direction))
		_direction_timer = direction_commit_time
		return

	if _fire_timer <= 0.0:
		_fire()
		_fire_timer = fire_cooldown


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()


func _choose_direction_toward_player() -> void:
	var to_player: Vector2 = _player.global_position - global_position
	var new_dir: int
	if absf(to_player.x) > absf(to_player.y):
		new_dir = Constants.Dir.R if to_player.x > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if to_player.y > 0 else Constants.Dir.U
	if new_dir != direction:
		_turn_to(new_dir)


func _turn_to(new_dir: int) -> void:
	direction = new_dir
	_update_sprite_for_direction()
	global_position = global_position.snapped(Vector2(grid, grid))


func _update_sprite_for_direction() -> void:
	if _sprite != null and direction < sprite_dir_offsets.size():
		_sprite.frame = sprite_base_frame + sprite_dir_offsets[direction]


func _try_step(motion: Vector2) -> bool:
	var test_collision: KinematicCollision2D = move_and_collide(motion, true)
	return test_collision == null


func _direction_vector(dir: int) -> Vector2:
	return Vector2(1, 0).rotated(Constants.dir_to_rotation(dir))


func _perpendicular(dir: int) -> Array:
	match dir:
		Constants.Dir.U, Constants.Dir.D:
			return [Constants.Dir.L, Constants.Dir.R]
		_:
			return [Constants.Dir.U, Constants.Dir.D]


func _opposite(dir: int) -> int:
	match dir:
		Constants.Dir.U: return Constants.Dir.D
		Constants.Dir.D: return Constants.Dir.U
		Constants.Dir.L: return Constants.Dir.R
		_: return Constants.Dir.L


func _fire() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	var muzzle_offset: Vector2 = _direction_vector(direction) * 8.0
	var spawn_pos: Vector2 = global_position + muzzle_offset
	get_parent().add_child(bullet)
	bullet.start(spawn_pos, direction, bullet_target_mask)
