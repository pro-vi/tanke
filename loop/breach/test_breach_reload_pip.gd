# Arc-4 iter 292 (consult-001 conf 0.84 — reload bar tank-adjacent dup):
# Verifies the tank-adjacent reload pip — a smaller second reload bar
# attached as a child of PlayerTank (world-space, follows the tank).
# Tests consult prediction 2 indirectly: by duplicating the timing
# signal near the tank, the player gets a chance to use it during
# combat focus (the top-left bar is still there for static-screen reads).
#
# Verifies:
#   1. Procedural baseline (loadout == null) does NOT build the pip
#      (loadout-gated contract; arc-2/3 HUD bit-identical).
#   2. Breach mode: pip bg + fg both built as direct children of player
#      (world-space, follows tank — NOT on HUD canvas).
#   3. Pip positioned below the tank (Y offset matches RELOAD_PIP_Y).
#   4. Idle state: fg width ≈ pip full width, fg color is current_shell
#      color at LOW alpha (~0.4; ready-to-fire fade).
#   5. Mid-cooldown: fg width < full, fg color is current_shell color
#      at HIGH alpha (~1.0; eye-catching).
#   6. Shell-cycle: switching current_shell changes pip color.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_reload_pip.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Case 1: procedural baseline — pip not built.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var pt_a: Node = PlayerTankScene.instantiate()
	holder_a.add_child(pt_a)
	await process_frame
	await process_frame
	if pt_a._reload_pip_bg != null or pt_a._reload_pip_fg != null:
		push_error("FAIL — procedural baseline built reload pip (must be null without loadout)")
		quit(1); return
	print("  procedural baseline: pip not built (loadout-gated contract holds)")
	pt_a.queue_free()
	await process_frame

	# === Case 2: breach mode — pip built as direct children of player.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt._reload_pip_bg == null or pt._reload_pip_fg == null:
		push_error("FAIL — pip bg or fg null in breach mode")
		quit(1); return
	# Verify they're children of the PlayerTank (NOT on HUD canvas — world-space follow).
	var bg_on_player: bool = false
	var fg_on_player: bool = false
	for c in pt.get_children():
		if c == pt._reload_pip_bg:
			bg_on_player = true
		if c == pt._reload_pip_fg:
			fg_on_player = true
	if not bg_on_player or not fg_on_player:
		push_error("FAIL — pip ColorRects not direct children of PlayerTank (world-space follow broken)")
		quit(1); return
	print("  case 2: pip bg + fg both children of PlayerTank (world-space tank-follow)")

	# === Case 3: pip positioned below tank.
	if pt._reload_pip_bg.position.y != PlayerTankT.RELOAD_PIP_Y:
		push_error("FAIL — pip bg.position.y = %.1f, want %.1f (below tank sprite)" \
				% [pt._reload_pip_bg.position.y, PlayerTankT.RELOAD_PIP_Y])
		quit(1); return
	if pt._reload_pip_bg.position.y < 9.0:
		push_error("FAIL — pip.y = %.1f overlaps tank sprite (want ≥ 9 below tank center)" \
				% pt._reload_pip_bg.position.y)
		quit(1); return
	print("  case 3: pip Y offset = %.1f (below 16px tank sprite, clear of overlap)" \
			% pt._reload_pip_bg.position.y)

	# === Case 4: idle (GunTimer not running) → fg full width, low alpha.
	pt._update_reload_pip()
	if absf(pt._reload_pip_fg.size.x - PlayerTankT.RELOAD_PIP_W) > 0.1:
		push_error("FAIL — idle fg width = %.2f, want %.2f (full pip)" \
				% [pt._reload_pip_fg.size.x, PlayerTankT.RELOAD_PIP_W])
		quit(1); return
	if pt._reload_pip_fg.color.a > 0.5:
		push_error("FAIL — idle alpha = %.2f, want ≤ 0.5 (faint when ready-to-fire)" \
				% pt._reload_pip_fg.color.a)
		quit(1); return
	print("  idle (ready): fg full width %.1f at alpha %.2f (faint, ready-to-fire)" \
			% [pt._reload_pip_fg.size.x, pt._reload_pip_fg.color.a])

	# === Case 5: mid-cooldown → fg shorter, high alpha.
	# Arm GunTimer with non-zero time_left.
	if not pt.has_node("GunTimer"):
		push_error("FAIL — GunTimer not on PlayerTank")
		quit(1); return
	var gt: Timer = pt.get_node("GunTimer")
	gt.wait_time = 2.0
	gt.start()
	await process_frame
	pt._update_reload_pip()
	if pt._reload_pip_fg.size.x >= PlayerTankT.RELOAD_PIP_W - 0.5:
		push_error("FAIL — mid-cooldown fg width %.2f still ≈ full %.2f" \
				% [pt._reload_pip_fg.size.x, PlayerTankT.RELOAD_PIP_W])
		quit(1); return
	if pt._reload_pip_fg.color.a < 0.9:
		push_error("FAIL — mid-cooldown alpha %.2f < 0.9 (should be eye-catching)" \
				% pt._reload_pip_fg.color.a)
		quit(1); return
	print("  mid-cooldown: fg width %.2f < full, alpha %.2f (eye-catching while filling)" \
			% [pt._reload_pip_fg.size.x, pt._reload_pip_fg.color.a])
	gt.stop()

	# === Case 6: shell-cycle → pip color updates.
	pt.current_shell = BulletT.SHELL_CLASS_HE
	pt._update_reload_pip()
	var want_he: Color = pt._shell_color(BulletT.SHELL_CLASS_HE)
	if absf(pt._reload_pip_fg.color.r - want_he.r) > 0.05 \
			or absf(pt._reload_pip_fg.color.g - want_he.g) > 0.05 \
			or absf(pt._reload_pip_fg.color.b - want_he.b) > 0.05:
		push_error("FAIL — after current_shell=HE, pip color RGB = (%.2f,%.2f,%.2f), want HE (%.2f,%.2f,%.2f)" \
				% [pt._reload_pip_fg.color.r, pt._reload_pip_fg.color.g, pt._reload_pip_fg.color.b,
				   want_he.r, want_he.g, want_he.b])
		quit(1); return
	print("  shell-cycle: HE → pip RGB (%.2f, %.2f, %.2f) matches _shell_color(HE)" \
			% [pt._reload_pip_fg.color.r, pt._reload_pip_fg.color.g, pt._reload_pip_fg.color.b])

	print("BREACH_RELOAD_PIP_OK 6 cases — gated baseline / world-space children / Y offset / idle faint / mid-cd bright / shell-cycle color")
	quit(0)
