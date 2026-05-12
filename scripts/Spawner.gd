extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 20
@export var max_spawn_attempts: int = 8
@export var map_x_margin: float = 4.0
@export var map_width: float = 320.0
@export var spawn_top_edge_offset: float = 8.0  # spawn this many px INSIDE the visible viewport top, so user sees enemies "driving in" from the edge (BC-style)
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
		"interval_mult": 1.25,
		"max_alive": 4,  # onboarding density
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
		"type_weights": {"Light": 0.25, "Heavy": 0.5, "Fast": 0.25},  # iter 40: Fast harasses while Heavy denies
		"interval_mult": 0.85,
		"max_alive": 8,  # fewer but heavier — denial pressure
		"guarantee_first_type": "Heavy",  # band-marker
	},
	{
		"name": "rush",
		"depth_max": 9999,
		"type_weights": {"Light": 0.25, "Heavy": 0.15, "Fast": 0.6},  # iter 40: Fast-dominant harassment phase
		"interval_mult": 0.7,
		"max_alive": 16,
		"guarantee_first_type": "Fast",  # iter 40: signal the rush phase with harassment, not lane-invader
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
# iter 30: visibility-fix state for below-spawn telegraph (Pro Consult 005 H2)
var _pending_below_spawn: bool = false
var _pending_below_telegraph_pos: Vector2 = Vector2.INF

# Counters for iter-4 pre-mortem prediction #2 (rejections per 10 ticks).
var spawns_total: int = 0
var rejections_total: int = 0
var ticks_total: int = 0
# iter 31: ascender-metric instrumentation (Pro Consult 005 H4)
var spawn_origin_top: int = 0
var spawn_origin_below: int = 0
# iter 43: death-screen summary counter. Incremented when any enemy
# tree_exits (i.e., gets queue_free'd by take_damage hp<=0 or other paths).
# Used by PlayerTank._die() to render death-screen kill count.
var enemies_killed: int = 0
# iter 56 (Pro Consult 007 H1 caveat: instrumentation for iter-60 diagnostic).
# Incremented by Enemy._heavy_aim_cancel() each time Heavy's wind-up is
# interrupted. Read by PlayerTank._die() for [run] summary + death screen.
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
	# iter 22: band interval_mult; iter 27: graduated stall multiplier.
	var band: Dictionary = _current_band()
	var base: float = spawn_interval * float(band.get("interval_mult", 1.0))
	return base * _current_stall_multiplier()


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
		var spawn_pos: Variant = _find_valid_spawn()
		if spawn_pos == null:
			rejections_total += 1
		else:
			_telegraph_then_spawn(spawn_pos)
			spawns_total += 1
	if ticks_total % 5 == 0:
		var cap_marker: String = " CAP" if cap_hit else ""
		print("[spawner] tick %d: spawns=%d (top=%d below=%d) rejections=%d alive=%d/%d%s depth=%d band=%s ascent=%.2f stall=%.1fs interval=%.2fs stallMult=%.2f" % [ticks_total, spawns_total, spawn_origin_top, spawn_origin_below, rejections_total, _enemies_alive, band_cap, cap_marker, _max_depth_reached, band.name, _ascent_velocity, _stall_time, _current_spawn_interval(), _current_stall_multiplier()])


# Compute spawn position. Top-edge by default (iter 12+). iter 28: if
# player has stalled past threshold, spawn from BELOW (threats-from-
# behind). iter 30 (Pro Consult 005 H2 fix): below-spawn telegraph must
# be VISIBLE inside the viewport edge — fairness-not-cheap. Below-spawn
# returns a Vector2 for enemy position AND a separate telegraph_pos for
# the marker (stored on `_pending_below_telegraph_pos`).
func _find_valid_spawn() -> Variant:
	var camera_center_y: float = _player.global_position.y
	if _camera != null and is_instance_valid(_camera):
		camera_center_y = _camera.get_screen_center_position().y
	var use_below: bool = _should_spawn_below()
	var spawn_y: float
	if use_below:
		var screen_bottom: float = camera_center_y + _viewport_half_height
		# Enemy still spawns just OFF-screen below (so it visibly enters)
		spawn_y = screen_bottom + spawn_bottom_edge_offset
		# Telegraph marker stored INSIDE bottom edge so player sees the warning
		_pending_below_telegraph_pos = Vector2.INF  # filled by caller after x picked
		_pending_below_spawn = true
		_last_below_spawn_time = _elapsed_time
	else:
		var screen_top: float = camera_center_y - _viewport_half_height
		var lookahead_px: float = maxf(0.0, _ascent_velocity) * 16.0 * ascent_lookahead_seconds
		spawn_y = screen_top + spawn_top_edge_offset - lookahead_px
		_pending_below_spawn = false
	for i in max_spawn_attempts:
		var x: float = randf_range(map_x_margin, map_width - map_x_margin)
		var candidate: Vector2 = Vector2(x, spawn_y)
		if _is_blocked(candidate):
			continue
		# iter 30: store telegraph pos for below-spawn (visible inside bottom)
		if _pending_below_spawn and _camera != null and is_instance_valid(_camera):
			var visible_bottom: float = _camera.get_screen_center_position().y + _viewport_half_height
			_pending_below_telegraph_pos = Vector2(x, visible_bottom - 12.0)  # 12px inside bottom
		return candidate
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
func _telegraph_then_spawn(pos: Vector2) -> void:
	var marker: ColorRect = ColorRect.new()
	marker.size = Vector2(8, 4)
	# Below-spawn: red marker at viewport-bottom edge (visible warning)
	# Top-spawn: yellow marker at spawn position (existing behavior)
	if _pending_below_spawn and _pending_below_telegraph_pos != Vector2.INF:
		marker.color = Color(1.0, 0.3, 0.3, 0.9)  # red for "behind" warning
		marker.position = _pending_below_telegraph_pos - Vector2(4, 2)
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
	var post_band: Dictionary = _current_band()
	var post_cap: int = int(post_band.get("max_alive", max_enemies))
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
	enemy.set("max_hp", type_data.max_hp)
	enemy.set("fire_cooldown", type_data.fire_cooldown)
	enemy.set("direction_commit_time", type_data.direction_commit_time)  # iter 26
	enemy.set("bullet_damage", type_data.bullet_damage)  # iter 52
	enemy.set("sprite_tint", type_data.sprite_tint)  # iter 67
	enemy.global_position = pos
	enemy.tree_exited.connect(_on_enemy_freed)
	parent_node.add_child(enemy)
	_enemies_alive += 1
	# iter 31: origin distribution counter
	if _pending_below_spawn:
		spawn_origin_below += 1
	else:
		spawn_origin_top += 1


# Weighted random selection from ENEMY_TYPES, weighted by the current
# DEPTH BAND's type_weights override (iter 22). iter 27: also honors
# band's guarantee_first_type when entering a new band — first spawn
# uses that type to set the band's tone before random weights take over.
func _pick_enemy_type() -> Dictionary:
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
	var roll: float = randf() * total
	var accum: float = 0.0
	for t in ENEMY_TYPES:
		accum += float(weights.get(t.name, t.weight))
		if roll <= accum:
			return t
	return ENEMY_TYPES[0]


# iter 27: helper for guarantee_first_type lookup
func _get_type_by_name(type_name: String) -> Dictionary:
	for t in ENEMY_TYPES:
		if t.name == type_name:
			return t
	return {}


func _on_enemy_freed() -> void:
	_enemies_alive -= 1
	enemies_killed += 1  # iter 43: death-screen summary counter


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
