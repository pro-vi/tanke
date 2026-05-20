# Arc-4 breach mode: per-run band-order shuffle verifier (Round 6a,
# iter 39 — the user's #1 not-roguelite complaint: "every run is the
# same 5 bands in the same order").
# Verifies ProceduralLevel._shuffled_breach_config:
#   1. always 5 bands; tutorial_choke first, endgame_mixed last (pinned)
#   2. the 3 middle bands are a permutation of the canonical set
#   3. the 3 middle depth slots are FIXED (30-70 / 70-120 / 120-180) —
#      so depots stay aligned + the reachability oracle is unaffected
#   4. >=2 distinct middle-band orders across a 7-seed sweep
#   5. the source breach_default.tres Resource is never mutated
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_shuffle.gd

extends SceneTree

const ProceduralLevelT = preload("res://scripts/ProceduralLevel.gd")
const SrcConfig = preload("res://configs/breach_default.tres")


func _initialize() -> void:
	# Snapshot the source config to verify it is never mutated.
	var src_order: Array = []
	for b in SrcConfig.bands:
		src_order.append([b.band_name, b.depth_min, b.depth_max])

	var expect: Array = [[0, 30], [30, 70], [70, 120], [120, 180], [180, 260]]
	var middle_orders: Dictionary = {}

	for s in [1, 7, 42, 99, 333, 777, 2024]:
		var pl: Node = ProceduralLevelT.new()
		pl.level_seed = s
		var cfg = pl._shuffled_breach_config(SrcConfig)
		pl.free()

		if cfg.bands.size() != 5:
			push_error("FAIL — seed %d: %d bands, want 5" % [s, cfg.bands.size()])
			quit(1); return
		if cfg.bands[0].band_name != "tutorial_choke":
			push_error("FAIL — seed %d: band 0 = '%s', want tutorial_choke" % [s, cfg.bands[0].band_name])
			quit(1); return
		if cfg.bands[4].band_name != "endgame_mixed":
			push_error("FAIL — seed %d: band 4 = '%s', want endgame_mixed" % [s, cfg.bands[4].band_name])
			quit(1); return

		# The 3 middle bands are a permutation of the canonical set.
		var mid: Array = []
		for i in [1, 2, 3]:
			mid.append(cfg.bands[i].band_name)
		var mid_sorted: Array = mid.duplicate()
		mid_sorted.sort()
		if mid_sorted != ["brick_maze", "bunker_zone", "open_killbox"]:
			push_error("FAIL — seed %d: middle bands not the canonical 3: %s" % [s, mid_sorted])
			quit(1); return

		# Depth slots are fixed regardless of shuffle.
		for i in cfg.bands.size():
			if cfg.bands[i].depth_min != expect[i][0] or cfg.bands[i].depth_max != expect[i][1]:
				push_error("FAIL — seed %d: band %d depth [%d,%d], want [%d,%d]" % [
					s, i, cfg.bands[i].depth_min, cfg.bands[i].depth_max,
					expect[i][0], expect[i][1]])
				quit(1); return

		middle_orders[",".join(mid)] = true

	if middle_orders.size() < 2:
		push_error("FAIL — shuffle produced only 1 distinct order across 7 seeds")
		quit(1); return
	print("  %d distinct middle-band orders across 7 seeds" % middle_orders.size())

	# The source breach_default.tres must be untouched.
	for i in SrcConfig.bands.size():
		var b = SrcConfig.bands[i]
		if [b.band_name, b.depth_min, b.depth_max] != src_order[i]:
			push_error("FAIL — source breach_default.tres mutated at band %d" % i)
			quit(1); return
	print("  source breach_default.tres unmutated")

	print("BREACH_SHUFFLE_OK band-order shuffle: 5 bands, tutorial+endgame pinned, fixed slots")
	quit(0)
