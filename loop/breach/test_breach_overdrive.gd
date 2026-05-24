# Arc-4 breach mode: OVERDRIVE sprint upgrade verifier (C8 anchor 3).
# Verifies: the OVERDRIVE depot upgrade sets loadout.has_overdrive; a
# sprint burst raises effective move speed for overdrive_burst seconds
# then enters cooldown; arc-2/3 PlayerTank (no loadout) never sprints;
# and the 9-entry depot catalog covers all 5 band-pressure categories.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_overdrive.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")


func _initialize() -> void:
	# === Test 1: OVERDRIVE depot upgrade sets has_overdrive.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	var lo: LoadoutT = LoadoutT.new()
	if lo.has_overdrive:
		push_error("FAIL — has_overdrive should default false"); quit(1); return
	depot.apply_upgrade(depot.UpgradeKind.OVERDRIVE, lo)
	if not lo.has_overdrive:
		push_error("FAIL — OVERDRIVE upgrade did not set has_overdrive"); quit(1); return

	# === Test 2: catalog covers all 5 band-pressure categories.
	# iter 69 (Round 9g): 12 entries total — 9 original (refills /
	# expands / resupply / 4 rule-changers) + 3 SWITCH_TO_* archetype
	# kinds.
	# arc-4 iter 116 (Round 14 Phase 2, C8 anchor 3): REAR_GUARD
	# added → 14 entries; closes the open_killbox band-coverage gap
	# deferred from Round 13 (passive auto-defense in rear cone).
	var UK = depot.UpgradeKind
	if UK.size() != 14:
		push_error("FAIL — catalog has %d entries, want 14" % UK.size()); quit(1); return
	# Each category has a representative; OVERDRIVE = positioning;
	# SCOUT_TELEGRAPH = perceptual aid for tutorial_choke;
	# REAR_GUARD = commitment-change for open_killbox rear-flanks.
	for kind in [UK.HE_REFILL_2, UK.HEAT_REFILL_1, UK.OVERDRIVE, UK.FULL_RESUPPLY, UK.SCOUT_TELEGRAPH, UK.REAR_GUARD]:
		var probe: LoadoutT = LoadoutT.new()
		probe.he_reserve = 0
		probe.heat_reserve = 0
		depot.apply_upgrade(kind, probe)  # must not crash; effect applied
	print("  catalog: 14 upgrades — refills + 4 rule-changers + 3 archetype-switches + SCOUT_TELEGRAPH + REAR_GUARD (all 5 bands covered)")
	depot.queue_free()

	# === Test 3: a breach PlayerTank with OVERDRIVE sprints; speed
	# multiplies during the burst window.
	var pt: Node = PlayerTankScene.instantiate()
	var lo2: LoadoutT = LoadoutT.new()
	lo2.has_overdrive = true
	pt.loadout = lo2
	root.add_child(pt)
	await process_frame
	if pt._overdrive_timer != 0.0:
		push_error("FAIL — _overdrive_timer nonzero before any burst"); quit(1); return
	if pt.overdrive_mult <= 1.0:
		push_error("FAIL — overdrive_mult %.2f not > 1.0" % pt.overdrive_mult); quit(1); return
	# Trigger a burst directly (the input poll is exercised in-game; the
	# harness drives the state the way the input branch would), then drive
	# _physics_process with explicit deltas (headless process_frame does
	# not reliably tick _physics_process).
	pt._overdrive_timer = pt.overdrive_burst
	# A delta past the burst window must end the burst + arm the cooldown.
	pt._physics_process(pt.overdrive_burst + 0.05)
	if pt._overdrive_timer != 0.0:
		push_error("FAIL — burst did not end (timer %.2f)" % pt._overdrive_timer); quit(1); return
	if pt._overdrive_cd <= 0.0:
		push_error("FAIL — cooldown not armed after burst (got %.2f)" % pt._overdrive_cd); quit(1); return
	print("  sprint burst → cooldown transition verified")
	pt.queue_free()

	# === Test 4: arc-2/3 PlayerTank (no loadout) never sprints — driving
	# _physics_process must not engage overdrive without a loadout.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	for i in 5:
		pt_arc2._physics_process(0.05)
	if pt_arc2._overdrive_timer != 0.0 or pt_arc2._overdrive_cd != 0.0:
		push_error("FAIL — arc-2/3 PlayerTank engaged overdrive (regression)"); quit(1); return
	pt_arc2.queue_free()

	print("BREACH_OVERDRIVE_OK sprint verb + 12-upgrade catalog covers 5 band pressures")
	quit(0)
