extends CharacterBody2D

# Enemy types (iter 24 behavioral split): "Light" (naive chaser) /
# "Heavy" (corridor-denier: pauses + bursts when aligned with player).
# Set by Spawner.gd at instantiate time per ENEMY_TYPES table.
enum State { CHASE, AIM_FIRE }

# iter 101 (review-fix): explicit domain signals replace tree_exited piggy-
# backing and find_child("Spawner") string lookup. `killed` fires
# synchronously from take_damage when hp drops to 0; `aim_canceled` fires
# only when a pending Heavy burst was actually interrupted.
signal killed
signal aim_canceled

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
# arc-4 iter 113 (Round 13 Phase 2, sanctioned substrate write ×4):
# SCOUT_TELEGRAPH outline flag. Set by Spawner at instantiate-time
# when the player owns has_scout_telegraph AND this enemy is a Light.
# When true, _ready overrides self_modulate with a warm yellow tint
# so the scout reads as visible/tagged from spawn. Default false
# preserves arc-2/3 baseline.
@export var scout_telegraph_outline: bool = false
# iter 86: per-type sprite scale — Heavy bigger (toughness), Fast smaller
# (agility), Light default. Adds visual ID layer alongside iter-67 color tint.
@export var sprite_scale: float = 1.0
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
@export var aim_telegraph_color: Color = Color(1.3, 0.4, 0.4, 1.0)
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
# arc-4 iter 63 (Round 9a): breach-mode HP-bar HUD (sanctioned per the
# iter-062 Round-9 amendment). Built only when the parent level has
# breach mode enabled AND max_hp > 1; visible only while damaged.
const HP_BAR_WIDTH: float = 16.0
var _hp_bar_bg: ColorRect = null
var _hp_bar_fg: ColorRect = null


func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	# iter 101 (review-fix): sibling lookups instead of root-walk find_child;
	# avoids ambiguity during scene reload windows and binds lifetime to the
	# level instead of the global scene tree.
	var level: Node = get_parent()
	if level != null:
		_player = level.get_node_or_null("PlayerTank") as Node2D
		_grass_tilemap = level.get_node_or_null("Tiles/Grass") as TileMapLayer
		# arc-4 iter 63 (Round 9a): breach-mode HP-bar HUD — built only when
		# the parent level has breach mode enabled AND max_hp > 1 (no point
		# in a bar for one-shot enemies).
		if "breach_mode_enabled" in level and level.breach_mode_enabled and max_hp > 1:
			_build_hp_bar()
	_fire_timer = randf() * fire_cooldown  # stagger initial volleys
	_choose_direction_toward_player()
	_update_sprite_for_direction()
	# iter 67: apply per-type sprite tint via self_modulate (independent of
	# the modulate channel used by hit-flash + aim-telegraph)
	# iter 86: apply per-type sprite scale (Heavy 1.15, Fast 0.85, Light 1.0)
	if _sprite != null:
		_sprite.self_modulate = sprite_tint
		_sprite.scale = Vector2(sprite_scale, sprite_scale)
		# arc-4 iter 113 (Round 13 Phase 2): SCOUT_TELEGRAPH override.
		# When set by Spawner (player has has_scout_telegraph AND this is
		# a Light enemy), replace the per-type tint with a warm yellow so
		# the scout is visible/tagged from spawn. Sentence: "helps me
		# climb tutorial_choke by changing how I see Light scouts."
		if scout_telegraph_outline:
			_sprite.self_modulate = Color(1.0, 0.95, 0.4, 1.0)


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
	# arc-4 iter 090 (P1-1 from code-review-iter-090.md): idempotency
	# guard. queue_free() is deferred, so a same-frame second damage
	# source (MORTAR AoE + bullet, RAM swing + collision, beam tick
	# overlap) can re-enter take_damage on an already-dying enemy.
	# Without this guard, killed.emit() fires twice → Spawner counts
	# double, ammo drops re-roll, XP doubles.
	if hp <= 0:
		return
	hp -= amount
	if hp <= 0:
		killed.emit()  # iter 101: synchronous kill notification (Spawner counts here)
		_spawn_death_effect()
		queue_free()
		return
	# arc-4 iter 63 (Round 9a): reflect the new HP in the breach-mode bar.
	_update_hp_bar()
	# iter 51: Heavy mid-AIM_FIRE → cancel wind-up, brief stun cooldown.
	# Cancel feedback IS the visual (white stagger flash overrides red telegraph);
	# regular _flash_hit gets skipped per iter-41 Heavy-AIM_FIRE rule anyway.
	if enemy_type == "Heavy" and _state == State.AIM_FIRE:
		# iter 101 (review-fix A8): only count a cancel if there was a pending shot
		# — between-bursts cooldown still in AIM_FIRE state shouldn't inflate the
		# counter when no wind-up was actually interrupted.
		var had_pending_shot: bool = _burst_remaining > 0 and _burst_timer > 0.0
		_heavy_aim_cancel()
		if had_pending_shot:
			aim_canceled.emit()
		return
	_flash_hit()


