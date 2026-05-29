class_name MoveToCoverBot
extends BotPolicy

# Heuristic: move toward the nearest visible obstacle (brick/steel) to hug
# cover. Never fires. Pure function of observation. (AC-001 policy 1/7.)

func _init() -> void:
	bot_id = "move-to-cover"


func tick(obs: BotObservation) -> BotAction:
	if obs.visible_obstacles.is_empty():
		return BotAction.new()  # nothing to hug -> hold position
	var nearest: Vector2i = obs.player_pos_tile
	var best_d: int = 1 << 30
	for o in obs.visible_obstacles:
		var p: Vector2i = o["pos_tile"]
		var d: int = BotHeuristics.manhattan(obs.player_pos_tile, p)
		if d < best_d:
			best_d = d
			nearest = p
	return BotAction.new(BotHeuristics.cardinal_toward(obs.player_pos_tile, nearest), false)
