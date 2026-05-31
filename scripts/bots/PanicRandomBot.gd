class_name PanicRandomBot
extends BotPolicy

# Heuristic: a nervous player — once HURT (HP below max, or below 50%), flail in
# a DETERMINISTIC pseudo-random UNBLOCKED cardinal direction (derived from the
# observation, NOT RNG — reproducible for the oracle); while unhurt, pursue the
# nearest enemy. The hurt-trigger (vs the old <25% that almost never fired
# before death) makes this genuinely distinct from approach-enemy. (AC-001 policy 6/7.)

const PANIC_HP_FRAC := 0.5
const RELOAD_READY := 0.8


func _init() -> void:
	bot_id = "panic-random"


func tick(obs: BotObservation) -> BotAction:
	var frac := 1.0
	if obs.player_hp_max > 0:
		frac = float(obs.player_hp) / float(obs.player_hp_max)
	var blocked := BotHeuristics.blocked_set(obs.visible_obstacles)
	if obs.player_hp < obs.player_hp_max or frac < PANIC_HP_FRAC:
		# deterministic "random": hash tick+pos, then pick the first UNBLOCKED
		# cardinal from there (flail, but don't just ram a wall)
		var h := obs.iter_n + obs.player_pos_tile.x * 7 + obs.player_pos_tile.y * 13
		for k in 4:
			var dir := posmod(h + k, 4)  # 0..3 == Constants.Dir.L/D/U/R
			if not blocked.has(BotHeuristics.next_tile(obs.player_pos_tile, dir)):
				return BotAction.new(dir, false)
		return BotAction.new(posmod(h, 4), false)
	# unhurt -> pursue nearest enemy with clear-shot fire
	var ne := obs.nearest_enemy()
	if ne.is_empty():
		return BotAction.new(Constants.Dir.U, false)
	var epos: Vector2i = ne["pos_tile"]
	var move := BotHeuristics.step_toward(obs.player_pos_tile, epos, blocked)
	return BotAction.new(move, BotHeuristics.clear_shot(obs.player_pos_tile, epos, blocked) and obs.reload_bar_value >= RELOAD_READY)
