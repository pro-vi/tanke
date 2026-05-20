# Arc-4 breach mode: shell HUD verifier (round-4 legibility).
# Verifies a breach PlayerTank (loadout set) builds a ShellLabel that
# reflects current_shell + HE/HEAT reserves, and an arc-2/3 PlayerTank
# (no loadout) builds none — the arc-2/3 HUD stays bit-identical.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hud.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Breach PlayerTank: loadout set → ShellLabel exists + reflects state.
	var pt: Node = PlayerTankScene.instantiate()
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 3
	lo.heat_reserve = 2
	pt.loadout = lo
	pt.current_shell = BulletT.SHELL_CLASS_HE
	root.add_child(pt)
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — PlayerTank has no HUD CanvasLayer")
		quit(1); return
	var shell_label: Label = hud.get_node_or_null("ShellLabel") as Label
	if shell_label == null:
		push_error("FAIL — breach PlayerTank has no ShellLabel")
		quit(1); return

	# _update_run_hud runs each _physics_process; drive it once.
	pt._update_run_hud()
	var txt: String = shell_label.text
	if txt.find("HE") == -1 or txt.find("3") == -1 or txt.find("2") == -1:
		push_error("FAIL — ShellLabel does not reflect shell/reserves: '%s'" % txt)
		quit(1); return
	print("  breach HUD: '%s'" % txt)

	# Reserve change is reflected on the next update.
	lo.he_reserve = 0
	pt.current_shell = BulletT.SHELL_CLASS_AP
	pt._update_run_hud()
	if shell_label.text.find("AP") == -1 or shell_label.text.find("HE 0") == -1:
		push_error("FAIL — ShellLabel did not refresh: '%s'" % shell_label.text)
		quit(1); return
	print("  breach HUD refreshed: '%s'" % shell_label.text)
	pt.queue_free()

	# === arc-2/3 PlayerTank: no loadout → no ShellLabel.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	var hud2: CanvasLayer = pt_arc2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ShellLabel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a ShellLabel (regression)")
		quit(1); return
	pt_arc2.queue_free()

	print("BREACH_HUD_OK shell HUD reflects state; arc-2/3 HUD unaffected")
	quit(0)
