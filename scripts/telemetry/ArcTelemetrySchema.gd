class_name ArcTelemetrySchema
extends RefCounted

# The arc telemetry contract (arc-harness-v0.2 AC-A2) — one source of truth for
# the arc producer (ArcTelemetryRecorder) and verifier (check-arc-telemetry-schema).
# A v0.2-arc record is one BreachLevel run's JSON: the WHOLE v0.1 contract
# (so arc telemetry stays a strict superset the same downstream tools read) PLUS
# the arc-specific fields the real procedural climb produces:
#   max_depth, final_band, bands_reached, band_segments, depot_picks, reached_endgame.
#
# Standalone (does NOT delegate to TelemetrySchema): the schema_version differs
# ("v0.2-arc" vs "v0.1"), so this validator owns the full check. validate()
# returns [] if conformant else a list of human-readable violations.
#
# JSON note: JSON.parse_string yields TYPE_FLOAT for every number and TYPE_BOOL
# for bools, so "integer" fields are checked with _is_int_like (float == floor),
# letting the SAME validator pass disk-loaded fixtures AND the recorder's
# in-memory dict (real ints/bools).

const SCHEMA_VERSION := "v0.2-arc"
const SHELL_KEYS := ["AP", "HE", "HEAT", "APCR"]
const DEATH_CAUSES := ["melee", "projectile", "suicide", "timeout", "victory"]
const CORR_KEYS := ["reload_bar", "shell_chip", "ribbon_visible"]


static func _is_num(v) -> bool:
	return typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT


static func _is_int_like(v) -> bool:
	if typeof(v) == TYPE_INT:
		return true
	if typeof(v) == TYPE_FLOAT:
		return v == floor(v)
	return false


# [] == valid; otherwise a list of violation strings.
static func validate(t) -> Array:
	var errs: Array = []
	if typeof(t) != TYPE_DICTIONARY:
		return ["record is not an object/dictionary"]

	# --- inherited v0.1 contract (superset) ---
	if not t.has("survival_time_sec") or not _is_num(t["survival_time_sec"]) or float(t["survival_time_sec"]) < 0.0:
		errs.append("survival_time_sec missing/non-numeric/<0")
	if not t.has("damage_taken") or not _is_int_like(t["damage_taken"]) or float(t["damage_taken"]) < 0.0:
		errs.append("damage_taken missing/non-int/<0")
	errs += _validate_shell_dict(t, "shells_fired_per_class")
	if not t.has("shell_hit_rate") or not _is_num(t["shell_hit_rate"]) or float(t["shell_hit_rate"]) < 0.0 or float(t["shell_hit_rate"]) > 1.0:
		errs.append("shell_hit_rate missing/out-of-[0,1]")
	if not t.has("reload_cancel_events") or not _is_int_like(t["reload_cancel_events"]) or float(t["reload_cancel_events"]) < 0.0:
		errs.append("reload_cancel_events missing/non-int/<0")
	if not t.has("time_exposed_pct") or not _is_num(t["time_exposed_pct"]) or float(t["time_exposed_pct"]) < 0.0 or float(t["time_exposed_pct"]) > 1.0:
		errs.append("time_exposed_pct missing/out-of-[0,1]")
	if not t.has("death_cause") or not (t["death_cause"] in DEATH_CAUSES):
		errs.append("death_cause missing/not-in-enum(%s)" % str(DEATH_CAUSES))
	if not t.has("ui_action_correlation") or typeof(t["ui_action_correlation"]) != TYPE_DICTIONARY:
		errs.append("ui_action_correlation missing/not-object")
	else:
		var uac = t["ui_action_correlation"]
		for k in CORR_KEYS:
			if not uac.has(k) or not _is_num(uac[k]):
				errs.append("ui_action_correlation.%s missing/non-numeric" % k)
	if not t.has("seed") or not _is_int_like(t["seed"]):
		errs.append("seed missing/non-int")
	if not t.has("bot_id") or typeof(t["bot_id"]) != TYPE_STRING or (t["bot_id"] as String).is_empty():
		errs.append("bot_id missing/empty")
	if not t.has("schema_version") or t["schema_version"] != SCHEMA_VERSION:
		errs.append("schema_version missing/!= '%s'" % SCHEMA_VERSION)

	# --- arc-specific fields (v0.2) ---
	if not t.has("max_depth") or not _is_int_like(t["max_depth"]) or float(t["max_depth"]) < 0.0:
		errs.append("max_depth missing/non-int/<0")
	if not t.has("final_band") or typeof(t["final_band"]) != TYPE_STRING:
		errs.append("final_band missing/not-string")
	if not t.has("reached_endgame") or typeof(t["reached_endgame"]) != TYPE_BOOL:
		errs.append("reached_endgame missing/not-bool")

	if not t.has("bands_reached") or typeof(t["bands_reached"]) != TYPE_ARRAY:
		errs.append("bands_reached missing/not-array")
	else:
		for b in t["bands_reached"]:
			if typeof(b) != TYPE_STRING:
				errs.append("bands_reached has a non-string entry"); break

	if not t.has("band_segments") or typeof(t["band_segments"]) != TYPE_ARRAY:
		errs.append("band_segments missing/not-array")
	else:
		for i in (t["band_segments"] as Array).size():
			errs += _validate_segment(t["band_segments"][i], i)

	if not t.has("depot_picks") or typeof(t["depot_picks"]) != TYPE_ARRAY:
		errs.append("depot_picks missing/not-array")
	else:
		for i in (t["depot_picks"] as Array).size():
			errs += _validate_depot_pick(t["depot_picks"][i], i)

	return errs


