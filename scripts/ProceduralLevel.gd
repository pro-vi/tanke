extends "res://scripts/Level.gd"

const ProceduralStep = preload("res://scripts/ProceduralStep.gd")
const DebugBlock = preload("res://scenes/DebugBlock.tscn")
export var debug = false

# algo variables
var osn
var ps
var verts
var next_row = 0
var grid_size = 16


func _ready():
	randomize()
	# init starting area
	ps = ProceduralStep.new(width/grid_size)
	verts = ps.generate_step()
	for row in range(height/grid_size, -1, -1):
		if row == height/grid_size - 1:
			continue
		_generate_next_row()

		for sid in ps.sets:
			_pave_set(sid, row)
			if debug:
				_pave_debug(sid, row)

		next_row = row - 1

	if false:
		# perlin noise
		osn = OpenSimplexNoise.new()
		osn.seed = randi()
		osn.octaves = 4
		osn.period = 15
		osn.lacunarity = 1.5
		osn.persistence = 0.75

		_generate_level_perlin()

	_replace_bricks()

func _process(_delta):
	var player_pos = player.position
	var next_row_h = next_row * grid_size
	
	if player_pos.y - next_row_h < height/2 + grid_size:
		_generate_next_row()

		for sid in ps.sets:
			_pave_set(sid, next_row)
			if debug:
				_pave_debug(sid, next_row)
		_replace_bricks()

		next_row -= 1

# populate the next procedural step using verts
func _generate_next_row():
	ps = ProceduralStep.new(width/grid_size, ps.set_count)
	for sid in verts:
		for c in verts[sid]:
			ps.add_cell(c, sid)
	verts = ps.generate_step()

# naive approach tile distribution
func _pave_set(sid, row):
	var size = ps.sets[sid].size()
	if 2 <= size and size <= 7 and sid % 2 == 0:
		for c in ps.sets[sid]:
			brickTileMap.set_cell(c*2, row*2, 0)
			brickTileMap.set_cell(c*2+1, row*2, 0)
			brickTileMap.set_cell(c*2, row*2+1, 0)
			brickTileMap.set_cell(c*2+1, row*2+1, 0)
	elif size <= 1 and sid % 3 == 0:
		for c in ps.sets[sid]:
			grassTileMap.set_cell(c*2, row*2, 0)
			grassTileMap.set_cell(c*2+1, row*2, 0)
			grassTileMap.set_cell(c*2, row*2+1, 0)
			grassTileMap.set_cell(c*2+1, row*2+1, 0)
	elif 2 <= size and size <= 3 and (sid % 5 == 0 or sid % 7 == 0):
		for c in ps.sets[sid]:
			steelTileMap.set_cell(c*2, row*2, 0)
			steelTileMap.set_cell(c*2+1, row*2, 0)
			steelTileMap.set_cell(c*2, row*2+1, 0)
			steelTileMap.set_cell(c*2+1, row*2+1, 0)

func _pave_debug(sid, row):
	for c in ps.sets[sid]:
		var debug_block = DebugBlock.instance()
		debug_block.get_node("Rect/Text").text = str(sid%100)
		debug_block.position = Vector2(c*grid_size+8, row*grid_size+8)
		add_child(debug_block)


func _generate_level_perlin():
	for x in width/grid_size:
		for y in height/grid_size:
			var sample = osn.get_noise_2d(float(x), float(y))
			if sample < -0.3:
				steelTileMap.set_cell(x, y, 0)
			elif (sample > 0.25) or (sample > -0.033 and sample < 0.033):
				brickTileMap.set_cell(x, y, 0)


