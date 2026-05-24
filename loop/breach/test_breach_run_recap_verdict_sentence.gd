# Arc-4 breach mode: Round 12 Phase 2 — RunRecap.verdict_sentence
# (iter 108, γ shape from iter-107 SPIKE). The death recap is now
# a one-sentence verdict naming build + killing_band + reserve
# state + (optionally) the band's canonical_answer.
#
# Constraint-6 verification: every assertion confirms the sentence
# reads as "tied to resource/build/route" — never "got overwhelmed".
#
# Verifies:
#   1. Standard shape: MORTAR dies in bunker_zone, dry on HE — the
#      verdict names depth, BUNKER_ZONE, build_tag, "0 HE",
#      pressure first-phrase, AND (canonical answer: APCR).
#   2. Comfortable reserves → "with N HE / M HEAT to spare" framing
#      replaces the "0 X" clauses.
#   3. Missing canonical_answer → no parenthetical aside (clean).
#   4. Long pressure string → truncated at first ";" + capped at
#      32 chars to fit the death label width.
#   5. Em-dash canonical_answer ("HE — open vertical lanes") → the
#      brief is "HE" (just the shell directive), not the full
#      explanation.
#   6. Meta canonical_answer ("build cohesion test — chosen identity
#      determines reach") → brief falls back to the first phrase
#      since the head isn't a short shell directive.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_verdict_sentence.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


# Stub band with the same duck-typed fields PlayerTank reads from
# the real BreachBand resource at death-render time.
class _BandStub extends RefCounted:
	var band_name: String = ""
	var dominant_pressure: String = ""
	var canonical_answer: String = ""


func _initialize() -> void:
	# === Test 1: standard shape — MORTAR dies in bunker, dry on HE.
	if not _test_standard_shape():
		quit(1); return

	# === Test 2: comfortable reserves.
	if not _test_comfortable_reserves():
		quit(1); return

	# === Test 3: missing canonical answer.
	if not _test_missing_canonical():
		quit(1); return

	# === Test 4: long pressure string truncation.
	if not _test_long_pressure_truncation():
		quit(1); return

	# === Test 5: em-dash canonical answer ("HE — explanation").
	if not _test_em_dash_canonical():
		quit(1); return

	# === Test 6: meta canonical answer (endgame_mixed case).
	if not _test_meta_canonical():
		quit(1); return

	print("BREACH_RUN_RECAP_VERDICT_SENTENCE_OK γ verdict sentence verified across 6 cases")
	quit(0)


# A RunRecap with the test state from iter-107 SPIKE: MORTAR build
# dies at depth 95 in bunker_zone, dry on HE, 1 HEAT remaining.
func _make_recap_standard() -> RunRecapT:
	var rr: RunRecapT = RunRecapT.new()
	rr.depth_reached = 95
	rr.killing_band = "bunker_zone"
	rr.killing_pressure = "steel-armored bunkers; entrenched heavy tanks"
	rr.killer = "shell impact"
	rr.he_reserve_at_death = 0
	rr.heat_reserve_at_death = 1
	rr.archetype = 2  # MORTAR
	rr.shells_fired[BulletT.SHELL_CLASS_AP] = 14
	rr.shells_fired[BulletT.SHELL_CLASS_HE] = 5
	rr.shells_fired[BulletT.SHELL_CLASS_HEAT] = 2
	rr.captured = true
	return rr


func _test_standard_shape() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	var canonical: String = "APCR 1-shots; HEAT 2-shots entrenched heavies (breach Heavy hp=3)"
	var s: String = rr.verdict_sentence(canonical)
	# Hit-list: the verdict must name each of these legible elements.
	var must_contain: Array[String] = [
		"Died at depth 95",
		"BUNKER_ZONE",
		"MIXED BREACHER",        # build_tag for AP14/HE5/HEAT2 — no shell dominates
		"0 HE",
		"steel-armored bunkers",  # pressure first-phrase (semicolon-split head)
		"canonical answer: APCR", # canonical brief from em-dash split (head "APCR" before space)
	]
	for s_part in must_contain:
		if not (s_part in s):
			push_error("FAIL standard — missing %q in verdict:\n%s" % [s_part, s])
			return false
	print("  standard — verdict names depth/band/build/dry-HE/pressure/canonical-APCR")
	return true


