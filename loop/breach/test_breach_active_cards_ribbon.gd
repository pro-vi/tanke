# Arc-4 breach mode: Round 24 Phase A widget 4 v1 — active cards ribbon (iter 278).
#
# A compact bottom-left strip above the route panel that grows as the
# player picks upgrade cards. Each chip carries:
#   - category-tinted bg color (HP=green, DEFAULT=AP-pale, PRISM=cyan,
#     MORTAR=warm yellow, RAM=warm red)
#   - 2-letter abbreviation label
#
# Closes Round 24 Phase A: HUD-as-status widget set complete.
#
# Verifies:
#   1. Procedural baseline (loadout == null) does NOT build the ribbon
#      (no panel, no chip arrays populated).
#   2. Breach mode (loadout != null) builds the panel + 8 chip slots,
#      all initially hidden (panel.visible = false, chips invisible).
#   3. After _apply_card(HP_PLUS_1), the ribbon panel becomes visible
#      and chip 0 shows label "HP" with green color.
#   4. After three picks (HP_PLUS_1, BEAM_DPS_UP, MOMENTUM), chips 0,
#      1, 2 are visible with correct labels (HP/BD/MV) and category
#      colors (green / cyan / AP-pale).
#   5. _applied_cards array tracks the pick history in order.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_active_cards_ribbon.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")


func _color_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.05 \
			and absf(a.g - b.g) < 0.05 \
			and absf(a.b - b.b) < 0.05


