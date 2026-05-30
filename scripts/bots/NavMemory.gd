class_name NavMemory
extends RefCounted

# Stateful navigation memory for the arc CompetentBot. A STATELESS reactive
# climber (BFS to the highest cell within a fixed radius) traps in water/steel
# local minima: it keeps re-selecting the locally-highest reachable cell (a
# pocket ceiling) and oscillates forever — exactly why the reactive bot stalled
# at ~row 4. This accumulates the IMPASSABLE terrain it has seen (water + steel
# are static, so the map only grows) into a persistent grid and plans a frontier
# path over it, biased to the highest UNVISITED reachable cell. That makes the
# tank explore OUT of a pocket (down/around, then up a clear column) instead of
# grinding the ceiling. Bricks are breakable, so they NEVER enter the map — the
# bot plans through them and breaches as it advances.
#
# Determinism: every field evolves deterministically from the (deterministic)
# observation stream; BFS expansion + target tie-breaks are fully ordered. A
# fresh instance per run (CompetentBot is re-created per run) means no leak.
# This is a deliberate, documented exception to the stateless-policy convention,
# taken to reach the endgame band the reactive cascade could not.

const REPLAN_EVERY := 12      # ticks between full replans (the path is cached between)
const STUCK_REPLAN := 6       # ticks of zero centre-movement before forcing a replan
const NODE_BUDGET := 2500     # max cells expanded per plan (bounds per-tick cost)

var _blocked := {}            # accumulated INFLATED impassable (water/steel) cells
var _seen := {}               # raw impassable already folded into _blocked
var _visited := {}            # cells the tank centre has occupied
var _path: Array = []         # cached planned route (Vector2i cells) pos -> frontier
var _path_i: int = 0
var _ticks: int = 0
var _stuck: int = 0
var _last_pos := Vector2i(1 << 30, 1 << 30)


# Fold this tick's IMPASSABLE terrain into the persistent map. Water + steel are
# static, so they accumulate permanently, inflated by the tank's ~1-tile radius
# so the planned centre keeps clearance. Bricks are NOT recorded — they're
# breakable, so the plan routes straight through them and the bot breaches.
func observe(obstacles: Array) -> void:
	for o in obstacles:
		var ty: String = str(o.get("type", ""))
		if ty != "water" and ty != "steel":
			continue
		var bp: Vector2i = o["pos_tile"]
		if _seen.has(bp):
			continue
		_seen[bp] = true
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				_blocked[bp + Vector2i(dx, dy)] = true


# The next cardinal step toward the frontier. NONE only if fully enclosed by
# known impassable (no reachable cell improves on staying put).
func plan_step(pos: Vector2i) -> int:
	_visited[pos] = true
	_ticks += 1
	_stuck = _stuck + 1 if pos == _last_pos else 0
	_last_pos = pos
	if _path.is_empty() or _path_i >= _path.size() \
			or _ticks >= REPLAN_EVERY or _stuck >= STUCK_REPLAN or _next_cell_blocked():
		_replan(pos)
		_ticks = 0
	# consume cells already reached (the tank may overshoot a cell in one frame)
	while _path_i < _path.size() and _path[_path_i] == pos:
		_path_i += 1
	if _path_i >= _path.size():
		return BotHeuristics.NONE
	return BotHeuristics.cardinal_toward(pos, _path[_path_i])


func _next_cell_blocked() -> bool:
	return _path_i < _path.size() and _blocked.has(_path[_path_i])


# The cell the plan is currently steering toward (for the motion executor's
# px-level lane-error). _last_pos when the path is exhausted. Call after plan_step.
func current_target() -> Vector2i:
	if _path_i < _path.size():
		return _path[_path_i]
	return _last_pos


# Plan a route to the frontier over the accumulated impassable map (brick is
# passable — breached as the tank advances). Targets the highest reachable
# UNVISITED cell, which is what escapes pockets: once the local ceiling is
# visited the bot is pushed to unexplored space that leads around to a clear
# column. (A "prefer pure-open routes" tier was tried and regressed — it sent the
# tank on long lateral detours to the map edge rather than breaching one brick.)
func _replan(pos: Vector2i) -> void:
	_set_path(pos, _bfs(pos))


# BFS from pos to the highest reachable UNVISITED cell (fallback: highest overall).
# Brick is passable (breached as the tank advances); only the accumulated
# water/steel map blocks. Returns {target, parent}.
func _bfs(pos: Vector2i) -> Dictionary:
	var dirs := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1)]
	var parent := {pos: pos}
	var queue: Array = [pos]
	var qi: int = 0
	var expanded: int = 0
	var best_unvisited := Vector2i(1 << 30, 1 << 30)
	var have_unvisited := false
	var best_any := pos
	while qi < queue.size() and expanded < NODE_BUDGET:
		var cur: Vector2i = queue[qi]
		qi += 1
		expanded += 1
		for d in dirs:
			var nxt: Vector2i = cur + d
			if parent.has(nxt) or _blocked.has(nxt):
				continue
			parent[nxt] = cur
			queue.append(nxt)
			if _higher(nxt, best_any):
				best_any = nxt
			if not _visited.has(nxt) and (not have_unvisited or _higher(nxt, best_unvisited)):
				best_unvisited = nxt
				have_unvisited = true
	return {"target": best_unvisited if have_unvisited else best_any, "parent": parent}


func _set_path(pos: Vector2i, plan: Dictionary) -> void:
	var parent: Dictionary = plan["parent"]
	var rev: Array = []
	var c: Vector2i = plan["target"]
	while c != pos and parent.has(c):
		rev.append(c)
		c = parent[c]
	rev.reverse()
	_path = rev
	_path_i = 0


# True if a ranks higher than b: smaller y wins (climb); ties break by nearer
# column to a's own x then by x,y for full determinism.
func _higher(a: Vector2i, b: Vector2i) -> bool:
	if a.y != b.y:
		return a.y < b.y
	if absi(a.x) != absi(b.x):
		return absi(a.x) < absi(b.x)
	if a.x != b.x:
		return a.x < b.x
	return false
