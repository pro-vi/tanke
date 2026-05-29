class_name DodgeShellBot
extends BotPolicy

# Heuristic: when an enemy projectile is heading at the player, step orthogonal
# to its path (dodge). Otherwise hold. Never fires. (AC-001 policy 2/7.)

func _init() -> void:
	bot_id = "dodge-shell"


func tick(obs: BotObservation) -> BotAction:
	var inc := obs.incoming_projectile()
	if inc.is_empty():
		return BotAction.new()  # no incoming threat -> hold
	var heading: Vector2 = inc.get("dir", Vector2.ZERO)
	var dodge := BotHeuristics.perpendicular_cardinal(heading)
	# don't dodge straight into cover — flip to the other side if blocked
	if dodge != BotHeuristics.NONE:
		var blocked := BotHeuristics.blocked_set(obs.visible_obstacles)
		if blocked.has(BotHeuristics.next_tile(obs.player_pos_tile, dodge)):
			dodge = BotHeuristics.opposite(dodge)
	return BotAction.new(dodge, false)
