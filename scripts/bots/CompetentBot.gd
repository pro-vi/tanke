class_name CompetentBot
extends BotPolicy

# The composite "competent player" — the one bot built to traverse the REAL
# procedural arc (BreachLevel). The 7 v0.1 policies each embody ONE verb and stall
# on whatever they don't handle; the arc needs all four at once, run as a per-tick
# priority cascade:
#
#   1. SURVIVE — dodge an enemy shell about to hit (perpendicular slip)
#   2. ENGAGE  — clear an enemy blocking the climb lane (HEAT vs Heavy if stocked)
#   3. CLIMB   — follow a frontier path from NavMemory, a STATEFUL terrain map that
#                escapes the water/steel local minima a stateless climber traps in
#   4. BREACH  — pierce brick (AP, or HE for a dense wall) / steel (APCR) in the path
#
# Unlike the 7 stateless probes, this bot carries navigation MEMORY (NavMemory):
# a deliberate, documented exception to the stateless-policy convention, taken to
# reach the endgame band the reactive cascade physically could not (it trapped at
# ~row 4 oscillating against a water pocket). Determinism + per-run isolation are
# preserved (NavMemory evolves deterministically; fresh per run). Shell swaps are
# expressed via action.shell_swap_to; the driver pulses TAB toward the target and
# the bot re-decides each tick from obs.current_shell_class.
#
# DELIBERATELY NOT in BotRegistry: an 8th policy there would flip the frozen Q1
# matrix to 8x12=96 and break RUNS_OK 84/84 + BOTS_OK 7/7; the arc runner resolves
# "competent" directly. (arc-harness-v0.2 plan, Architecture Decision.)

const RELOAD_READY := 0.8     # mirror ApproachEnemyBot — don't fire mid-reload at enemies
const BREACH_LOOKAHEAD := 3   # tiles directly above to count toward "dense brick wall"
const DODGE_RANGE := 6        # an incoming enemy shell this close (Manhattan) is imminent
# Staged for the not-yet-built motion-primitive controller (U10 / plan addendum):
# the lane-error layer that realigns the perpendicular axis before advancing.
const CELL_PX := 8.0          # observation tile size (px) — tile T centre is at T*CELL_PX
const LANE_TOL := 3.0         # px of perpendicular drift tolerated before realigning to lane
const DEPOT_SEEK_ROWS := 6    # bias toward a depot within this many rows above
const DEPOT_ALIGN_TILES := 2  # within this column delta the player overlaps the 32px gate

# Bullet shell-class ints (scripts/Bullet.gd:11) — mirrored in BotAction's contract.
const SHELL_AP := 0
const SHELL_HE := 1
const SHELL_HEAT := 2
const SHELL_APCR := 3

# Persistent navigation memory (the one piece of cross-tick state). Fresh per
# instance, and the arc runner makes a new bot per run, so nothing leaks.
var _nav := NavMemory.new()


func _init() -> void:
	bot_id = "competent"


func tick(obs: BotObservation) -> BotAction:
	var pos: Vector2i = obs.player_pos_tile
	var raw := BotHeuristics.blocked_set(obs.visible_obstacles)   # all — for dodge/clear_shot/depot
	# Fold this tick's terrain into the persistent map (water/steel only; bricks are
	# breakable so the plan routes straight through them and the bot breaches).
	_nav.observe(obs.visible_obstacles)

	# 1. SURVIVE — an enemy shell is about to land: slip perpendicular to its path.
	var inc := obs.incoming_projectile()
	if not inc.is_empty():
		var ipos: Vector2i = inc["pos_tile"]
		if BotHeuristics.manhattan(ipos, pos) <= DODGE_RANGE:
			var dodge := BotHeuristics.perpendicular_cardinal(inc.get("dir", Vector2.ZERO))
			if dodge != BotHeuristics.NONE and raw.has(BotHeuristics.next_tile(pos, dodge)):
				dodge = BotHeuristics.opposite(dodge)
			if dodge != BotHeuristics.NONE:
				return BotAction.new(dodge, false)

	# 2. CLIMB — follow the frontier path planned over the accumulated terrain map.
	# (NOTE: the GPT-Pro second opinion identifies the real depth-ceiling fix as a
	# footprint-aligned MOTION-PRIMITIVE controller — align the perpendicular axis,
	# THEN advance, as a phased primitive with progress-abort — see the plan
	# addendum. A quick per-tick realign-or-advance toggle regressed (oscillated in
	# place), so that controller is left as the next, carefully-built step; this
	# remains the best working version.)
	var step := _nav.plan_step(pos)
	if step == BotHeuristics.NONE:
		step = Constants.Dir.U   # fully enclosed by known impassable — push up + breach-try

	# Finalize the heading FIRST — a depot detour can override the climb step with a
	# horizontal L/R seek. fire/swap MUST be derived from the heading the tank will
	# ACTUALLY face, or a shot meant to breach a blocker above is emitted while the
	# tank faces sideways: the breach never lands and the tank stays blocked.
	# (PR#5 review #3: compose fire/swap on the final move, not the pre-bias step.)
	var move := _depot_bias(obs, pos, raw, step)

	# 3. FIRE/SWAP while moving — NEVER halt for combat. The tank faces its move
	# direction, so a forward shot hits whatever is along it: breach the terrain
	# blocker ahead (steel->APCR, dense brick wall->HE, else cheap AP), or shoot an
	# enemy lined up that way (Heavy->HEAT). Off-axis enemies are climbed past.
	var fire := false
	var swap := BotAction.NO_SWAP
	var blk := _blocker_ahead(obs, pos, move)
	if blk == "steel":
		if _reserve(obs, SHELL_APCR) > 0:
			if obs.current_shell_class != SHELL_APCR:
				swap = SHELL_APCR
			else:
				fire = true
	elif blk == "brick":
		fire = true
		if move == Constants.Dir.U and _footprint_brick_density(obs, pos) >= 3 \
				and _reserve(obs, SHELL_HE) > 0:
			if obs.current_shell_class != SHELL_HE:
				swap = SHELL_HE
				fire = false   # cycle to HE first; breach the wide lane next tick
	else:
		var foe := _enemy_in_dir(obs, pos, move, raw)
		if not foe.is_empty() and obs.reload_bar_value >= RELOAD_READY:
			fire = true
			if str(foe.get("type", "")) == "Heavy" and _reserve(obs, SHELL_HEAT) > 0 \
					and obs.current_shell_class != SHELL_HEAT:
				swap = SHELL_HEAT
				fire = false   # cycle to HEAT first

	return BotAction.new(move, fire, swap)


