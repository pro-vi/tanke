extends Node2D

const RosterT = preload("res://scripts/Roster.gd")
# arc-4 iter 58 (Round 8c): enemy ammo drops. A killed enemy has
# AMMO_DROP_CHANCE to drop an AmmoPickup at its death position. Gated on
# breach mode (the player carries a Loadout); arc-2/3 drops nothing.
const AmmoPickupScene = preload("res://scenes/AmmoPickup.tscn")
const AMMO_DROP_CHANCE: float = 0.4
# arc-4 iter 63 (Round 9a): enemy HP bumped in breach mode so HEAT /
# beam / multi-hit gameplay reads. arc-2/3 (breach_mode_enabled=false)
# keeps the original max_hp values bit-identical.
const BREACH_HP_BONUS: Dictionary = {"Light": 1, "Heavy": 1, "Fast": 1}

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var max_spawn_attempts: int = 8
@export var map_x_margin: float = 4.0
@export var map_width: float = 320.0
@export var spawn_top_edge_offset: float = 8.0  # spawn this many px INSIDE the visible viewport top, so user sees enemies "driving in" from the edge (BC-style)

# iter 011 (arc 3): per-stage roster integration. When stage_number > 0 the
# spawner runs in ORIGINALS mode: 20 total enemies, max 4 simultaneous,
# Roster.armored_probability(stage)-driven Light/Heavy mix, canonical
# 3-point spawn positions (Tanks: stage cells (1,1)/(12,1)/(24,1)),
# stage_cleared signal on full kill. Default stage_number=0 preserves
# arc-2 procedural behavior bit-identical (no code paths changed for
# stage_number==0; only new branches added).
@export var stage_number: int = 0
signal stage_cleared
var _total_spawns_this_stage: int = 0
# Tanks canonical spawn points: stage cells (1, 1) / (12, 1) / (24, 1) at
# top row. arc-3 scene coords add (col_offset=7, row_offset=2). At 8 px/tile
# with cell-center anchoring (+4 each axis): (4 + 8*8, 4 + 8*3) and so on.
const OG_SPAWN_POINTS: Array = [
	# iter 019 (F002): y=44 (was 28) follows row_offset 2→4 shift. Stage row 1
	# = arc-3 scene row 5 = screen y 5*8+4 = 44. Without this update enemies
	# would spawn 2 cells above the BC playfield top (visible only briefly
	# before walls/level catch them).
	Vector2(68, 44),    # Tanks stage col 1 → arc-3 scene col 8 → screen x 4 + 8*8 = 68
	Vector2(156, 44),   # Tanks stage col 12 → arc-3 scene col 19 → screen x 4 + 19*8 = 156
	Vector2(252, 44),   # Tanks stage col 24 → arc-3 scene col 31 → screen x 4 + 31*8 = 252
]
# Ascender pressure (iter 12)
@export var ascent_lookahead_seconds: float = 1.5  # spawn this many seconds-of-ascent further ahead
@export var stall_threshold: float = 0.3  # rows/sec; below this counts as stalling
@export var stall_pressure_after: float = 4.0  # seconds of stall before pressure kicks in
@export var stall_interval_multiplier: float = 0.5  # spawn_interval × this when stalled (faster)
@export var telegraph_lead_time: float = 0.5  # seconds the warning marker shows before spawn
@export var velocity_ema_alpha: float = 2.0  # EMA smoothing factor; higher = more responsive

