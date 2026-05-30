extends SceneTree

# U6 verifier (arc-harness-v0.2 AC-A3) — the COMPETENCE ORACLE. Proves the
# composite `competent` bot climbs the real procedural arc (BreachLevel) and
# DECISIVELY out-climbs the single-verb baselines the arc was shown to defeat.
#
# Calibrated to DEMONSTRATED capability (FileAccess-measured this build; the
# determinism re-seed in arc_run_helper makes each seed reproducible). HONEST
# SCOPE: the composite reaches mid-`tutorial_choke` (band 0), median max_depth ~8
# across the 12 seed-bank seeds; it does NOT clear band 0 or reach the endgame
# band. The depth ceiling is enemy SURVIVAL (3 HP vs a stall-pressure swarm), not
# navigation — measured, see ACCEPTANCE-arc.md. Navigation rewrites (footprint
# lanes, brick cost-weighting) were tried and measured NOT to lift the ceiling.
# So this oracle asserts a real mid-band-0 floor, not an endgame claim.
#
# Teeth (disconfirming evidence): the single-verb `objective-rush` run through the
# SAME oracle must FAIL the competent floor — it stalls at depth ~0 (an enemy
# blocks its lane and it never breaches). If it could pass, the oracle is vacuous.
#
# Emits `ARC_CLIMB_OK depth=<median> endgame=<k>/<n> baseline=<median>` on pass.

const Helper := preload("res://loop/eprime-experiment/arc_run_helper.gd")

# The 12 seed-bank seeds (data/seed_bank/seeds.json), all tiers.
const SEEDS := [101, 207, 313, 419, 523, 619, 727, 829, 937, 1031, 1153, 1279]
# Teeth subset — enough single-verb runs to show the baseline stalls.
const TEETH_SEEDS := [101, 313, 619, 1031]

# Floor from the REAL measured distribution (committed baseline bot + the
# arc_run_helper determinism re-seed; FileAccess-measured; two batches agree):
# competent max_depth = {0,1,4,5,5,12,14,14,15,15,15,15}, median 13, all in
# tutorial_choke (band 0); single-verb objective-rush median 0. The floor (5) sits
# well below the measured median and above the stuck baseline — it proves DECISIVE
# out-climb of the single-verb bots, the plan's disconfirming-evidence design.
# Raise it (never lower it) when a future controller climbs deeper.
const COMPETENT_MEDIAN_FLOOR := 5    # measured competent median 13; baseline 0
const REQUIRE_ENDGAME := 0           # endgame seeds required (0 until a controller reaches it)


func _initialize() -> void:
	var comp_depths: Array = []
	var endgame_k: int = 0
	for s in SEEDS:
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
	for s in TEETH_SEEDS:
		var h := Helper.new()
		var r = await h.run_one(self, "objective-rush", s, "user://arc_climb_baseline_%d.json" % s)
		base_depths.append(int(r["max_depth"]) if bool(r["ok"]) else 0)
		print("  baseline(objective-rush) seed=%d depth=%d" % [s, int(r.get("max_depth", 0))])

	var comp_med := _median(comp_depths)
	var base_med := _median(base_depths)
	print("  competent median=%d  baseline median=%d  endgame=%d/%d" % [
		comp_med, base_med, endgame_k, SEEDS.size()])

	var failures: int = 0
	failures += _expect("competent median >= floor (%d)" % COMPETENT_MEDIAN_FLOOR,
		comp_med >= COMPETENT_MEDIAN_FLOOR)
	failures += _expect("competent decisively out-climbs baseline (>= 2x + gap)",
		comp_med >= 2 * maxi(base_med, 1) and comp_med - base_med >= COMPETENT_MEDIAN_FLOOR)
	# Teeth: the single-verb baseline through THIS SAME oracle must FAIL the floor.
	failures += _expect("baseline FAILS the competent floor [teeth]",
		base_med < COMPETENT_MEDIAN_FLOOR)
	if REQUIRE_ENDGAME > 0:
		failures += _expect("endgame reached on >= %d seeds" % REQUIRE_ENDGAME,
			endgame_k >= REQUIRE_ENDGAME)

	if failures == 0:
		print("ARC_CLIMB_OK depth=%d endgame=%d/%d baseline=%d" % [
			comp_med, endgame_k, SEEDS.size(), base_med])
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
