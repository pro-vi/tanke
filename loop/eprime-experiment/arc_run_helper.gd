class_name ArcRunHelper
extends RefCounted

# One headless run of one bot x one seed on the REAL procedural arc
# (BreachLevel) — the shared single-run engine for BOTH the arc batch runner
# (arc_runner.gd) and the competence oracle (test_arc_climb.gd), so the run
# lifecycle has exactly one source of truth.
#
# Headless hang-proofing (the arc has two pause/modal gates the fixed Q1 room
# lacks, and scenes/BreachLevel.tscn is a FORBIDDEN edit so both are driven in
# code, never by editing the scene):
#   * archetype-select modal — disabled by setting force_archetype_select=false
#     on the PlayerTank BEFORE add_child (before _ready runs the modal check).
#   * depot safe-gates — Depot.gd pauses the tree on entry; this loop detects the
#     pause each frame and calls the active depot's public apply_choice(1), which
#     applies an upgrade AND unpauses (Depot.gd:355). process_frame keeps firing
#     while paused, so the loop can drive the gate.
# ARC_MAX_FRAMES is the safety backstop above the recorder's game-time timeout.

const BREACH := preload("res://scenes/BreachLevel.tscn")
const COMPETENT := preload("res://scripts/bots/CompetentBot.gd")
const ARC_MAX_FRAMES := 14600   # > ArcTelemetryRecorder.ARC_TIMEOUT_SEC*60 (14400)


# "competent" resolves to the composite bot directly (it is deliberately NOT in
# BotRegistry — see CompetentBot.gd); every other id delegates to the frozen
# registry. Returns null for an unknown id (callers MUST fail loud — no silent skip).
static func make_bot(bot_id: String) -> BotPolicy:
	if bot_id == "competent":
		return COMPETENT.new()
	return BotRegistry.make(bot_id)


static func has_bot(bot_id: String) -> bool:
	return bot_id == "competent" or BotRegistry.has(bot_id)


static func arc_bot_ids() -> Array:
	# the composite first, then the 7 frozen single-verb probes (for contrast).
	return ["competent"] + BotRegistry.ids()


# Run one bot x seed on BreachLevel; return a result dict:
#   {ok, cause, max_depth, final_band, reached_endgame, frames, errs}
func run_one(tree: SceneTree, bot_id: String, seed_v: int, out_path: String) -> Dictionary:
	# Fail loud on an unknown id — never score a typo'd / stale bot as a vacuous
	# passing timeout run (module contract: "no silent skip"). The frozen Q1 runner
	# guards this; the arc runner must too.
	if not has_bot(bot_id):
		return _fail("unknown bot id '%s' (no silent skip)" % bot_id)
	# determinism: TANKE_SEED feeds ProceduralLevel's level_seed (band shuffle +
	# terrain); seed() feeds the enemy-fire stagger. Both before instantiate.
	OS.set_environment("TANKE_SEED", str(seed_v))
	seed(seed_v)

	var level: Node = BREACH.instantiate()
	# kill the archetype-select modal before _ready (can't edit the scene file).
	var pre_player: Node = level.get_node_or_null("PlayerTank")
	if pre_player != null:
		pre_player.set("force_archetype_select", false)
	tree.get_root().add_child(level)
	for _i in 4:
		await tree.process_frame

	var player: Node = level.get_node_or_null("PlayerTank")
	if player == null:
		await _teardown(tree, level)
		return _fail("no PlayerTank spawned")

	var policy := make_bot(bot_id)
	if policy == null:   # has_bot passed but the script failed to load -> fail loud
		await _teardown(tree, level)
		return _fail("bot policy null for id '%s'" % bot_id)
	var driver := BotInputDriver.new()
	driver.bot_policy = policy
	driver.player = player
	driver.level = level
	level.add_child(driver)

	var rec := ArcTelemetryRecorder.new()
	rec.player = player
	rec.level = level
	rec.driver = driver
	rec.seed_value = seed_v
	rec.bot_id = bot_id
	rec.out_path = out_path
	level.add_child(rec)

	# Determinism: re-seed the global RNG AFTER setup settles. The 4 setup frames
	# (and any not-yet-freed stragglers from a prior run in the same process) tick
	# the Spawner and consume randf(), which otherwise offsets this run's enemy-fire
	# stagger by an amount that depends on run order. Re-seeding here pins the
	# run-proper enemy RNG to seed_v regardless of what ran during setup, so a seed
	# yields the same trajectory whether run first or tenth in a batch.
	seed(seed_v)

	var frames := 0
	while not rec._ended and frames < ARC_MAX_FRAMES:
		await tree.process_frame
		frames += 1
		if tree.paused:
			_drive_depot(level)

	# backstop: if the frame cap hit before the recorder finalized, force timeout
	# so every run yields a record (never a vacuous "no telemetry").
	if not rec._ended:
		rec.finalize("timeout")

	driver.release_all()
	tree.paused = false   # never leak a depot pause into the next run

	var captured: Dictionary = rec._result
	var result := {
		"ok": false,
		"cause": String(captured.get("death_cause", "")),
		"max_depth": int(captured.get("max_depth", 0)),
		"final_band": String(captured.get("final_band", "")),
		"reached_endgame": bool(captured.get("reached_endgame", false)),
		"frames": frames,
		"errs": [],
	}
	var errs: Array = ArcTelemetrySchema.validate(captured) if not captured.is_empty() else ["no telemetry emitted"]
	var path := out_path

	await _teardown(tree, level)

	# consumer-side oracle: the file must exist + parse + conform on disk.
	if errs.is_empty() and path != "":
		if not FileAccess.file_exists(path):
			errs = ["telemetry file not written: %s" % path]
		else:
			var f := FileAccess.open(path, FileAccess.READ)
			if f == null:   # exists() can pass yet open() fail (lock/perm) — don't crash the batch
				errs = ["telemetry file unreadable: %s (err %d)" % [path, FileAccess.get_open_error()]]
			else:
				var disk = JSON.parse_string(f.get_as_text())
				f.close()
				errs = ArcTelemetrySchema.validate(disk)

	result["errs"] = errs
	result["ok"] = errs.is_empty()
	return result


# Drive the active depot past its safe-gate (apply choice 1 = first offer). The
# active depot is the one that captured the player's loadout and hasn't been
# picked yet; apply_choice both applies the upgrade and unpauses the tree.
static func _drive_depot(level: Node) -> void:
	if not is_instance_valid(level):
		return
	for c in level.get_children():
		if is_instance_valid(c) and c.has_method("apply_choice") \
				and c.get("_player_loadout") != null and not bool(c.get("_picked")):
			c.apply_choice(1)
			return


func _teardown(tree: SceneTree, level: Node) -> void:
	tree.paused = false
	if is_instance_valid(level):
		level.queue_free()
	await tree.process_frame
	await tree.process_frame


func _fail(msg: String) -> Dictionary:
	return {"ok": false, "cause": "", "max_depth": 0, "final_band": "",
		"reached_endgame": false, "frames": 0, "errs": [msg]}
