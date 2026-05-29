class_name ReloadAwareWaitBot
extends BotPolicy

# Heuristic: never waste a premature shot — fire ONLY when reloaded
# (>= RELOAD_READY) and lined up. While reloading, kite AWAY from the nearest
# enemy; when ready, close in. (AC-001 policy 5/7. Probes consult P2: does the
# bot time shots to the reload bar?)

const RELOAD_READY := 0.8


func _init() -> void:
	bot_id = "reload-aware-wait"


func tick(obs: BotObservation) -> BotAction:
	var ne := obs.nearest_enemy()
	if ne.is_empty():
		return BotAction.new()
	var epos: Vector2i = ne["pos_tile"]
	var ready := obs.reload_bar_value >= RELOAD_READY
	if ready:
		var aligned := BotHeuristics.aligned_dir(obs.player_pos_tile, epos) != BotHeuristics.NONE
		if aligned:
			return BotAction.new(BotAction.NONE, true)  # hold + fire
		return BotAction.new(BotHeuristics.cardinal_toward(obs.player_pos_tile, epos), false)  # close in
	# reloading -> kite away, never fire (no reload-cancel)
	return BotAction.new(BotHeuristics.cardinal_away(obs.player_pos_tile, epos), false)
