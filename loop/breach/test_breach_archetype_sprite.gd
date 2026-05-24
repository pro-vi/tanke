# Arc-4 breach mode: archetype → sprite swap regression (iter 146,
# Pro Consult 011 step 4/5). Verifies _apply_archetype_sprite gating:
#   - loadout=null PlayerTank keeps sprites_0.png + vframes=18 +
#     frame_base=0 (arc-2/3 baseline bit-identical).
#   - loadout!=null + archetype=PRISM swaps to archetype_sprites.png
#     with vframes=3 + frame_base=0 (row 0).
#   - loadout!=null + archetype=MORTAR uses frame_base=16 (row 1).
#   - loadout!=null + archetype=RAM uses frame_base=32 (row 2).
#   - switch_archetype PRISM → DEFAULT reverts texture (idempotent).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_archetype_sprite.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const ARCHETYPE_TEX = preload("res://img/archetype_sprites.png")
const DEFAULT_TEX = preload("res://img/sprites_0.png")


func _assert_eq(actual, expected, label: String) -> bool:
	if actual != expected:
		push_error("FAIL — %s: got %s, want %s" % [label, str(actual), str(expected)])
		return false
	return true


func _spawn(holder: Node, with_loadout: bool, arch: int) -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	if with_loadout:
		pt.loadout = LoadoutT.new()
	pt.archetype = arch
	holder.add_child(pt)
	return pt


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Case 1: no loadout → keeps default texture even if archetype set ===
	# (Defense-in-depth — arc-2/3 callers never set archetype != DEFAULT,
	# but if they did, the loadout gate keeps them on the default sprite.)
	var pt_arc23: Node = _spawn(holder, false, PlayerTankT.TankArchetype.PRISM)
	await process_frame
	await process_frame
	var sprite_arc23: Sprite2D = pt_arc23.sprite
	if not _assert_eq(sprite_arc23.texture, DEFAULT_TEX, "arc-2/3 loadout=null keeps DEFAULT_TEX"):
		quit(1); return
	if not _assert_eq(sprite_arc23.vframes, 18, "arc-2/3 loadout=null keeps vframes=18"):
		quit(1); return
	if not _assert_eq(sprite_arc23.get("frame_base"), 0, "arc-2/3 loadout=null keeps frame_base=0"):
		quit(1); return
	print("  arc-2/3 gating: loadout=null PlayerTank stays on sprites_0.png (vframes 18, frame_base 0)")

	# === Case 2: loadout + DEFAULT → still default texture (DEFAULT lives in sprites_0.png) ===
	var pt_default: Node = _spawn(holder, true, PlayerTankT.TankArchetype.DEFAULT)
	await process_frame
	await process_frame
	var sprite_default: Sprite2D = pt_default.sprite
	if not _assert_eq(sprite_default.texture, DEFAULT_TEX, "loadout + DEFAULT keeps DEFAULT_TEX"):
		quit(1); return
	if not _assert_eq(sprite_default.get("frame_base"), 0, "loadout + DEFAULT keeps frame_base=0"):
		quit(1); return
	print("  DEFAULT archetype with loadout: keeps sprites_0.png (frame_base 0)")

	# === Case 3: loadout + PRISM → archetype atlas, frame_base 0 (row 0) ===
	var pt_prism: Node = _spawn(holder, true, PlayerTankT.TankArchetype.PRISM)
	await process_frame
	await process_frame
	var sprite_prism: Sprite2D = pt_prism.sprite
	if not _assert_eq(sprite_prism.texture, ARCHETYPE_TEX, "PRISM swaps to ARCHETYPE_TEX"):
		quit(1); return
	if not _assert_eq(sprite_prism.vframes, 3, "PRISM sets vframes=3"):
		quit(1); return
	if not _assert_eq(sprite_prism.hframes, 16, "PRISM keeps hframes=16"):
		quit(1); return
	if not _assert_eq(sprite_prism.get("frame_base"), 0, "PRISM uses frame_base=0 (row 0)"):
		quit(1); return
	print("  PRISM archetype: archetype_sprites.png, vframes=3, frame_base=0")

	# === Case 4: loadout + MORTAR → archetype atlas, frame_base 16 (row 1) ===
	var pt_mortar: Node = _spawn(holder, true, PlayerTankT.TankArchetype.MORTAR)
	await process_frame
	await process_frame
	if not _assert_eq(pt_mortar.sprite.texture, ARCHETYPE_TEX, "MORTAR swaps to ARCHETYPE_TEX"):
		quit(1); return
	if not _assert_eq(pt_mortar.sprite.get("frame_base"), 16, "MORTAR uses frame_base=16 (row 1)"):
		quit(1); return
	print("  MORTAR archetype: archetype_sprites.png, frame_base=16 (row 1)")

	# === Case 5: loadout + RAM → archetype atlas, frame_base 32 (row 2) ===
	var pt_ram: Node = _spawn(holder, true, PlayerTankT.TankArchetype.RAM)
	await process_frame
	await process_frame
	if not _assert_eq(pt_ram.sprite.texture, ARCHETYPE_TEX, "RAM swaps to ARCHETYPE_TEX"):
		quit(1); return
	if not _assert_eq(pt_ram.sprite.get("frame_base"), 32, "RAM uses frame_base=32 (row 2)"):
		quit(1); return
	print("  RAM archetype: archetype_sprites.png, frame_base=32 (row 2)")

	# === Case 6: switch_archetype PRISM → DEFAULT reverts to default texture ===
	pt_prism.switch_archetype(PlayerTankT.TankArchetype.DEFAULT)
	await process_frame
	if not _assert_eq(pt_prism.sprite.texture, DEFAULT_TEX, "switch_archetype DEFAULT reverts texture"):
		quit(1); return
	if not _assert_eq(pt_prism.sprite.vframes, 18, "switch_archetype DEFAULT restores vframes=18"):
		quit(1); return
	if not _assert_eq(pt_prism.sprite.get("frame_base"), 0, "switch_archetype DEFAULT restores frame_base=0"):
		quit(1); return
	print("  switch PRISM→DEFAULT: texture reverted to sprites_0.png (vframes 18, frame_base 0)")

	# === Case 7: switch_archetype PRISM → MORTAR → RAM chains cleanly ===
	pt_mortar.switch_archetype(PlayerTankT.TankArchetype.RAM)
	await process_frame
	if not _assert_eq(pt_mortar.sprite.texture, ARCHETYPE_TEX, "MORTAR→RAM stays on ARCHETYPE_TEX"):
		quit(1); return
	if not _assert_eq(pt_mortar.sprite.get("frame_base"), 32, "MORTAR→RAM updates frame_base to 32"):
		quit(1); return
	print("  switch MORTAR→RAM: chain works (frame_base 16 → 32)")

	holder.queue_free()
	print("BREACH_ARCHETYPE_SPRITE_OK 7 cases verified: arc-2/3 gating + DEFAULT + PRISM/MORTAR/RAM frame_base + revert + chain")
	quit(0)
