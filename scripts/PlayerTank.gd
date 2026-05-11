extends CharacterBody2D

signal shoot
signal hp_changed(new_hp: int, max_hp: int)
signal died

@export var speed: int = 32
@export var gun_cooldown: int = 100
@export var Bullet: PackedScene
@export var max_hp: int = 3
@export var damage_iframes: float = 0.6
@export var forest_hidden_alpha: float = 0.3
@export var forest_visible_alpha: float = 1.0
# Hit flash (iter 19) — red pulse on damage + alternating blink during iframes
@export var hit_flash_color: Color = Color(1.6, 0.3, 0.3, 1.0)
# Camera shake (iter 42) — kicks Camera2D.offset on non-kill damage. Independent
# of Camera2D.position which is driven by PlayerTank's RemoteTransform2D.
@export var screen_shake_magnitude: float = 3.0  # px at 320×240
@export var screen_shake_duration: float = 0.25
@export var screen_shake_steps: int = 5

@onready var sprite: Sprite2D = $Sprite2D

var _grass_tilemap: TileMapLayer = null
var _flash_tween: Tween = null
var _shake_tween: Tween = null
var _camera: Camera2D = null
var _is_flashing: bool = false

var direction: int = Constants.Dir.U
var grid: Vector2 = Vector2(4, 4)  # minimum grid size to snap to when turning
var can_shoot: bool = true
var hp: int = 0
var _iframe_timer: float = 0.0
var _dead: bool = false
var _restart_armed: bool = false
var _hp_label: Label
var _death_label: Label
# Roguelike ascender state (iter 11 — Pro Consult 003 reframe)
var _start_y: float = 0.0
var _min_y_reached: float = 0.0
var _run_time: float = 0.0
var _depth_label: Label
var _time_label: Label
# iter 30: depth milestone flash (Pro Consult 005 META — ascent legibility)
var _last_milestone_depth: int = 0
@export var depth_milestone_step: int = 10
# iter 31: ascender-metric instrumentation (Pro Consult 005 H4)
var _stall_time_total: float = 0.0  # cumulative seconds with ascent_velocity < threshold
var _last_y_for_velocity: float = 0.0
var _ascent_velocity_player: float = 0.0  # smoothed rows/sec, player-side estimate
@export var stall_velocity_threshold: float = 0.3  # rows/sec; matches Spawner.stall_threshold
@export var velocity_ema_alpha_player: float = 2.0


func _ready() -> void:
	hp = max_hp
	rotation = Constants.dir_to_rotation(direction)
	_start_y = global_position.y
	_min_y_reached = _start_y
	_last_y_for_velocity = _start_y  # iter 31: instrumentation seed
	_grass_tilemap = get_tree().get_root().find_child("Grass", true, false) as TileMapLayer
	_camera = get_parent().get_node_or_null("Camera2D") as Camera2D
	_setup_hurtbox()
	_setup_hud()
	hp_changed.emit(hp, max_hp)
	_update_run_hud()


func _physics_process(delta: float) -> void:
	if _iframe_timer > 0.0:
		_iframe_timer -= delta

	if _dead:
		_handle_restart_input()
		return

	# Roguelike ascender: track depth + run time (iter 11)
	_run_time += delta
	if global_position.y < _min_y_reached:
		_min_y_reached = global_position.y
	_update_run_hud()
	_update_forest_hide()
	# iter 31: ascender-metric instrumentation
	if delta > 0.0:
		var dy_rows: float = (_last_y_for_velocity - global_position.y) / 16.0
		var instant: float = dy_rows / delta
		var a: float = clampf(velocity_ema_alpha_player * delta, 0.0, 1.0)
		_ascent_velocity_player = lerpf(_ascent_velocity_player, instant, a)
		_last_y_for_velocity = global_position.y
		if _ascent_velocity_player < stall_velocity_threshold:
			_stall_time_total += delta

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


func take_damage(amount: int) -> void:
	if _dead or _iframe_timer > 0.0:
		return
	hp = max(0, hp - amount)
	_iframe_timer = damage_iframes
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		_die()
	else:
		_start_hit_flash()
		_start_screen_shake()


