# Arc-4 Q1 reframe (iter 285 per blueprint loop/breach/iter-283-round24-Q1-architect.md
# deliverable 2; consult-001 Q3 verdict 0.92):
# RunRecap route-currency metrics — data + API verification.
#
# Ships the diagnostic half of the Q1 sprint: shells_spent_on_routes
# and shells_spent_on_combat dicts, populated by record_shot_hit().
# Wiring from Bullet/level scenes lands iter 286.
#
# Verifies:
#   1. Initial state: both dicts have AP/HE/HEAT/APCR keys with value 0;
#      route_taken == ""; time_per_lane == {}.
#   2. record_shot_hit(HE, "route") → shells_spent_on_routes[HE] == 1;
#      shells_spent_on_combat unchanged.
#   3. record_shot_hit(AP, "combat") → shells_spent_on_combat[AP] == 1;
#      shells_spent_on_routes unchanged.
#   4. Accumulation: 3× HE route hits + 2× AP combat hits → route HE=3,
#      combat AP=2, all other classes still 0. total_shells_on_routes()
#      == 3 and total_shells_on_combat() == 2.
#   5. Existing record_shot still works (no regression on iter-30 counter).
#      Crucially: record_shot is INDEPENDENT of record_shot_hit — firing
#      a shot doesn't auto-increment hit counters; only landed shots do.
#   6. Defensive: unknown hit_kind ("miss" or "") is a no-op.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_run_recap_routes.gd

extends SceneTree

const RunRecapT = preload("res://scripts/RunRecap.gd")
const BulletT = preload("res://scripts/Bullet.gd")


func _initialize() -> void:
	# === Case 1: initial state.
	var rr: RunRecap = RunRecapT.new()
	for sc in [BulletT.SHELL_CLASS_AP, BulletT.SHELL_CLASS_HE,
			BulletT.SHELL_CLASS_HEAT, BulletT.SHELL_CLASS_APCR]:
		if not rr.shells_spent_on_routes.has(sc):
			push_error("FAIL — shells_spent_on_routes missing key %d" % sc)
			quit(1); return
		if rr.shells_spent_on_routes[sc] != 0:
			push_error("FAIL — shells_spent_on_routes[%d] = %d, want 0 at init" \
					% [sc, rr.shells_spent_on_routes[sc]])
			quit(1); return
		if not rr.shells_spent_on_combat.has(sc):
			push_error("FAIL — shells_spent_on_combat missing key %d" % sc)
			quit(1); return
		if rr.shells_spent_on_combat[sc] != 0:
			push_error("FAIL — shells_spent_on_combat[%d] = %d, want 0 at init" \
					% [sc, rr.shells_spent_on_combat[sc]])
			quit(1); return
	if rr.route_taken != "":
		push_error("FAIL — route_taken = '%s', want '' at init" % rr.route_taken)
		quit(1); return
	if not rr.time_per_lane.is_empty():
		push_error("FAIL — time_per_lane non-empty at init")
		quit(1); return
	print("  init state: 4 shell-class keys present in both dicts, all 0; route_taken empty; time_per_lane empty")

	# === Case 2: HE route hit only.
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	if rr.shells_spent_on_routes[BulletT.SHELL_CLASS_HE] != 1:
		push_error("FAIL — HE route hit not recorded: %d, want 1" \
				% rr.shells_spent_on_routes[BulletT.SHELL_CLASS_HE])
		quit(1); return
	if rr.shells_spent_on_combat[BulletT.SHELL_CLASS_HE] != 0:
		push_error("FAIL — HE route hit leaked to combat dict")
		quit(1); return
	print("  HE route hit: shells_spent_on_routes[HE] = 1; combat dict unchanged")

	# === Case 3: AP combat hit (different shell, different bucket).
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	if rr.shells_spent_on_combat[BulletT.SHELL_CLASS_AP] != 1:
		push_error("FAIL — AP combat hit not recorded")
		quit(1); return
	if rr.shells_spent_on_routes[BulletT.SHELL_CLASS_AP] != 0:
		push_error("FAIL — AP combat hit leaked to routes dict")
		quit(1); return
	print("  AP combat hit: shells_spent_on_combat[AP] = 1; routes dict unchanged")

	# === Case 4: accumulation.
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_HE, RunRecapT.HIT_KIND_ROUTE)
	rr.record_shot_hit(BulletT.SHELL_CLASS_AP, RunRecapT.HIT_KIND_COMBAT)
	if rr.shells_spent_on_routes[BulletT.SHELL_CLASS_HE] != 3:
		push_error("FAIL — accumulation broken: HE routes = %d, want 3" \
				% rr.shells_spent_on_routes[BulletT.SHELL_CLASS_HE])
		quit(1); return
	if rr.shells_spent_on_combat[BulletT.SHELL_CLASS_AP] != 2:
		push_error("FAIL — accumulation broken: AP combat = %d, want 2" \
				% rr.shells_spent_on_combat[BulletT.SHELL_CLASS_AP])
		quit(1); return
	if rr.total_shells_on_routes() != 3:
		push_error("FAIL — total_shells_on_routes() = %d, want 3" \
				% rr.total_shells_on_routes())
		quit(1); return
	if rr.total_shells_on_combat() != 2:
		push_error("FAIL — total_shells_on_combat() = %d, want 2" \
				% rr.total_shells_on_combat())
		quit(1); return
	print("  accumulation: HE routes=3, AP combat=2; total_routes=3, total_combat=2")

	# === Case 5: existing record_shot still works (no regression).
	var prior_he: int = rr.shells_fired.get(BulletT.SHELL_CLASS_HE, 0)
	rr.record_shot(BulletT.SHELL_CLASS_HE)
	if rr.shells_fired[BulletT.SHELL_CLASS_HE] != prior_he + 1:
		push_error("FAIL — record_shot regression: shells_fired[HE] = %d, want %d" \
				% [rr.shells_fired[BulletT.SHELL_CLASS_HE], prior_he + 1])
		quit(1); return
	# AND record_shot must NOT also increment route/combat (independence).
	if rr.shells_spent_on_routes[BulletT.SHELL_CLASS_HE] != 3:
		push_error("FAIL — record_shot incorrectly bumped routes dict")
		quit(1); return
	if rr.shells_spent_on_combat[BulletT.SHELL_CLASS_HE] != 0:
		push_error("FAIL — record_shot incorrectly bumped combat dict")
		quit(1); return
	print("  record_shot independence: fired counter ticked; hit counters unchanged")

	# === Case 6: defensive — unknown hit_kind is a no-op.
	var pre_routes: int = rr.total_shells_on_routes()
	var pre_combat: int = rr.total_shells_on_combat()
	rr.record_shot_hit(BulletT.SHELL_CLASS_APCR, "miss")
	rr.record_shot_hit(BulletT.SHELL_CLASS_APCR, "")
	rr.record_shot_hit(BulletT.SHELL_CLASS_APCR, "bogus")
	if rr.total_shells_on_routes() != pre_routes:
		push_error("FAIL — unknown hit_kind bumped routes dict")
		quit(1); return
	if rr.total_shells_on_combat() != pre_combat:
		push_error("FAIL — unknown hit_kind bumped combat dict")
		quit(1); return
	print("  defensive: 3 unknown hit_kind calls → no-op (totals unchanged)")

	print("BREACH_RUN_RECAP_ROUTES_OK 6 cases — init / route hit / combat hit / accumulation / record_shot independence / defensive no-op")
	quit(0)