# Enemy type table (iter 16; behavioral split iter 24 Heavy + iter 26 Light).
# Per Pro Consult 004 H2 recipe: Light = "lane-invader, advances aggressively,
# fires rarely"; Heavy = "corridor-denier, pauses, fires bursts."
# direction_commit_time per type — Light commits to a lane longer (3.0s);
# Heavy stays at 0.8s for responsiveness to player movement.
const ENEMY_TYPES: Array = [
	{
		"name": "Light",
		"weight": 0.7,
		"base_frame": 8,
		"speed": 24.0,
		"max_hp": 1,
		"fire_cooldown": 3.5,  # iter 26: fires rarely (was 1.5)
		"direction_commit_time": 3.0,  # iter 26: commits to a lane (was 0.8)
		"bullet_damage": 1,  # iter 52
		"sprite_tint": Color(1.0, 1.0, 1.0, 1.0),  # iter 67: white (default)
		"sprite_scale": 1.0,  # iter 86
	},
	{
		"name": "Heavy",
		"weight": 0.3,
		"base_frame": 32,
		"speed": 14.0,
		"max_hp": 2,
		"fire_cooldown": 0.8,
		"direction_commit_time": 0.8,
		"bullet_damage": 2,  # iter 52: corridor-denier hits harder
		"sprite_tint": Color(1.0, 1.0, 1.0, 1.0),  # iter 67: white (telegraph handles ID)
		"sprite_scale": 1.15,  # iter 86: bigger = toughness signal
		"armored": true,  # arc-4 iter 23: AP/HE mitigated; only HEAT bypasses
	},
	# iter 40: 3rd type "Fast" — harassment rusher. Continuous fire while
	# moving (no state machine, no aim, no telegraph). Distinct from Light
	# (rare-fire lane-invader) and Heavy (paused-aim corridor-denier).
	# Unlocks crit 6 anchor 3 ("3+ types with distinct movement AND firing").
	{
		"name": "Fast",
		"weight": 0.0,  # band-overridden; never spawned via fallback weight
		"base_frame": 16,
		"speed": 32.0,
		"max_hp": 1,
		"fire_cooldown": 1.0,
		"direction_commit_time": 0.8,
		"bullet_damage": 1,  # iter 52: volume-based pressure, not per-bullet
		"sprite_tint": Color(0.55, 0.95, 1.0, 1.0),  # iter 67: cyan (F009 fix)
		"sprite_scale": 0.85,  # iter 86: smaller = agility signal
	},
]

# Ascent director (iter 22 scaffold; iter 27 adds per-band max_alive +
# guarantee_first_type encounter rules). Each band differs in:
# - depth_max: upper bound for band membership
# - type_weights: spawn pool override
# - interval_mult: spawn cadence multiplier on base spawn_interval
# - max_alive: cap on simultaneously-alive enemies (overrides global)
# - guarantee_first_type: first spawn after entering this band is this type
#   (sets the tone before random weights take over)
const DEPTH_BANDS: Array = [
	{
		"name": "warmup",
		"depth_max": 8,
		"type_weights": {"Light": 1.0, "Heavy": 0.0, "Fast": 0.0},
		"interval_mult": 1.5,  # iter 90: slower spawn pace for onboarding
		"max_alive": 2,  # iter 91: truly sparse onboarding — 1-2 enemies max
		"guarantee_first_type": null,
	},
	{
		"name": "first_push",
		"depth_max": 20,
		"type_weights": {"Light": 0.5, "Heavy": 0.3, "Fast": 0.2},  # iter 68: +0.1 Heavy (Q1 "less heavy")
		"interval_mult": 1.0,
		"max_alive": 10,
		"guarantee_first_type": "Heavy",  # iter 68: signal "heavies arrive" at first_push entry
	},
	{
		"name": "heavy_gate",
		"depth_max": 40,
		"type_weights": {"Light": 0.20, "Heavy": 0.6, "Fast": 0.20},  # iter 89: more Heavy-dominant (stop-and-aim)
		"interval_mult": 0.7,  # iter 89: denser spawns for sustained pressure
		"max_alive": 6,  # iter 89: fewer concurrent → forces individual engagement
		"guarantee_first_type": "Heavy",
	},
	{
		"name": "rush",
		"depth_max": 9999,
		"type_weights": {"Light": 0.2, "Heavy": 0.1, "Fast": 0.7},  # iter 90: more Fast-dominant chaos
		"interval_mult": 0.6,  # iter 90: faster cadence — more enemies on screen
		"max_alive": 18,  # iter 90: higher cap for chaos
		"guarantee_first_type": "Fast",
	},
]

