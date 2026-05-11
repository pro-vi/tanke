extends CharacterBody2D

@export var speed: float = 24.0
@export var max_hp: int = 1

var hp: int = max_hp
var _player: Node2D


func _ready() -> void:
	hp = max_hp
	_player = get_tree().get_root().find_child("PlayerTank", true, false)


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var to_player: Vector2 = _player.global_position - global_position
	if to_player.length() < 1.0:
		return
	velocity = to_player.normalized() * speed
	move_and_slide()


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
