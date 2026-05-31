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
	# fire only on a clear cardinal line — not through brick/steel cover
	var blocked := BotHeuristics.blocked_set(obs.visible_obstacles)
	return BotAction.new(BotAction.NONE, BotHeuristics.clear_shot(obs.player_pos_tile, ne["pos_tile"], blocked))