# Graduated stall pressure (iter 27, replacing binary multiplier):
# stall_time < stall_pressure_after  → mult = 1.0 (no pressure)
# stall_time = stall_pressure_after  → mult = 1.0 (start ramp)
# stall_time = stall_full_pressure_at → mult = stall_min_multiplier (capped)
@export var stall_full_pressure_at: float = 12.0  # seconds for full pressure
@export var stall_min_multiplier: float = 0.4  # floor (max 2.5× spawn rate)
# META mitigation (iter 28, per Pro Consult 004 META: threats-from-behind):
# When player has stalled past stall_below_spawn_after, NEXT spawn comes
# from below viewport (pushes player upward via fear-of-encirclement).
# Rate-limited so it doesn't dominate every spawn cycle.
@export var stall_below_spawn_after: float = 12.0  # iter 35 (F008): raised 8→12 to reduce false-positive below-spawns during slow navigation
@export var below_spawn_cooldown: float = 10.0  # iter 35 (F008): raised 6→10 to reduce frequency
@export var spawn_bottom_edge_offset: float = 8.0  # px below viewport bottom (telegraph stays visible)
# Depth pressure landmarks (iter 48, Pro Consult 006 secondary). Every
# depth_gate_step rows, spawn a recognizable visual "gate" in the world —
# two yellow posts at viewport edges + center label "* DEPTH N *". Persistent
# (world-static); marks ascent progress so player remembers "I pushed past 80m"
# instead of "the maze kept scrolling."
@export var depth_gate_step: int = 20
@export var depth_gate_post_color: Color = Color(1.0, 0.85, 0.2, 0.9)
@export var depth_gate_text_color: Color = Color(1.0, 0.95, 0.5, 1.0)
var _last_gate_depth: int = 0
# Band-marker visual cue (iter 64, Phase A iter 3, user iter-60 Q5 priority 1
# "interesting local map"). On band transition, flash band-themed color tint
# + center label "ENTERING <BAND>" for ~2s. Makes ascent feel authored —
# user remembers "I pushed into heavy_gate" not "the maze kept scrolling."
const BAND_COLORS: Dictionary = {
	"warmup": Color(0.6, 0.9, 0.6, 1.0),       # pale green — peaceful
	"first_push": Color(1.0, 0.95, 0.5, 1.0),  # light yellow — caution
	"heavy_gate": Color(1.0, 0.55, 0.2, 1.0),  # orange — danger
	"rush": Color(1.0, 0.35, 0.35, 1.0),       # red — high pressure
}

var _player: Node2D
var _camera: Camera2D
var _enemies_alive: int = 0
var _viewport_half_height: float = 120.0

# Spawn accumulator (replaces Timer; allows live spawn_interval modulation)
var _spawn_accumulator: float = 0.0

# Ascent tracking (iter 12 + iter 22 depth bands)
var _last_player_y: float = 0.0
var _player_start_y: float = 0.0  # iter 22: depth = (start - current) / 16
var _max_depth_reached: int = 0   # iter 22: peak depth in rows
var _ascent_velocity: float = 0.0  # rows/sec, positive = ascending
var _stall_time: float = 0.0
var _last_band_name: String = ""  # log when band changes
var _band_first_spawn_pending: bool = false  # iter 27: trigger guarantee_first_type on band entry
var _last_below_spawn_time: float = -1000.0  # iter 28: timestamp of last below-spawn (running seconds)
var _elapsed_time: float = 0.0  # iter 28: accumulator since spawner ready

# Counters for iter-4 pre-mortem prediction #2 (rejections per 10 ticks).
var spawns_total: int = 0
var rejections_total: int = 0
var ticks_total: int = 0
# iter 31: ascender-metric instrumentation (Pro Consult 005 H4)
var spawn_origin_top: int = 0
var spawn_origin_below: int = 0
# iter 43: death-screen summary counter. iter 101 (review-fix): now driven
# by Enemy.killed signal (hp<=0 path only), not tree_exited — so scene
# reload / future non-kill frees don't inflate the metric.
var enemies_killed: int = 0
# iter 56 (instrumentation for iter-60 diagnostic). iter 101 (review-fix):
# driven by Enemy.aim_canceled signal, gated on a real pending burst.
var aim_cancels_landed: int = 0


func _ready() -> void:
	_player = get_parent().get_node_or_null("PlayerTank")
	_camera = get_parent().get_node_or_null("Camera2D")
	_viewport_half_height = float(ProjectSettings.get_setting("display/window/size/viewport_height", 240)) * 0.5
	if _player != null:
		_last_player_y = _player.global_position.y
		_player_start_y = _player.global_position.y


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# iter 101 (review-fix): suppress spawn cadence after player death so
	# enemies + band markers don't keep appearing on the death screen.
	if _player.get("_dead") == true:
		return
	_elapsed_time += delta  # iter 28
	_update_ascent_velocity(delta)
	_update_stall_time(delta)
	_check_depth_gates()  # iter 48

	var current_interval: float = _current_spawn_interval()
	_spawn_accumulator += delta
	if _spawn_accumulator >= current_interval:
		_spawn_accumulator -= current_interval
		_try_spawn()


func _update_ascent_velocity(delta: float) -> void:
	if delta <= 0.0:
		return
	# rows ascended this frame (player moving up = decreasing y)
	var dy_rows: float = (_last_player_y - _player.global_position.y) / 16.0
	var instant: float = dy_rows / delta
	# EMA smoothing
	var alpha: float = clampf(velocity_ema_alpha * delta, 0.0, 1.0)
	_ascent_velocity = lerpf(_ascent_velocity, instant, alpha)
	_last_player_y = _player.global_position.y
	# iter 22: track peak depth for band lookup
	var current_depth: int = int(maxf(0.0, (_player_start_y - _player.global_position.y) / 16.0))
	if current_depth > _max_depth_reached:
		_max_depth_reached = current_depth


