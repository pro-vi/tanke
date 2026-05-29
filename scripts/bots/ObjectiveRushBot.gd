class_name ObjectiveRushBot
extends BotPolicy

# Heuristic: rush straight for the exit (Q1ProofRoom GOAL_ROW is at the top,
# y -> 0, so move UP). Fire only to breach an obstacle blocking the path
# directly above. (AC-001 policy 7/7.)

const BREACH_LOOKAHEAD := 3  # tiles ahead to consider "blocking"


func _init() -> void:
	bot_id = "objective-rush"


func tick(obs: BotObservation) -> BotAction:
	var fire := false
	for o in obs.visible_obstacles:
		var p: Vector2i = o["pos_tile"]
		# same column, directly above, within lookahead -> blocking the rush
		if p.x == obs.player_pos_tile.x and p.y < obs.player_pos_tile.y \
				and (obs.player_pos_tile.y - p.y) <= BREACH_LOOKAHEAD:
			fire = true
			break
	return BotAction.new(Constants.Dir.U, fire)
