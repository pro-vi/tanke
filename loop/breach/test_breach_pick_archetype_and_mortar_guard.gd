# Arc-4 breach mode: P1-2 + P1-6 regression — _pick_archetype now
# routes through switch_archetype (P1-2) + MortarShell._explode
# guards against freed parent (P1-6).
#
# P1-2: latent today (start-pick is always from DEFAULT), but if a
#   future caller invokes _pick_archetype from a non-DEFAULT state,
#   the old direct-assignment path would leak per-archetype mods.
# P1-6: MortarShell in flight when scene reloads → parent freed →
#   _explode crashes on add_child.
#
# Verifies:
#   P1-2:
#   - Force archetype = RAM externally (bypassing switch_archetype),
#     simulate _archetype_initialized = true (as if init already ran),
#     speed += RAM_SPEED_BONUS manually.
#   - Then enter selector + _pick_archetype(DEFAULT).
#   - Verify: _revert_archetype ran for RAM (speed back to base),
#     archetype = DEFAULT, selector exited cleanly.
#   P1-6:
#   - Instantiate MortarShell, queue_free its parent, await frames.
#   - Call _explode — must not crash.
#   - Verify no children added to the (now freed) parent.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_pick_archetype_and_mortar_guard.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === P1-2: _pick_archetype from non-DEFAULT state must revert.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.RAM  # simulate non-DEFAULT pre-pick
	holder.add_child(pt)
	await process_frame
	await process_frame
	# After _ready, _init_archetype ran for RAM → speed += RAM_SPEED_BONUS.
	var base_speed: int = 32  # PlayerTank.speed default
	var ram_boosted_speed: int = base_speed + pt.RAM_SPEED_BONUS
	if pt.speed != ram_boosted_speed:
		push_error("FAIL — RAM start: speed %d, want %d (base + RAM_SPEED_BONUS)" % [pt.speed, ram_boosted_speed])
		quit(1); return
	print("  RAM start: speed=%d (base %d + RAM_SPEED_BONUS %d)" % [pt.speed, base_speed, pt.RAM_SPEED_BONUS])

	# Force-reopen selector + pick DEFAULT.
	pt._show_archetype_select()
	pt._pick_archetype(PlayerTankT.TankArchetype.DEFAULT)
	await process_frame

	# After _pick_archetype routes through switch_archetype, _revert_archetype
	# for RAM should have subtracted RAM_SPEED_BONUS.
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — after _pick_archetype(DEFAULT): archetype %d, want DEFAULT" % pt.archetype)
		quit(1); return
	if pt.speed != base_speed:
		push_error("FAIL — after RAM→DEFAULT via _pick_archetype: speed %d, want %d (RAM bonus not reverted — P1-2 fix didn't work)" % [pt.speed, base_speed])
		quit(1); return
	if pt._archetype_selecting:
		push_error("FAIL — after _pick_archetype: _archetype_selecting still true")
		quit(1); return
	if paused:
		push_error("FAIL — after _pick_archetype: tree still paused")
		quit(1); return
	print("  _pick_archetype(DEFAULT) from RAM: speed reverted to base %d, archetype=DEFAULT, selector exited" % pt.speed)

	# === P1-6: MortarShell._explode against a freed parent must not crash.
	var orphan_parent: Node2D = Node2D.new()
	holder.add_child(orphan_parent)
	var shell: Node = MortarShellScene.instantiate()
	shell.position = Vector2.ZERO
	orphan_parent.add_child(shell)
	await process_frame

	# Now free the parent; shell becomes orphan after frame.
	orphan_parent.queue_free()
	await process_frame
	await process_frame
	# The shell node is auto-freed with the parent in Godot — so we
	# can't test shell._explode() directly. INSTEAD: simulate the
	# specific failure (shell exists, parent freed). Create a fresh
	# shell + manually set its parent_node reference via reparent
	# trickery... actually since Godot auto-frees children, the
	# real scenario is: _physics_process fires once more while
	# scene-reload begins. We can simulate by giving the shell a
	# fresh parent we then free WHILE the shell tries to _explode.

	# Re-construct: fresh parent, fresh shell, queue_free parent
	# BUT call _explode on the shell BEFORE the deferred free completes.
	var parent2: Node2D = Node2D.new()
	holder.add_child(parent2)
	var shell2: Node = MortarShellScene.instantiate()
	shell2.position = Vector2.ZERO
	parent2.add_child(shell2)
	await process_frame
	# Queue free the parent; shell2 will also be queued.
	parent2.queue_free()
	# But call _explode BEFORE the queue_free is processed (this frame).
	# get_parent() should still return parent2 (queued for deletion).
	shell2._explode()
	# If we reach here without crash, the guard works.
	print("  MortarShell._explode after parent.queue_free (queued-for-deletion): no crash")

	# Verify no burst child was added to the queued parent.
	# parent2.get_children() should NOT contain a new ColorRect burst
	# (since _explode early-returned via the is_queued_for_deletion guard).
	var burst_count: int = 0
	for child in parent2.get_children():
		if child is ColorRect:
			burst_count += 1
	if burst_count > 0:
		push_error("FAIL — burst added to queued-for-deletion parent: count %d, want 0" % burst_count)
		quit(1); return
	print("  no ColorRect burst added to queued-for-deletion parent (guard early-returned correctly)")

	# Let the deferred frees run.
	await process_frame
	await process_frame

	holder.queue_free()
	print("BREACH_PICK_ARCHETYPE_AND_MORTAR_GUARD_OK P1-2 (_pick_archetype reverts) + P1-6 (MortarShell parent guard) both verified")
	quit(0)
