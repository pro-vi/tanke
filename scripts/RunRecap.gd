class_name RunRecap
extends RefCounted

# Arc-4 breach mode: death attribution. CONSULT 000 named this the
# "paired omission" alongside depots. CONSULT §9 constraint 6: "every
# run produces a death reason tied to resource/build/route — not 'got
# overwhelmed'."
#
# Owned by PlayerTank (created per-run when breach mode is active).
# record_shot() ticks during play; capture_death() snapshots on death;
# format() renders the recap text.

const Bullet = preload("res://scripts/Bullet.gd")

# Captured at death:
var depth_reached: int = 0
var killing_band: String = ""        # the breach band the player died in
var killing_pressure: String = ""    # that band's dominant_pressure text
var killer: String = "shell impact"  # what dealt the fatal blow
var he_reserve_at_death: int = 0
var heat_reserve_at_death: int = 0
var captured: bool = false

# arc-4 iter 82 (Round 11 Phase 1 — band-shape recorder per CONSULT
# 009's blind-spot finding): per-run band-shape telemetry. Each entry
# is { "band": String, "entered_ms": int } — the sequence of band
# crossings during this run. Cross-archetype comparison of these
# sequences (post-hoc) surfaces RUN-SHAPE distinctness that the
# iter-74 single-moment distinctness audit can't see.
var archetype: int = 0  # PlayerTank.TankArchetype value at run start
var band_visit_log: Array = []

# Ticked during the run:
var shells_fired: Dictionary = {
	Bullet.SHELL_CLASS_AP: 0,
	Bullet.SHELL_CLASS_HE: 0,
	Bullet.SHELL_CLASS_HEAT: 0,
}


# Called on every player shot. Increments the per-class fired counter.
func record_shot(shell_class: int) -> void:
	if shells_fired.has(shell_class):
		shells_fired[shell_class] += 1
	else:
		shells_fired[shell_class] = 1


# arc-4 iter 82: called when the player crosses into a new breach
# band (signal from ProceduralLevel). Appends to band_visit_log; the
# sequence + entry timing is the per-archetype run-shape signature.
# Idempotent on same-band repeats — only logs when band_name changes.
func enter_band(band_name: String) -> void:
	if band_visit_log.size() > 0 and band_visit_log[-1]["band"] == band_name:
		return  # same band — already logged
	band_visit_log.append({
		"band": band_name,
		"entered_ms": Time.get_ticks_msec(),
	})


# arc-4 iter 82: derive a compact per-archetype run-shape signature
# for cross-archetype distinctness analysis. Returns a Dictionary
# the analyzer can compare across runs / archetypes / seeds.
func band_signature() -> Dictionary:
	var visit_count: int = band_visit_log.size()
	var first_ms: int = band_visit_log[0]["entered_ms"] if visit_count > 0 else 0
	var last_ms: int = band_visit_log[-1]["entered_ms"] if visit_count > 0 else 0
	var sequence: Array = []
	for v in band_visit_log:
		sequence.append(v["band"])
	return {
		"archetype": archetype,
		"visit_count": visit_count,
		"total_run_ms": last_ms - first_ms,
		"band_sequence": sequence,
		"shells_fired_total": total_shells_fired(),
		"depth_reached": depth_reached,
	}


# Snapshot run state at death. `band` is a BreachBand (or null if the
# player died outside any band); `loadout` may be null. Defensive on
# both — duck-typed reads.
func capture_death(depth: int, band, loadout) -> void:
	depth_reached = depth
	if band != null:
		killing_band = band.band_name
		killing_pressure = band.dominant_pressure
	if loadout != null:
		he_reserve_at_death = loadout.he_reserve
		heat_reserve_at_death = loadout.heat_reserve
	captured = true


# Total shells fired across all classes.
func total_shells_fired() -> int:
	var t: int = 0
	for k in shells_fired:
		t += shells_fired[k]
	return t


# Derive a build identity tag from the run's shell mix (C1/C6 anchor 3
# substrate). Whichever non-AP shell dominated names the build; an
# AP-only run is a "lane sniper" (precise, conservation-minded).
func build_tag() -> String:
	var he: int = shells_fired.get(Bullet.SHELL_CLASS_HE, 0)
	var heat: int = shells_fired.get(Bullet.SHELL_CLASS_HEAT, 0)
	var ap: int = shells_fired.get(Bullet.SHELL_CLASS_AP, 0)
	if he == 0 and heat == 0:
		return "lane sniper"        # AP-only — precision, conservation
	if he >= heat and he >= ap:
		return "rubble plow"        # HE-dominant — breaches terrain
	if heat >= he and heat >= ap:
		return "bunker cracker"     # HEAT-dominant — anti-armor
	return "mixed breacher"


