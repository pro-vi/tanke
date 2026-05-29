# Arc-4 breach mode: P2-C regression — _highlight_route_cell must
# preserve the "cleared" tint on cells visited and retreated-from
# (iter 104, code-review-iter-100).
#
# Before the fix: `i < idx` painted cells behind the current band
# as cleared. Climbing to band 3 then retreating to band 1 made
# cells 2-3 lose their cleared tint (since 2 > 1, 3 > 1). The
# route strip should reflect "I visited these bands" not "I'm
# below these bands right now."
#
# After the fix: `_route_max_cleared_idx` tracks the highest idx
# ever reached. Cells `<= _route_max_cleared_idx and != idx`
# stay cleared. Retreats no longer flicker the tint.
#
# Verifies:
#   1. After climbing 0 → 1 → 2 → 3, cells 0-2 are cleared, 3 is
#      current, _route_max_cleared_idx = 3.
#   2. After retreating to idx=1: cell 1 is current; cells 0, 2,
#      3 ALL stay cleared (cells 2 + 3 preserved by max-cleared
#      tracking; pre-fix would have lost them).
#   3. Climbing back to idx=2: cell 2 is current; cells 0, 1, 3
#      stay cleared.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_route_strip_max_cleared.gd

extends SceneTree

const PlayerTankT = preload("res://scripts/PlayerTank.gd")

# Cleared tint (cells visited but not current): the iter-50 green
# tint that `_highlight_route_cell` paints. Matches the value in
# the function body.
const CLEARED_BG: Color = Color(0.32, 0.55, 0.36, 0.4)
const CURRENT_BG: Color = Color(0.95, 0.95, 0.55, 0.5)
const AHEAD_BG: Color = Color(0, 0, 0, 0)


func _initialize() -> void:
	# Drive _highlight_route_cell directly on a PlayerTank with a
	# manually-wired route strip. We don't need the breach level —
	# just enough state for the function to paint.
	var pt = PlayerTankT.new()
	# Wire a synthetic 4-cell route strip. Each cell needs a bg
	# (ColorRect) + label (Label) — _highlight_route_cell mutates
	# bg.color and label.modulate.
	for i in 4:
		pt._route_cell_bgs.append(ColorRect.new())
		pt._route_cell_labels.append(Label.new())
		pt._route_bands.append(_BandStub.new())

	# === Climb 0 → 1 → 2 → 3.
	for i in 4:
		pt._highlight_route_cell(i)

	if pt._route_max_cleared_idx != 3:
		push_error("FAIL — after climb to idx=3, _route_max_cleared_idx = %d, want 3" \
				% pt._route_max_cleared_idx)
		quit(1); return
	for i in 4:
		var want: Color
		if i == 3:
			want = CURRENT_BG
		else:
			want = CLEARED_BG
		if pt._route_cell_bgs[i].color != want:
			push_error("FAIL — after climb to 3: cell[%d].color = %s, want %s" \
					% [i, pt._route_cell_bgs[i].color, want])
			quit(1); return
	print("  climb 0→1→2→3: cells 0-2 cleared, 3 current; max_cleared_idx = 3")

	# === Retreat to idx=1. Cells 0,2,3 ALL stay cleared.
	pt._highlight_route_cell(1)
	if pt._route_max_cleared_idx != 3:
		push_error("FAIL — after retreat to 1: _route_max_cleared_idx = %d, want 3 (must not decrease)" \
				% pt._route_max_cleared_idx)
		quit(1); return
	for i in 4:
		var want: Color
		if i == 1:
			want = CURRENT_BG
		else:
			want = CLEARED_BG  # 0, 2, 3 all visited
		if pt._route_cell_bgs[i].color != want:
			push_error("FAIL — after retreat to 1: cell[%d].color = %s, want %s (pre-fix would lose cells 2,3 tint)" \
					% [i, pt._route_cell_bgs[i].color, want])
			quit(1); return
	print("  retreat to 1: cell 1 current; cells 0, 2, 3 stay cleared (max_cleared_idx unchanged)")

	# === Climb back to idx=2.
	pt._highlight_route_cell(2)
	for i in 4:
		var want: Color
		if i == 2:
			want = CURRENT_BG
		else:
			want = CLEARED_BG
		if pt._route_cell_bgs[i].color != want:
			push_error("FAIL — after climb back to 2: cell[%d].color = %s, want %s" \
					% [i, pt._route_cell_bgs[i].color, want])
			quit(1); return
	print("  climb back to 2: cell 2 current; cells 0, 1, 3 stay cleared")

	# Hygiene: free the orphaned ColorRect + Label nodes (we built
	# them outside a tree, so they don't have a parent to clean up).
	for bg in pt._route_cell_bgs:
		bg.free()
	for lbl in pt._route_cell_labels:
		lbl.free()
	pt.queue_free()
	print("BREACH_ROUTE_STRIP_MAX_CLEARED_OK retreat preserves cleared tint on visited cells")
	quit(0)


class _BandStub extends RefCounted:
	var band_name: String = ""
