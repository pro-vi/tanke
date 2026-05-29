# Arc-4 breach mode: longer-shield verifier (Round 8d, iter 59).
# Verifies the playtest-3 "make shields longer" change:
#   - a breach PlayerTank's apply_shield extends the duration to
#     BREACH_SHIELD_DURATION (6s), 3x the 2s pickup default
#   - a "SHIELD" HUD indicator shows while the shield is active
#   - an arc-2/3 PlayerTank keeps the passed duration + builds no
#     breach HUD
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_shield.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === breach PlayerTank — shields last longer + a HUD indicator.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	root.add_child(pt)
	await process_frame
	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — no HUD"); quit(1); return
	var sl: Label = hud.get_node_or_null("ShieldLabel") as Label
	if sl == null:
		push_error("FAIL — breach HUD has no ShieldLabel"); quit(1); return
	if sl.visible:
		push_error("FAIL — ShieldLabel visible before any shield"); quit(1); return

	# apply_shield extends the duration in breach mode (check before a
	# frame — _physics_process decrements the timer).
	pt.apply_shield(2.0)
	if pt._shield_timer < pt.BREACH_SHIELD_DURATION - 0.001:
		push_error("FAIL — breach shield = %.2fs, want >= %.1fs" % [pt._shield_timer, pt.BREACH_SHIELD_DURATION])
		quit(1); return
	print("  breach shield: apply_shield(2.0) → %.1fs" % pt._shield_timer)

	await process_frame  # _physics_process toggles the indicator
	if not sl.visible:
		push_error("FAIL — ShieldLabel not shown while shielded"); quit(1); return
	print("  shield HUD indicator shows while shielded")
	pt.queue_free()

	# === arc-2/3 PlayerTank — shield unchanged, no breach HUD.
	var pt2: Node = PlayerTankScene.instantiate()
	root.add_child(pt2)
	await process_frame
	pt2.apply_shield(2.0)
	if pt2._shield_timer > 2.001:
		push_error("FAIL — arc-2/3 shield extended to %.2fs (regression)" % pt2._shield_timer)
		quit(1); return
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ShieldLabel") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a ShieldLabel (regression)")
		quit(1); return
	print("  arc-2/3 shield unchanged (2.0s), no breach HUD")
	pt2.queue_free()

	print("BREACH_SHIELD_OK breach shields last longer + a HUD indicator; arc-2/3 unaffected")
	quit(0)
