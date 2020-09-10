var sets = {}  # set -> cells mapping
var cells = {}  # cells -> set mapping
var cell_width = 0  # cell num per row
var set_count = 0  # current set id

func _init(width, next_set=0):
	cell_width = width
	sets = sets
	cells = cells
	set_count = next_set

func generate_step():
	# assign each cell to its own set
	_init_row()
	
	# horizontally connect cells randomly
	for c in cell_width - 1:
		if _in_same_set(c, c+1) || randi() % 3 > 0:
			continue
		else:
			_merge(c, c+1)
	
	# for each set, add 0<n<size vertical connections to the next row
	var verticals = {}
	for sid in sets.keys():
		var cells = sets[sid]
		cells.shuffle()
		cells = cells.slice(0, randi() % cells.size())
		verticals[sid] = cells

	return verticals

# populate row
func _init_row():
	for c in cell_width:
		if not cells.has(c):
			_set_append(c, set_count)
			cells[c] = set_count
			set_count += 1

# merge target_cell to the set of sink_cell
func _merge(sink_cell, target_cell):
	var sink_set = cells[sink_cell]
	var target_set = cells[target_cell]
	sets[sink_set] += sets[target_set]
	for c in sets[target_set]:
		cells[c] = sink_set
	sets.erase(target_set)

func _in_same_set(c1, c2):
	return cells[c1] == cells[c2] 

func _set_append(cell, sid):
	if not sets.has(sid):
		sets[sid] = []
	sets[sid].append(cell)

func add_cell(cell, sid):
	_set_append(cell, sid)
	cells[cell] = sid
