# Arc-4 breach mode: P2-B regression — _show_pickup_toast must
# stagger Y offset so multi-level-up XP bursts don't pile toasts
# at the same position (iter 104, code-review-iter-100).
#
# Before the fix: every toast spawned at (140, 28); a big XP burst
# crossing 2-3 levels in one tick called _apply_level_boost per
# level, each calling _show_pickup_toast → toasts stacked
# overlapping. Reduces legibility of the moment-to-moment HUD
# events (CONSULT constraint 6 spirit — readable run signals).
#
# After the fix: each toast's Y is TOAST_BASE_Y + 12 * live_count,
# capped at TOAST_STAGGER_MAX (4). Toasts tagged with the
# `is_pickup_toast` meta key so the live count is accurate.
#
# Verifies:
#   1. 1st toast → y = 28 (base)
#   2. 2nd toast → y = 40 (base + 12 * 1)
#   3. 3rd toast → y = 52 (base + 12 * 2)
#   4. After all fade + free (simulated by killing the toasts),
#      next toast starts again at y = 28.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_toast_stagger.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


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
		push_error("FAIL — PlayerTank HUD canvas not found")
		quit(1); return

	# === Spawn 3 toasts in rapid succession (synchronous; no awaits
	# between spawns, so the tween hasn't stepped + nothing has fired
	# queue_free callbacks).
	pt._show_pickup_toast("LEVEL 2  +1 MAX HP", Color.WHITE)
	pt._show_pickup_toast("LEVEL 3  FASTER RELOAD", Color.WHITE)
	pt._show_pickup_toast("LEVEL 4  +SHELL CAP", Color.WHITE)

	# Collect toast Y positions (filter by our meta key).
	var ys: Array[float] = []
	for child in hud.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			ys.append((child as Label).position.y)
	# Tweens may have stepped — find a clean way: just check the
	# expected count + that they are all distinct.
	if ys.size() != 3:
		push_error("FAIL — expected 3 toasts on HUD, found %d" % ys.size())
		quit(1); return
	ys.sort()
	# After 3 spawns the Y values should be at 28, 40, 52 BEFORE the
	# tween starts moving them toward 16. They may have stepped a
	# bit, but they should still be distinct (no two share the same
	# spawn Y).
	for i in ys.size() - 1:
		if absf(ys[i + 1] - ys[i]) < 6.0:
			push_error("FAIL — toasts at Y=%s are too close (stacking regressed)" % str(ys))
			quit(1); return
	print("  3 rapid toasts staggered: y values = %s (distinct)" % str(ys))

	# === Verify the stagger pattern matches the formula: y diffs
	# should be ~TOAST_STAGGER_PX (12) before any tween motion. The
	# tween moves them toward 16, so post-step values may differ
	# slightly — accept ±3 px tolerance.
	for i in ys.size() - 1:
		var diff: float = ys[i + 1] - ys[i]
		if absf(diff - PlayerTankT.TOAST_STAGGER_PX) > 3.0:
			push_error("FAIL — toast Y diff = %.1f, want ~%.1f (TOAST_STAGGER_PX)" \
					% [diff, PlayerTankT.TOAST_STAGGER_PX])
			quit(1); return
	print("  Y diffs match TOAST_STAGGER_PX (~12 px between toasts)")

	# === Free all toasts immediately, then spawn one more — should
	# return to base Y (the live count is now 0).
	for child in hud.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			child.queue_free()
	await process_frame
	pt._show_pickup_toast("LEVEL 5  +1 MAX HP", Color.WHITE)
	var fresh_y: float = -1.0
	for child in hud.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			if not child.is_queued_for_deletion():
				fresh_y = (child as Label).position.y
				break
	if absf(fresh_y - PlayerTankT.TOAST_BASE_Y) > 3.0:
		push_error("FAIL — after clearing toasts, new toast y = %.1f, want ~%.1f (BASE_Y)" \
				% [fresh_y, PlayerTankT.TOAST_BASE_Y])
		quit(1); return
	print("  after clearing live toasts, next toast restarts at BASE_Y (%.1f)" % fresh_y)

	print("BREACH_TOAST_STAGGER_OK toast stagger + live-count restart verified")
	quit(0)
