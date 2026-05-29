# arc-4 PR-#4 P1 review fix regression — Bullet._apply_he_blast had
# three converging bugs: (a) friendly-fired the player, (b) bypassed
# armor mitigation on splash, (c) skipped kill-attribution propagation
# + route-currency recording.
#
# This harness builds a MockLevel parent that mimics the iter-24
# lvl.player pattern + a MockPlayer that records take_damage calls,
# plus stub Heavy + Brick siblings around the HE blast origin.
#
# 6 cases:
#   1. HE splash does NOT damage the firing player (case a).
#   2. HE splash does NOT damage a sibling in the "player" group (case a).
#   3. HE splash on an armored Heavy applies ARMOR_MITIGATION (case b).
#   4. HE splash on an unarmored brick still does full damage.
#   5. HE splash propagates set_last_damage_shell + set_last_damage_source
#      to splash victims (case c).
#   6. HE splash does NOT extra-record route currency — shell economy
#      tracks shells SPENT (1 per shot), not bodies cleared. Probe 1 F1
#      "routes 1/1/1/1" depends on this. Splash adds bonus damage,
#      not bonus shell-spend.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_he_blast_friendly_fire.gd

extends SceneTree

const BulletT = preload("res://scripts/Bullet.gd")
const BulletScene = preload("res://scenes/Bullet.tscn")
const ARMOR_MITIGATION: int = 1  # mirror Bullet.gd const for assertions


# MockLevel exposes a `player` ref so Bullet._apply_he_blast can detect
# the firing player via the iter-24 lvl.player duck-type pattern.
class MockLevel extends Node2D:
	var player: MockPlayer = null

	func _init() -> void:
		player = MockPlayer.new()
		player.position = Vector2(0, 0)
		add_child(player)


# MockPlayer records take_damage calls; sits in "player" group so the
# group-skip path is also exercised by Cases 1+2.
class MockPlayer extends Node2D:
	var dmg_taken: int = 0

	# record_shot_hit pass-through so _try_record_shot_hit can fire.
	var routes_recorded: int = 0
	var combat_recorded: int = 0

	func _init() -> void:
		add_to_group("player")

	func take_damage(amount: int) -> void:
		dmg_taken += amount

	func record_shot_hit(_shell: int, kind: String) -> void:
		if kind == "route":
			routes_recorded += 1
		elif kind == "combat":
			combat_recorded += 1


# MockHeavy is armored (in "armored" group); records take_damage +
# set_last_damage_shell/source for attribution assertions.
class MockHeavy extends Node2D:
	var dmg_taken: int = 0
	var last_shell: int = -1
	var last_source: String = ""

	func _init() -> void:
		add_to_group("armored")

	func take_damage(amount: int) -> void:
		dmg_taken += amount

	func set_last_damage_shell(s: int) -> void:
		last_shell = s

	func set_last_damage_source(src: String) -> void:
		last_source = src


# MockBrick is unarmored; mirrors BrickBlock's take_damage contract.
class MockBrick extends Node2D:
	var dmg_taken: int = 0
	var last_shell: int = -1

	func take_damage(amount: int) -> void:
		dmg_taken += amount

	func set_last_damage_shell(s: int) -> void:
		last_shell = s


func _fire_he(parent: Node, primary: Node, origin: Vector2) -> void:
	# Position primary at origin so distance_to(origin) is 0.
	(primary as Node2D).position = origin
	var b: Node = BulletScene.instantiate()
	b.shell_class = BulletT.SHELL_CLASS_HE
	b.source_label = "player_he_test"
	parent.add_child(b)
	# Manually invoke _apply_he_blast on the primary so we exercise the
	# splash codepath without needing a real physics collision.
	b._apply_he_blast(primary)