# Visual damage cue (iter 19): bright red pulse + alternating alpha blink
# during the iframe window. Suppresses forest_hide for the duration so the
# flash isn't masked by grass concealment.
func _start_hit_flash() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_is_flashing = true
	_flash_tween = create_tween()
	# Red pulse (saturated red, brief)
	_flash_tween.tween_property(sprite, "modulate", hit_flash_color, 0.0)
	_flash_tween.tween_interval(0.08)
	# Iframe blink — 3 cycles of dimmed/normal (~0.48s)
	for i in 3:
		_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.4), 0.08)
		_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	# Restore: forest_hide will resume on next physics frame
	_flash_tween.tween_callback(_end_hit_flash)


func _end_hit_flash() -> void:
	_is_flashing = false
	# Reset modulate to white; _update_forest_hide will set alpha next frame
	if sprite != null:
		sprite.modulate = Color.WHITE


# Camera shake (iter 42) — randomized Camera2D.offset kicks with decaying
# amplitude, ending in snap-to-zero restore. Independent of position smoothing
# because we tween `offset`, not `position`. RemoteTransform2D on PlayerTank
# drives Camera2D.position; offset is undriven and free to animate.
func _start_screen_shake() -> void:
	if _camera == null:
		return
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	var step_dur: float = screen_shake_duration / float(screen_shake_steps)
	for i in screen_shake_steps:
		var t: float = float(i) / float(maxi(screen_shake_steps - 1, 1))
		var amp: float = screen_shake_magnitude * (1.0 - t)
		var offset: Vector2 = Vector2(randf_range(-amp, amp), randf_range(-amp, amp))
		_shake_tween.tween_property(_camera, "offset", offset, step_dur)
	# Restore to (0,0) — fast snap so the camera doesn't drift after damage
	_shake_tween.tween_property(_camera, "offset", Vector2.ZERO, 0.05)


func _die() -> void:
	_dead = true
	sprite.stop()
	velocity = Vector2.ZERO
	# iter 31: ascender run summary on death (Pro Consult 005 H4)
	var depth: int = int(maxf(0.0, (_start_y - _min_y_reached) / 16.0))
	var t: int = int(_run_time)
	var ascent_rate: float = 0.0
	if _run_time > 0.0:
		ascent_rate = float(depth) / _run_time
	var stall_pct: float = 0.0
	if _run_time > 0.0:
		stall_pct = 100.0 * _stall_time_total / _run_time
	# iter 43: kills lookup from Spawner sibling (best-effort)
	var kills: int = 0
	var spawner: Node = get_parent().get_node_or_null("Spawner")
	if spawner != null and "enemies_killed" in spawner:
		kills = int(spawner.enemies_killed)
	print("[run] depth=%d time=%d:%02d kills=%d ascent_rate=%.2f rows/s stall_total=%.1fs (%.0f%%)" % [depth, t / 60, t % 60, kills, ascent_rate, _stall_time_total, stall_pct])
	# iter 44: persistent best-depth tracking
	var prior_best: int = _load_best_depth()
	var is_new_best: bool = depth > prior_best
	if is_new_best:
		_save_best_depth(depth)
	# iter 43: render run summary on death label (iter 44: + BEST line)
	if _death_label != null:
		var best_line: String
		if is_new_best:
			best_line = "\n* NEW BEST!  (was %d)" % prior_best
		else:
			best_line = "\nBEST %d" % prior_best
		_death_label.text = "YOU DIED\n\nDEPTH %d\nTIME %d:%02d\nKILLS %d\nSTALL %d%%%s\n\n[R] RESTART" % [depth, t / 60, t % 60, kills, int(stall_pct), best_line]
		_death_label.visible = true
	died.emit()


# iter 44: persistent best-depth via ConfigFile at user://stats.cfg.
# First-run path: ConfigFile.load returns ERR_FILE_NOT_FOUND → treat as 0.
# Other errors: print warning and treat as 0 (defensive — corruption should
# not block UI).
const _STATS_CFG_PATH: String = "user://stats.cfg"

func _load_best_depth() -> int:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load(_STATS_CFG_PATH)
	if err == OK:
		return int(cfg.get_value("run", "best_depth", 0))
	if err != ERR_FILE_NOT_FOUND:
		push_warning("[stats] ConfigFile.load err=%d (treating as no prior best)" % err)
	return 0


