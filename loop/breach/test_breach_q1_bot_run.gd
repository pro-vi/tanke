# Arc-4 iter 307 — Round 25 Probe 1 harness:
# verifies the bot-run driver's data-shape contract by replicating
# the dominant_per_lane policy inline + asserting expected outcomes.
#
# Why a per-harness replication instead of invoking the driver:
# the driver extends SceneTree and writes to tools/out/*.json which
# is the probe report path. The harness is a separate SceneTree that
# verifies the underlying calibration shape we expect the driver to
# capture. If this passes, the driver's outputs match the structural
# claims Probe 1 reports.
#
# Verifies:
#   1. dominant_per_lane policy: 1 HE shot + 1 APCR shot + 1 HEAT shot +
#      1 AP shot each at canonical gate target produces routes pattern
#      1/1/1/1 (per shell class) — the "shells as route currency"
#      identity claim at structural floor.
#   2. always_ap baseline: 4 AP shots produce routes=3 (brick + Heavy +
#      Light; steel bounces with no record) AND enemies_damage=1
#      (Light killed; Heavy mitigated to 0 dmg by armor).
#   3. The bot driver script is preloadable + has the expected
#      POLICY_NAMES + TARGETS constants.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_bot_run.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const Q1BotRunScript = preload("res://tools/q1_bot_run.gd")


func _fire_at(room: Node, shell: int, body: Node) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell
	room.add_child(b)
	b._on_body_entered(body)


func _find_terrain_at(room: Node, col: int, row: int) -> Node:
	var px: Vector2 = Q1ProofRoomT.grid_to_pixel(col, row, 8)
	for t in room.spawned_terrain:
		if t == null or not is_instance_valid(t) or t.is_queued_for_deletion():
			continue
		if absf(t.position.x - px.x) < 0.5 and absf(t.position.y - px.y) < 0.5:
			return t
	return null


func _find_enemy_at(room: Node, col: int, row: int) -> Node:
	var px: Vector2 = Q1ProofRoomT.grid_to_pixel(col, row, 8)
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		if absf(e.position.x - px.x) < 0.5 and absf(e.position.y - px.y) < 0.5:
			return e
	return null


