# Arc-4 breach mode: APCR shell verifier (Round 5, iter 34 — the
# sanctioned 4th shell; user override of CONSULT constraint 2).
# Verifies:
#   1. SHELL_CLASS_APCR exists, distinct from AP/HE/HEAT.
#   2. APCR breaches a SteelBlock (calls breach() → node freed).
#   3. AP / HE / HEAT do NOT breach steel (SteelBlock survives).
#   4. APCR breach has a radius — a near steel sibling opens too, a far
#      one does not.
#   5. APCR pierces armor: an armored stub takes full damage from APCR,
#      unlike AP which is mitigated to 0.
#   6. Loadout APCR economy: apcr_reserve + can_fire + consume + refill.
#
# Bullet._on_body_entered is invoked directly with stub/real bodies
# (the arc-3 _initialize() harness pattern; cf. test_breach_he_blast.gd).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_apcr.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


class StubArmored extends Node2D:
	var hp: int = 5
	var damage_taken: int = 0

	func _ready() -> void:
		add_to_group("armored")

	func take_damage(amount: int) -> void:
		hp -= amount
		damage_taken += amount


func _initialize() -> void:
	# === Test 1: SHELL_CLASS_APCR exists + distinct.
	var apcr: int = BulletT.SHELL_CLASS_APCR
	if apcr == BulletT.SHELL_CLASS_AP or apcr == BulletT.SHELL_CLASS_HE \
			or apcr == BulletT.SHELL_CLASS_HEAT:
		push_error("FAIL — SHELL_CLASS_APCR not distinct")
		quit(1); return
	print("  APCR shell class = %d (distinct)" % apcr)

	# === Tests 2-4: steel breaching (shell-class gating + radius).
	if not await _test_steel_breach():
		quit(1); return

	# === Test 5: APCR pierces armor.
	if not await _test_armor_pierce():
		quit(1); return

	# === Test 6: Loadout APCR economy.
	if not _test_loadout_apcr():
		quit(1); return

	print("BREACH_APCR_OK APCR breaches steel; AP/HE/HEAT cannot; pierces armor")
	quit(0)


# Fire one bullet of `shell` at `target` via _on_body_entered. The bullet
# needs a parent (its _spawn_impact_spark + queue_free assume one).
func _fire_at(shell: int, target: Node) -> void:
	var bullet: Node = BulletScene.instantiate()
	root.add_child(bullet)
	await process_frame
	bullet.shell_class = shell
	bullet._on_body_entered(target)
	await process_frame


func _test_steel_breach() -> bool:
	# AP / HE / HEAT must NOT breach steel.
	for pair in [[BulletT.SHELL_CLASS_AP, "AP"],
			[BulletT.SHELL_CLASS_HE, "HE"], [BulletT.SHELL_CLASS_HEAT, "HEAT"]]:
		var container := Node2D.new()
		root.add_child(container)
		var steel: Node2D = SteelBlockScene.instantiate()
		container.add_child(steel)
		await process_frame
		await _fire_at(pair[0], steel)
		if not is_instance_valid(steel):
			push_error("FAIL — %s breached steel (only APCR may)" % pair[1])
			container.queue_free()
			return false
		print("  %s — steel survived (correct)" % pair[1])
		container.queue_free()
		await process_frame

	# APCR breaches the hit steel + a near sibling; a far one survives.
	var box := Node2D.new()
	root.add_child(box)
	var hit: Node2D = SteelBlockScene.instantiate()
	hit.position = Vector2.ZERO
	box.add_child(hit)
	var near: Node2D = SteelBlockScene.instantiate()
	near.position = Vector2(16, 0)   # within APCR_BREACH_RADIUS_PX (18)
	box.add_child(near)
	var far: Node2D = SteelBlockScene.instantiate()
	far.position = Vector2(40, 0)    # outside the radius
	box.add_child(far)
	await process_frame
	await _fire_at(BulletT.SHELL_CLASS_APCR, hit)
	if is_instance_valid(hit):
		push_error("FAIL — APCR did not breach the hit steel block")
		box.queue_free(); return false
	if is_instance_valid(near):
		push_error("FAIL — APCR did not breach the near steel sibling (radius)")
		box.queue_free(); return false
	if not is_instance_valid(far):
		push_error("FAIL — APCR breached a steel block outside its radius")
		box.queue_free(); return false
	print("  APCR — breached hit + near; far survived (radius correct)")
	box.queue_free()
	await process_frame
	return true


func _test_armor_pierce() -> bool:
	# APCR vs armored: full damage (pierces). AP vs armored: mitigated to 0.
	var container := Node2D.new()
	root.add_child(container)

	var armored_apcr := StubArmored.new()
	container.add_child(armored_apcr)
	var armored_ap := StubArmored.new()
	container.add_child(armored_ap)
	await process_frame

	await _fire_at(BulletT.SHELL_CLASS_APCR, armored_apcr)
	await _fire_at(BulletT.SHELL_CLASS_AP, armored_ap)

	if armored_apcr.damage_taken < 1:
		push_error("FAIL — APCR mitigated by armor (took %d, want >=1)" % armored_apcr.damage_taken)
		container.queue_free(); return false
	if armored_ap.damage_taken != 0:
		push_error("FAIL — AP not mitigated by armor (took %d, want 0)" % armored_ap.damage_taken)
		container.queue_free(); return false
	print("  APCR pierces armor (took %d); AP mitigated to 0" % armored_apcr.damage_taken)
	container.queue_free()
	await process_frame
	return true


func _test_loadout_apcr() -> bool:
	var lo: LoadoutT = LoadoutT.new()
	lo.apcr_reserve = 2
	lo.max_apcr_reserve = 4
	if not lo.can_fire(BulletT.SHELL_CLASS_APCR):
		push_error("FAIL — can_fire(APCR) false at apcr_reserve=2"); return false
	var fired: int = lo.consume(BulletT.SHELL_CLASS_APCR)
	if fired != BulletT.SHELL_CLASS_APCR or lo.apcr_reserve != 1:
		push_error("FAIL — consume(APCR) wrong (fired=%d reserve=%d)" % [fired, lo.apcr_reserve]); return false
	lo.apcr_reserve = 0
	if lo.consume(BulletT.SHELL_CLASS_APCR) != BulletT.SHELL_CLASS_AP:
		push_error("FAIL — consume(APCR) at reserve 0 should fall back to AP"); return false
	lo.refill_apcr(99)
	if lo.apcr_reserve != lo.max_apcr_reserve:
		push_error("FAIL — refill_apcr did not cap at max (got %d)" % lo.apcr_reserve); return false
	print("  loadout APCR economy: consume + fallback + refill cap OK")
	return true
