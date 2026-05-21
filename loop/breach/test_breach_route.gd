# Arc-4 breach mode: run-route legibility verifier (Round 7c, iter 50).
# Verifies a breach PlayerTank surfaces the run's shuffled band route:
#   - a persistent route strip (RoutePanel) with one cell per band,
#     labelled with each band's short name in the run's order
#   - the current band's cell is highlighted; crossing a band moves
#     the highlight
#   - the strip is hidden behind the run-start codex, shown on dismiss
#   - an arc-2/3 PlayerTank (no loadout) builds no route strip
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_route.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BreachBandT = preload("res://scripts/BreachBand.gd")
const BreachConfigT = preload("res://scripts/BreachConfig.gd")


# Stub breach level — carries breach_config (the run's band order) and
# _current_breach_band, the two things _build_route_strip reads, plus
# the breach_band_changed signal PlayerTank connects to.
class StubBreachLevel extends Node2D:
	signal breach_band_changed(band)
	var breach_config = null
	var _current_breach_band = null


func _make_config(names: Array) -> BreachConfigT:
	var cfg: BreachConfigT = BreachConfigT.new()
	var bands: Array[BreachBandT] = []
	for nm in names:
		var b: BreachBandT = BreachBandT.new()
		b.band_name = nm
		bands.append(b)
	cfg.bands = bands
	return cfg


func _initialize() -> void:
	var names: Array = ["tutorial_choke", "brick_maze", "bunker_zone",
		"open_killbox", "endgame_mixed"]
	var cfg: BreachConfigT = _make_config(names)
	var lvl := StubBreachLevel.new()
	lvl.breach_config = cfg
	lvl._current_breach_band = cfg.bands[0]
	root.add_child(lvl)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	lvl.add_child(pt)
	# two frames: _ready, then the deferred _build_route_strip.
	await process_frame
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — PlayerTank has no HUD"); quit(1); return
	var panel: ColorRect = hud.get_node_or_null("RoutePanel") as ColorRect
	if panel == null:
		push_error("FAIL — breach HUD has no RoutePanel (run-route strip)")
		quit(1); return

	# one cell per band, labelled in run order with short names.
	var expect: Array = ["CHOKE", "MAZE", "BUNKER", "KILLBOX", "ENDGAME"]
	if pt._route_cell_labels.size() != expect.size():
		push_error("FAIL — route strip has %d cells, want %d" % [pt._route_cell_labels.size(), expect.size()])
		quit(1); return
	for i in expect.size():
		if pt._route_cell_labels[i].text != expect[i]:
			push_error("FAIL — cell %d text '%s', want '%s'" % [i, pt._route_cell_labels[i].text, expect[i]])
			quit(1); return
	print("  route strip: %s" % " > ".join(expect))

	# the current band (cell 0) is highlighted at run start.
	if pt._route_cell_bgs[0].color.a <= 0.0:
		push_error("FAIL — starting band cell not highlighted")
		quit(1); return
	print("  cell 0 highlighted at run start")

	# crossing into band index 2 moves the highlight off cell 0.
	var current_color: Color = pt._route_cell_bgs[0].color
	lvl.breach_band_changed.emit(cfg.bands[2])
	await process_frame
	if pt._route_cell_bgs[2].color.a <= 0.0:
		push_error("FAIL — highlight did not move to the crossed band")
		quit(1); return
	if pt._route_cell_bgs[0].color == current_color:
		push_error("FAIL — passed band still carries the current highlight")
		quit(1); return
	print("  highlight tracks band crossings (now on cell 2)")

	# the strip is hidden under the run-start codex, shown on dismiss.
	if panel.visible:
		push_error("FAIL — route strip visible while the codex still covers it")
		quit(1); return
	pt._dismiss_codex()
	if not panel.visible:
		push_error("FAIL — route strip not shown after codex dismiss")
		quit(1); return
	print("  route strip hidden behind codex, shown on dismiss")
	pt.queue_free()
	lvl.queue_free()

	# === arc-2/3 PlayerTank (no loadout) → no route strip.
	var pt2: Node = PlayerTankScene.instantiate()
	root.add_child(pt2)
	await process_frame
	await process_frame
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("RoutePanel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a RoutePanel (regression)")
		quit(1); return
	pt2.queue_free()

	print("BREACH_ROUTE_OK run-route strip names the band order; highlight tracks crossings; arc-2/3 unaffected")
	quit(0)
