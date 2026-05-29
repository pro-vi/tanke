# arc-4 PR-#4 review fix regression — Batch 1 (P2 #1 + S3 + S4):
#
# P2 #1 — Bullet._try_record_shot_hit now player-fired-only.
#   Pre-fix: enemy bullets parented under the Level resolved lvl.player
#   and credited the run-recap COMBAT/ROUTE counters with hits the
#   player never fired. Recap stats inflated under enemy fire.
#   Fix: gate on source_label == "" (player-fired default; enemy
#   bullets get "light bullet" / "heavy bullet" / "fast bullet" set by
#   Enemy._fire at iter 109).
#
# S3 — Bullet only sets last_damage_source/shell when deal > 0.
#   Pre-fix: armor mitigation can drive deal to 0 (AP/HE on armored),
#   but source/shell were still set. Recap killer attributed kills to
#   hits that did zero damage.
#   Fix: gate set_last_damage_source + set_last_damage_shell on
#   deal > 0 on both primary hit + HE splash paths.
#
# S4 — Enemy.take_beam_damage hp guard.
#   Pre-fix: no `if hp <= 0: return` mirroring take_damage's idempotency
#   guard. Latent — kill-once only held because take_damage zeroed hp
#   first. A future refactor could re-enter take_beam_damage on a dying
#   enemy.
#   Fix: add hp guard at top of take_beam_damage.
#
# 4 cases:
#   1. Player-fired bullet (source_label="") on gate-row body →
#      route hit recorded.
#   2. Enemy-fired bullet (source_label="light bullet") on gate-row body →
#      NO route hit recorded (P2 #1 regression lock).
#   3. AP on armored body (deal mitigated to 0) → set_last_damage_source
#      NOT called (S3 regression lock).
#   4. take_beam_damage on already-dying enemy (hp=0) → no-op
#      (S4 latent fragility guard).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_review_p2_batch1.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")


# MockLevel with player + run-recap-style hit tracking.
class MockLevel extends Node2D:
	var player: MockPlayer = null

	func _init() -> void:
		player = MockPlayer.new()
		add_child(player)


class MockPlayer extends Node:
	var route_hits: int = 0
	var combat_hits: int = 0

	func record_shot_hit(_shell: int, kind: String) -> void:
		if kind == "route":
			route_hits += 1
		elif kind == "combat":
			combat_hits += 1


# Body that accepts take_damage + last_damage_source. Records both.
class MockBody extends Node2D:
	var dmg_taken: int = 0
	var last_source: String = "UNSET"
	var last_shell: int = -999

	func take_damage(amount: int) -> void:
		dmg_taken += amount

	func set_last_damage_source(s: String) -> void:
		last_source = s

	func set_last_damage_shell(sc: int) -> void:
		last_shell = sc


# Armored variant for S3 case 3.
class MockArmored extends MockBody:
	func _init() -> void:
		add_to_group("armored")


func _fire_bullet(lvl: Node, shell: int, body: Node, source: String) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell
	b.source_label = source
	lvl.add_child(b)
	b._on_body_entered(body)


func _initialize() -> void:
	# === Case 1: player-fired AP at gate-row body → 1 route hit recorded.
	var lvl1 := MockLevel.new()
	root.add_child(lvl1)
	await process_frame
	var gate_body := MockBody.new()
	gate_body.set_meta("is_route_gate", true)
	lvl1.add_child(gate_body)
	await process_frame
	_fire_bullet(lvl1, BulletT.SHELL_CLASS_AP, gate_body, "")  # source="" = player
	await process_frame
	if lvl1.player.route_hits != 1:
		push_error("FAIL — player-fired AP on gate body: routes=%d (want 1)" % lvl1.player.route_hits)
		quit(1); return
	print("  case 1: player-fired bullet credits route hit on gate-row body")

	# === Case 2: enemy-fired bullet on gate-row body → NO route hit.
	var lvl2 := MockLevel.new()
	root.add_child(lvl2)
	await process_frame
	var gate_body2 := MockBody.new()
	gate_body2.set_meta("is_route_gate", true)
	lvl2.add_child(gate_body2)
	await process_frame
	# Simulate enemy fire: source_label = "light bullet"
	_fire_bullet(lvl2, BulletT.SHELL_CLASS_AP, gate_body2, "light bullet")
	await process_frame
	if lvl2.player.route_hits != 0:
		push_error("FAIL — enemy-fired bullet credited %d route hits (want 0; P2 #1 regression)" \
				% lvl2.player.route_hits)
		quit(1); return
	if lvl2.player.combat_hits != 0:
		push_error("FAIL — enemy-fired bullet credited %d combat hits (want 0)" \
				% lvl2.player.combat_hits)
		quit(1); return
	print("  case 2: enemy-fired bullet does NOT credit recap (P2 #1 regression locked)")

	# === Case 3: AP on armored body → mitigated to 0 → no source set.
	var lvl3 := MockLevel.new()
	root.add_child(lvl3)
	await process_frame
	var armored := MockArmored.new()
	lvl3.add_child(armored)
	await process_frame
	# Bullet damage=1, ARMOR_MITIGATION=1 → deal = max(0, 1-1) = 0.
	_fire_bullet(lvl3, BulletT.SHELL_CLASS_AP, armored, "")
	await process_frame
	# last_source should NOT have been set (S3 fix). UNSET sentinel survives.
	if armored.last_source != "UNSET":
		push_error("FAIL — AP-on-armored (0 dmg) set last_source='%s' (want UNSET; S3 regression)" \
				% armored.last_source)
		quit(1); return
	if armored.last_shell != -999:
		push_error("FAIL — AP-on-armored (0 dmg) set last_shell=%d (want -999 sentinel; S3 regression)" \
				% armored.last_shell)
		quit(1); return
	print("  case 3: AP on armored (deal=0) → set_last_damage_source NOT called (S3 regression locked)")

	# === Case 4: Enemy.take_beam_damage hp-guard idempotency.
	# Simulate a dying enemy: instantiate Enemy, set hp=0 directly,
	# then call take_beam_damage. The hp guard should make it a no-op.
	var enemy := EnemyScene.instantiate()
	root.add_child(enemy)
	await process_frame
	enemy.hp = 0  # already dying
	var beam_hp_pre: int = int(enemy.beam_hp)
	enemy.take_beam_damage(5)
	if int(enemy.beam_hp) != beam_hp_pre:
		push_error("FAIL — take_beam_damage on hp=0 enemy decremented beam_hp (S4 fragility regression)")
		quit(1); return
	print("  case 4: take_beam_damage(5) on hp=0 enemy → no-op (S4 fragility guard)")

	print("BREACH_REVIEW_P2_BATCH1_OK 4 cases — P2 #1 enemy-fire credit + S3 deal>0 attribution + S4 beam hp-guard")
	quit(0)
