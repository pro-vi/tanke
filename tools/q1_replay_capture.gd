# Arc-4 iter 318 (Round 27 Probe 5): Q1 replay capture driver.
#
# Records per-EVENT state during a deterministic dominant_per_lane bot
# run through Q1ProofRoom. Each "event" = one bot shot at one gate
# target. Records pre/post state around each shot:
#   - event_idx, target_lane, target_col, shell_class
#   - pre_state: target_hp, shells_spent_on_routes per class, terrain_alive_count
#   - post_state: same keys
# Plus a final summary snapshot.
#
# **Honest naming note**: this is an EVENT-indexed timeseries, not a
# frame-indexed one. The synthetic-fire approach (mirrors iter-307
# q1_bot_run.gd + iter-289 test_breach_q1_proof_playthrough.gd) bypasses
# real-time physics; calling per-frame "replay" would overclaim. The
# data is still useful: it shows what each shot DID, in order, with
# observable state deltas.
#
# Future Phase B+ could swap synthetic-fire for a real-time physics
# replay (PlayerTank._input_dir + GunTimer awaits + 60Hz tick loop)
# producing per-frame data. Deferred until user re-engages.
#
# Run with:
#   godot --headless --path . --script res://tools/q1_replay_capture.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")

# Targets and shell selection match iter-307 q1_bot_run.gd
# dominant_per_lane policy.
const TARGETS: Array = [
	{"col": 2,  "lane": "HE",   "kind": "terrain", "shell": 1},  # HE
	{"col": 7,  "lane": "APCR", "kind": "terrain", "shell": 3},  # APCR
	{"col": 12, "lane": "HEAT", "kind": "enemy",   "shell": 2},  # HEAT
	{"col": 16, "lane": "AP",   "kind": "enemy",   "shell": 0},  # AP
]

const SHELL_NAMES: Array = ["AP", "HE", "HEAT", "APCR"]


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


func _count_alive_terrain(room: Node) -> int:
	var n: int = 0
	for t in room.spawned_terrain:
		if t == null or not is_instance_valid(t):
			continue
		if t.is_queued_for_deletion():
			continue
		n += 1
	return n


func _count_alive_enemies(room: Node) -> int:
	var n: int = 0
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e):
			continue
		if e.is_queued_for_deletion():
			continue
		n += 1
	return n


func _routes_snapshot(rr) -> Dictionary:
	return {
		"AP":   int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_AP, 0)),
		"HE":   int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HE, 0)),
		"HEAT": int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_HEAT, 0)),
		"APCR": int(rr.shells_spent_on_routes.get(BulletT.SHELL_CLASS_APCR, 0)),
	}


