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
	# iter 53: high-damage bullets (Heavy =2) get a warm orange tint so player
	# can identify the threat mid-air. Makes iter-52 damage variation visible.
	if damage >= 2:
		var sprite: Sprite2D = $Sprite2D
		if sprite != null:
			sprite.modulate = Color(1.0, 0.5, 0.3, 1.0)


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
	# iter 69 (F010 user iter-60 Q2 "noise artifact"): smaller, warmer,
	# briefer spark. 3×3 yellow instead of 4×4 white; 0.08s instead of 0.12s.
	# Aims for "muzzle flash" reading rather than "bright spam."
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var spark: ColorRect = ColorRect.new()
	spark.size = Vector2(3, 3)
	spark.color = Color(1.0, 0.95, 0.3, 1.0)  # warm yellow
	spark.position = global_position - Vector2(1.5, 1.5)
	spark.pivot_offset = Vector2(1.5, 1.5)
	spark.z_index = 60
	parent_node.add_child(spark)
	var tween: Tween = spark.create_tween()
	tween.set_parallel(true)
	tween.tween_property(spark, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(spark, "modulate:a", 0.0, 0.08)
	tween.chain().tween_callback(spark.queue_free)


func _on_lifetime_timeout() -> void:
	queue_free()
