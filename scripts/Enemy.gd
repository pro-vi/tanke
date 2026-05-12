extends CharacterBody2D

# Enemy types (iter 24 behavioral split): "Light" (naive chaser) /
# "Heavy" (corridor-denier: pauses + bursts when aligned with player).
# Set by Spawner.gd at instantiate time per ENEMY_TYPES table.
enum State { CHASE, AIM_FIRE }

@export var speed: float = 24.0
@export var max_hp: int = 1
@export var fire_cooldown: float = 1.5
@export var direction_commit_time: float = 0.8
@export var bullet_scene: PackedScene
@export var bullet_target_mask: int = 3  # Environment (1) + Player (2)
@export var bullet_damage: int = 1  # iter 52: per-type damage (Heavy=2, others=1)
# iter 67 (Phase B early, F009 remediation per user iter-60 Q1): per-type
# sprite tint via self_modulate (independent of modulate used by hit-flash
# and aim-telegraph). Light=white default, Fast=cyan, Heavy=white (its red
# AIM_FIRE telegraph is sufficient distinction).
@export var sprite_tint: Color = Color(1, 1, 1, 1)
@export var grid: float = 8.0  # half-cell snap on turn
# Visual
@export var sprite_base_frame: int = 8
@export var sprite_dir_offsets: Array[int] = [2, 4, 0, 6]
@export var forest_hidden_alpha: float = 0.3
@export var forest_visible_alpha: float = 1.0
# Behavioral split (iter 24)
@export var enemy_type: String = "Light"  # "Light" or "Heavy"
@export var aim_fire_range: float = 80.0  # max distance for LOS aim (vision cone)
@export var aim_fire_axis_tolerance: float = 12.0  # cone lateral tolerance (px)
# iter 35 (F005, per .research/battle-city-ai.md Stage 1): vision is now
# CARDINAL-FORWARD-CONE + RAYCAST through env layer. Heavy must FACE the
# player AND have unobstructed LOS to enter AIM_FIRE. Authentic-BC tactical
# play: player can hide behind brick walls, peek out, hide again.
@export var vision_blocked_by_env: bool = true  # raycast obstruction check
@export var aim_fire_min_dwell: float = 0.4  # hysteresis floor before exit
@export var burst_count: int = 2
@export var burst_interval: float = 0.4
@export var aim_fire_cooldown_between_bursts: float = 1.2
# iter 38 (user iter-37 playtest: "still points me directly and fire rapidly
# as soon as i came into its line of sight"): aim wind-up. Heavy stops, faces
# player, and shows red telegraph for this duration BEFORE first shot. Gives
# player reaction time to break LOS or commit to a dodge.
@export var aim_fire_reaction_time: float = 0.45
@export var aim_telegraph_color: Color = Color(1.6, 0.5, 0.5, 1.0)
# iter 51: aim-cancel on hit. Shooting Heavy during AIM_FIRE wind-up cancels
# the burst — player tactical reward for accurate aim during red telegraph.
# Cooldown prevents instant re-AIM_FIRE (stunlock prevention).
@export var aim_cancel_cooldown: float = 1.5

var hp: int = max_hp
var direction: int = Constants.Dir.D  # start facing down (comes from top)
var _player: Node2D
var _grass_tilemap: TileMapLayer = null
var _fire_timer: float = 0.0
var _direction_timer: float = 0.0
var _state: int = State.CHASE
var _state_time: float = 0.0
var _burst_remaining: int = 0
var _burst_timer: float = 0.0
# iter 47 (Pro Consult 006 primary): Heavy LKP de-omniscience. Heavy CHASE no
# longer reads raw player.global_position; instead tracks last-known position
# and searches when LOS lost. Light/Fast unaffected (omniscient is part of
# their design — Light commits lane, Fast sprays).
var _lkp: Variant = null  # Vector2 when set, null when no LKP
var _reached_lkp: bool = false
var _search_until: float = 0.0  # _state_time threshold past which SEARCH expires
var _aim_cancel_timer: float = 0.0  # iter 51: stuns Heavy out of AIM_FIRE after hit-cancel
@export var lkp_reach_radius: float = 12.0
@export var lkp_search_duration: float = 2.5
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	_player = get_tree().get_root().find_child("PlayerTank", true, false)
	_grass_tilemap = get_tree().get_root().find_child("Grass", true, false) as TileMapLayer
	_fire_timer = randf() * fire_cooldown  # stagger initial volleys
	_choose_direction_toward_player()
	_update_sprite_for_direction()
	# iter 67: apply per-type sprite tint via self_modulate (independent of
	# the modulate channel used by hit-flash + aim-telegraph)
	if _sprite != null:
		_sprite.self_modulate = sprite_tint


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	_state_time += delta
	_fire_timer -= delta
	_direction_timer -= delta

	match enemy_type:
		"Heavy": _heavy_tick(delta)
		"Fast": _fast_tick(delta)
		_: _light_tick(delta)

	_update_forest_hide()


