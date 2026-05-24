# Arc-4 breach mode: P0-1 regression — archetype-select must pause
# the world (iter 091, fixing the iter-90 /code-review P0-1).
#
# Without the pause, enemies spawn / shoot / hit the player while
# the pick screen is up. The fix:
#   - _show_archetype_select sets paused = true
#   - PlayerTank sets self.process_mode = PROCESS_MODE_ALWAYS
#     (so it keeps polling picker input while tree paused)
#   - _exit_archetype_select (called by _pick_archetype + dead-
#     during-selector escape) unpauses + restores process_mode
#
# This harness verifies:
#   - _show_archetype_select pauses the tree
#   - PlayerTank.process_mode == PROCESS_MODE_ALWAYS while selecting
#   - A stub non-ALWAYS Node's _physics_process is NOT called while paused
#   - _pick_archetype unpauses the tree + restores PlayerTank.process_mode
#   - The dead-during-selector escape path clears the selector + unpauses
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_archetype_select_pause.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


# A stub Node2D that ticks a counter in _physics_process — used to
# verify default PROCESS_MODE_INHERIT nodes pause when tree pauses.
class _TickStub extends Node2D:
	var ticks: int = 0
	func _physics_process(_delta: float) -> void:
		ticks += 1


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Spawn PlayerTank with force_archetype_select to trigger
	# the pick-screen path on _ready.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.force_archetype_select = true
	holder.add_child(pt)
	await process_frame
	await process_frame

	# === Assertion 1: tree is paused.
	if not paused:
		push_error("FAIL — after _show_archetype_select, tree is NOT paused")
		quit(1); return
	print("  tree paused: true (after _show_archetype_select)")

	# === Assertion 2: PlayerTank.process_mode == PROCESS_MODE_ALWAYS.
	if pt.process_mode != Node.PROCESS_MODE_ALWAYS:
		push_error("FAIL — PlayerTank.process_mode %d, want PROCESS_MODE_ALWAYS (%d)" % [pt.process_mode, Node.PROCESS_MODE_ALWAYS])
		quit(1); return
	print("  PlayerTank.process_mode: PROCESS_MODE_ALWAYS (player keeps polling input)")

	# === Assertion 3: a stub PROCESS_MODE_INHERIT node does NOT tick
	# while tree paused. (Tree paused → INHERIT children pause too.)
	var stub: Node = _TickStub.new()
	holder.add_child(stub)
	# stub.process_mode default = PROCESS_MODE_INHERIT → pauses with tree
	await process_frame
	await process_frame
	if stub.ticks != 0:
		push_error("FAIL — stub Node ticked %d times while tree paused, want 0" % stub.ticks)
		quit(1); return
	print("  stub Node ticks while paused: 0 (Enemy/Spawner equivalents also blocked)")

	# === Assertion 4: _pick_archetype unpauses tree + restores
	# PlayerTank.process_mode.
	pt._pick_archetype(PlayerTankT.TankArchetype.PRISM)
	await process_frame
	if paused:
		push_error("FAIL — after _pick_archetype, tree is STILL paused")
		quit(1); return
	if pt.process_mode != Node.PROCESS_MODE_INHERIT:
		push_error("FAIL — after _pick_archetype, PlayerTank.process_mode %d, want PROCESS_MODE_INHERIT (%d)" % [pt.process_mode, Node.PROCESS_MODE_INHERIT])
		quit(1); return
	if pt._archetype_selecting:
		push_error("FAIL — after _pick_archetype, _archetype_selecting still true")
		quit(1); return
	print("  _pick_archetype: tree unpaused, process_mode INHERIT, _archetype_selecting=false")

	# === Assertion 5: stub Node DOES tick now that tree is unpaused.
	stub.ticks = 0
	await process_frame
	await process_frame
	if stub.ticks == 0:
		push_error("FAIL — stub Node still 0 ticks after tree unpaused")
		quit(1); return
	print("  stub Node resumed ticking after unpause: %d ticks" % stub.ticks)

	# === Assertion 6: dead-during-selector escape path. Re-enter
	# selector, set _dead, verify _physics_process exits selector.
	pt._show_archetype_select()
	if not paused:
		push_error("FAIL — re-enter selector: tree not paused")
		quit(1); return
	if not pt._archetype_selecting:
		push_error("FAIL — re-enter selector: _archetype_selecting not true")
		quit(1); return
	# Force _dead = true (simulate scripted death bypassing the pause).
	pt._dead = true
	# Drive _physics_process directly — the dead-during-selector branch
	# should fire _exit_archetype_select + return.
	pt._physics_process(0.05)
	if pt._archetype_selecting:
		push_error("FAIL — dead-during-selector: _archetype_selecting still true after _physics_process tick")
		quit(1); return
	if paused:
		push_error("FAIL — dead-during-selector: tree still paused after escape")
		quit(1); return
	if pt.process_mode != Node.PROCESS_MODE_INHERIT:
		push_error("FAIL — dead-during-selector: process_mode %d, want INHERIT" % pt.process_mode)
		quit(1); return
	print("  dead-during-selector escape: selector exited, tree unpaused, process_mode restored")

	holder.queue_free()
	print("BREACH_ARCHETYPE_SELECT_PAUSE_OK P0-1 fix verified — selector pauses world; pick unpauses; dead-during-selector escapes cleanly")
	quit(0)
