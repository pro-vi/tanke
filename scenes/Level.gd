extends Node2D

var BrickBlock = preload("res://scenes/BrickBlock.tscn")

onready var tiles = $Tiles


func _ready():
	# replace brick cells with BrickBlock
	var brickTileMap = tiles.get_node("BrickTileMap")
	var brick_cells = brickTileMap.get_used_cells()
	for cell in brick_cells:
		var brick_block = BrickBlock.instance()
		brick_block.global_position = Vector2(cell.x, cell.y)
	brick_cells.clear()
	
	print(brick_cells)
