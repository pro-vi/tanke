# arc-4 PR-#4 Codex P2 review fix regression — Q1ProofRoom enemy
# player-link.
#
# Q1ProofRoomScene._ready spawns enemies (in _spawn_grid) BEFORE the
# player (in _spawn_player). Enemy._ready captures `_player` via
# get_node_or_null("PlayerTank") and caches the result. With grid-then-
# player order, the lookup returns null, and _physics_process returns
# forever at the null guard → every enemy in the proof room is inert
# (no movement, no aim, no firing) instead of exercising the lane
# pressures the room was designed to test.
#
# Fix: Q1ProofRoomScene._spawn_player runs a post-pass calling
# Enemy.set_player(spawned_player) on each spawned enemy (mirroring
# the iter-315 brick variant post-pass pattern).
#
# 2 cases:
#   1. Enemy.set_player(p) sets _player to p (sanity).
#   2. Q1ProofRoomScene end-to-end: after the scene's _ready completes,
#      EVERY spawned enemy has _player == spawned_player (regression
#      lock — pre-fix all enemies had _player == null).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_enemy_player_link.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")


func _initialize() -> void:
	# === Case 1: Enemy.set_player sets _player.
	var holder := Node2D.new()
	root.add_child(holder)
	await process_frame
	var enemy := EnemyScene.instantiate()
	holder.add_child(enemy)
	await process_frame
	var stub_player := Node2D.new()
	stub_player.name = "StubPlayer"
	holder.add_child(stub_player)
	await process_frame
	if not enemy.has_method("set_player"):
		push_error("FAIL — Enemy missing set_player method (Codex P2 fix not applied)")
		quit(1); return
	enemy.set_player(stub_player)
	if enemy._player != stub_player:
		push_error("FAIL — Enemy.set_player didn't set _player (got %s, want stub)" % enemy._player)
		quit(1); return
	print("  case 1: Enemy.set_player(stub) → _player == stub")
	holder.queue_free()
	await process_frame

	# === Case 2: end-to-end — every Q1ProofRoom enemy has _player set
	# after scene _ready (post-pass retro-link).
	var room: Node = Q1ProofRoomScene.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame
	if room.spawned_player == null:
		push_error("FAIL — Q1ProofRoomScene.spawned_player is null")
		quit(1); return
	if room.spawned_enemies.size() == 0:
		push_error("FAIL — Q1ProofRoomScene spawned 0 enemies (scene-spawn regression)")
		quit(1); return
	var unlinked: int = 0
	var checked: int = 0
	for e in room.spawned_enemies:
		if e == null or not is_instance_valid(e):
			continue
		checked += 1
		if e._player != room.spawned_player:
			unlinked += 1
	if unlinked > 0:
		push_error("FAIL — %d/%d spawned enemies have wrong _player (Codex P2 regression: retro-link missed)" \
				% [unlinked, checked])
		quit(1); return
	print("  case 2: Q1ProofRoom end-to-end — %d/%d enemies linked to spawned_player (Codex P2 regression locked)" \
			% [checked, checked])

	print("BREACH_Q1_ENEMY_PLAYER_LINK_OK 2 cases — Enemy.set_player setter + Q1ProofRoom post-pass retro-link")
	quit(0)
