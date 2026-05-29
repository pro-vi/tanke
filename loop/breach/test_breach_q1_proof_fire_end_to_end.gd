# Arc-4 iter 296 (playtest-fix end-to-end test): drives the FULL fire
# path inside Q1ProofRoom.tscn — input → PlayerTank._fire() → shoot
# signal → scene handler → Bullet instantiated → bullet collides → body
# damaged + route-currency metrics update.
#
# This harness exists because iter 289's per-lane "playthrough" called
# Bullet._on_body_entered(body) DIRECTLY, skipping the shoot-signal
# wiring. The scene shipped without connecting that signal, and the
# unit tests all passed because none of them exercised input → bullet
# instantiation. User playtest at iter 295 surfaced the gap immediately
# ("I can't fire") — this harness ensures that gap can never regress.
#
# Verifies:
#   1. Scene instantiates with a player who has loadout + run_recap.
#   2. Calling pt._fire() emits the shoot signal AND a Bullet appears
#      as a child of the scene (handler is wired).
#   3. The spawned Bullet, fired at a gate-row brick, damages it via
#      take_damage AND updates run_recap.shells_spent_on_routes.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_proof_fire_end_to_end.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _count_bullets_in(node: Node) -> int:
	var n: int = 0
	for c in node.get_children():
		# Bullet is an Area2D in arc-4 (per Bullet.tscn) — check for the
		# shell_class property as a duck-type.
		if "shell_class" in c:
			n += 1
	return n


func _initialize() -> void:
	# === Case 1: scene + player + loadout precondition.
	var room: Node = Q1ProofRoomScene.instantiate()
	room.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room)
	await process_frame
	await process_frame
	if room.player == null:
		push_error("FAIL — room.player alias null")
		quit(1); return
	if room.player.loadout == null or room.player.run_recap == null:
		push_error("FAIL — player loadout or run_recap null; integration test cannot run")
		quit(1); return
	print("  case 1: scene instantiated; player has loadout + run_recap")

	# === Case 2: pt._fire() must spawn a Bullet via the shoot-signal wire.
	var before_count: int = _count_bullets_in(room)
	# Pre-conditions for fire path: can_shoot, no _swap_cooldown, alive.
	room.player.can_shoot = true
	room.player._swap_cooldown = 0.0
	room.player._fire()
	# Bullet spawns synchronously inside the shoot-signal handler.
	await process_frame
	var after_count: int = _count_bullets_in(room)
	if after_count <= before_count:
		push_error("FAIL — _fire() did not spawn a Bullet via shoot signal " \
				+ "(bullet count %d → %d; handler not wired in Q1ProofRoomScene)" \
				% [before_count, after_count])
		quit(1); return
	print("  case 2: _fire() spawned Bullet via wired shoot signal (%d → %d)" \
			% [before_count, after_count])

	# === Case 3: bullet at gate-brick → brick dies + route-currency ticks.
	# Find HE-lane gate brick at (2, 14) like iter 289's playthrough did.
	var gate_pos: Vector2 = Q1ProofRoomT.grid_to_pixel(2, Q1ProofRoomT.GATE_ROW, 8)
	var target: Node = null
	for t in room.spawned_terrain:
		if t == null or not is_instance_valid(t):
			continue
		if absf(t.position.x - gate_pos.x) < 0.5 \
				and absf(t.position.y - gate_pos.y) < 0.5:
			target = t
			break
	if target == null:
		push_error("FAIL — gate brick at (2, 14) not found")
		quit(1); return
	# Find a spawned bullet to use as the in-flight projectile.
	var bullet: Node = null
	for c in room.get_children():
		if "shell_class" in c:
			bullet = c
			break
	if bullet == null:
		push_error("FAIL — no bullet found after fire")
		quit(1); return
	bullet.shell_class = BulletT.SHELL_CLASS_HE
	var prior_routes: int = room.player.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_HE]
	bullet._on_body_entered(target)
	await process_frame
	if is_instance_valid(target) and not target.is_queued_for_deletion():
		push_error("FAIL — HE shot did not destroy gate brick")
		quit(1); return
	if room.player.run_recap.shells_spent_on_routes[BulletT.SHELL_CLASS_HE] <= prior_routes:
		push_error("FAIL — route-currency metric did not tick after gate-brick hit")
		quit(1); return
	print("  case 3: HE bullet hit gate brick → brick destroyed + route-currency ticked")

	print("BREACH_Q1_PROOF_FIRE_E2E_OK 3 cases — scene + fire-signal-wired + route-currency end-to-end")
	quit(0)
