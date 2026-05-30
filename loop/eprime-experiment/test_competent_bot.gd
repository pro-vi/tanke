extends SceneTree

# U1 verifier (arc-harness-v0.2 AC-A1) — the composite CompetentBot. It must
# instantiate as a BotPolicy(bot_id="competent"), return a VALID BotAction for
# any obs (teeth: null/garbage fails the validity gate before behavioural
# asserts so it never hangs headless), and exhibit each cascade verb on a
# triggering observation (teeth: a broken cascade fails these):
#   climb / engage (+HEAT vs Heavy) / breach brick (AP) / breach steel (APCR when
#   boxed) / DON'T fire at water / dodge an incoming shell / steer onto a depot.
#
# CompetentBot is deliberately NOT in BotRegistry (keeps the frozen Q1 7-bot
# matrix bit-identical), so this verifier preloads it directly.
#
# Emits `COMPETENT_OK` on full pass; quit(1) otherwise.

const Dir := Constants.Dir
const CompetentBotT := preload("res://scripts/bots/CompetentBot.gd")
const AP := 0
const HE := 1
const HEAT := 2
const APCR := 3


func _initialize() -> void:
	var failures: int = 0
	var bot: BotPolicy = CompetentBotT.new()

	if not (bot is BotPolicy):
		print("  FAIL — CompetentBot is not a BotPolicy"); failures += 1
	if bot.bot_id != "competent":
		print("  FAIL — bot_id=%s, expected 'competent'" % bot.bot_id); failures += 1

	# validity gate (teeth: a tick returning null/invalid fails here) — bail before
	# behavioural asserts so a fundamentally broken tick never hangs headless.
	var probes: Array = [
		_obs(Vector2i(5, 5), [], [], []),
		_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 1), "Heavy")], [_ob(Vector2i(5, 3), "brick")],
			[_proj(Vector2i(5, 2), Vector2(0, 1))], {"AP": -1, "HE": 1, "HEAT": 2, "APCR": 1}, AP, 1.0,
			[_depot(Vector2i(8, 2))]),
	]
	for o in probes:
		var ret = bot.tick(o)
		if ret == null or not (ret is BotAction) or not ret.is_valid():
			print("  FAIL — tick() returned invalid/null action"); failures += 1
	if failures > 0:
		print("COMPETENT_FAIL %d failures (basic validity)" % failures)
		quit(1)
		return
	print("  case validity gate OK")

	# 4. CLIMB — clear lane -> step upward, no fire.
	var c := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [], []))
	failures += _expect("clear lane -> climbs UP", c.move_dir == Dir.U)
	failures += _expect("clear lane -> does NOT fire", c.fire == false)

	# 2. ENGAGE — enemy lined up in the climb direction (directly above): fire WHILE
	# climbing (the bot never halts for combat — the tank faces up, the shot hits).
	var e := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 1), "Light")], [], []))
	failures += _expect("enemy lined up above + reloaded -> fires", e.fire == true)
	failures += _expect("fires WHILE climbing (does not halt)", e.move_dir == Dir.U)

	# 2b. ENGAGE — a Heavy lined up above with HEAT stocked -> swap to HEAT first.
	var h := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 1), "Heavy")], [], [],
		{"AP": -1, "HE": 0, "HEAT": 2, "APCR": 0}, AP, 1.0))
	failures += _expect("Heavy lined up above + HEAT stocked -> swaps to HEAT", h.shell_swap_to == HEAT)

	# 2c. ENGAGE — an OFF-AXIS enemy is NOT chased: the bot keeps climbing past it
	# (halting to chase every enemy is what pinned the tank in dense bands).
	var l := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [_enemy(Vector2i(7, 4), "Light")], [], []))
	failures += _expect("off-axis enemy -> keeps climbing (does not chase)", l.move_dir == Dir.U)
	failures += _expect("off-axis enemy -> does not fire (shot would miss)", l.fire == false)

	# 3. BREACH — brick directly above -> press up + fire (AP breaches brick).
	var b := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [_ob(Vector2i(5, 4), "brick")], []))
	failures += _expect("brick directly above -> fires to breach", b.fire == true)
	failures += _expect("breaching brick -> presses UP", b.move_dir == Dir.U)

	# 3b. BREACH — steel directly above AND boxed in (no BFS detour) + APCR stocked
	# -> swap to APCR (only APCR breaches steel).
	var boxed: Array = [_ob(Vector2i(5, 4), "steel"), _ob(Vector2i(4, 5), "steel"),
		_ob(Vector2i(6, 5), "steel"), _ob(Vector2i(5, 6), "steel")]
	var s := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], boxed, [], {"AP": -1, "HE": 0, "HEAT": 0, "APCR": 2}, AP, 1.0))
	failures += _expect("steel above + boxed in + APCR stocked -> swaps to APCR", s.shell_swap_to == APCR)

	# 3c. BREACH conservation — steel above but a detour exists -> route around, no APCR.
	var sd := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [_ob(Vector2i(5, 4), "steel")], [],
		{"AP": -1, "HE": 0, "HEAT": 0, "APCR": 2}, AP, 1.0))
	failures += _expect("steel above with a detour -> does NOT spend APCR", sd.shell_swap_to == BotAction.NO_SWAP)
	failures += _expect("steel above with a detour -> does NOT fire", sd.fire == false)

	# 3d. BREACH — never fire at water (unbreakable terrain).
	var w := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [_ob(Vector2i(5, 4), "water")], []))
	failures += _expect("water above -> does NOT fire", w.fire == false)

	# 1. SURVIVE — an enemy shell about to hit -> slip off the line, no fire.
	var d := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [], [_proj(Vector2i(5, 2), Vector2(0, 1))]))
	failures += _expect("incoming shell -> dodges off the line", d.move_dir != BotAction.NONE)
	failures += _expect("dodging -> does NOT fire", d.fire == false)

	# 4b. CLIMB — a depot a few rows above, off-column -> steer onto its column.
	var dp := CompetentBotT.new().tick(_obs(Vector2i(5, 5), [], [], [], {"AP": -1, "HE": 0, "HEAT": 0, "APCR": 0}, AP, 1.0,
		[_depot(Vector2i(9, 2))]))
	failures += _expect("depot above off-column -> steers toward its column", dp.move_dir == Dir.R)

	if failures == 0:
		print("COMPETENT_OK")
		quit(0)
	else:
		print("COMPETENT_FAIL %d failures" % failures)
		quit(1)