# Light (iter 26): commit-to-lane behavior. Per Pro Consult 004 H2 recipe:
# "lane-invader that advances aggressively and fires rarely." Light picks a
# direction with VERTICAL BIAS (prefer U/D unless player is strongly off-axis),
# commits for direction_commit_time=3.0s (set per-type via Spawner), fires on
# 3.5s cooldown. Player learns to dodge by exiting Light's committed lane.
func _light_tick(delta: float) -> void:
	if _direction_timer <= 0.0:
		_choose_direction_light_lane()
		_direction_timer = direction_commit_time

	var dir_vec: Vector2 = _direction_vector(direction)
	velocity = dir_vec * speed
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var alternates: Array = _perpendicular(direction)
		alternates.shuffle()
		for alt in alternates:
			if _try_step(_direction_vector(alt) * speed * delta):
				_turn_to(alt)
				_direction_timer = direction_commit_time
				return
		_turn_to(_opposite(direction))
		_direction_timer = direction_commit_time
		return

	if _fire_timer <= 0.0:
		_fire()
		_fire_timer = fire_cooldown


# Fast (iter 40): harassment rusher. Continuous fire while moving — no state
# machine, no aim adjustment, no telegraph, no LOS check. Fires in current
# facing direction every fire_cooldown=1.0s. Distinct from Light's rare-fire
# lane-commit and Heavy's paused-aim wind-up. Player can't safely hide behind
# walls from Fast because it sprays in motion direction rather than aiming.
# Speed 32 (highest) + direction_commit_time 0.8 = turns aggressively.
func _fast_tick(delta: float) -> void:
	if _direction_timer <= 0.0:
		_choose_direction_fast()
		_direction_timer = direction_commit_time

	var dir_vec: Vector2 = _direction_vector(direction)
	velocity = dir_vec * speed
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var alternates: Array = _perpendicular(direction)
		alternates.shuffle()
		for alt in alternates:
			if _try_step(_direction_vector(alt) * speed * delta):
				_turn_to(alt)
				_direction_timer = direction_commit_time
				return
		_turn_to(_opposite(direction))
		_direction_timer = direction_commit_time
		return

	if _fire_timer <= 0.0:
		_fire()
		_fire_timer = fire_cooldown


# Fast variant of direction choice: aggressive vertical bias. Turns to face
# player more often than Light's |dx| > 2× |dy| threshold — Fast uses
# 1.5× threshold, snapping into the player's horizontal lane more eagerly.
func _choose_direction_fast() -> void:
	if _player == null:
		return
	var to_player: Vector2 = _player.global_position - global_position
	var new_dir: int
	if absf(to_player.x) > absf(to_player.y) * 1.5:
		new_dir = Constants.Dir.R if to_player.x > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if to_player.y > 0 else Constants.Dir.U
	if new_dir != direction:
		_turn_to(new_dir)


# Light variant of direction choice: vertical bias. Light prefers U/D
# (ascending lanes) unless player is strongly off-axis horizontally
# (|dx| > 2× |dy|). Result: Light "invades" a vertical lane toward player
# rather than tracking precisely.
func _choose_direction_light_lane() -> void:
	if _player == null:
		return
	var to_player: Vector2 = _player.global_position - global_position
	var new_dir: int
	# Vertical bias: prefer vertical unless |dx| > 2× |dy| (strongly horizontal)
	if absf(to_player.x) > absf(to_player.y) * 2.0:
		new_dir = Constants.Dir.R if to_player.x > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if to_player.y > 0 else Constants.Dir.U
	if new_dir != direction:
		_turn_to(new_dir)


# Heavy: corridor-denier state machine (iter 24). CHASE → AIM_FIRE on LOS;
# AIM_FIRE → CHASE on lost LOS after min dwell. AIM_FIRE: stop, face
# player, fire bursts of burst_count shots at burst_interval, then cool
# down before refreshing burst.
func _heavy_tick(delta: float) -> void:
	match _state:
		State.CHASE:
			_heavy_chase_tick(delta)
		State.AIM_FIRE:
			_heavy_aim_fire_tick(delta)


