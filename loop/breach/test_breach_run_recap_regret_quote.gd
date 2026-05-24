# Arc-4 breach mode: Round 17 BUILD-QUALITY — RunRecap.regret_
# quote_candidate (iter 123, Gap 5 from iter-106 diagnosis;
# LAST iter-106 backlog item).
#
# Auto-generates a CANDIDATE QUESTION the player can confirm or
# deny in the playtest debrief. Per iter-106 anti-pattern note:
# better to GENERATE A QUESTION than a STATEMENT (avoids putting
# words in the player's mouth).
#
# Question forms:
#   - dry-on-X AND X matches canonical brief → "Could you have
#     held more X for BAND?" (under-budgeted the right resource)
#   - dry-on-X AND canonical brief is Y → "Did your [BUILD_TAG]
#     build fit BAND?" (wrong build for the pressure)
#   - else → "" (caller falls back to iter-78 generic prompt)
#
# Verifies:
#   1. Match form: dry-on-HE in brick_maze (canonical brief "HE")
#      → "Could you have held more HE for BRICK MAZE?"
#   2. Mismatch form: dry-on-HE in bunker_zone (canonical brief
#      "APCR 1-shots", BUILD_TAG "mixed breacher") → "Did your
#      MIXED BREACHER build fit BUNKER ZONE?"
#   3. Comfortable reserves → "" (no signal)
#   4. Not captured → "" (defensive)
#   5. Underscore→space conversion in BAND label (open_killbox
#      → OPEN KILLBOX, not OPEN_KILLBOX)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_regret_quote.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	if not _test_match_form(): quit(1); return
	if not _test_mismatch_form(): quit(1); return
	if not _test_comfortable_no_quote(): quit(1); return
	if not _test_not_captured(): quit(1); return
	if not _test_underscore_to_space(): quit(1); return

	print("BREACH_RUN_RECAP_REGRET_QUOTE_OK 5 cases verified: match/mismatch/comfortable/not-captured/underscore-replace")
	quit(0)


func _make_recap_dry_he_in_band(band_name: String) -> RunRecapT:
	var rr: RunRecapT = RunRecapT.new()
	rr.depth_reached = 95
	rr.killing_band = band_name
	rr.killing_pressure = "test pressure"
	rr.he_reserve_at_death = 0
	rr.heat_reserve_at_death = 2
	# Configure shells so build_tag returns "mixed breacher"
	# (no shell dominates: AP 14, HE 5, HEAT 2).
	rr.shells_fired[BulletT.SHELL_CLASS_AP] = 14
	rr.shells_fired[BulletT.SHELL_CLASS_HE] = 5
	rr.shells_fired[BulletT.SHELL_CLASS_HEAT] = 2
	rr.captured = true
	return rr


func _test_match_form() -> bool:
	# brick_maze canonical: brief is "HE" after em-dash split.
	var rr: RunRecapT = _make_recap_dry_he_in_band("brick_maze")
	var s: String = rr.regret_quote_candidate(
		"HE — open vertical lanes; trade shells for time")
	if s != "Could you have held more HE for BRICK MAZE?":
		push_error("FAIL match form — got '%s'" % s)
		return false
	print("  match form (dry-on-HE + canonical HE) → '%s'" % s)
	return true


func _test_mismatch_form() -> bool:
	# bunker_zone canonical: brief is "APCR 1-shots".
	var rr: RunRecapT = _make_recap_dry_he_in_band("bunker_zone")
	var s: String = rr.regret_quote_candidate(
		"APCR 1-shots; HEAT 2-shots entrenched heavies")
	if s != "Did your MIXED BREACHER build fit BUNKER ZONE?":
		push_error("FAIL mismatch form — got '%s'" % s)
		return false
	print("  mismatch form (dry-on-HE + canonical APCR + build mixed breacher) → '%s'" % s)
	return true


func _test_comfortable_no_quote() -> bool:
	var rr: RunRecapT = _make_recap_dry_he_in_band("bunker_zone")
	rr.he_reserve_at_death = 4
	rr.heat_reserve_at_death = 2
	var s: String = rr.regret_quote_candidate("APCR 1-shots")
	if not s.is_empty():
		push_error("FAIL comfortable — got '%s', want '' (no dry signal)" % s)
		return false
	print("  comfortable (no dry shells) → '' (no signal; caller falls back to generic prompt)")
	return true


func _test_not_captured() -> bool:
	var rr: RunRecapT = RunRecapT.new()
	# captured = false by default
	rr.he_reserve_at_death = 0
	var s: String = rr.regret_quote_candidate("HE")
	if not s.is_empty():
		push_error("FAIL not-captured — got '%s', want '' (defensive)" % s)
		return false
	print("  not captured → '' (defensive)")
	return true


func _test_underscore_to_space() -> bool:
	var rr: RunRecapT = _make_recap_dry_he_in_band("open_killbox")
	var s: String = rr.regret_quote_candidate("AP precision")
	# Build_tag is "mixed breacher". Brief "AP precision" → no
	# HE word boundary → mismatch form.
	if not ("OPEN KILLBOX" in s):
		push_error("FAIL underscore — got '%s'; expected 'OPEN KILLBOX' (underscore replaced)" % s)
		return false
	if "OPEN_KILLBOX" in s:
		push_error("FAIL underscore — got '%s'; still contains 'OPEN_KILLBOX' (underscore not replaced)" % s)
		return false
	print("  underscore→space (open_killbox → OPEN KILLBOX): '%s'" % s)
	return true