func _expect(desc: String, cond: bool) -> int:
	if cond:
		print("  behaviour %s OK" % desc)
		return 0
	print("  FAIL — behaviour: %s" % desc)
	return 1


func _obs(ptile: Vector2i, enemies: Array, obstacles: Array, projectiles: Array,
		reserves: Dictionary = {}, shell: int = 0, reload: float = 1.0,
		depots: Array = []) -> BotObservation:
	var o := BotObservation.new()
	o.player_pos_tile = ptile
	o.reload_bar_value = reload
	o.current_shell_class = shell
	if not reserves.is_empty():
		o.shell_reserves = reserves
	for e in enemies:
		o.visible_enemies.append(e)
	for ob in obstacles:
		o.visible_obstacles.append(ob)
	for pj in projectiles:
		o.visible_projectiles.append(pj)
	for dp in depots:
		o.visible_depots.append(dp)
	return o


func _enemy(tile: Vector2i, type: String) -> Dictionary:
	return {"pos_tile": tile, "hp": 1, "type": type}


func _ob(tile: Vector2i, type: String) -> Dictionary:
	return {"pos_tile": tile, "type": type}


func _proj(tile: Vector2i, heading: Vector2) -> Dictionary:
	return {"pos_tile": tile, "dir": heading, "shell_class": 0, "owner": "enemy"}


func _depot(tile: Vector2i) -> Dictionary:
	return {"pos_tile": tile, "name": "depot_test"}