func _heavy_chase_tick(delta: float) -> void:
	# iter 47: LKP-aware CHASE. LOS check first; on TRUE, save LKP + transition
	# to AIM_FIRE. LOS FALSE → direction picks come from _choose_direction_heavy_chase
	# which uses LKP state machine (CHASE_TO_LKP / SEARCH / WANDER).
	# iter 51: aim-cancel cooldown blocks re-AIM_FIRE entry for stunlock prevention.
	if _aim_cancel_timer > 0.0:
		_aim_cancel_timer -= delta
	if _aim_cancel_timer <= 0.0 and _player_in_line_of_sight():
		_save_lkp()
		_enter_aim_fire()
		return

	if _direction_timer <= 0.0:
		_choose_direction_heavy_chase()
		_direction_timer = direction_commit_time

	var dir_vec: Vector2 = _direction_vector(direction)
	velocity = dir_vec * speed
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var alternates: Array = _perpendicular(direction)
		alternates.shuffle()
		for alt in alternates:
			if _try_step(_direction_vector(alt) * speed * delta):
				_turn_to(alt)
				_direction_timer = direction_commit_time
				return
		_turn_to(_opposite(direction))
		_direction_timer = direction_commit_time
		return

	# iter 47: check if reached LKP (sets _reached_lkp + arms SEARCH window)
	if _lkp != null and not _reached_lkp:
		var dist: float = global_position.distance_to(_lkp)
		if dist < lkp_reach_radius:
			_reached_lkp = true
			_search_until = _state_time + lkp_search_duration

	# Heavy fires occasionally during CHASE too, but less than during AIM_FIRE
	if _fire_timer <= 0.0:
		_fire()
		_fire_timer = fire_cooldown


# iter 47: Heavy LKP-aware direction picking (Pro Consult 006 primary).
# Three phases by LKP state:
#   1. CHASE_TO_LKP: LKP set, not yet reached → bee-line cardinal toward LKP
#   2. SEARCH: reached LKP, within search window → random cardinal
#   3. WANDER: no LKP OR search expired → vertical-bias-upward random
# Light/Fast continue to use omniscient direction picks (their design).
func _choose_direction_heavy_chase() -> void:
	if _lkp == null:
		_choose_direction_wander()
		return
	if _reached_lkp:
		if _state_time < _search_until:
			_choose_direction_random_cardinal()
		else:
			# Search expired without re-acquire — clear LKP and wander
			_lkp = null
			_reached_lkp = false
			_choose_direction_wander()
		return
	# CHASE_TO_LKP: bee-line cardinal toward last known position
	var to_lkp: Vector2 = (_lkp as Vector2) - global_position
	var new_dir: int
	if absf(to_lkp.x) > absf(to_lkp.y):
		new_dir = Constants.Dir.R if to_lkp.x > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if to_lkp.y > 0 else Constants.Dir.U
	if new_dir != direction:
		_turn_to(new_dir)


# WANDER: vertical-bias-upward random cardinal. Heavy with no LKP patrols
# loosely upward (matches ascent direction so Heavy still creates pressure).
func _choose_direction_wander() -> void:
	# Weight: U=3, D=1, L=1, R=1 → 60% chance U, 40% spread among the rest
	var pool: Array = [Constants.Dir.U, Constants.Dir.U, Constants.Dir.U, Constants.Dir.D, Constants.Dir.L, Constants.Dir.R]
	var new_dir: int = pool[randi() % pool.size()]
	if new_dir != direction:
		_turn_to(new_dir)


# SEARCH: uniform random cardinal. Heavy reached LKP, hunts nearby briefly.
func _choose_direction_random_cardinal() -> void:
	var pool: Array = [Constants.Dir.U, Constants.Dir.D, Constants.Dir.L, Constants.Dir.R]
	var new_dir: int = pool[randi() % pool.size()]
	if new_dir != direction:
		_turn_to(new_dir)


# iter 47: save player position as LKP. Called when LOS is TRUE (entering
# AIM_FIRE) and also during AIM_FIRE to keep LKP fresh while player stays
# in cone — so when player slips out, LKP is the EXIT point of cone, not
# stale.
func _save_lkp() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_lkp = _player.global_position
	_reached_lkp = false
	_search_until = 0.0


