# arc-4 PR-#4 Codex P1 review fix regression — Depot._is_player must
# detect the real PlayerTank, not just grouped stubs.
#
# Pre-fix: _is_player checked is_in_group("player") OR
# has_method("_on_PlayerTank_shoot"). In the live BreachLevel.tscn flow:
#   - PlayerTank.tscn is NOT in the "player" group
#   - _on_PlayerTank_shoot is on Level.gd, NOT on PlayerTank.gd
# So depot entry silently returned at the _is_player check for every
# field depot in real play — no pause, no upgrade panel, no breach-
# economy. Harnesses didn't catch it because they explicitly add the
# stub player to the "player" group (Q1ProofRoomScene, depot-unpause).
#
# Fix: add has_method("switch_archetype") as a third detection
# signature. switch_archetype is PlayerTank-only (arc-4 iter 69, grep-
# confirmed) and the depot's own SWITCH_TO_* upgrades already call it.
#
# 4 cases:
#   1. Real PlayerTank (no group + no _on_PlayerTank_shoot) →
#      _is_player returns true via switch_archetype signature
#      (Codex P1 regression lock).
#   2. Grouped stub player → still detected (back-compat).
#   3. Level-handler stub (has _on_PlayerTank_shoot) → still detected
#      (arc-2 back-compat).
#   4. Enemy / unrelated Node2D → _is_player returns false (no
#      false-positives).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot_player_detection.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")


# Stub WITHOUT switch_archetype — pre-fix detection would catch via group.
class GroupedStubPlayer extends Node2D:
	func _init() -> void:
		add_to_group("player")


# Stub WITHOUT group — exposes only the arc-2 signal-handler signature.
class LevelHandlerStub extends Node2D:
	func _on_PlayerTank_shoot(_a, _b, _c, _d = 0) -> void:
		pass


func _initialize() -> void:
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame

	# === Case 1: real PlayerTank (no group, no _on_PlayerTank_shoot).
	var pt: Node = PlayerTankScene.instantiate()
	root.add_child(pt)
	await process_frame
	if pt.is_in_group("player"):
		push_error("FAIL — PlayerTank.tscn is in 'player' group; test premise broken")
		quit(1); return
	if pt.has_method("_on_PlayerTank_shoot"):
		push_error("FAIL — PlayerTank.gd has _on_PlayerTank_shoot; test premise broken")
		quit(1); return
	if not pt.has_method("switch_archetype"):
		push_error("FAIL — PlayerTank.gd lacks switch_archetype; review-fix premise broken")
		quit(1); return
	if not depot._is_player(pt):
		push_error("FAIL — Depot._is_player returned false for real PlayerTank (Codex P1 regression: live depots dead in BreachLevel)")
		quit(1); return
	print("  case 1: real PlayerTank (no group + no _on_PlayerTank_shoot) → _is_player=true via switch_archetype (Codex P1 fix)")
	pt.queue_free()
	await process_frame

	# === Case 2: grouped stub player → detected.
	var stub_g := GroupedStubPlayer.new()
	root.add_child(stub_g)
	await process_frame
	if not depot._is_player(stub_g):
		push_error("FAIL — _is_player returned false for grouped stub (back-compat regression)")
		quit(1); return
	print("  case 2: grouped stub → _is_player=true (back-compat preserved)")
	stub_g.queue_free()
	await process_frame

	# === Case 3: level-handler stub → detected.
	var stub_lh := LevelHandlerStub.new()
	root.add_child(stub_lh)
	await process_frame
	if not depot._is_player(stub_lh):
		push_error("FAIL — _is_player returned false for level-handler stub (arc-2 back-compat regression)")
		quit(1); return
	print("  case 3: level-handler stub (has _on_PlayerTank_shoot) → _is_player=true (arc-2 back-compat)")
	stub_lh.queue_free()
	await process_frame

	# === Case 4: Enemy / unrelated node → NOT a player.
	var enemy: Node = EnemyScene.instantiate()
	root.add_child(enemy)
	await process_frame
	if depot._is_player(enemy):
		push_error("FAIL — Enemy detected as player (false-positive; review-fix signature too broad)")
		quit(1); return
	var unrelated := Node2D.new()
	root.add_child(unrelated)
	await process_frame
	if depot._is_player(unrelated):
		push_error("FAIL — unrelated Node2D detected as player (false-positive)")
		quit(1); return
	print("  case 4: Enemy + unrelated Node2D → _is_player=false (no false-positives)")

	print("BREACH_DEPOT_PLAYER_DETECTION_OK 4 cases — real PlayerTank + grouped stub + level-handler stub + non-player rejection")
	quit(0)
