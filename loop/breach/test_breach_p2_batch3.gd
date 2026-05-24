# Arc-4 breach mode: P2 sweep batch 3 regression (iter 098).
# Verifies:
#   P2-7: PlayerTank._apply_beam_to_body applies BEAM_DAMAGE_COOLDOWN
#         to ALL bodies with take_damage (not just enemies). Future
#         multi-HP non-enemy bodies (eagle base, destructible cover)
#         no longer melt at framerate.
#   P2-9: MetaProgress.archetype_ladder() returns 3 archetype rungs
#         (PRISM@20, MORTAR@40, RAM@60) — companion to the existing
#         4-rung unlock_ladder().
#   P2-5: PRESSURES.md + configs/breach_default.tres canonical_answer
#         text correctly describes HEAT as 2-shot vs breach Heavy
#         (BREACH_HP_BONUS makes Heavy hp=3; HEAT damage=2).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_p2_batch3.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MetaProgressT = preload("res://scripts/MetaProgress.gd")
const BreachConfigT = preload("res://scripts/BreachConfig.gd")


class _MultiHpStub extends Node2D:
	var damage_taken: int = 0
	func take_damage(amount: int) -> void:
		damage_taken += amount


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === P2-7: non-enemy multi-HP stub no longer melts at framerate.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt)
	await process_frame
	await process_frame

	# Stub is in NO group (not "enemy"). Pre-fix (iter 098): would
	# take damage every tick. Post-iter-098: cooldown gates per-tick
	# damage. Post-iter-138 (PLAYTEST-FIX): accumulator-based — 4
	# cooldown-spaced ticks per HP via BEAM_DAMAGE_PER_TICK=0.25.
	# Universal cooldown discipline preserved.
	var stub: Node = _MultiHpStub.new()
	holder.add_child(stub)
	pt._beam_dmg_timer = 0.0  # reset for clean cooldown trace

	# 4 cooldown-spaced ticks → 1 damage (accumulator hits 1.0).
	for i in 4:
		pt._apply_beam_to_body(pt.BEAM_DAMAGE_COOLDOWN + 0.01, stub)
	if stub.damage_taken != 1:
		push_error("FAIL — P2-7 after 4 cooldown ticks: stub damage %d, want 1" % stub.damage_taken)
		quit(1); return

	# Mid-cooldown ticks (within timer window): NO accumulator add.
	pt._beam_dmg_timer = pt.BEAM_DAMAGE_COOLDOWN  # arm cooldown
	pt._apply_beam_to_body(0.05, stub)
	pt._apply_beam_to_body(0.05, stub)
	if stub.damage_taken != 1:
		push_error("FAIL — P2-7 mid-cooldown: stub damage %d, want 1 (was framerate-damaged before iter-098 fix; cooldown discipline preserved at iter-138)" % stub.damage_taken)
		quit(1); return

	# 4 more cooldown-spaced ticks → +1 damage = 2 total.
	for i in 4:
		pt._apply_beam_to_body(pt.BEAM_DAMAGE_COOLDOWN + 0.01, stub)
	if stub.damage_taken != 2:
		push_error("FAIL — P2-7 post-cooldown: stub damage %d, want 2" % stub.damage_taken)
		quit(1); return
	print("  P2-7 universal cooldown + iter-138 accumulator: 4 ticks → 1 damage; mid-cooldown skipped; 4 more → 2 damage")

	# === P2-9: archetype_ladder returns the 3 archetype rungs.
	var arch_ladder: Array = MetaProgressT.archetype_ladder()
	if arch_ladder.size() != 3:
		push_error("FAIL — P2-9: archetype_ladder size %d, want 3" % arch_ladder.size())
		quit(1); return
	var expected_names: Array = ["PRISM", "MORTAR", "RAM"]
	var expected_depths: Array = [MetaProgressT.UNLOCK_PRISM_DEPTH, MetaProgressT.UNLOCK_MORTAR_DEPTH, MetaProgressT.UNLOCK_RAM_DEPTH]
	for i in 3:
		if arch_ladder[i]["name"] != expected_names[i]:
			push_error("FAIL — P2-9: archetype_ladder[%d].name %s, want %s" % [i, arch_ladder[i]["name"], expected_names[i]])
			quit(1); return
		if arch_ladder[i]["depth"] != expected_depths[i]:
			push_error("FAIL — P2-9: archetype_ladder[%d].depth %d, want %d" % [i, arch_ladder[i]["depth"], expected_depths[i]])
			quit(1); return
	print("  P2-9 archetype_ladder: 3 rungs (PRISM@20, MORTAR@40, RAM@60) — companion to upgrade unlock_ladder")

	# Also verify the existing unlock_ladder still has 4 rungs (backward compat).
	var unlock_ladder: Array = MetaProgressT.unlock_ladder()
	if unlock_ladder.size() != 4:
		push_error("FAIL — P2-9: unlock_ladder size %d, want 4 (backward compat broken)" % unlock_ladder.size())
		quit(1); return
	print("  P2-9 unlock_ladder unchanged: 4 upgrade rungs (backward compat preserved)")

	# === P2-5: breach_default.tres canonical_answer text updated.
	var cfg: BreachConfigT = load("res://configs/breach_default.tres")
	var bunker_band = null
	for b in cfg.bands:
		if b.band_name == "bunker_zone":
			bunker_band = b
			break
	if bunker_band == null:
		push_error("FAIL — P2-5: bunker_zone band not found in breach_default.tres")
		quit(1); return
	# The canonical answer should mention "2-shot" or similar to clarify
	# HEAT takes 2 hits against breach Heavy.
	var ans: String = String(bunker_band.canonical_answer)
	if not "2-shot" in ans.to_lower():
		push_error("FAIL — P2-5: bunker_zone canonical_answer '%s' missing '2-shot' clarification" % ans)
		quit(1); return
	print("  P2-5 doc fix: bunker_zone canonical_answer correctly notes HEAT as 2-shot vs breach Heavy hp=3")

	holder.queue_free()
	print("BREACH_P2_BATCH3_OK P2-7 (universal beam cooldown) + P2-9 (archetype_ladder) + P2-5 (HEAT/Heavy doc fix) all verified")
	quit(0)
