# Arc-4 iter 307 (Round 25 Probe 1): Q1 headless bot run driver.
#
# Drives Q1ProofRoom under 3 fixed bot policies and writes per-policy
# JSON to tools/out/q1_bot_run_<policy>.json. Each policy fires at the
# same 4 gate targets (HE brick, APCR steel, HEAT Heavy, AP-lane Light)
# but selects shell class differently. Per-policy stats captured:
#   shells_fired_per_class, shells_spent_on_routes, shells_spent_on_combat,
#   terrain_destroyed_at_gate_row, enemies_killed, enemies_total_damage,
#   bot_finished_cleanly.
#
# Synthetic fire approach (mirrors loop/breach/test_breach_q1_proof_playthrough.gd
# precedent at iter 289): instantiates Bullet directly, calls
# _on_body_entered. The iter-296 e2e fire harness already validates the
# full PlayerTank._fire → emit shoot → bullet.start → physics path; this
# probe focuses on calibration data shape, not wiring re-verification.
#
# Run with:
#   godot --headless --path . --script res://tools/q1_bot_run.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")

# 0=ALWAYS_AP, 1=ROUND_ROBIN, 2=DOMINANT_PER_LANE.
const POLICY_NAMES: Array = ["always_ap", "round_robin", "dominant_per_lane"]

# Gate targets the bot will attempt to breach. (col, row) match
# Q1ProofRoomT.TILE_GRID at GATE_ROW (14). The 4 lanes:
#   HE   — brick at (2,  14)
#   APCR — steel at (7,  14)
#   HEAT — Heavy at (12, 14)
#   AP   — Light at (15, 14)
const TARGETS: Array = [
	{"col": 2,  "lane": "HE",   "kind": "terrain"},
	{"col": 7,  "lane": "APCR", "kind": "terrain"},
	{"col": 12, "lane": "HEAT", "kind": "enemy"},
	{"col": 16, "lane": "AP",   "kind": "enemy"},  # gate row col 16 is the AP-lane Light per TILE_GRID
]


func _shell_for_policy(policy: int, lane: String, shot_idx: int) -> int:
	if policy == 0:
		return BulletT.SHELL_CLASS_AP
	if policy == 1:
		var cycle: Array[int] = [
			BulletT.SHELL_CLASS_AP,
			BulletT.SHELL_CLASS_HE,
			BulletT.SHELL_CLASS_HEAT,
			BulletT.SHELL_CLASS_APCR,
		]
		return cycle[shot_idx % 4]
	# policy 2: dominant per lane
	match lane:
		"HE":
			return BulletT.SHELL_CLASS_HE
		"APCR":
			return BulletT.SHELL_CLASS_APCR
		"HEAT":
			return BulletT.SHELL_CLASS_HEAT
		_:
			return BulletT.SHELL_CLASS_AP


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


func _fire_synthetic(room: Node, shell: int, target: Node) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell
	room.add_child(b)
	b._on_body_entered(target)


func _shell_name(c: int) -> String:
	if c == BulletT.SHELL_CLASS_AP:
		return "AP"
	if c == BulletT.SHELL_CLASS_HE:
		return "HE"
	if c == BulletT.SHELL_CLASS_HEAT:
		return "HEAT"
	if c == BulletT.SHELL_CLASS_APCR:
		return "APCR"
	return "UNK"


