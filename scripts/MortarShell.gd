extends Node2D

# arc-4 iter 66 (Round 9d): MORTAR Tank projectile — a lobbed shell
# that travels from launch point to target over TRAVEL_TIME with a
# parabolic Y arc, then explodes (AoE damages siblings within
# AOE_RADIUS via take_damage). Fires over walls (no LoS check during
# flight) — that's the MORTAR archetype's whole pitch: terrain bypass.
# Arc-4-owned; no substrate touched.

const TRAVEL_TIME: float = 0.6
const ARC_HEIGHT: float = 24.0
const AOE_RADIUS: float = 18.0
const AOE_DAMAGE: int = 2

# arc-4 iter 199 (Round 23 Phase 3): per-shell overrides so MORTAR
# upgrade cards (AOE_RADIUS_UP, AOE_DAMAGE_UP) can boost individual
# shells without mutating the class-level constants. Defaults match
# the constants exactly — existing callers (and harness) get the
# same behavior as before unless they explicitly override.
var aoe_radius_override: float = AOE_RADIUS
var aoe_damage_override: int = AOE_DAMAGE

var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0
var _exploded: bool = false


# Launch the shell from `from_pos` arcing to `to_pos`. Call after
# add_child (the shell's _physics_process drives motion from here).
func launch(from_pos: Vector2, to_pos: Vector2) -> void:
	start_pos = from_pos
	target_pos = to_pos
	global_position = from_pos
	_elapsed = 0.0


func _ready() -> void:
	# Small dark shell visual.
	var chip: ColorRect = ColorRect.new()
	chip.size = Vector2(6, 6)
	chip.position = Vector2(-3, -3)
	chip.color = Color(0.4, 0.3, 0.2, 1.0)
	chip.z_index = 25
	chip.mouse_filter = 2
	add_child(chip)


func _physics_process(delta: float) -> void:
	if _exploded:
		return
	_elapsed += delta
	# arc-4 iter 096 (P2-8 fix from code-review-iter-090): clamp t
	# to [0, 1] so a frame-spike (large delta) doesn't overshoot
	# the lerp + arc math. t >= 1.0 still triggers _explode/queue_free
	# on the next branch.
	var t: float = minf(1.0, _elapsed / TRAVEL_TIME)
	if t >= 1.0:
		_explode()
		queue_free()
		return
	# Lerp horizontally + parabolic arc vertically (sin(πt) = 0..1..0).
	var pos: Vector2 = start_pos.lerp(target_pos, t)
	pos.y -= sin(t * PI) * ARC_HEIGHT
	global_position = pos


# AoE: damage every Node2D sibling within AOE_RADIUS that has
# take_damage. Idempotent via _exploded. Public so the harness can
# trigger without waiting TRAVEL_TIME of frames.
func _explode() -> void:
	if _exploded:
		return
	_exploded = true
	global_position = target_pos
	var parent_node: Node = get_parent()
	# arc-4 iter 094 (P1-6 fix from code-review-iter-090): scene-reload
	# mid-flight (e.g. player dies + presses R within TRAVEL_TIME 0.6s
	# of firing) can leave parent_node freed or queued for deletion.
	# Without this guard, parent_node.add_child(burst) crashes.
	if parent_node == null \
			or not is_instance_valid(parent_node) \
			or parent_node.is_queued_for_deletion():
		return
	# arc-4 PR-#4 P1 review fix — friendly-fire skip. MORTAR AoE
	# previously hit the firing player (sibling of bricks/enemies under
	# Level) — tap-fire a close shell or fire near a wall that lobs
	# back → self-damage; AOE_DAMAGE_UP cards make each self-hit worse.
	# Resolve the firing player via the iter-24 lvl.player duck-type
	# pattern; defensive so harness parents without it still work.
	var firing_player: Node = null
	if "player" in parent_node:
		firing_player = parent_node.player
	for sibling in parent_node.get_children():
		if sibling == self:
			continue
		# Skip firing player + any player-group member (covers Q1ProofRoom
		# alias spawn + future multi-player scenes).
		if firing_player != null and sibling == firing_player:
			continue
		if sibling.is_in_group("player"):
			continue
		if not (sibling is Node2D):
			continue
		if not sibling.has_method("take_damage"):
			continue
		var d: float = (sibling as Node2D).global_position.distance_to(target_pos)
		if d <= aoe_radius_override:
			sibling.take_damage(aoe_damage_override)
	_spawn_burst(parent_node)


# Brief orange burst at impact — outlives the shell's queue_free.
func _spawn_burst(parent_node: Node) -> void:
	# arc-4 iter 094 (P1-6 fix): defensive — _explode already guards,
	# but if _spawn_burst is ever called from elsewhere with a
	# freed/queued parent, no-op silently.
	if parent_node == null \
			or not is_instance_valid(parent_node) \
			or parent_node.is_queued_for_deletion():
		return
	var burst: ColorRect = ColorRect.new()
	burst.size = Vector2(AOE_RADIUS * 2.0, AOE_RADIUS * 2.0)
	burst.position = target_pos - Vector2(AOE_RADIUS, AOE_RADIUS)
	burst.color = Color(1.0, 0.55, 0.2, 0.8)
	burst.z_index = 50
	burst.mouse_filter = 2
	parent_node.add_child(burst)
	var tween: Tween = burst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(burst, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(burst, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(burst.queue_free)