func _heavy_aim_fire_tick(delta: float) -> void:
	# Stop moving, face player, fire bursts.
	velocity = Vector2.ZERO
	_face_player()
	_burst_timer -= delta
	# iter 47: refresh LKP while LOS holds during AIM_FIRE — when player breaks
	# out of cone, LKP captures the exit point (latest known pos), not the
	# entry point.
	if _player_in_line_of_sight():
		_save_lkp()

	if _burst_remaining > 0 and _burst_timer <= 0.0:
		# First shot of a fresh burst clears the wind-up telegraph.
		_clear_aim_telegraph()
		_fire()
		_burst_remaining -= 1
		_burst_timer = burst_interval
		return

	if _burst_remaining == 0:
		# Burst complete. Decide: cool down for refresh, or exit on lost LOS.
		if _state_time >= aim_fire_min_dwell:
			var still_los: bool = _player_in_line_of_sight()
			if not still_los:
				_state = State.CHASE
				_state_time = 0.0
				_direction_timer = 0.0  # reconsider direction immediately
				return
			# Player still aligned — wait for inter-burst cooldown then refresh.
			if _burst_timer <= -aim_fire_cooldown_between_bursts:
				_burst_remaining = burst_count
				_burst_timer = 0.0
				_state_time = 0.0


func _enter_aim_fire() -> void:
	_state = State.AIM_FIRE
	_state_time = 0.0
	_burst_remaining = burst_count
	# Wind-up: first shot delayed by aim_fire_reaction_time. Red telegraph
	# during this window so player sees Heavy lock onto them.
	_burst_timer = aim_fire_reaction_time
	_face_player()
	_apply_aim_telegraph()


func _apply_aim_telegraph() -> void:
	if _sprite == null:
		return
	# Preserve current alpha (forest hide manages alpha separately).
	var a: float = _sprite.modulate.a
	_sprite.modulate = aim_telegraph_color
	_sprite.modulate.a = a


func _clear_aim_telegraph() -> void:
	if _sprite == null:
		return
	var a: float = _sprite.modulate.a
	_sprite.modulate = Color(1, 1, 1, 1)
	_sprite.modulate.a = a


func _face_player() -> void:
	if _player == null:
		return
	var dx: float = _player.global_position.x - global_position.x
	var dy: float = _player.global_position.y - global_position.y
	var new_dir: int
	if absf(dx) > absf(dy):
		new_dir = Constants.Dir.R if dx > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if dy > 0 else Constants.Dir.U
	if new_dir != direction:
		direction = new_dir
		_update_sprite_for_direction()


# iter 35 (F005): Heavy vision check = CARDINAL FORWARD CONE in facing direction
# + RAYCAST obstruction through env layer. Replaces iter-24 omniscient LOS
# (which read raw player.global_position with no wall check — "too smart" per
# user iter-33 playtest). Per .research/battle-city-ai.md Stage 1.
func _player_in_line_of_sight() -> bool:
	if _player == null:
		return false
	var dir_vec: Vector2 = _direction_vector(direction)
	var to_player: Vector2 = _player.global_position - global_position
	# Project onto facing direction. Require positive forward distance + within range.
	var forward_dist: float = to_player.dot(dir_vec)
	if forward_dist <= 0.0 or forward_dist > aim_fire_range:
		return false
	# Perpendicular component (cone lateral). 90° rotation of dir_vec.
	var perp: Vector2 = Vector2(-dir_vec.y, dir_vec.x)
	var lateral_dist: float = absf(to_player.dot(perp))
	if lateral_dist > aim_fire_axis_tolerance:
		return false
	# Raycast: any env-layer body between us blocks vision.
	if vision_blocked_by_env:
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		if space_state != null:
			var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
				global_position, _player.global_position, 1  # env layer (mask)
			)
			query.exclude = [get_rid()]  # exclude self
			var hit: Dictionary = space_state.intersect_ray(query)
			if not hit.is_empty():
				return false  # wall between us
	return true


# BC forest convention: enemy is concealed (low alpha) when on a grass cell.
func _update_forest_hide() -> void:
	if _grass_tilemap == null or _sprite == null:
		return
	var local_pos: Vector2 = _grass_tilemap.to_local(global_position)
	var cell: Vector2i = _grass_tilemap.local_to_map(local_pos)
	var source_id: int = _grass_tilemap.get_cell_source_id(cell)
	_sprite.modulate.a = forest_hidden_alpha if source_id != -1 else forest_visible_alpha


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_spawn_death_effect()
		queue_free()
		return
	# iter 51: Heavy mid-AIM_FIRE → cancel wind-up, brief stun cooldown.
	# Cancel feedback IS the visual (white stagger flash overrides red telegraph);
	# regular _flash_hit gets skipped per iter-41 Heavy-AIM_FIRE rule anyway.
	if enemy_type == "Heavy" and _state == State.AIM_FIRE:
		_heavy_aim_cancel()
		return
	_flash_hit()


