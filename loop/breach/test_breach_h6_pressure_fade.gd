# Arc-4 iter 294 (consult-001 H6 visibility classes, conf 0.81 —
# user direction Option A at iter-294 AskUserQuestion):
# Verifies the pressure-fade behavior for run-context HUD strips.
#
# H6 design: combat-critical widgets (HP / reload bar / reload pip /
# shell chips / speed meter) stay at full alpha. Run-context strips
# (active-cards ribbon + route panel) fade to H6_FADE_ALPHA during
# H6_PRESSURE_WINDOW_S seconds after firing; restore to H6_FULL_ALPHA
# when the player has not fired recently.
#
# Verifies:
#   1. Initial state (no fires): _is_high_pressure() == false;
#      active_cards_panel.modulate.a == FULL; route_panel.modulate.a == FULL.
#   2. After simulated fire (sets _last_fire_time = now): _is_high_pressure()
#      == true; both panels' alpha == FADE.
#   3. After H6_PRESSURE_WINDOW_S elapsed (simulate by setting
#      _last_fire_time far in past): _is_high_pressure() == false; alpha
#      restored to FULL.
#   4. Procedural baseline (loadout == null) does not panic — neither
#      panel is built; _update_h6_pressure_fade no-ops without error.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_h6_pressure_fade.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === Case 1: initial state — no fires, full alpha.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	# active-cards ribbon panel exists when loadout is set (built in
	# _setup_hud). Route panel is BUILD-DEFERRED via call_deferred and
	# needs _run_band_route() to be non-empty — requires a real breach
	# config in the parent. In this minimal harness route_panel may be
	# null; H6 modulation null-guards both, so we verify active-cards
	# behavior here and note route as conditional.
	if pt._active_cards_panel == null:
		push_error("FAIL — _active_cards_panel not built (pre-condition)")
		quit(1); return
	var route_built: bool = pt._route_panel != null

	# Initial: no fires → not high pressure
	if pt._is_high_pressure():
		push_error("FAIL — fresh player should NOT be high pressure; _last_fire_time = %.2f" \
				% pt._last_fire_time)
		quit(1); return
	pt._update_h6_pressure_fade()
	if absf(pt._active_cards_panel.modulate.a - PlayerTankT.H6_FULL_ALPHA) > 0.01:
		push_error("FAIL — initial active-cards alpha = %.2f, want %.2f" \
				% [pt._active_cards_panel.modulate.a, PlayerTankT.H6_FULL_ALPHA])
		quit(1); return
	if route_built and absf(pt._route_panel.modulate.a - PlayerTankT.H6_FULL_ALPHA) > 0.01:
		push_error("FAIL — initial route alpha = %.2f, want %.2f" \
				% [pt._route_panel.modulate.a, PlayerTankT.H6_FULL_ALPHA])
		quit(1); return
	print("  case 1: initial — no fires, panel(s) at FULL alpha (%.2f); route built=%s" \
			% [PlayerTankT.H6_FULL_ALPHA, "yes" if route_built else "no (V1 minimal harness)"])

	# === Case 2: simulated fire → high pressure → fade.
	pt._last_fire_time = Time.get_ticks_msec() / 1000.0
	if not pt._is_high_pressure():
		push_error("FAIL — after _last_fire_time = now, _is_high_pressure() should be true")
		quit(1); return
	pt._update_h6_pressure_fade()
	if absf(pt._active_cards_panel.modulate.a - PlayerTankT.H6_FADE_ALPHA) > 0.01:
		push_error("FAIL — high-pressure active-cards alpha = %.2f, want %.2f" \
				% [pt._active_cards_panel.modulate.a, PlayerTankT.H6_FADE_ALPHA])
		quit(1); return
	if route_built and absf(pt._route_panel.modulate.a - PlayerTankT.H6_FADE_ALPHA) > 0.01:
		push_error("FAIL — high-pressure route alpha = %.2f, want %.2f" \
				% [pt._route_panel.modulate.a, PlayerTankT.H6_FADE_ALPHA])
		quit(1); return
	print("  case 2: just-fired — panel(s) faded to %.2f (combat focus)" \
			% PlayerTankT.H6_FADE_ALPHA)

	# === Case 3: simulate window expiry → restore.
	pt._last_fire_time = Time.get_ticks_msec() / 1000.0 - (PlayerTankT.H6_PRESSURE_WINDOW_S + 0.5)
	if pt._is_high_pressure():
		push_error("FAIL — after window expiry, _is_high_pressure() should be false")
		quit(1); return
	pt._update_h6_pressure_fade()
	if absf(pt._active_cards_panel.modulate.a - PlayerTankT.H6_FULL_ALPHA) > 0.01:
		push_error("FAIL — post-window active-cards alpha = %.2f, want %.2f" \
				% [pt._active_cards_panel.modulate.a, PlayerTankT.H6_FULL_ALPHA])
		quit(1); return
	if route_built and absf(pt._route_panel.modulate.a - PlayerTankT.H6_FULL_ALPHA) > 0.01:
		push_error("FAIL — post-window route alpha = %.2f, want %.2f" \
				% [pt._route_panel.modulate.a, PlayerTankT.H6_FULL_ALPHA])
		quit(1); return
	print("  case 3: post-window — panel(s) restored to FULL %.2f (calm)" \
			% PlayerTankT.H6_FULL_ALPHA)
	pt.queue_free()
	await process_frame

	# === Case 4: procedural baseline — no panels built, no crash.
	var holder_b := Node2D.new()
	root.add_child(holder_b)
	var pt_b: Node = PlayerTankScene.instantiate()
	# loadout left null
	holder_b.add_child(pt_b)
	await process_frame
	await process_frame
	if pt_b._active_cards_panel != null or pt_b._route_panel != null:
		push_error("FAIL — procedural baseline built H6-affected panels (must be null without loadout)")
		quit(1); return
	# Direct call must NOT crash (defensive null-guard).
	pt_b._update_h6_pressure_fade()
	print("  case 4: procedural baseline — panels null, _update_h6_pressure_fade silent no-op")

	print("BREACH_H6_PRESSURE_FADE_OK 4 cases — initial FULL / fired FADED / post-window FULL / baseline silent")
	quit(0)
