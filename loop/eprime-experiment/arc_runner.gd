extends SceneTree

# U5 (arc-harness-v0.2) — the arc batch runner: drives the arc bot roster x the
# 12-seed bank on the REAL procedural arc (BreachLevel) via ArcRunHelper,
# validates each emitted v0.2-arc telemetry JSON, and emits `ARC_RUNS_OK <N>/<N>`.
# Mirrors the frozen Q1 batch (bot_runner.gd) but for the arc; the heavy
# single-run lifecycle (archetype-skip, depot auto-drive, frame loop, write +
# re-read + schema-validate) lives in ArcRunHelper — one source of truth, shared
# with the climb oracle (U6). Fails loud (ARC_RUNS_FAIL + quit(1)) on an empty or
# unknown bot list or ANY non-conforming/missing run — no silent skip.
#
#   godot --headless --path . --fixed-fps 60 \
#     --script res://loop/eprime-experiment/arc_runner.gd \
#     -- [--bots all|competent,objective-rush] [--seeds all|1234,42] [--out res://data/telemetry/arc]
#
# Default roster = competent + the 7 frozen single-verb probes (for contrast);
# default seeds = the 12-seed bank. Single-verb probes die early on the arc
# (signal); only `competent` climbs — its depth distribution is summarised.

const SEEDS_PATH := "res://data/seed_bank/seeds.json"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var bots := _parse_list(args, "--bots", ArcRunHelper.arc_bot_ids())
	var seeds := _parse_seeds(args, "--seeds")
	var out_dir := _parse_str(args, "--out", "res://data/telemetry/arc")

	# fail loud on a vacuous or typo'd roster (no silent skip — AC parity with Q1).
	if bots.is_empty():
		print("ARC_RUNS_FAIL no bots resolved (empty --bots list)")
		quit(1); return
	for b in bots:
		if not ArcRunHelper.has_bot(b):
			print("ARC_RUNS_FAIL unknown bot '%s' (no silent skip)" % b)
			quit(1); return
	if seeds.is_empty():
		print("ARC_RUNS_FAIL no seeds resolved")
		quit(1); return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

	var total := bots.size() * seeds.size()
	var ok := 0
	var buckets := {"timeout": 0, "death": 0, "victory": 0}
	var failures: Array = []
	var competent_depths: Array = []
	var helper := ArcRunHelper.new()

	for seed_v in seeds:
		for bot in bots:
			var out_path := "%s/seed_%d_bot_%s.json" % [out_dir, int(seed_v), bot]
			var r = await helper.run_one(self, bot, int(seed_v), out_path)
			if r["ok"]:
				ok += 1
				var c: String = r["cause"]
				if c == "timeout" or c == "victory":
					buckets[c] += 1
				else:
					buckets["death"] += 1   # melee / projectile / suicide
				if bot == "competent":
					competent_depths.append(int(r["max_depth"]))
				printerr("  run %s@%d -> %s depth=%d band=%s (%d frames)" % [
					bot, int(seed_v), c, int(r["max_depth"]), r["final_band"], int(r["frames"])])
			else:
				failures.append("%s@%d: %s" % [bot, int(seed_v), str(r["errs"])])
				printerr("  RUN_FAIL %s@%d -> %s" % [bot, int(seed_v), str(r["errs"])])

	if failures.is_empty() and ok == total:
		print("ARC_RUNS_OK %d/%d (victory: %d, death: %d, timeout: %d; competent %s)" % [
			ok, total, buckets["victory"], buckets["death"], buckets["timeout"],
			_depth_summary(competent_depths)])
		quit(0)
	else:
		for fmsg in failures:
			print("  RUN_FAIL " + fmsg)
		print("ARC_RUNS_FAIL %d/%d ok (%d failures)" % [ok, total, failures.size()])
		quit(1)


# Compact competent-depth distribution (the arc's headline playtest signal).
func _depth_summary(depths: Array) -> String:
	if depths.is_empty():
		return "depth: n/a"
	depths.sort()
	return "depth min=%d med=%d max=%d" % [depths[0], depths[depths.size() / 2], depths[-1]]


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
	if not FileAccess.file_exists(SEEDS_PATH):
		return []
	var f := FileAccess.open(SEEDS_PATH, FileAccess.READ)
	if f == null:
		return []
	var bank = JSON.parse_string(f.get_as_text())
	f.close()
	var seeds: Array = []
	if typeof(bank) == TYPE_ARRAY:
		for e in bank:
			seeds.append(int(e["seed"]))
	return seeds