# iter 22 ASCENT DIRECTOR: which encounter band is the player currently in?
# Returns the first band whose depth_max >= current peak depth.
func _current_band() -> Dictionary:
	for band in DEPTH_BANDS:
		if _max_depth_reached <= band.depth_max:
			return band
	return DEPTH_BANDS[-1]


func _update_stall_time(delta: float) -> void:
	if _ascent_velocity < stall_threshold:
		_stall_time += delta
	else:
		_stall_time = maxf(0.0, _stall_time - delta * 2.0)  # decay faster than build


func _current_spawn_interval() -> float:
	# iter 011: ORIGINALS mode flat cadence — no ascent / stall logic applies.
	if stage_number > 0:
		return spawn_interval
	# iter 22: band interval_mult; iter 27: graduated stall multiplier.
	var band: Dictionary = _current_band()
	var base: float = spawn_interval * float(band.get("interval_mult", 1.0))
	return base * _current_stall_multiplier()


# iter 011: ORIGINALS-mode spawn entry. Caps at TOTAL_ENEMIES_PER_STAGE = 20
# spawns + MAX_SIMULTANEOUS = 4 alive (Tanks canonical from Roster.gd).
# Spawn position is one of the 3 canonical OG_SPAWN_POINTS (random).
func _try_spawn_originals() -> void:
	ticks_total += 1
	if enemy_scene == null:
		return
	if _total_spawns_this_stage >= RosterT.TOTAL_ENEMIES_PER_STAGE:
		return
	if _enemies_alive >= RosterT.MAX_SIMULTANEOUS:
		return
	var spawn_pos: Vector2 = OG_SPAWN_POINTS[randi() % OG_SPAWN_POINTS.size()]
	if _is_blocked(spawn_pos):
		rejections_total += 1
		return
	var plan := {"pos": spawn_pos, "is_below": false, "telegraph_pos": spawn_pos}
	_telegraph_then_spawn(plan)
	spawns_total += 1
	_total_spawns_this_stage += 1
	if ticks_total % 5 == 0:
		print("[spawner-og] stage %d  tick %d  spawned %d/%d  alive %d/%d" % [
			stage_number, ticks_total, _total_spawns_this_stage,
			RosterT.TOTAL_ENEMIES_PER_STAGE, _enemies_alive, RosterT.MAX_SIMULTANEOUS
		])


# iter 27: graduated stall multiplier replacing iter-12 binary stall_interval_multiplier.
# Linear ramp from 1.0 at stall_pressure_after to stall_min_multiplier at
# stall_full_pressure_at. Capped at floor. The original binary
# stall_interval_multiplier export is now interpreted as the floor target
# but kept for backward compatibility.
func _current_stall_multiplier() -> float:
	if _stall_time <= stall_pressure_after:
		return 1.0
	var span: float = maxf(stall_full_pressure_at - stall_pressure_after, 0.01)
	var t: float = clampf((_stall_time - stall_pressure_after) / span, 0.0, 1.0)
	return lerpf(1.0, stall_min_multiplier, t)


func _try_spawn() -> void:
	# iter 011: ORIGINALS mode early-branch. Default stage_number=0 falls
	# through to the unchanged arc-2 procedural path below.
	if stage_number > 0:
		_try_spawn_originals()
		return
	ticks_total += 1
	if enemy_scene == null:
		return
	# iter 22+27: band transition + first-spawn guarantee setup
	var band: Dictionary = _current_band()
	if band.name != _last_band_name:
		print("[spawner] band ENTER %s at depth %d" % [band.name, _max_depth_reached])
		_last_band_name = band.name
		_band_first_spawn_pending = true
		_spawn_band_marker(band.name)  # iter 64
	# iter 27: per-band max_alive override
	var band_cap: int = int(band.get("max_alive", max_enemies))
	var cap_hit: bool = _enemies_alive >= band_cap
	if not cap_hit:
		var spawn_plan: Variant = _find_valid_spawn()
		if spawn_plan == null:
			rejections_total += 1
		else:
			_telegraph_then_spawn(spawn_plan)
			spawns_total += 1
	if ticks_total % 5 == 0:
		var cap_marker: String = " CAP" if cap_hit else ""
		print("[spawner] tick %d: spawns=%d (top=%d below=%d) rejections=%d alive=%d/%d%s depth=%d band=%s ascent=%.2f stall=%.1fs interval=%.2fs stallMult=%.2f" % [ticks_total, spawns_total, spawn_origin_top, spawn_origin_below, rejections_total, _enemies_alive, band_cap, cap_marker, _max_depth_reached, band.name, _ascent_velocity, _stall_time, _current_spawn_interval(), _current_stall_multiplier()])


