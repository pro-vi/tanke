# Arc-4 breach mode: BreachLevel.tscn integration verifier.
# Verifies the first end-to-end breach scene wires together every
# round-1/2 piece: breach_mode flag, BreachConfig, player Loadout, a
# Depot placement. Runs 30 frames to catch _ready/_process errors.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_level.gd

extends SceneTree

const BreachLevelScene = preload("res://scenes/BreachLevel.tscn")


func _initialize() -> void:
	var level: Node = BreachLevelScene.instantiate()
	# Deterministic seed so the run is reproducible.
	level.level_seed = 42
	root.add_child(level)

	# Let _ready fire + a few process ticks.
	for i in 30:
		await process_frame

	# 1. breach_mode_enabled flag is on.
	if not level.breach_mode_enabled:
		push_error("FAIL — breach_mode_enabled is false on BreachLevel")
		quit(1); return

	# 2. breach_config is wired.
	if level.breach_config == null:
		push_error("FAIL — breach_config is null on BreachLevel")
		quit(1); return
	var band_count: int = level.breach_config.band_count()
	if band_count < 2:
		push_error("FAIL — breach_config has %d bands, want >= 2" % band_count)
		quit(1); return

	# 3. PlayerTank exists + has a non-null loadout.
	var player: Node = level.get_node_or_null("PlayerTank")
	if player == null:
		push_error("FAIL — no PlayerTank node in BreachLevel")
		quit(1); return
	if player.loadout == null:
		push_error("FAIL — PlayerTank.loadout is null (starter loadout not wired)")
		quit(1); return
	if player.loadout.he_reserve <= 0:
		push_error("FAIL — starter loadout has no HE reserve (got %d)" % player.loadout.he_reserve)
		quit(1); return

	# 4. >=4 Depot children at deterministic band-transition depths —
	# arc-4 iter 57 (Round 8b): one pick per completable phase (was >=3;
	# Depot4 added at the open_killbox→endgame boundary). Duck-typed by
	# the depot's apply_choice + _is_player methods.
	var depot_count: int = 0
	var depot_ys: Array = []
	for child in level.get_children():
		if child.has_method("apply_choice") and child.has_method("_is_player"):
			depot_count += 1
			if child is Node2D:
				depot_ys.append(int((child as Node2D).position.y))
	if depot_count < 4:
		push_error("FAIL — BreachLevel has %d depots, want >=4 (8b: one per phase)" % depot_count)
		quit(1); return

	depot_ys.sort()
	print("BREACH_LEVEL_OK  bands=%d  he_reserve=%d  depots=%d  depot_y=%s" % [
		band_count, player.loadout.he_reserve, depot_count, str(depot_ys)
	])
	quit(0)
