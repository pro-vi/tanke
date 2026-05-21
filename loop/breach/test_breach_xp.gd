# Arc-4 breach mode: XP + level-up verifier (Round 8a, iter 56).
# Verifies the roguelite progression core (playtest-3):
#   - a breach PlayerTank builds the XP HUD (LevelLabel + XP bar)
#   - granting XP crosses level thresholds → _level rises
#   - each level-up applies an automatic stat boost, rotated across
#     max HP / reload (GunTimer) / shell capacity
#   - an arc-2/3 PlayerTank (no loadout) builds none + cannot gain XP
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_xp.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	var pt: Node = PlayerTankScene.instantiate()
	var lo: LoadoutT = LoadoutT.new()
	pt.loadout = lo
	root.add_child(pt)
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — no HUD"); quit(1); return
	var lvl_label: Label = hud.get_node_or_null("LevelLabel") as Label
	if lvl_label == null:
		push_error("FAIL — breach HUD has no LevelLabel"); quit(1); return
	if lvl_label.text != "LVL 1":
		push_error("FAIL — start level not 1: '%s'" % lvl_label.text); quit(1); return
	if hud.get_node_or_null("XPBarBG") == null or hud.get_node_or_null("XPBarFG") == null:
		push_error("FAIL — XP bar not built"); quit(1); return
	print("  XP HUD: LVL readout + bar built, start LVL 1")

	# Level 1 → 2: the first level-up grants +1 max HP.
	var hp_max0: int = pt.max_hp
	pt._grant_xp(pt.XP_BASE)
	if pt._level != 2:
		push_error("FAIL — _level = %d after XP_BASE, want 2" % pt._level); quit(1); return
	if pt.max_hp != hp_max0 + 1:
		push_error("FAIL — level 2 did not grant +1 max HP (%d → %d)" % [hp_max0, pt.max_hp]); quit(1); return
	print("  level 2 — +1 max HP (%d → %d)" % [hp_max0, pt.max_hp])

	# A big XP grant climbs several levels; the rotation must hit reload
	# (faster GunTimer) and shell capacity, not just HP.
	var reload0: float = (pt.get_node("GunTimer") as Timer).wait_time
	var cap0: int = pt.loadout.max_he_reserve
	pt._grant_xp(1000)
	if pt._level < 5:
		push_error("FAIL — _level = %d after +1000 XP, want >= 5" % pt._level); quit(1); return
	if (pt.get_node("GunTimer") as Timer).wait_time >= reload0:
		push_error("FAIL — reload never improved across level-ups"); quit(1); return
	if pt.loadout.max_he_reserve <= cap0:
		push_error("FAIL — shell capacity never improved across level-ups"); quit(1); return
	if lvl_label.text != "LVL %d" % pt._level:
		push_error("FAIL — LevelLabel stale: '%s' vs LVL %d" % [lvl_label.text, pt._level]); quit(1); return
	print("  levels rotate boosts: HP + reload + shell cap (now LVL %d)" % pt._level)
	pt.queue_free()

	# === arc-2/3 PlayerTank (no loadout) → no XP HUD, no level-ups.
	var pt2: Node = PlayerTankScene.instantiate()
	root.add_child(pt2)
	await process_frame
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("LevelLabel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a LevelLabel (regression)"); quit(1); return
	pt2._grant_xp(9999)
	if pt2._level != 1:
		push_error("FAIL — arc-2/3 PlayerTank gained levels (regression)"); quit(1); return
	pt2.queue_free()

	print("BREACH_XP_OK XP + level-up core; rotated stat boosts; arc-2/3 unaffected")
	quit(0)
