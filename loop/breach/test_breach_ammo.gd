# Arc-4 breach mode: enemy ammo-drop verifier (Round 8c, iter 58).
# Verifies the AmmoPickup entity (playtest-3 — "does enemy drop ammo?"):
#   - on _ready it picks a droppable shell (HE/HEAT/APCR, never AP)
#   - the player driving over it adds AMOUNT to that shell's reserve
#     + shows a toast + frees the pickup
#   - a body with no loadout (arc-2/3) does not collect it
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_ammo.gd

extends SceneTree

const AmmoPickupScene = preload("res://scenes/AmmoPickup.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const BulletT = preload("res://scripts/Bullet.gd")


class StubPlayer extends Node:
	var loadout = null
	var toasts: int = 0
	func _show_pickup_toast(_text, _color) -> void:
		toasts += 1


func _reserve(lo, sc: int) -> int:
	if sc == BulletT.SHELL_CLASS_HE:
		return lo.he_reserve
	if sc == BulletT.SHELL_CLASS_HEAT:
		return lo.heat_reserve
	if sc == BulletT.SHELL_CLASS_APCR:
		return lo.apcr_reserve
	return -1


func _initialize() -> void:
	# === a pickup picks a droppable shell (never AP).
	var pickup: Area2D = AmmoPickupScene.instantiate()
	root.add_child(pickup)
	await process_frame
	var sc: int = pickup.shell_class
	var amt: int = pickup.AMOUNT
	if sc == BulletT.SHELL_CLASS_AP:
		push_error("FAIL — pickup dropped AP (the unlimited shell)"); quit(1); return
	if _reserve(LoadoutT.new(), sc) < 0:
		push_error("FAIL — pickup shell_class %d is not a droppable shell" % sc); quit(1); return
	if pickup.get_node_or_null("Chip") == null:
		push_error("FAIL — pickup has no Chip visual"); quit(1); return
	print("  pickup picks a droppable shell (class %d), chip built" % sc)

	# === the player drives over it → +AMOUNT to that shell's reserve.
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.he_reserve = 0
	lo.heat_reserve = 0
	lo.apcr_reserve = 0
	player.loadout = lo
	root.add_child(player)
	await process_frame
	var before: int = _reserve(lo, sc)
	pickup._on_body_entered(player)
	await process_frame
	if _reserve(lo, sc) != before + amt:
		push_error("FAIL — reserve %d, want %d after collect" % [_reserve(lo, sc), before + amt])
		quit(1); return
	if is_instance_valid(pickup):
		push_error("FAIL — pickup not freed after collection"); quit(1); return
	if player.toasts < 1:
		push_error("FAIL — no pickup toast on collection"); quit(1); return
	print("  collected: +%d to shell %d, toast shown, pickup freed" % [amt, sc])

	# === a body with no loadout (arc-2/3) does not collect.
	var pickup2: Area2D = AmmoPickupScene.instantiate()
	root.add_child(pickup2)
	await process_frame
	var bare := StubPlayer.new()  # loadout stays null
	root.add_child(bare)
	await process_frame
	pickup2._on_body_entered(bare)
	await process_frame
	if not is_instance_valid(pickup2):
		push_error("FAIL — pickup collected by a no-loadout body (arc-2/3 regression)")
		quit(1); return
	print("  no-loadout body does not collect (arc-2/3 safe)")
	pickup2.queue_free()

	print("BREACH_AMMO_OK enemy ammo drops; player collects to reserve; arc-2/3 unaffected")
	quit(0)