# An enemy lined up on the cardinal axis in direction `dir` from pos with a clear
# (un-blocked) shot — i.e., one the tank's forward gun will hit while moving that
# way. {} if none. Off-axis enemies are intentionally NOT engaged (climb past).
func _enemy_in_dir(obs: BotObservation, pos: Vector2i, dir: int, blocked: Dictionary) -> Dictionary:
	if dir == BotHeuristics.NONE:
		return {}
	for e in obs.visible_enemies:
		var ep: Vector2i = e["pos_tile"]
		if BotHeuristics.aligned_dir(pos, ep) == dir and BotHeuristics.clear_shot(pos, ep, blocked):
			return e
	return {}


# The obstacle the tank's leading edge hits when stepping in `dir` — the cell
# ahead plus the two cells flanking it (perpendicular to motion), covering the
# 16px tank's width. Returns "steel" (priority — needs APCR), else "brick", else
# "water", else "". Lets the bot breach whatever blocks the PLANNED step,
# whichever direction it's heading (up through a wall, or sideways around water).
func _blocker_ahead(obs: BotObservation, pos: Vector2i, dir: int) -> String:
	if dir == BotHeuristics.NONE:
		return ""
	var ahead := BotHeuristics.next_tile(pos, dir)
	var perps := BotHeuristics.perpendiculars(dir)
	var cells := {
		ahead: true,
		BotHeuristics.next_tile(ahead, perps[0]): true,
		BotHeuristics.next_tile(ahead, perps[1]): true,
	}
	var found := ""
	for o in obs.visible_obstacles:
		if not cells.has(o["pos_tile"]):
			continue
		var ty := str(o.get("type", ""))
		if ty == "steel":
			return "steel"
		if ty == "brick":
			found = "brick"
		elif found == "":
			found = ty   # water
	return found


# Count bricks in the footprint above (|dx| <= 1, up to BREACH_LOOKAHEAD rows up).
# A high count means a dense wall, not a lone brick — the 16px tank needs HE's
# wide blast to open a 2-tile channel through it rather than a single AP hole.
func _footprint_brick_density(obs: BotObservation, pos: Vector2i) -> int:
	var n: int = 0
	for o in obs.visible_obstacles:
		if str(o.get("type", "")) != "brick":
			continue
		var op: Vector2i = o["pos_tile"]
		if absi(op.x - pos.x) <= 1 and op.y < pos.y and (pos.y - op.y) <= BREACH_LOOKAHEAD:
			n += 1
	return n


# Reserve count for a shell class. AP is unlimited (-1 sentinel) -> reported as
# plentiful so the AP path is always affordable.
func _reserve(obs: BotObservation, shell_class: int) -> int:
	match shell_class:
		SHELL_AP: return 1 << 30
		SHELL_HE: return int(obs.shell_reserves.get("HE", 0))
		SHELL_HEAT: return int(obs.shell_reserves.get("HEAT", 0))
		SHELL_APCR: return int(obs.shell_reserves.get("APCR", 0))
	return 0


# Gentle steer onto an upcoming depot's column so the upgrade gate triggers (a
# human detours slightly to grab a depot). Only overrides the climb step when a
# depot is a few rows above and the player is off its column; returns the climb
# move otherwise. Stateless: re-evaluated each tick from visible_depots.
func _depot_bias(obs: BotObservation, pos: Vector2i, blocked: Dictionary, move: int) -> int:
	var best: Dictionary = {}
	var best_d: int = 1 << 30
	for dpt in obs.visible_depots:
		var dpos: Vector2i = dpt["pos_tile"]
		var dy: int = pos.y - dpos.y         # >= 0 == at/above the player (not yet passed)
		if dy >= 0 and dy <= DEPOT_SEEK_ROWS:
			var dist: int = absi(dpos.x - pos.x) + dy
			if dist < best_d:
				best_d = dist
				best = dpt
	if best.is_empty():
		return move
	var dx: int = (best["pos_tile"] as Vector2i).x - pos.x
	if absi(dx) <= DEPOT_ALIGN_TILES:
		return move   # already column-aligned enough to overlap the gate
	var horiz := BotHeuristics.step_toward(pos, Vector2i((best["pos_tile"] as Vector2i).x, pos.y), blocked)
	if horiz == Constants.Dir.L or horiz == Constants.Dir.R:
		return horiz
	return move
