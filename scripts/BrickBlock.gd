extends StaticBody2D

@export var max_hp: int = 1
# arc-4 iter 139 (PLAYTEST-FIX-2 from user): bricks have a separate
# beam_hp pool so the PRISM beam takes 3 cooldown ticks to break a
# brick (visible drain, not 1-tick instant melt). Bullets unchanged
# (still 1-shot via take_damage on the bullet `hp` field).
@export var beam_hp_max: int = 3

@onready var sprite: Sprite2D = $Sprite2D

var hp: int = max_hp
var beam_hp: int = 3


func _ready() -> void:
	hp = max_hp
	beam_hp = beam_hp_max


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()


# arc-4 iter 139 (PLAYTEST-FIX-2): beam-pool damage path. Bricks
# break when beam_hp drains to 0 (3 cooldown ticks at default).
func take_beam_damage(amount: int) -> void:
	if amount <= 0:
		return
	beam_hp = max(0, beam_hp - amount)
	if beam_hp <= 0:
		queue_free()
