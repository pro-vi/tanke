extends Node2D

var BrickBlock = preload("res://scenes/BrickBlock.tscn")
var WaterBlock = preload("res://scenes/WaterBlock.tscn")
onready var camera = $Camera2D
onready var player = $PlayerTank
onready var tiles = $Tiles
onready var brickTileMap = tiles.get_node("BrickTileMap")
onready var steelTileMap = tiles.get_node("SteelTileMap")
onready var grassTileMap = tiles.get_node("GrassTileMap")
onready var waterTileMap = tiles.get_node("WaterTileMap")
var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")


func _ready():
	_replace_blocks()


func _replace_blocks():
	var offset = Vector2(4, 4)

	var brick_cells = brickTileMap.get_used_cells()
	for cell in brick_cells:
		var brick_block = BrickBlock.instance()
		brick_block.global_position = brickTileMap.map_to_world(cell) + offset
		add_child(brick_block)
	brickTileMap.clear()
	
	var water_cells = waterTileMap.get_used_cells()
	for cell in water_cells:
		var water_block = WaterBlock.instance()
		water_block.get_node("AnimatedSprite").play()
		water_block.global_position = waterTileMap.map_to_world(cell) + offset
		add_child(water_block)
	waterTileMap.clear()
