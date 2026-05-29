# Arc-4 breach mode: P1-C regression — BandBanner Labels must NOT
# stack on Y-boundary oscillation (iter 102, code-review-iter-100).
#
# Before the fix: each `breach_band_changed` emit spawned a new Label
# named "BandBanner" via _show_band_banner, with a 1.3s interval +
# 0.9s fade tween before queue_free. A Y-position oscillating across
# a band boundary emits multiple band changes per second, stacking
# Labels at position (20, 58) on the HUD CanvasLayer until the
# slowest tween finishes.
#
# After the fix: PlayerTank tracks `_band_banner: Label`. Each call
# to _show_band_banner frees the prior live banner before spawning
# the next. Result: HUD always has ≤1 BandBanner.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_band_banner_stacking.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


class _BandStub extends RefCounted:
	var band_name: String = ""
	var dominant_pressure: String = ""


# Count by TEXT signature ("ENTERING:" prefix) rather than name —
# when prior banners are queue_free'd but not yet culled, the name
# "BandBanner" is still reserved in the tree, so add_child auto-
# renames new ones to "@Label@37" etc. The text content is the
# stable signature for our purposes (it identifies the banner kind
# regardless of Godot's auto-naming behavior).
func _count_band_banners(hud: CanvasLayer) -> int:
	var n: int = 0
	for child in hud.get_children():
		if child is Label and (child as Label).text.begins_with("ENTERING:"):
			if is_instance_valid(child) and not child.is_queued_for_deletion():
				n += 1
	return n


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame

	var hud: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	if hud == null:
		push_error("FAIL — PlayerTank HUD canvas not found")
		quit(1); return

	# === First crossing — one banner appears.
	var b1 := _BandStub.new()
	b1.band_name = "warmup"
	b1.dominant_pressure = "open ground"
	pt._show_band_banner(b1)
	await process_frame
	var c1: int = _count_band_banners(hud)
	if c1 != 1:
		push_error("FAIL — after 1st banner: BandBanner count = %d, want 1" % c1)
		quit(1); return
	print("  after 1st crossing: 1 BandBanner")

	# === Oscillate: 4 rapid crossings. Pre-fix this would leave 5
	# banners stacked (1 from above + 4 here). Post-fix: still 1.
	for i in 4:
		var b := _BandStub.new()
		b.band_name = "bunker_%d" % i
		b.dominant_pressure = "armored grind"
		pt._show_band_banner(b)
	# Do NOT `await process_frame` here — that would let the queued
	# free's flush AND let the tween_callback for previously-freed
	# banners step, potentially freeing the LATEST banner too. We
	# want to inspect the tree immediately after the synchronous
	# burst of band changes. The fix's correctness is observable
	# right now: 4 freed + 1 alive = 1 alive.
	var c2: int = _count_band_banners(hud)
	if c2 != 1:
		# Diagnostic dump if it fails — list every BandBanner-named
		# child + their queued state.
		var dump: Array = []
		for child in hud.get_children():
			if child is Label and String(child.name).begins_with("BandBanner"):
				dump.append("%s queued=%s text=%s" % [
					child.name,
					child.is_queued_for_deletion(),
					(child as Label).text])
		push_error("FAIL — after 4 rapid oscillations: BandBanner count = %d, want 1 (dump: %s)" \
				% [c2, str(dump)])
		quit(1); return
	print("  after 4 rapid oscillations: 1 BandBanner alive (4 prior queued for deletion)")

	# === Verify the surviving banner is the LATEST one (bunker_3),
	# not the first (warmup) — confirms we free the prior, not the
	# new one.
	var found_latest: bool = false
	for child in hud.get_children():
		if child is Label and (child as Label).text.begins_with("ENTERING:"):
			if is_instance_valid(child) and not child.is_queued_for_deletion() \
					and "BUNKER 3" in (child as Label).text:
				found_latest = true
				break
	if not found_latest:
		push_error("FAIL — surviving banner is not the latest (BUNKER 3) — freed wrong banner")
		quit(1); return
	print("  surviving banner is the LATEST (BUNKER 3) — correct cleanup direction")

	print("BREACH_BAND_BANNER_STACKING_OK band-banner cleanup verified — no HUD leak")
	quit(0)
