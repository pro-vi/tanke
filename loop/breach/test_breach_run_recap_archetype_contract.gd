# Arc-4 breach mode: P1-4 regression — RunRecap.archetype must
# reflect the RUN-START archetype, not the latest archetype (iter
# 095, fixing iter-90 /code-review P1-4).
#
# Before the fix: PlayerTank._on_breach_band_changed reassigned
# run_recap.archetype = archetype on every band crossing,
# contradicting the documented "at run start" contract. Mid-run
# SWITCH_TO_* upgrades polluted cross-archetype distinctness
# analysis (iter-82/83 RunRecapAnalyzer).
#
# After the fix:
#   - run_recap.archetype captured in _ready (run-start default)
#   - run_recap.archetype updated in _pick_archetype (pick override)
#   - run_recap.archetype NEVER touched in _on_breach_band_changed
#   - switch_archetype calls (mid-run SWITCH_TO_*) do NOT touch it
#
# Verifies:
#   - Fresh PlayerTank with DEFAULT: run_recap.archetype == 0
#   - switch_archetype(PRISM) mid-run: run_recap.archetype STAYS 0
#   - Simulated band crossing via _on_breach_band_changed: stays 0
#   - _pick_archetype(MORTAR): run_recap.archetype updates to 2
#   - Subsequent switch_archetype(RAM): run_recap.archetype STAYS 2
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_archetype_contract.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


# Stub band with a band_name property — duck-typed match for the
# PlayerTank._on_breach_band_changed handler's `"band_name" in band`
# check.
class _BandStub extends RefCounted:
	var band_name: String = ""


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Fresh PlayerTank with DEFAULT archetype.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	# archetype defaults to DEFAULT (0); leave force_archetype_select false
	# so _ready captures DEFAULT into run_recap.archetype directly.
	holder.add_child(pt)
	await process_frame
	await process_frame

	if pt.run_recap == null:
		push_error("FAIL — run_recap was not created in _ready")
		quit(1); return
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — fresh _ready: run_recap.archetype %d, want DEFAULT (0)" % pt.run_recap.archetype)
		quit(1); return
	print("  fresh _ready: run_recap.archetype = DEFAULT (0) — captured at run start")

	# === Mid-run switch_archetype(PRISM) — run_recap.archetype must STAY 0.
	pt.switch_archetype(PlayerTankT.TankArchetype.PRISM)
	if pt.archetype != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — after switch_archetype(PRISM): pt.archetype %d, want PRISM (1)" % pt.archetype)
		quit(1); return
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — after switch_archetype(PRISM): run_recap.archetype %d, want DEFAULT (0) [run-start contract violated]" % pt.run_recap.archetype)
		quit(1); return
	print("  after switch_archetype(PRISM): pt.archetype=PRISM, run_recap.archetype STAYS DEFAULT (0)")

	# === Simulate band crossing — run_recap.archetype must STAY 0.
	var band1: _BandStub = _BandStub.new()
	band1.band_name = "warmup"
	pt._on_breach_band_changed(band1)
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — after band crossing: run_recap.archetype %d, want DEFAULT (0) [band-change reassignment leaked back]" % pt.run_recap.archetype)
		quit(1); return
	# But band_visit_log should have grown (P1-4 fix removed only the
	# archetype reassignment, not the enter_band call).
	if pt.run_recap.band_visit_log.size() != 1:
		push_error("FAIL — after 1 band crossing: band_visit_log.size %d, want 1" % pt.run_recap.band_visit_log.size())
		quit(1); return
	print("  after band crossing: run_recap.archetype STAYS DEFAULT; band_visit_log captured 'warmup'")

	# === Multiple band crossings + another switch — archetype STAYS 0.
	var band2: _BandStub = _BandStub.new()
	band2.band_name = "bunker"
	pt._on_breach_band_changed(band2)
	pt.switch_archetype(PlayerTankT.TankArchetype.RAM)
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — after multi-events: run_recap.archetype %d, want DEFAULT (0)" % pt.run_recap.archetype)
		quit(1); return
	if pt.run_recap.band_visit_log.size() != 2:
		push_error("FAIL — band_visit_log.size %d after 2 bands, want 2" % pt.run_recap.band_visit_log.size())
		quit(1); return
	print("  after multi-band + switch_archetype(RAM): run_recap.archetype STAYS DEFAULT (0), band log size 2")

	# === Now exercise the _pick_archetype path. Re-open selector,
	# pick MORTAR — run_recap.archetype should update to 2.
	pt._show_archetype_select()
	pt._pick_archetype(PlayerTankT.TankArchetype.MORTAR)
	if pt.archetype != PlayerTankT.TankArchetype.MORTAR:
		push_error("FAIL — after _pick_archetype(MORTAR): pt.archetype %d, want MORTAR (2)" % pt.archetype)
		quit(1); return
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.MORTAR:
		push_error("FAIL — after _pick_archetype(MORTAR): run_recap.archetype %d, want MORTAR (2) [pick should override]" % pt.run_recap.archetype)
		quit(1); return
	print("  _pick_archetype(MORTAR): run_recap.archetype UPDATED to MORTAR (2) — pick overrides _ready capture")

	# === Final assertion: switch_archetype AFTER pick does NOT
	# overwrite run_recap.archetype (it stays at the pick value).
	pt.switch_archetype(PlayerTankT.TankArchetype.RAM)
	if pt.run_recap.archetype != PlayerTankT.TankArchetype.MORTAR:
		push_error("FAIL — switch_archetype(RAM) post-pick: run_recap.archetype %d, want MORTAR (2) [pick value preserved]" % pt.run_recap.archetype)
		quit(1); return
	print("  switch_archetype(RAM) post-pick: run_recap.archetype STAYS MORTAR (2) — pick value preserved")

	holder.queue_free()
	print("BREACH_RUN_RECAP_ARCHETYPE_CONTRACT_OK P1-4 fix verified — run_recap.archetype = run-start (DEFAULT or pick-screen choice), never mid-run switch value")
	quit(0)
