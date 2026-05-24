# Arc-4 breach mode: P1-E + P1-F regression — _apply_level_boost
# must clamp max_hp / max_*_reserve at sane ceilings (iter 103,
# code-review-iter-100).
#
# Before the fix: every 3 levels did `max_hp += 1` (kind 0) or
# `max_he/heat/apcr_reserve += 1` (kind 2) unconditionally. A long
# run inflated stats arbitrarily — passive-stat-soup drift, fails
# CONSULT constraint 7 ("RPG progression is mostly verbs and
# affordances, not passive stats").
#
# After the fix:
#   - kind 0: max_hp grows only if < MAX_HP_CEILING (8). At cap →
#     full heal (still a meaningful reward).
#   - kind 2: each max_*_reserve grows only if < its ceiling
#     (HE=12, HEAT=8, APCR=10). Refill always fires. At cap →
#     toast says "+SHELL REFILL" instead of "+SHELL CAP".
#
# Verifies:
#   1. max_hp grows 3 → MAX_HP_CEILING under sustained kind-0 boosts.
#   2. Past ceiling, kind-0 still heals (hp = max_hp) but doesn't grow.
#   3. max_he_reserve clamps at MAX_HE_RESERVE_CEILING under
#      sustained kind-2 boosts; max_heat and max_apcr similarly.
#   4. At cap, kind-2 still refills (he_reserve goes up).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_level_up_ceilings.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Test A: max_hp clamps at MAX_HP_CEILING.
	if not await _test_hp_ceiling():
		quit(1); return

	# === Test B: at-cap HP level-up still heals (no silent no-op).
	if not await _test_hp_ceiling_heal_fallback():
		quit(1); return

	# === Test C: max_*_reserve clamps at per-shell ceilings.
	if not await _test_reserve_ceilings():
		quit(1); return

	# === Test D: at-cap reserve level-up still refills.
	if not await _test_reserve_ceiling_refill_fallback():
		quit(1); return

	print("BREACH_LEVEL_UP_CEILINGS_OK max_hp + max_*_reserve clamps + at-cap refills verified")
	quit(0)


# Drive kind-0 level-ups (level = 2, 5, 8, ...) until max_hp stabilizes.
# The ceiling is MAX_HP_CEILING (=8); starting from 3, we need 5 boosts.
# Send 10 kind-0 boosts to overrun the ceiling and confirm the clamp.
func _test_hp_ceiling() -> bool:
	var pt: Node = _build_pt()
	await process_frame
	await process_frame
	var start_hp: int = pt.max_hp
	var ceiling: int = PlayerTankT.MAX_HP_CEILING
	for i in 10:
		pt._apply_level_boost(2 + i * 3)  # kind = (2-2)%3 = 0
	if pt.max_hp != ceiling:
		push_error("FAIL — max_hp = %d after 10 kind-0 boosts, want %d (CEILING)" \
				% [pt.max_hp, ceiling])
		pt.queue_free()
		return false
	print("  max_hp clamped: %d → %d (CEILING after 10 boosts, not inflated)" \
			% [start_hp, pt.max_hp])
	pt.queue_free()
	await process_frame
	return true


func _test_hp_ceiling_heal_fallback() -> bool:
	var pt: Node = _build_pt()
	await process_frame
	await process_frame
	# Force at-cap state: set max_hp to CEILING, hp to 1 (damaged).
	pt.max_hp = PlayerTankT.MAX_HP_CEILING
	pt.hp = 1
	pt._apply_level_boost(2)  # kind 0 — should fall back to FULL HEAL
	if pt.max_hp != PlayerTankT.MAX_HP_CEILING:
		push_error("FAIL — at-cap kind-0 boost grew max_hp past ceiling: %d" % pt.max_hp)
		pt.queue_free(); return false
	if pt.hp != pt.max_hp:
		push_error("FAIL — at-cap kind-0 boost did NOT full-heal: hp=%d, max_hp=%d" \
				% [pt.hp, pt.max_hp])
		pt.queue_free(); return false
	print("  at-cap kind-0 boost: hp 1 → %d (full heal), max_hp held at CEILING" \
			% pt.hp)
	pt.queue_free()
	await process_frame
	return true


func _test_reserve_ceilings() -> bool:
	var pt: Node = _build_pt()
	await process_frame
	await process_frame
	var lo = pt.loadout
	if lo == null:
		push_error("FAIL — pt.loadout is null (couldn't drive kind-2 boosts)")
		pt.queue_free(); return false
	var start_he: int = lo.max_he_reserve
	# Drive kind-2 level-ups (level=4, 7, 10, ...) — kind = (4-2)%3 = 2.
	for i in 20:
		pt._apply_level_boost(4 + i * 3)
	if lo.max_he_reserve != PlayerTankT.MAX_HE_RESERVE_CEILING:
		push_error("FAIL — max_he_reserve = %d after 20 kind-2 boosts, want %d" \
				% [lo.max_he_reserve, PlayerTankT.MAX_HE_RESERVE_CEILING])
		pt.queue_free(); return false
	if lo.max_heat_reserve != PlayerTankT.MAX_HEAT_RESERVE_CEILING:
		push_error("FAIL — max_heat_reserve = %d, want %d" \
				% [lo.max_heat_reserve, PlayerTankT.MAX_HEAT_RESERVE_CEILING])
		pt.queue_free(); return false
	if lo.max_apcr_reserve != PlayerTankT.MAX_APCR_RESERVE_CEILING:
		push_error("FAIL — max_apcr_reserve = %d, want %d" \
				% [lo.max_apcr_reserve, PlayerTankT.MAX_APCR_RESERVE_CEILING])
		pt.queue_free(); return false
	print("  max_*_reserve clamped: HE %d→%d, HEAT →%d, APCR →%d (all at CEILINGS)" \
			% [start_he, lo.max_he_reserve, lo.max_heat_reserve, lo.max_apcr_reserve])
	pt.queue_free()
	await process_frame
	return true


func _test_reserve_ceiling_refill_fallback() -> bool:
	var pt: Node = _build_pt()
	await process_frame
	await process_frame
	var lo = pt.loadout
	# Force at-cap: max all reserves to ceiling, set reserves below cap.
	lo.max_he_reserve = PlayerTankT.MAX_HE_RESERVE_CEILING
	lo.max_heat_reserve = PlayerTankT.MAX_HEAT_RESERVE_CEILING
	lo.max_apcr_reserve = PlayerTankT.MAX_APCR_RESERVE_CEILING
	lo.he_reserve = 0
	lo.heat_reserve = 0
	lo.apcr_reserve = 0
	pt._apply_level_boost(4)  # kind 2 — at cap, should still refill
	if lo.max_he_reserve != PlayerTankT.MAX_HE_RESERVE_CEILING:
		push_error("FAIL — at-cap kind-2 boost inflated max_he_reserve: %d" % lo.max_he_reserve)
		pt.queue_free(); return false
	if lo.he_reserve != 1 or lo.heat_reserve != 1 or lo.apcr_reserve != 1:
		push_error("FAIL — at-cap kind-2 boost did not refill: HE=%d HEAT=%d APCR=%d (want 1/1/1)" \
				% [lo.he_reserve, lo.heat_reserve, lo.apcr_reserve])
		pt.queue_free(); return false
	print("  at-cap kind-2 boost: refilled HE/HEAT/APCR by +1 each; max_*_reserve held at ceilings")
	pt.queue_free()
	await process_frame
	return true


func _build_pt() -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	(root.get_child(0) as Node).add_child(pt)
	return pt
