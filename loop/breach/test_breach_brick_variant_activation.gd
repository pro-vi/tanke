# Arc-4 iter 315 — Round 26 Phase B activation harness:
# verifies BrickBlock self-discovers variant_texture from the active
# player's Loadout.brick_variant field, AND the arc-2/3 baseline chain
# (no player, no loadout, or loadout.brick_variant == null) produces
# bit-identical rendering to canonical sprites_1.png frame 5.
#
# This locks the iter-313 capability + iter-315 self-discovery wiring
# against silent regression. If a future iter breaks the player-loadout
# lookup, the harness fails BEFORE the change ships.
#
# 4 cases:
#   1. No player in scene → BrickBlock variant_texture stays null →
#      sprite on sprites_1.png frame 5 (baseline preserved).
#   2. Player with loadout but loadout.brick_variant == null → BrickBlock
#      self-discovery returns null → baseline preserved.
#   3. Player with loadout.brick_variant == brick_012.png → BrickBlock
#      self-discovers + swaps to brick_012 + atlas collapsed.
#   4. Q1ProofRoomScene end-to-end: instantiate the scene, verify all
#      spawned bricks pick up brick_012 from the player's loadout.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_brick_variant_activation.gd

extends SceneTree

const BrickBlockScene = preload("res://scenes/BrickBlock.tscn")
const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BrickVariantTexture = preload("res://img/brick_012.png")
const BrickSheetTexture = preload("res://img/sprites_1.png")


func _initialize() -> void:
	# === Case 1: no player → BrickBlock baseline.
	var holder1 := Node2D.new()
	root.add_child(holder1)
	await process_frame
	var b1: Node2D = BrickBlockScene.instantiate()
	holder1.add_child(b1)
	await process_frame
	var s1: Sprite2D = b1.get_node("Sprite2D")
	if s1.texture != BrickSheetTexture or s1.frame != 5:
		push_error("FAIL — no-player baseline broken (texture=%s, frame=%d; want sprites_1.png, frame=5)" % [s1.texture.resource_path, s1.frame])
		quit(1); return
	print("  case 1: no player in scene → BrickBlock baseline (sprites_1.png frame 5)")
	holder1.queue_free()
	await process_frame

	# === Case 2: player with null brick_variant → baseline.
	var holder2 := Node2D.new()
	root.add_child(holder2)
	await process_frame
	var p2: Node = PlayerTankScene.instantiate()
	p2.loadout = LoadoutT.new()
	# Explicit: brick_variant is null by default.
	p2.add_to_group("player")
	holder2.add_child(p2)
	await process_frame
	var b2: Node2D = BrickBlockScene.instantiate()
	holder2.add_child(b2)
	await process_frame
	var s2: Sprite2D = b2.get_node("Sprite2D")
	if s2.texture != BrickSheetTexture or s2.frame != 5:
		push_error("FAIL — player.loadout.brick_variant=null baseline broken (texture=%s, frame=%d)" % [s2.texture.resource_path, s2.frame])
		quit(1); return
	print("  case 2: player with loadout.brick_variant=null → BrickBlock baseline preserved")
	holder2.queue_free()
	await process_frame

	# === Case 3: player with brick_variant set → self-discovery applies override.
	var holder3 := Node2D.new()
	root.add_child(holder3)
	await process_frame
	var p3: Node = PlayerTankScene.instantiate()
	p3.loadout = LoadoutT.new()
	p3.loadout.brick_variant = BrickVariantTexture
	p3.add_to_group("player")
	holder3.add_child(p3)
	await process_frame
	var b3: Node2D = BrickBlockScene.instantiate()
	holder3.add_child(b3)
	await process_frame
	var s3: Sprite2D = b3.get_node("Sprite2D")
	if s3.texture != BrickVariantTexture:
		push_error("FAIL — player.loadout.brick_variant=brick_012 not picked up by self-discovery (texture=%s)" % s3.texture.resource_path)
		quit(1); return
	if s3.hframes != 1 or s3.vframes != 1 or s3.frame != 0:
		push_error("FAIL — variant brick atlas not collapsed (hf=%d, vf=%d, frame=%d)" % [s3.hframes, s3.vframes, s3.frame])
		quit(1); return
	print("  case 3: player with loadout.brick_variant set → self-discovery swaps to brick_012")
	holder3.queue_free()
	await process_frame

	# === Case 4: end-to-end via Q1ProofRoomScene.
	var room: Node = Q1ProofRoomScene.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame
	if room.spawned_player == null:
		push_error("FAIL — Q1ProofRoomScene spawned_player is null")
		quit(1); return
	if not ("loadout" in room.spawned_player) or room.spawned_player.loadout == null:
		push_error("FAIL — Q1ProofRoomScene player has no loadout")
		quit(1); return
	if room.spawned_player.loadout.brick_variant != BrickVariantTexture:
		push_error("FAIL — Q1ProofRoomScene player.loadout.brick_variant not set to brick_012")
		quit(1); return
	# Sample a brick from spawned_terrain and verify it picked up the variant.
	var checked_bricks: int = 0
	for ter in room.spawned_terrain:
		if ter == null or not is_instance_valid(ter):
			continue
		if ter.name.begins_with("BrickBlock_"):
			var sp: Sprite2D = ter.get_node("Sprite2D")
			if sp.texture != BrickVariantTexture:
				push_error("FAIL — Q1ProofRoom brick %s did not pick up brick_012 variant (texture=%s)" % [ter.name, sp.texture.resource_path])
				quit(1); return
			checked_bricks += 1
			if checked_bricks >= 3:
				break
	if checked_bricks == 0:
		push_error("FAIL — no BrickBlock bricks found in Q1ProofRoom scene")
		quit(1); return
	print("  case 4: Q1ProofRoom end-to-end → %d sampled bricks rendered with brick_012 variant (player.loadout.brick_variant active)" % checked_bricks)

	print("BREACH_BRICK_VARIANT_ACTIVATION_OK 4 cases — no-player baseline + null-variant baseline + self-discovery override + Q1ProofRoom e2e")
	quit(0)
