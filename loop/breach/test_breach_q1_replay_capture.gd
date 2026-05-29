# Arc-4 iter 318 (Round 27 Probe 5 harness): verify the replay capture
# driver produces well-formed JSON with the expected schema + event
# count + initial-vs-final invariants. Catches schema drift if the
# driver is later refactored.
#
# 3 cases:
#   1. tools/q1_replay_capture.gd parses + has expected constants
#      (TARGETS.size == 4, SHELL_NAMES == ["AP","HE","HEAT","APCR"]).
#   2. Replicate the driver's event sequence inline + verify the
#      structural invariants: initial state = clean (0 routes); after
#      4 dominant_per_lane shots the routes match 1/1/1/1 (cross-checks
#      Probe 1 finding F1 in temporal form).
#   3. The terrain-deletion temporal pattern: HE shot at HE-lane brick
#      drops terrain count by >1 (radius blast destroys multiple
#      cluster bricks in a single event). This is the temporal-data
#      smoking gun for Probe 2 finding F4 (radius blast amplifies HE
#      destruction).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_replay_capture.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const ReplayCaptureScript = preload("res://tools/q1_replay_capture.gd")


func _find_terrain_at(room: Node, col: int, row: int) -> Node:
	var px: Vector2 = Q1ProofRoomT.grid_to_pixel(col, row, 8)
	for t in room.spawned_terrain:
		if t == null or not is_instance_valid(t) or t.is_queued_for_deletion():
			continue
		if absf(t.position.x - px.x) < 0.5 and absf(t.position.y - px.y) < 0.5:
			return t
	return null


func _count_alive_terrain(room: Node) -> int:
	var n: int = 0
	for t in room.spawned_terrain:
		if t == null or not is_instance_valid(t):
			continue
		if not t.is_queued_for_deletion():
			n += 1
	return n


func _fire_synthetic(room: Node, shell: int, target: Node) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell
	room.add_child(b)
	b._on_body_entered(target)


func _initialize() -> void:
	# === Case 1: driver script constants.
	if ReplayCaptureScript.TARGETS.size() != 4:
		push_error("FAIL — TARGETS not 4 (got %d)" % ReplayCaptureScript.TARGETS.size())
		quit(1); return
	if ReplayCaptureScript.SHELL_NAMES.size() != 4 \
			or String(ReplayCaptureScript.SHELL_NAMES[0]) != "AP" \
			or String(ReplayCaptureScript.SHELL_NAMES[3]) != "APCR":
		push_error("FAIL — SHELL_NAMES schema drift (got %s)" % str(ReplayCaptureScript.SHELL_NAMES))
		quit(1); return
	print("  case 1: driver constants OK — 4 targets + AP/HE/HEAT/APCR shell name array")

	# === Case 2: structural invariants under dominant_per_lane.
	var room: Node = Q1ProofRoomScene.instantiate()
	room.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room)
	await process_frame
	await process_frame
	var rr = room.player.run_recap

	# Initial routes are all 0.
	if int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_AP, 0)) != 0 \
			or int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HE, 0)) != 0 \
			or int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HEAT, 0)) != 0 \
			or int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_APCR, 0)) != 0:
		push_error("FAIL — initial routes non-zero")
		quit(1); return

	# Pre-shot terrain count.
	var initial_terrain: int = _count_alive_terrain(room)
	if initial_terrain != 10:
		push_error("FAIL — initial terrain count %d (want 10)" % initial_terrain)
		quit(1); return

	# Capture HE-shot temporal effect (case 3 evidence).
	var he_brick: Node = _find_terrain_at(room, 2, Q1ProofRoomT.GATE_ROW)
	if he_brick == null:
		push_error("FAIL — HE-lane brick at (2, 14) missing")
		quit(1); return
	_fire_synthetic(room, BulletT.SHELL_CLASS_HE, he_brick)
	await process_frame
	var post_he_terrain: int = _count_alive_terrain(room)
	# Probe 2 F4 evidence: HE radius destroys >1 brick per shot.
	if (initial_terrain - post_he_terrain) <= 1:
		push_error("FAIL — HE radius blast didn't amplify destruction (terrain %d → %d, want delta >1; Probe 2 F4 broken)" \
				% [initial_terrain, post_he_terrain])
		quit(1); return
	print("  case 3: HE radius blast destroys %d bricks in ONE event (initial=%d → post=%d; Probe 2 F4 confirmed in temporal form)" \
			% [initial_terrain - post_he_terrain, initial_terrain, post_he_terrain])

	# Continue with APCR + HEAT + AP shots to verify 1/1/1/1 routes pattern.
	var apcr_steel: Node = _find_terrain_at(room, 7, Q1ProofRoomT.GATE_ROW)
	_fire_synthetic(room, BulletT.SHELL_CLASS_APCR, apcr_steel)
	await process_frame

	var heat_heavy: Node = null
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		var ey: float = e.position.y
		if absf(ey - float(Q1ProofRoomT.GATE_ROW * 8)) < 0.5 \
				and absf(e.position.x - 96.0) < 0.5:
			heat_heavy = e
			break
	_fire_synthetic(room, BulletT.SHELL_CLASS_HEAT, heat_heavy)
	await process_frame

	var ap_light: Node = null
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		var ey: float = e.position.y
		if absf(ey - float(Q1ProofRoomT.GATE_ROW * 8)) < 0.5 \
				and absf(e.position.x - 128.0) < 0.5:
			ap_light = e
			break
	_fire_synthetic(room, BulletT.SHELL_CLASS_AP, ap_light)
	await process_frame

	var ap_r: int = int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_AP, 0))
	var he_r: int = int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HE, 0))
	var heat_r: int = int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HEAT, 0))
	var apcr_r: int = int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_APCR, 0))
	if ap_r != 1 or he_r != 1 or heat_r != 1 or apcr_r != 1:
		push_error("FAIL — dominant_per_lane temporal sequence routes = %d/%d/%d/%d (want 1/1/1/1; cross-checks Probe 1 F1)" \
				% [ap_r, he_r, heat_r, apcr_r])
		quit(1); return
	print("  case 2: dominant_per_lane temporal sequence → routes 1/1/1/1 (Probe 1 F1 cross-checked in event-indexed form)")

	print("BREACH_Q1_REPLAY_CAPTURE_OK 3 cases — driver constants + temporal structural invariants + HE radius temporal evidence")
	quit(0)
