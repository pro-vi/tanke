extends SceneTree

# U4a verifier (AC-002) — the telemetry SCHEMA contract + oracle independence.
# TelemetrySchema.validate() must ACCEPT a hand-crafted VALID fixture and REJECT
# a hand-crafted INVALID one. The bad fixture failing first is the teeth (oracle
# principle #2): a rubber-stamp validator that returns valid for everything
# fails case "bad". Both fixtures are loaded from disk + JSON-parsed, so this
# also proves the validator tolerates JSON's int-as-float number typing.
#
# Emits `TELEMETRY_OK 2/2 fixtures conform` on full pass; quit(1) otherwise.

const GOOD := "res://tests/fixtures/telemetry_good.json"
const BAD := "res://tests/fixtures/telemetry_bad.json"

func _initialize() -> void:
	var failures: int = 0

	var good = _load_json(GOOD)
	var bad = _load_json(BAD)
	if good == null:
		print("  FAIL — could not load/parse %s" % GOOD); failures += 1
	if bad == null:
		print("  FAIL — could not load/parse %s" % BAD); failures += 1

	if good != null:
		var ge: Array = TelemetrySchema.validate(good)
		if ge.is_empty():
			print("  fixture good: VALID (expected VALID) OK")
		else:
			print("  FAIL — good fixture rejected: %s" % str(ge)); failures += 1

	if bad != null:
		var be: Array = TelemetrySchema.validate(bad)
		if not be.is_empty():
			print("  fixture bad: INVALID (expected INVALID) OK — %d violations e.g. %s" % [be.size(), str(be[0])])
		else:
			print("  FAIL — TEETH: bad fixture ACCEPTED (validator is a rubber stamp)"); failures += 1

	if failures == 0:
		print("TELEMETRY_OK 2/2 fixtures conform")
		quit(0)
	else:
		print("TELEMETRY_SCHEMA_FAIL %d failures" % failures)
		quit(1)


func _load_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	return parsed  # null on parse error
