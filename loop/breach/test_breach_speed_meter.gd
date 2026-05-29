# Arc-4 breach mode: Round 24 Phase A widget 3 — speed meter (iter 275).
#
# The speed meter is a top-right HUD label that displays current speed
# normalized to the BC baseline (32), reflecting:
#   - RAM archetype init (speed 32 → 38 ≈ 1.2×)
#   - MOMENTUM upgrade card (speed * 1.2)
#   - OVERDRIVE burst (speed * overdrive_mult while _overdrive_timer > 0)
#
# Verifies:
#   1. Procedural baseline (loadout == null) does NOT build _speed_label
#      (loadout-gated contract; arc-2/3 HUD bit-identical).
#   2. Breach mode with default speed (32): label = "SPD 1.0×".
#   3. After MOMENTUM-style speed boost (32 → 38): label = "SPD 1.2×".
#   4. During overdrive burst (speed=32, _overdrive_timer > 0,
#      overdrive_mult=1.6): label = "SPD 1.6×", color is cyan boost tier.
#   5. Boost ≥ 1.5× shifts color to yellow tier.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_speed_meter.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === Case A: procedural baseline — label not built.
	var holder_a := Node2D.new()
	root.add_child(holder_a)
	var pt_a: Node = PlayerTankScene.instantiate()
	holder_a.add_child(pt_a)
	await process_frame
	await process_frame
	if pt_a._speed_label != null:
		push_error("FAIL — procedural baseline built _speed_label (must be null without loadout)")
		quit(1); return
	print("  procedural baseline: _speed_label not built (loadout-gated contract holds)")
	pt_a.queue_free()
	await process_frame

	# === Case B: breach mode (loadout != null) — meter built + reads baseline 1.0×.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	if pt._speed_label == null:
		push_error("FAIL — _speed_label not built in breach mode (expected loadout-gated build)")
		quit(1); return
	# Verify it's parented to the HUD canvas.
	var hud: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	if hud == null:
		push_error("FAIL — PlayerTank HUD canvas not found")
		quit(1); return
	var on_hud: bool = false
	for c in hud.get_children():
		if c == pt._speed_label:
			on_hud = true
			break
	if not on_hud:
		push_error("FAIL — _speed_label not parented to HUD")
		quit(1); return
	# Default speed should be 32 (BC baseline).
	pt.speed = 32
	pt._overdrive_timer = 0.0
	pt._update_speed_meter()
	if pt._speed_label.text != "SPD 1.0×":
		push_error("FAIL — baseline label = '%s', want 'SPD 1.0×'" % pt._speed_label.text)
		quit(1); return
	print("  case B baseline (speed=32): label = '%s'" % pt._speed_label.text)

	# === Case C: MOMENTUM-style boost (speed 32 → 38) → ratio 1.19 → "SPD 1.2×".
	pt.speed = 38
	pt._update_speed_meter()
	if pt._speed_label.text != "SPD 1.2×":
		push_error("FAIL — speed=38 label = '%s', want 'SPD 1.2×'" % pt._speed_label.text)
		quit(1); return
	print("  MOMENTUM-style (speed=38): label = '%s'" % pt._speed_label.text)

	# === Case D: overdrive burst (speed=32, overdrive_mult=1.6, timer active) → "SPD 1.6×".
	pt.speed = 32
	pt.overdrive_mult = 1.6
	pt._overdrive_timer = 0.5
	pt._update_speed_meter()
	if pt._speed_label.text != "SPD 1.6×":
		push_error("FAIL — overdrive label = '%s', want 'SPD 1.6×'" % pt._speed_label.text)
		quit(1); return
	# Color should be cyan tier under overdrive.
	var color_under_burst: Color = pt._speed_label.get_theme_color("font_color")
	if absf(color_under_burst.b - 1.0) > 0.05 or color_under_burst.r > 0.7:
		push_error("FAIL — overdrive color = %s, want cyan-tier (high blue, low red)" \
				% str(color_under_burst))
		quit(1); return
	print("  overdrive (32 × 1.6): label = '%s', color = %s (cyan tier)" \
			% [pt._speed_label.text, str(color_under_burst)])

	# === Case E: boost ≥ 1.5× (speed=48 → 1.5×) shifts color to yellow tier.
	pt._overdrive_timer = 0.0
	pt.speed = 48
	pt._update_speed_meter()
	if pt._speed_label.text != "SPD 1.5×":
		push_error("FAIL — speed=48 label = '%s', want 'SPD 1.5×'" % pt._speed_label.text)
		quit(1); return
	var color_yellow: Color = pt._speed_label.get_theme_color("font_color")
	# Yellow tier = high R, high G, low B.
	if color_yellow.r < 0.9 or color_yellow.b > 0.5:
		push_error("FAIL — high-boost color = %s, want yellow tier" % str(color_yellow))
		quit(1); return
	print("  high boost (speed=48 → 1.5×): label = '%s', color = %s (yellow tier)" \
			% [pt._speed_label.text, str(color_yellow)])

	print("BREACH_SPEED_METER_OK speed meter built + baseline + boost + overdrive verified")
	quit(0)
