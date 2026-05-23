# Arc-4 breach mode: Round-11 Phase-1 band-shape analyzer verifier
# (iter 83). Pairs with the iter-82 RunRecap band-shape recorder.
# Verifies that RunRecapAnalyzer.compare_signatures correctly
# computes pairwise sequence distance + time distance + verdict
# across N per-archetype signatures.
#
# Verifies:
#   - Identical sequences → distance 0 → verdict "similar"
#   - Different-order sequences of same length → distance > 0
#   - Different-length sequences → tail counts as mismatches
#   - 4-archetype mock set → divergence relationships match design
#     intuition (DEFAULT≈DEFAULT-clone vs DEFAULT≠RAM)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_band_shape_analyzer.gd

extends SceneTree

const AnalyzerT = preload("res://scripts/RunRecapAnalyzer.gd")


func _sig(archetype: int, seq: Array, total_ms: int) -> Dictionary:
	return {
		"archetype": archetype,
		"visit_count": seq.size(),
		"total_run_ms": total_ms,
		"band_sequence": seq,
		"shells_fired_total": 0,
		"depth_reached": 0,
	}


func _initialize() -> void:
	# === Identical sequences → distance 0 → verdict "similar".
	var a: Dictionary = _sig(0, ["warmup", "first_push", "bunker"], 30000)
	var b: Dictionary = _sig(0, ["warmup", "first_push", "bunker"], 30000)
	var r1: Dictionary = AnalyzerT.compare_signatures([a, b])
	if r1["min_seq_distance"] != 0:
		push_error("FAIL — identical seqs: min_seq_distance %d, want 0" % r1["min_seq_distance"])
		quit(1); return
	if r1["verdict"] != "similar":
		push_error("FAIL — identical seqs: verdict '%s', want 'similar'" % r1["verdict"])
		quit(1); return
	print("  identical sequences: distance=0, verdict='similar'")

	# === Different order, same length → distance > 0.
	var c: Dictionary = _sig(1, ["warmup", "bunker", "first_push"], 30000)
	var r2: Dictionary = AnalyzerT.compare_signatures([a, c])
	if r2["min_seq_distance"] != 2:
		push_error("FAIL — reorder pair: distance %d, want 2" % r2["min_seq_distance"])
		quit(1); return
	print("  reorder same length: distance=%d" % r2["min_seq_distance"])

	# === Different length → tail counts as mismatches.
	var d: Dictionary = _sig(2, ["warmup", "first_push"], 20000)
	var r3: Dictionary = AnalyzerT.compare_signatures([a, d])
	if r3["min_seq_distance"] != 1:  # only the "bunker" tail differs
		push_error("FAIL — different length: distance %d, want 1 (tail mismatch)" % r3["min_seq_distance"])
		quit(1); return
	print("  different length (3 vs 2 bands): distance=%d (tail mismatch)" % r3["min_seq_distance"])

	# === 4-archetype mock set: design-intuition check. DEFAULT and
	# its mock-clone PRISM share the sequence (timing differs);
	# MORTAR has a shorter sequence; RAM has a re-ordered sequence.
	# Pairwise distances should reflect the design distinctness
	# story per CONSULT 009.
	var s_default: Dictionary = _sig(0, ["warmup", "first_push", "bunker", "steel"], 60000)
	var s_prism: Dictionary = _sig(1, ["warmup", "first_push", "bunker", "steel"], 75000)  # same seq, slower
	var s_mortar: Dictionary = _sig(2, ["warmup", "first_push", "bunker"], 45000)  # shorter (died at bunker)
	var s_ram: Dictionary = _sig(3, ["warmup", "bunker", "first_push", "steel"], 40000)  # reordered
	var r4: Dictionary = AnalyzerT.compare_signatures([s_default, s_prism, s_mortar, s_ram])

	if r4["pairs"].size() != 6:
		push_error("FAIL — 4-archetype set: pair count %d, want 6" % r4["pairs"].size())
		quit(1); return
	# Pair distance lookup (archetype-id pair → seq_distance).
	var dist_lookup: Dictionary = {}
	for p in r4["pairs"]:
		var key: String = "%d_%d" % [p["a"], p["b"]]
		dist_lookup[key] = p["seq_distance"]
	# DEFAULT(0) ↔ PRISM(1): same sequence → seq_distance = 0
	if dist_lookup["0_1"] != 0:
		push_error("FAIL — DEFAULT↔PRISM seq_distance %d, want 0 (same seq, only timing differs)" % dist_lookup["0_1"])
		quit(1); return
	# DEFAULT(0) ↔ MORTAR(2): tail mismatch → 1
	if dist_lookup["0_2"] != 1:
		push_error("FAIL — DEFAULT↔MORTAR seq_distance %d, want 1 (tail mismatch)" % dist_lookup["0_2"])
		quit(1); return
	# DEFAULT(0) ↔ RAM(3): reorder → 2 mismatches
	if dist_lookup["0_3"] != 2:
		push_error("FAIL — DEFAULT↔RAM seq_distance %d, want 2 (reorder)" % dist_lookup["0_3"])
		quit(1); return
	# Time distance DEFAULT↔PRISM: |60000-75000| = 15000
	var t_default_prism: int = 0
	for p in r4["pairs"]:
		if p["a"] == 0 and p["b"] == 1:
			t_default_prism = p["time_distance_ms"]
			break
	if t_default_prism != 15000:
		push_error("FAIL — DEFAULT↔PRISM time_distance_ms %d, want 15000" % t_default_prism)
		quit(1); return
	print("  4-archetype mock: DEFAULT↔PRISM=0 (same seq), DEFAULT↔MORTAR=1 (tail), DEFAULT↔RAM=2 (reorder); PRISM timing 15000ms slower")
	print("  verdict: '%s' (min %d, max %d)" % [r4["verdict"], r4["min_seq_distance"], r4["max_seq_distance"]])

	# === Verdict logic: min=0 → "similar"; if all pairs ≥2 → "distinct".
	# The 4-archetype mock has DEFAULT↔PRISM=0 → verdict should be "similar"
	# (because some pair converges — the CONSULT 009 warning).
	if r4["verdict"] != "similar":
		push_error("FAIL — verdict '%s', want 'similar' (DEFAULT↔PRISM converges)" % r4["verdict"])
		quit(1); return

	# === All-distinct sequences → verdict "distinct".
	var s1: Dictionary = _sig(0, ["a", "b"], 10000)
	var s2: Dictionary = _sig(1, ["b", "a"], 10000)
	var s3: Dictionary = _sig(2, ["c", "d"], 10000)
	var r5: Dictionary = AnalyzerT.compare_signatures([s1, s2, s3])
	if r5["verdict"] != "distinct":
		push_error("FAIL — all-divergent set: verdict '%s', want 'distinct'" % r5["verdict"])
		quit(1); return
	print("  all-divergent set: verdict='distinct' (min %d)" % r5["min_seq_distance"])

	print("BREACH_BAND_SHAPE_ANALYZER_OK pairwise sequence + time distances + verdict logic correct across 4 test cases + 4-archetype mock")
	quit(0)