# Compute spawn plan. Top-edge by default (iter 12+). iter 28: if player
# has stalled past threshold, spawn from BELOW (threats-from-behind).
# iter 30 (Pro Consult 005 H2): below-spawn telegraph is placed INSIDE
# the viewport edge — fairness-not-cheap.
# iter 101 (review-fix): returns a Dictionary {pos, is_below, telegraph_pos}
# instead of stashing pending state on `self`. Prior pattern corrupted
# under overlapping awaits when interval < telegraph_lead_time (rush band
# stalled: 0.48s interval vs 0.5s telegraph).
# `_last_below_spawn_time` is no longer armed here — it moves to the
# post-await success branch so rejected/cancelled spawns don't drain the
# below-spawn cooldown.
func _find_valid_spawn() -> Variant:
	var camera_center_y: float = _player.global_position.y
	if _camera != null and is_instance_valid(_camera):
		camera_center_y = _camera.get_screen_center_position().y
	var use_below: bool = _should_spawn_below()
	var spawn_y: float
	if use_below:
		var screen_bottom: float = camera_center_y + _viewport_half_height
		spawn_y = screen_bottom + spawn_bottom_edge_offset
	else:
		var screen_top: float = camera_center_y - _viewport_half_height
		var lookahead_px: float = maxf(0.0, _ascent_velocity) * 16.0 * ascent_lookahead_seconds
		spawn_y = screen_top + spawn_top_edge_offset - lookahead_px
	for i in max_spawn_attempts:
		var x: float = randf_range(map_x_margin, map_width - map_x_margin)
		var candidate: Vector2 = Vector2(x, spawn_y)
		if _is_blocked(candidate):
			continue
		var telegraph_pos: Vector2 = candidate
		if use_below and _camera != null and is_instance_valid(_camera):
			var visible_bottom: float = _camera.get_screen_center_position().y + _viewport_half_height
			telegraph_pos = Vector2(x, visible_bottom - 12.0)  # 12px inside bottom
		return {"pos": candidate, "is_below": use_below, "telegraph_pos": telegraph_pos}
	return null


# iter 28: should this spawn come from below the player? Yes when:
# (1) player has stalled past stall_below_spawn_after seconds AND
# (2) below_spawn_cooldown has elapsed since last below-spawn.
func _should_spawn_below() -> bool:
	if _stall_time < stall_below_spawn_after:
		return false
	if _elapsed_time - _last_below_spawn_time < below_spawn_cooldown:
		return false
	return true


func _is_blocked(pos: Vector2) -> bool:
	var world: World2D = get_world_2d()
	if world == null:
		return false
	var space_state: PhysicsDirectSpaceState2D = world.direct_space_state
	if space_state == null:
		return false
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = 513  # Environment (1) + Water (512); both block tank traversal
	var results: Array = space_state.intersect_point(params, 1)
	return results.size() > 0


