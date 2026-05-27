# Arc-4 iter 313 — Round 26 Phase A — BrickBlock variant_texture override harness.
#
# Verifies the iter-313 substrate write (BrickBlock.gd ×1 — adding the
# `variant_texture` @export field) preserves arc-2/3 baseline AND
# correctly swaps the sprite when an override is supplied.
#
# Hash anchor 23d6a2ec3bf2821f is preserved by the loadout-gated style
# (default null → no _ready branch taken → sprite stays on sprites_1.png
# frame 5 = baseline).
#
# 4 cases:
#   1. Default brick (no variant): sprite.texture == sprites_1.png +
#      hframes=6 + vframes=2 + frame=5 (the canonical arc-2/3 wiring).
#   2. Variant brick (variant_texture set): sprite.texture == override +
#      hframes=1 + vframes=1 + frame=0.
#   3. Default brick still take_damage works (regression check).
#   4. Variant brick still take_damage works + beam_hp path intact.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_brick_variant.gd

extends SceneTree

const BrickBlockScene = preload("res://scenes/BrickBlock.tscn")
const BrickVariantTexture = preload("res://img/brick_012.png")
const BrickSheetTexture = preload("res://img/sprites_1.png")


func _initialize() -> void:
	# === Case 1: default brick — arc-2/3 baseline preserved.
	var b1: Node2D = BrickBlockScene.instantiate()
	root.add_child(b1)
	await process_frame
	var s1: Sprite2D = b1.get_node("Sprite2D")
	if s1.texture != BrickSheetTexture:
		push_error("FAIL — default brick sprite.texture changed (want sprites_1.png; got %s)" % s1.texture.resource_path)
		quit(1); return
	if s1.hframes != 6:
		push_error("FAIL — default brick hframes=%d (want 6)" % s1.hframes)
		quit(1); return
	if s1.vframes != 2:
		push_error("FAIL — default brick vframes=%d (want 2)" % s1.vframes)
		quit(1); return
	if s1.frame != 5:
		push_error("FAIL — default brick frame=%d (want 5)" % s1.frame)
		quit(1); return
	print("  case 1: default brick → sprites_1.png frame 5 (arc-2/3 baseline preserved)")

	# === Case 2: variant brick — override texture, collapsed atlas indexing.
	var b2: Node2D = BrickBlockScene.instantiate()
	b2.variant_texture = BrickVariantTexture
	root.add_child(b2)
	await process_frame
	var s2: Sprite2D = b2.get_node("Sprite2D")
	if s2.texture != BrickVariantTexture:
		push_error("FAIL — variant brick sprite.texture not override (got %s)" % s2.texture.resource_path)
		quit(1); return
	if s2.hframes != 1:
		push_error("FAIL — variant brick hframes=%d (want 1; standalone 8×8)" % s2.hframes)
		quit(1); return
	if s2.vframes != 1:
		push_error("FAIL — variant brick vframes=%d (want 1; standalone 8×8)" % s2.vframes)
		quit(1); return
	if s2.frame != 0:
		push_error("FAIL — variant brick frame=%d (want 0; first frame of standalone)" % s2.frame)
		quit(1); return
	print("  case 2: variant brick → brick_012.png hframes=1 vframes=1 frame=0 (standalone tile)")

	# === Case 3: default brick still takes damage (regression check).
	if b1.hp != b1.max_hp:
		push_error("FAIL — default brick hp init regression (want max_hp=%d; got hp=%d)" % [b1.max_hp, b1.hp])
		quit(1); return
	b1.take_damage(1)
	await process_frame
	if is_instance_valid(b1):
		push_error("FAIL — default brick survived take_damage(1) (still valid; should be freed)")
		quit(1); return
	print("  case 3: default brick still take_damage works → freed at hp=0")

	# === Case 4: variant brick beam_hp path intact (PRISM beam interaction preserved).
	if b2.beam_hp != b2.beam_hp_max:
		push_error("FAIL — variant brick beam_hp init regression (want max=%d; got %d)" % [b2.beam_hp_max, b2.beam_hp])
		quit(1); return
	b2.take_beam_damage(1)
	if b2.beam_hp != b2.beam_hp_max - 1:
		push_error("FAIL — variant brick beam damage didn't apply (want %d; got %d)" % [b2.beam_hp_max - 1, b2.beam_hp])
		quit(1); return
	b2.take_beam_damage(2)
	await process_frame
	if is_instance_valid(b2):
		push_error("FAIL — variant brick survived 3 beam ticks (still valid; should be freed)")
		quit(1); return
	print("  case 4: variant brick beam_hp path intact → 3 ticks → freed")

	print("BREACH_BRICK_VARIANT_OK 4 cases — default baseline + variant override + take_damage + beam_hp")
	quit(0)
