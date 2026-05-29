extends SceneTree

# U7 batch runner (AC-004) — runs the 7 bots x 12 seeds = 84 matrix headless.
# Each combo: seed the RNG (deterministic enemy-fire stagger per seed), load
# Q1ProofRoom, attach a BotInputDriver (the policy) + TelemetryRecorder as
# PlayerTank siblings, step physics frames until the recorder finalizes
# (death/victory/timeout), validate + write the telemetry JSON, then free the
# scene and reset cleanly (test_chain_35 queue_free+await pattern).
#
# Run as-fast-as-possible with --fixed-fps (decouples from wall clock; ~0.1-0.5s
# per run headless). Game-time is frame-based in the recorder, so timing is
# stable regardless of wall speed.
#
#   godot --headless --path . --fixed-fps 60 \
#     --script res://loop/eprime-experiment/bot_runner.gd \
#     -- [--bots all|a,b] [--seeds all|1,2] [--out res://data/telemetry]
#
# Emits `RUNS_OK <N>/<N> (timeout: T, death: D, victory: V; T+D+V=N)` on full
# success (all runs emit a schema-conforming telemetry JSON); RUNS_FAIL + quit(1)
# on any non-conforming / missing run or unknown bot.

const Q1 := preload("res://scenes/Q1ProofRoom.tscn")
const SEEDS_PATH := "res://data/seed_bank/seeds.json"
const MAX_FRAMES := 2000   # safety cap; the recorder times out at 1800 (30 game-sec)


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var bots := _parse_list(args, "--bots", BotRegistry.ids())
	var seeds := _parse_seeds(args, "--seeds")
	var out_dir := _parse_str(args, "--out", "res://data/telemetry")

	for b in bots:
		if not BotRegistry.has(b):
			print("RUNS_FAIL unknown bot '%s' (no silent skip)" % b)
			quit(1)
			return
	if seeds.is_empty():
		print("RUNS_FAIL no seeds resolved")
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

	var total := bots.size() * seeds.size()
	var ok := 0
	var buckets := {"timeout": 0, "death": 0, "victory": 0}
	var failures: Array = []

	for seed_v in seeds:
		for bot in bots:
			var r := await _run_one(bot, int(seed_v), out_dir)
			if r["ok"]:
				ok += 1
				var c: String = r["cause"]
				if c == "timeout":
					buckets["timeout"] += 1
				elif c == "victory":
					buckets["victory"] += 1
				else:
					buckets["death"] += 1
				printerr("  run %s@%d -> %s (%d frames)" % [bot, int(seed_v), c, r["frames"]])
			else:
				failures.append("%s@%d: %s" % [bot, int(seed_v), str(r["errs"])])
				printerr("  RUN_FAIL %s@%d -> %s" % [bot, int(seed_v), str(r["errs"])])

	if failures.is_empty() and ok == total:
		print("RUNS_OK %d/%d (timeout: %d, death: %d, victory: %d; %d+%d+%d=%d)" % [
			ok, total, buckets["timeout"], buckets["death"], buckets["victory"],
			buckets["timeout"], buckets["death"], buckets["victory"], total])
		quit(0)
	else:
		for fmsg in failures:
			print("  RUN_FAIL " + fmsg)
		print("RUNS_FAIL %d/%d ok (%d failures)" % [ok, total, failures.size()])
		quit(1)


func _run_one(bot: String, seed_v: int, out_dir: String) -> Dictionary:
	seed(seed_v)  # deterministic enemy-fire stagger per seed
	var level := Q1.instantiate()
	get_root().add_child(level)
	for i in 4:
		await process_frame
	var player: Node = level.get_node_or_null("PlayerTank")
	if player == null:
		level.queue_free()
		await process_frame
		return {"ok": false, "cause": "", "errs": ["no PlayerTank spawned"], "frames": 0}

	var driver := BotInputDriver.new()
	driver.bot_policy = BotRegistry.make(bot)
	driver.player = player
	driver.level = level
	level.add_child(driver)

	var rec := TelemetryRecorder.new()
	rec.player = player
	rec.level = level
	rec.driver = driver
	rec.seed_value = seed_v
	rec.bot_id = bot
	rec.out_path = "%s/seed_%d_bot_%s.json" % [out_dir, seed_v, bot]
	level.add_child(rec)

	var frames := 0
	while not rec._ended and frames < MAX_FRAMES:
		await process_frame
		frames += 1

	driver.release_all()  # never leak a held key across runs
	# read the finalized record directly (GDScript lambdas capture locals by
	# value, so a `recorded` signal -> local var would silently no-op)
	var captured: Dictionary = rec._result
	var cause: String = captured.get("death_cause", "") if not captured.is_empty() else ""
	var errs: Array = TelemetrySchema.validate(captured) if not captured.is_empty() else ["no telemetry emitted"]
	var path: String = rec.out_path

	level.queue_free()
	await process_frame
	await process_frame  # let the freed scene + siblings actually release

	# the file must exist + parse + conform (consumer-side oracle)
	if errs.is_empty():
		if not FileAccess.file_exists(path):
			errs = ["telemetry file not written: %s" % path]
		else:
			var f := FileAccess.open(path, FileAccess.READ)
			var disk = JSON.parse_string(f.get_as_text())
			f.close()
			errs = TelemetrySchema.validate(disk)

	return {"ok": errs.is_empty(), "cause": cause, "errs": errs, "frames": frames}


func _parse_list(args: PackedStringArray, flag: String, dflt: Array) -> Array:
	for i in args.size():
		if args[i] == flag and i + 1 < args.size():
			var v := args[i + 1]
			if v == "all":
				return dflt
			return Array(v.split(",", false))
	return dflt


func _parse_str(args: PackedStringArray, flag: String, dflt: String) -> String:
	for i in args.size():
		if args[i] == flag and i + 1 < args.size():
			return args[i + 1]
	return dflt


# Resolve seeds: explicit comma list, or all 12 from the seed bank.
func _parse_seeds(args: PackedStringArray, flag: String) -> Array:
	for i in args.size():
		if args[i] == flag and i + 1 < args.size() and args[i + 1] != "all":
			var out: Array = []
			for s in args[i + 1].split(",", false):
				out.append(int(s))
			return out
	# default: the 12 seed-bank seeds
	if not FileAccess.file_exists(SEEDS_PATH):
		return []
	var f := FileAccess.open(SEEDS_PATH, FileAccess.READ)
	var bank = JSON.parse_string(f.get_as_text())
	f.close()
	var seeds: Array = []
	if typeof(bank) == TYPE_ARRAY:
		for e in bank:
			seeds.append(int(e["seed"]))
	return seeds
