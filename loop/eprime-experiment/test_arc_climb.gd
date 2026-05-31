extends SceneTree

# U6 verifier (arc-harness-v0.2 AC-A3) — the COMPETENCE ORACLE. Proves the
# composite `competent` bot climbs the real procedural arc (BreachLevel) and
# DECISIVELY out-climbs the single-verb baselines the arc was shown to defeat.
#
# Calibrated to DEMONSTRATED capability (FileAccess-measured this build; the
# determinism re-seed in arc_run_helper makes each seed reproducible). HONEST
# SCOPE: the composite reaches mid-`tutorial_choke` (band 0); it does NOT clear
# band 0 or reach the endgame band. The depth ceiling is enemy SURVIVAL (3 HP vs a
# stall-pressure swarm), not navigation — measured, see ACCEPTANCE-arc.md.
# Navigation rewrites (footprint lanes, brick cost-weighting) were tried and
# measured NOT to lift the ceiling. So this oracle asserts a real mid-band-0
# floor + decisive out-climb of the single-verb bots, not an endgame claim.
#
# The seeds ARE the canonical 12-seed bank, loaded from data/seed_bank/seeds.json
# at runtime (the same source arc_runner.gd uses), so this oracle measures the
# exact bank that check-seed-bank validates and the arc batch runs — not a separate
# hand-picked set. (PR#5 review #1: the prior hardcoded list overlapped the bank
# by zero seeds, so the AC-A3 claim proved nothing about the bank.)
#
# Teeth (disconfirming evidence): the single-verb `objective-rush` run through the
# SAME oracle must FAIL the competent floor — it stalls at depth ~0 (an enemy
# blocks its lane and it never breaches). If it could pass, the oracle is vacuous.
#
# Emits `ARC_CLIMB_OK depth=<median> endgame=<k>/<n> baseline=<median>` on pass.

const Helper := preload("res://loop/eprime-experiment/arc_run_helper.gd")
const SEEDS_PATH := "res://data/seed_bank/seeds.json"

# Floor from the REAL measured distribution on the CANONICAL seed bank (committed
# baseline bot + the arc_run_helper determinism re-seed; FileAccess-measured):
# the arc batch reports competent depth min=0 med=6 max=15 over the bank, all in
# tutorial_choke (band 0); single-verb objective-rush median 0. The floor (4) sits
# below the measured median and above the stuck baseline — it proves DECISIVE
# out-climb of the single-verb bots, the plan's disconfirming-evidence design.
# Raise it (never lower it) when a future controller climbs deeper.
const COMPETENT_MEDIAN_FLOOR := 4    # measured competent median ~6 on the bank; baseline 0
const REQUIRE_ENDGAME := 0           # endgame seeds required (0 until a controller reaches it)


# The canonical 12 seed-bank seeds (data/seed_bank/seeds.json) — loaded at runtime
# so this oracle and arc_runner.gd measure the SAME bank. [] if the file is missing
# (caller fails the run loudly rather than scoring a vacuous pass).
func _seed_bank() -> Array:
	if not FileAccess.file_exists(SEEDS_PATH):
		return []
	var f := FileAccess.open(SEEDS_PATH, FileAccess.READ)
	if f == null:
		return []
	var bank = JSON.parse_string(f.get_as_text())
	f.close()
	var out: Array = []
	if typeof(bank) == TYPE_ARRAY:
		for e in bank:
			out.append(int(e["seed"]))
	return out


