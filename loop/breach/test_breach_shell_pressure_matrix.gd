# Arc-4 iter 308 — Round 25 Probe 2 harness: locks in the canonical
# per-cell mechanics that the shell × target pressure matrix surfaces.
#
# Why this harness exists: if any future iter refactors shell-vs-target
# behavior (Bullet armor mitigation, HEAT 2x, APCR drill, HE radius),
# this catches the regression. The probe report cites these patterns as
# foundation for the "shells as route currency" identity; if the patterns
# silently change, the design's load-bearing claims drift.
#
# Six fingerprint assertions (chosen for maximum coverage with minimum
# duplication of test_breach_apcr / test_breach_q1_proof_playthrough):
#   1. AP × brick: 1 hit destroys + 1 route recorded (control case).
#   2. AP × steel: bounces — steel survives MAX hits (cross-pollination).
#   3. AP × armored heavy: 0 damage per hit (armor mitigation).
#   4. HEAT × armored heavy: 2 hits to kill (HEAT 2x damage + armor-piercing).
#   5. APCR × steel: 1 hit drills (canonical APCR verb).
#   6. HE per-cell mechanics = AP per-cell mechanics (HE radius is a
#      SCENE-LEVEL effect, not per-cell).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_shell_pressure_matrix.gd

extends SceneTree

const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const BrickBlockScene = preload("res://scenes/BrickBlock.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")
const ShellMatrixScript = preload("res://tools/shell_pressure_matrix.gd")


class MockLevel extends Node2D:
	var player: MockPlayer = null

	func _init() -> void:
		player = MockPlayer.new()
		add_child(player)


class MockPlayer extends Node:
	var route_hits: int = 0
	var combat_hits: int = 0

	func record_shot_hit(shell_class: int, hit_kind: String) -> void:
		if hit_kind == "route":
			route_hits += 1
		elif hit_kind == "combat":
			combat_hits += 1


func _fire_n(parent: Node, shell_class: int, target: Node, n: int) -> int:
	# Fire bullets one at a time, stopping early if target destroyed.
	# Returns the number of hits actually fired.
	var fired: int = 0
	while fired < n:
		if not is_instance_valid(target) or (target as Node).is_queued_for_deletion():
			break
		var b: Node = BulletScene.instantiate()
		b.shell_class = shell_class
		parent.add_child(b)
		b._on_body_entered(target)
		fired += 1
		await process_frame
	return fired


