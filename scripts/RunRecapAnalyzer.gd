class_name RunRecapAnalyzer
extends RefCounted

# Arc-4 iter 83 (Round 11 Phase 1 continuation): post-hoc analyzer
# for per-archetype run-shape signatures. Pairs with the iter-82
# RunRecap.band_signature() extension. Per CONSULT 009's band-shape
# blind-spot finding — the iter-74 distinctness audit tests single
# moments; this analyzer tests run-shape distinctness across N
# RunRecap signatures from the same scenario.
#
# Distance metric: position-count (Hamming-like on sequences). For
# each pair of band-sequences, counts the number of positions where
# they differ. Aligns left-to-right; the longer sequence's tail
# contributes one mismatch per extra element. Simple, explainable,
# robust to permutations of equal-length sequences.


# Compare an array of band-shape signatures (each a Dictionary as
# returned by RunRecap.band_signature()). Returns:
#   {
#     "pairs": Array of { "a": int, "b": int, "seq_distance": int,
#                         "time_distance_ms": int },
#     "min_seq_distance": int,
#     "max_seq_distance": int,
#     "verdict": String,
#   }
#
# Verdict is "distinct" if min_seq_distance >= 2, "similar" if
# min_seq_distance <= 1 (the runs are too alike — likely either
# the same archetype on the same seed, OR a band-shape convergence
# the CONSULT-009 audit was built to detect).
static func compare_signatures(sigs: Array) -> Dictionary:
	var pairs: Array = []
	var min_d: int = 99999
	var max_d: int = -1
	for i in sigs.size():
		for j in range(i + 1, sigs.size()):
			var seq_a: Array = sigs[i].get("band_sequence", [])
			var seq_b: Array = sigs[j].get("band_sequence", [])
			var d: int = _sequence_distance(seq_a, seq_b)
			var t_a: int = sigs[i].get("total_run_ms", 0)
			var t_b: int = sigs[j].get("total_run_ms", 0)
			var t_d: int = abs(t_a - t_b)
			pairs.append({
				"a": sigs[i].get("archetype", -1),
				"b": sigs[j].get("archetype", -1),
				"seq_distance": d,
				"time_distance_ms": t_d,
			})
			if d < min_d:
				min_d = d
			if d > max_d:
				max_d = d
	if sigs.size() < 2:
		min_d = 0
		max_d = 0
	var verdict: String = "distinct" if min_d >= 2 else "similar"
	return {
		"pairs": pairs,
		"min_seq_distance": min_d,
		"max_seq_distance": max_d,
		"verdict": verdict,
	}


# Hamming-style position-count distance. Aligns left-to-right;
# extra tail elements each count as 1 mismatch.
static func _sequence_distance(a: Array, b: Array) -> int:
	var n: int = max(a.size(), b.size())
	var d: int = 0
	for i in n:
		var ax = a[i] if i < a.size() else null
		var bx = b[i] if i < b.size() else null
		if ax != bx:
			d += 1
	return d
