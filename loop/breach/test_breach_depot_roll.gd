# Arc-4 breach mode: depot-offer randomization verifier (Round 6b,
# iter 40). A depot with randomize_offers=true draws 3 distinct upgrade
# kinds from the 7-entry catalog, deterministic from the run seed + the
# depot's depth — so depots differ from each other and runs differ from
# each other. A depot with randomize_offers=false keeps the fixed
# choice_*_kind exports (the harness-safe default).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot_roll.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")


# Stub level carrying a level_seed property — _ensure_rolled reads it
# from the depot's parent.
class StubLevel extends Node2D:
	var level_seed: int = 0


func _initialize() -> void:
	# === Default: randomize_offers is false → fixed @export choices.
	var d0: Area2D = DepotScene.instantiate()
	root.add_child(d0)
	await process_frame
	if d0.randomize_offers != false:
		push_error("FAIL — randomize_offers default is not false")
		quit(1); return
	if d0._choice_kind(1) != d0.choice_a_kind:
		push_error("FAIL — fixed depot: _choice_kind(1) != choice_a_kind")
		quit(1); return
	d0.queue_free()
	print("  randomize_offers default false → fixed @export choices")

	# === randomize_offers=true → 3 distinct kinds, varying by seed.
	var roll_sets: Dictionary = {}
	for s in [1, 7, 42, 99, 333]:
		var lvl := StubLevel.new()
		lvl.level_seed = s
		var d: Area2D = DepotScene.instantiate()
		d.randomize_offers = true
		lvl.add_child(d)
		root.add_child(lvl)
		await process_frame
		d._ensure_rolled()
		var kinds: Array = [d._choice_kind(1), d._choice_kind(2), d._choice_kind(3)]
		if kinds[0] == kinds[1] or kinds[0] == kinds[2] or kinds[1] == kinds[2]:
			push_error("FAIL — seed %d: rolled kinds not distinct: %s" % [s, kinds])
			quit(1); return
		for i in [1, 2, 3]:
			var lbl: String = d._choice_label(i)
			if lbl == "" or lbl == "upgrade":
				push_error("FAIL — seed %d: choice %d has no real label" % [s, i])
				quit(1); return
		var sorted_kinds: Array = kinds.duplicate()
		sorted_kinds.sort()
		roll_sets[str(sorted_kinds)] = true
		lvl.queue_free()

	if roll_sets.size() < 2:
		push_error("FAIL — randomization produced only 1 offer-set across 5 seeds")
		quit(1); return
	print("  %d distinct offer-sets across 5 seeds" % roll_sets.size())

	print("BREACH_DEPOT_ROLL_OK depot offers randomize per run; fixed default preserved")
	quit(0)