# arc-4 iter 108 (Round 12 Phase 2, γ shape from iter-107 SPIKE):
# compose a one-sentence verdict from build + killing_band +
# reserve_left + (optionally) the band's canonical_answer. The
# canonical answer is read from the killing BreachBand by
# PlayerTank at death-render time and passed in here, since
# RunRecap is a RefCounted that doesn't hold a band reference.
#
# Sentence template:
#   "Died at depth N in BAND_NAME
#    as a BUILD_TAG —
#    RESOURCE_CLAUSE against
#    PRESSURE_PHRASE.
#
#    (canonical answer: CANONICAL_BRIEF)"
#
# Constraint-6-shaped: names the band (route), build (build), and
# resource state (resource) in one declarative sentence. The
# canonical_answer surfacing turns the recap into a DIAGNOSIS the
# player can learn from, not just a report of what happened.
func verdict_sentence(canonical_answer: String = "") -> String:
	if not captured:
		return "(no death captured)"
	var build_up: String = build_tag().to_upper()
	var resource_clause: String = _format_resource_clause()
	var pressure_short: String = _pressure_first_phrase()
	var band_up: String = killing_band.to_upper() if not killing_band.is_empty() else "UNKNOWN"
	var s: String = "Died at depth %d in %s\nas a %s —\n%s against\n%s." % [
		depth_reached,
		band_up,
		build_up,
		resource_clause,
		pressure_short,
	]
	# arc-4 iter 110 (Round 12 Phase 4, Gap 3): splice the resource
	# attribution sentence between the main verdict and the canonical
	# aside. When the resource sentence fires (player was dry on a
	# shell), it ALREADY references the canonical answer — so suppress
	# the parenthetical aside to preserve the panel's line budget.
	var rs: String = resource_sentence(canonical_answer)
	if not rs.is_empty():
		s += "\n\n" + rs
	elif not canonical_answer.is_empty():
		var brief: String = _canonical_answer_brief(canonical_answer)
		if not brief.is_empty():
			s += "\n\n(canonical answer: %s)" % brief
	return s


# arc-4 iter 110 (Round 12 Phase 4, Gap 3): the constraint-6
# learning-moment clause. When the player was dry on a shell at
# death, name the dry-vs-canonical relationship so the recap
# diagnoses the failure mode:
#
#   - dry-on-X AND X matches the canonical answer → "Dry on HE —
#     the band's canonical answer." (you ran out of THE answer)
#   - dry-on-X AND canonical is Y → "Dry on HE; band wanted APCR."
#     (you had the wrong answer ready)
#   - dry-on-X AND no canonical → "Dry on HE." (no canonical tie;
#     still surfaces the resource gap)
#   - comfortable reserves → "" (no clause; caller falls back to
#     the parenthetical canonical aside)
#
# Returns "" when no dry-on-X clause applies.
# arc-4 iter 121 (Round 16 BUILD-QUALITY, Gap 4 from iter-106
# diagnosis): the route-diff clause. Given the run's FULL band
# route (PlayerTank._route_bands names) and the band_visit_log,
# return a one-line summary naming both the visited path AND
# the path-not-taken. Strongest constraint-6 form for ROUTE
# attribution — "you went here, skipped here."
#
# Returns:
#   - "Visited: A > B; skipped: C, D."  when partial route walked
#   - "Route: A > B > C (full clear)." when no skips
#   - "" when either input is empty (degenerate; caller skips)
func route_diff_clause(full_route_names: Array) -> String:
	if full_route_names.is_empty() or band_visit_log.is_empty():
		return ""
	var visited: Array[String] = []
	for v in band_visit_log:
		visited.append(String(v["band"]))
	var skipped: Array[String] = []
	for r in full_route_names:
		var r_str: String = String(r)
		if not (r_str in visited):
			skipped.append(r_str)
	var v_label: String = " > ".join(visited)
	if skipped.is_empty():
		return "Route: %s (full clear)." % v_label
	var s_label: String = ", ".join(skipped)
	return "Visited: %s; skipped: %s." % [v_label, s_label]


func resource_sentence(canonical_answer: String) -> String:
	var dry: Array[String] = _dry_shells_list()
	if dry.is_empty():
		return ""
	var dry_label: String = ", ".join(dry)
	if canonical_answer.is_empty():
		return "Dry on %s." % dry_label
	var brief: String = _canonical_answer_brief(canonical_answer)
	if brief.is_empty():
		return "Dry on %s." % dry_label
	if _dry_matches_canonical(brief, dry):
		return "Dry on %s — the band's canonical answer." % dry_label
	return "Dry on %s; band wanted %s." % [dry_label, brief]


