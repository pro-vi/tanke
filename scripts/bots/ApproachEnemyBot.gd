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
	var blocked := BotHeuristics.blocked_set(obs.visible_obstacles)
	var move := BotHeuristics.step_toward(obs.player_pos_tile, epos, blocked)
	# fire only with a clear line (don't waste shells into cover) + reloaded
	var fire := BotHeuristics.clear_shot(obs.player_pos_tile, epos, blocked) and obs.reload_bar_value >= RELOAD_READY
	return BotAction.new(move, fire)
