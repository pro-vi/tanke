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

@onready var sprite: Sprite2D = $Sprite2D

var _grass_tilemap: TileMapLayer = null

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


func _ready() -> void:
	hp = max_hp
	rotation = Constants.dir_to_rotation(direction)
	_start_y = global_position.y
	_min_y_reached = _start_y
	_grass_tilemap = get_tree().get_root().find_child("Grass", true, false) as TileMapLayer
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


func _die() -> void:
	_dead = true
	sprite.stop()
	velocity = Vector2.ZERO
	if _death_label != null:
		_death_label.visible = true
	died.emit()


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
	_death_label.position = Vector2(96, 96)
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
	if _time_label != null:
		var t: int = int(_run_time)
		_time_label.text = "TIME %d:%02d" % [t / 60, t % 60]


# BC forest convention: tank is concealed (low alpha) when standing on a grass
# cell. Grass tilemap has no collision; tanks drive freely over it.
func _update_forest_hide() -> void:
	if _grass_tilemap == null or sprite == null:
		return
	var local_pos: Vector2 = _grass_tilemap.to_local(global_position)
	var cell: Vector2i = _grass_tilemap.local_to_map(local_pos)
	var source_id: int = _grass_tilemap.get_cell_source_id(cell)
	sprite.modulate.a = forest_hidden_alpha if source_id != -1 else forest_visible_alpha
