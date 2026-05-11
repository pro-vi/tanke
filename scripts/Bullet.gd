extends Area2D

@export var speed: int = 120
@export var damage: int = 1
@export var lifetime: float = 2.0

var velocity: Vector2 = Vector2.ZERO

@onready var _lifetime_timer: Timer = $LifeTimeTimer


func start(pos: Vector2, dir: int, target_mask: int = -1) -> void:
	position = pos
	rotation = Constants.dir_to_rotation(dir)
	velocity = Vector2(1, 0).rotated(rotation) * float(speed)
	if target_mask >= 0:
		collision_mask = target_mask
	_lifetime_timer.wait_time = lifetime
	_lifetime_timer.start()


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
