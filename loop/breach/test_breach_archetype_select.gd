# Arc-4 breach mode: archetype start-pick verifier (Round 9f, iter 68).
# Verifies:
#   - MetaProgress predicates: PRISM@20, MORTAR@40, RAM@60
#   - unlocked_archetypes returns the ordered list across depth tiers
#   - PlayerTank._show_archetype_select builds the panel + arms the flag
#   - _pick_archetype(PRISM) sets archetype + clears the flag + fires
#     the per-archetype init (the beam line is built)
#   - the panel is NOT built when force_archetype_select is false
#     (existing harnesses don't get a screen leak)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_archetype_select.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MetaProgressT = preload("res://scripts/MetaProgress.gd")


func _initialize() -> void:
	# === MetaProgress unlock predicates.
	if MetaProgressT.prism_unlocked(19) or not MetaProgressT.prism_unlocked(20):
		push_error("FAIL — PRISM tier wrong (want @20)"); quit(1); return
	if MetaProgressT.mortar_unlocked(39) or not MetaProgressT.mortar_unlocked(40):
		push_error("FAIL — MORTAR tier wrong (want @40)"); quit(1); return
	if MetaProgressT.ram_unlocked(59) or not MetaProgressT.ram_unlocked(60):
		push_error("FAIL — RAM tier wrong (want @60)"); quit(1); return
	print("  unlock predicates: PRISM@20, MORTAR@40, RAM@60")

	# === unlocked_archetypes across tiers.
	var u0: Array = MetaProgressT.unlocked_archetypes(0)
	var u30: Array = MetaProgressT.unlocked_archetypes(30)
	var u50: Array = MetaProgressT.unlocked_archetypes(50)
	var u70: Array = MetaProgressT.unlocked_archetypes(70)
	if u0.size() != 1 or u30.size() != 2 or u50.size() != 3 or u70.size() != 4:
		push_error("FAIL — unlocked_archetypes sizes %d/%d/%d/%d, want 1/2/3/4" % [u0.size(), u30.size(), u50.size(), u70.size()])
		quit(1); return
	print("  unlocked_archetypes across tiers: 1/2/3/4 (depths 0/30/50/70)")

	# === breach PlayerTank — _show_archetype_select builds the panel.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame  # iter-50 deferred RoutePanel
	# Harness doesn't depend on best_depth file state — drive directly.
	pt._show_archetype_select()
	if not pt._archetype_selecting:
		push_error("FAIL — _archetype_selecting not true after _show"); quit(1); return
	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	var panel: ColorRect = hud.get_node_or_null("ArchetypePanel") as ColorRect
	if panel == null or not panel.visible:
		push_error("FAIL — ArchetypePanel not built or hidden"); quit(1); return
	print("  _show_archetype_select: panel built + flag set")

	# === _pick_archetype(PRISM) sets state + fires PRISM init.
	pt._pick_archetype(PlayerTankT.TankArchetype.PRISM)
	if pt.archetype != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — archetype not set to PRISM (got %d)" % pt.archetype); quit(1); return
	if pt._archetype_selecting:
		push_error("FAIL — _archetype_selecting still true after pick"); quit(1); return
	if panel.visible:
		push_error("FAIL — panel still visible after pick"); quit(1); return
	if pt.get_node_or_null("BeamLine") == null:
		push_error("FAIL — PRISM init did not fire (no BeamLine)"); quit(1); return
	print("  _pick_archetype(PRISM): archetype set, flag cleared, beam line built")
	holder.queue_free()
	await process_frame

	# === force_archetype_select default false → no auto-show.
	var h2 := Node2D.new()
	root.add_child(h2)
	var pt2: Node = PlayerTankScene.instantiate()
	pt2.loadout = LoadoutT.new()
	# force_archetype_select stays false (default).
	h2.add_child(pt2)
	await process_frame
	await process_frame
	if pt2._archetype_selecting:
		push_error("FAIL — selecting flag set without force_archetype_select"); quit(1); return
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ArchetypePanel") != null:
		push_error("FAIL — ArchetypePanel built without force_archetype_select"); quit(1); return
	print("  force_archetype_select default false → no auto-show (harness safe)")
	h2.queue_free()

	print("BREACH_ARCHETYPE_SELECT_OK MetaProgress unlocks + start-pick screen + pick flow")
	quit(0)
