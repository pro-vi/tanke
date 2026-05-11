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
	_spawn_impact_spark()
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_spawn_impact_spark()
	queue_free()


# iter 41: visual juice — small white ColorRect at impact position, scaled +
# faded out over 0.12s. Parented to bullet's parent so it outlives queue_free.
# z_index 60 keeps it above tiles/bullets but below HUD.
func _spawn_impact_spark() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var spark: ColorRect = ColorRect.new()
	spark.size = Vector2(4, 4)
	spark.color = Color(1.0, 1.0, 1.0, 1.0)
	spark.position = global_position - Vector2(2, 2)
	spark.pivot_offset = Vector2(2, 2)
	spark.z_index = 60
	parent_node.add_child(spark)
	var tween: Tween = spark.create_tween()
	tween.set_parallel(true)
	tween.tween_property(spark, "scale", Vector2(1.5, 1.5), 0.12)
	tween.tween_property(spark, "modulate:a", 0.0, 0.12)
	tween.chain().tween_callback(spark.queue_free)


func _on_lifetime_timeout() -> void:
	queue_free()