func _initialize() -> void:
	# === Case 1: AP × brick — 1 hit destroys + 1 route recorded.
	var lvl1 := MockLevel.new()
	root.add_child(lvl1)
	await process_frame
	var brick: Node = BrickBlockScene.instantiate()
	brick.set_meta("is_route_gate", true)
	lvl1.add_child(brick)
	await process_frame
	var fired1: int = await _fire_n(lvl1, BulletT.SHELL_CLASS_AP, brick, 1)
	if fired1 != 1:
		push_error("FAIL — AP×brick: fired %d (want 1)" % fired1)
		quit(1); return
	if is_instance_valid(brick) and not brick.is_queued_for_deletion():
		push_error("FAIL — AP×brick: brick survived 1 hit (want destroyed)")
		quit(1); return
	if lvl1.player.route_hits != 1:
		push_error("FAIL — AP×brick: route_hits=%d (want 1)" % lvl1.player.route_hits)
		quit(1); return
	lvl1.queue_free()
	await process_frame
	print("  case 1: AP × brick → 1 hit destroyed + 1 route recorded (control)")

	# === Case 2: AP × steel — bounces, steel survives.
	var lvl2 := MockLevel.new()
	root.add_child(lvl2)
	await process_frame
	var steel: Node = SteelBlockScene.instantiate()
	steel.set_meta("is_route_gate", true)
	lvl2.add_child(steel)
	await process_frame
	var fired2: int = await _fire_n(lvl2, BulletT.SHELL_CLASS_AP, steel, 5)
	if fired2 != 5:
		push_error("FAIL — AP×steel: should fire all 5 (steel doesn't die); got %d" % fired2)
		quit(1); return
	if not is_instance_valid(steel) or steel.is_queued_for_deletion():
		push_error("FAIL — AP×steel: steel destroyed; cross-pollination broken")
		quit(1); return
	if lvl2.player.route_hits != 0:
		push_error("FAIL — AP×steel: route_hits=%d (want 0 — steel has no take_damage)" % lvl2.player.route_hits)
		quit(1); return
	lvl2.queue_free()
	await process_frame
	print("  case 2: AP × steel → 5 hits, steel intact, 0 routes (cross-pollination preserved)")

	# === Case 3: AP × armored heavy — 0 damage per hit (armor mitigation).
	var lvl3 := MockLevel.new()
	root.add_child(lvl3)
	await process_frame
	var heavy: Node = EnemyScene.instantiate()
	(heavy as Node2D).set("enemy_type", "Heavy")
	(heavy as Node2D).set("max_hp", 3)
	(heavy as Node2D).set("hp", 3)
	(heavy as Node2D).add_to_group("armored")
	heavy.set_meta("is_route_gate", true)
	lvl3.add_child(heavy)
	await process_frame
	var fired3: int = await _fire_n(lvl3, BulletT.SHELL_CLASS_AP, heavy, 3)
	if fired3 != 3:
		push_error("FAIL — AP×heavy: should fire all 3 (heavy doesn't die from AP); got %d" % fired3)
		quit(1); return
	if not is_instance_valid(heavy) or heavy.is_queued_for_deletion():
		push_error("FAIL — AP×heavy: heavy died from AP (armor mitigation broken)")
		quit(1); return
	if int(heavy.hp) != 3:
		push_error("FAIL — AP×heavy: hp=%d after 3 AP hits (want 3 — armor mitigates AP to 0)" % heavy.hp)
		quit(1); return
	# The ledger conflation finding (Probe 1 F3): route_hits == 3 despite 0 damage.
	if lvl3.player.route_hits != 3:
		push_error("FAIL — AP×heavy: route_hits=%d (want 3 — ledger conflates consumed with damaged)" % lvl3.player.route_hits)
		quit(1); return
	lvl3.queue_free()
	await process_frame
	print("  case 3: AP × armored heavy → 3 hits, hp unchanged, but 3 routes recorded (F3 ledger conflation locked)")

	# === Case 4: HEAT × armored heavy — 2 hits kill (2x damage + armor-piercing).
	var lvl4 := MockLevel.new()
	root.add_child(lvl4)
	await process_frame
	var heavy4: Node = EnemyScene.instantiate()
	(heavy4 as Node2D).set("enemy_type", "Heavy")
	(heavy4 as Node2D).set("max_hp", 3)
	(heavy4 as Node2D).set("hp", 3)
	(heavy4 as Node2D).add_to_group("armored")
	heavy4.set_meta("is_route_gate", true)
	lvl4.add_child(heavy4)
	await process_frame
	var fired4: int = await _fire_n(lvl4, BulletT.SHELL_CLASS_HEAT, heavy4, 3)
	if fired4 != 2:
		push_error("FAIL — HEAT×heavy: should fire exactly 2 (hp 3 → 2 hits at 2 dmg = 4 dmg = dead); got %d" % fired4)
		quit(1); return
	if is_instance_valid(heavy4) and not heavy4.is_queued_for_deletion():
		push_error("FAIL — HEAT×heavy: heavy survived 2 HEAT hits (HEAT 2x broken)")
		quit(1); return
	lvl4.queue_free()
	await process_frame
	print("  case 4: HEAT × armored heavy → 2 hits kill (HEAT 2x damage + armor-piercing)")

	# === Case 5: APCR × steel — 1 hit drills (canonical APCR verb).
	var lvl5 := MockLevel.new()
	root.add_child(lvl5)
	await process_frame
	var steel5: Node = SteelBlockScene.instantiate()
	steel5.set_meta("is_route_gate", true)
	lvl5.add_child(steel5)
	await process_frame
	var fired5: int = await _fire_n(lvl5, BulletT.SHELL_CLASS_APCR, steel5, 2)
	if fired5 != 1:
		push_error("FAIL — APCR×steel: should fire exactly 1 (steel drilled in 1 hit); got %d" % fired5)
		quit(1); return
	if is_instance_valid(steel5) and not steel5.is_queued_for_deletion():
		push_error("FAIL — APCR×steel: steel survived APCR shot (drill broken)")
		quit(1); return
	if lvl5.player.route_hits != 1:
		push_error("FAIL — APCR×steel: route_hits=%d (want 1 — iter-289 drill-records-route)" % lvl5.player.route_hits)
		quit(1); return
	lvl5.queue_free()
	await process_frame
	print("  case 5: APCR × steel → 1 hit drills + 1 route recorded (canonical APCR verb)")

	# === Case 6: HE × brick == AP × brick (per-cell, no radius effect).
	var lvl6 := MockLevel.new()
	root.add_child(lvl6)
	await process_frame
	var brick6: Node = BrickBlockScene.instantiate()
	brick6.set_meta("is_route_gate", true)
	lvl6.add_child(brick6)
	await process_frame
	var fired6: int = await _fire_n(lvl6, BulletT.SHELL_CLASS_HE, brick6, 1)
	if fired6 != 1:
		push_error("FAIL — HE×brick: fired %d (want 1; per-cell HE == AP)" % fired6)
		quit(1); return
	if is_instance_valid(brick6) and not brick6.is_queued_for_deletion():
		push_error("FAIL — HE×brick: brick survived (HE on single brick should match AP)")
		quit(1); return
	lvl6.queue_free()
	await process_frame
	print("  case 6: HE × brick (single, no neighbors) == AP × brick — radius is scene-level effect")

	# === Driver sanity: shell_pressure_matrix.gd has the expected constants.
	if ShellMatrixScript.SHELL_NAMES.size() != 4:
		push_error("FAIL — driver SHELL_NAMES not 4")
		quit(1); return
	if ShellMatrixScript.TARGET_NAMES.size() != 4:
		push_error("FAIL — driver TARGET_NAMES not 4")
		quit(1); return

	print("BREACH_SHELL_PRESSURE_MATRIX_OK 6 fingerprint assertions — control + cross-pollination + ledger-conflation + HEAT 2x + APCR drill + HE=AP per-cell")
	quit(0)
