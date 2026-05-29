class_name ApproachEnemyBot
extends BotPolicy

# Heuristic: move toward the closest visible enemy; fire when it is lined up on
# a cardinal axis AND the gun is reloaded (>= RELOAD_READY). (AC-001 policy 3/7.)

const RELOAD_READY := 0.8


func _init() -> void:
	bot_id = "approach-enemy"


func tick(obs: BotObservation) -> BotAction:
	var ne := obs.nearest_enemy()
	if ne.is_empty():
		return BotAction.new(Constants.Dir.U, false)  # no enemy -> probe upward
	var epos: Vector2i = ne["pos_tile"]
	var move := BotHeuristics.cardinal_toward(obs.player_pos_tile, epos)
	var aligned := BotHeuristics.aligned_dir(obs.player_pos_tile, epos) != BotHeuristics.NONE
	var fire := aligned and obs.reload_bar_value >= RELOAD_READY
	return BotAction.new(move, fire)
