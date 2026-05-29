class_name PanicRandomBot
extends BotPolicy

# Heuristic: below 25% HP, flail in a DETERMINISTIC pseudo-random cardinal
# direction (derived from the observation, NOT RNG — bots must be reproducible
# for the oracle); otherwise behave like approach-enemy. (AC-001 policy 6/7.)

const PANIC_HP_FRAC := 0.25
const RELOAD_READY := 0.8


func _init() -> void:
	bot_id = "panic-random"


func tick(obs: BotObservation) -> BotAction:
	var frac := 1.0
	if obs.player_hp_max > 0:
		frac = float(obs.player_hp) / float(obs.player_hp_max)
	if frac < PANIC_HP_FRAC:
		# deterministic "random": hash the tick + position into a cardinal Dir
		var h := obs.iter_n + obs.player_pos_tile.x * 7 + obs.player_pos_tile.y * 13
		var dir := posmod(h, 4)  # 0..3 == Constants.Dir.L/D/U/R
		return BotAction.new(dir, false)
	# calm -> approach-enemy behaviour
	var ne := obs.nearest_enemy()
	if ne.is_empty():
		return BotAction.new(Constants.Dir.U, false)
	var epos: Vector2i = ne["pos_tile"]
	var move := BotHeuristics.cardinal_toward(obs.player_pos_tile, epos)
	var aligned := BotHeuristics.aligned_dir(obs.player_pos_tile, epos) != BotHeuristics.NONE
	return BotAction.new(move, aligned and obs.reload_bar_value >= RELOAD_READY)
