# Arc-4 Q1 sprint iter 288 (5/7 per revised blueprint):
# Q1ProofRoom.tscn playable scene + spawn-logic verification.
#
# Instantiates scenes/Q1ProofRoom.tscn, waits for _ready, then asserts
# the scene contains the expected counts of terrain/enemies/player and
# that gate-row bodies have is_route_gate=true meta (so iter-286's
# Bullet→PlayerTank→RunRecap wiring fires correctly during play).
#
# Verifies:
#   1. Scene instantiates without error.
#   2. Gate row 14 has 5 BrickBlocks (HE lane cols 0-4).
#   3. Gate row 14 has 5 SteelBlocks (APCR lane cols 5-9).
#   4. Gate row 14 has 1 Heavy enemy (HEAT lane).
#   5. Gate row 14 has 2 Light enemies (AP lane patrol).
#   6. All gate-row bodies have is_route_gate=true meta.
#   7. Exactly 1 PlayerTank spawned at HE lane's start (col 2, row 29).
#   8. PlayerTank has a loadout assigned (so HUD + RunRecap activate).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_proof_scene.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")


func _initialize() -> void:
	# === Case 1: instantiate without error.
	var room: Node = Q1ProofRoomScene.instantiate()
	if room == null:
		push_error("FAIL — Q1ProofRoom.tscn failed to instantiate")
		quit(1); return
	root.add_child(room)
	await process_frame
	await process_frame
	print("  case 1: scene instantiated; %d terrain + %d enemies + %s player" % [
		room.spawned_terrain.size(),
		room.spawned_enemies.size(),
		"1" if room.spawned_player != null else "0",
	])

	# === Case 2-5: gate-row composition matches the lane semantics.
	var gate_y_pixel: float = float(Q1ProofRoomT.GATE_ROW) * 8.0
	var gate_bricks: int = 0
	var gate_steels: int = 0
	var gate_heavies: int = 0
	var gate_lights: int = 0
	for terr in room.spawned_terrain:
		if absf(terr.position.y - gate_y_pixel) > 0.5:
			continue
		if "BrickBlock" in terr.name:
			gate_bricks += 1
		elif "SteelBlock" in terr.name:
			gate_steels += 1
	for enemy in room.spawned_enemies:
		if absf(enemy.position.y - gate_y_pixel) > 0.5:
			continue
		if enemy.enemy_type == "Heavy":
			gate_heavies += 1
		elif enemy.enemy_type == "Light":
			gate_lights += 1
	if gate_bricks != 5:
		push_error("FAIL — HE gate has %d bricks, want 5" % gate_bricks)
		quit(1); return
	if gate_steels != 5:
		push_error("FAIL — APCR gate has %d steels, want 5" % gate_steels)
		quit(1); return
	if gate_heavies != 1:
		push_error("FAIL — HEAT gate has %d heavies, want 1" % gate_heavies)
		quit(1); return
	if gate_lights != 2:
		push_error("FAIL — AP gate has %d lights, want 2" % gate_lights)
		quit(1); return
	print("  cases 2-5: gate row has %d bricks / %d steels / %d Heavy / %d Lights (lane semantics intact)" % [
		gate_bricks, gate_steels, gate_heavies, gate_lights,
	])

	# === Case 6: all gate-row bodies have is_route_gate=true meta.
	var checked: int = 0
	for terr in room.spawned_terrain:
		if absf(terr.position.y - gate_y_pixel) > 0.5:
			continue
		if not terr.has_meta("is_route_gate") or not terr.get_meta("is_route_gate"):
			push_error("FAIL — gate-row terrain '%s' missing is_route_gate=true meta" % terr.name)
			quit(1); return
		checked += 1
	for enemy in room.spawned_enemies:
		if absf(enemy.position.y - gate_y_pixel) > 0.5:
			continue
		if not enemy.has_meta("is_route_gate") or not enemy.get_meta("is_route_gate"):
			push_error("FAIL — gate-row enemy '%s' missing is_route_gate=true meta" % enemy.name)
			quit(1); return
		checked += 1
	print("  case 6: %d gate-row bodies all carry is_route_gate=true meta" % checked)

	# === Case 7: exactly 1 PlayerTank at HE lane start (col 2, row 29).
	if room.spawned_player == null:
		push_error("FAIL — no PlayerTank spawned")
		quit(1); return
	var want_player_x: float = float(Q1ProofRoomT.player_start_col("HE")) * 8.0
	var want_player_y: float = float(Q1ProofRoomT.PLAYER_START_ROW) * 8.0
	if absf(room.spawned_player.position.x - want_player_x) > 0.5 \
			or absf(room.spawned_player.position.y - want_player_y) > 0.5:
		push_error("FAIL — PlayerTank at %s, want (%s, %s)" % [
			str(room.spawned_player.position), want_player_x, want_player_y,
		])
		quit(1); return
	print("  case 7: 1 PlayerTank at HE start (col 2, row 29) → pixel (%.0f, %.0f)" % [
		want_player_x, want_player_y,
	])

	# === Case 8: PlayerTank has a loadout (HUD + RunRecap activate).
	if room.spawned_player.loadout == null:
		push_error("FAIL — PlayerTank.loadout is null; HUD + RunRecap won't activate")
		quit(1); return
	print("  case 8: PlayerTank.loadout assigned → loadout-gated breach-mode active")

	print("BREACH_Q1_PROOF_SCENE_OK 8 cases — scene + gate composition + route meta + player spawn")
	quit(0)
