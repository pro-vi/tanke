# Arc-4 breach mode: shell-readout HUD verifier (Round 5 legibility,
# iter 35 — playtest finding 1 "no shell UI"; iter 300 — moved to
# bottom-center WoT-style per user feedback #3, replacing the legacy
# y=209 tray with the iter-276 chip row carrying shell-name + reserve).
#
# Verifies a breach PlayerTank (loadout set) builds a 4-chip
# ShellChipsPanel reflecting current_shell + per-shell reserves + a
# selection highlight, and an arc-2/3 PlayerTank (no loadout) builds
# none — the arc-2/3 HUD stays bit-identical.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hud.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Breach PlayerTank: loadout set → 4 chips with reserve labels.
	var pt: Node = PlayerTankScene.instantiate()
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 3
	lo.heat_reserve = 2
	lo.apcr_reserve = 1
	pt.loadout = lo
	pt.current_shell = BulletT.SHELL_CLASS_HE
	root.add_child(pt)
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — PlayerTank has no HUD CanvasLayer")
		quit(1); return
	var panel: ColorRect = hud.get_node_or_null("ShellChipsPanel") as ColorRect
	if panel == null:
		push_error("FAIL — breach PlayerTank has no ShellChipsPanel")
		quit(1); return
	if pt._shell_chip_labels.size() != 4:
		push_error("FAIL — ShellChipsPanel has %d chips, want 4" % pt._shell_chip_labels.size())
		quit(1); return

	# iter 300: panel sits bottom-center
	if absf(panel.position.x - (PlayerTankT.SHELL_CHIPS_X - 1.0)) > 0.5 \
			or absf(panel.position.y - (PlayerTankT.SHELL_CHIPS_Y - 1.0)) > 0.5:
		push_error("FAIL — panel position %s, want (%s, %s) bottom-center" \
				% [str(panel.position), PlayerTankT.SHELL_CHIPS_X - 1.0,
				   PlayerTankT.SHELL_CHIPS_Y - 1.0])
		quit(1); return
	# Roughly centered in 320-wide viewport
	var center_x: float = panel.position.x + panel.size.x * 0.5
	if absf(center_x - 160.0) > 8.0:
		push_error("FAIL — panel center_x = %.1f, want ~160 (viewport center)" % center_x)
		quit(1); return
	print("  panel bottom-center at %s, centered ≈ 160 (viewport center)" % str(panel.position))

	pt._update_shell_chips()
	# Slot order: AP, HE, HEAT, APCR. Reserves: HE 3, HEAT 2, APCR 1.
	var ap_txt: String = pt._shell_chip_labels[0].text
	var he_txt: String = pt._shell_chip_labels[1].text
	var heat_txt: String = pt._shell_chip_labels[2].text
	var apcr_txt: String = pt._shell_chip_labels[3].text
	if ap_txt != "AP --":
		push_error("FAIL — AP chip = '%s', want 'AP --'" % ap_txt); quit(1); return
	if he_txt != "HE 3":
		push_error("FAIL — HE chip = '%s', want 'HE 3'" % he_txt); quit(1); return
	if heat_txt != "HEAT 2":
		push_error("FAIL — HEAT chip = '%s', want 'HEAT 2'" % heat_txt); quit(1); return
	if apcr_txt != "APCR 1":
		push_error("FAIL — APCR chip = '%s', want 'APCR 1'" % apcr_txt); quit(1); return
	print("  chips: [%s] [%s] [%s] [%s]" % [ap_txt, he_txt, heat_txt, apcr_txt])

	# Selection highlight: HE chip (current_shell) bg at full saturation;
	# AP chip (not selected) at ~35% brightness.
	var he_bg: Color = pt._shell_chip_bgs[1].color
	var ap_bg: Color = pt._shell_chip_bgs[0].color
	if (he_bg.r + he_bg.g + he_bg.b) <= (ap_bg.r + ap_bg.g + ap_bg.b):
		push_error("FAIL — selected HE not brighter than unselected AP")
		quit(1); return
	print("  selection highlight tracks current_shell (HE bright, others dim)")

	# Reserve change + selection change reflect on next update.
	pt.loadout.he_reserve = 0
	pt.current_shell = BulletT.SHELL_CLASS_AP
	pt._update_shell_chips()
	if pt._shell_chip_labels[1].text != "HE 0":
		push_error("FAIL — HE chip did not refresh to '0': '%s'" % pt._shell_chip_labels[1].text)
		quit(1); return
	# AP should now be the bright one.
	var ap_bg2: Color = pt._shell_chip_bgs[0].color
	var he_bg2: Color = pt._shell_chip_bgs[1].color
	if (ap_bg2.r + ap_bg2.g + ap_bg2.b) <= (he_bg2.r + he_bg2.g + he_bg2.b):
		push_error("FAIL — selection did not move to the AP chip")
		quit(1); return
	# Empty HE chip should be dimmed (out-of-reserve).
	if pt._shell_chip_labels[1].modulate.a >= 0.9:
		push_error("FAIL — HE chip (reserve 0) not dimmed; alpha = %.2f" \
				% pt._shell_chip_labels[1].modulate.a)
		quit(1); return
	print("  chips refresh on reserve + selection change; empty HE chip dimmed")
	pt.queue_free()

	# === arc-2/3 PlayerTank: no loadout → no ShellChipsPanel.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	var hud2: CanvasLayer = pt_arc2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ShellChipsPanel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a ShellChipsPanel (regression)")
		quit(1); return
	# Also ensure the legacy ShellPanel (iter 35) is GONE — iter 300 removal.
	if hud2 != null and hud2.get_node_or_null("ShellPanel") != null:
		push_error("FAIL — legacy ShellPanel still being built (iter-300 removal regressed)")
		quit(1); return
	pt_arc2.queue_free()

	print("BREACH_HUD_OK 4-chip bottom-center shell readout reflects state; arc-2/3 HUD unaffected")
	quit(0)