func _save_best_depth(d: int) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	# Re-load to preserve any other future keys
	cfg.load(_STATS_CFG_PATH)
	cfg.set_value("run", "best_depth", d)
	var err: int = cfg.save(_STATS_CFG_PATH)
	if err != OK:
		push_warning("[stats] ConfigFile.save err=%d" % err)


func _handle_restart_input() -> void:
	var pressed: bool = Input.is_physical_key_pressed(KEY_R)
	if pressed and _restart_armed:
		get_tree().reload_current_scene()
		return
	if not pressed:
		_restart_armed = true


func _setup_hurtbox() -> void:
	var hurtbox: Area2D = Area2D.new()
	hurtbox.name = "HurtBox"
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 8  # Enemy layer
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(12, 12)
	shape.shape = rect
	hurtbox.add_child(shape)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	add_child(hurtbox)


func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		take_damage(1)


func _setup_hud() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD"
	_hp_label = Label.new()
	_hp_label.name = "HPLabel"
	_hp_label.position = Vector2(4, 4)
	_hp_label.text = "HP %d/%d" % [hp, max_hp]
	_hp_label.add_theme_color_override("font_color", Color.WHITE)
	canvas.add_child(_hp_label)
	_death_label = Label.new()
	_death_label.name = "DeathLabel"
	# iter 43: position raised to make room for multi-line run summary
	_death_label.position = Vector2(96, 72)
	_death_label.text = "YOU DIED\n[R] RESTART"
	_death_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_death_label.visible = false
	canvas.add_child(_death_label)
	# Roguelike ascender HUD (iter 11) — top-right
	_depth_label = Label.new()
	_depth_label.name = "DepthLabel"
	_depth_label.position = Vector2(232, 4)
	_depth_label.text = "DEPTH 0"
	_depth_label.add_theme_color_override("font_color", Color.WHITE)
	canvas.add_child(_depth_label)
	_time_label = Label.new()
	_time_label.name = "TimeLabel"
	_time_label.position = Vector2(232, 16)
	_time_label.text = "TIME 0:00"
	_time_label.add_theme_color_override("font_color", Color.WHITE)
	canvas.add_child(_time_label)
	add_child(canvas)
	hp_changed.connect(_on_hp_changed_hud)


func _on_hp_changed_hud(new_hp: int, the_max_hp: int) -> void:
	if _hp_label != null:
		_hp_label.text = "HP %d/%d" % [new_hp, the_max_hp]


func _update_run_hud() -> void:
	if _depth_label != null:
		var depth: int = int(maxf(0.0, (_start_y - _min_y_reached) / 16.0))
		_depth_label.text = "DEPTH %d" % depth
		# iter 30: milestone flash on every Nth depth row crossing
		if depth_milestone_step > 0 and depth > 0 and depth % depth_milestone_step == 0 and depth != _last_milestone_depth:
			_last_milestone_depth = depth
			_flash_depth_milestone(depth)
	if _time_label != null:
		var t: int = int(_run_time)
		_time_label.text = "TIME %d:%02d" % [t / 60, t % 60]


# iter 30 (Pro Consult 005 META — "readable upward intent"): when player
# crosses a depth milestone (multiple of depth_milestone_step), briefly
# scale + recolor the DEPTH label. Cues the climb visually.
func _flash_depth_milestone(_depth: int) -> void:
	if _depth_label == null:
		return
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_depth_label, "scale", Vector2(1.8, 1.8), 0.12)
	tween.tween_property(_depth_label, "modulate", Color(0.4, 1.0, 0.4, 1.0), 0.12)
	tween.chain().set_parallel(true)
	tween.tween_property(_depth_label, "scale", Vector2.ONE, 0.4)
	tween.tween_property(_depth_label, "modulate", Color.WHITE, 0.4)


# BC forest convention: tank is concealed (low alpha) when standing on a grass
# cell. Grass tilemap has no collision; tanks drive freely over it.
func _update_forest_hide() -> void:
	if _is_flashing or _grass_tilemap == null or sprite == null:
		return
	var local_pos: Vector2 = _grass_tilemap.to_local(global_position)
	var cell: Vector2i = _grass_tilemap.local_to_map(local_pos)
	var source_id: int = _grass_tilemap.get_cell_source_id(cell)
	sprite.modulate.a = forest_hidden_alpha if source_id != -1 else forest_visible_alpha
