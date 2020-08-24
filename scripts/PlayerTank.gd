extends KinematicBody2D

export(int) var SPEED = 32

onready var sprite = $Sprite

var velocity = Vector2()

func _physics_process(delta):
	var input_vector = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y += -1
		sprite.play()
	elif Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		sprite.play()
	elif Input.is_action_pressed("ui_left"):
		input_vector.x += -1
		sprite.play()
	elif Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		sprite.play()
	else:
		sprite.stop()
	velocity = input_vector * SPEED
	sprite.set_dir_set(input_vector)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.normal)
	$Sprite.colliding = collision != null
