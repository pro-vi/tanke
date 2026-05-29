# Arc-4 breach mode: shell codex verifier (Round 5, iter 36 — playtest
# findings 2-3: "no tutorial" + "I don't understand the shells").
# Verifies a breach PlayerTank builds a ShellCodex overlay that names
# all 4 shells + their terrain roles, is visible at run start, and
# hides on _dismiss_codex(); an arc-2/3 PlayerTank builds none.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_codex.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === Breach PlayerTank: loadout set → a ShellCodex overlay.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	root.add_child(pt)
	await process_frame

	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — no HUD CanvasLayer"); quit(1); return
	var codex: ColorRect = hud.get_node_or_null("ShellCodex") as ColorRect
	if codex == null:
		push_error("FAIL — breach PlayerTank has no ShellCodex overlay")
		quit(1); return
	if not codex.visible:
		push_error("FAIL — codex not visible at run start"); quit(1); return

	# Gather all label text in the codex.
	var blob: String = ""
	for child in codex.get_children():
		if child is Label:
			blob += (child as Label).text + " | "
	# Every shell + the two hard-terrain roles must be named.
	for token in ["AP", "HE", "HEAT", "APCR", "BRICK", "STEEL"]:
		if blob.find(token) == -1:
			push_error("FAIL — codex never mentions '%s': %s" % [token, blob])
			quit(1); return
	print("  codex names all 4 shells + BRICK/STEEL roles")

	# arc-4 iter 51: the codex also renders the meta unlock ladder.
	for token in ["UNLOCKS", "DIVIDEND", "OVERDRIVE", "SWAP", "SALVAGE"]:
		if blob.find(token) == -1:
			push_error("FAIL — codex never renders unlock-ladder '%s': %s" % [token, blob])
			quit(1); return
	print("  codex renders the 4-rung unlock ladder")

	# Dismiss hides it.
	pt._dismiss_codex()
	if codex.visible:
		push_error("FAIL — _dismiss_codex did not hide the codex"); quit(1); return
	print("  _dismiss_codex hides the overlay")
	pt.queue_free()

	# === arc-2/3 PlayerTank: no loadout → no ShellCodex.
	var pt2: Node = PlayerTankScene.instantiate()
	root.add_child(pt2)
	await process_frame
	var hud2: CanvasLayer = pt2.get_node_or_null("HUD") as CanvasLayer
	if hud2 != null and hud2.get_node_or_null("ShellCodex") != null:
		push_error("FAIL — arc-2/3 PlayerTank built a ShellCodex (regression)")
		quit(1); return
	pt2.queue_free()

	print("BREACH_CODEX_OK shell codex names 4 shells + roles; arc-2/3 unaffected")
	quit(0)