func _fire_synthetic(room: Node, shell: int, target: Node) -> void:
	var b: Node = BulletScene.instantiate()
	b.shell_class = shell
	room.add_child(b)
	b._on_body_entered(target)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tools/out")

	var room: Node = Q1ProofRoomScene.instantiate()
	room.enable_enemy_ai = false  # PR-#4 Codex P2 opt-out: keep enemies inert for deterministic probe/harness
	root.add_child(room)
	await process_frame
	await process_frame

	var rr = room.player.run_recap
	var events: Array = []

	# Initial snapshot before any shots.
	var initial: Dictionary = {
		"event_idx": -1,
		"phase": "initial_state",
		"terrain_alive": _count_alive_terrain(room),
		"enemies_alive": _count_alive_enemies(room),
		"routes": _routes_snapshot(rr),
		"player_position": {"x": room.player.position.x, "y": room.player.position.y},
	}
	events.append(initial)

	# Per-event recording — synthetic-fire each TARGET in order.
	for i in TARGETS.size():
		var t: Dictionary = TARGETS[i]
		var target: Node = null
		if t["kind"] == "terrain":
			target = _find_terrain_at(room, t["col"], Q1ProofRoomT.GATE_ROW)
		else:
			target = _find_enemy_at(room, t["col"], Q1ProofRoomT.GATE_ROW)

		# PRE-STATE (before this shot).
		var target_hp_pre: int = -1
		if target != null and "hp" in target:
			target_hp_pre = int(target.hp)
		var pre_state: Dictionary = {
			"event_idx": i,
			"phase": "pre_shot",
			"target_lane": t["lane"],
			"target_col": t["col"],
			"target_kind": t["kind"],
			"shell_class": SHELL_NAMES[t["shell"]],
			"target_present": target != null,
			"target_hp": target_hp_pre,
			"terrain_alive": _count_alive_terrain(room),
			"enemies_alive": _count_alive_enemies(room),
			"routes": _routes_snapshot(rr),
		}
		events.append(pre_state)

		# Fire.
		if target != null:
			_fire_synthetic(room, t["shell"], target)
			await process_frame

		# POST-STATE.
		var target_hp_post: int = -1
		var target_destroyed: bool = false
		if target == null or not is_instance_valid(target) or (target as Node).is_queued_for_deletion():
			target_destroyed = true
		else:
			if "hp" in target:
				target_hp_post = int(target.hp)
		var post_state: Dictionary = {
			"event_idx": i,
			"phase": "post_shot",
			"target_lane": t["lane"],
			"target_col": t["col"],
			"shell_class": SHELL_NAMES[t["shell"]],
			"target_destroyed": target_destroyed,
			"target_hp": target_hp_post,
			"terrain_alive": _count_alive_terrain(room),
			"enemies_alive": _count_alive_enemies(room),
			"routes": _routes_snapshot(rr),
		}
		events.append(post_state)

	# Final summary.
	var final: Dictionary = {
		"event_idx": TARGETS.size(),
		"phase": "final_summary",
		"terrain_alive": _count_alive_terrain(room),
		"enemies_alive": _count_alive_enemies(room),
		"routes": _routes_snapshot(rr),
		"combat": {
			"AP":   int(rr.shells_spent_on_combat.get(BulletT.SHELL_CLASS_AP, 0)),
			"HE":   int(rr.shells_spent_on_combat.get(BulletT.SHELL_CLASS_HE, 0)),
			"HEAT": int(rr.shells_spent_on_combat.get(BulletT.SHELL_CLASS_HEAT, 0)),
			"APCR": int(rr.shells_spent_on_combat.get(BulletT.SHELL_CLASS_APCR, 0)),
		},
	}
	events.append(final)

	# Write JSON.
	var out_path: String = "res://tools/out/q1_replay_dominant_per_lane.json"
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("FAIL — could not write %s" % out_path)
		quit(1); return
	var payload: Dictionary = {
		"policy": "dominant_per_lane",
		"capture_mode": "event_indexed_synthetic_fire",
		"events": events,
	}
	f.store_string(JSON.stringify(payload, "  "))
	f.close()

	print("Q1_REPLAY_CAPTURE_OK %d events (1 initial + 4 pre/post pairs + 1 final = 10) — output to tools/out/q1_replay_dominant_per_lane.json" % events.size())
	for e in events:
		var phase: String = String(e["phase"])
		if phase == "initial_state":
			print("  event[-1] initial: terrain=%d enemies=%d routes=%s" % [e["terrain_alive"], e["enemies_alive"], e["routes"]])
		elif phase == "pre_shot":
			print("  event[%d] pre  lane=%s shell=%s target_hp=%d terrain=%d enemies=%d" % [
				e["event_idx"], e["target_lane"], e["shell_class"], e["target_hp"],
				e["terrain_alive"], e["enemies_alive"]])
		elif phase == "post_shot":
			print("  event[%d] post lane=%s shell=%s destroyed=%s target_hp=%d terrain=%d enemies=%d routes=%s" % [
				e["event_idx"], e["target_lane"], e["shell_class"],
				str(e["target_destroyed"]), e["target_hp"],
				e["terrain_alive"], e["enemies_alive"], e["routes"]])
		else:
			print("  final: terrain=%d enemies=%d routes=%s combat=%s" % [
				e["terrain_alive"], e["enemies_alive"], e["routes"], e["combat"]])

	quit(0)