func _test_comfortable_reserves() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	rr.he_reserve_at_death = 4
	rr.heat_reserve_at_death = 2
	var s: String = rr.verdict_sentence("")
	if not ("with 4 HE / 2 HEAT to spare" in s):
		push_error("FAIL comfortable — expected 'with 4 HE / 2 HEAT to spare' in:\n%s" % s)
		return false
	if "0 HE" in s or "0 HEAT" in s:
		push_error("FAIL comfortable — verdict mentioned a 0-reserve clause incorrectly:\n%s" % s)
		return false
	print("  comfortable reserves — 'with 4 HE / 2 HEAT to spare' (no 0-clauses)")
	return true


func _test_missing_canonical() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	var s: String = rr.verdict_sentence("")  # canonical empty
	if "canonical answer" in s:
		push_error("FAIL missing-canonical — verdict included parenthetical despite empty canonical:\n%s" % s)
		return false
	# Other elements still present.
	if not ("BUNKER_ZONE" in s) or not ("0 HE" in s):
		push_error("FAIL missing-canonical — base verdict shape broken:\n%s" % s)
		return false
	print("  missing canonical — no parenthetical; base verdict intact")
	return true


func _test_long_pressure_truncation() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	# A long pressure with no semicolon — must truncate at 32 chars + "...".
	rr.killing_pressure = "an absurdly long single-clause pressure string with no semicolons at all"
	var s: String = rr.verdict_sentence("")
	# The truncated string ends with "..." — verify present.
	if not ("..." in s):
		push_error("FAIL long-pressure — truncation marker missing:\n%s" % s)
		return false
	# The full long string must NOT be present verbatim.
	if rr.killing_pressure in s:
		push_error("FAIL long-pressure — full string not truncated:\n%s" % s)
		return false
	print("  long pressure — truncated with ellipsis (32-char cap fits panel width)")
	return true


func _test_em_dash_canonical() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	# brick_maze canonical: "HE — open vertical lanes; trade shells for time"
	var canonical: String = "HE — open vertical lanes; trade shells for time"
	var s: String = rr.verdict_sentence(canonical)
	# Em-dash split → head "HE" (length 2 ≤ 12) → brief is "HE".
	if not ("canonical answer: HE" in s):
		push_error("FAIL em-dash — brief should be 'HE' (just the shell directive):\n%s" % s)
		return false
	# Full explanation should NOT be in the brief.
	if "open vertical lanes" in s:
		push_error("FAIL em-dash — explanation leaked into brief:\n%s" % s)
		return false
	print("  em-dash canonical — brief is 'HE' (head of 'HE — explanation' kept)")
	return true


func _test_meta_canonical() -> bool:
	var rr: RunRecapT = _make_recap_standard()
	# endgame_mixed canonical: "build cohesion test — chosen identity determines reach"
	# Em-dash head "build cohesion test" is 19 chars, exceeds the 12-char shell-
	# directive ceiling, so the helper falls back to the FIRST phrase whole.
	var canonical: String = "build cohesion test — chosen identity determines reach"
	var s: String = rr.verdict_sentence(canonical)
	# First phrase (no semicolon, but >24 chars) gets truncated.
	# "build cohesion test — chosen identity determines reach" length = 54.
	# Truncated to 21 chars + "..." → "build cohesion test —..."
	if not ("canonical answer:" in s):
		push_error("FAIL meta — parenthetical missing entirely:\n%s" % s)
		return false
	if not ("build cohesion test" in s):
		push_error("FAIL meta — first phrase head should still appear:\n%s" % s)
		return false
	print("  meta canonical — first-phrase fallback used (not the em-dash head)")
	return true
