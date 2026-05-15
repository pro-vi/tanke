extends StaticBody2D

# Arc-3 eagle entity (criterion 2). HP=1: a single bullet kills it.
# Emits eagle_destroyed when defeated — OriginalLevel listens to convert
# to a game-over state in a future iter (iter 4+).
#
# Collision contract: collision_layer = 1 (Environment) so Bullet's mask=9
# (Environment | Enemy) catches the eagle the same way it catches steel
# tiles and bricks. take_damage(amount) matches the Bullet._on_body_entered
# duck-typed contract — same shape as BrickBlock.take_damage and arc-2's
# enemy entities.

signal eagle_destroyed

@export var hp: int = 1


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		eagle_destroyed.emit()
		queue_free()