# Battle-City-style spawn telegraph: brief warning marker, then enemy
# instantiates after telegraph_lead_time. iter 30 (Pro Consult 005 H2):
# for below-spawn, the marker is placed INSIDE the viewport bottom edge
# (visible warning), while enemy still spawns at the off-screen `pos`.
# iter 30 (Pro Consult 005 H5): re-check BAND cap after await, not just
# global max_enemies.
func _telegraph_then_spawn(plan: Dictionary) -> void:
	# iter 101 (review-fix): all per-coroutine state is captured into locals
	# here — overlapping coroutines no longer clobber each other's intent.
	var pos: Vector2 = plan["pos"]
	var is_below: bool = plan["is_below"]
	var telegraph_pos: Vector2 = plan["telegraph_pos"]
	var marker: ColorRect = ColorRect.new()
	marker.size = Vector2(8, 4)
	# Below-spawn: red marker at viewport-bottom edge (visible warning)
	# Top-spawn: yellow marker at spawn position
	if is_below:
		marker.color = Color(1.0, 0.3, 0.3, 0.9)  # red for "behind" warning
		marker.position = telegraph_pos - Vector2(4, 2)
	else:
		marker.color = Color(1.0, 0.85, 0.2, 0.9)  # yellow for top spawn
		marker.position = pos - Vector2(4, 2)
	marker.z_index = 100
	get_parent().add_child(marker)
	await get_tree().create_timer(telegraph_lead_time).timeout
	if is_instance_valid(marker):
		marker.queue_free()
	# iter 30: re-check BAND cap (not just global) after await
	if enemy_scene == null:
		return
	var post_cap: int
	if stage_number > 0:
		# iter 011: OG mode uses canonical Tanks cap, not depth-band cap.
		post_cap = RosterT.MAX_SIMULTANEOUS
	else:
		var post_band: Dictionary = _current_band()
		post_cap = int(post_band.get("max_alive", max_enemies))
	if _enemies_alive >= post_cap:
		return
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var enemy: Node2D = enemy_scene.instantiate()
	# Apply enemy type stats BEFORE add_child so _ready sees the right values
	var type_data: Dictionary = _pick_enemy_type()
	enemy.set("enemy_type", type_data.name)  # iter 24: behavioral switch in Enemy.gd
	enemy.set("sprite_base_frame", type_data.base_frame)
	enemy.set("speed", type_data.speed)
	# arc-4 iter 63 (Round 9a): bump max_hp in breach mode for the HP primitive.
	var mhp: int = type_data.max_hp
	var lvl: Node = get_parent()
	if lvl != null and "breach_mode_enabled" in lvl and lvl.breach_mode_enabled:
		mhp += int(BREACH_HP_BONUS.get(type_data.name, 0))
	enemy.set("max_hp", mhp)
	enemy.set("fire_cooldown", type_data.fire_cooldown)
	enemy.set("direction_commit_time", type_data.direction_commit_time)  # iter 26
	enemy.set("bullet_damage", type_data.bullet_damage)  # iter 52
	enemy.set("sprite_tint", type_data.sprite_tint)  # iter 67
	enemy.set("sprite_scale", type_data.sprite_scale)  # iter 86
	# arc-4 iter 23: armored enemies join the "armored" group — Bullet.gd
	# mitigates AP/HE against group members; HEAT bypasses. Uses a group
	# tag (a Node method) rather than an Enemy.gd @export, so no Layer-2
	# Enemy.gd substrate write is needed.
	# F002: gated on breach mode — the Heavy ENEMY_TYPES entry is shared
	# with arc-3 OG mode; without this gate, OG Heavy enemies would be
	# tagged armored and the OG player's AP would deal 0 damage to them.
	if type_data.get("armored", false) and _is_breach_mode():
		enemy.add_to_group("armored")
	enemy.global_position = pos
	# iter 101 (review-fix): explicit domain signals replace tree_exited
	# piggy-backing for kill counter. tree_exited still drives _enemies_alive
	# decrement (correct for any exit cause).
	enemy.tree_exited.connect(_on_enemy_freed)
	if enemy.has_signal("killed"):
		# arc-4 iter 58: bind the enemy so _on_enemy_killed can drop ammo
		# at its death position.
		enemy.killed.connect(_on_enemy_killed.bind(enemy))
	if enemy.has_signal("aim_canceled"):
		enemy.aim_canceled.connect(_on_enemy_aim_canceled)
	parent_node.add_child(enemy)
	_enemies_alive += 1
	# iter 31: origin distribution counter; iter 101: armed only on real spawn
	if is_below:
		spawn_origin_below += 1
		_last_below_spawn_time = _elapsed_time
	else:
		spawn_origin_top += 1


# Weighted random selection from ENEMY_TYPES, weighted by the current
# DEPTH BAND's type_weights override (iter 22). iter 27: also honors
# band's guarantee_first_type when entering a new band — first spawn
# uses that type to set the band's tone before random weights take over.
func _pick_enemy_type() -> Dictionary:
	# iter 011: ORIGINALS mode uses Roster.armored_probability(stage) to
	# pick Light (A/B/C) vs Heavy (D). No band logic, no first-spawn guarantee.
	if stage_number > 0:
		var armored: bool = RosterT.is_armored_spawn(stage_number)
		var picked: Dictionary = _get_type_by_name("Heavy" if armored else "Light")
		if picked.is_empty():
			picked = ENEMY_TYPES[0]
		return picked
	# arc-4 iter 15: breach-mode roster. When the parent level is in
	# breach mode and the active BreachBand declares enemy_weights, those
	# weights drive the pick — replacing the arc-2 DEPTH_BANDS table.
	# Gated: arc-2 procedural + arc-3 OG paths never enter this branch,
	# so the hash anchor + OG behavior stay bit-identical.
	var breach_weights: Dictionary = _breach_band_weights()
	if not breach_weights.is_empty():
		return _weighted_pick(breach_weights)
	var band: Dictionary = _current_band()
	# iter 27: band-entry guarantee
	if _band_first_spawn_pending:
		_band_first_spawn_pending = false
		var guar = band.get("guarantee_first_type", null)
		if guar != null:
			var forced: Dictionary = _get_type_by_name(guar)
			if not forced.is_empty():
				return forced
	var weights: Dictionary = band.get("type_weights", {})
	var total: float = 0.0
	for t in ENEMY_TYPES:
		total += float(weights.get(t.name, t.weight))
	if total <= 0.0:
		return ENEMY_TYPES[0]
	return _weighted_pick(weights)


