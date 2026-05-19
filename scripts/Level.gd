extends Node2D

const BrickBlock: PackedScene = preload("res://scenes/BrickBlock.tscn")
const WaterBlock: PackedScene = preload("res://scenes/WaterBlock.tscn")
@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $PlayerTank
@onready var tiles: Node2D = $Tiles
@onready var brickTileMap: TileMapLayer = tiles.get_node("Brick")
@onready var steelTileMap: TileMapLayer = tiles.get_node("Steel")
@onready var grassTileMap: TileMapLayer = tiles.get_node("Grass")
@onready var waterTileMap: TileMapLayer = tiles.get_node("Water")
var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")


func _ready() -> void:
	player.shoot.connect(_on_PlayerTank_shoot)
	_replace_blocks()


func _replace_blocks() -> void:
	for cell in brickTileMap.get_used_cells():
		var brick_block: Node2D = BrickBlock.instantiate()
		brick_block.global_position = brickTileMap.map_to_local(cell)
		add_child(brick_block)
	brickTileMap.clear()

	for cell in waterTileMap.get_used_cells():
		var water_block: Node2D = WaterBlock.instantiate()
		water_block.get_node("AnimatedSprite2D").play()
		water_block.global_position = waterTileMap.map_to_local(cell)
		add_child(water_block)
	waterTileMap.clear()


func _on_PlayerTank_shoot(bullet: PackedScene, _position: Vector2, _direction: int, shell_class: int = 0) -> void:
	var b: Node2D = bullet.instantiate()
	add_child(b)
	# iter 101 (review-fix): pass mask explicitly — Environment (1) + Enemy (8).
	# Previously relied on Bullet.tscn's baked collision_mask=9, hiding shooter
	# intent at the call site.
	# arc-4 iter 8: route shell_class to Bullet.start()'s 4th param. Default
	# `shell_class = 0` (SHELL_CLASS_AP) preserves arc-2/3 baseline when the
	# caller (PlayerTank without loadout, or any non-arc-4 emitter) doesn't
	# supply the param.
	b.start(_position, _direction, 9, shell_class)
