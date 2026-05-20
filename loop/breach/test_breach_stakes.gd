# Arc-4 breach mode: stakes & escalation verifier (Round 6d, iter 42).
# Verifies a breach PlayerTank surfaces the single-life depth chase:
#   - a live best-depth readout (BestLabel) on the HUD
#   - a band-arrival banner when the breach level reports a band cross
# An arc-2/3 PlayerTank (no loadout) builds neither.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_stakes.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BreachBandT = preload("res://scripts/BreachBand.gd")


# Stub breach level — carries the breach_band_changed signal PlayerTank
# connects to in breach mode.
class StubBreachLevel extends Node2D:
	signal breach_band_changed(band)


func _initialize() -> void:
	# === Breach PlayerTank under a stub breach level.
	var lvl := StubBreachLevel.new()
	root.add_child(lvl)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	lvl.add_child(pt)
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — PlayerTank has no HUD"); quit(1); return

	# Live best-depth readout — the depth chase, always visible.
	var best: Label = hud.get_node_or_null("BestLabel") as Label
	if best == null:
		push_error("FAIL — breach HUD has no BestLabel (depth chase)")
		quit(1); return
	if best.text.find("BEST") == -1:
		push_error("FAIL — BestLabel text wrong: '%s'" % best.text)
		quit(1); return
	print("  BestLabel present: '%s'" % best.text)

	# Band-arrival banner fires on a band crossing.
	var band := BreachBandT.new()
	band.band_name = "bunker_zone"
	band.dominant_pressure = "steel-armored bunkers"
	lvl.breach_band_changed.emit(band)
	await process_frame
	var banner: Label = hud.get_node_or_null("BandBanner") as Label
	if banner == null:
		push_error("FAIL — no BandBanner after a band crossing")
		quit(1); return
	if banner.text.find("BUNKER") == -1:
		push_error("FAIL — banner does not name the band: '%s'" % banner.text)
		quit(1); return
	print("  band banner: '%s'" % banner.text.replace("\n", " / "))
	pt.queue_free()
	lvl.queue_free()

	# === arc-2/3 PlayerTank (no loadout) → no BestLabel.
	var pt2: Node = PlayerTankScene.instantiate()
	root.add_child(pt2)
	await process_frame
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("BestLabel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a BestLabel (regression)")
		quit(1); return
	pt2.queue_free()

	print("BREACH_STAKES_OK depth-chase readout + band-arrival banner; arc-2/3 unaffected")
	quit(0)
