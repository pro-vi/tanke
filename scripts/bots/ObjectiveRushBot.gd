class_name ObjectiveRushBot
extends BotPolicy

# Heuristic: rush straight for the exit (Q1ProofRoom GOAL_ROW is at the top,
# y -> 0, so move UP). Fire only to breach an obstacle blocking the path
# directly above. (AC-001 policy 7/7.)

const BREACH_LOOKAHEAD := 3  # tiles ahead to consider "blocking"


func _init() -> void:
	bot_id = "objective-rush"


func tick(obs: BotObservation) -> BotAction:
	# route toward the exit row at the top, steering around brick/steel instead
	# of jamming straight up into it
	var blocked := BotHeuristics.blocked_set(obs.visible_obstacles)
	var target := Vector2i(obs.player_pos_tile.x, 0)
	var move := BotHeuristics.step_toward(obs.player_pos_tile, target, blocked)
	# ...but also breach a brick directly in the upward path (open the lane)
	var fire := false
	for o in obs.visible_obstacles:
		var p: Vector2i = o["pos_tile"]
		if p.x == obs.player_pos_tile.x and p.y < obs.player_pos_tile.y \
				and (obs.player_pos_tile.y - p.y) <= BREACH_LOOKAHEAD:
			fire = true
			break
	return BotAction.new(move, fire)
