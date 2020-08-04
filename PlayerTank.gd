extends KinematicBody2D

export(int) var SPEED = 100

onready var sprite = $Sprite

var velocity

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y = -1
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1
	elif Input.is_action_pressed("ui_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("ui_right"):
		input_vector.x = 1
	velocity = input_vector * SPEED
	velocity = move_and_slide(velocity)
