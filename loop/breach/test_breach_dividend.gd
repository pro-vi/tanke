# Arc-4 breach mode: "Breach Dividend" depot rule-changer verifier
# (CONSULT 002 #2). Verifies: an HE shot that breaches >=4 bricks
# refunds 1 HE IF the firing player's loadout has breach_dividend on;
# no refund without the upgrade; no refund for a <4-brick breach.
#
# Builds a stub Level (has a `player`) + stub player (has a `loadout`)
# + a cluster of brick stubs, then drives Bullet._on_body_entered as
# an HE shot. Mirrors the arc-3 _initialize() harness pattern.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_dividend.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")
const DepotScene = preload("res://scenes/Depot.tscn")


class StubBrick extends Node2D:
	func take_damage(_amount: int) -> void:
		pass


class StubPlayer extends Node:
	var loadout = null


class StubLevel extends Node:
	var player = null


func _initialize() -> void:
	# Case A: 5-brick cluster, dividend ON  → he_reserve +1
	if not await _run("dividend ON, 5-cluster", true, 4, 2, 3):
		quit(1); return
	# Case B: 5-brick cluster, dividend OFF → no refund
	if not await _run("dividend OFF, 5-cluster", false, 4, 2, 2):
		quit(1); return
	# Case C: 2-brick cluster, dividend ON  → below threshold, no refund
	if not await _run("dividend ON, 2-cluster", true, 1, 2, 2):
		quit(1); return
	# Case D: dividend ON, cluster big but he_reserve already at max → capped
	if not await _run("dividend ON, at max", true, 4, 6, 6):
		quit(1); return

	# Confirm the depot upgrade actually sets the flag.
	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	await process_frame
	var lo := LoadoutT.new()
	depot.apply_upgrade(depot.UpgradeKind.BREACH_DIVIDEND, lo)
	if not lo.breach_dividend:
		push_error("FAIL — BREACH_DIVIDEND upgrade did not set the flag")
		quit(1); return
	depot.queue_free()

	print("BREACH_DIVIDEND_OK cluster-breach refunds HE only with the upgrade")
	quit(0)


# Spawn a stub Level→player→loadout + `neighbors` brick stubs around the
# primary, fire an HE bullet via _on_body_entered, check he_reserve.
func _run(label: String, dividend: bool, neighbors: int, start_he: int, expect_he: int) -> bool:
	var level := StubLevel.new()
	var player := StubPlayer.new()
	var lo := LoadoutT.new()
	lo.he_reserve = start_he
	lo.max_he_reserve = 6
	lo.breach_dividend = dividend
	player.loadout = lo
	level.player = player
	root.add_child(level)
	level.add_child(player)

	# Bullet must be a child of `level` so _try_breach_dividend's
	# get_parent() resolves to the stub Level.
	var bullet: Node = BulletScene.instantiate()
	level.add_child(bullet)
	await process_frame
	bullet.shell_class = BulletT.SHELL_CLASS_HE

	# Primary brick + `neighbors` siblings within HE_BLAST_RADIUS_PX (18).
	# All parented under one container so _apply_he_blast sees them as
	# siblings of the primary.
	var container := Node2D.new()
	level.add_child(container)
	var primary := StubBrick.new()
	primary.position = Vector2.ZERO
	container.add_child(primary)
	for i in neighbors:
		var b := StubBrick.new()
		# spread within 18px: small offsets
		b.position = Vector2(4 + i * 3, 0)
		container.add_child(b)
	await process_frame

	bullet._on_body_entered(primary)
	await process_frame

	if lo.he_reserve != expect_he:
		push_error("FAIL %s — he_reserve = %d, want %d" % [label, lo.he_reserve, expect_he])
		level.queue_free()
		return false
	print("  %s — he_reserve %d → %d" % [label, start_he, lo.he_reserve])
	level.queue_free()
	return true
