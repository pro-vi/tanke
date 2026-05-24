# Arc-4 breach mode: P0-A regression — Depot re-entry must not allow
# a second pick from the same depot (iter 100, fixing iter-100
# /code-review P0-A).
#
# Before the fix: _on_body_entered reset _picked = false on every
# entry. Player could enter depot, pick HE_REFILL_2 (+2 HE), exit,
# re-enter — pick HE_REFILL_2 again (+2 HE). With HE_MAX_EXPAND_2,
# the player could unboundedly grow max_he_reserve. With
# FULL_RESUPPLY, infinite resupply on demand.
#
# After the fix: _lifetime_picked latches once on apply_choice and
# never clears. Re-entry leaves _picked at its prior (true) state;
# apply_choice early-returns.
#
# Verifies:
#   - First entry: _picked = false initially
#   - apply_choice: _picked = true, _lifetime_picked = true
#   - Exit + re-entry: _picked STAYS true (not reset because
#     _lifetime_picked is true)
#   - apply_choice 2nd time: no-op (early returns on _picked)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot_lifetime_pick.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")
const DepotT = preload("res://scripts/Depot.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Spawn PlayerTank + Depot.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.add_to_group("player")
	holder.add_child(pt)
	await process_frame
	await process_frame

	var depot: Area2D = DepotScene.instantiate()
	holder.add_child(depot)
	await process_frame

	# === First entry — _picked starts false, _lifetime_picked false.
	depot._on_body_entered(pt)
	if depot._picked:
		push_error("FAIL — first entry: _picked %s, want false" % str(depot._picked))
		quit(1); return
	if depot._lifetime_picked:
		push_error("FAIL — first entry: _lifetime_picked %s, want false" % str(depot._lifetime_picked))
		quit(1); return
	print("  first entry: _picked=false, _lifetime_picked=false")

	# === First pick: HE_REFILL_2.
	var he_before: int = pt.loadout.he_reserve
	depot.apply_choice(1)  # picks the first rolled kind — exact kind depends on shuffle, but a pick is made
	if not depot._picked:
		push_error("FAIL — after apply_choice: _picked %s, want true" % str(depot._picked))
		quit(1); return
	if not depot._lifetime_picked:
		push_error("FAIL — after apply_choice: _lifetime_picked %s, want true" % str(depot._lifetime_picked))
		quit(1); return
	print("  apply_choice(1): _picked=true, _lifetime_picked=true (latched)")

	# === Exit + re-enter — _picked STAYS true (P0-A fix).
	depot._on_body_exited(pt)
	if not depot._lifetime_picked:
		push_error("FAIL — after exit: _lifetime_picked dropped (should be sticky)")
		quit(1); return
	depot._on_body_entered(pt)
	if not depot._picked:
		push_error("FAIL — re-entry: _picked %s, want STAYS true (P0-A: lifetime latch should prevent reset)" % str(depot._picked))
		quit(1); return
	if not depot._lifetime_picked:
		push_error("FAIL — re-entry: _lifetime_picked dropped")
		quit(1); return
	print("  re-enter after pick: _picked STAYS true (lifetime latch blocks reset)")

	# === Second pick attempt: apply_choice must no-op.
	# Record loadout values to verify no second pick fires.
	var he_after_first_pick: int = pt.loadout.he_reserve
	var heat_after_first_pick: int = pt.loadout.heat_reserve
	var max_he_after_first_pick: int = pt.loadout.max_he_reserve

	depot.apply_choice(1)
	if pt.loadout.he_reserve != he_after_first_pick:
		push_error("FAIL — 2nd apply_choice mutated loadout.he_reserve (%d → %d): EXPLOIT NOT BLOCKED" % [he_after_first_pick, pt.loadout.he_reserve])
		quit(1); return
	if pt.loadout.heat_reserve != heat_after_first_pick:
		push_error("FAIL — 2nd apply_choice mutated heat_reserve: EXPLOIT NOT BLOCKED")
		quit(1); return
	if pt.loadout.max_he_reserve != max_he_after_first_pick:
		push_error("FAIL — 2nd apply_choice mutated max_he_reserve (%d → %d): UNBOUNDED CAPACITY EXPLOIT NOT BLOCKED" % [max_he_after_first_pick, pt.loadout.max_he_reserve])
		quit(1); return
	print("  2nd apply_choice: loadout untouched (he_reserve/heat_reserve/max_he_reserve preserved) — exploit blocked")

	# === Third pick attempt (apply_choice(2) — different idx).
	depot.apply_choice(2)
	if pt.loadout.max_he_reserve != max_he_after_first_pick:
		push_error("FAIL — apply_choice(2) on picked depot mutated max_he_reserve")
		quit(1); return
	print("  apply_choice(2) on already-picked depot: no-op (idx ignored when _picked)")

	holder.queue_free()
	print("BREACH_DEPOT_LIFETIME_PICK_OK P0-A fix verified — once-picked depot rejects subsequent picks across re-entries (no unbounded HE_REFILL / HE_MAX_EXPAND / FULL_RESUPPLY exploit)")
	quit(0)
