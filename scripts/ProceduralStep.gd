var sets: Dictionary = {}  # set -> cells mapping
var cells: Dictionary = {}  # cells -> set mapping
var cell_width: int = 0  # cell num per row
var set_count: int = 0  # current set id
var merge_probability: float = 0.333  # P(merge) for horizontally adjacent cells


func _init(width: int, next_set: int = 0, p_merge: float = 0.333) -> void:
	cell_width = width
	set_count = next_set
	merge_probability = p_merge


func generate_step() -> Dictionary:
	# assign each cell to its own set
	_init_row()

	# horizontally connect cells randomly
	for c in cell_width - 1:
		if _in_same_set(c, c + 1) || randf() >= merge_probability:
			continue
		else:
			_merge(c, c + 1)

	# For each set, carry 1..size cells vertically to the next row.
	# Classical Eller's invariant: every set MUST have at least one vertical
	# connection or it gets stranded as a topological island. Iter 21 fixed
	# the off-by-one (`randi() % size` could emit zero) — every set now
	# carries at least one cell.
	var verticals: Dictionary = {}
	for sid in sets.keys():
		var members: Array = sets[sid]
		# iter 101 (review-fix): forward-safety assert — current invariant says
		# every set has size >= 1, but a future _merge edit producing an empty
		# set would crash on `randi() % 0` with no diagnostic.
		assert(members.size() > 0, "ProceduralStep: empty set %d during carry-up" % sid)
		members.shuffle()
		var carry: int = (randi() % members.size()) + 1
		verticals[sid] = members.slice(0, carry)

	return verticals


# populate row
func _init_row() -> void:
	for c in cell_width:
		if not cells.has(c):
			_set_append(c, set_count)
			cells[c] = set_count
			set_count += 1


# merge target_cell to the set of sink_cell
func _merge(sink_cell: int, target_cell: int) -> void:
	var sink_set: int = cells[sink_cell]
	var target_set: int = cells[target_cell]
	sets[sink_set] += sets[target_set]
	for c in sets[target_set]:
		cells[c] = sink_set
	sets.erase(target_set)


func _in_same_set(c1: int, c2: int) -> bool:
	return cells[c1] == cells[c2]


func _set_append(cell: int, sid: int) -> void:
	if not sets.has(sid):
		sets[sid] = []
	sets[sid].append(cell)


func add_cell(cell: int, sid: int) -> void:
	_set_append(cell, sid)
	cells[cell] = sid
