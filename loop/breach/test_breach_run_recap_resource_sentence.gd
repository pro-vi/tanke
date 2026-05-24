# Arc-4 breach mode: Round 12 Phase 4 — RunRecap.resource_sentence
# (iter 110, Gap 3 from iter-106 diagnosis). The verdict now NAMES
# the dry-vs-canonical relationship as a learning-moment clause:
#
#   - dry-on-X AND brief contains X (word-boundary) → "Dry on X
#     — the band's canonical answer." (you ran out of THE answer)
#   - dry-on-X AND brief is Y ≠ X → "Dry on X; band wanted Y."
#     (you had the wrong answer ready)
#   - dry-on-X AND no canonical → "Dry on X." (no canonical tie)
#   - comfortable reserves → "" (suppresses; caller falls back to
#     the parenthetical canonical aside)
#
# Word-boundary regex prevents "AP" matching "APCR" and "HE"
# matching "HEAT".
#
# Verifies:
#   1. Match form: dry-on-HE in brick_maze (canonical "HE — open
#      vertical lanes") → "Dry on HE — the band's canonical answer."
#   2. Mismatch form: dry-on-HE in bunker_zone (canonical "APCR
#      1-shots") → "Dry on HE; band wanted APCR 1-shots."
#   3. Comfortable form: full HE + HEAT reserves → resource_sentence
#      returns "" (no clause).
#   4. No-canonical form: dry-on-HE, empty canonical → "Dry on HE."
#   5. Word-boundary correctness: brief "APCR 1-shots" must NOT
#      trigger the dry-on-AP match path (substring AP exists but
#      not as a word boundary).
#   6. Word-boundary correctness: brief "HEAT 2-shots" must NOT
#      trigger the dry-on-HE match path.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_resource_sentence.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Test 1: match form (dry-on-HE in HE-canonical band).
	if not _test_match_form():
		quit(1); return
	# === Test 2: mismatch form (dry-on-HE in APCR-canonical band).
	if not _test_mismatch_form():
		quit(1); return
	# === Test 3: comfortable reserves → no clause.
	if not _test_comfortable_no_clause():
		quit(1); return
	# === Test 4: no canonical, dry → bare "Dry on X."
	if not _test_no_canonical_dry_only():
		quit(1); return
	# === Test 5: word-boundary — "APCR" doesn't trigger dry-on-AP.
	if not _test_word_boundary_apcr_vs_ap():
		quit(1); return
	# === Test 6: word-boundary — "HEAT" doesn't trigger dry-on-HE.
	if not _test_word_boundary_heat_vs_he():
		quit(1); return

	print("BREACH_RUN_RECAP_RESOURCE_SENTENCE_OK 6 cases verified: match/mismatch/comfortable/no-canonical + 2 word-boundary")
	quit(0)


# A RunRecap dry on HE only.
func _make_recap_dry_he() -> RunRecapT:
	var rr: RunRecapT = RunRecapT.new()
	rr.depth_reached = 95
	rr.killing_band = "test_band"
	rr.killing_pressure = "test pressure"
	rr.he_reserve_at_death = 0
	rr.heat_reserve_at_death = 2
	rr.captured = true
	return rr


# A RunRecap with full reserves.
func _make_recap_comfortable() -> RunRecapT:
	var rr: RunRecapT = RunRecapT.new()
	rr.depth_reached = 50
	rr.killing_band = "test_band"
	rr.killing_pressure = "test pressure"
	rr.he_reserve_at_death = 4
	rr.heat_reserve_at_death = 2
	rr.captured = true
	return rr


func _test_match_form() -> bool:
	var rr: RunRecapT = _make_recap_dry_he()
	# brick_maze canonical: brief is "HE" after em-dash split.
	var s: String = rr.resource_sentence("HE — open vertical lanes; trade shells for time")
	if s != "Dry on HE — the band's canonical answer.":
		push_error("FAIL match form — got %s\nwant 'Dry on HE — the band's canonical answer.'" % s)
		return false
	print("  match form — dry-on-HE in HE-canonical band → '%s'" % s)
	return true


func _test_mismatch_form() -> bool:
	var rr: RunRecapT = _make_recap_dry_he()
	# bunker_zone canonical: brief is "APCR 1-shots" (length 12, no em-dash split).
	var s: String = rr.resource_sentence("APCR 1-shots; HEAT 2-shots entrenched heavies (breach Heavy hp=3)")
	# Brief should be "APCR 1-shots" — length 12, no em-dash, no truncate.
	if not s.begins_with("Dry on HE; band wanted "):
		push_error("FAIL mismatch form — wrong prefix:\n%s" % s)
		return false
	if not ("APCR" in s):
		push_error("FAIL mismatch form — missing 'APCR' in tail:\n%s" % s)
		return false
	print("  mismatch form — dry-on-HE in APCR-canonical band → '%s'" % s)
	return true


func _test_comfortable_no_clause() -> bool:
	var rr: RunRecapT = _make_recap_comfortable()
	var s: String = rr.resource_sentence("APCR 1-shots")
	if not s.is_empty():
		push_error("FAIL comfortable — got '%s', want '' (no clause when comfortable)" % s)
		return false
	print("  comfortable — empty (no clause; caller falls back to parenthetical)")
	return true


func _test_no_canonical_dry_only() -> bool:
	var rr: RunRecapT = _make_recap_dry_he()
	var s: String = rr.resource_sentence("")
	if s != "Dry on HE.":
		push_error("FAIL no-canonical — got '%s', want 'Dry on HE.'" % s)
		return false
	print("  no-canonical + dry → 'Dry on HE.' (bare clause)")
	return true


func _test_word_boundary_apcr_vs_ap() -> bool:
	# dry-on-HE; brief "APCR 1-shots" contains "AP" as substring but
	# NOT as a word. The dry list is ["HE"], so we test the HE
	# detection — brief "APCR 1-shots" has no "HE" word either, so
	# we expect the mismatch form (not the match form).
	var rr: RunRecapT = _make_recap_dry_he()
	var s: String = rr.resource_sentence("APCR 1-shots")
	if "the band's canonical answer" in s:
		push_error("FAIL word-boundary apcr-vs-ap — false positive match (HE shouldn't word-match 'APCR 1-shots'):\n%s" % s)
		return false
	if not ("band wanted APCR 1-shots" in s):
		push_error("FAIL word-boundary apcr-vs-ap — wrong mismatch tail:\n%s" % s)
		return false
	print("  word-boundary AP vs APCR — no false match; mismatch form fires correctly")
	return true


func _test_word_boundary_heat_vs_he() -> bool:
	# dry-on-HE; brief "HEAT 2-shots" contains "HE" as substring (the
	# first two chars of HEAT) but NOT as a word boundary. Resource
	# sentence should treat this as a mismatch, not a match.
	var rr: RunRecapT = _make_recap_dry_he()
	var s: String = rr.resource_sentence("HEAT 2-shots entrenched heavies")
	if "the band's canonical answer" in s:
		push_error("FAIL word-boundary heat-vs-he — false positive match (HE shouldn't word-match 'HEAT 2-shots'):\n%s" % s)
		return false
	if not ("band wanted HEAT 2-shots" in s):
		push_error("FAIL word-boundary heat-vs-he — wrong mismatch tail:\n%s" % s)
		return false
	print("  word-boundary HE vs HEAT — no false match; mismatch form fires correctly")
	return true