func _initialize() -> void:
	# === Case A: procedural baseline — ribbon not built.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var pt_a: Node = PlayerTankScene.instantiate()
	holder_a.add_child(pt_a)
	await process_frame
	await process_frame
	if pt_a._active_cards_panel != null:
		push_error("FAIL — procedural baseline built _active_cards_panel (must be null without loadout)")
		quit(1); return
	if not pt_a._active_cards_chip_bgs.is_empty():
		push_error("FAIL — procedural baseline populated _active_cards_chip_bgs (must be empty)")
		quit(1); return
	if not pt_a._applied_cards.is_empty():
		push_error("FAIL — procedural baseline _applied_cards not empty (must be [])")
		quit(1); return
	print("  procedural baseline: ribbon not built (loadout-gated contract holds)")
	pt_a.queue_free()
	await process_frame

	# === Case B: breach mode — built with 8 slots, all hidden.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt._active_cards_panel == null:
		push_error("FAIL — _active_cards_panel not built in breach mode")
		quit(1); return
	if pt._active_cards_chip_bgs.size() != PlayerTankT.ACTIVE_CARDS_MAX_VISIBLE:
		push_error("FAIL — expected %d chip slots, got %d" \
				% [PlayerTankT.ACTIVE_CARDS_MAX_VISIBLE, pt._active_cards_chip_bgs.size()])
		quit(1); return
	if pt._active_cards_panel.visible:
		push_error("FAIL — panel.visible should be false when no cards applied")
		quit(1); return
	for i in PlayerTankT.ACTIVE_CARDS_MAX_VISIBLE:
		if pt._active_cards_chip_bgs[i].visible:
			push_error("FAIL — chip %d should be hidden at baseline" % i)
			quit(1); return
	print("  case B: ribbon built with %d slots, all hidden, panel hidden" \
			% PlayerTankT.ACTIVE_CARDS_MAX_VISIBLE)

	# === Case C: 1 pick (HP_PLUS_1) → panel visible + chip 0 = green "HP".
	pt._apply_card(UpgradeCatalogT.CardKind.HP_PLUS_1)
	if not pt._active_cards_panel.visible:
		push_error("FAIL — after 1 pick, panel.visible should be true")
		quit(1); return
	if not pt._active_cards_chip_bgs[0].visible:
		push_error("FAIL — after 1 pick, chip 0 should be visible")
		quit(1); return
	# iter 280 (consult-001 H5 fix): HP token retained as "HP" (3-letter
	# tokens for others; HP is conventional + universally parseable).
	if pt._active_cards_chip_labels[0].text != "HP":
		push_error("FAIL — chip 0 label = '%s', want 'HP'" \
				% pt._active_cards_chip_labels[0].text)
		quit(1); return
	if not _color_close(pt._active_cards_chip_bgs[0].color, Color(0.3, 0.9, 0.4, 1.0)):
		push_error("FAIL — HP chip color = %s, want green (~0.3, 0.9, 0.4)" \
				% str(pt._active_cards_chip_bgs[0].color))
		quit(1); return
	if pt._applied_cards != [UpgradeCatalogT.CardKind.HP_PLUS_1]:
		push_error("FAIL — _applied_cards = %s, want [HP_PLUS_1]" % str(pt._applied_cards))
		quit(1); return
	print("  1 pick (HP_PLUS_1): panel shown, chip 0 = green 'HP'")

	# === Case D: 3 total picks (HP_PLUS_1, BEAM_DPS_UP, MOMENTUM).
	pt._apply_card(UpgradeCatalogT.CardKind.BEAM_DPS_UP)
	pt._apply_card(UpgradeCatalogT.CardKind.MOMENTUM)
	for i in 3:
		if not pt._active_cards_chip_bgs[i].visible:
			push_error("FAIL — chip %d should be visible after 3 picks" % i)
			quit(1); return
	# iter 280 (consult-001 H5 fix): chip 1 = BEAM_DPS_UP = "BEAM" (was "BD")
	if pt._active_cards_chip_labels[1].text != "BEAM":
		push_error("FAIL — chip 1 label = '%s', want 'BEAM' (consult-001 H5 relabel)" % pt._active_cards_chip_labels[1].text)
		quit(1); return
	if not _color_close(pt._active_cards_chip_bgs[1].color, Color(0.6, 0.85, 1.0, 1.0)):
		push_error("FAIL — BEAM_DPS_UP chip color = %s, want cyan" \
				% str(pt._active_cards_chip_bgs[1].color))
		quit(1); return
	# iter 280 (consult-001 H5 fix): chip 2 = MOMENTUM = "MOVE" (was "MV") + AP-pale
	if pt._active_cards_chip_labels[2].text != "MOVE":
		push_error("FAIL — chip 2 label = '%s', want 'MOVE' (consult-001 H5 relabel)" % pt._active_cards_chip_labels[2].text)
		quit(1); return
	if not _color_close(pt._active_cards_chip_bgs[2].color, Color(0.92, 0.92, 0.95, 1.0)):
		push_error("FAIL — MOMENTUM chip color = %s, want AP-pale" \
				% str(pt._active_cards_chip_bgs[2].color))
		quit(1); return
	# chip 3+ remain hidden
	for i in range(3, PlayerTankT.ACTIVE_CARDS_MAX_VISIBLE):
		if pt._active_cards_chip_bgs[i].visible:
			push_error("FAIL — chip %d should still be hidden (only 3 picks)" % i)
			quit(1); return
	print("  3 picks: chips [HP green, BEAM cyan, MOVE AP-pale] visible; chips 3-7 hidden")

	# === Case E: _applied_cards history preserved in order.
	if pt._applied_cards != [
			UpgradeCatalogT.CardKind.HP_PLUS_1,
			UpgradeCatalogT.CardKind.BEAM_DPS_UP,
			UpgradeCatalogT.CardKind.MOMENTUM,
		]:
		push_error("FAIL — _applied_cards order = %s, want [HP, BEAM_DPS, MOMENTUM]" \
				% str(pt._applied_cards))
		quit(1); return
	print("  _applied_cards preserves pick order: %s" % str(pt._applied_cards))

	print("BREACH_ACTIVE_CARDS_RIBBON_OK Phase A widget 4 ribbon + 8 slots + 3-pick render verified")
	quit(0)
