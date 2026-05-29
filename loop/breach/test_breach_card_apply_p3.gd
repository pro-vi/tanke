# Arc-4 breach mode: Round 23 Phase 3 — PRISM + MORTAR card apply
# branches (iter 199). Verifies each card mutates the right state.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_card_apply_p3.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")


func _assert_eq(actual, expected, label: String) -> bool:
	if actual != expected:
		push_error("FAIL — %s: got %s, want %s" % [label, str(actual), str(expected)])
		return false
	return true


func _assert_close(actual: float, expected: float, eps: float, label: String) -> bool:
	if absf(actual - expected) > eps:
		push_error("FAIL — %s: got %f, want %f" % [label, actual, expected])
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

	# === PRISM: BEAM_DPS_UP ===
	var pt_dps: Node = PlayerTankScene.instantiate()
	pt_dps.loadout = LoadoutT.new()
	pt_dps.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt_dps)
	await process_frame
	await process_frame
	if not _assert_close(pt_dps._beam_dps_mult, 1.0, 0.001, "BEAM_DPS_UP initial mult = 1.0"):
		quit(1); return
	_force_pick(pt_dps, UpgradeCatalogT.CardKind.BEAM_DPS_UP)
	await process_frame
	if not _assert_close(pt_dps._beam_dps_mult, 0.7, 0.001, "BEAM_DPS_UP: mult → 0.7"):
		quit(1); return
	print("  BEAM_DPS_UP: _beam_dps_mult 1.0 → 0.7 (~43%% faster ticks)")

	# === PRISM: BEAM_RANGE_UP ===
	var pt_range: Node = PlayerTankScene.instantiate()
	pt_range.loadout = LoadoutT.new()
	pt_range.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt_range)
	await process_frame
	await process_frame
	_force_pick(pt_range, UpgradeCatalogT.CardKind.BEAM_RANGE_UP)
	await process_frame
	if not _assert_close(pt_range._beam_range_mult, 1.5, 0.001, "BEAM_RANGE_UP: mult → 1.5"):
		quit(1); return
	print("  BEAM_RANGE_UP: _beam_range_mult 1.0 → 1.5 (BEAM_RANGE 160 → 240 px)")

	# === PRISM: BEAM_PIERCE ===
	var pt_pierce: Node = PlayerTankScene.instantiate()
	pt_pierce.loadout = LoadoutT.new()
	pt_pierce.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt_pierce)
	await process_frame
	await process_frame
	if not _assert_eq(pt_pierce._beam_pierce, false, "BEAM_PIERCE initial false"):
		quit(1); return
	_force_pick(pt_pierce, UpgradeCatalogT.CardKind.BEAM_PIERCE)
	await process_frame
	if not _assert_eq(pt_pierce._beam_pierce, true, "BEAM_PIERCE: flag → true"):
		quit(1); return
	print("  BEAM_PIERCE: _beam_pierce false → true (visual ray extends past first body)")

	# === MORTAR: AOE_DAMAGE_UP — verify shell launches with bonus ===
	var pt_aoe: Node = PlayerTankScene.instantiate()
	pt_aoe.loadout = LoadoutT.new()
	pt_aoe.archetype = PlayerTankT.TankArchetype.MORTAR
	holder.add_child(pt_aoe)
	await process_frame
	await process_frame
	_force_pick(pt_aoe, UpgradeCatalogT.CardKind.AOE_DAMAGE_UP)
	await process_frame
	if not _assert_eq(pt_aoe._mortar_aoe_damage_bonus, 1, "AOE_DAMAGE_UP: bonus → 1"):
		quit(1); return
	# Verify _fire_mortar propagates the bonus to a launched shell.
	pt_aoe._fire_mortar(48.0)
	await process_frame
	var fired_shell: Node = null
	for ch in holder.get_children():
		if ch.has_method("launch") and ch != pt_aoe:
			fired_shell = ch
			break
	if fired_shell == null:
		push_error("FAIL — AOE_DAMAGE_UP: no shell instance found post-fire")
		quit(1); return
	if not _assert_eq(fired_shell.aoe_damage_override, fired_shell.AOE_DAMAGE + 1, "shell.aoe_damage_override = AOE_DAMAGE + 1"):
		quit(1); return
	print("  AOE_DAMAGE_UP: bonus +1 propagates into shell.aoe_damage_override")

	# === MORTAR: AOE_RADIUS_UP ===
	var pt_rad: Node = PlayerTankScene.instantiate()
	pt_rad.loadout = LoadoutT.new()
	pt_rad.archetype = PlayerTankT.TankArchetype.MORTAR
	holder.add_child(pt_rad)
	await process_frame
	await process_frame
	_force_pick(pt_rad, UpgradeCatalogT.CardKind.AOE_RADIUS_UP)
	await process_frame
	if not _assert_close(pt_rad._mortar_aoe_radius_bonus, 6.0, 0.001, "AOE_RADIUS_UP: bonus → 6.0"):
		quit(1); return
	print("  AOE_RADIUS_UP: _mortar_aoe_radius_bonus 0 → +6 px")

	# === MORTAR: MORTAR_COOLDOWN_DOWN ===
	var pt_cd: Node = PlayerTankScene.instantiate()
	pt_cd.loadout = LoadoutT.new()
	pt_cd.archetype = PlayerTankT.TankArchetype.MORTAR
	holder.add_child(pt_cd)
	await process_frame
	await process_frame
	var cd_before: float = pt_cd.get_node("GunTimer").wait_time
	_force_pick(pt_cd, UpgradeCatalogT.CardKind.MORTAR_COOLDOWN_DOWN)
	await process_frame
	if not _assert_close(pt_cd._mortar_cooldown_mult, 0.7, 0.001, "MORTAR_COOLDOWN: mult → 0.7"):
		quit(1); return
	var cd_after: float = pt_cd.get_node("GunTimer").wait_time
	if cd_after >= cd_before:
		push_error("FAIL — MORTAR_COOLDOWN_DOWN: wait_time should drop, was %f → %f" % [cd_before, cd_after])
		quit(1); return
	print("  MORTAR_COOLDOWN_DOWN: GunTimer wait_time %.3f → %.3f s" % [cd_before, cd_after])

	holder.queue_free()
	print("BREACH_CARD_APPLY_P3_OK 6 cases: BEAM_DPS+RANGE+PIERCE + AOE_DAMAGE+RADIUS + MORTAR_COOLDOWN")
	quit(0)
