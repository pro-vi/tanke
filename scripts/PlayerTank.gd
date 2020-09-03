extends KinematicBody2D

export (int) var SPEED = 32

onready var sprite = $Sprite

var velocity = Vector2()
var direction = Constants.Dir.U
var grid = Vector2(4, 4)  # minimum grid size to snap to when turning

func _physics_process(delta):
	var input_vector = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y += -1
		set_dir(Constants.Dir.U)
		sprite.play()
	elif Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		set_dir(Constants.Dir.D)
		sprite.play()
	elif Input.is_action_pressed("ui_left"):
		input_vector.x += -1
		set_dir(Constants.Dir.L)
		sprite.play()
	elif Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		set_dir(Constants.Dir.R)
		sprite.play()
	else:
		sprite.stop()
	velocity = input_vector * SPEED
	sprite.set_dir_set(input_vector)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.normal)
	sprite.colliding = collision != null


func set_dir(new_dir):
	# snap to grid
	if direction != new_dir:
		position = position.snapped(grid)
	direction = new_dir
