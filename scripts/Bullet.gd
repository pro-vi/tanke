extends Area2D

# Arc-4 breach mode: 3 primary shell classes (CONSULT §9 constraint 2).
# AP = cheap precise; HE = terrain-mutating; HEAT = anti-heavy-armor.
# Default = AP for arc-2 baseline bit-identicality (hash anchor
# 23d6a2ec3bf2821f… on seed 42 procedural fires AP bullets only via
# the arc-2 codepath; Spawner-fired enemy bullets stay AP too).
const SHELL_CLASS_AP: int = 0
const SHELL_CLASS_HE: int = 1
const SHELL_CLASS_HEAT: int = 2

@export var speed: int = 120
@export var damage: int = 1
@export var lifetime: float = 2.0
# Arc-4 default-on gating (PATTERN 2 / L5). Default = AP preserves arc-2
# baseline; HE / HEAT behaviors land in iter 5+ (terrain-cracking,
# anti-armor). When at default, `start()` runs an arc-2-identical path.
@export var shell_class: int = SHELL_CLASS_AP

var velocity: Vector2 = Vector2.ZERO

@onready var _lifetime_timer: Timer = $LifeTimeTimer


func start(pos: Vector2, dir: int, target_mask: int = -1, shell: int = -1) -> void:
	position = pos
	rotation = Constants.dir_to_rotation(dir)
	velocity = Vector2(1, 0).rotated(rotation) * float(speed)
	if target_mask >= 0:
		collision_mask = target_mask
	if shell >= 0:
		shell_class = shell
	_lifetime_timer.wait_time = lifetime
	_lifetime_timer.start()
	# iter 53: high-damage bullets (Heavy =2) get a warm orange tint so player
	# can identify the threat mid-air. Makes iter-52 damage variation visible.
	if damage >= 2:
		var sprite: Sprite2D = $Sprite2D
		if sprite != null:
			sprite.modulate = Color(1.0, 0.5, 0.3, 1.0)
	# Arc-4 shell-class visual hint. AP = no mutation (preserves arc-2
	# look + the damage>=2 warm-orange code path above). HE = soft yellow.
	# HEAT = warm crimson. Visual is a temporary scaffold until iter ~6+
	# replaces sprite per shell with gen_tile.py outputs (constraint 4
	# silhouette-grammar gate applies then).
	if shell_class != SHELL_CLASS_AP:
		var s: Sprite2D = $Sprite2D
		if s != null:
			if shell_class == SHELL_CLASS_HE:
				s.modulate = Color(1.0, 0.85, 0.25, 1.0)
			elif shell_class == SHELL_CLASS_HEAT:
				s.modulate = Color(1.0, 0.35, 0.25, 1.0)


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