func _initialize() -> void:
	# === Case 1: firing player NOT damaged by splash.
	var lvl1 := MockLevel.new()
	root.add_child(lvl1)
	await process_frame
	# Place the firing player WITHIN the blast radius (8px from primary).
	lvl1.player.position = Vector2(8, 0)
	# Primary brick at origin (16, 0); blast radius is 18.0 so player
	# 8px away from primary would be hit pre-fix.
	var primary1 := MockBrick.new()
	primary1.position = Vector2(16, 0)
	lvl1.add_child(primary1)
	await process_frame
	_fire_he(lvl1, primary1, primary1.position)
	if lvl1.player.dmg_taken != 0:
		push_error("FAIL — firing player took %d HE splash damage (want 0; case a friendly-fire)" % lvl1.player.dmg_taken)
		quit(1); return
	print("  case 1: firing player not damaged by HE splash (lvl.player ref skip)")

	# === Case 2: player-group sibling NOT damaged (independent of lvl.player).
	# Use a NEW level whose lvl.player is far away, but add a second node
	# in "player" group within radius — should still be skipped.
	var lvl2 := MockLevel.new()
	root.add_child(lvl2)
	await process_frame
	lvl2.player.position = Vector2(999, 999)  # far away — won't be hit anyway
	var second_player := MockPlayer.new()  # also in "player" group
	second_player.position = Vector2(8, 0)
	lvl2.add_child(second_player)
	var primary2 := MockBrick.new()
	primary2.position = Vector2(16, 0)
	lvl2.add_child(primary2)
	await process_frame
	_fire_he(lvl2, primary2, primary2.position)
	if second_player.dmg_taken != 0:
		push_error("FAIL — player-group sibling took %d HE splash damage (want 0; case a group skip)" % second_player.dmg_taken)
		quit(1); return
	print("  case 2: player-group sibling not damaged by HE splash (group filter)")

	# === Case 3: armored Heavy in splash applies ARMOR_MITIGATION.
	var lvl3 := MockLevel.new()
	root.add_child(lvl3)
	await process_frame
	lvl3.player.position = Vector2(999, 999)
	var heavy3 := MockHeavy.new()
	heavy3.position = Vector2(8, 0)
	lvl3.add_child(heavy3)
	var primary3 := MockBrick.new()
	primary3.position = Vector2(16, 0)
	lvl3.add_child(primary3)
	await process_frame
	_fire_he(lvl3, primary3, primary3.position)
	# Bullet default damage is 1; armor mitigation reduces to max(0, 1-1) = 0.
	if heavy3.dmg_taken != 0:
		push_error("FAIL — armored Heavy took %d HE splash (want 0 after armor mitigation; case b)" % heavy3.dmg_taken)
		quit(1); return
	print("  case 3: armored Heavy splash applies armor mitigation (HE = AP-class on armored)")

	# === Case 4: unarmored brick still takes full splash damage.
	var lvl4 := MockLevel.new()
	root.add_child(lvl4)
	await process_frame
	lvl4.player.position = Vector2(999, 999)
	var brick4 := MockBrick.new()
	brick4.position = Vector2(8, 0)
	lvl4.add_child(brick4)
	var primary4 := MockBrick.new()
	primary4.position = Vector2(16, 0)
	lvl4.add_child(primary4)
	await process_frame
	_fire_he(lvl4, primary4, primary4.position)
	if brick4.dmg_taken != 1:
		push_error("FAIL — unarmored brick splash dmg %d (want 1; mitigation should NOT apply)" % brick4.dmg_taken)
		quit(1); return
	print("  case 4: unarmored brick splash takes full damage (mitigation skipped)")

	# === Case 5: splash propagates set_last_damage_shell + set_last_damage_source
	# WHEN the hit actually applies damage. The unarmored brick (case 4)
	# took 1 damage → attribution set. The armored Heavy (case 3) took 0
	# damage after mitigation → attribution NOT set per PR-#4 S3 review
	# fix (don't attribute kills to hits that did zero damage).
	if brick4.last_shell != BulletT.SHELL_CLASS_HE:
		push_error("FAIL — splash brick last_shell=%d (want HE=%d; case c)" % [brick4.last_shell, BulletT.SHELL_CLASS_HE])
		quit(1); return
	# Heavy in case 3 had armor mitigation drive splash_deal to 0 → S3
	# gate skips attribution. Was -1 (initial) before any fire; should
	# still be -1.
	if heavy3.last_shell != -1:
		push_error("FAIL — splash Heavy last_shell=%d (want -1; S3 deal>0 gate should skip 0-damage attribution)" % heavy3.last_shell)
		quit(1); return
	if heavy3.last_source != "":
		push_error("FAIL — splash Heavy last_source='%s' (want ''; S3 deal>0 gate)" % heavy3.last_source)
		quit(1); return
	print("  case 5: splash propagates attribution when deal>0 (brick); SKIPS when deal=0 from armor (Heavy; S3 fix)")

	# === Case 6: gate-row splash does NOT extra-record route currency.
	# The shells_spent_on_routes ledger tracks shells SPENT, and only one
	# shell was fired. Counting each splash victim would overcount the
	# shell economy and break Probe 1 F1's routes-1/1/1/1 invariant.
	var lvl6 := MockLevel.new()
	root.add_child(lvl6)
	await process_frame
	lvl6.player.position = Vector2(999, 999)
	var gate_brick := MockBrick.new()
	gate_brick.position = Vector2(8, 0)
	gate_brick.set_meta("is_route_gate", true)
	lvl6.add_child(gate_brick)
	var primary6 := MockBrick.new()
	primary6.position = Vector2(16, 0)
	lvl6.add_child(primary6)
	await process_frame
	var routes_before: int = lvl6.player.routes_recorded
	_fire_he(lvl6, primary6, primary6.position)
	# _apply_he_blast is called by the caller AFTER the primary record;
	# in this isolated harness we never invoke the primary path, so
	# routes_recorded should be UNCHANGED after the splash.
	if lvl6.player.routes_recorded != routes_before:
		push_error("FAIL — splash extra-recorded %d routes (want 0; Probe 1 F1 routes-1/1/1/1 invariant broken)" \
				% (lvl6.player.routes_recorded - routes_before))
		quit(1); return
	print("  case 6: gate-row splash does NOT extra-record routes (shell economy = shells spent)")

	print("BREACH_HE_BLAST_FRIENDLY_FIRE_OK 6 cases — friendly-fire skip + armor mitigation + attribution propagation")
	quit(0)
