extends SceneTree

# iter 022: 25-stage advance chain test for C10 anchor 4.
# Verifies: stages 1-25 instantiate without crashes; eagle present + valid;
# Spawner present + stage_number correct.

const OG_SCENE = preload("res://scenes/OriginalLevel.tscn")
const StageDirectorT = preload("res://scripts/StageDirector.gd")
const RosterT = preload("res://scripts/Roster.gd")

var _failures: int = 0


func _initialize() -> void:
	var director = StageDirectorT.new(1)
	# Verify stages 1 through 25 (anchor 4 "Stages 1-25 reachable")
	for target_stage in range(1, 26):
		var ok: bool = await _verify_stage(target_stage)
		if not ok:
			_failures += 1
		# Advance director (also a soft check it doesn't error)
		if target_stage < 25:
			director.advance_stage()
	if _failures == 0:
		print("CHAIN_25_OK 25 stages instantiated cleanly")
		quit(0)
	else:
		print("CHAIN_25_FAILURES: %d" % _failures)
		quit(1)


func _verify_stage(stage_n: int) -> bool:
	var level: Node = OG_SCENE.instantiate()
	level.stage_number = stage_n
	root.add_child(level)
	# Let _ready run + Eagle + Spawner instantiate
	for i in 3:
		await process_frame
	var failures: Array = []
	# Eagle check (C10 anchor 4: "eagle gameplay survives")
	if level.get("eagle") == null:
		failures.append("eagle null")
	elif not is_instance_valid(level.eagle):
		failures.append("eagle invalid")
	# Spawner check
	var spawner = level.get_node_or_null("Spawner")
	if spawner == null:
		failures.append("Spawner missing")
	elif int(spawner.get("stage_number")) != stage_n:
		failures.append("Spawner.stage_number=%d (expected %d)" % [int(spawner.get("stage_number")), stage_n])
	# Roster probability check (mechanism sanity)
	var p: float = RosterT.armored_probability(stage_n)
	if p < 0.0 or p > 1.0:
		failures.append("Roster p_armored=%.4f out of [0, 1]" % p)
	if failures.is_empty():
		print("  ok stage %2d  eagle=valid  spawner=%d  p_armored=%.4f" % [stage_n, int(spawner.get("stage_number")), p])
		level.queue_free()
		await process_frame
		return true
	else:
		print("  FAIL stage %d: %s" % [stage_n, ", ".join(failures)])
		level.queue_free()
		await process_frame
		return false
