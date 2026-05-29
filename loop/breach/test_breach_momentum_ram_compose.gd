# arc-4 PR-#4 P1 review fix regression — MOMENTUM card + RAM speed
# bonus used to compound multiplicatively-then-additively in `speed`,
# with no single source of truth: _momentum_mult had a clamp(<=2.0) that
# was never read by _physics_process; the real mutation `speed = round(
# speed * 1.2)` was uncapped; _revert_archetype subtracted only the
# flat RAM_SPEED_BONUS, leaving permanent inflation when MOMENTUM landed
# during RAM.
#
# Compound bug (untested by test_breach_archetype_switch which never
# picked MOMENTUM):
#   RAM init: 32 + 6 = 38
#   MOMENTUM: round(38 * 1.2) = 46
#   _revert_archetype: 46 - 6 = 40   ← inflated by +2, base was 32×1.2=38
#
# Fix: _base_speed captured pre-archetype-init + _momentum_mult is the
# single multiplier source + _recompute_speed derives speed = round(
# base * mult) + (RAM ? RAM_SPEED_BONUS : 0). Revert composes cleanly.
#
# 7 cases:
#   1. _base_speed captures from _ready (default 32).
#   2. RAM init: speed = base + RAM_SPEED_BONUS (no MOMENTUM).
#   3. RAM → DEFAULT revert: speed = base (no MOMENTUM).
#   4. MOMENTUM (DEFAULT archetype): speed = round(base * 1.2).
#   5. MOMENTUM during RAM: speed = round(base * 1.2) + RAM_SPEED_BONUS.
#   6. Revert from RAM (after MOMENTUM pick): speed = round(base * 1.2)
#      (NOT base — MOMENTUM persists; NOT inflated).
#   7. MOMENTUM cap at 2.0× base: speed plateaus, no runaway after
#      4+ picks.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_momentum_ram_compose.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _make() -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	root.add_child(pt)
	return pt


func _initialize() -> void:
	# === Case 1: _base_speed captured from _ready.
	var pt1 := _make()
	await process_frame
	if pt1._base_speed != 32:
		push_error("FAIL — _base_speed=%d (want 32 from default @export speed)" % pt1._base_speed)
		quit(1); return
	if pt1.speed != 32:
		push_error("FAIL — initial speed=%d (want 32; DEFAULT archetype, no MOMENTUM)" % pt1.speed)
		quit(1); return
	print("  case 1: _base_speed captured (32); initial speed = base (DEFAULT, no MOMENTUM)")
	pt1.queue_free()
	await process_frame

	# === Case 2: RAM init + revert (no MOMENTUM).
	var pt2 := _make()
	await process_frame
	pt2.switch_archetype(PlayerTankT.TankArchetype.RAM)
	if pt2.speed != 32 + pt2.RAM_SPEED_BONUS:
		push_error("FAIL — RAM speed=%d (want 38)" % pt2.speed)
		quit(1); return
	print("  case 2: RAM init → speed = base + RAM_SPEED_BONUS (38)")

	# === Case 3: RAM → DEFAULT revert.
	pt2.switch_archetype(PlayerTankT.TankArchetype.DEFAULT)
	if pt2.speed != 32:
		push_error("FAIL — DEFAULT after RAM speed=%d (want 32; no MOMENTUM)" % pt2.speed)
		quit(1); return
	print("  case 3: RAM → DEFAULT revert → speed = base (32)")
	pt2.queue_free()
	await process_frame

	# === Case 4: MOMENTUM card alone (DEFAULT archetype).
	var pt4 := _make()
	await process_frame
	pt4._apply_card(UpgradeCatalogT.CardKind.MOMENTUM)
	if pt4._momentum_mult < 1.19 or pt4._momentum_mult > 1.21:
		push_error("FAIL — _momentum_mult=%.3f (want ~1.2 after 1 MOMENTUM pick)" % pt4._momentum_mult)
		quit(1); return
	var want_speed: int = int(round(32 * 1.2))  # 38
	if pt4.speed != want_speed:
		push_error("FAIL — MOMENTUM-only speed=%d (want %d = round(32*1.2))" % [pt4.speed, want_speed])
		quit(1); return
	print("  case 4: MOMENTUM alone → speed = round(32*1.2) = %d (DEFAULT)" % pt4.speed)

	# === Case 5: MOMENTUM during RAM.
	pt4.switch_archetype(PlayerTankT.TankArchetype.RAM)
	# After switch: _recompute_speed runs again → round(32*1.2)=38 + 6 = 44.
	var want_ram_mom: int = int(round(32 * 1.2)) + pt4.RAM_SPEED_BONUS
	if pt4.speed != want_ram_mom:
		push_error("FAIL — RAM+MOMENTUM speed=%d (want %d = round(32*1.2)+6)" % [pt4.speed, want_ram_mom])
		quit(1); return
	print("  case 5: MOMENTUM + RAM compose → speed = %d (round(32*1.2)+6)" % pt4.speed)

	# === Case 6: revert RAM (after MOMENTUM): speed drops by exactly RAM_SPEED_BONUS,
	# NOT inflated. This is the compound-bug regression lock.
	pt4.switch_archetype(PlayerTankT.TankArchetype.DEFAULT)
	if pt4.speed != int(round(32 * 1.2)):
		push_error("FAIL — DEFAULT after RAM (with MOMENTUM) speed=%d (want %d; compound-bug regression)" \
				% [pt4.speed, int(round(32 * 1.2))])
		quit(1); return
	print("  case 6: revert RAM (post-MOMENTUM) → speed = %d (NOT inflated; compound-bug regression locked)" % pt4.speed)
	pt4.queue_free()
	await process_frame

	# === Case 7: MOMENTUM cap at 2.0× base.
	var pt7 := _make()
	await process_frame
	# Pick MOMENTUM 6 times — multiplier: 1.0 → 1.2 → 1.44 → 1.728 → ~2.07 capped → 2.0 → 2.0 → 2.0
	for i in 6:
		pt7._apply_card(UpgradeCatalogT.CardKind.MOMENTUM)
	if pt7._momentum_mult > 2.001:
		push_error("FAIL — _momentum_mult=%.3f after 6 MOMENTUM picks (cap at 2.0 broken)" % pt7._momentum_mult)
		quit(1); return
	var want_cap: int = int(round(32 * 2.0))
	if pt7.speed != want_cap:
		push_error("FAIL — capped MOMENTUM speed=%d (want %d = round(32*2.0))" % [pt7.speed, want_cap])
		quit(1); return
	print("  case 7: MOMENTUM cap → 6 picks → mult=%.3f, speed=%d (round(32*2.0)=%d)" \
			% [pt7._momentum_mult, pt7.speed, want_cap])

	print("BREACH_MOMENTUM_RAM_COMPOSE_OK 7 cases — base capture + RAM init/revert + MOMENTUM cap + compound regression")
	quit(0)