# arc-4 iter 15: weighted pick from a {role_name: weight} map. Shared by
# the arc-2 DEPTH_BANDS path and the breach-mode path.
func _weighted_pick(weights: Dictionary) -> Dictionary:
	var total: float = 0.0
	for t in ENEMY_TYPES:
		total += float(weights.get(t.name, 0.0))
	if total <= 0.0:
		return ENEMY_TYPES[0]
	var roll: float = randf() * total
	var accum: float = 0.0
	for t in ENEMY_TYPES:
		accum += float(weights.get(t.name, 0.0))
		if roll <= accum:
			return t
	return ENEMY_TYPES[0]


# arc-4 iter 23: is the parent level in breach mode? Used to gate
# breach-only behavior (armored enemy tagging) off the arc-2/3 paths.
func _is_breach_mode() -> bool:
	var lvl: Node = get_parent()
	if lvl == null:
		return false
	return ("breach_mode_enabled" in lvl) and lvl.breach_mode_enabled


# arc-4 iter 15: read the active BreachBand's enemy_weights via the
# parent level. Returns {} when not in breach mode (→ arc-2 fallback).
func _breach_band_weights() -> Dictionary:
	var lvl: Node = get_parent()
	if lvl == null:
		return {}
	if not ("breach_mode_enabled" in lvl) or not lvl.breach_mode_enabled:
		return {}
	if not ("_current_breach_band" in lvl) or lvl._current_breach_band == null:
		return {}
	var band = lvl._current_breach_band
	if "enemy_weights" in band and band.enemy_weights is Dictionary:
		return band.enemy_weights
	return {}


# iter 27: helper for guarantee_first_type lookup
func _get_type_by_name(type_name: String) -> Dictionary:
	for t in ENEMY_TYPES:
		if t.name == type_name:
			return t
	return {}


func _on_enemy_freed() -> void:
	# iter 101: alive-decrement only — kill counting moved to _on_enemy_killed
	# so non-kill exits (scene reload, future despawn-off-screen) don't inflate
	# the death-screen "KILLS" metric.
	_enemies_alive -= 1
	# iter 011 (review-fix): ORIGINALS clear-condition checked here, post-
	# decrement. Enemy.gd emits `killed` synchronously BEFORE queue_free
	# defers the tree-exit, so checking _enemies_alive in _on_enemy_killed
	# sees the stale ==1 on the last kill and stage_cleared never fires.
	# Gated on stage_number + total-spawns to avoid the boot-time false-
	# positive (alive==0 at start before any spawn).
	if stage_number > 0 \
			and _total_spawns_this_stage >= RosterT.TOTAL_ENEMIES_PER_STAGE \
			and _enemies_alive == 0:
		stage_cleared.emit()


func _on_enemy_killed(enemy: Node) -> void:
	enemies_killed += 1
	_try_ammo_drop(enemy)


# arc-4 iter 58 (Round 8c): a killed enemy may drop an ammo pickup at
# its death position (playtest-3 — "does enemy drop ammo?"). The
# breach-mode gate is checked BEFORE randf(), so an arc-2/3 run consumes
# zero RNG here — the seed-42 procedural baseline stays bit-identical.
func _try_ammo_drop(enemy: Node) -> void:
	if not (enemy is Node2D):
		return
	var lvl: Node = get_parent()
	if lvl == null:
		return
	var player: Node = lvl.get_node_or_null("PlayerTank")
	if player == null or not ("loadout" in player) or player.loadout == null:
		return
	if randf() >= AMMO_DROP_CHANCE:
		return
	var pickup: Area2D = AmmoPickupScene.instantiate()
	pickup.global_position = (enemy as Node2D).global_position
	lvl.add_child(pickup)


func _on_enemy_aim_canceled() -> void:
	aim_cancels_landed += 1


