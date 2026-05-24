# Arc-4 breach mode: meta-progression verifier (Round 6e iter 45,
# retiered Round 7d iter 51). Verifies the 4-rung MetaProgress unlock
# ladder + the depot offer pool widening with best-depth — climbing
# deep unlocks advanced rule-changers as OPTIONS (CONSULT 003: options,
# not power).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_meta.gd

extends SceneTree

const MetaProgressT = preload("res://scripts/MetaProgress.gd")
const DepotScene = preload("res://scenes/Depot.tscn")


func _initialize() -> void:
	# === MetaProgress unlock predicates (pure — explicit depths).
	if MetaProgressT.breach_dividend_unlocked(19) or not MetaProgressT.breach_dividend_unlocked(20):
		push_error("FAIL — Breach Dividend tier wrong (want @20)"); quit(1); return
	if MetaProgressT.overdrive_unlocked(39) or not MetaProgressT.overdrive_unlocked(40):
		push_error("FAIL — Overdrive tier wrong (want @40)"); quit(1); return
	if MetaProgressT.quick_swap_unlocked(59) or not MetaProgressT.quick_swap_unlocked(60):
		push_error("FAIL — Quick Swap tier wrong (want @60)"); quit(1); return
	if MetaProgressT.steel_salvage_unlocked(79) or not MetaProgressT.steel_salvage_unlocked(80):
		push_error("FAIL — Steel Salvage tier wrong (want @80)"); quit(1); return
	if MetaProgressT.best_depth() < 0:
		push_error("FAIL — best_depth() returned negative"); quit(1); return
	print("  unlock predicates: Dividend@20, Overdrive@40, Swap@60, Salvage@80")

	# === The unlock ladder is 4 rungs, strictly ascending shallow→deep.
	var ladder: Array = MetaProgressT.unlock_ladder()
	if ladder.size() != 4:
		push_error("FAIL — unlock ladder has %d rungs, want 4" % ladder.size())
		quit(1); return
	var prev: int = -1
	for rung in ladder:
		if int(rung["depth"]) <= prev:
			push_error("FAIL — unlock ladder not strictly ascending"); quit(1); return
		prev = int(rung["depth"])
	print("  unlock ladder: 4 rungs, ascending — %d/%d/%d/%d" % [
		int(ladder[0]["depth"]), int(ladder[1]["depth"]),
		int(ladder[2]["depth"]), int(ladder[3]["depth"])])

	# === The depot offer pool widens with best-depth: 5 core always,
	# +1 per unlock tier reached.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	# Pool sizes after iter 69 (Round 9g) added 3 archetype-SWITCH kinds
	# gated on the same tiers as the start-pick screen.
	var sizes: Dictionary = {0: 5, 20: 7, 40: 9, 60: 11, 80: 12, 999: 12}
	for best in sizes:
		var got: int = depot._upgrade_pool(best).size()
		if got != sizes[best]:
			push_error("FAIL — pool@%d = %d, want %d" % [best, got, sizes[best]])
			quit(1); return
	# All pool kinds distinct (no accidental dup).
	var deep: Array = depot._upgrade_pool(999)
	for i in deep.size():
		for j in range(i + 1, deep.size()):
			if deep[i] == deep[j]:
				push_error("FAIL — duplicate kind in the upgrade pool"); quit(1); return
	print("  depot pool widens: 5 (fresh) -> 7/9/11 -> 12 (all tiers; incl. archetype switches)")
	depot.queue_free()

	# === Arc-4 iter 097 (P2-2): enum-pin assertion. MetaProgress's
	# _ARCHETYPE_* constants MUST equal PlayerTank.TankArchetype
	# enum values. If the TankArchetype enum is reordered, this
	# guard catches the divergence at test time instead of producing
	# silently-wrong SWITCH_TO_* picks in Depot.
	var PlayerTankT = load("res://scripts/PlayerTank.gd")
	if MetaProgressT._ARCHETYPE_DEFAULT != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — P2-2: _ARCHETYPE_DEFAULT %d != TankArchetype.DEFAULT %d" % [MetaProgressT._ARCHETYPE_DEFAULT, PlayerTankT.TankArchetype.DEFAULT])
		quit(1); return
	if MetaProgressT._ARCHETYPE_PRISM != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — P2-2: _ARCHETYPE_PRISM %d != TankArchetype.PRISM %d" % [MetaProgressT._ARCHETYPE_PRISM, PlayerTankT.TankArchetype.PRISM])
		quit(1); return
	if MetaProgressT._ARCHETYPE_MORTAR != PlayerTankT.TankArchetype.MORTAR:
		push_error("FAIL — P2-2: _ARCHETYPE_MORTAR %d != TankArchetype.MORTAR %d" % [MetaProgressT._ARCHETYPE_MORTAR, PlayerTankT.TankArchetype.MORTAR])
		quit(1); return
	if MetaProgressT._ARCHETYPE_RAM != PlayerTankT.TankArchetype.RAM:
		push_error("FAIL — P2-2: _ARCHETYPE_RAM %d != TankArchetype.RAM %d" % [MetaProgressT._ARCHETYPE_RAM, PlayerTankT.TankArchetype.RAM])
		quit(1); return
	print("  P2-2 enum-pin: MetaProgress._ARCHETYPE_* == TankArchetype enum (DEFAULT=0/PRISM=1/MORTAR=2/RAM=3) — Depot SWITCH_TO_* coupling safe")

	print("BREACH_META_OK 4-rung unlock ladder; depth-gated pool widens 5->9 (options, not power); enum pin verified")
	quit(0)