# arc-4 iter 110: list shells the player was dry on at death (HE +
# HEAT — APCR isn't captured by RunRecap yet; that's a Gap-2-adjacent
# follow-on, not blocking this iter). Returns ["HE"], ["HEAT"],
# ["HE", "HEAT"], or [].
func _dry_shells_list() -> Array[String]:
	var dry: Array[String] = []
	if he_reserve_at_death == 0:
		dry.append("HE")
	if heat_reserve_at_death == 0:
		dry.append("HEAT")
	return dry


# arc-4 iter 110: does any of `dry` appear as a whole-word token
# in `brief`? Uses regex word-boundary so "AP" doesn't match "APCR"
# and "HE" doesn't match "HEAT".
func _dry_matches_canonical(brief: String, dry: Array[String]) -> bool:
	if brief.is_empty():
		return false
	var brief_upper: String = brief.to_upper()
	var re: RegEx = RegEx.new()
	for d in dry:
		re.compile("\\b%s\\b" % d)
		if re.search(brief_upper) != null:
			return true
	return false


# arc-4 iter 108: format the resource clause. Reports only the
# reserves that are LOW (== 0); if all reserves are comfortable,
# returns the positive "with shells to spare" framing. Note this
# only knows HE + HEAT (the fields RunRecap captured); APCR was
# added in iter 33 but not captured at death — that's a follow-on
# fix (Gap 2's surface, not blocking γ).
func _format_resource_clause() -> String:
	var clauses: Array[String] = []
	if he_reserve_at_death == 0:
		clauses.append("0 HE")
	if heat_reserve_at_death == 0:
		clauses.append("0 HEAT")
	if clauses.is_empty():
		return "with %d HE / %d HEAT to spare" % [
			he_reserve_at_death, heat_reserve_at_death]
	return ", ".join(clauses)


# arc-4 iter 108: trim the band's `dominant_pressure` string to its
# first phrase (split on ";" — matches BreachConfig's convention of
# semicolons separating sub-pressures). Cap at 32 chars so the
# verdict sentence fits the 176px death label width.
func _pressure_first_phrase() -> String:
	if killing_pressure.is_empty():
		return "(unknown pressure)"
	var first: String = killing_pressure.split(";", true, 1)[0].strip_edges()
	if first.length() > 32:
		first = first.substr(0, 29) + "..."
	return first


# arc-4 iter 108: trim the band's `canonical_answer` string to its
# first phrase (split on ";" or em-dash "—" — the BreachConfig
# convention is "SHELL — terse explanation; further detail").
# Returns "" if the answer is empty or starts with a meta-string
# we can't usefully convey in one line (e.g. "build cohesion test"
# for endgame_mixed). Cap at 24 chars.
func _canonical_answer_brief(answer: String) -> String:
	if answer.is_empty():
		return ""
	var first: String = answer.split(";", true, 1)[0].strip_edges()
	# Em-dash split — take the first part if the answer leads with
	# "SHELL — explanation" form; otherwise keep the whole first phrase.
	if "—" in first:
		var em_parts: PackedStringArray = first.split("—", true, 1)
		var head: String = em_parts[0].strip_edges()
		# Only use the head if it reads as a shell directive (short).
		if head.length() <= 12:
			return head
	if first.length() > 24:
		first = first.substr(0, 21) + "..."
	return first


# Render the recap text. Reads as an actionable diagnosis tied to
# resource/build/route (constraint 6) — NOT "got overwhelmed".
func format() -> String:
	if not captured:
		return "RUN RECAP — (no death captured)"
	var ap: int = shells_fired.get(Bullet.SHELL_CLASS_AP, 0)
	var he: int = shells_fired.get(Bullet.SHELL_CLASS_HE, 0)
	var heat: int = shells_fired.get(Bullet.SHELL_CLASS_HEAT, 0)
	# arc-4 iter 82: render band-visit summary if any band crossings
	# were logged. Reads as the player's actual run-shape (which bands
	# in what order) for CONSULT-009 band-shape verdict.
	var band_line: String = ""
	if band_visit_log.size() > 0:
		var names: Array = []
		for v in band_visit_log:
			names.append(v["band"])
		band_line = "\n  band visits   : %s" % " > ".join(names)
	return "\n".join([
		"RUN RECAP",
		"  depth reached : %d  (%s band)" % [depth_reached, killing_band],
		"  band pressure : %s" % killing_pressure,
		"  build         : %s" % build_tag(),
		"  killed by     : %s" % killer,
		"  shells fired  : AP %d / HE %d / HEAT %d" % [ap, he, heat],
		"  reserve left  : HE %d / HEAT %d" % [he_reserve_at_death, heat_reserve_at_death],
	]) + band_line
