# Arc-4 breach mode: Round-11 Phase-1 band-shape recorder verifier
# (iter 82). Per CONSULT 009's band-shape-blind-spot finding:
# Round-10 instrumentation tested single moments, not multi-band
# run-shape. This harness verifies the RunRecap extension that
# captures per-band visit telemetry for cross-archetype post-hoc
# analysis.
#
# Verifies:
#   - RunRecap.archetype + RunRecap.band_visit_log fields exist
#   - enter_band() appends a visit dict to the log
#   - enter_band() is idempotent on same-band repeats (only
#     transitions log)
#   - enter_band() preserves visit order
#   - band_signature() returns the expected schema
#   - format() includes a band-visits line when visits exist
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_band_shape.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")


func _initialize() -> void:
	# === New schema fields exist + default correctly.
	var r: RunRecapT = RunRecapT.new()
	if r.archetype != 0:
		push_error("FAIL — RunRecap.archetype default %d, want 0 (DEFAULT)" % r.archetype)
		quit(1); return
	if r.band_visit_log.size() != 0:
		push_error("FAIL — RunRecap.band_visit_log default size %d, want 0" % r.band_visit_log.size())
		quit(1); return
	print("  schema: archetype=0, band_visit_log=[] (fresh)")

	# === enter_band appends a visit dict with the band name + a ms
	# timestamp.
	r.enter_band("warmup")
	if r.band_visit_log.size() != 1:
		push_error("FAIL — after 1 enter_band, log size %d, want 1" % r.band_visit_log.size())
		quit(1); return
	if r.band_visit_log[0]["band"] != "warmup":
		push_error("FAIL — log[0].band '%s', want 'warmup'" % r.band_visit_log[0]["band"])
		quit(1); return
	if not r.band_visit_log[0].has("entered_ms"):
		push_error("FAIL — log[0] missing 'entered_ms' key")
		quit(1); return
	print("  enter_band 'warmup': log size 1, entry has band+entered_ms")

	# === enter_band is idempotent on same-band repeats.
	r.enter_band("warmup")
	r.enter_band("warmup")
	if r.band_visit_log.size() != 1:
		push_error("FAIL — same-band repeats: log size %d, want 1 (idempotent)" % r.band_visit_log.size())
		quit(1); return
	print("  enter_band repeated 'warmup' x2: log size still 1 (idempotent)")

	# === enter_band preserves order across transitions.
	r.enter_band("first_push")
	r.enter_band("bunker")
	r.enter_band("steel")
	if r.band_visit_log.size() != 4:
		push_error("FAIL — after 4 distinct bands, log size %d, want 4" % r.band_visit_log.size())
		quit(1); return
	var expected_sequence: Array = ["warmup", "first_push", "bunker", "steel"]
	for i in expected_sequence.size():
		if r.band_visit_log[i]["band"] != expected_sequence[i]:
			push_error("FAIL — log[%d].band '%s', want '%s'" % [i, r.band_visit_log[i]["band"], expected_sequence[i]])
			quit(1); return
	print("  4-band sequence preserved: warmup > first_push > bunker > steel")

	# === A repeat AFTER a transition adds a new entry (re-visiting
	# a prior band is a meaningful event — different from same-band
	# heartbeats).
	r.enter_band("first_push")  # re-enter
	if r.band_visit_log.size() != 5:
		push_error("FAIL — re-entry of 'first_push': log size %d, want 5" % r.band_visit_log.size())
		quit(1); return
	print("  re-entry of 'first_push' after 'steel' adds new entry (log size 5)")

	# === band_signature returns the expected schema.
	r.archetype = 1  # PRISM
	r.depth_reached = 42
	var sig: Dictionary = r.band_signature()
	for key in ["archetype", "visit_count", "total_run_ms", "band_sequence", "shells_fired_total", "depth_reached"]:
		if not sig.has(key):
			push_error("FAIL — band_signature missing key '%s' — got %s" % [key, str(sig.keys())])
			quit(1); return
	if sig["archetype"] != 1:
		push_error("FAIL — sig.archetype %d, want 1" % sig["archetype"]); quit(1); return
	if sig["visit_count"] != 5:
		push_error("FAIL — sig.visit_count %d, want 5" % sig["visit_count"]); quit(1); return
	if sig["depth_reached"] != 42:
		push_error("FAIL — sig.depth_reached %d, want 42" % sig["depth_reached"]); quit(1); return
	if sig["band_sequence"] != ["warmup", "first_push", "bunker", "steel", "first_push"]:
		push_error("FAIL — sig.band_sequence %s, want [warmup, first_push, bunker, steel, first_push]" % str(sig["band_sequence"]))
		quit(1); return
	print("  band_signature schema: archetype=%d, visit_count=%d, depth_reached=%d, %d-band sequence" % [sig["archetype"], sig["visit_count"], sig["depth_reached"], sig["band_sequence"].size()])

	# === format() includes a band-visits line when the log has entries.
	r.capture_death(42, null, null)
	r.killing_band = "steel"
	r.killing_pressure = "narrow corridors"
	var txt: String = r.format()
	if not "band visits" in txt:
		push_error("FAIL — format() missing 'band visits' line; got: %s" % txt)
		quit(1); return
	if not "warmup > first_push > bunker > steel > first_push" in txt:
		push_error("FAIL — format() band-visits line missing the sequence; got: %s" % txt)
		quit(1); return
	print("  format(): band-visits line present with full sequence")

	# === A fresh RunRecap with NO band visits produces a format()
	# that does NOT include the band-visits line (arc-2/3 unaffected
	# even if RunRecap is somehow instantiated).
	var r_empty: RunRecapT = RunRecapT.new()
	r_empty.capture_death(0, null, null)
	var txt_empty: String = r_empty.format()
	if "band visits" in txt_empty:
		push_error("FAIL — empty log format() contains 'band visits' line (should not)")
		quit(1); return
	print("  empty-log format(): no 'band visits' line (no false positives)")

	print("BREACH_BAND_SHAPE_OK RunRecap band-shape recorder: idempotent enter_band, preserved order, signature schema, format() integration")
	quit(0)
