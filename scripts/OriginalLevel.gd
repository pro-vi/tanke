extends "res://scripts/Level.gd"

const LevelLoaderT = preload("res://scripts/LevelLoader.gd")

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
	print("originals: stage %d  brick:%d steel:%d grass:%d water:%d ice_skipped:%d" % [
		stage_number, report.brick, report.steel, report.grass, report.water, report.ice_skipped
	])
	if not report.ok:
		push_error("LevelLoader failed for stage %d: %s" % [stage_number, report.error])
	_replace_blocks()
