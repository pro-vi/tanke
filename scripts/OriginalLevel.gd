extends "res://scripts/Level.gd"

const LevelLoaderT = preload("res://scripts/LevelLoader.gd")
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


func _spawn_eagle() -> void:
	eagle = EagleScene.instantiate()
	eagle.global_position = EAGLE_SCREEN_POS
	add_child(eagle)
	eagle.eagle_destroyed.connect(_on_eagle_destroyed)


func _on_eagle_destroyed() -> void:
	# iter 003: minimal handler — logs. Game-over state machine lands in iter 4+
	# alongside the stage-progression director (criterion 10 anchor 2).
	print("originals: eagle destroyed on stage %d" % stage_number)
