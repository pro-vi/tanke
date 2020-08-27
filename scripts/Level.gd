extends Node2D

var BrickBlock = preload("res://scenes/BrickBlock.tscn")

onready var tiles = $Tiles
onready var brickTileMap = tiles.get_node("BrickTileMap")
onready var steelTileMap = tiles.get_node("SteelTileMap")


func _ready():
	_replace_bricks()


func _replace_bricks():
	var brick_cells = brickTileMap.get_used_cells()
	for cell in brick_cells:
		var brick_block = BrickBlock.instance()
		brick_block.global_position = Vector2(cell.x, cell.y)
	brick_cells.clear()
