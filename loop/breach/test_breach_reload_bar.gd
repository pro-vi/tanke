# Arc-4 breach mode: Round 24 Phase A widget 2 — reload bar (iter 274).
#
# Phase A's goal is HUD-as-status: the player sees every existing
# system without taking action. The reload bar visualizes GunTimer
# cooldown progress as a colored rectangle that grows left → right,
# with the fg color matching the current shell class (so reload
# chrome reads as continuous with the in-flight bullet sprite).
#
# Verifies:
#   1. ReloadBarBG + ReloadBarFG ColorRects exist on the HUD when
#      loadout != null (built inside the breach-mode-gated block).
#   2. When idle (GunTimer just instantiated, never started, or
#      time_left == 0), fg width is approximately full (= bg_w − 2*inset).
#   3. After _fire arms a fresh GunTimer cycle, _update_reload_bar
#      yields a clamped 0 ≤ progress < 1.0 → fg width < max_w.
#   4. fg color follows current_shell — cycling shell changes the bar
#      color to match _shell_color(current_shell).
#   5. Procedural baseline (loadout == null) does NOT build the bar
#      (arc-2/3 HUD bit-identical contract — both fields stay null).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_reload_bar.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Case A: procedural baseline (loadout == null) — neither bar
	# field should be built. Bit-identical arc-2/3 HUD contract.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var pt_a: Node = PlayerTankScene.instantiate()
	# loadout deliberately left null
	holder_a.add_child(pt_a)
	await process_frame
	await process_frame
	if pt_a._reload_bar_bg != null or pt_a._reload_bar_fg != null:
		push_error("FAIL — procedural baseline built reload bar (must be null without loadout)")
		quit(1); return
	print("  procedural baseline: reload bar not built (loadout-gated contract holds)")
	pt_a.queue_free()
	await process_frame

	# === Case B: breach mode (loadout != null) — bar built + behaves.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	var hud: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	if hud == null:
		push_error("FAIL — PlayerTank HUD canvas not found")
		quit(1); return
	if pt._reload_bar_bg == null or pt._reload_bar_fg == null:
		push_error("FAIL — reload bar not built (expected loadout-gated build)")
		quit(1); return
	# Verify the ColorRects are children of the HUD canvas.
	var bg_on_hud: bool = false
	var fg_on_hud: bool = false
	for c in hud.get_children():
		if c == pt._reload_bar_bg:
			bg_on_hud = true
		if c == pt._reload_bar_fg:
			fg_on_hud = true
	if not bg_on_hud or not fg_on_hud:
		push_error("FAIL — reload bar ColorRects not parented to HUD")
		quit(1); return
	print("  case B: reload bar built + on HUD (bg + fg both present)")

	# Idle width = max width (no cooldown active).
	pt._update_reload_bar()
	var max_w: float = PlayerTankT.RELOAD_BAR_BG_W - 2.0 * PlayerTankT.RELOAD_BAR_INSET
	if absf(pt._reload_bar_fg.size.x - max_w) > 0.5:
		push_error("FAIL — idle reload bar fg width = %.2f, want %.2f" \
				% [pt._reload_bar_fg.size.x, max_w])
		quit(1); return
	print("  idle: fg.size.x = %.2f (= max_w %.2f, ready-to-fire visualized)" \
			% [pt._reload_bar_fg.size.x, max_w])

	# Color follows current_shell (default AP).
	var ap_color: Color = pt._shell_color(BulletT.SHELL_CLASS_AP)
	if pt._reload_bar_fg.color != ap_color:
		push_error("FAIL — default reload bar color = %s, want AP %s" \
				% [str(pt._reload_bar_fg.color), str(ap_color)])
		quit(1); return
	print("  color: matches current_shell (AP) — %s" % str(pt._reload_bar_fg.color))

	# Mid-reload: arm GunTimer with non-zero time_left, expect width < max.
	if not pt.has_node("GunTimer"):
		push_error("FAIL — PlayerTank scene missing GunTimer child")
		quit(1); return
	var gt: Timer = pt.get_node("GunTimer")
	gt.wait_time = 1.0
	gt.start()
	# Force time_left to 0.5 (50% reloaded) so the assertion is deterministic.
	# Godot Timer.start() resets time_left = wait_time; we can't directly
	# write time_left, but we can advance by sleeping... Instead, since
	# _update_reload_bar reads time_left/wait_time, we verify the formula
	# by manipulating wait_time to a value we know:
	gt.wait_time = 2.0  # if time_left ≈ 1.0 (just started but advancing) → progress < 1
	# Wait a frame so the timer actually ticks.
	await process_frame
	pt._update_reload_bar()
	if pt._reload_bar_fg.size.x >= max_w - 0.5:
		push_error("FAIL — after firing, fg width %.2f still ≈ max_w %.2f (no cooldown progress)" \
				% [pt._reload_bar_fg.size.x, max_w])
		quit(1); return
	if pt._reload_bar_fg.size.x < 0.0:
		push_error("FAIL — fg width %.2f went negative (clamp regression)" \
				% pt._reload_bar_fg.size.x)
		quit(1); return
	print("  mid-cooldown: fg.size.x = %.2f (< max_w %.2f; progress visible)" \
			% [pt._reload_bar_fg.size.x, max_w])
	gt.stop()  # clean up before color-cycle check

	# Cycle shell → color updates next tick.
	pt.current_shell = BulletT.SHELL_CLASS_HE
	pt._update_reload_bar()
	var he_color: Color = pt._shell_color(BulletT.SHELL_CLASS_HE)
	if pt._reload_bar_fg.color != he_color:
		push_error("FAIL — after current_shell=HE, fg color = %s, want HE %s" \
				% [str(pt._reload_bar_fg.color), str(he_color)])
		quit(1); return
	print("  color follows current_shell on cycle: HE %s" % str(pt._reload_bar_fg.color))

	print("BREACH_RELOAD_BAR_OK reload bar built + width + color verified")
	quit(0)