# arc-4 iter 63 (Round 9a): build the breach-mode HP-bar HUD — two
# small ColorRects (dark bg + red fg) above the sprite. Visible only
# while damaged (toggled in _update_hp_bar on take_damage).
func _build_hp_bar() -> void:
	_hp_bar_bg = ColorRect.new()
	_hp_bar_bg.name = "HPBarBG"
	_hp_bar_bg.size = Vector2(HP_BAR_WIDTH, 2)
	_hp_bar_bg.position = Vector2(-HP_BAR_WIDTH * 0.5, -12)
	_hp_bar_bg.color = Color(0.08, 0.08, 0.1, 0.85)
	_hp_bar_bg.visible = false
	_hp_bar_bg.z_index = 50
	_hp_bar_bg.mouse_filter = 2
	add_child(_hp_bar_bg)
	_hp_bar_fg = ColorRect.new()
	_hp_bar_fg.name = "HPBarFG"
	_hp_bar_fg.size = Vector2(HP_BAR_WIDTH, 2)
	_hp_bar_fg.position = Vector2(-HP_BAR_WIDTH * 0.5, -12)
	_hp_bar_fg.color = Color(0.95, 0.3, 0.3, 1.0)
	_hp_bar_fg.visible = false
	_hp_bar_fg.z_index = 51
	_hp_bar_fg.mouse_filter = 2
	add_child(_hp_bar_fg)


# arc-4 iter 63: reflect the current hp/max_hp in the HP bar — visible
# + fg width tracks the damage ratio. Called from take_damage on every
# non-fatal hit; a no-op if the bar was never built (arc-2/3 or
# max_hp = 1).
func _update_hp_bar() -> void:
	if _hp_bar_bg == null or _hp_bar_fg == null or max_hp <= 0:
		return
	_hp_bar_bg.visible = true
	_hp_bar_fg.visible = true
	var ratio: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	_hp_bar_fg.size = Vector2(HP_BAR_WIDTH * ratio, 2.0)


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
	# iter 101: counter increment moved to take_damage caller (gated on
	# `_burst_remaining > 0` so cooldown hits don't inflate the metric).


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
	# iter 78 (Q5 priority 4 "explore roguelite mechanics"): Heavy 25% drop
	# chance for HP pickup. Player walking over → +1 HP (clamped to max_hp).
	if enemy_type == "Heavy" and randf() < 0.25:
		_spawn_hp_pickup(parent_node)
	# iter 82: Light 10% drop chance for shield. 2s invulnerability.
	# iter 88 (Pro Consult 008 "Legibility Lock"): Speed pickup CUT — Fast
	# already owns cyan/urgency, temp speed alters control feel during combat
	# (cognitive burden + visual collision with Fast enemy tint).
	elif enemy_type == "Light" and randf() < 0.10:
		_spawn_shield_pickup(parent_node)


