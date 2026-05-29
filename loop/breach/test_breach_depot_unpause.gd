# arc-4 PR-#4 P0 review fix regression harness — depot hard-lock.
#
# Before the fix, _on_body_entered paused the tree; apply_choice only
# hid the panel + emitted depot_picked without unpausing; the only
# unpause path was _on_body_exited, which depended on the player
# physically leaving the Area2D — but the player is PROCESS_MODE_INHERIT
# and froze under the pause → permanent freeze on every depot pick.
#
# Verifies:
#   1. Enter depot → tree paused (current behavior).
#   2. apply_choice → tree unpaused (NEW; the load-bearing fix).
#   3. apply_choice → _player_loadout cleared, _player cleared
#      (re-entry-safe state hygiene).
#   4. After apply_choice, _on_body_exited from a still-overlapping
#      player is a no-op (idempotent unpause).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot_unpause.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


# Minimal stub matching the depot's duck-typed player contract:
# is_in_group("player") OR has_method("_on_PlayerTank_shoot"), plus
# a `loadout` property the depot captures into _player_loadout.
class StubPlayer extends Node2D:
	var loadout: Resource = null

	func _init() -> void:
		add_to_group("player")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)
	await process_frame

	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame

	var player := StubPlayer.new()
	player.loadout = LoadoutT.new()
	holder.add_child(player)
	await process_frame

	# === Case 1: enter depot → tree pauses.
	depot._on_body_entered(player)
	if not paused:
		push_error("FAIL — entering depot did not pause the tree")
		quit(1); return
	if depot._player_loadout != player.loadout:
		push_error("FAIL — depot did not capture player loadout on entry")
		quit(1); return
	if depot._player != player:
		push_error("FAIL — depot did not capture player ref on entry")
		quit(1); return
	print("  case 1: enter depot → tree paused + player+loadout captured")

	# === Case 2: apply_choice → tree unpauses (the P0 fix).
	depot.apply_choice(1)
	if paused:
		push_error("FAIL — apply_choice did not unpause the tree (P0 depot hard-lock regression)")
		quit(1); return
	print("  case 2: apply_choice → tree unpaused (P0 fix verified)")

	# === Case 3: apply_choice → captured player refs cleared.
	if depot._player_loadout != null:
		push_error("FAIL — apply_choice did not clear _player_loadout")
		quit(1); return
	if depot._player != null:
		push_error("FAIL — apply_choice did not clear _player")
		quit(1); return
	print("  case 3: apply_choice → _player_loadout + _player cleared")

	# === Case 4: subsequent _on_body_exited is a safe no-op.
	# (Tree already unpaused; _player_loadout already null. Idempotent.)
	depot._on_body_exited(player)
	if paused:
		push_error("FAIL — _on_body_exited re-paused the tree (post-pick state corrupted)")
		quit(1); return
	print("  case 4: _on_body_exited after pick is a safe no-op")

	print("BREACH_DEPOT_UNPAUSE_OK 4 cases — P0 depot hard-lock regression locked")
	quit(0)
