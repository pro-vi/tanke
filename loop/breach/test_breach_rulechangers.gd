# Arc-4 breach mode: depot rule-changer verifier (Round 6c, iter 41).
# Verifies the two new rule-changer upgrades:
#   QUICK_SWAP — a real shell swap arms NO reload beat (vs the iter-27
#     default which arms shell_swap_cost).
#   STEEL_SALVAGE — an APCR shot that opens a steel cluster of
#     >=STEEL_SALVAGE_THRESHOLD blocks refunds 1 APCR, only with the
#     upgrade; the APCR analogue of Breach Dividend.
# Plus: depot apply_upgrade sets each flag.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_rulechangers.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")


class StubPlayer extends Node:
	var loadout = null


class StubLevel extends Node2D:
	var player = null


func _initialize() -> void:
	# === QUICK_SWAP: a swap with the upgrade arms no reload beat.
	var pt: Node = PlayerTankScene.instantiate()
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 3
	lo.quick_swap = true
	pt.loadout = lo
	root.add_child(pt)
	await process_frame
	pt._cycle_shell()
	if pt.current_shell == BulletT.SHELL_CLASS_AP:
		push_error("FAIL — QUICK_SWAP: _cycle_shell did not change shell")
		quit(1); return
	if pt._swap_cooldown != 0.0:
		push_error("FAIL — QUICK_SWAP: swap armed a cooldown (%.2f)" % pt._swap_cooldown)
		quit(1); return
	print("  QUICK_SWAP — real swap, no reload beat")
	pt.queue_free()

	# Control: without QUICK_SWAP a swap DOES arm the beat (iter-27 rule).
	var pt2: Node = PlayerTankScene.instantiate()
	var lo2: LoadoutT = LoadoutT.new()
	lo2.he_reserve = 3
	pt2.loadout = lo2
	root.add_child(pt2)
	await process_frame
	pt2._cycle_shell()
	if pt2._swap_cooldown < 0.5:
		push_error("FAIL — control: swap without QUICK_SWAP did not arm the beat")
		quit(1); return
	print("  control — swap without QUICK_SWAP arms the beat (%.2fs)" % pt2._swap_cooldown)
	pt2.queue_free()

	# === STEEL_SALVAGE: cluster breach refunds APCR only with the upgrade.
	if not await _run_salvage("salvage ON, 4-cluster", true, 3, 0, 1):
		quit(1); return
	if not await _run_salvage("salvage OFF, 4-cluster", false, 3, 0, 0):
		quit(1); return
	if not await _run_salvage("salvage ON, lone block", true, 0, 0, 0):
		quit(1); return

	# === depot apply_upgrade sets each rule-changer flag.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	var lo3 := LoadoutT.new()
	depot.apply_upgrade(depot.UpgradeKind.QUICK_SWAP, lo3)
	depot.apply_upgrade(depot.UpgradeKind.STEEL_SALVAGE, lo3)
	if not lo3.quick_swap or not lo3.steel_salvage:
		push_error("FAIL — apply_upgrade did not set the rule-changer flags")
		quit(1); return
	print("  apply_upgrade sets quick_swap + steel_salvage")
	depot.queue_free()

	print("BREACH_RULECHANGERS_OK QUICK_SWAP + STEEL_SALVAGE verified")
	quit(0)


# Fire an APCR shot at a steel cluster (primary + `siblings` blocks);
# verify apcr_reserve after, given the steel_salvage flag. Mirrors the
# test_breach_dividend.gd stub-Level pattern.
func _run_salvage(label: String, salvage: bool, siblings: int,
		start_apcr: int, expect_apcr: int) -> bool:
	var level := StubLevel.new()
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.apcr_reserve = start_apcr
	lo.max_apcr_reserve = 4
	lo.steel_salvage = salvage
	player.loadout = lo
	level.player = player
	root.add_child(level)
	level.add_child(player)

	var bullet: Node = BulletScene.instantiate()
	level.add_child(bullet)
	await process_frame
	bullet.shell_class = BulletT.SHELL_CLASS_APCR

	var container := Node2D.new()
	level.add_child(container)
	var primary: Node2D = SteelBlockScene.instantiate()
	primary.position = Vector2.ZERO
	container.add_child(primary)
	for i in siblings:
		var s: Node2D = SteelBlockScene.instantiate()
		s.position = Vector2(4 + i * 3, 0)
		container.add_child(s)
	await process_frame

	bullet._on_body_entered(primary)
	await process_frame

	if lo.apcr_reserve != expect_apcr:
		push_error("FAIL %s — apcr_reserve = %d, want %d" % [label, lo.apcr_reserve, expect_apcr])
		level.queue_free()
		return false
	print("  salvage: %s — apcr_reserve %d → %d" % [label, start_apcr, lo.apcr_reserve])
	level.queue_free()
	return true
