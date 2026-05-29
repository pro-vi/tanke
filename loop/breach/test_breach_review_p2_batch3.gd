# arc-4 PR-#4 review fix regression — Batch 3 (P2 #3):
# APCR was added as the 4th shell class at iter 33 user override but
# RunRecap was never updated to capture it. Affected:
#   - shells_fired init dict (APCR fell into the dynamic `else` branch)
#   - capture_death didn't snapshot apcr_reserve_at_death
#   - _dry_shells_list omitted APCR
#   - _format_resource_clause omitted APCR
#   - format() output omitted APCR
#   - build_tag bucketed APCR-heavy runs as "lane sniper" (AP-only
#     check tested only he == 0 and heat == 0)
#
# All gaps closed in this batch.
#
# 5 cases:
#   1. shells_fired init dict includes SHELL_CLASS_APCR.
#   2. capture_death snapshots apcr_reserve from loadout.
#   3. _dry_shells_list reports APCR when reserve == 0.
#   4. _format_resource_clause includes "0 APCR" / "to spare" line.
#   5. build_tag returns "steel driller" for APCR-dominant run (and
#      still "lane sniper" for AP-only).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_review_p2_batch3.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === Case 1: shells_fired init dict has APCR.
	var rr1 := RunRecapT.new()
	if not rr1.shells_fired.has(BulletT.SHELL_CLASS_APCR):
		push_error("FAIL — shells_fired init dict missing SHELL_CLASS_APCR (P2 #3 regression)")
		quit(1); return
	if int(rr1.shells_fired[BulletT.SHELL_CLASS_APCR]) != 0:
		push_error("FAIL — shells_fired[APCR] init = %d (want 0)" % rr1.shells_fired[BulletT.SHELL_CLASS_APCR])
		quit(1); return
	print("  case 1: shells_fired init dict includes SHELL_CLASS_APCR at 0")

	# === Case 2: capture_death snapshots apcr_reserve.
	var rr2 := RunRecapT.new()
	var loadout := LoadoutT.new()
	loadout.he_reserve = 4
	loadout.heat_reserve = 2
	loadout.apcr_reserve = 1
	rr2.capture_death(50, null, loadout)
	if rr2.apcr_reserve_at_death != 1:
		push_error("FAIL — capture_death didn't snapshot apcr_reserve (got %d, want 1)" % rr2.apcr_reserve_at_death)
		quit(1); return
	print("  case 2: capture_death snapshots apcr_reserve_at_death=1 (from loadout)")

	# === Case 3: _dry_shells_list includes APCR when reserve == 0.
	var rr3 := RunRecapT.new()
	rr3.he_reserve_at_death = 0
	rr3.heat_reserve_at_death = 2
	rr3.apcr_reserve_at_death = 0
	var dry: Array = rr3._dry_shells_list()
	if not "APCR" in dry:
		push_error("FAIL — _dry_shells_list missing APCR with apcr_reserve_at_death=0 (got %s)" % str(dry))
		quit(1); return
	if not "HE" in dry:
		push_error("FAIL — _dry_shells_list missing HE (sanity check)")
		quit(1); return
	if "HEAT" in dry:
		push_error("FAIL — _dry_shells_list incorrectly reports HEAT dry when heat_reserve=2")
		quit(1); return
	print("  case 3: _dry_shells_list = %s (APCR included when reserve=0)" % str(dry))

	# === Case 4: _format_resource_clause includes "0 APCR".
	var rr4 := RunRecapT.new()
	rr4.he_reserve_at_death = 3
	rr4.heat_reserve_at_death = 1
	rr4.apcr_reserve_at_death = 0  # dry on APCR only
	var clause: String = rr4._format_resource_clause()
	if not "0 APCR" in clause:
		push_error("FAIL — _format_resource_clause missing '0 APCR' (got '%s')" % clause)
		quit(1); return
	print("  case 4: _format_resource_clause reports '0 APCR' (got '%s')" % clause)
	# Sub-case: all reserves comfortable → "to spare" framing includes APCR.
	rr4.apcr_reserve_at_death = 5
	var clause2: String = rr4._format_resource_clause()
	if not "APCR" in clause2:
		push_error("FAIL — comfortable-reserve clause omits APCR (got '%s')" % clause2)
		quit(1); return
	print("    sub: comfortable-reserve clause includes APCR (got '%s')" % clause2)

	# === Case 5: build_tag handles APCR-dominant.
	var rr5 := RunRecapT.new()
	rr5.shells_fired[BulletT.SHELL_CLASS_AP] = 3
	rr5.shells_fired[BulletT.SHELL_CLASS_HE] = 0
	rr5.shells_fired[BulletT.SHELL_CLASS_HEAT] = 0
	rr5.shells_fired[BulletT.SHELL_CLASS_APCR] = 5
	var tag: String = rr5.build_tag()
	if tag != "steel driller":
		push_error("FAIL — build_tag for APCR-dominant=%d / AP=3 / HE=0 / HEAT=0 → '%s' (want 'steel driller')" \
				% [rr5.shells_fired[BulletT.SHELL_CLASS_APCR], tag])
		quit(1); return
	print("  case 5: build_tag → 'steel driller' for APCR-heavy run (was 'lane sniper' pre-fix)")
	# Sub-case: pure AP-only still "lane sniper".
	rr5.shells_fired[BulletT.SHELL_CLASS_APCR] = 0
	rr5.shells_fired[BulletT.SHELL_CLASS_AP] = 7
	var tag2: String = rr5.build_tag()
	if tag2 != "lane sniper":
		push_error("FAIL — AP-only build_tag → '%s' (want 'lane sniper' preserved)" % tag2)
		quit(1); return
	print("    sub: AP-only build_tag still 'lane sniper'")

	print("BREACH_REVIEW_P2_BATCH3_OK 5 cases — APCR captured + dry list + resource clause + build_tag")
	quit(0)
