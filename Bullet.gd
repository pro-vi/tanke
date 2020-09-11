extends Area2D

export (int) var speed
export (int) var damage
export (float) var lifetime = 1

var velocity = Vector2()

func start(_position, _direction):
	position = _position
	rotation = Constants.dir_to_rotation(_direction)
	velocity = Vector2(1, 0).rotated(rotation) * speed
	$LifeTimeTimer.start()
	
func _process(delta):
	position += velocity * delta

func impact():
	queue_free()

func die():
	queue_free()

func _on_Bullet_area_entered(area):
	impact()

func _on_LifeTimeTimer_timeout():
	die()
