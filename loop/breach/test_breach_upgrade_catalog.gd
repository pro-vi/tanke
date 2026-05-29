# Arc-4 breach mode: Round 23 Phase 1 — UpgradeCatalog data module
# regression (iter 197). Verifies:
#   - Each archetype pool has exactly 4 entries (v1 scope cap).
#   - pool_for() returns the correct pool per archetype enum value.
#   - pool_for() falls back to DEFAULT on out-of-range archetype.
#   - label_for() and sentence_for() return non-empty for every
#     CardKind enum value.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_upgrade_catalog.gd

extends SceneTree

const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")


func _assert_eq(actual, expected, label: String) -> bool:
	if actual != expected:
		push_error("FAIL — %s: got %s, want %s" % [label, str(actual), str(expected)])
		return false
	return true


func _initialize() -> void:
	# === Case 1: each archetype pool has 4 entries (v1 scope cap) ===
	if not _assert_eq(UpgradeCatalogT.POOL_DEFAULT.size(), 4, "DEFAULT pool size"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.POOL_PRISM.size(), 4, "PRISM pool size"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.POOL_MORTAR.size(), 4, "MORTAR pool size"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.POOL_RAM.size(), 4, "RAM pool size"):
		quit(1); return
	print("  pools: DEFAULT=4, PRISM=4, MORTAR=4, RAM=4 (v1 scope cap respected)")

	# === Case 2: pool_for() returns correct pool per archetype ===
	if not _assert_eq(UpgradeCatalogT.pool_for(PlayerTankT.TankArchetype.DEFAULT), UpgradeCatalogT.POOL_DEFAULT, "pool_for(DEFAULT)"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.pool_for(PlayerTankT.TankArchetype.PRISM), UpgradeCatalogT.POOL_PRISM, "pool_for(PRISM)"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.pool_for(PlayerTankT.TankArchetype.MORTAR), UpgradeCatalogT.POOL_MORTAR, "pool_for(MORTAR)"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.pool_for(PlayerTankT.TankArchetype.RAM), UpgradeCatalogT.POOL_RAM, "pool_for(RAM)"):
		quit(1); return
	print("  pool_for(): 4-way archetype → pool mapping verified")

	# === Case 3: out-of-range archetype falls back to DEFAULT ===
	if not _assert_eq(UpgradeCatalogT.pool_for(99), UpgradeCatalogT.POOL_DEFAULT, "pool_for(99 out-of-range)"):
		quit(1); return
	if not _assert_eq(UpgradeCatalogT.pool_for(-1), UpgradeCatalogT.POOL_DEFAULT, "pool_for(-1 out-of-range)"):
		quit(1); return
	print("  pool_for(): out-of-range archetype falls back to DEFAULT")

	# === Case 4: every CardKind has non-empty label + sentence ===
	# Enumerate all CardKind values via reflection over the pools
	# (they collectively cover every enum value).
	var all_kinds: Dictionary = {}
	for pool in [UpgradeCatalogT.POOL_DEFAULT, UpgradeCatalogT.POOL_PRISM, UpgradeCatalogT.POOL_MORTAR, UpgradeCatalogT.POOL_RAM]:
		for k in pool:
			all_kinds[k] = true
	var missing_label: Array[int] = []
	var missing_sentence: Array[int] = []
	for k in all_kinds.keys():
		if UpgradeCatalogT.label_for(k) in ["", "?"]:
			missing_label.append(k)
		if UpgradeCatalogT.sentence_for(k) == "":
			missing_sentence.append(k)
	if missing_label.size() != 0:
		push_error("FAIL — label_for() missing/'?' for kinds %s" % str(missing_label))
		quit(1); return
	if missing_sentence.size() != 0:
		push_error("FAIL — sentence_for() empty for kinds %s" % str(missing_sentence))
		quit(1); return
	print("  metadata: every CardKind in pools has non-empty label + sentence (%d kinds checked)" % all_kinds.size())

	print("BREACH_UPGRADE_CATALOG_OK 4 cases verified: pool sizes + pool_for + fallback + metadata coverage")
	quit(0)
