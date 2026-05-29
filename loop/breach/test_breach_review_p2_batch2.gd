# arc-4 PR-#4 review fix regression — Batch 2 (P2 #2 + P2 #4 + S2):
#
# P2 #2 — _fire_mortar didn't stamp _last_fire_time. The reload bar
#   (_update_reload_bar per iter 297) reads _last_fire_time only, so
#   MORTAR launches showed the bar at READY throughout the 1.5s cooldown.
#   Fix: stamp _last_fire_time at the end of _fire_mortar.
#
# P2 #4 — pause-before-bail in _show_archetype_select + _show_levelup_pick.
#   Both set the gate flag + paused=true + process_mode=ALWAYS BEFORE
#   the `if canvas == null: return` early-return. If $HUD is ever
#   absent, the tree is left paused with the gate armed and no panel —
#   same shape as the P0 depot hard-lock. Robustness only (production
#   scenes always have $HUD).
#   Fix: resolve canvas + bail before mutating pause/process_mode/flags.
#
# S2 — _stop_beam reset _beam_dmg_timer = 0.0 on release, so
#   tap-and-release left the timer at 0 → next press immediately
#   applied beam damage on the first frame, bypassing
#   BEAM_DAMAGE_COOLDOWN. Fix: removed the reset; timer carries over.
#
# 4 cases:
#   1. _fire_mortar stamps _last_fire_time (P2 #2 regression lock).
#   2. _show_archetype_select with $HUD absent does NOT leave the tree
#      paused / process_mode=ALWAYS / _archetype_selecting flag set
#      (P2 #4 regression lock).
#   3. _show_levelup_pick with $HUD absent: same robustness check.
#   4. _stop_beam does NOT reset _beam_dmg_timer (S2 regression lock).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_review_p2_batch2.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _make(arch: int = -1) -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	if arch >= 0:
		pt.archetype = arch
	root.add_child(pt)
	return pt


func _initialize() -> void:
	# === Case 1: _fire_mortar stamps _last_fire_time.
	var pt1 := _make(PlayerTankT.TankArchetype.MORTAR)
	await process_frame
	# Reset stamp to far in past + ensure can_shoot (state may have
	# settled after _ready).
	pt1._last_fire_time = -100.0
	# Drive the MORTAR fire path. _fire_mortar needs a parent; pt1 is
	# already added to root, but its parent should expose a level-like
	# tree. The fire just instantiates the shell + launches.
	pt1._fire_mortar()
	# After fire, _last_fire_time should be ~now (within the last second).
	var now: float = Time.get_ticks_msec() / 1000.0
	if pt1._last_fire_time < now - 1.0 or pt1._last_fire_time > now + 0.1:
		push_error("FAIL — _fire_mortar didn't stamp _last_fire_time (got %.3f, now=%.3f; P2 #2 regression)" \
				% [pt1._last_fire_time, now])
		quit(1); return
	print("  case 1: _fire_mortar stamps _last_fire_time (%.3f vs now=%.3f; P2 #2 regression locked)" \
			% [pt1._last_fire_time, now])
	pt1.queue_free()
	await process_frame

	# === Case 2: _show_archetype_select with $HUD absent.
	# Build a PlayerTank WITHOUT $HUD by removing the node. We must
	# preserve the procedural baseline _ready hash, so build with
	# loadout=null first, remove HUD after, then re-add loadout.
	# Actually simpler: instantiate, then remove $HUD child if it exists,
	# then directly call _show_archetype_select.
	var pt2 := _make()
	await process_frame
	# Force $HUD absent to exercise the canvas == null bail path.
	if pt2.has_node("HUD"):
		pt2.get_node("HUD").queue_free()
		await process_frame
	# Snapshot pre-state.
	var paused_pre: bool = paused
	var process_mode_pre: int = pt2.process_mode
	var selecting_pre: bool = pt2._archetype_selecting
	pt2._show_archetype_select()
	if paused != paused_pre:
		push_error("FAIL — _show_archetype_select with no $HUD changed tree pause (P2 #4 regression: pause-before-bail)")
		quit(1); return
	if pt2.process_mode != process_mode_pre:
		push_error("FAIL — _show_archetype_select with no $HUD changed process_mode (P2 #4 regression)")
		quit(1); return
	if pt2._archetype_selecting != selecting_pre:
		push_error("FAIL — _show_archetype_select with no $HUD set _archetype_selecting (P2 #4 regression)")
		quit(1); return
	print("  case 2: _show_archetype_select with no $HUD → no pause/process_mode/flag mutations (P2 #4 fix)")
	pt2.queue_free()
	await process_frame

	# === Case 3: _show_levelup_pick with $HUD absent.
	var pt3 := _make()
	await process_frame
	if pt3.has_node("HUD"):
		pt3.get_node("HUD").queue_free()
		await process_frame
	var paused_pre3: bool = paused
	var process_mode_pre3: int = pt3.process_mode
	var picking_pre: bool = pt3._levelup_picking
	pt3._show_levelup_pick(2)
	if paused != paused_pre3:
		push_error("FAIL — _show_levelup_pick with no $HUD changed tree pause (P2 #4 regression)")
		quit(1); return
	if pt3.process_mode != process_mode_pre3:
		push_error("FAIL — _show_levelup_pick with no $HUD changed process_mode (P2 #4 regression)")
		quit(1); return
	if pt3._levelup_picking != picking_pre:
		push_error("FAIL — _show_levelup_pick with no $HUD set _levelup_picking (P2 #4 regression)")
		quit(1); return
	print("  case 3: _show_levelup_pick with no $HUD → no pause/process_mode/flag mutations (P2 #4 fix)")
	pt3.queue_free()
	await process_frame

	# === Case 4: _stop_beam does NOT reset _beam_dmg_timer.
	var pt4 := _make(PlayerTankT.TankArchetype.PRISM)
	await process_frame
	# Set timer to a known nonzero value, then call _stop_beam.
	pt4._beam_dmg_timer = 0.42
	pt4._stop_beam()
	if pt4._beam_dmg_timer != 0.42:
		push_error("FAIL — _stop_beam reset _beam_dmg_timer (was 0.42; now %.3f; S2 regression — tap-release would bypass cooldown)" \
				% pt4._beam_dmg_timer)
		quit(1); return
	print("  case 4: _stop_beam preserves _beam_dmg_timer (0.42 → 0.42; S2 regression locked)")

	print("BREACH_REVIEW_P2_BATCH2_OK 4 cases — P2 #2 mortar reload stamp + P2 #4 pause-before-bail + S2 beam cooldown carry-over")
	quit(0)
