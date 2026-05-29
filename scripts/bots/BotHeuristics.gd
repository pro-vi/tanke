class_name BotHeuristics
extends RefCounted

# Shared cardinal-movement primitives for the 7 bot policies — the repo's
# Enemy.gd has these inline (dominant-axis + sign projection, Enemy.gd:853;
# _opposite Enemy.gd:897) but exposes no reusable helper, so the bots get them
# here. Tile space is Y-down (Constants.Dir.D = +y, U = -y, L = -x, R = +x).

const NONE := -1  # mirrors BotAction.NONE (stationary)


# Manhattan tile distance (movement is cardinal, so Manhattan, not Euclidean).
static func manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# Cardinal step from `from_tile` toward `to_tile` (dominant axis + sign), or
# NONE if same tile. Mirrors Enemy._choose_direction_toward_player.
static func cardinal_toward(from_tile: Vector2i, to_tile: Vector2i) -> int:
	var dx := to_tile.x - from_tile.x
	var dy := to_tile.y - from_tile.y
	if dx == 0 and dy == 0:
		return NONE
	if absi(dx) > absi(dy):
		return Constants.Dir.R if dx > 0 else Constants.Dir.L
	return Constants.Dir.D if dy > 0 else Constants.Dir.U


# Cardinal step AWAY from `to_tile` (flee). Enemy.gd has no away-projection;
# this is the opposite of cardinal_toward.
static func cardinal_away(from_tile: Vector2i, to_tile: Vector2i) -> int:
	return opposite(cardinal_toward(from_tile, to_tile))


# The Dir if `to_tile` sits exactly on a cardinal axis from `from_tile` (same
# row -> L/R, same column -> U/D), else NONE. The "is the target lined up on my
# axis" test (analog of Enemy's dot(perp) alignment band, Enemy.gd:480).
static func aligned_dir(from_tile: Vector2i, to_tile: Vector2i) -> int:
	if from_tile == to_tile:
		return NONE
	if from_tile.x == to_tile.x:
		return Constants.Dir.D if to_tile.y > from_tile.y else Constants.Dir.U
	if from_tile.y == to_tile.y:
		return Constants.Dir.R if to_tile.x > from_tile.x else Constants.Dir.L
	return NONE


static func opposite(dir: int) -> int:
	match dir:
		Constants.Dir.U: return Constants.Dir.D
		Constants.Dir.D: return Constants.Dir.U
		Constants.Dir.L: return Constants.Dir.R
		Constants.Dir.R: return Constants.Dir.L
		_: return NONE


# Perpendicular cardinal to a world-space heading vector (for dodging). Picks
# the dominant axis of the 90deg rotation of `heading`.
static func perpendicular_cardinal(heading: Vector2) -> int:
	if heading.length() < 0.001:
		return NONE
	var perp := Vector2(-heading.y, heading.x)
	if absf(perp.x) > absf(perp.y):
		return Constants.Dir.R if perp.x > 0.0 else Constants.Dir.L
	return Constants.Dir.D if perp.y > 0.0 else Constants.Dir.U