func _initialize() -> void:
	var seeds := _seed_bank()
	if seeds.is_empty():
		print("  FAIL — could not load seed bank from %s" % SEEDS_PATH)
		print("ARC_CLIMB_FAIL")
		quit(1)
		return
	# teeth subset: the first 4 bank seeds run through objective-rush (single-verb).
	var teeth_seeds: Array = seeds.slice(0, mini(4, seeds.size()))

	var comp_depths: Array = []
	var endgame_k: int = 0
	for s in seeds:
		var h := Helper.new()
		var r = await h.run_one(self, "competent", s, "user://arc_climb_competent_%d.json" % s)
		if not bool(r["ok"]):
			print("  FAIL — competent run errored seed=%d: %s" % [s, str(r["errs"])])
			print("ARC_CLIMB_FAIL")
			quit(1)
			return
		comp_depths.append(int(r["max_depth"]))
		if bool(r["reached_endgame"]):
			endgame_k += 1
		print("  competent seed=%d depth=%d band=%s endgame=%s" % [
			s, int(r["max_depth"]), r["final_band"], str(r["reached_endgame"])])

	var base_depths: Array = []
	for s in teeth_seeds:
		var h := Helper.new()
		var r = await h.run_one(self, "objective-rush", s, "user://arc_climb_baseline_%d.json" % s)
		base_depths.append(int(r["max_depth"]) if bool(r["ok"]) else 0)
		print("  baseline(objective-rush) seed=%d depth=%d" % [s, int(r.get("max_depth", 0))])

	# Determinism regression guard (PR#5 review #2 + /gate invariance): re-run the
	# FIRST seed a SECOND time IN THIS SAME PROCESS and require an identical
	# max_depth. arc_run_helper re-seeds the RNG after setup precisely so a run is
	# batch-order-independent; without that fix this seed gave 15/10/10 across
	# repeats. The main loop above runs each seed once, so only this back-to-back
	# repeat can catch a regression that drops the re-seed.
	var det_seed: int = int(seeds[0])
	var det_expect: int = int(comp_depths[0])
	var dh := Helper.new()
	var dr = await dh.run_one(self, "competent", det_seed, "user://arc_climb_det_%d.json" % det_seed)
	var det_again := int(dr["max_depth"]) if bool(dr["ok"]) else -1
	print("  determinism seed=%d depth=%d (first pass %d)" % [det_seed, det_again, det_expect])

	var comp_med := _median(comp_depths)
	var base_med := _median(base_depths)
	print("  competent median=%d  baseline median=%d  endgame=%d/%d" % [
		comp_med, base_med, endgame_k, seeds.size()])

	var failures: int = 0
	failures += _expect("competent median >= floor (%d)" % COMPETENT_MEDIAN_FLOOR,
		comp_med >= COMPETENT_MEDIAN_FLOOR)
	failures += _expect("competent decisively out-climbs baseline (>= 2x + gap)",
		comp_med >= 2 * maxi(base_med, 1) and comp_med - base_med >= COMPETENT_MEDIAN_FLOOR)
	# Teeth: the single-verb baseline through THIS SAME oracle must FAIL the floor.
	failures += _expect("baseline FAILS the competent floor [teeth]",
		base_med < COMPETENT_MEDIAN_FLOOR)
	failures += _expect("same seed twice in one process -> identical depth (determinism)",
		det_again == det_expect)
	if REQUIRE_ENDGAME > 0:
		failures += _expect("endgame reached on >= %d seeds" % REQUIRE_ENDGAME,
			endgame_k >= REQUIRE_ENDGAME)

	if failures == 0:
		print("ARC_CLIMB_OK depth=%d endgame=%d/%d baseline=%d" % [
			comp_med, endgame_k, seeds.size(), base_med])
		quit(0)
	else:
		print("ARC_CLIMB_FAIL %d failures" % failures)
		quit(1)


func _median(a: Array) -> int:
	if a.is_empty():
		return 0
	var s := a.duplicate()
	s.sort()
	var n := s.size()
	if n % 2 == 1:
		return int(s[n / 2])
	return int((int(s[n / 2 - 1]) + int(s[n / 2])) / 2.0)


func _expect(desc: String, cond: bool) -> int:
	if cond:
		print("  case %s OK" % desc)
		return 0
	print("  FAIL — %s" % desc)
	return 1
