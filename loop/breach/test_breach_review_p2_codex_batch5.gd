# arc-4 PR-#4 Codex review fix regression — Batch 5 (P2 #A + P2 #B):
#
# P2 #A — Enemy.take_damage now guards amount <= 0 before side effects.
#   Pre-fix: Bullet's S3 fix gated set_last_damage_* on deal>0 but
#   still called take_damage(0) when AP/HE hit an armored Heavy
#   (armor mitigation drives deal to 0). Enemy.take_damage only
#   short-circuited for hp<=0, so it fell through to _update_hp_bar
#   AND the iter-51 AIM_FIRE cancel block — a 0-damage hit emitted
#   `aim_canceled` and interrupted the Heavy's wind-up. Armor was
#   supposed to mean AP/HE bounce off Heavies, not "interrupt without
#   damage."
#
# P2 #B — RunRecap.format() now prints APCR shells fired.
#   Pre-fix: my P2 #3 fix added APCR to shells_fired init dict,
#   build_tag, _dry_shells_list, _format_resource_clause. But the
#   actual `shells fired` line in format() still hard-coded
#   "AP %d / HE %d / HEAT %d". An APCR-heavy run could show
#   build="steel driller" with zero APCR shots in the output.
#
# 3 cases:
#   1. Enemy.take_damage(0) is a no-op — hp unchanged, AIM_FIRE state
#      preserved, aim_canceled signal NOT emitted (Codex P2 #A lock).
#   2. Enemy.take_damage(2) on a Heavy in AIM_FIRE still cancels +
#      damages (sanity: amount > 0 path unaffected).
#   3. RunRecap.format() output contains "APCR N" for a shells_fired
#      with APCR > 0 (Codex P2 #B lock).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_review_p2_codex_batch5.gd

extends SceneTree

const EnemyScene = preload("res://scenes/Enemy.tscn")
const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Case 1: take_damage(0) is a no-op (Codex P2 #A).
	var heavy: Node = EnemyScene.instantiate()
	heavy.enemy_type = "Heavy"
	heavy.max_hp = 3
	heavy.hp = 3
	heavy.add_to_group("armored")
	root.add_child(heavy)
	await process_frame
	# Track aim_canceled signal — should NOT fire on a 0-damage hit.
	var aim_canceled_count: int = 0
	heavy.connect("aim_canceled", func(): aim_canceled_count += 1)
	# Force the Heavy into AIM_FIRE state (the iter-51 cancel block's
	# trigger). Enemy.State.AIM_FIRE is the second state.
	heavy._state = heavy.State.AIM_FIRE
	var hp_before: int = int(heavy.hp)
	heavy.take_damage(0)
	if int(heavy.hp) != hp_before:
		push_error("FAIL — take_damage(0) changed hp (%d → %d; Codex P2 #A regression)" \
				% [hp_before, int(heavy.hp)])
		quit(1); return
	if aim_canceled_count != 0:
		push_error("FAIL — take_damage(0) emitted aim_canceled %d times (want 0; Codex P2 #A regression)" \
				% aim_canceled_count)
		quit(1); return
	if heavy._state != heavy.State.AIM_FIRE:
		push_error("FAIL — take_damage(0) changed AIM_FIRE state (now %d; expected unchanged)" \
				% heavy._state)
		quit(1); return
	print("  case 1: take_damage(0) on AIM_FIRE Heavy → no damage, no aim_canceled, state preserved")

	# === Case 2: take_damage(2) still applies damage (sanity).
	# aim_canceled only fires under additional iter-101 preconditions
	# (_burst_remaining > 0 AND _burst_timer > 0.0); we don't assert it
	# here. The key invariant: damage IS applied on amount > 0.
	heavy.take_damage(2)
	if int(heavy.hp) != hp_before - 2:
		push_error("FAIL — take_damage(2) didn't apply damage (%d → %d, want %d)" \
				% [hp_before, int(heavy.hp), hp_before - 2])
		quit(1); return
	print("  case 2: take_damage(2) still applies damage (amount > 0 path unaffected)")
	heavy.queue_free()
	await process_frame

	# === Case 3: format() prints APCR (Codex P2 #B).
	var rr := RunRecapT.new()
	rr.captured = true
	rr.depth_reached = 50
	rr.killing_band = "test_band"
	rr.killing_pressure = "test"
	rr.killer = "test"
	rr.shells_fired[BulletT.SHELL_CLASS_AP] = 4
	rr.shells_fired[BulletT.SHELL_CLASS_HE] = 2
	rr.shells_fired[BulletT.SHELL_CLASS_HEAT] = 1
	rr.shells_fired[BulletT.SHELL_CLASS_APCR] = 5
	var out: String = rr.format()
	if not ("APCR 5" in out):
		push_error("FAIL — format() output missing 'APCR 5' (Codex P2 #B regression):\n%s" % out)
		quit(1); return
	if not ("AP 4" in out and "HE 2" in out and "HEAT 1" in out):
		push_error("FAIL — format() output missing AP/HE/HEAT line (regression of existing behavior):\n%s" % out)
		quit(1); return
	print("  case 3: format() prints 'AP 4 / HE 2 / HEAT 1 / APCR 5' (Codex P2 #B fix)")

	print("BREACH_REVIEW_P2_CODEX_BATCH5_OK 3 cases — take_damage(0) guard + format() APCR line")
	quit(0)
