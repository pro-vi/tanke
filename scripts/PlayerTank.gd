extends CharacterBody2D

signal shoot

@export var speed: int = 32
@export var gun_cooldown: int = 100
@export var Bullet: PackedScene

@onready var sprite: Sprite2D = $Sprite2D

var direction: int = Constants.Dir.U
var grid: Vector2 = Vector2(4, 4)  # minimum grid size to snap to when turning
var can_shoot: bool = true


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2()

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

	velocity = input_vector * speed
	sprite.set_dir_set(input_vector)

	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
	sprite.colliding = collision != null

	if Input.is_action_pressed("ui_accept"):
		_fire()


func set_dir(new_dir: int) -> void:
	# snap to grid
	if direction != new_dir:
		position = position.snapped(grid)
	direction = new_dir
	set_rotation(Constants.dir_to_rotation(direction))


func _fire() -> void:
	if can_shoot:
		$GunTimer.start()
		shoot.emit(Bullet, $Muzzle.global_position, direction)
		can_shoot = false


func _on_GunTimer_timeout() -> void:
	can_shoot = true
