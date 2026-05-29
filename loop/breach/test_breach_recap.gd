# Arc-4 breach mode: RunRecap death-attribution verifier (C6 anchors
# 1+2). Verifies RunRecap.gd captures depth + killing band, per-type
# shell consumption, reserves at death, and formats a non-empty recap.
#
# Also exercises the PlayerTank integration: a breach-mode PlayerTank
# (loadout set) creates a run_recap; an arc-2/3 PlayerTank (loadout
# null) does NOT.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_recap.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")
const BreachBandT = preload("res://scripts/BreachBand.gd")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")


func _initialize() -> void:
	# === Test 1: RunRecap captures + formats.
	var rc: RunRecapT = RunRecapT.new()
	rc.record_shot(BulletT.SHELL_CLASS_AP)
	rc.record_shot(BulletT.SHELL_CLASS_HE)
	rc.record_shot(BulletT.SHELL_CLASS_HE)
	rc.record_shot(BulletT.SHELL_CLASS_HEAT)
	if rc.total_shells_fired() != 4:
		push_error("FAIL — total_shells_fired = %d, want 4" % rc.total_shells_fired())
		quit(1); return
	if rc.shells_fired[BulletT.SHELL_CLASS_HE] != 2:
		push_error("FAIL — HE fired count != 2"); quit(1); return

	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 1
	lo.heat_reserve = 0
	var band: BreachBandT = BreachBandT.new()
	band.band_name = "bunker_zone"
	band.dominant_pressure = "steel-armored bunkers; entrenched heavy tanks"
	rc.capture_death(84, band, lo)
	if not rc.captured:
		push_error("FAIL — capture_death did not set captured"); quit(1); return
	if rc.depth_reached != 84:
		push_error("FAIL — depth_reached = %d, want 84" % rc.depth_reached); quit(1); return
	if rc.killing_band != "bunker_zone":
		push_error("FAIL — killing_band = %s" % rc.killing_band); quit(1); return
	if rc.killing_pressure.find("steel-armored bunkers") == -1:
		push_error("FAIL — killing_pressure not captured: '%s'" % rc.killing_pressure); quit(1); return
	if rc.he_reserve_at_death != 1:
		push_error("FAIL — he_reserve_at_death = %d, want 1" % rc.he_reserve_at_death); quit(1); return

	# Build tag: HE-dominant run → "rubble plow".
	if rc.build_tag() != "rubble plow":
		push_error("FAIL — build_tag = %s, want 'rubble plow'" % rc.build_tag()); quit(1); return

	var text: String = rc.format()
	if text.find("depth reached") == -1 or text.find("84") == -1 or text.find("bunker_zone") == -1:
		push_error("FAIL — recap text missing depth/band:\n%s" % text); quit(1); return
	if text.find("AP 1 / HE 2 / HEAT 1") == -1:
		push_error("FAIL — recap text missing shell breakdown:\n%s" % text); quit(1); return
	if text.find("band pressure") == -1 or text.find("steel-armored bunkers") == -1:
		push_error("FAIL — recap text missing band pressure:\n%s" % text); quit(1); return
	print(text)

	# === Test 2: build_tag variants.
	var ap_only: RunRecapT = RunRecapT.new()
	ap_only.record_shot(BulletT.SHELL_CLASS_AP)
	if ap_only.build_tag() != "lane sniper":
		push_error("FAIL — AP-only build_tag = %s, want 'lane sniper'" % ap_only.build_tag()); quit(1); return
	var heat_run: RunRecapT = RunRecapT.new()
	heat_run.record_shot(BulletT.SHELL_CLASS_HEAT)
	heat_run.record_shot(BulletT.SHELL_CLASS_HEAT)
	if heat_run.build_tag() != "bunker cracker":
		push_error("FAIL — HEAT-heavy build_tag = %s" % heat_run.build_tag()); quit(1); return

	# === Test 3: PlayerTank integration — breach mode creates run_recap.
	var pt_breach: Node = PlayerTankScene.instantiate()
	pt_breach.loadout = LoadoutT.new()
	root.add_child(pt_breach)
	await process_frame
	if pt_breach.run_recap == null:
		push_error("FAIL — breach-mode PlayerTank did not create run_recap"); quit(1); return
	pt_breach.queue_free()

	# === Test 4: arc-2/3 PlayerTank (no loadout) does NOT create run_recap.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	if pt_arc2.run_recap != null:
		push_error("FAIL — arc-2/3 PlayerTank created run_recap (regression)"); quit(1); return
	pt_arc2.queue_free()

	print("BREACH_RECAP_OK depth + band + pressure + per-type shells + reserves captured")
	quit(0)