# iter 48 (Pro Consult 006 secondary): depth pressure landmarks. Each time
# _max_depth_reached crosses a multiple of depth_gate_step, spawn one gate.
# Idempotent: tracks _last_gate_depth to fire each gate exactly once.
func _check_depth_gates() -> void:
	var next_gate: int = _last_gate_depth + depth_gate_step
	if _max_depth_reached < next_gate:
		return
	_last_gate_depth = next_gate
	_spawn_depth_gate(next_gate)


# iter 64: band-marker HUD overlay on band transition. Brief tinted screen
# flash + center label "ENTERING <BAND>" that fades. NOT spawned for the
# initial warmup band (already there at start). Skip first transition.
var _band_marker_count: int = 0


func _spawn_band_marker(band_name: String) -> void:
	# Skip the very first band-enter event (initial warmup at game start).
	_band_marker_count += 1
	if _band_marker_count <= 1:
		return
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var tint_color: Color = BAND_COLORS.get(band_name, Color(1.0, 1.0, 1.0, 1.0))
	# iter 92 (Pro Consult 008 visual budget): band-marker camera shake REMOVED.
	# Reserves shake for the damage event (iter 42) — meaningful semantic anchor.
	# Dedicated CanvasLayer above HUD (layer 10) for full-screen overlay
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 10
	parent_node.add_child(canvas)
	# Full-screen tint (alpha 0.18 starts, fades to 0 over 0.5s)
	var tint: ColorRect = ColorRect.new()
	tint.size = Vector2(320, 240)
	tint.position = Vector2.ZERO
	tint.color = Color(tint_color.r, tint_color.g, tint_color.b, 0.18)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(tint)
	# Center label
	var label: Label = Label.new()
	label.text = "ENTERING %s" % band_name.to_upper()
	label.position = Vector2(96, 110)
	label.size = Vector2(128, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", tint_color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	canvas.add_child(label)
	# Tween: tint fades over 0.5s; label visible 1.5s then fades to 0 over 0.5s; canvas frees after
	var tween: Tween = canvas.create_tween()
	tween.set_parallel(true)
	tween.tween_property(tint, "modulate:a", 0.0, 0.5)
	tween.tween_property(label, "modulate:a", 1.0, 0.0)  # ensure visible at start
	tween.chain()
	tween.tween_interval(1.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.chain()
	tween.tween_callback(canvas.queue_free)


# iter 92 (visual budget): _kick_camera_for_band removed per Pro Consult 008
# — reduces "noise artifact" surface; only damage events shake camera.


func _spawn_depth_gate(depth_rows: int) -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	# iter 65: derive band-themed colors from depth — gate at depth 20 enters
	# heavy_gate (orange), depth 40 enters rush (red), etc. Composes with
	# iter-64 band-marker HUD overlays for cohesive band visual identity.
	var band_color: Color = _band_color_for_depth(depth_rows)
	var post_color: Color = Color(band_color.r, band_color.g, band_color.b, 0.9)
	var text_color: Color = Color(band_color.r, band_color.g, band_color.b, 1.0)
	# World-y of gate row (player ascended depth_rows × 16 px from start)
	var gate_y: float = _player_start_y - float(depth_rows) * 16.0
	# Two posts at viewport edges (inside map walls at x=-4 and x=324)
	for px in [4.0, 308.0]:
		var post: ColorRect = ColorRect.new()
		post.size = Vector2(8, 16)
		post.color = post_color
		post.position = Vector2(px, gate_y - 8.0)  # centered on gate row
		post.z_index = 30
		parent_node.add_child(post)
	# Center label
	var label: Label = Label.new()
	label.text = "* DEPTH %d *" % depth_rows
	label.position = Vector2(120.0, gate_y - 6.0)
	label.add_theme_color_override("font_color", text_color)
	label.z_index = 31
	parent_node.add_child(label)
	print("[landmark] gate depth %d at y=%d band_color=%s" % [depth_rows, int(gate_y), band_color])


# iter 65: map gate depth → band color. Gate at depth 20 enters heavy_gate
# (orange). Depth 40 enters rush (red). Pre-20 gates would use first_push
# yellow but with depth_gate_step=20, no gate spawns before depth 20.
func _band_color_for_depth(depth: int) -> Color:
	if depth < 8:
		return BAND_COLORS.get("warmup", Color(1.0, 1.0, 1.0, 1.0))
	if depth < 20:
		return BAND_COLORS.get("first_push", Color(1.0, 0.95, 0.5, 1.0))
	if depth < 40:
		return BAND_COLORS.get("heavy_gate", Color(1.0, 0.55, 0.2, 1.0))
	return BAND_COLORS.get("rush", Color(1.0, 0.35, 0.35, 1.0))
