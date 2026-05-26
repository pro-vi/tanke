# Arc-4 iter 298 (user feedback #2 — z-index audit):
# Verifies the HUD z-index hierarchy. The audit doc at
# loop/breach/iter-298-z-index-audit.md names the contract:
#
#   HUD_Z_BASE        = 0   — base HUD (HP bar, reload bar, chips, etc.)
#   HUD_Z_RUN_CONTEXT = 1   — route panel, active-cards ribbon, shell tray
#   HUD_Z_INFO        = 10  — shell codex
#   HUD_Z_MODAL       = 20  — archetype pick / levelup pick / depot
#   HUD_Z_DEATH       = 30  — death panel + label + restart hint + breach prompt
#   HUD_Z_BANNER      = 35  — band-arrival banner
#   HUD_Z_TOAST       = 40  — pickup toasts (always reach the player)
#
# Verifies the contract holds at runtime:
#   1. Constants are correctly ordered (BASE < RUN_CONTEXT < INFO < MODAL < DEATH < BANNER < TOAST).
#   2. Built panels carry the right z_index — death panel == HUD_Z_DEATH,
#      active-cards panel == HUD_Z_RUN_CONTEXT.
#   3. Lazy popups (archetype + levelup) get HUD_Z_MODAL when built.
#   4. A pickup toast fired AFTER the death overlay shows renders ABOVE it.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hud_z_stack.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === Case 1: constants strictly ordered.
	if not (PlayerTankT.HUD_Z_BASE < PlayerTankT.HUD_Z_RUN_CONTEXT \
			and PlayerTankT.HUD_Z_RUN_CONTEXT < PlayerTankT.HUD_Z_INFO \
			and PlayerTankT.HUD_Z_INFO < PlayerTankT.HUD_Z_MODAL \
			and PlayerTankT.HUD_Z_MODAL < PlayerTankT.HUD_Z_DEATH \
			and PlayerTankT.HUD_Z_DEATH < PlayerTankT.HUD_Z_BANNER \
			and PlayerTankT.HUD_Z_BANNER < PlayerTankT.HUD_Z_TOAST):
		push_error("FAIL — HUD_Z_* constants out of order")
		quit(1); return
	print("  constants: BASE(%d) < RUN_CONTEXT(%d) < INFO(%d) < MODAL(%d) < DEATH(%d) < BANNER(%d) < TOAST(%d)" % [
		PlayerTankT.HUD_Z_BASE, PlayerTankT.HUD_Z_RUN_CONTEXT,
		PlayerTankT.HUD_Z_INFO, PlayerTankT.HUD_Z_MODAL,
		PlayerTankT.HUD_Z_DEATH, PlayerTankT.HUD_Z_BANNER,
		PlayerTankT.HUD_Z_TOAST,
	])

	# === Case 2-3: built panels carry the right z_index.
	var holder := Node2D.new()
	root.add_child(holder)
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	if pt._death_panel == null:
		push_error("FAIL — death panel not built")
		quit(1); return
	if pt._death_panel.z_index != PlayerTankT.HUD_Z_DEATH:
		push_error("FAIL — death panel z_index = %d, want HUD_Z_DEATH(%d)" \
				% [pt._death_panel.z_index, PlayerTankT.HUD_Z_DEATH])
		quit(1); return
	if pt._active_cards_panel == null:
		push_error("FAIL — active-cards panel not built")
		quit(1); return
	if pt._active_cards_panel.z_index != PlayerTankT.HUD_Z_RUN_CONTEXT:
		push_error("FAIL — active-cards panel z_index = %d, want HUD_Z_RUN_CONTEXT(%d)" \
				% [pt._active_cards_panel.z_index, PlayerTankT.HUD_Z_RUN_CONTEXT])
		quit(1); return
	if pt._shell_codex == null:
		push_error("FAIL — shell codex not built")
		quit(1); return
	if pt._shell_codex.z_index != PlayerTankT.HUD_Z_INFO:
		push_error("FAIL — shell codex z_index = %d, want HUD_Z_INFO(%d)" \
				% [pt._shell_codex.z_index, PlayerTankT.HUD_Z_INFO])
		quit(1); return
	print("  built panels: death=%d, active-cards=%d, codex=%d (match constants)" % [
		pt._death_panel.z_index, pt._active_cards_panel.z_index, pt._shell_codex.z_index,
	])

	# Lazy popups: trigger build by setting force_archetype_select then ready
	# Actually they're built on-demand by _build_archetype_panel/_build_levelup_panel.
	# Call them directly.
	var canvas: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	pt._build_archetype_panel(canvas)
	pt._build_levelup_panel(canvas)
	if pt._archetype_panel == null or pt._archetype_panel.z_index != PlayerTankT.HUD_Z_MODAL:
		push_error("FAIL — archetype panel z_index = %s, want HUD_Z_MODAL(%d)" \
				% [str(pt._archetype_panel.z_index if pt._archetype_panel else "null"), PlayerTankT.HUD_Z_MODAL])
		quit(1); return
	if pt._levelup_panel == null or pt._levelup_panel.z_index != PlayerTankT.HUD_Z_MODAL:
		push_error("FAIL — levelup panel z_index = %s, want HUD_Z_MODAL(%d)" \
				% [str(pt._levelup_panel.z_index if pt._levelup_panel else "null"), PlayerTankT.HUD_Z_MODAL])
		quit(1); return
	print("  lazy popups: archetype=%d, levelup=%d (both HUD_Z_MODAL)" % [
		pt._archetype_panel.z_index, pt._levelup_panel.z_index,
	])

	# === Case 4: pickup toast spawned during death overlay renders ABOVE it.
	pt._show_pickup_toast("+1 HP", Color.WHITE)
	var toast: Node = null
	for c in canvas.get_children():
		if c is Label and c.has_meta("is_pickup_toast"):
			toast = c
			break
	if toast == null:
		push_error("FAIL — pickup toast not found on canvas")
		quit(1); return
	if toast.z_index <= pt._death_panel.z_index:
		push_error("FAIL — toast z_index %d not above death panel z_index %d" \
				% [toast.z_index, pt._death_panel.z_index])
		quit(1); return
	print("  pickup toast z_index %d > death panel z_index %d (always-reach contract held)" % [
		toast.z_index, pt._death_panel.z_index,
	])

	print("BREACH_HUD_Z_STACK_OK 4 cases — constants ordered + built panels + lazy popups + toast-above-death")
	quit(0)
