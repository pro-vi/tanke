class_name TelemetrySchema
extends RefCounted

# The stable telemetry contract (AC-002) — one source of truth for both the
# producer (TelemetryRecorder) and the verifier (check-telemetry-schema). A
# telemetry record is one run's JSON; validate() returns [] if conformant else
# a list of human-readable violations.
#
# JSON note: JSON.parse_string yields TYPE_FLOAT for every number, so "integer"
# fields are checked with _is_int_like (float that equals its floor), letting
# the SAME validator pass both disk-loaded fixtures and the recorder's
# in-memory dict (real ints).

const SCHEMA_VERSION := "v0.1"
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

	if not t.has("survival_time_sec") or not _is_num(t["survival_time_sec"]) or float(t["survival_time_sec"]) < 0.0:
		errs.append("survival_time_sec missing/non-numeric/<0")

	if not t.has("damage_taken") or not _is_int_like(t["damage_taken"]) or float(t["damage_taken"]) < 0.0:
		errs.append("damage_taken missing/non-int/<0")

	if not t.has("shells_fired_per_class") or typeof(t["shells_fired_per_class"]) != TYPE_DICTIONARY:
		errs.append("shells_fired_per_class missing/not-object")
	else:
		var sf = t["shells_fired_per_class"]
		for k in SHELL_KEYS:
			if not sf.has(k) or not _is_int_like(sf[k]) or float(sf[k]) < 0.0:
				errs.append("shells_fired_per_class.%s missing/non-int/<0" % k)

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

	return errs


static func is_valid(t) -> bool:
	return validate(t).is_empty()