# iter 78: HP pickup spawned at Heavy death position. Inline Area2D (no
# separate scene). Despawns after 8s. Adds tactical decision: detour for
# HP after defeating Heavy, or push past.
func _spawn_hp_pickup(parent_node: Node) -> void:
	var pickup: Area2D = Area2D.new()
	pickup.collision_layer = 0
	pickup.collision_mask = 2  # player layer
	pickup.global_position = global_position
	pickup.z_index = 45
	# Green plus-symbol visual: 2 perpendicular ColorRects (horiz + vert bars)
	var horiz: ColorRect = ColorRect.new()
	horiz.size = Vector2(8, 3)
	horiz.color = Color(0.3, 0.95, 0.4, 1.0)
	horiz.position = Vector2(-4, -1.5)
	pickup.add_child(horiz)
	var vert: ColorRect = ColorRect.new()
	vert.size = Vector2(3, 8)
	vert.color = Color(0.3, 0.95, 0.4, 1.0)
	vert.position = Vector2(-1.5, -4)
	pickup.add_child(vert)
	# Collision shape (8x8 square — covers the plus extent)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rs: RectangleShape2D = RectangleShape2D.new()
	rs.size = Vector2(8, 8)
	shape.shape = rs
	pickup.add_child(shape)
	# body_entered: heal player, free pickup
	pickup.body_entered.connect(func(body):
		if body.has_method("heal"):
			body.heal(1)
			pickup.queue_free()
	)
	# 8s despawn timer
	var timer: Timer = Timer.new()
	timer.wait_time = 8.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(pickup.queue_free)
	pickup.add_child(timer)
	parent_node.add_child(pickup)


# iter 92 (visual budget): _spawn_speed_pickup removed. Speed pickup was
# cut iter 88 per Pro Consult 008. Function was dead code after iter 88.


# iter 82: Shield pickup spawned at Light death position. Light 10% drop
# rate (rarer because Light spawns frequently). 2s invulnerability on
# overlap. Pale-blue diamond visual.
func _spawn_shield_pickup(parent_node: Node) -> void:
	var pickup: Area2D = Area2D.new()
	pickup.collision_layer = 0
	pickup.collision_mask = 2
	pickup.global_position = global_position
	pickup.z_index = 45
	# Pale-blue square visual with white inner accent ("shield" suggests defense)
	var outer: ColorRect = ColorRect.new()
	outer.size = Vector2(8, 8)
	outer.color = Color(0.7, 0.85, 1.0, 1.0)
	outer.position = Vector2(-4, -4)
	pickup.add_child(outer)
	var inner: ColorRect = ColorRect.new()
	inner.size = Vector2(2, 2)
	inner.color = Color(1.0, 1.0, 1.0, 1.0)
	inner.position = Vector2(-1, -1)
	pickup.add_child(inner)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rs: RectangleShape2D = RectangleShape2D.new()
	rs.size = Vector2(8, 8)
	shape.shape = rs
	pickup.add_child(shape)
	pickup.body_entered.connect(func(body):
		if body.has_method("apply_shield"):
			body.apply_shield(2.0)
			pickup.queue_free()
	)
	var timer: Timer = Timer.new()
	timer.wait_time = 8.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(pickup.queue_free)
	pickup.add_child(timer)
	parent_node.add_child(pickup)


func _choose_direction_toward_player() -> void:
	# iter 101 (review-fix): defensive null guard — _ready calls this before
	# any physics tick, and Enemy.tscn loaded standalone (editor "play scene",
	# fresh test_runner) has no PlayerTank in tree.
	if _player == null or not is_instance_valid(_player):
		return
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
	# arc-4 iter 109 (Round 12 Gap 2): tag the bullet with its source
	# enemy type so the player's RunRecap.killer names the actual
	# cause instead of "shell impact". The field is on Bullet.gd
	# (arc-4 substrate write ×9); set() is defensive in case a
	# non-Bullet scene is wired here.
	bullet.set("source_label", "%s bullet" % enemy_type.to_lower())
	get_parent().add_child(bullet)
	bullet.start(spawn_pos, direction, bullet_target_mask)
