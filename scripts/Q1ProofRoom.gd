class_name Q1ProofRoom
extends Node

# Arc-4 Round 24 reframe Q1 sprint (iter 287; sprint mid-correction per
# iter-283 architect blueprint; consult-001 Q1 verdict 0.90):
# parser module + grid helpers for the breach-economy proof room.
#
# Embeds the tile grid as a const PackedStringArray so the playable
# scene (iter 288+) and the test harness (this iter) can read the
# same source of truth WITHOUT file I/O dependencies. The narrative
# version of the layout lives at loop/breach/q1_proof_layout.txt;
# this module's TILE_GRID is the canonical PROGRAMMATIC version.
#
# Tile legend:
#   .   empty (passable)
#   B   brick (StaticBody2D; HE blast clears 4+ cell radius)
#   S   steel (only APCR drills)
#   G   grass (passable; reduces visibility)
#   L   Light enemy spawn marker (hp=1, no armor)
#   H   Heavy enemy spawn marker (hp=3, armored)
#   P   player start marker (one per lane; player picks lane at start)
#   X   goal marker (depot cache; row 0)
#
# Grid is 30 rows × 21 cols. Lane assignment by column:
#   Lane HE:    cols 0-4
#   Lane APCR:  cols 5-9
#   Lane HEAT:  cols 10-14
#   Lane AP:    cols 15-20

const GRID_ROWS: int = 30
const GRID_COLS: int = 21
const GATE_ROW: int = 14    # The shell-gate row (mid-band)
const GOAL_ROW: int = 0     # Top of band; depot cache
const PLAYER_START_ROW: int = 29  # Bottom of band

# Lane boundaries (inclusive ranges).
const LANE_HE_COLS: Array[int] = [0, 4]
const LANE_APCR_COLS: Array[int] = [5, 9]
const LANE_HEAT_COLS: Array[int] = [10, 14]
const LANE_AP_COLS: Array[int] = [15, 20]

# Canonical tile grid. 30 strings, each 21 chars wide.
# Row 0 = top (goal). Row 29 = bottom (player start).
const TILE_GRID: PackedStringArray = [
	"XXXXXXXXXXXXXXXXXXXXX",  # 0 — GOAL row (depot cache spans all 4 lanes)
	".....................",  # 1
	".....................",  # 2
	"..L..................",  # 3 — light obstacle in HE-lane clearance
	"............L........",  # 4 — light obstacle in HEAT-lane clearance
	".......L.............",  # 5 — light obstacle in APCR-lane clearance
	".....................",  # 6
	".....................",  # 7
	".....................",  # 8
	".....................",  # 9
	".....................",  # 10
	".....................",  # 11
	".....................",  # 12
	".....................",  # 13
	"BBBBBSSSSS..H...L.L..",  # 14 — GATE ROW: HE brick / APCR steel / HEAT Heavy / AP Light patrol
	".....................",  # 15
	"..G..................",  # 16 — grass cover in HE-lane approach
	".....................",  # 17
	"........G............",  # 18 — grass cover in APCR-lane approach
	".....................",  # 19
	".....................",  # 20
	"............G........",  # 21 — grass cover in HEAT-lane approach
	".....................",  # 22
	"...................G.",  # 23 — grass cover in AP-lane approach
	".....................",  # 24
	".....................",  # 25
	".....................",  # 26
	".....................",  # 27
	".....................",  # 28
	"..P..P....P.......P..",  # 29 — PLAYER START (4 markers; one per lane)
]


# Lane name → (col_min, col_max) inclusive range.
const LANES: Dictionary = {
	"HE": LANE_HE_COLS,
	"APCR": LANE_APCR_COLS,
	"HEAT": LANE_HEAT_COLS,
	"AP": LANE_AP_COLS,
}


# Return the tile char at (col, row). Out-of-bounds → "" empty string.
static func terrain_at(col: int, row: int) -> String:
	if row < 0 or row >= GRID_ROWS:
		return ""
	if col < 0 or col >= GRID_COLS:
		return ""
	return TILE_GRID[row].substr(col, 1)


# Return the player-start column for the named lane (the column inside
# the lane that has a "P" tile at PLAYER_START_ROW). Returns -1 if no
# P marker found in the lane's column range.
static func player_start_col(lane: String) -> int:
	if not LANES.has(lane):
		return -1
	var lane_range: Array[int] = LANES[lane]
	for col in range(lane_range[0], lane_range[1] + 1):
		if terrain_at(col, PLAYER_START_ROW) == "P":
			return col
	return -1


# Return list of (col, row, tile) triples for all gate-row cells in a lane.
# Used by spawn logic to set is_route_gate meta on gate-row terrain/enemies.
static func gate_cells_for_lane(lane: String) -> Array:
	var out: Array = []
	if not LANES.has(lane):
		return out
	var lane_range: Array[int] = LANES[lane]
	for col in range(lane_range[0], lane_range[1] + 1):
		var t: String = terrain_at(col, GATE_ROW)
		if t != "" and t != ".":
			out.append([col, GATE_ROW, t])
	return out


# Validate the embedded grid against its declared dimensions. Returns
# an array of error strings (empty array = valid). Used by the harness
# to assert the const is well-formed.
static func validate_grid() -> Array[String]:
	var errors: Array[String] = []
	if TILE_GRID.size() != GRID_ROWS:
		errors.append("TILE_GRID has %d rows, want %d" % [TILE_GRID.size(), GRID_ROWS])
	for i in TILE_GRID.size():
		if TILE_GRID[i].length() != GRID_COLS:
			errors.append("Row %d has %d cols, want %d ('%s')" \
					% [i, TILE_GRID[i].length(), GRID_COLS, TILE_GRID[i]])
	return errors


# Convert grid (col, row) to scene-space pixel position. Uses BC's
# 16-pixel grid convention; offsets so (0,0) is upper-left of band.
static func grid_to_pixel(col: int, row: int, grid_size: int = 16) -> Vector2:
	return Vector2(col * grid_size, row * grid_size)