# iter 51: Heavy hit-cancel during AIM_FIRE. Interrupts wind-up burst,
# transitions back to CHASE, applies brief stagger flash, arms cooldown
# to prevent immediate re-AIM_FIRE entry (stunlock guard).
func _heavy_aim_cancel() -> void:
	_state = State.CHASE
	_state_time = 0.0
	_direction_timer = 0.0
	_burst_remaining = 0
	_burst_timer = 0.0
	_clear_aim_telegraph()
	_aim_cancel_timer = aim_cancel_cooldown
	# White stagger flash (overrides red — visual signal of successful cancel)
	if _sprite != null:
		var a: float = _sprite.modulate.a
		_sprite.modulate = Color(2.0, 2.0, 2.0, a)
		var tween: Tween = _sprite.create_tween()
		tween.tween_property(_sprite, "modulate", Color(1, 1, 1, a), 0.15)
	# iter 56: increment Spawner counter for [run] summary
	var spawner: Node = get_tree().get_root().find_child("Spawner", true, false)
	if spawner != null and "aim_cancels_landed" in spawner:
		spawner.aim_cancels_landed += 1


# iter 41: visual juice — brief white modulate on non-kill damage. Skip when
# Heavy is mid-AIM_FIRE so the red wind-up telegraph signal isn't stomped.
func _flash_hit() -> void:
	if _sprite == null:
		return
	if enemy_type == "Heavy" and _state == State.AIM_FIRE:
		return
	var saved_a: float = _sprite.modulate.a
	_sprite.modulate = Color(2.0, 2.0, 2.0, saved_a)
	var tween: Tween = _sprite.create_tween()
	tween.tween_property(_sprite, "modulate", Color(1, 1, 1, saved_a), 0.12)


# BC-style death burst — yellow ColorRect at enemy position, fades + scales
# up over 0.3s, then auto-frees. Parented to level (not enemy) so the
# tween survives the enemy's queue_free.
func _spawn_death_effect() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var burst: ColorRect = ColorRect.new()
	burst.size = Vector2(16, 16)
	burst.color = Color(1.0, 0.9, 0.3, 0.9)  # warm yellow burst
	burst.position = global_position - Vector2(8, 8)  # center on enemy
	burst.z_index = 50
	parent_node.add_child(burst)
	var tween: Tween = burst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(burst, "modulate:a", 0.0, 0.3)
	tween.tween_property(burst, "scale", Vector2(1.6, 1.6), 0.3)
	tween.chain().tween_callback(burst.queue_free)


func _choose_direction_toward_player() -> void:
	var to_player: Vector2 = _player.global_position - global_position
	var new_dir: int
	if absf(to_player.x) > absf(to_player.y):
		new_dir = Constants.Dir.R if to_player.x > 0 else Constants.Dir.L
	else:
		new_dir = Constants.Dir.D if to_player.y > 0 else Constants.Dir.U
	if new_dir != direction:
		_turn_to(new_dir)


func _turn_to(new_dir: int) -> void:
	direction = new_dir
	_update_sprite_for_direction()
	global_position = global_position.snapped(Vector2(grid, grid))


func _update_sprite_for_direction() -> void:
	if _sprite != null and direction < sprite_dir_offsets.size():
		_sprite.frame = sprite_base_frame + sprite_dir_offsets[direction]


func _try_step(motion: Vector2) -> bool:
	var test_collision: KinematicCollision2D = move_and_collide(motion, true)
	return test_collision == null


func _direction_vector(dir: int) -> Vector2:
	return Vector2(1, 0).rotated(Constants.dir_to_rotation(dir))


func _perpendicular(dir: int) -> Array:
	match dir:
		Constants.Dir.U, Constants.Dir.D:
			return [Constants.Dir.L, Constants.Dir.R]
		_:
			return [Constants.Dir.U, Constants.Dir.D]


func _opposite(dir: int) -> int:
	match dir:
		Constants.Dir.U: return Constants.Dir.D
		Constants.Dir.D: return Constants.Dir.U
		Constants.Dir.L: return Constants.Dir.R
		_: return Constants.Dir.L


func _fire() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	var muzzle_offset: Vector2 = _direction_vector(direction) * 8.0
	var spawn_pos: Vector2 = global_position + muzzle_offset
	bullet.set("damage", bullet_damage)  # iter 52: per-type damage
	get_parent().add_child(bullet)
	bullet.start(spawn_pos, direction, bullet_target_mask)
