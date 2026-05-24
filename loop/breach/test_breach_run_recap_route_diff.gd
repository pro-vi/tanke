# Arc-4 breach mode: Round 16 BUILD-QUALITY — RunRecap.route_
# diff_clause (iter 121, Gap 4 from iter-106 diagnosis).
#
# The breach-prompt label below the death overlay now names
# BOTH the visited path AND the path-not-taken via route_diff_
# clause. Constraint-6 strongest form for ROUTE attribution.
#
# Output forms:
#   - "Visited: A > B; skipped: C, D." for partial walks
#   - "Route: A > B > C (full clear)." when no skips
#   - "" when either input is empty (degenerate; caller skips)
#
# Verifies:
#   1. Partial walk: visited [warmup, bunker], full
#      [warmup, maze, bunker, killbox, endgame] → "Visited:
#      warmup > bunker; skipped: maze, killbox, endgame."
#   2. Full clear: visited [a, b, c], full [a, b, c] → "Route:
#      a > b > c (full clear)."
#   3. Empty band_visit_log → ""
#   4. Empty full_route_names → ""
#   5. Out-of-order visit: visited [endgame, warmup] when full
#      [warmup, maze, bunker, killbox, endgame] → "Visited:
#      endgame > warmup; skipped: maze, bunker, killbox."
#      (preserves visit order in label; skipped names are
#      from full route minus visited)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_route_diff.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")


func _initialize() -> void:
	if not _test_partial_walk():
		quit(1); return
	if not _test_full_clear():
		quit(1); return
	if not _test_empty_visit_log():
		quit(1); return
	if not _test_empty_full_route():
		quit(1); return
	if not _test_out_of_order_visit():
		quit(1); return

	print("BREACH_RUN_RECAP_ROUTE_DIFF_OK 5 cases verified: partial/full/empty(×2)/out-of-order")
	quit(0)


func _make_recap_with_visits(visits: Array) -> RunRecapT:
	var rr: RunRecapT = RunRecapT.new()
	for v in visits:
		rr.enter_band(String(v))
	return rr


func _test_partial_walk() -> bool:
	var rr: RunRecapT = _make_recap_with_visits(["warmup", "bunker"])
	var full: Array = ["warmup", "maze", "bunker", "killbox", "endgame"]
	var s: String = rr.route_diff_clause(full)
	if s != "Visited: warmup > bunker; skipped: maze, killbox, endgame.":
		push_error("FAIL partial — got '%s'" % s)
		return false
	print("  partial walk → '%s'" % s)
	return true


func _test_full_clear() -> bool:
	var rr: RunRecapT = _make_recap_with_visits(["a", "b", "c"])
	var s: String = rr.route_diff_clause(["a", "b", "c"])
	if s != "Route: a > b > c (full clear).":
		push_error("FAIL full-clear — got '%s'" % s)
		return false
	print("  full clear → '%s'" % s)
	return true


func _test_empty_visit_log() -> bool:
	var rr: RunRecapT = RunRecapT.new()
	var s: String = rr.route_diff_clause(["a", "b"])
	if not s.is_empty():
		push_error("FAIL empty visit-log — got '%s', want ''" % s)
		return false
	print("  empty visit-log → '' (degenerate; caller skips)")
	return true


func _test_empty_full_route() -> bool:
	var rr: RunRecapT = _make_recap_with_visits(["a"])
	var s: String = rr.route_diff_clause([])
	if not s.is_empty():
		push_error("FAIL empty full-route — got '%s', want ''" % s)
		return false
	print("  empty full-route → '' (degenerate; caller skips)")
	return true


func _test_out_of_order_visit() -> bool:
	var rr: RunRecapT = _make_recap_with_visits(["endgame", "warmup"])
	var full: Array = ["warmup", "maze", "bunker", "killbox", "endgame"]
	var s: String = rr.route_diff_clause(full)
	# Visit order preserved in label (endgame > warmup); skipped
	# is full minus visited, in full-route order (maze, bunker,
	# killbox).
	if s != "Visited: endgame > warmup; skipped: maze, bunker, killbox.":
		push_error("FAIL out-of-order — got '%s'" % s)
		return false
	print("  out-of-order → '%s' (visit order preserved; skipped in full-route order)" % s)
	return true