func _run_policy(policy: int) -> Dictionary:
	var room: Node = Q1ProofRoomScene.instantiate()
	room.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room)
	await process_frame
	await process_frame

	# Snapshot initial gate-row population BEFORE policy fires so we
	# can compute lanes_breached even after bricks queue_free.
	var gate_y: float = float(Q1ProofRoomT.GATE_ROW * 8)
	var initial_gate_terrain_ids: Array = []
	for ter in room.spawned_terrain:
		if ter == null or not is_instance_valid(ter):
			continue
		if absf(ter.position.y - gate_y) < 4.5:
			initial_gate_terrain_ids.append(ter.get_instance_id())
	var initial_gate_terrain_count: int = initial_gate_terrain_ids.size()

	# Snapshot initial enemy state BEFORE policy fires so post-policy
	# damage attribution survives queue_free.
	var initial_enemy_max_hp: Dictionary = {}  # instance_id → max_hp
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e):
			continue
		initial_enemy_max_hp[e.get_instance_id()] = int(e.max_hp)

	# Initialize shell-fire counters per shell-class int (0..3).
	var fired: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0}
	var shots_taken: int = 0
	var shots_missed_target_gone: int = 0
	var per_shot_log: Array = []

	for i in TARGETS.size():
		var t: Dictionary = TARGETS[i]
		var target: Node = null
		if t["kind"] == "terrain":
			target = _find_terrain_at(room, t["col"], Q1ProofRoomT.GATE_ROW)
		else:
			target = _find_enemy_at(room, t["col"], Q1ProofRoomT.GATE_ROW)
		if target == null:
			shots_missed_target_gone += 1
			per_shot_log.append({
				"target_lane": t["lane"],
				"target_col": t["col"],
				"shell": null,
				"hit": false,
				"reason": "target_already_gone",
			})
			continue
		var shell: int = _shell_for_policy(policy, t["lane"], shots_taken)
		_fire_synthetic(room, shell, target)
		fired[shell] += 1
		shots_taken += 1
		per_shot_log.append({
			"target_lane": t["lane"],
			"target_col": t["col"],
			"shell": _shell_name(shell),
			"hit": true,
		})
		await process_frame

	var run_recap = room.player.run_recap
	var routes: Dictionary = run_recap.shells_spent_on_routes.duplicate()
	var combat: Dictionary = run_recap.shells_spent_on_combat.duplicate()

	# Count gate-row blocks destroyed: compare initial snapshot vs
	# post-policy state. A block is "destroyed" if its instance id
	# from the snapshot is no longer valid OR is queued_for_deletion.
	var gate_row_destroyed: int = 0
	for ter_id in initial_gate_terrain_ids:
		var inst: Object = instance_from_id(ter_id)
		if inst == null:
			gate_row_destroyed += 1
		elif (inst as Node).is_queued_for_deletion():
			gate_row_destroyed += 1

	# Enemy stats: snapshot-based — track each enemy's max_hp from
	# initial snapshot; count "killed" if its instance is gone or
	# queued_for_deletion; sum damage by comparing max_hp to current hp.
	var enemies_killed: int = 0
	var enemies_total_damage: int = 0
	for e_id in initial_enemy_max_hp:
		var inst: Object = instance_from_id(e_id)
		var max_hp_snapshot: int = int(initial_enemy_max_hp[e_id])
		if inst == null:
			enemies_killed += 1
			enemies_total_damage += max_hp_snapshot
			continue
		var node: Node = inst as Node
		if node.is_queued_for_deletion():
			enemies_killed += 1
			enemies_total_damage += max_hp_snapshot
			continue
		if int(node.hp) < max_hp_snapshot:
			enemies_total_damage += int(max_hp_snapshot - node.hp)

	var stats: Dictionary = {
		"policy": POLICY_NAMES[policy],
		"shells_fired_per_class": {
			"AP":   fired[BulletT.SHELL_CLASS_AP],
			"HE":   fired[BulletT.SHELL_CLASS_HE],
			"HEAT": fired[BulletT.SHELL_CLASS_HEAT],
			"APCR": fired[BulletT.SHELL_CLASS_APCR],
		},
		"shells_spent_on_routes": {
			"AP":   int(routes.get(BulletT.SHELL_CLASS_AP, 0)),
			"HE":   int(routes.get(BulletT.SHELL_CLASS_HE, 0)),
			"HEAT": int(routes.get(BulletT.SHELL_CLASS_HEAT, 0)),
			"APCR": int(routes.get(BulletT.SHELL_CLASS_APCR, 0)),
		},
		"shells_spent_on_combat": {
			"AP":   int(combat.get(BulletT.SHELL_CLASS_AP, 0)),
			"HE":   int(combat.get(BulletT.SHELL_CLASS_HE, 0)),
			"HEAT": int(combat.get(BulletT.SHELL_CLASS_HEAT, 0)),
			"APCR": int(combat.get(BulletT.SHELL_CLASS_APCR, 0)),
		},
		"gate_row_initial_block_count": initial_gate_terrain_count,
		"gate_row_blocks_destroyed_this_run": gate_row_destroyed,
		"enemies_killed": enemies_killed,
		"enemies_total_damage_dealt": enemies_total_damage,
		"shots_taken": shots_taken,
		"shots_skipped_target_missing": shots_missed_target_gone,
		"per_shot_log": per_shot_log,
		"bot_finished_cleanly": true,
	}

	room.queue_free()
	await process_frame
	return stats


func _initialize() -> void:
	# Ensure output dir exists.
	DirAccess.make_dir_recursive_absolute("res://tools/out")

	var all_stats: Array = []
	for policy in 3:
		var stats: Dictionary = await _run_policy(policy)
		all_stats.append(stats)
		var out_path: String = "res://tools/out/q1_bot_run_%s.json" % POLICY_NAMES[policy]
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f == null:
			push_error("FAIL — could not open %s for write" % out_path)
			quit(1)
			return
		f.store_string(JSON.stringify(stats, "  "))
		f.close()
		print("  policy %s: shots_taken=%d  fired=%s  routes=%s  combat=%s  enemies_killed=%d  damage=%d" % [
			POLICY_NAMES[policy],
			stats["shots_taken"],
			stats["shells_fired_per_class"],
			stats["shells_spent_on_routes"],
			stats["shells_spent_on_combat"],
			stats["enemies_killed"],
			stats["enemies_total_damage_dealt"],
		])

	# Aggregate file for easy table comparison.
	var agg_path: String = "res://tools/out/q1_bot_run_all.json"
	var fa := FileAccess.open(agg_path, FileAccess.WRITE)
	if fa == null:
		push_error("FAIL — could not open %s for write" % agg_path)
		quit(1)
		return
	fa.store_string(JSON.stringify(all_stats, "  "))
	fa.close()

	print("Q1_BOT_RUN_OK 3 policies — output to tools/out/q1_bot_run_{policy}.json + q1_bot_run_all.json")
	quit(0)