static func _validate_shell_dict(parent, key: String) -> Array:
	var errs: Array = []
	if not parent.has(key) or typeof(parent[key]) != TYPE_DICTIONARY:
		return ["%s missing/not-object" % key]
	var sf = parent[key]
	for k in SHELL_KEYS:
		if not sf.has(k) or not _is_int_like(sf[k]) or float(sf[k]) < 0.0:
			errs.append("%s.%s missing/non-int/<0" % [key, k])
	return errs


static func _validate_segment(seg, idx: int) -> Array:
	var errs: Array = []
	if typeof(seg) != TYPE_DICTIONARY:
		return ["band_segments[%d] not-object" % idx]
	if not seg.has("band") or typeof(seg["band"]) != TYPE_STRING:
		errs.append("band_segments[%d].band missing/not-string" % idx)
	if not seg.has("entered_sec") or not _is_num(seg["entered_sec"]) or float(seg["entered_sec"]) < 0.0:
		errs.append("band_segments[%d].entered_sec missing/non-numeric/<0" % idx)
	if not seg.has("duration_sec") or not _is_num(seg["duration_sec"]) or float(seg["duration_sec"]) < 0.0:
		errs.append("band_segments[%d].duration_sec missing/non-numeric/<0" % idx)
	if not seg.has("damage_taken") or not _is_int_like(seg["damage_taken"]) or float(seg["damage_taken"]) < 0.0:
		errs.append("band_segments[%d].damage_taken missing/non-int/<0" % idx)
	errs += _prefix(_validate_shell_dict(seg, "shells_fired"), "band_segments[%d]." % idx)
	return errs


static func _validate_depot_pick(pick, idx: int) -> Array:
	var errs: Array = []
	if typeof(pick) != TYPE_DICTIONARY:
		return ["depot_picks[%d] not-object" % idx]
	if not pick.has("depot") or typeof(pick["depot"]) != TYPE_STRING:
		errs.append("depot_picks[%d].depot missing/not-string" % idx)
	if not pick.has("kind") or not _is_int_like(pick["kind"]) or float(pick["kind"]) < 0.0:
		errs.append("depot_picks[%d].kind missing/non-int/<0" % idx)
	if not pick.has("band_next") or typeof(pick["band_next"]) != TYPE_STRING:
		errs.append("depot_picks[%d].band_next missing/not-string" % idx)
	return errs


static func _prefix(errs: Array, p: String) -> Array:
	var out: Array = []
	for e in errs:
		out.append(p + str(e))
	return out


static func is_valid(t) -> bool:
	return validate(t).is_empty()
