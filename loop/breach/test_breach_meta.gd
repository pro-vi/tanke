# Arc-4 breach mode: meta-progression verifier (Round 6e, iter 45).
# Verifies MetaProgress unlock predicates + the depot offer pool widens
# with best-depth — climbing deep unlocks advanced rule-changers as
# OPTIONS (CONSULT 003: options, not power).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_meta.gd

extends SceneTree

const MetaProgressT = preload("res://scripts/MetaProgress.gd")
const DepotScene = preload("res://scenes/Depot.tscn")


func _initialize() -> void:
	# === MetaProgress unlock predicates (pure — explicit depths).
	if MetaProgressT.quick_swap_unlocked(0) or MetaProgressT.quick_swap_unlocked(39):
		push_error("FAIL — Quick Swap unlocked below its threshold"); quit(1); return
	if not MetaProgressT.quick_swap_unlocked(40):
		push_error("FAIL — Quick Swap not unlocked at depth 40"); quit(1); return
	if MetaProgressT.steel_salvage_unlocked(79):
		push_error("FAIL — Steel Salvage unlocked below its threshold"); quit(1); return
	if not MetaProgressT.steel_salvage_unlocked(80):
		push_error("FAIL — Steel Salvage not unlocked at depth 80"); quit(1); return
	if MetaProgressT.best_depth() < 0:
		push_error("FAIL — best_depth() returned negative"); quit(1); return
	print("  unlock predicates: Quick Swap @40, Steel Salvage @80")

	# === The depot offer pool widens with best-depth.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	var p0: int = depot._upgrade_pool(0).size()
	var p40: int = depot._upgrade_pool(40).size()
	var p80: int = depot._upgrade_pool(80).size()
	var p999: int = depot._upgrade_pool(999).size()
	if p0 != 7:
		push_error("FAIL — fresh-save pool = %d, want 7" % p0); quit(1); return
	if p40 != 8:
		push_error("FAIL — depth-40 pool = %d, want 8" % p40); quit(1); return
	if p80 != 9 or p999 != 9:
		push_error("FAIL — deep pool = %d / %d, want 9 / 9" % [p80, p999]); quit(1); return
	# All pool kinds distinct (no accidental dup).
	var deep: Array = depot._upgrade_pool(999)
	for i in deep.size():
		for j in range(i + 1, deep.size()):
			if deep[i] == deep[j]:
				push_error("FAIL — duplicate kind in the upgrade pool"); quit(1); return
	print("  depot pool widens: 7 (fresh) -> 8 (@40) -> 9 (@80)")
	depot.queue_free()

	print("BREACH_META_OK depth-gated unlocks widen the depot pool (options, not power)")
	quit(0)
