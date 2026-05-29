extends SceneTree

# U6 verifier (AC-001) — the 7 deterministic bot policies. For each registered
# bot: it instantiates as a BotPolicy with the expected bot_id and its tick()
# returns a VALID BotAction (teeth: a tick returning null/garbage fails the
# `is BotAction` + is_valid() gate). Plus per-bot BEHAVIOURAL assertions that a
# triggering observation produces the policy's defining action (teeth: a broken
# heuristic that ignores the observation fails these).
#
# Emits `BOTS_OK 7/7` on full pass; quit(1) otherwise.

const Dir := Constants.Dir


func _initialize() -> void:
	var failures: int = 0
	var ids: Array = BotRegistry.ids()

	if ids.size() != 7:
		print("  FAIL — registry has %d bots, expected 7" % ids.size()); failures += 1

	# generic: every bot instantiates + returns a valid action for a rich obs
	var rich := _obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))],
		[_obstacle(Vector2i(5, 8))], [_proj(Vector2i(5, 2), Vector2(0, 1))], 2, 3, 1.0)
	for id in ids:
		var p: BotPolicy = BotRegistry.make(id)
		if p == null or not (p is BotPolicy):
			print("  FAIL — registry.make(%s) is not a BotPolicy" % id); failures += 1; continue
		if p.bot_id != id:
			print("  FAIL — %s reports bot_id=%s" % [id, p.bot_id]); failures += 1
		var ret = p.tick(rich)
		if ret == null or not (ret is BotAction) or not ret.is_valid():
			print("  FAIL — %s.tick() returned invalid/null action" % id); failures += 1
		else:
			print("  case %s valid OK" % id)

	# unknown bot must NOT silently resolve (AC-007 precondition)
	if BotRegistry.make("no-such-bot") != null:
		print("  FAIL — registry.make(unknown) returned non-null (silent skip)"); failures += 1

	# Bail before the behavioural assertions if any bot is fundamentally broken
	# (e.g. tick() returns null) — otherwise dereferencing a null action below
	# would abort _initialize without reaching quit() and hang headless.
	if failures > 0:
		print("BOTS_FAIL %d failures (basic validity)" % failures)
		quit(1)
		return

	# --- behavioural teeth ---
	failures += _expect("approach-enemy moves toward enemy on the right",
		BotRegistry.make("approach-enemy").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))], [], [], 3, 3, 1.0)).move_dir == Dir.R)

	failures += _expect("fire-when-lined-up fires when enemy is axis-aligned",
		BotRegistry.make("fire-when-lined-up").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))], [], [], 3, 3, 1.0)).fire == true)

	failures += _expect("fire-when-lined-up holds (no move)",
		BotRegistry.make("fire-when-lined-up").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))], [], [], 3, 3, 1.0)).move_dir == BotAction.NONE)

	failures += _expect("objective-rush moves UP toward the exit",
		BotRegistry.make("objective-rush").tick(
			_obs(Vector2i(5, 5), [], [], [], 3, 3, 1.0)).move_dir == Dir.U)

	failures += _expect("objective-rush fires to breach a blocking obstacle above",
		BotRegistry.make("objective-rush").tick(
			_obs(Vector2i(5, 5), [], [_obstacle(Vector2i(5, 3))], [], 3, 3, 1.0)).fire == true)

	failures += _expect("move-to-cover moves toward obstacle below",
		BotRegistry.make("move-to-cover").tick(
			_obs(Vector2i(5, 5), [], [_obstacle(Vector2i(5, 8))], [], 3, 3, 1.0)).move_dir == Dir.D)

	failures += _expect("dodge-shell steps off the projectile line",
		BotRegistry.make("dodge-shell").tick(
			_obs(Vector2i(5, 5), [], [], [_proj(Vector2i(5, 2), Vector2(0, 1))], 3, 3, 1.0)).move_dir != BotAction.NONE)

	# reload-aware-wait: reloading (<0.8) -> kite away from enemy, no fire
	var raw := BotRegistry.make("reload-aware-wait").tick(
		_obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))], [], [], 3, 3, 0.5))
	failures += _expect("reload-aware-wait kites away while reloading", raw.move_dir == Dir.L)
	failures += _expect("reload-aware-wait does NOT fire while reloading", raw.fire == false)

	# panic-random: hurt -> a (deterministic) cardinal flail
	var pr := BotRegistry.make("panic-random").tick(
		_obs(Vector2i(5, 5), [_enemy(Vector2i(10, 5))], [], [], 1, 10, 1.0))
	failures += _expect("panic-random flails (a cardinal move) when hurt",
		pr.move_dir >= Dir.L and pr.move_dir <= Dir.R)

	# --- competence teeth (obstacle-avoidance + line-of-sight) ---
	# approach-enemy must steer AROUND a wall in its path, not walk into it:
	# enemy straight up (5,0), wall directly above at (5,4) -> sidestep (L/R), not U
	failures += _expect("approach-enemy steers around a blocking wall (not into it)",
		[Dir.L, Dir.R].has(BotRegistry.make("approach-enemy").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 0))], [_obstacle(Vector2i(5, 4))], [], 3, 3, 1.0)).move_dir))

	# fire-when-lined-up must HOLD fire when a wall blocks the cardinal line...
	failures += _expect("fire-when-lined-up holds fire when a wall blocks the shot",
		BotRegistry.make("fire-when-lined-up").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 0))], [_obstacle(Vector2i(5, 3))], [], 3, 3, 1.0)).fire == false)

	# ...and DOES fire when the line is clear (teeth both ways)
	failures += _expect("fire-when-lined-up fires when the cardinal line is clear",
		BotRegistry.make("fire-when-lined-up").tick(
			_obs(Vector2i(5, 5), [_enemy(Vector2i(5, 0))], [], [], 3, 3, 1.0)).fire == true)

	if failures == 0:
		print("BOTS_OK 7/7")
		quit(0)
	else:
		print("BOTS_FAIL %d failures" % failures)
		quit(1)


func _expect(desc: String, cond: bool) -> int:
	if cond:
		print("  behaviour %s OK" % desc)
		return 0
	print("  FAIL — behaviour: %s" % desc)
	return 1


func _obs(ptile: Vector2i, enemies: Array, obstacles: Array, projectiles: Array,
		hp: int, hp_max: int, reload: float) -> BotObservation:
	var o := BotObservation.new()
	o.player_pos_tile = ptile
	o.player_hp = hp
	o.player_hp_max = hp_max
	o.reload_bar_value = reload
	for e in enemies:
		o.visible_enemies.append(e)
	for ob in obstacles:
		o.visible_obstacles.append(ob)
	for pj in projectiles:
		o.visible_projectiles.append(pj)
	return o


func _enemy(tile: Vector2i) -> Dictionary:
	return {"pos_tile": tile, "hp": 1, "type": "Light"}


func _obstacle(tile: Vector2i) -> Dictionary:
	return {"pos_tile": tile, "type": "brick"}


func _proj(tile: Vector2i, heading: Vector2) -> Dictionary:
	return {"pos_tile": tile, "dir": heading, "shell_class": 0, "owner": "enemy"}
