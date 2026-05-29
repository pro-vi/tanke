# Arc-4 breach mode: shell-swap reload cost verifier (C3 anchor 4).
# Verifies the iter-27 reload beat: a real shell swap arms
# _swap_cooldown to shell_swap_cost (>=0.5s); _fire is blocked while
# the cooldown is live; once it elapses _fire emits again; an arc-2/3
# PlayerTank with no loadout never arms the cooldown.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_swap.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Breach PlayerTank: loadout with HE+HEAT so a cycle can move.
	var pt: Node = PlayerTankScene.instantiate()
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 3
	lo.heat_reserve = 2
	pt.loadout = lo
	root.add_child(pt)
	await process_frame

	# Anchor floor: the swap cost is >= 0.5s.
	if pt.shell_swap_cost < 0.5:
		push_error("FAIL — shell_swap_cost %.2f < 0.5 (anchor floor)" % pt.shell_swap_cost)
		quit(1); return

	# Pre-swap: no cooldown.
	if pt._swap_cooldown > 0.0:
		push_error("FAIL — _swap_cooldown nonzero before any swap")
		quit(1); return

	# A real swap (AP → HE) arms the reload beat.
	pt._cycle_shell()
	if pt.current_shell == BulletT.SHELL_CLASS_AP:
		push_error("FAIL — _cycle_shell did not change current_shell")
		quit(1); return
	if pt._swap_cooldown < 0.5:
		push_error("FAIL — swap did not arm cooldown (got %.2f)" % pt._swap_cooldown)
		quit(1); return
	print("  swap armed cooldown: %.2fs" % pt._swap_cooldown)

	# _fire is blocked while the reload beat is live.
	var shots: Array = []
	pt.shoot.connect(func(_b, _p, _d, _s): shots.append(1))
	pt._fire()
	if shots.size() != 0:
		push_error("FAIL — _fire emitted during the reload beat")
		quit(1); return

	# Once the beat elapses, _fire works again.
	pt._swap_cooldown = 0.0
	pt._fire()
	if shots.size() != 1:
		push_error("FAIL — _fire blocked after the reload beat elapsed (shots=%d)" % shots.size())
		quit(1); return
	print("  fire blocked mid-beat, restored after")
	pt.queue_free()

	# === arc-2/3 PlayerTank (no loadout): never arms the cooldown.
	var pt_arc2: Node = PlayerTankScene.instantiate()
	root.add_child(pt_arc2)
	await process_frame
	pt_arc2._cycle_shell()  # no-op without a loadout
	if pt_arc2._swap_cooldown != 0.0:
		push_error("FAIL — arc-2/3 PlayerTank armed a swap cooldown (regression)")
		quit(1); return
	pt_arc2.queue_free()

	print("BREACH_SWAP_OK reload beat blocks fire; arc-2/3 unaffected")
	quit(0)
