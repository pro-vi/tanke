# Arc-4 iter 291 (consult-001 Q3 verdict 0.92):
# Verifies RunRecap.route_currency_summary() — compact 2-line format
# for the death-overlay route-currency block. Closes the loop between
# iter 285's storage API and the player's post-run feedback.
#
# Verifies:
#   1. Empty state → "" (death label can skip the section)
#   2. 1 HE route hit only → "ROUTE: 1HE" (no COMBAT line)
#   3. 1 AP combat hit only → "COMBAT: 1AP" (no ROUTE line)
#   4. Mixed: HE route + AP combat → "ROUTE: 1HE\nCOMBAT: 1AP"
#   5. Multi-class accumulation: 2 HE routes + 1 APCR route + 3 AP combat
#      → "ROUTE: 2HE 1APCR\nCOMBAT: 3AP" (ordered AP/HE/HEAT/APCR, zeros dropped)
#   6. Worst-case width: every class in both dicts. Line lengths still
#      under ~36 chars (panel width budget).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_route_currency_summary.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Case 1: empty.
	var rr: RunRecap = RunRecapT.new()
	if rr.route_currency_summary() != "":
		push_error("FAIL — empty state should return '', got '%s'" % rr.route_currency_summary())
		quit(1); return
	print("  empty state: '' (label skips section)")

	# === Case 2: HE route only.
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	var s2: String = rr.route_currency_summary()
	if s2 != "ROUTE: 1HE":
		push_error("FAIL — 1 HE route → '%s', want 'ROUTE: 1HE'" % s2)
		quit(1); return
	print("  1 HE route: '%s'" % s2)

	# === Case 3: reset, AP combat only.
	rr = RunRecapT.new()
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	var s3: String = rr.route_currency_summary()
	if s3 != "COMBAT: 1AP":
		push_error("FAIL — 1 AP combat → '%s', want 'COMBAT: 1AP'" % s3)
		quit(1); return
	print("  1 AP combat: '%s'" % s3)

	# === Case 4: mixed.
	rr = RunRecapT.new()
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	var s4: String = rr.route_currency_summary()
	if s4 != "ROUTE: 1HE\nCOMBAT: 1AP":
		push_error("FAIL — mixed → '%s', want 'ROUTE: 1HE\\nCOMBAT: 1AP'" % s4)
		quit(1); return
	print("  HE route + AP combat: 2 lines, correct order")

	# === Case 5: multi-class accumulation, ordered AP/HE/HEAT/APCR.
	rr = RunRecapT.new()
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_APCR, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	var s5: String = rr.route_currency_summary()
	# Ordered AP/HE/HEAT/APCR; HE comes before APCR; HEAT skipped (zero).
	if s5 != "ROUTE: 2HE 1APCR\nCOMBAT: 3AP":
		push_error("FAIL — multi-class → '%s', want 'ROUTE: 2HE 1APCR\\nCOMBAT: 3AP'" % s5)
		quit(1); return
	print("  2HE 1APCR routes + 3AP combat: '%s'" % s5.replace("\n", " | "))

	# === Case 6: worst-case width.
	rr = RunRecapT.new()
	for sc in [BulletT.SHELL_CLASS_AP, BulletT.SHELL_CLASS_HE,
			BulletT.SHELL_CLASS_HEAT, BulletT.SHELL_CLASS_APCR]:
		for _i in 9:
			rr.record_shot_hit(sc, RunRecapT.HIT_KIND_ROUTE)
		for _j in 9:
			rr.record_shot_hit(sc, RunRecapT.HIT_KIND_COMBAT)
	var s6: String = rr.route_currency_summary()
	var max_line_len: int = 0
	for line in s6.split("\n"):
		if line.length() > max_line_len:
			max_line_len = line.length()
	if max_line_len > 38:
		push_error("FAIL — worst-case width %d exceeds 38-char budget; lines:\n%s" \
				% [max_line_len, s6])
		quit(1); return
	print("  worst case (9 per class × 4 classes × 2 dicts): max line %d chars (within 38 budget)" \
			% max_line_len)
	print("    sample: %s" % s6.split("\n")[0])

	print("BREACH_ROUTE_CURRENCY_SUMMARY_OK 6 cases — empty / single-class route / single-class combat / mixed / multi-class ordered / width budget")
	quit(0)
