extends Node2D

var BrickBlock = preload("res://scenes/BrickBlock.tscn")
var WaterBlock = preload("res://scenes/WaterBlock.tscn")
@onready var camera = $Camera2D
@onready var player = $PlayerTank
@onready var tiles = $Tiles
@onready var brickTileMap: TileMapLayer = tiles.get_node("BrickTileMap/Layer0")
@onready var steelTileMap: TileMapLayer = tiles.get_node("SteelTileMap/Layer0")
@onready var grassTileMap: TileMapLayer = tiles.get_node("GrassTileMap/Layer0")
@onready var waterTileMap: TileMapLayer = tiles.get_node("WaterTileMap/Layer0")
var width = ProjectSettings.get_setting("display/window/size/viewport_width")
var height = ProjectSettings.get_setting("display/window/size/viewport_height")


func _ready():
	player.shoot.connect(_on_PlayerTank_shoot)
	_replace_blocks()


func _replace_blocks():
	var offset = Vector2(4, 4)

	var brick_cells = brickTileMap.get_used_cells()
	for cell in brick_cells:
		var brick_block = BrickBlock.instantiate()
		brick_block.global_position = brickTileMap.map_to_local(cell) + offset
		add_child(brick_block)
	brickTileMap.clear()

	var water_cells = waterTileMap.get_used_cells()
	for cell in water_cells:
		var water_block = WaterBlock.instantiate()
		water_block.get_node("AnimatedSprite2D").play()
		water_block.global_position = waterTileMap.map_to_local(cell) + offset
		add_child(water_block)
	waterTileMap.clear()


func _on_PlayerTank_shoot(bullet, _position, _direction):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction)
