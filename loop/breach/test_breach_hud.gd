# Arc-4 breach mode: shell-panel HUD verifier (Round 5 legibility,
# iter 35 — playtest finding 1 "no shell UI").
# Verifies a breach PlayerTank (loadout set) builds a 4-slot ShellPanel
# reflecting current_shell + per-shell reserves + a selection highlight,
# and an arc-2/3 PlayerTank (no loadout) builds none — the arc-2/3 HUD
# stays bit-identical.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hud.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Breach PlayerTank: loadout set → a 4-slot ShellPanel.
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
	var panel: ColorRect = hud.get_node_or_null("ShellPanel") as ColorRect
	if panel == null:
		push_error("FAIL — breach PlayerTank has no ShellPanel")
		quit(1); return
	if pt._shell_slot_labels.size() != 4:
		push_error("FAIL — ShellPanel has %d slots, want 4" % pt._shell_slot_labels.size())
		quit(1); return

	pt._update_shell_panel()
	# Slot order: AP, HE, HEAT, APCR. Reserves: HE 3, HEAT 2, APCR 1.
	var ap_txt: String = pt._shell_slot_labels[0].text
	var he_txt: String = pt._shell_slot_labels[1].text
	var heat_txt: String = pt._shell_slot_labels[2].text
	var apcr_txt: String = pt._shell_slot_labels[3].text
	if he_txt.find("HE") == -1 or he_txt.find("3") == -1:
		push_error("FAIL — HE slot wrong: '%s'" % he_txt); quit(1); return
	if heat_txt.find("HEAT") == -1 or heat_txt.find("2") == -1:
		push_error("FAIL — HEAT slot wrong: '%s'" % heat_txt); quit(1); return
	if apcr_txt.find("APCR") == -1 or apcr_txt.find("1") == -1:
		push_error("FAIL — APCR slot wrong: '%s'" % apcr_txt); quit(1); return
	print("  slots: [%s] [%s] [%s] [%s]" % [ap_txt, he_txt, heat_txt, apcr_txt])

	# Selection highlight: the HE slot (current_shell) bg is opaque-ish;
	# the AP slot (not selected) is transparent.
	if pt._shell_slot_bgs[1].color.a <= 0.0:
		push_error("FAIL — selected (HE) slot not highlighted"); quit(1); return
	if pt._shell_slot_bgs[0].color.a > 0.0:
		push_error("FAIL — unselected (AP) slot is highlighted"); quit(1); return
	print("  selection highlight tracks current_shell")

	# Reserve + selection change is reflected on the next update.
	# (iter 44: PlayerTank duplicates its loadout at _ready — mutate
	# pt.loadout, the live per-run copy, not the passed template.)
	pt.loadout.he_reserve = 0
	pt.current_shell = BulletT.SHELL_CLASS_AP
	pt._update_shell_panel()
	if pt._shell_slot_labels[1].text.find("0") == -1:
		push_error("FAIL — HE slot did not refresh to 0: '%s'" % pt._shell_slot_labels[1].text)
		quit(1); return
	if pt._shell_slot_bgs[0].color.a <= 0.0:
		push_error("FAIL — selection did not move to the AP slot"); quit(1); return
	print("  panel refreshes on reserve + selection change")
	pt.queue_free()

	# === arc-2/3 PlayerTank: no loadout → no ShellPanel.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	var hud2: CanvasLayer = pt_arc2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ShellPanel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a ShellPanel (regression)")
		quit(1); return
	pt_arc2.queue_free()

	print("BREACH_HUD_OK 4-slot shell panel reflects state; arc-2/3 HUD unaffected")
	quit(0)
