# Arc-4 Q1 sprint 3/4 (iter 286 per blueprint loop/breach/iter-283-round24-Q1-architect.md):
# wire Bullet → PlayerTank → RunRecap route-currency hit recording.
#
# Verifies the wiring shipped this iter:
#   - Bullet._try_record_shot_hit reads body's is_route_gate meta
#   - Forwards to player.record_shot_hit(shell_class, "route"|"combat")
#   - PlayerTank.record_shot_hit delegates to run_recap.record_shot_hit
#   - Procedural / arc-2/3 path (no loadout, no run_recap) silently no-ops
#
# Verifies:
#   1. Body WITH is_route_gate=true meta → records as route hit
#   2. Body WITHOUT meta → records as combat hit
#   3. Body WITH is_route_gate=false meta → records as combat hit (defensive)
#   4. Bullet without parent.player → silent no-op (no crash)
#   5. PlayerTank without run_recap → record_shot_hit silently no-ops
#      (loadout-gated procedural baseline contract)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_route_gate_wiring.gd

extends SceneTree

const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const RunRecapT = preload("res://scripts/RunRecap.gd")


# Stub body that mimics the bits Bullet._on_body_entered touches:
# take_damage (no-op), groups (none), and meta. Created fresh per case
# so meta state doesn't leak.
class StubBody extends StaticBody2D:
	func take_damage(_amount: int) -> void:
		pass


# Fake level node mirroring Level.gd's `player` declared property —
# Bullet's `"player" in lvl` check (iter-24 _try_breach_dividend pattern)
# requires a DECLARED property, not metadata. A plain Node2D with
# set("player", ...) wouldn't satisfy `in`.
class FakeLevel extends Node2D:
	var player: Node = null


func _setup_level_with_player() -> Array:
	var lvl: FakeLevel = FakeLevel.new()
	lvl.name = "FakeLevel"
	root.add_child(lvl)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	lvl.add_child(pt)
	lvl.player = pt
	return [lvl, pt]


func _fire_bullet_at_body(lvl: Node, shell_class: int, body: Node) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell_class
	lvl.add_child(b)
	# Manually invoke the body-entered handler (bypassing physics).
	b._on_body_entered(body)
	# Note: _on_body_entered queue_frees the bullet — that's fine here.


func _initialize() -> void:
	# === Case 1: body with is_route_gate=true → route hit recorded.
	var arr1: Array = _setup_level_with_player()
	var lvl1: Node = arr1[0]
	var pt1: Node = arr1[1]
	await process_frame
	await process_frame
	var gate_body: StubBody = StubBody.new()
	gate_body.set_meta("is_route_gate", true)
	lvl1.add_child(gate_body)
	_fire_bullet_at_body(lvl1, BulletT.SHELL_CLASS_HE, gate_body)
	if pt1.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_HE] != 1:
		push_error("FAIL — case 1: route hit not recorded; got %d, want 1" \
				% pt1.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_HE])
		quit(1); return
	if pt1.run_recap.shells_spent_on_combat[BulletT.SHELL_CLASS_HE] != 0:
		push_error("FAIL — case 1: route hit leaked to combat dict")
		quit(1); return
	print("  case 1: HE bullet on is_route_gate=true body → route hit recorded")
	lvl1.queue_free()
	await process_frame

	# === Case 2: body without meta → combat hit.
	var arr2: Array = _setup_level_with_player()
	var lvl2: Node = arr2[0]
	var pt2: Node = arr2[1]
	await process_frame
	await process_frame
	var enemy_body: StubBody = StubBody.new()
	# no meta set
	lvl2.add_child(enemy_body)
	_fire_bullet_at_body(lvl2, BulletT.SHELL_CLASS_AP, enemy_body)
	if pt2.run_recap.shells_spent_on_combat[BulletT.SHELL_CLASS_AP] != 1:
		push_error("FAIL — case 2: combat hit not recorded; got %d, want 1" \
				% pt2.run_recap.shells_spent_on_combat[BulletT.SHELL_CLASS_AP])
		quit(1); return
	if pt2.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_AP] != 0:
		push_error("FAIL — case 2: combat hit leaked to routes dict")
		quit(1); return
	print("  case 2: AP bullet on untagged body → combat hit recorded")
	lvl2.queue_free()
	await process_frame

	# === Case 3: body with is_route_gate=false → combat hit (defensive).
	var arr3: Array = _setup_level_with_player()
	var lvl3: Node = arr3[0]
	var pt3: Node = arr3[1]
	await process_frame
	await process_frame
	var false_gate: StubBody = StubBody.new()
	false_gate.set_meta("is_route_gate", false)
	lvl3.add_child(false_gate)
	_fire_bullet_at_body(lvl3, BulletT.SHELL_CLASS_HEAT, false_gate)
	if pt3.run_recap.shells_spent_on_combat[BulletT.SHELL_CLASS_HEAT] != 1:
		push_error("FAIL — case 3: false-meta should record as combat; got %d" \
				% pt3.run_recap.shells_spent_on_combat[BulletT.SHELL_CLASS_HEAT])
		quit(1); return
	if pt3.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_HEAT] != 0:
		push_error("FAIL — case 3: false meta incorrectly recorded as route")
		quit(1); return
	print("  case 3: HEAT bullet on is_route_gate=false → combat hit (defensive default)")
	lvl3.queue_free()
	await process_frame

	# === Case 4: Bullet without parent.player → silent no-op.
	# Build a bare level (Node2D without FakeLevel script → no `player` property).
	var lvl4 := Node2D.new()
	root.add_child(lvl4)
	# do NOT set player — Node2D has no such declared property
	var orphan_body: StubBody = StubBody.new()
	orphan_body.set_meta("is_route_gate", true)
	lvl4.add_child(orphan_body)
	var b4: Node = BulletScene.instantiate()
	b4.shell_class = BulletT.SHELL_CLASS_APCR
	lvl4.add_child(b4)
	# Should NOT crash, even though `player` isn't on the level.
	b4._on_body_entered(orphan_body)
	print("  case 4: bullet with no parent.player → silent no-op (no crash)")
	lvl4.queue_free()
	await process_frame

	# === Case 5: PlayerTank without loadout/run_recap → silent no-op
	# (procedural / arc-2/3 baseline contract).
	var lvl5: FakeLevel = FakeLevel.new()
	root.add_child(lvl5)
	var pt5: Node = PlayerTankScene.instantiate()
	# loadout deliberately NULL — arc-2/3 baseline
	lvl5.add_child(pt5)
	lvl5.player = pt5
	await process_frame
	await process_frame
	if pt5.run_recap != null:
		push_error("FAIL — case 5: pre-condition broken — run_recap should be null without loadout")
		quit(1); return
	# Direct call to record_shot_hit must NOT crash.
	pt5.record_shot_hit(BulletT.SHELL_CLASS_HE, "route")
	print("  case 5: PlayerTank without run_recap → record_shot_hit silent no-op (no crash)")
	lvl5.queue_free()
	await process_frame

	print("BREACH_ROUTE_GATE_WIRING_OK 5 cases — route meta / no meta / false meta / no player / no run_recap")
	quit(0)
