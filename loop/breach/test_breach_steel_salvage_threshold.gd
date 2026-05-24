# Arc-4 breach mode: Steel Salvage threshold regression (iter 101,
# P1-A fix from code-review-iter-100). The pre-fix code had three
# distinct edge-case failures that the existing test_breach_rulechangers
# coverage did NOT exercise:
#
#   1. **Frame-skip bug**: `if _steel_drilled == STEEL_SALVAGE_THRESHOLD`
#      uses strict equality, so a counter that jumps past THRESHOLD in
#      one frame (e.g. an Area2D scanning 2 adjacent steel tiles
#      simultaneously) would skip the refund forever. Fix: `>=` + a
#      `_salvage_paid` once-per-shot latch.
#   2. **Double-refund bug**: with `>=` alone, drilling 6 blocks would
#      refund twice (once at 3, again at 4/5/6). Fix: latch.
#   3. **Inert-steel inflation**: a body in the "steel" group without
#      a `breach()` method (defensive duck-type) still ticked the
#      counter, falsely advancing toward THRESHOLD. Fix: move the
#      increment INSIDE the `body.has_method("breach")` guard.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_steel_salvage_threshold.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


class StubPlayer extends Node:
	var loadout = null


class StubLevel extends Node2D:
	var player = null


# A node in the "steel" group with NO `breach()` method — simulates the
# defensive-duck-type path (something a future arc adds to the steel
# group but that doesn't implement the contract). Pre-fix this would
# still tick _steel_drilled.
class StubInertSteel extends Node2D:
	func _ready() -> void:
		add_to_group("steel")


func _initialize() -> void:
	# === Test A: frame-skip — counter STARTS already at THRESHOLD - 1,
	# then one steel hit takes it past THRESHOLD. With the old `==`
	# code this still fires on 3, but the fix's semantic — `>=` — also
	# fires when the increment overshoots. Use start = 2 → +1 = 3 (==
	# THRESHOLD) for the baseline path.
	if not await _run_threshold_overshoot("baseline drill=3", 0, 3, 1):
		quit(1); return
	# Overshoot: pre-seed the counter to THRESHOLD itself, then a single
	# drill takes it to THRESHOLD+1 (4). Old code's `_steel_drilled ==
	# THRESHOLD` check fires the refund DURING the first hit (counter
	# went 0→1→2→3, fires at 3), but a real-world frame-skip seeds
	# counter at 2 then jumps to 4 in one tick — pre-fix would never
	# fire. Simulate that here: pre-seed at 4 (already past), then drill
	# 1 more → counter=5; `>=` fires once.
	if not await _run_threshold_overshoot("overshoot pre-seed=4", 4, 1, 1):
		quit(1); return

	# === Test B: latch — drilling 6 real steels refunds EXACTLY 1, not
	# 2. Without the `_salvage_paid` latch, `>=` semantics would fire
	# on hits 3, 4, 5, 6 — refunding 4 APCR from one shot.
	if not await _run_threshold_overshoot("latch drill=6", 0, 6, 1):
		quit(1); return

	# === Test C: inert steel doesn't tick the counter. Drill 5 inert
	# steels (in "steel" group but no breach() method); counter must
	# stay 0, no refund. Pre-fix the counter would have ticked to 5
	# and triggered the refund (false positive).
	if not await _run_inert_steel():
		quit(1); return

	print("BREACH_STEEL_SALVAGE_THRESHOLD_OK overshoot + latch + inert-guard verified")
	quit(0)


# Build a stub-level + APCR bullet with salvage ON; pre-seed
# `_steel_drilled` then drill `drill` REAL steel blocks. Assert
# the resulting apcr_reserve delta matches `expect_refunds`.
func _run_threshold_overshoot(label: String, pre_seed: int, drill: int,
		expect_refunds: int) -> bool:
	var level := StubLevel.new()
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.apcr_reserve = 0
	lo.max_apcr_reserve = 8
	lo.steel_salvage = true
	player.loadout = lo
	level.player = player
	root.add_child(level)
	level.add_child(player)

	var bullet: Node = BulletScene.instantiate()
	level.add_child(bullet)
	await process_frame
	bullet.shell_class = BulletT.SHELL_CLASS_APCR
	bullet._steel_drilled = pre_seed

	var container := Node2D.new()
	level.add_child(container)
	for i in drill:
		var s: Node2D = SteelBlockScene.instantiate()
		s.position = Vector2(i * 8, 0)
		container.add_child(s)
	await process_frame

	for s in container.get_children():
		bullet._on_body_entered(s)
	await process_frame

	if lo.apcr_reserve != expect_refunds:
		push_error("FAIL %s — apcr_reserve = %d, want %d (pre_seed=%d, drill=%d)" \
				% [label, lo.apcr_reserve, expect_refunds, pre_seed, drill])
		level.queue_free()
		return false
	print("  %s — apcr_reserve %d → %d (pre_seed=%d, drill=%d)" \
			% [label, 0, lo.apcr_reserve, pre_seed, drill])
	level.queue_free()
	await process_frame
	return true


func _run_inert_steel() -> bool:
	var level := StubLevel.new()
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.apcr_reserve = 0
	lo.max_apcr_reserve = 8
	lo.steel_salvage = true
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
	for i in 5:
		var inert := StubInertSteel.new()
		inert.position = Vector2(i * 8, 0)
		container.add_child(inert)
	await process_frame

	for s in container.get_children():
		bullet._on_body_entered(s)
	await process_frame

	if bullet._steel_drilled != 0:
		push_error("FAIL inert-guard — _steel_drilled = %d (want 0; inert steel must not tick)" \
				% bullet._steel_drilled)
		level.queue_free()
		return false
	if lo.apcr_reserve != 0:
		push_error("FAIL inert-guard — apcr_reserve = %d (want 0; inert steel must not refund)" \
				% lo.apcr_reserve)
		level.queue_free()
		return false
	print("  inert-guard — 5 inert hits → _steel_drilled stays 0; no refund")
	level.queue_free()
	await process_frame
	return true
