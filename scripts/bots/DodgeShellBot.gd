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
	return BotAction.new(dodge, false)
