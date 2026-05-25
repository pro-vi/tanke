# Arc-4 breach mode: Round 23 Phase 4 — RAM + DEFAULT card apply
# branches + level-up trigger wiring flag (iter 200).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_card_apply_p4.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")


func _assert_eq(actual, expected, label: String) -> bool:
	if actual != expected:
		push_error("FAIL — %s: got %s, want %s" % [label, str(actual), str(expected)])
		return false
	return true


func _force_pick(pt: Node, kind: int) -> void:
	pt._levelup_picking = true
	pt._levelup_choices = [kind]
	self.paused = true
	pt._pick_levelup_card(0)


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === RAM: SWING_DAMAGE_UP ===
	var pt_sw: Node = PlayerTankScene.instantiate()
	pt_sw.loadout = LoadoutT.new()
	pt_sw.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt_sw)
	await process_frame
	await process_frame
	if not _assert_eq(pt_sw._ram_swing_damage_bonus, 0, "SWING initial bonus = 0"):
		quit(1); return
	_force_pick(pt_sw, UpgradeCatalogT.CardKind.SWING_DAMAGE_UP)
	await process_frame
	if not _assert_eq(pt_sw._ram_swing_damage_bonus, 1, "SWING_DAMAGE_UP: bonus 0 → 1"):
		quit(1); return
	print("  SWING_DAMAGE_UP: _ram_swing_damage_bonus 0 → 1 (RAM swing dmg 2 → 3)")

	# === RAM: COLLISION_DAMAGE_UP ===
	var pt_co: Node = PlayerTankScene.instantiate()
	pt_co.loadout = LoadoutT.new()
	pt_co.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt_co)
	await process_frame
	await process_frame
	_force_pick(pt_co, UpgradeCatalogT.CardKind.COLLISION_DAMAGE_UP)
	await process_frame
	if not _assert_eq(pt_co._ram_collision_damage_bonus, 1, "COLLISION_DAMAGE_UP: bonus 0 → 1"):
		quit(1); return
	print("  COLLISION_DAMAGE_UP: _ram_collision_damage_bonus 0 → 1")

	# === RAM: SPRINT_DURATION_UP ===
	var pt_sp: Node = PlayerTankScene.instantiate()
	pt_sp.loadout = LoadoutT.new()
	pt_sp.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt_sp)
	await process_frame
	await process_frame
	var sp_before: float = pt_sp.overdrive_burst
	_force_pick(pt_sp, UpgradeCatalogT.CardKind.SPRINT_DURATION_UP)
	await process_frame
	if pt_sp.overdrive_burst != sp_before + 0.5:
		push_error("FAIL — SPRINT_DURATION_UP: overdrive_burst %f → %f, want +0.5" % [sp_before, pt_sp.overdrive_burst])
		quit(1); return
	print("  SPRINT_DURATION_UP: overdrive_burst %.1f → %.1f (+0.5s sprint)" % [sp_before, pt_sp.overdrive_burst])

	# === DEFAULT: FASTER_RELOAD ===
	var pt_fr: Node = PlayerTankScene.instantiate()
	pt_fr.loadout = LoadoutT.new()
	pt_fr.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt_fr)
	await process_frame
	await process_frame
	var fr_before: float = pt_fr.get_node("GunTimer").wait_time
	_force_pick(pt_fr, UpgradeCatalogT.CardKind.FASTER_RELOAD)
	await process_frame
	var fr_after: float = pt_fr.get_node("GunTimer").wait_time
	if fr_after >= fr_before:
		push_error("FAIL — FASTER_RELOAD: wait_time should drop, %f → %f" % [fr_before, fr_after])
		quit(1); return
	print("  FASTER_RELOAD: GunTimer.wait_time %.3f → %.3f s" % [fr_before, fr_after])

	# === DEFAULT: SHELL_CAP_PLUS_1 ===
	var pt_sc: Node = PlayerTankScene.instantiate()
	pt_sc.loadout = LoadoutT.new()
	pt_sc.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt_sc)
	await process_frame
	await process_frame
	var he_max_before: int = pt_sc.loadout.max_he_reserve
	var heat_max_before: int = pt_sc.loadout.max_heat_reserve
	_force_pick(pt_sc, UpgradeCatalogT.CardKind.SHELL_CAP_PLUS_1)
	await process_frame
	if pt_sc.loadout.max_he_reserve != he_max_before + 1:
		push_error("FAIL — SHELL_CAP_PLUS_1: HE cap %d → %d, want +1" % [he_max_before, pt_sc.loadout.max_he_reserve])
		quit(1); return
	if pt_sc.loadout.max_heat_reserve != heat_max_before + 1:
		push_error("FAIL — SHELL_CAP_PLUS_1: HEAT cap %d → %d, want +1" % [heat_max_before, pt_sc.loadout.max_heat_reserve])
		quit(1); return
	print("  SHELL_CAP_PLUS_1: HE cap %d → %d, HEAT cap %d → %d" % [he_max_before, pt_sc.loadout.max_he_reserve, heat_max_before, pt_sc.loadout.max_heat_reserve])

	# === DEFAULT: MOMENTUM (move speed up) ===
	var pt_mo: Node = PlayerTankScene.instantiate()
	pt_mo.loadout = LoadoutT.new()
	pt_mo.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt_mo)
	await process_frame
	await process_frame
	var sp0: int = pt_mo.speed
	_force_pick(pt_mo, UpgradeCatalogT.CardKind.MOMENTUM)
	await process_frame
	var sp1: int = pt_mo.speed
	if sp1 <= sp0:
		push_error("FAIL — MOMENTUM: speed %d → %d, want increase" % [sp0, sp1])
		quit(1); return
	print("  MOMENTUM: speed %d → %d (~20%% faster)" % [sp0, sp1])

	# === Level-up wiring flag: default false → existing auto-boost path
	# preserved (no pick popped during _grant_xp). ===
	var pt_lv: Node = PlayerTankScene.instantiate()
	pt_lv.loadout = LoadoutT.new()
	pt_lv.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt_lv)
	await process_frame
	await process_frame
	# pick_card_on_levelup defaults to false.
	if not _assert_eq(pt_lv.pick_card_on_levelup, false, "pick_card_on_levelup default = false"):
		quit(1); return
	var hp0: int = pt_lv.max_hp
	pt_lv._grant_xp(pt_lv.XP_BASE)
	await process_frame
	if not _assert_eq(pt_lv._levelup_picking, false, "level-up with flag off → no pick"):
		quit(1); return
	# Auto-boost still fires: max HP +1.
	if not _assert_eq(pt_lv.max_hp, hp0 + 1, "auto-boost still fires when flag off"):
		quit(1); return
	print("  level-up flag default false: auto-boost fires (max_hp %d → %d), no pick" % [hp0, pt_lv.max_hp])

	# === Level-up wiring flag: true → pick UI pops alongside auto-boost ===
	var pt_lv2: Node = PlayerTankScene.instantiate()
	pt_lv2.loadout = LoadoutT.new()
	pt_lv2.archetype = PlayerTankT.TankArchetype.DEFAULT
	pt_lv2.pick_card_on_levelup = true
	holder.add_child(pt_lv2)
	await process_frame
	await process_frame
	pt_lv2._grant_xp(pt_lv2.XP_BASE)
	await process_frame
	if not _assert_eq(pt_lv2._levelup_picking, true, "level-up with flag on → pick UI shows"):
		quit(1); return
	pt_lv2._exit_levelup_pick()  # cleanup so harness exits cleanly
	print("  level-up flag true: pick UI shows alongside auto-boost")

	holder.queue_free()
	print("BREACH_CARD_APPLY_P4_OK 8 cases: RAM (SWING+COLLISION+SPRINT) + DEFAULT (RELOAD+SHELLS+MOMENTUM) + levelup-flag default + flag-on")
	quit(0)
