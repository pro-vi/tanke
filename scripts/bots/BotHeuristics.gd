class_name BotHeuristics
extends RefCounted

# Shared cardinal-movement primitives for the bot policies. Tile space is Y-down
# (Constants.Dir.D = +y, U = -y, L = -x, R = +x). The obstacle-aware variants
# (step_toward / step_away / clear_shot) give bots the basic spatial competence
# a human playtester has — routing around brick/steel instead of jamming a wall,
# and not firing into cover — so their telemetry reflects real play, not the
# artifact of a stuck bot. Obstacles come from BotObservation.visible_obstacles
# (screen-visible only); these stay pure functions of the observation.

const NONE := -1  # mirrors BotAction.NONE (stationary)


static func manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


static func next_tile(from_tile: Vector2i, dir: int) -> Vector2i:
	match dir:
		Constants.Dir.U: return from_tile + Vector2i(0, -1)
		Constants.Dir.D: return from_tile + Vector2i(0, 1)
		Constants.Dir.L: return from_tile + Vector2i(-1, 0)
		Constants.Dir.R: return from_tile + Vector2i(1, 0)
		_: return from_tile


# Cardinal step from `from_tile` toward `to_tile` (dominant axis + sign), or
# NONE if same tile. Mirrors Enemy._choose_direction_toward_player. No collision.
static func cardinal_toward(from_tile: Vector2i, to_tile: Vector2i) -> int:
	var dx := to_tile.x - from_tile.x
	var dy := to_tile.y - from_tile.y
	if dx == 0 and dy == 0:
		return NONE
	if absi(dx) > absi(dy):
		return Constants.Dir.R if dx > 0 else Constants.Dir.L
	return Constants.Dir.D if dy > 0 else Constants.Dir.U


static func cardinal_away(from_tile: Vector2i, to_tile: Vector2i) -> int:
	return opposite(cardinal_toward(from_tile, to_tile))


# The Dir if `to_tile` sits exactly on a cardinal axis from `from_tile` (same
# row -> L/R, same column -> U/D), else NONE.
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


# The two cross-axis Dirs for `dir` (U/D -> L,R ; L/R -> U,D).
static func perpendiculars(dir: int) -> Array:
	if dir == Constants.Dir.U or dir == Constants.Dir.D:
		return [Constants.Dir.L, Constants.Dir.R]
	return [Constants.Dir.U, Constants.Dir.D]


# Perpendicular cardinal to a world-space heading vector (for dodging).
static func perpendicular_cardinal(heading: Vector2) -> int:
	if heading.length() < 0.001:
		return NONE
	var perp := Vector2(-heading.y, heading.x)
	if absf(perp.x) > absf(perp.y):
		return Constants.Dir.R if perp.x > 0.0 else Constants.Dir.L
	return Constants.Dir.D if perp.y > 0.0 else Constants.Dir.U


# Build a set (Dictionary keyed by Vector2i) of blocked tiles from a list of
# obstacle dicts {pos_tile, type}.
static func blocked_set(obstacles: Array) -> Dictionary:
	var s := {}
	for o in obstacles:
		s[o["pos_tile"]] = true
	return s


# Obstacle-aware step toward `to_tile`: prefer cardinal_toward; if that cell is
# blocked, try the perpendicular that gets closer to the target, then the other
# perpendicular, then the opposite. NONE only if fully boxed in. This is the
# bot-side analog of Enemy.gd's _try_step + perpendicular recovery.
static func step_toward(from_tile: Vector2i, to_tile: Vector2i, blocked: Dictionary) -> int:
	var primary := cardinal_toward(from_tile, to_tile)
	if primary == NONE:
		return NONE
	var perps := perpendiculars(primary)
	# closer-reducing perpendicular first (read-only capture of from/to is safe)
	perps.sort_custom(func(a, b):
		return manhattan(next_tile(from_tile, a), to_tile) < manhattan(next_tile(from_tile, b), to_tile))
	var candidates := [primary, perps[0], perps[1], opposite(primary)]
	for d in candidates:
		if not blocked.has(next_tile(from_tile, d)):
			return d
	return NONE  # boxed in on all four sides


# Obstacle-aware flee from `to_tile` (step toward the mirror point on the far side).
static func step_away(from_tile: Vector2i, to_tile: Vector2i, blocked: Dictionary) -> int:
	return step_toward(from_tile, from_tile + (from_tile - to_tile), blocked)


# Bounded BFS over free tiles (within `radius` Manhattan of the start) to find
# the first step on a shortest path to the HIGHEST reachable tile (min y = most
# climbed). Escapes the local minima that trap greedy step_toward in a maze:
# greedy sidesteps a wall then re-points straight up into it again; this looks
# `radius` tiles ahead and commits to a route around the pocket. NONE if boxed in.
static func step_climb(from_tile: Vector2i, blocked: Dictionary, radius: int) -> int:
	return step_bfs(from_tile, Vector2i(from_tile.x, from_tile.y - radius - 1), blocked, radius)


# Bounded BFS first-step toward `goal` (or the reachable tile nearest goal within
# `radius`). General maze navigation: returns the Dir of the first step on a
# shortest path. NONE if no reachable free tile improves on staying put.
static func step_bfs(from_tile: Vector2i, goal: Vector2i, blocked: Dictionary, radius: int) -> int:
	var dirs := [Constants.Dir.U, Constants.Dir.D, Constants.Dir.L, Constants.Dir.R]
	var first_step := {}          # tile -> Dir of the first step from the origin
	var visited := {from_tile: true}
	var queue := [from_tile]
	var qi := 0
	var best := from_tile
	var best_d := manhattan(from_tile, goal)
	while qi < queue.size():
		var cur: Vector2i = queue[qi]
		qi += 1
		for dir in dirs:
			var nxt := next_tile(cur, dir)
			if visited.has(nxt) or blocked.has(nxt):
				continue
			if manhattan(nxt, from_tile) > radius:
				continue
			visited[nxt] = true
			first_step[nxt] = first_step.get(cur, dir)
			queue.append(nxt)
			var d := manhattan(nxt, goal)
			if d < best_d:
				best_d = d
				best = nxt
	if best == from_tile:
		return NONE
	return first_step.get(best, NONE)


# True iff `to_tile` is on a cardinal axis from `from_tile` AND no blocked tile
# lies strictly between them on that axis (don't fire into cover).
static func clear_shot(from_tile: Vector2i, to_tile: Vector2i, blocked: Dictionary) -> bool:
	if from_tile == to_tile:
		return false
	if from_tile.x == to_tile.x:
		var sy := 1 if to_tile.y > from_tile.y else -1
		var y := from_tile.y + sy
		while y != to_tile.y:
			if blocked.has(Vector2i(from_tile.x, y)):
				return false
			y += sy
		return true
	if from_tile.y == to_tile.y:
		var sx := 1 if to_tile.x > from_tile.x else -1
		var x := from_tile.x + sx
		while x != to_tile.x:
			if blocked.has(Vector2i(x, from_tile.y)):
				return false
			x += sx
		return true
	return false  # not axis-aligned
