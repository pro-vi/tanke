# Arc-4 breach mode: Depot 3-choice upgrade catalog verifier
# (C2 anchor 2 — "Depot offers ≥3 meaningful upgrade choices on entry
# + previews next band's dominant pressure — code-cited [STRUCTURE]").
#
# Stub body with a `loadout` property (arc-4 PlayerTank shape) — Depot's
# capture logic reads `body.loadout` on entry. Then directly invoke
# Depot.apply_choice(N) (bypasses raw KEY_1/2/3 polling which is
# headless-noisy).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot_choice.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


# Stub player carrying a `loadout` property like arc-4 PlayerTank does.
class StubPlayer extends Node:
	var loadout: LoadoutT = null


func _initialize() -> void:
	# Test 1: depot has next_band_hint surface (string field exists).
	# Tests 2-4: each of the 3 picks applies the expected loadout mutation.

	# Test 2: choice 1 (HE_REFILL_2) refills HE by 2.
	if not await _drive_pick(1, "he_refill_2", func(lo): return lo.he_reserve, 2):
		quit(1); return

	# Test 3: choice 2 (HEAT_REFILL_1) refills HEAT by 1.
	if not await _drive_pick(2, "heat_refill_1", func(lo): return lo.heat_reserve, 1):
		quit(1); return

	# Test 4: choice 3 (HE_MAX_EXPAND_2) expands max + refills 2.
	# (Verify max_he_reserve goes from 6 → 8.)
	if not await _drive_pick(3, "he_max_expand_2", func(lo): return lo.max_he_reserve, 8):
		quit(1); return

	# Test 5: next_band_hint surface exists (string field on Depot).
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	if not (depot.next_band_hint is String):
		push_error("FAIL — Depot.next_band_hint not a String field")
		quit(1); return
	depot.queue_free()

	print("BREACH_DEPOT_CHOICE_OK 3 choices apply distinct effects + preview field present")
	quit(0)


# Spawn a fresh depot + player + loadout; trigger entry, invoke the given
# pick index, then verify the loadout state via the provided extractor.
func _drive_pick(idx: int, label: String, extract: Callable, expect: int) -> bool:
	var depot: Area2D = DepotScene.instantiate()
	var stub := StubPlayer.new()
	stub.add_to_group("player")
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 0
	lo.heat_reserve = 0
	lo.max_he_reserve = 6  # baseline for HE_MAX_EXPAND test
	stub.loadout = lo

	root.add_child(depot)
	root.add_child(stub)
	await process_frame  # _ready fires; signals wired

	depot._on_body_entered(stub)
	# Single-pick semantics: invoke apply_choice directly (skipping the
	# input poll). Real input path is the SAME code with input gating.
	depot.apply_choice(idx)
	var got: int = extract.call(lo)
	depot._on_body_exited(stub)  # resume + clear loadout ref

	if got != expect:
		push_error("FAIL %s — expected %d, got %d" % [label, expect, got])
		depot.queue_free()
		stub.queue_free()
		return false

	print("  %s — %s = %d" % [label, label.split("_")[0], got])
	depot.queue_free()
	stub.queue_free()
	return true