func _initialize() -> void:
	# === Case 1: driver script constants exist + are well-formed.
	if Q1BotRunScript.POLICY_NAMES.size() != 3:
		push_error("FAIL — Q1BotRunScript.POLICY_NAMES not 3 policies (got %d)"
				% Q1BotRunScript.POLICY_NAMES.size())
		quit(1); return
	if Q1BotRunScript.TARGETS.size() != 4:
		push_error("FAIL — Q1BotRunScript.TARGETS not 4 gate cells (got %d)"
				% Q1BotRunScript.TARGETS.size())
		quit(1); return
	# AP-lane target must be col 16 (not 15) per TILE_GRID at row 14.
	var ap_target: Dictionary = Q1BotRunScript.TARGETS[3]
	if ap_target["lane"] != "AP" or ap_target["col"] != 16:
		push_error("FAIL — AP-lane target should be col 16 (per TILE_GRID gate row); got col %d"
				% ap_target["col"])
		quit(1); return
	print("  case 1: driver script preloads + has 3 policies + 4 targets + AP-lane col 16")

	# === Case 2: dominant_per_lane → routes pattern 1/1/1/1 (each shell class fires once at canonical lane).
	var room1: Node = Q1ProofRoomScene.instantiate()
	room1.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room1)
	await process_frame
	await process_frame
	var rr1 = room1.player.run_recap
	# HE lane brick
	var t_he: Node = _find_terrain_at(room1, 2, Q1ProofRoomT.GATE_ROW)
	_fire_at(room1, BulletT.SHELL_CLASS_HE, t_he)
	await process_frame
	# APCR lane steel
	var t_apcr: Node = _find_terrain_at(room1, 7, Q1ProofRoomT.GATE_ROW)
	_fire_at(room1, BulletT.SHELL_CLASS_APCR, t_apcr)
	await process_frame
	# HEAT lane Heavy
	var t_heat: Node = _find_enemy_at(room1, 12, Q1ProofRoomT.GATE_ROW)
	_fire_at(room1, BulletT.SHELL_CLASS_HEAT, t_heat)
	await process_frame
	# AP lane Light at col 16
	var t_ap: Node = _find_enemy_at(room1, 16, Q1ProofRoomT.GATE_ROW)
	_fire_at(room1, BulletT.SHELL_CLASS_AP, t_ap)
	await process_frame

	var routes_he: int = int(rr1.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HE, 0))
	var routes_apcr: int = int(rr1.shells_spent_on_routes.get(BulletT.SHELL_CLASS_APCR, 0))
	var routes_heat: int = int(rr1.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HEAT, 0))
	var routes_ap: int = int(rr1.shells_spent_on_routes.get(BulletT.SHELL_CLASS_AP, 0))
	if routes_he != 1 or routes_apcr != 1 or routes_heat != 1 or routes_ap != 1:
		push_error("FAIL — dominant_per_lane routes should be 1/1/1/1 (HE/APCR/HEAT/AP), got %d/%d/%d/%d"
				% [routes_he, routes_apcr, routes_heat, routes_ap])
		quit(1); return
	print("  case 2: dominant_per_lane routes pattern = HE 1 | APCR 1 | HEAT 1 | AP 1 (perfect lane symmetry)")
	room1.queue_free()
	await process_frame

	# === Case 3: always_ap baseline — 4 AP shots produce 3 routes (steel bounces silently)
	# AND enemies_damage=1 (Light killed; Heavy armor-mitigated to 0 dmg).
	var room2: Node = Q1ProofRoomScene.instantiate()
	room2.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room2)
	await process_frame
	await process_frame
	var rr2 = room2.player.run_recap

	# Capture pre-state for enemy damage tracking.
	var heavy_pre: Node = _find_enemy_at(room2, 12, Q1ProofRoomT.GATE_ROW)
	var heavy_max_hp: int = int(heavy_pre.max_hp) if heavy_pre != null else 0

	for t in Q1BotRunScript.TARGETS:
		var target: Node = null
		if t["kind"] == "terrain":
			target = _find_terrain_at(room2, t["col"], Q1ProofRoomT.GATE_ROW)
		else:
			target = _find_enemy_at(room2, t["col"], Q1ProofRoomT.GATE_ROW)
		if target == null:
			continue
		_fire_at(room2, BulletT.SHELL_CLASS_AP, target)
		await process_frame

	var ap_routes: int = int(rr2.shells_spent_on_routes.get(BulletT.SHELL_CLASS_AP, 0))
	if ap_routes != 3:
		push_error("FAIL — always_ap should record 3 routes (brick + Heavy + Light; steel bounces silently). Got %d"
				% ap_routes)
		quit(1); return

	# Heavy still alive after AP shot (armor mitigation → 0 dmg).
	var heavy_post: Node = _find_enemy_at(room2, 12, Q1ProofRoomT.GATE_ROW)
	if heavy_post == null:
		push_error("FAIL — Heavy should survive AP shot (armor mitigation should yield 0 dmg)")
		quit(1); return
	if int(heavy_post.hp) != heavy_max_hp:
		push_error("FAIL — Heavy hp should be unchanged (%d) after AP shot (armor mitigation); got %d"
				% [heavy_max_hp, heavy_post.hp])
		quit(1); return
	print("  case 3: always_ap baseline → AP routes=3 (steel silent) + Heavy hp unchanged (armor mitigates AP to 0)")

	# === Case 4: AP cannot breach steel (cross-pollination — the load-bearing
	# "route currency" structural claim). Steel at col 7 (APCR lane) must
	# survive an AP bounce.
	var t_steel_post: Node = _find_terrain_at(room2, 7, Q1ProofRoomT.GATE_ROW)
	if t_steel_post == null:
		push_error("FAIL — APCR-lane steel at col 7 should survive AP bounce; it's gone (cross-pollination broken)")
		quit(1); return
	print("  case 4: AP cannot breach steel (cross-pollination preserved — APCR-lane requires APCR)")
	room2.queue_free()
	await process_frame

	print("BREACH_Q1_BOT_RUN_OK 4 cases — driver constants + dominant_per_lane symmetry + always_ap baseline + AP-cannot-breach-steel")
	quit(0)
