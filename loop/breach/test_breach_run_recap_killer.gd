# Arc-4 breach mode: Round 12 Phase 3 — RunRecap.killer must
# reflect the actual damage source, not the "shell impact"
# placeholder (iter 109, Gap 2 from iter-106 diagnosis).
#
# Before the fix: PlayerTank.take_damage was source-blind; the
# fatal hit's source was lost. RunRecap.killer stayed at the
# "shell impact" default. Recap's "killed by" line was a
# placeholder — fails CONSULT constraint 6's "tied to resource/
# build/route" standard.
#
# After the fix:
#   - Bullet.source_label is set by Enemy._fire to "light bullet" /
#     "heavy bullet" / "fast bullet" depending on enemy_type.
#   - Bullet._on_body_entered calls body.set_last_damage_source
#     just before take_damage (method-existence-gated, so arc-2/3
#     bodies are no-ops).
#   - PlayerTank.set_last_damage_source stores in
#     _last_damage_source.
#   - PlayerTank._die stamps run_recap.killer with that string
#     (fallback to "shell impact" preserved when empty).
#
# Verifies:
#   1. Light enemy bullet kill → killer = "light bullet"
#   2. Heavy enemy bullet kill → killer = "heavy bullet"
#   3. No source set (legacy damage path) → killer stays
#      "shell impact" (placeholder fallback)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_killer.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Test 1: light bullet kill stamps "light bullet".
	if not await _run_kill_test("light bullet", "light bullet"):
		quit(1); return

	# === Test 2: heavy bullet kill stamps "heavy bullet".
	if not await _run_kill_test("heavy bullet", "heavy bullet"):
		quit(1); return

	# === Test 3: legacy take_damage (no source set) → "shell impact" fallback.
	if not await _run_legacy_kill_test():
		quit(1); return

	print("BREACH_RUN_RECAP_KILLER_OK kill-source attribution verified for light/heavy bullets + fallback")
	quit(0)


# Build a PlayerTank in breach mode (loadout != null → run_recap
# created). Spawn a Bullet tagged with `source_label`, fire it at
# the player via _on_body_entered (bypasses physics), assert the
# resulting run_recap.killer matches `expected_killer`.
func _run_kill_test(source_label: String, expected_killer: String) -> bool:
	var holder: Node = root.get_child(0)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.max_hp = 1  # set HP=1 so a single shot kills
	holder.add_child(pt)
	await process_frame
	await process_frame
	pt.hp = 1  # in case _ready reset it
	# Spawn the bullet at the player.
	var bullet: Node = BulletScene.instantiate()
	holder.add_child(bullet)
	await process_frame
	bullet.source_label = source_label
	bullet.damage = 1
	# Drive the damage path: bullet hits player.
	bullet._on_body_entered(pt)
	await process_frame
	# Player should be dead with run_recap.killer stamped.
	if not pt._dead:
		push_error("FAIL %s — player not dead after 1-damage hit (hp=%d)" % [source_label, pt.hp])
		holder.remove_child(pt); pt.queue_free(); return false
	if pt.run_recap == null:
		push_error("FAIL %s — run_recap is null after death (breach mode should create it)" % source_label)
		holder.remove_child(pt); pt.queue_free(); return false
	if pt.run_recap.killer != expected_killer:
		push_error("FAIL %s — run_recap.killer = '%s', want '%s'" \
				% [source_label, pt.run_recap.killer, expected_killer])
		holder.remove_child(pt); pt.queue_free(); return false
	print("  %s → killer = '%s'" % [source_label, pt.run_recap.killer])
	holder.remove_child(pt); pt.queue_free()
	await process_frame
	return true


# Direct take_damage(N) call (no source set) → killer stays
# "shell impact" (the placeholder fallback for damage paths that
# don't yet propagate a source).
func _run_legacy_kill_test() -> bool:
	var holder: Node = root.get_child(0)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.max_hp = 1
	holder.add_child(pt)
	await process_frame
	await process_frame
	pt.hp = 1
	pt.take_damage(1)  # legacy path — no set_last_damage_source first
	await process_frame
	if not pt._dead:
		push_error("FAIL legacy — player not dead after take_damage(1)")
		holder.remove_child(pt); pt.queue_free(); return false
	if pt.run_recap == null:
		push_error("FAIL legacy — run_recap is null")
		holder.remove_child(pt); pt.queue_free(); return false
	if pt.run_recap.killer != "shell impact":
		push_error("FAIL legacy — killer = '%s', want 'shell impact' (placeholder fallback)" \
				% pt.run_recap.killer)
		holder.remove_child(pt); pt.queue_free(); return false
	print("  legacy take_damage → killer = 'shell impact' (placeholder fallback)")
	holder.remove_child(pt); pt.queue_free()
	await process_frame
	return true
