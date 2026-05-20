# Arc-4 breach mode: Loadout + finite reserves verifier (round 2;
# CONSULT 001 "atomic verb" cite). Verifies:
#   1. Loadout.gd Resource instantiates with default reserves
#   2. consume(HE) decrements he_reserve when > 0
#   3. consume(HE) with he_reserve = 0 falls back to AP (no decrement)
#   4. can_fire(AP) always true (unlimited baseline)
#   5. PlayerTank.gd default loadout = null → arc-2 baseline (current
#      _fire always emits AP via shoot.emit)
#   6. PlayerTank.gd with loadout set + current_shell = HE → consume()
#      decrements reserve + shoot.emit carries shell_class = HE
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_loadout.gd

extends SceneTree

const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")


func _initialize() -> void:
	# === Test 1: Loadout.gd schema.
	var lo: LoadoutT = LoadoutT.new()
	lo.he_reserve = 3
	lo.heat_reserve = 1
	if not lo.can_fire(BulletT.SHELL_CLASS_AP):
		push_error("FAIL — AP should always be fire-able"); quit(1); return
	if not lo.can_fire(BulletT.SHELL_CLASS_HE):
		push_error("FAIL — HE fire blocked at he_reserve=3"); quit(1); return
	if not lo.can_fire(BulletT.SHELL_CLASS_HEAT):
		push_error("FAIL — HEAT fire blocked at heat_reserve=1"); quit(1); return

	# === Test 2: consume(HE) decrements he_reserve.
	var fired: int = lo.consume(BulletT.SHELL_CLASS_HE)
	if fired != BulletT.SHELL_CLASS_HE:
		push_error("FAIL — consume(HE) did not return HE (got %d)" % fired); quit(1); return
	if lo.he_reserve != 2:
		push_error("FAIL — he_reserve should be 2 after one HE fire (got %d)" % lo.he_reserve); quit(1); return

	# === Test 3: consume(HE) at he_reserve = 0 falls back to AP.
	lo.he_reserve = 0
	fired = lo.consume(BulletT.SHELL_CLASS_HE)
	if fired != BulletT.SHELL_CLASS_AP:
		push_error("FAIL — consume(HE) at reserve=0 should return AP (got %d)" % fired); quit(1); return
	if lo.he_reserve != 0:
		push_error("FAIL — he_reserve should stay 0 (got %d)" % lo.he_reserve); quit(1); return

	# === Test 4: PlayerTank default loadout = null → arc-2 baseline.
	var pt_default: Node = PlayerTankScene.instantiate()
	root.add_child(pt_default)
	await process_frame
	if pt_default.loadout != null:
		push_error("FAIL — PlayerTank default loadout != null (regression risk)"); quit(1); return
	if pt_default.current_shell != BulletT.SHELL_CLASS_AP:
		push_error("FAIL — PlayerTank default current_shell != AP"); quit(1); return
	pt_default.queue_free()

	# === Test 5: PlayerTank with loadout — consume on _fire.
	var pt_loaded: Node = PlayerTankScene.instantiate()
	var lo2: LoadoutT = LoadoutT.new()
	lo2.he_reserve = 2
	pt_loaded.loadout = lo2
	pt_loaded.current_shell = BulletT.SHELL_CLASS_HE
	root.add_child(pt_loaded)
	await process_frame
	# Connect a sink to capture the emitted shoot signal's shell_class.
	var captured: Array[int] = []
	pt_loaded.shoot.connect(func(_bs, _pos, _dir, sc): captured.append(sc))
	# Force-fire (bypass can_shoot gate by directly calling _fire; the
	# arc-3 test pattern uses direct method invocation for harness work).
	pt_loaded._fire()
	await process_frame
	if captured.size() != 1:
		push_error("FAIL — shoot signal not emitted once (got %d)" % captured.size()); quit(1); return
	if captured[0] != BulletT.SHELL_CLASS_HE:
		push_error("FAIL — shoot.shell_class != HE (got %d)" % captured[0]); quit(1); return
	# iter 44 (F004): PlayerTank duplicates its loadout at _ready — the
	# consumed reserve lives on pt_loaded.loadout (the per-run copy).
	if pt_loaded.loadout.he_reserve != 1:
		push_error("FAIL — he_reserve should be 1 after one HE _fire (got %d)" % pt_loaded.loadout.he_reserve); quit(1); return
	pt_loaded.queue_free()

	# === Test 6 (iter 44, F004): the loadout is per-run isolated. The
	# breach starter loadout is a shared Resource baked into
	# BreachLevel.tscn; without a per-run copy, consume() in run 1 would
	# leave run 2 starting depleted (reload_current_scene reuses the
	# resource cache).
	var t1 = load("res://configs/breach_starter_loadout.tres")
	var t2 = load("res://configs/breach_starter_loadout.tres")
	if t1 != t2:
		push_error("FAIL — load() did not return the cached instance"); quit(1); return
	var template: LoadoutT = LoadoutT.new()
	template.he_reserve = 5
	var pt_iso: Node = PlayerTankScene.instantiate()
	pt_iso.loadout = template
	root.add_child(pt_iso)
	await process_frame
	if pt_iso.loadout == template:
		push_error("FAIL — PlayerTank did not duplicate its loadout (run-leak risk)"); quit(1); return
	if pt_iso.loadout.he_reserve != 5:
		push_error("FAIL — the duplicated loadout lost its values"); quit(1); return
	pt_iso.loadout.he_reserve = 0  # simulate a run spending the reserve
	if template.he_reserve != 5:
		push_error("FAIL — spending the run loadout mutated the template"); quit(1); return
	pt_iso.queue_free()
	print("  loadout per-run isolation: PlayerTank copies; template untouched")

	print("BREACH_LOADOUT_OK finite reserves + consume-on-fire + per-run isolation")
	quit(0)
