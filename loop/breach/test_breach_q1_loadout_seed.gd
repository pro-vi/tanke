# arc-4 PR-#4 Codex P1 review fix regression — Q1ProofRoom loadout
# starter reserves.
#
# Pre-fix: Q1ProofRoomScene._spawn_player assigned a fresh LoadoutT.new()
# with default he_reserve=heat_reserve=apcr_reserve=0. In live play
# PlayerTank._cycle_shell skips empty finite reserves and
# Loadout.consume falls back to AP, so the player could only fire AP
# in the proof room — the HE/HEAT/APCR route-currency lanes were
# unreachable without the synthetic-fire harness bypass.
#
# Fix: explicitly seed he/heat/apcr reserves on the proof-room loadout
# (5 / 3 / 4) so each lane is exercisable from the player's hands.
#
# 4 cases:
#   1. spawned_player.loadout.he_reserve > 0 (live HE-lane playable)
#   2. spawned_player.loadout.heat_reserve >= 2 (Heavy needs 2 HEAT)
#   3. spawned_player.loadout.apcr_reserve > 0 (APCR-lane playable)
#   4. Loadout.consume(HE/HEAT/APCR) returns the requested shell class,
#      not the AP fallback (proves the reserves work end-to-end).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_loadout_seed.gd

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# Instantiate Q1ProofRoom with enemy AI disabled for harness
	# determinism (per the iter-Codex-P2 opt-out pattern). Loadout
	# seed is independent of AI; default-ON wouldn't change it.
	var room: Node = Q1ProofRoomScene.instantiate()
	room.enable_enemy_ai = false
	root.add_child(room)
	await process_frame
	await process_frame
	if room.spawned_player == null:
		push_error("FAIL — spawned_player is null")
		quit(1); return
	if room.spawned_player.loadout == null:
		push_error("FAIL — spawned_player.loadout is null")
		quit(1); return

	var ld = room.spawned_player.loadout

	# === Case 1: HE reserve > 0.
	if int(ld.he_reserve) <= 0:
		push_error("FAIL — he_reserve=%d (want >0; HE lane would be unplayable; Codex P1 regression)" \
				% int(ld.he_reserve))
		quit(1); return
	print("  case 1: loadout.he_reserve = %d (HE lane playable)" % int(ld.he_reserve))

	# === Case 2: HEAT reserve >= 2 (the HEAT lane Heavy needs 2 HEAT to kill).
	if int(ld.heat_reserve) < 2:
		push_error("FAIL — heat_reserve=%d (want >=2 to kill the gate-row Heavy)" % int(ld.heat_reserve))
		quit(1); return
	print("  case 2: loadout.heat_reserve = %d (HEAT lane has enough to finish Heavy)" % int(ld.heat_reserve))

	# === Case 3: APCR reserve > 0.
	if int(ld.apcr_reserve) <= 0:
		push_error("FAIL — apcr_reserve=%d (want >0; APCR lane would be unplayable)" % int(ld.apcr_reserve))
		quit(1); return
	print("  case 3: loadout.apcr_reserve = %d (APCR lane playable)" % int(ld.apcr_reserve))

	# === Case 4: Loadout.consume returns the requested class, not AP fallback.
	var he_pre: int = int(ld.he_reserve)
	var consumed_he: int = int(ld.consume(BulletT.SHELL_CLASS_HE))
	if consumed_he != BulletT.SHELL_CLASS_HE:
		push_error("FAIL — consume(HE) returned %d (want HE=%d; reserve drained to AP fallback)" \
				% [consumed_he, BulletT.SHELL_CLASS_HE])
		quit(1); return
	if int(ld.he_reserve) != he_pre - 1:
		push_error("FAIL — consume(HE) didn't decrement he_reserve (%d → %d, want %d)" \
				% [he_pre, int(ld.he_reserve), he_pre - 1])
		quit(1); return

	var consumed_heat: int = int(ld.consume(BulletT.SHELL_CLASS_HEAT))
	if consumed_heat != BulletT.SHELL_CLASS_HEAT:
		push_error("FAIL — consume(HEAT) returned %d (want HEAT=%d)" \
				% [consumed_heat, BulletT.SHELL_CLASS_HEAT])
		quit(1); return

	var consumed_apcr: int = int(ld.consume(BulletT.SHELL_CLASS_APCR))
	if consumed_apcr != BulletT.SHELL_CLASS_APCR:
		push_error("FAIL — consume(APCR) returned %d (want APCR=%d)" \
				% [consumed_apcr, BulletT.SHELL_CLASS_APCR])
		quit(1); return
	print("  case 4: consume(HE) → HE; consume(HEAT) → HEAT; consume(APCR) → APCR (end-to-end)")

	print("BREACH_Q1_LOADOUT_SEED_OK 4 cases — all three finite-shell lanes seeded + consume returns requested class")
	quit(0)
