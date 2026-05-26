# Arc-4 iter 302 (consult-001 H5 sub-recommendation):
# Verifies that picking an upgrade card surfaces the FULL name +
# sentence-test description as a transient toast on the HUD, so the
# active-cards ribbon (iter 278, relabeled iter 280) functions as a
# reminder rather than the first explanation.
#
# Consult-001 H5 verdict 0.95: "Replace ribbon labels with short
# tokens; ON PICKUP, show the full card name for 1-2 seconds so the
# ribbon becomes a reminder, not the first explanation."
#
# Verifies:
#   1. Calling _apply_card spawns a Label (via _show_pickup_toast)
#      on the HUD canvas tagged is_pickup_toast.
#   2. Toast text contains the full UpgradeCatalog label + sentence,
#      not the 2-letter ribbon token.
#   3. Toast color matches the ribbon chip category color (so the
#      player learns the color → category mapping).
#   4. Toast z_index == HUD_Z_TOAST (40) so it renders over popups.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_card_pickup_toast.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	var hud: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	if hud == null:
		push_error("FAIL — HUD canvas missing")
		quit(1); return

	# Pre-condition: no pickup toasts yet.
	var before: int = _count_pickup_toasts(hud)
	if before != 0:
		push_error("FAIL — %d pickup toasts present pre-apply" % before)
		quit(1); return

	# Apply HP_PLUS_1 — the simplest universal card.
	pt._apply_card(UpgradeCatalogT.CardKind.HP_PLUS_1)
	await process_frame

	# Case 1: at least one toast appeared.
	var after: int = _count_pickup_toasts(hud)
	if after <= before:
		push_error("FAIL — _apply_card did not spawn a pickup toast (count %d → %d)" \
				% [before, after])
		quit(1); return

	# Find the most recent toast (largest y stagger likely; or grab any).
	var toast: Label = null
	for child in hud.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			toast = child as Label
			break
	if toast == null:
		push_error("FAIL — no is_pickup_toast Label found on HUD")
		quit(1); return
	print("  case 1: pickup toast spawned (%d → %d)" % [before, after])

	# Case 2: toast text contains the FULL card label + sentence.
	var want_label: String = UpgradeCatalogT.label_for(UpgradeCatalogT.CardKind.HP_PLUS_1)
	var want_sentence: String = UpgradeCatalogT.sentence_for(UpgradeCatalogT.CardKind.HP_PLUS_1)
	if not toast.text.contains(want_label):
		push_error("FAIL — toast text '%s' does not contain card label '%s'" \
				% [toast.text, want_label])
		quit(1); return
	if not toast.text.contains(want_sentence):
		push_error("FAIL — toast text '%s' does not contain sentence '%s'" \
				% [toast.text, want_sentence])
		quit(1); return
	print("  case 2: toast text contains label '%s' + sentence '%s'" % [want_label, want_sentence])

	# Case 3: toast color matches the ribbon chip category color.
	var want_color: Color = pt._card_chip_color(UpgradeCatalogT.CardKind.HP_PLUS_1)
	var got_color: Color = toast.get_theme_color("font_color")
	if absf(got_color.r - want_color.r) > 0.02 \
			or absf(got_color.g - want_color.g) > 0.02 \
			or absf(got_color.b - want_color.b) > 0.02:
		push_error("FAIL — toast color (%.2f,%.2f,%.2f) does not match chip color (%.2f,%.2f,%.2f)" \
				% [got_color.r, got_color.g, got_color.b,
				   want_color.r, want_color.g, want_color.b])
		quit(1); return
	print("  case 3: toast color matches HP_PLUS_1 chip category (green)")

	# Case 4: toast z_index = HUD_Z_TOAST so it reaches the player over popups.
	if toast.z_index != PlayerTankT.HUD_Z_TOAST:
		push_error("FAIL — toast z_index = %d, want HUD_Z_TOAST (%d)" \
				% [toast.z_index, PlayerTankT.HUD_Z_TOAST])
		quit(1); return
	print("  case 4: toast z_index = HUD_Z_TOAST (%d, always-reach contract)" % toast.z_index)

	print("BREACH_CARD_PICKUP_TOAST_OK 4 cases — toast spawns / text has label+sentence / color matches chip / z=TOAST")
	quit(0)


func _count_pickup_toasts(hud: CanvasLayer) -> int:
	var n: int = 0
	for child in hud.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			if not child.is_queued_for_deletion():
				n += 1
	return n
