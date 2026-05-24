# Arc-4 breach mode: P1-D regression — fire-while-swap rejection
# must produce a VISIBLE UX cue, not a silent input drop (iter 102,
# code-review-iter-100).
#
# Before the fix: `_fire` returned early when `_swap_cooldown > 0`
# (the iter-27 reload-beat enforcement) without any visual feedback.
# Player reads the missing shot as "broken input", not as "you're
# still committing to the swap." Fails CONSULT constraint 1's
# legibility spirit — the cost surface must be readable.
#
# After the fix: when `_fire` is rejected by `_swap_cooldown > 0`,
# `_flash_shell_panel_reject()` sets `_shell_panel.color` to
# `SHELL_PANEL_BG_REJECTED` (warm orange), then a tween fades it
# back to `SHELL_PANEL_BG_DEFAULT` over `SHELL_PANEL_REJECT_FADE_S`.
# Behavior unchanged (the swap-cost reload-beat is the iter-27
# design); only the silent-drop UX failure is corrected.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_fire_while_swap.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# Build PlayerTank with a loadout (so the shell panel is built).
	var pt: Node = PlayerTankScene.instantiate()
	var lo := LoadoutT.new()
	lo.he_reserve = 3
	pt.loadout = lo
	holder.add_child(pt)
	await process_frame
	await process_frame

	if pt._shell_panel == null:
		push_error("FAIL — shell panel was not built (loadout-gated; check _ready path)")
		quit(1); return

	# === Sanity: panel starts at the default dark BG.
	if pt._shell_panel.color != PlayerTankT.SHELL_PANEL_BG_DEFAULT:
		push_error("FAIL — initial _shell_panel.color = %s, want SHELL_PANEL_BG_DEFAULT" \
				% pt._shell_panel.color)
		quit(1); return
	print("  initial panel color = SHELL_PANEL_BG_DEFAULT (dark)")

	# === Arm the swap cooldown (the post-_cycle_shell state). Then
	# fire — the fix should reject + flash. Pre-fix would silently
	# drop the fire and panel color would stay at the default.
	pt._swap_cooldown = 0.5
	pt.can_shoot = true
	pt._fire()
	# Immediately inspect — the tween has not yet stepped, so the
	# panel color is at its flash-start value (SHELL_PANEL_BG_REJECTED).
	if pt._shell_panel.color != PlayerTankT.SHELL_PANEL_BG_REJECTED:
		push_error("FAIL — after rejected fire: _shell_panel.color = %s, want SHELL_PANEL_BG_REJECTED (silent-drop regression)" \
				% pt._shell_panel.color)
		quit(1); return
	print("  after rejected fire: panel flashed SHELL_PANEL_BG_REJECTED (warm orange)")

	# === Verify can_shoot is still true (the fire was rejected, not
	# consumed) — the iter-27 swap-cost reload-beat semantics must
	# hold: rejection costs a fire-attempt but does NOT arm GunTimer
	# nor consume a shell.
	if not pt.can_shoot:
		push_error("FAIL — rejected fire set can_shoot=false (would arm GunTimer + waste a tick)")
		quit(1); return
	if pt.loadout.he_reserve != 3:
		push_error("FAIL — rejected fire consumed a shell (he_reserve %d, want 3)" % pt.loadout.he_reserve)
		quit(1); return
	print("  rejected fire did NOT consume a shell nor arm GunTimer (behavior preserved)")

	# === After ~0.18s the tween should fade back to default. Step
	# enough frames for the tween to complete.
	for i in 30:
		await process_frame
	# Allow some tolerance — the tween may not land precisely on the
	# default if we don't step exactly the right number of frames,
	# but it should be in the direction of default (the red channel
	# should be much lower than SHELL_PANEL_BG_REJECTED's 1.0).
	if pt._shell_panel.color.r > 0.5:
		push_error("FAIL — panel did not fade back (color.r = %.2f after 30 frames, want < 0.5)" \
				% pt._shell_panel.color.r)
		quit(1); return
	print("  panel faded back toward default after tween (color.r = %.3f)" \
			% pt._shell_panel.color.r)

	# === Control: when `_swap_cooldown == 0`, fire is NOT rejected
	# and the panel is NOT flashed. The fire goes through normally
	# (it'll arm GunTimer + consume — verify reserve drops or
	# can_shoot flips).
	pt._swap_cooldown = 0.0
	pt.can_shoot = true
	pt._shell_panel.color = PlayerTankT.SHELL_PANEL_BG_DEFAULT
	# Direct _fire emits the `shoot` signal; without a connected
	# handler the emit is harmless. Skip if the muzzle node isn't
	# present in this minimal harness.
	if not pt.has_node("Muzzle"):
		print("  (skipping control fire — no Muzzle in instantiated PlayerTank)")
	else:
		pt._fire()
		if pt._shell_panel.color == PlayerTankT.SHELL_PANEL_BG_REJECTED:
			push_error("FAIL — control fire (no swap cooldown) wrongly flashed the panel")
			quit(1); return
		if pt.can_shoot:
			push_error("FAIL — control fire (no swap cooldown) did not arm GunTimer (can_shoot still true)")
			quit(1); return
		print("  control fire (swap_cooldown=0) — no flash; GunTimer armed normally")

	print("BREACH_FIRE_WHILE_SWAP_OK rejected fire flashes panel; behavior unchanged")
	quit(0)
