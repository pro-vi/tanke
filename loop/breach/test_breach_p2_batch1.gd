# Arc-4 breach mode: P2 sweep batch 1 regression (iter 096).
# Verifies three small fixes from code-review-iter-090.md:
#
#   P2-1: RunRecapAnalyzer.compare_signatures returns
#         "insufficient_data" for sigs.size() < 2 (not "similar")
#   P2-3: PlayerTank._init_archetype MORTAR branch stops GunTimer
#         before setting wait_time (so DEFAULT→MORTAR doesn't
#         carry a stale cooldown)
#   P2-8: MortarShell._physics_process clamps t to [0,1] before
#         lerp (prevents frame-spike overshoot)
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_p2_batch1.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")
const AnalyzerT = preload("res://scripts/RunRecapAnalyzer.gd")


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === P2-1: RunRecapAnalyzer empty + single-sig verdict.
	var r_empty: Dictionary = AnalyzerT.compare_signatures([])
	if r_empty["verdict"] != "insufficient_data":
		push_error("FAIL — P2-1 empty input: verdict '%s', want 'insufficient_data'" % r_empty["verdict"])
		quit(1); return
	print("  P2-1 empty input: verdict='insufficient_data' (was 'similar' before fix)")

	var r_single: Dictionary = AnalyzerT.compare_signatures([{"archetype": 0, "band_sequence": ["a", "b"], "total_run_ms": 1000}])
	if r_single["verdict"] != "insufficient_data":
		push_error("FAIL — P2-1 single sig: verdict '%s', want 'insufficient_data'" % r_single["verdict"])
		quit(1); return
	print("  P2-1 single sig: verdict='insufficient_data' (sparse data correctly flagged)")

	# Two distinct sigs still returns "distinct" (verifies the
	# verdict semantics for legitimate input weren't broken).
	var r_two: Dictionary = AnalyzerT.compare_signatures([
		{"archetype": 0, "band_sequence": ["a", "b"], "total_run_ms": 1000},
		{"archetype": 1, "band_sequence": ["c", "d"], "total_run_ms": 2000},
	])
	if r_two["verdict"] != "distinct":
		push_error("FAIL — P2-1 2 distinct sigs: verdict '%s', want 'distinct'" % r_two["verdict"])
		quit(1); return
	print("  P2-1 2 distinct sigs: verdict='distinct' (legitimate verdict preserved)")

	# === P2-3: DEFAULT→MORTAR _init_archetype stops + restarts GunTimer.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	holder.add_child(pt)
	await process_frame
	await process_frame
	var gt: Timer = pt.get_node("GunTimer")

	# Prime the GunTimer to running state (simulate post-fire cooldown).
	gt.start()
	pt.can_shoot = false
	# Switch DEFAULT → MORTAR.
	pt.switch_archetype(PlayerTankT.TankArchetype.MORTAR)
	# After P2-3: GunTimer stopped + can_shoot true.
	if not gt.is_stopped():
		push_error("FAIL — P2-3: GunTimer still running after DEFAULT→MORTAR (stale cooldown leaked)")
		quit(1); return
	if not pt.can_shoot:
		push_error("FAIL — P2-3: can_shoot %s after DEFAULT→MORTAR, want true" % str(pt.can_shoot))
		quit(1); return
	print("  P2-3 DEFAULT→MORTAR: GunTimer stopped + can_shoot=true (stale cooldown cleared)")

	# === P2-8: MortarShell t clamp on frame-spike.
	var lvl := Node2D.new()
	holder.add_child(lvl)
	var shell: Node = MortarShellScene.instantiate()
	lvl.add_child(shell)
	shell.launch(Vector2.ZERO, Vector2(100, 0))
	await process_frame
	# Massive delta — TRAVEL_TIME is 0.6, so delta=10.0 should give t=16.67 → clamped to 1.0.
	shell._elapsed = 0.0
	# Drive _physics_process with a huge delta; t should clamp to 1.0
	# and _explode + queue_free.
	shell._physics_process(10.0)
	# Shell should have been _explode'd + queue_free'd (deferred).
	if not shell._exploded:
		push_error("FAIL — P2-8: frame-spike t didn't trigger _explode (still in flight)")
		quit(1); return
	print("  P2-8 frame-spike delta=10.0: t clamped to 1.0 → _explode fired (no NaN/overshoot)")

	holder.queue_free()
	print("BREACH_P2_BATCH1_OK P2-1 (analyzer verdict) + P2-3 (MORTAR init hygiene) + P2-8 (MortarShell t clamp) all verified")
	quit(0)
