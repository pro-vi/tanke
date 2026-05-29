class_name FireWhenLinedUpBot
extends BotPolicy

# Heuristic: stationary turret — never moves; fires only when the closest enemy
# is lined up on a cardinal axis. (AC-001 policy 4/7.)

func _init() -> void:
	bot_id = "fire-when-lined-up"


func tick(obs: BotObservation) -> BotAction:
	var ne := obs.nearest_enemy()
	if ne.is_empty():
		return BotAction.new()  # stationary, no target
	var aligned := BotHeuristics.aligned_dir(obs.player_pos_tile, ne["pos_tile"]) != BotHeuristics.NONE
	return BotAction.new(BotAction.NONE, aligned)
