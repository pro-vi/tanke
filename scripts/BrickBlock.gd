extends StaticBody2D

@export var max_hp: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var hp: int = max_hp


func _ready() -> void:
	hp = max_hp


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
