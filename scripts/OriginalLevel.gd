extends "res://scripts/Level.gd"

const LevelLoaderT = preload("res://scripts/LevelLoader.gd")
const StageDirectorT = preload("res://scripts/StageDirector.gd")
const EagleScene: PackedScene = preload("res://scenes/Eagle.tscn")

# Arc-3 originals-mode scene script. Parallel to ProceduralLevel.gd but
# instead of generating terrain with ProceduralStep, it parses a Tanks
# ASCII stage via LevelLoader and writes cells onto the inherited
# Brick/Steel/Grass/Water TileMapLayers. Then the inherited
# _replace_blocks() converts brick + water cells into BrickBlock and
# WaterBlock StaticBody2D instances (the same machinery the procedural
# mode uses — H1 tripwire respected).

@export var stage_number: int = 1
@export var col_offset: int = 7
@export var row_offset: int = 2

# iter 003: iceTileMap is an arc-3-only addition (Ice TileMapLayer was
# added to OriginalLevel.tscn but NOT to Level.gd's substrate). Exposed so
# LevelLoader can write '-' cells when present.
@onready var iceTileMap: TileMapLayer = tiles.get_node_or_null("Ice")

# Eagle entity (criterion 2). Per iter-003 survey, the canonical BC fortress
# `#..#` pattern lives at stage cols 11-14 of rows 24-25 in ALL 35 stages
# (zero variance). The eagle sits in the 2x2 empty cells at stage cols 12-13,
# rows 24-25 — which after the (col_offset=7, row_offset=2) scene mapping
# is scene cells (19-20, 26-27), center at screen (160, 216).
const EAGLE_SCREEN_POS := Vector2(160, 216)
var eagle: Node2D = null

# iter 007: StageDirector tracks 1..35 stage progression. Owns the
# advance_stage / restart / goto_stage state. Dev N-key triggers advance
# for testing (anchor-2 "linear advance — code-cited"); natural clear
# condition awaits Spawner integration (iter 9+).
var stage_director: StageDirectorT = null

# iter 011: arc-2 Spawner integration. OriginalLevel.tscn includes a
# Spawner node; we push the current stage_number to it on _ready so the
# spawner uses Roster.armored_probability(stage). When the spawner emits
# stage_cleared (all 20 enemies killed), advance to the next stage.
# _advancing latch prevents double-fire from rapid signal + scene-reload race.
var _advancing: bool = false


func _ready() -> void:
	# Wire player shoot signal (mirrors Level._ready and ProceduralLevel._ready;
	# we override the parent _ready entirely because we need to insert
	# LevelLoader.parse_stage BEFORE _replace_blocks).
	player.shoot.connect(_on_PlayerTank_shoot)
	# Env-var override for headless oracle (--og-stage K passes via TANKE_OG_STAGE).
	var stage_override: String = OS.get_environment("TANKE_OG_STAGE")
	if stage_override != "":
		stage_number = int(stage_override)
	var report: Dictionary = LevelLoaderT.parse_stage(self, stage_number, col_offset, row_offset)
	var ice_placed: int = report.get("ice", 0)
	print("originals: stage %d  brick:%d steel:%d grass:%d water:%d ice:%d ice_skipped:%d" % [
		stage_number, report.brick, report.steel, report.grass, report.water, ice_placed, report.ice_skipped
	])
	if not report.ok:
		push_error("LevelLoader failed for stage %d: %s" % [stage_number, report.error])
	_replace_blocks()
	_spawn_eagle()
	stage_director = StageDirectorT.new(stage_number)
	stage_director.arc_complete.connect(_on_arc_complete)
	_wire_spawner()


func _wire_spawner() -> void:
	var spawner: Node = get_node_or_null("Spawner")
	if spawner == null:
		return
	spawner.set("stage_number", stage_number)
	if spawner.has_signal("stage_cleared"):
		spawner.stage_cleared.connect(_on_stage_cleared)


func _on_stage_cleared() -> void:
	if _advancing or _game_over:
		return
	_advancing = true
	print("originals: stage %d cleared — advancing" % stage_number)
	_advance_to_next_stage()


func _spawn_eagle() -> void:
	eagle = EagleScene.instantiate()
	eagle.global_position = EAGLE_SCREEN_POS
	add_child(eagle)
	eagle.eagle_destroyed.connect(_on_eagle_destroyed)


# iter 006: criterion 2 anchor-3 cite — eagle_destroyed transitions to a
# game-over overlay; R reloads the scene, Esc returns to the title screen.
const TITLE_SCENE := "res://scenes/TitleScreen.tscn"
var _game_over: bool = false
var _game_over_overlay: CanvasLayer = null


func _on_eagle_destroyed() -> void:
	if _game_over:
		return
	_game_over = true
	print("originals: eagle destroyed on stage %d — GAME OVER" % stage_number)
	_show_game_over()


func _show_game_over() -> void:
	_game_over_overlay = CanvasLayer.new()
	_game_over_overlay.layer = 10
	add_child(_game_over_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = Vector2(width, height)
	_game_over_overlay.add_child(dim)

	var label := Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 24)
	label.position = Vector2(width * 0.5 - 60, height * 0.5 - 24)
	label.modulate = Color(1.0, 0.3, 0.2, 1.0)
	_game_over_overlay.add_child(label)

	var hint := Label.new()
	hint.text = "R RESTART  ESC TITLE"
	hint.position = Vector2(width * 0.5 - 72, height * 0.5 + 16)
	hint.modulate = Color(0.7, 0.7, 0.7, 1.0)
	_game_over_overlay.add_child(hint)


func _process(_delta: float) -> void:
	# Dev N-key: advance to the next stage. Anchor-2 cite for criterion 10.
	# Natural clear-condition (all enemies dead) is iter 9+ Spawner work.
	# Guarded by _game_over so the GAME OVER screen stops accepting it.
	if not _game_over and Input.is_key_pressed(KEY_N):
		_advance_to_next_stage()
		return
	if not _game_over:
		return
	if Input.is_key_pressed(KEY_R):
		stage_director.restart()
		get_tree().reload_current_scene()
	elif Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file(TITLE_SCENE)


func _advance_to_next_stage() -> void:
	var next_stage: int = stage_director.advance_stage()
	if next_stage == stage_number and next_stage == StageDirectorT.STAGE_MAX:
		return  # arc_complete signal handled by _on_arc_complete
	OS.set_environment("TANKE_OG_STAGE", str(next_stage))
	get_tree().reload_current_scene()


func _on_arc_complete() -> void:
	print("originals: ARC COMPLETE — all 35 stages cleared")
	_game_over = true
	_show_game_over_arc_complete()


func _show_game_over_arc_complete() -> void:
	_game_over_overlay = CanvasLayer.new()
	_game_over_overlay.layer = 10
	add_child(_game_over_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = Vector2(width, height)
	_game_over_overlay.add_child(dim)
	var label := Label.new()
	label.text = "ARC COMPLETE"
	label.add_theme_font_size_override("font_size", 24)
	label.position = Vector2(width * 0.5 - 84, height * 0.5 - 24)
	label.modulate = Color(0.2, 1.0, 0.4, 1.0)
	_game_over_overlay.add_child(label)
	var hint := Label.new()
	hint.text = "ESC TITLE"
	hint.position = Vector2(width * 0.5 - 36, height * 0.5 + 16)
	hint.modulate = Color(0.7, 0.7, 0.7, 1.0)
	_game_over_overlay.add_child(hint)
