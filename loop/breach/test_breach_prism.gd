# Arc-4 breach mode: PRISM Tank verifier (Round 9c, iter 65).
# Verifies:
#   - archetype=PRISM builds the BeamLine; DEFAULT does not.
#   - _apply_beam_to_body applies the beam's per-body-type damage rule:
#     * brick stub (take_damage, no "enemy" group) → damaged every tick
#     * enemy stub ("enemy" group + take_damage) → damaged on the
#       BEAM_DAMAGE_COOLDOWN cadence (first call damages, second call
#       within cooldown does NOT, after cooldown elapses damages again)
#     * steel-style stub (no take_damage) → no damage, no crash
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_prism.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


class StubBrick extends Node2D:
	var damage_taken: int = 0
	func take_damage(amount: int) -> void:
		damage_taken += amount


class StubEnemy extends Node2D:
	var damage_taken: int = 0
	func _ready() -> void:
		add_to_group("enemy")
	func take_damage(amount: int) -> void:
		damage_taken += amount


class StubSteel extends Node2D:
	pass  # no take_damage — beam stops here without damage


func _initialize() -> void:
	# === BeamLine built for archetype=PRISM, hidden initially.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.PRISM
	root.add_child(pt)
	await process_frame
	await process_frame  # iter-50 deferred RoutePanel build
	var beam: Line2D = pt.get_node_or_null("BeamLine") as Line2D
	if beam == null:
		push_error("FAIL — PRISM PlayerTank did not build BeamLine"); quit(1); return
	if beam.visible:
		push_error("FAIL — BeamLine visible without firing"); quit(1); return
	print("  PRISM builds BeamLine (hidden initially)")

	# DEFAULT does NOT build BeamLine.
	var pt_d: Node = PlayerTankScene.instantiate()
	pt_d.loadout = LoadoutT.new()
	pt_d.archetype = PlayerTankT.TankArchetype.DEFAULT
	root.add_child(pt_d)
	await process_frame
	await process_frame
	if pt_d.get_node_or_null("BeamLine") != null:
		push_error("FAIL — DEFAULT PlayerTank built BeamLine (regression)"); quit(1); return
	print("  DEFAULT builds no BeamLine")
	pt_d.queue_free()
	await process_frame

	# === Brick: drained over 4 cooldown ticks (iter-138 PLAYTEST-FIX
	# from user feedback — was "1 damage per cooldown tick", now
	# BEAM_DAMAGE_PER_TICK = 0.25 accumulator → 4 ticks per HP).
	# This preserves visible HP-bar drain across the beam-active
	# window. Cooldown still applies between accumulator ticks.
	var brick := StubBrick.new()
	root.add_child(brick)
	await process_frame
	pt._beam_dmg_timer = 0.0  # reset for clean cooldown trace
	# 4 ticks past cooldown each → accumulator hits 1.0 → 1 damage.
	for i in 4:
		pt._apply_beam_to_body(pt.BEAM_DAMAGE_COOLDOWN + 0.01, brick)
	if brick.damage_taken != 1:
		push_error("FAIL — brick after 4 beam ticks (each past cooldown): damage %d, want 1" % brick.damage_taken)
		quit(1); return
	# Tick within cooldown: no accumulator add.
	pt._beam_dmg_timer = pt.BEAM_DAMAGE_COOLDOWN  # arm cooldown so next call is mid-cooldown
	pt._apply_beam_to_body(0.05, brick)
	if brick.damage_taken != 1:
		push_error("FAIL — brick mid-cooldown: damage %d, want 1 (cooldown should have blocked accumulator)" % brick.damage_taken)
		quit(1); return
	print("  brick: 4 cooldown-gated ticks → 1 damage (accumulator-based; iter-138)")

	# === Enemy: drained over 4 cooldown ticks per HP.
	var enemy := StubEnemy.new()
	root.add_child(enemy)
	await process_frame
	pt._beam_dmg_timer = 0.0  # reset for clean cooldown trace
	# 4 ticks past cooldown → 1 damage.
	for i in 4:
		pt._apply_beam_to_body(pt.BEAM_DAMAGE_COOLDOWN + 0.01, enemy)
	if enemy.damage_taken != 1:
		push_error("FAIL — enemy after 4 beam ticks: damage %d, want 1" % enemy.damage_taken)
		quit(1); return
	# Tick within cooldown: no damage.
	pt._beam_dmg_timer = pt.BEAM_DAMAGE_COOLDOWN  # arm cooldown
	pt._apply_beam_to_body(0.05, enemy)
	if enemy.damage_taken != 1:
		push_error("FAIL — enemy mid-cooldown: damage %d, want 1 (cooldown should have blocked)" % enemy.damage_taken)
		quit(1); return
	# 4 more ticks past cooldown → +1 damage = 2 total.
	for i in 4:
		pt._apply_beam_to_body(pt.BEAM_DAMAGE_COOLDOWN + 0.01, enemy)
	if enemy.damage_taken != 2:
		push_error("FAIL — enemy after 8 beam ticks: damage %d, want 2" % enemy.damage_taken)
		quit(1); return
	print("  enemy: accumulator drain — 4 ticks per HP via BEAM_DAMAGE_PER_TICK=%.2f (1.0 / 0.25)" % pt.BEAM_DAMAGE_PER_TICK)

	# === Steel: no take_damage → no crash, no damage path.
	var steel := StubSteel.new()
	root.add_child(steel)
	await process_frame
	pt._beam_dmg_timer = 0.0
	pt._apply_beam_to_body(0.1, steel)
	print("  steel: beam blocks without taking damage (no crash)")
	pt.queue_free()

	print("BREACH_PRISM_OK BeamLine built on PRISM; damage rule per-body-type works")
	quit(0)
