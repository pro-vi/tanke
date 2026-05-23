# Arc-4 breach mode: mid-run archetype switching verifier
# (Round 9g, iter 69). Verifies:
#   - 3 new SWITCH_TO_* UpgradeKinds exist + are distinct
#   - _upgrade_pool includes the switches at their MetaProgress tiers
#     (PRISM@20, MORTAR@40, RAM@60) — and excludes them below
#   - Depot.apply_upgrade(SWITCH_TO_*, lo) with a stub player flips
#     the player's archetype via switch_archetype
#   - Multi-switch keeps speed clean (no accumulation) — _revert_archetype
#     undoes the outgoing archetype's mods
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_archetype_switch.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")
const DepotT = preload("res://scripts/Depot.gd")


func _initialize() -> void:
	# === 3 new SWITCH_TO_* UpgradeKinds exist + distinct.
	var p: int = DepotT.UpgradeKind.SWITCH_TO_PRISM
	var m: int = DepotT.UpgradeKind.SWITCH_TO_MORTAR
	var r: int = DepotT.UpgradeKind.SWITCH_TO_RAM
	if p == m or m == r or p == r:
		push_error("FAIL — SWITCH_TO_* values not distinct (%d/%d/%d)" % [p, m, r])
		quit(1); return
	print("  UpgradeKind: SWITCH_TO_PRISM=%d, SWITCH_TO_MORTAR=%d, SWITCH_TO_RAM=%d" % [p, m, r])

	# === _upgrade_pool gates each switch by its MetaProgress tier.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	var pool_0: Array = depot._upgrade_pool(0)
	var pool_20: Array = depot._upgrade_pool(20)
	var pool_40: Array = depot._upgrade_pool(40)
	var pool_60: Array = depot._upgrade_pool(60)
	if pool_0.has(p) or pool_0.has(m) or pool_0.has(r):
		push_error("FAIL — fresh pool has a SWITCH_TO_* (should be 0 switches)"); quit(1); return
	if not pool_20.has(p) or pool_20.has(m) or pool_20.has(r):
		push_error("FAIL — pool@20 should have only SWITCH_TO_PRISM"); quit(1); return
	if not pool_40.has(p) or not pool_40.has(m) or pool_40.has(r):
		push_error("FAIL — pool@40 should have PRISM+MORTAR, not RAM"); quit(1); return
	if not pool_60.has(p) or not pool_60.has(m) or not pool_60.has(r):
		push_error("FAIL — pool@60 should have all 3 switches"); quit(1); return
	print("  switch pool gates: @0/20/40/60 → 0/1/2/3 SWITCH_TO_* entries")
	depot.queue_free()
	await process_frame

	# === apply_upgrade(SWITCH_TO_PRISM, lo) flips the player's archetype.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	# Start as DEFAULT (no explicit archetype set).
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt.archetype != PlayerTankT.TankArchetype.DEFAULT:
		push_error("FAIL — start archetype %d, want DEFAULT" % pt.archetype); quit(1); return

	var d2: Area2D = DepotScene.instantiate()
	holder.add_child(d2)
	await process_frame
	d2._player = pt
	d2._player_loadout = pt.loadout
	# Switch to PRISM.
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_PRISM, pt.loadout)
	if pt.archetype != PlayerTankT.TankArchetype.PRISM:
		push_error("FAIL — apply SWITCH_TO_PRISM: archetype %d, want PRISM" % pt.archetype)
		quit(1); return
	if pt.get_node_or_null("BeamLine") == null:
		push_error("FAIL — SWITCH_TO_PRISM did not fire _init_archetype (no BeamLine)")
		quit(1); return
	print("  apply SWITCH_TO_PRISM: archetype=PRISM + BeamLine built")

	# === Multi-switch: PRISM → RAM → MORTAR → DEFAULT. Speed bonus
	# applied and reverted cleanly (no accumulation).
	var base_speed: int = pt.speed  # currently 32 (PRISM doesn't bump)
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_RAM, pt.loadout)
	if pt.archetype != PlayerTankT.TankArchetype.RAM:
		push_error("FAIL — apply SWITCH_TO_RAM: archetype %d, want RAM" % pt.archetype)
		quit(1); return
	if pt.speed != base_speed + pt.RAM_SPEED_BONUS:
		push_error("FAIL — RAM switch: speed %d, want %d" % [pt.speed, base_speed + pt.RAM_SPEED_BONUS])
		quit(1); return
	# Switch RAM → MORTAR: speed should revert.
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_MORTAR, pt.loadout)
	if pt.archetype != PlayerTankT.TankArchetype.MORTAR:
		push_error("FAIL — apply SWITCH_TO_MORTAR: archetype %d, want MORTAR" % pt.archetype)
		quit(1); return
	if pt.speed != base_speed:
		push_error("FAIL — MORTAR after RAM: speed %d, want %d (revert)" % [pt.speed, base_speed])
		quit(1); return
	# Switch MORTAR → RAM again — speed bumps once, not stacks.
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_RAM, pt.loadout)
	if pt.speed != base_speed + pt.RAM_SPEED_BONUS:
		push_error("FAIL — RAM re-switch: speed %d, want %d (no accumulation)" % [pt.speed, base_speed + pt.RAM_SPEED_BONUS])
		quit(1); return
	print("  multi-switch: PRISM→RAM→MORTAR→RAM keeps speed clean (no accumulation)")

	# === Iter 88 (BUILD-QUALITY): _revert_archetype clears per-archetype
	# timer state — S1 (_ram_swing_timer), S2 (_beam_dmg_timer), S3
	# (GunTimer stopped + wait_time reset).
	# Prime each timer as if mid-cooldown, then switch away, then
	# check the timer is cleared.

	# RAM: prime swing timer (pretend a swing just happened).
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_RAM, pt.loadout)
	pt._ram_swing_timer = pt.RAM_SWING_COOLDOWN
	# Switch away from RAM.
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_PRISM, pt.loadout)
	if pt._ram_swing_timer != 0.0:
		push_error("FAIL — S1: _ram_swing_timer %.2f after switch FROM RAM, want 0.0" % pt._ram_swing_timer)
		quit(1); return
	print("  S1 cleared: _ram_swing_timer reset on switch FROM RAM")

	# PRISM: prime beam damage timer.
	pt._beam_dmg_timer = pt.BEAM_DAMAGE_COOLDOWN
	# Switch away from PRISM.
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_MORTAR, pt.loadout)
	if pt._beam_dmg_timer != 0.0:
		push_error("FAIL — S2: _beam_dmg_timer %.2f after switch FROM PRISM, want 0.0" % pt._beam_dmg_timer)
		quit(1); return
	print("  S2 cleared: _beam_dmg_timer reset on switch FROM PRISM")

	# MORTAR: prime GunTimer to running state, switch away, check stopped + wait_time=1.0.
	var gt2: Timer = pt.get_node("GunTimer")
	gt2.start()
	pt.can_shoot = false
	d2.apply_upgrade(DepotT.UpgradeKind.SWITCH_TO_RAM, pt.loadout)
	if not gt2.is_stopped():
		push_error("FAIL — S3: GunTimer still running after switch FROM MORTAR")
		quit(1); return
	if gt2.wait_time != 1.0:
		push_error("FAIL — S3: GunTimer.wait_time %.2f after switch FROM MORTAR, want 1.0" % gt2.wait_time)
		quit(1); return
	if not pt.can_shoot:
		push_error("FAIL — S3: can_shoot %s after switch FROM MORTAR, want true" % str(pt.can_shoot))
		quit(1); return
	print("  S3 cleared: GunTimer stopped + wait_time=1.0 + can_shoot=true on switch FROM MORTAR")

	holder.queue_free()
	print("BREACH_ARCHETYPE_SWITCH_OK 3 new SWITCH_TO_* kinds + pool gating + clean multi-switch + S1/S2/S3 timer cleanup")
	quit(0)
