# Arc-4 breach mode: Round 24 Phase A widget 1 v1 — shell chips (iter 276).
#
# A compact top-left row showing the 4 shell classes (AP/HE/HEAT/APCR)
# with the currently-selected class rendered at full saturation and the
# others dimmed. Reserve counts shown for HE/HEAT/APCR; AP shows "AP".
# Procedural V1 (palette-aligned ColorRects); /agentify icons may swap
# in via a CAPABILITY iter later.
#
# Verifies:
#   1. Procedural baseline (loadout == null) does NOT build the chip row.
#   2. Breach mode (loadout != null) builds 4 chip bgs + 4 chip labels.
#   3. Reserve labels read live from the loadout (HE=6/HEAT=3/APCR=4
#      defaults from Loadout.gd; AP shows "AP" string).
#   4. The currently-selected chip's bg is at full saturation; others
#      are dimmed (selected_brightness > non_selected_brightness ratio).
#   5. After current_shell = SHELL_CLASS_HE, the HE chip is full and
#      the AP chip dims (highlight follows the cycle).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_shell_chips.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _brightness(c: Color) -> float:
	return c.r + c.g + c.b


func _initialize() -> void:
	# === Case A: procedural baseline — chip row not built.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var pt_a: Node = PlayerTankScene.instantiate()
	holder_a.add_child(pt_a)
	await process_frame
	await process_frame
	if not pt_a._shell_chip_bgs.is_empty():
		push_error("FAIL — procedural baseline built shell chips (must be empty without loadout)")
		quit(1); return
	if pt_a._shell_chips_panel != null:
		push_error("FAIL — procedural baseline built _shell_chips_panel (must be null without loadout)")
		quit(1); return
	print("  procedural baseline: shell chips not built (loadout-gated contract holds)")
	pt_a.queue_free()
	await process_frame

	# === Case B: breach mode — 4 chips + 4 labels.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt._shell_chip_bgs.size() != 4:
		push_error("FAIL — expected 4 chip bgs, got %d" % pt._shell_chip_bgs.size())
		quit(1); return
	if pt._shell_chip_labels.size() != 4:
		push_error("FAIL — expected 4 chip labels, got %d" % pt._shell_chip_labels.size())
		quit(1); return
	# All chip bgs should have the expected size.
	for i in 4:
		var bg: ColorRect = pt._shell_chip_bgs[i]
		if absf(bg.size.x - PlayerTankT.SHELL_CHIP_W) > 0.5 \
				or absf(bg.size.y - PlayerTankT.SHELL_CHIP_H) > 0.5:
			push_error("FAIL — chip %d size = %s, want %sx%s" \
					% [i, str(bg.size), PlayerTankT.SHELL_CHIP_W, PlayerTankT.SHELL_CHIP_H])
			quit(1); return
	print("  case B: 4 chip bgs + 4 labels, sizes match constants")

	# === Case C: reserve labels match loadout state (iter 300 WoT-style:
	# "AP --" / "HE 6" / "HEAT 3" / "APCR 4" — full shell-name + reserve,
	# matching the legacy tray semantics now that the tray is removed).
	pt.loadout.he_reserve = 6
	pt.loadout.heat_reserve = 3
	pt.loadout.apcr_reserve = 4
	pt._update_shell_chips()
	if pt._shell_chip_labels[0].text != "AP --":
		push_error("FAIL — AP chip label = '%s', want 'AP --'" % pt._shell_chip_labels[0].text)
		quit(1); return
	if pt._shell_chip_labels[1].text != "HE 6":
		push_error("FAIL — HE chip label = '%s', want 'HE 6'" % pt._shell_chip_labels[1].text)
		quit(1); return
	if pt._shell_chip_labels[2].text != "HEAT 3":
		push_error("FAIL — HEAT chip label = '%s', want 'HEAT 3'" % pt._shell_chip_labels[2].text)
		quit(1); return
	if pt._shell_chip_labels[3].text != "APCR 4":
		push_error("FAIL — APCR chip label = '%s', want 'APCR 4'" % pt._shell_chip_labels[3].text)
		quit(1); return
	print("  reserve labels match loadout state: AP --/HE 6/HEAT 3/APCR 4")

	# === Case D: selected chip is full-bright; others are dimmed.
	pt.current_shell = BulletT.SHELL_CLASS_AP
	pt._update_shell_chips()
	var bright_ap: float = _brightness(pt._shell_chip_bgs[0].color)
	var dim_he: float = _brightness(pt._shell_chip_bgs[1].color)
	if bright_ap <= dim_he + 0.1:
		push_error("FAIL — selected AP brightness %.2f not greater than HE dim %.2f" \
				% [bright_ap, dim_he])
		quit(1); return
	print("  selected AP brightness %.2f > dim HE %.2f (highlight visible)" % [bright_ap, dim_he])

	# === Case E: cycling current_shell to HE flips the highlight.
	pt.current_shell = BulletT.SHELL_CLASS_HE
	pt._update_shell_chips()
	var dim_ap: float = _brightness(pt._shell_chip_bgs[0].color)
	var bright_he: float = _brightness(pt._shell_chip_bgs[1].color)
	if bright_he <= dim_ap + 0.1:
		push_error("FAIL — after cycle, HE brightness %.2f not greater than dim AP %.2f" \
				% [bright_he, dim_ap])
		quit(1); return
	print("  cycle → HE: HE brightness %.2f > dim AP %.2f (highlight follows cycle)" \
			% [bright_he, dim_ap])

	print("BREACH_SHELL_CHIPS_OK shell chips built + reserves + selection highlight verified")
	quit(0)
