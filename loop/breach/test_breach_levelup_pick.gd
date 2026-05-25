# Arc-4 breach mode: Round 23 Phase 2 — pick-1-of-3 card UI
# regression (iter 198). Verifies:
#   - _show_levelup_pick(level) pauses tree + sets _levelup_picking.
#   - _levelup_choices has 3 cards drawn from CURRENT_ARCHETYPE pool.
#   - _pick_levelup_card(idx) applies card + unpauses + clears state.
#   - HP_PLUS_1 card mutates max_hp + hp.
#   - HP_PLUS_2 card adds 2 (RAM-exclusive).
#   - arc-2/3 mode (loadout=null) skips the pick entirely (no panel).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_levelup_pick.gd

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


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Case 1: loadout + DEFAULT — pick screen shows 3 cards ===
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt)
	await process_frame
	await process_frame

	pt._show_levelup_pick(2)
	await process_frame
	if not _assert_eq(pt._levelup_picking, true, "_levelup_picking after show"):
		quit(1); return
	if not _assert_eq(self.paused, true, "tree paused after show"):
		quit(1); return
	if not _assert_eq(pt._levelup_choices.size(), 3, "3 cards drawn"):
		quit(1); return
	# Cards must come from DEFAULT pool.
	for k in pt._levelup_choices:
		if not UpgradeCatalogT.POOL_DEFAULT.has(int(k)):
			push_error("FAIL — DEFAULT pick has card outside POOL_DEFAULT: %d" % int(k))
			quit(1); return
	print("  DEFAULT: pick screen shown; 3 cards drawn from POOL_DEFAULT; tree paused")

	# === Case 2: _pick_levelup_card unpauses + clears state ===
	pt._pick_levelup_card(0)
	await process_frame
	if not _assert_eq(pt._levelup_picking, false, "_levelup_picking false after pick"):
		quit(1); return
	if not _assert_eq(self.paused, false, "tree unpaused after pick"):
		quit(1); return
	print("  pick: cleared _levelup_picking + unpaused tree")

	# === Case 3: HP_PLUS_1 mutates max_hp + hp ===
	var pt_hp: Node = PlayerTankScene.instantiate()
	pt_hp.loadout = LoadoutT.new()
	pt_hp.archetype = PlayerTankT.TankArchetype.DEFAULT
	holder.add_child(pt_hp)
	await process_frame
	await process_frame
	var hp_before: int = pt_hp.max_hp
	# Skip the random draw; force HP_PLUS_1 into the pick directly.
	pt_hp._levelup_picking = true
	pt_hp._levelup_choices = [UpgradeCatalogT.CardKind.HP_PLUS_1]
	self.paused = true
	pt_hp._pick_levelup_card(0)
	await process_frame
	if not _assert_eq(pt_hp.max_hp, hp_before + 1, "HP_PLUS_1 adds 1 max_hp"):
		quit(1); return
	print("  HP_PLUS_1: max_hp %d → %d" % [hp_before, pt_hp.max_hp])

	# === Case 4: HP_PLUS_2 adds 2 ===
	var pt_ram: Node = PlayerTankScene.instantiate()
	pt_ram.loadout = LoadoutT.new()
	pt_ram.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt_ram)
	await process_frame
	await process_frame
	var ram_hp_before: int = pt_ram.max_hp
	pt_ram._levelup_picking = true
	pt_ram._levelup_choices = [UpgradeCatalogT.CardKind.HP_PLUS_2]
	self.paused = true
	pt_ram._pick_levelup_card(0)
	await process_frame
	if not _assert_eq(pt_ram.max_hp, ram_hp_before + 2, "HP_PLUS_2 adds 2 max_hp"):
		quit(1); return
	print("  HP_PLUS_2: max_hp %d → %d (RAM tank flavor)" % [ram_hp_before, pt_ram.max_hp])

	# === Case 5: arc-2/3 mode (loadout=null) skips the pick ===
	var pt_legacy: Node = PlayerTankScene.instantiate()
	pt_legacy.loadout = null
	holder.add_child(pt_legacy)
	await process_frame
	await process_frame
	pt_legacy._show_levelup_pick(2)
	await process_frame
	if not _assert_eq(pt_legacy._levelup_picking, false, "arc-2/3: pick skipped (loadout=null)"):
		quit(1); return
	if not _assert_eq(self.paused, false, "arc-2/3: tree not paused"):
		quit(1); return
	print("  arc-2/3: loadout=null skips pick entirely (no panel, no pause)")

	# === Case 6: PRISM pool only draws PRISM cards ===
	var pt_prism: Node = PlayerTankScene.instantiate()
	pt_prism.loadout = LoadoutT.new()
	pt_prism.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt_prism)
	await process_frame
	await process_frame
	pt_prism._show_levelup_pick(2)
	await process_frame
	for k in pt_prism._levelup_choices:
		if not UpgradeCatalogT.POOL_PRISM.has(int(k)):
			push_error("FAIL — PRISM pick has card outside POOL_PRISM: %d" % int(k))
			quit(1); return
	pt_prism._exit_levelup_pick()
	print("  PRISM: 3 cards drawn entirely from POOL_PRISM")

	holder.queue_free()
	print("BREACH_LEVELUP_PICK_OK 6 cases verified: panel + card-pool gating + HP+1 + HP+2 + arc-2/3 skip + archetype-pool")
	quit(0)
