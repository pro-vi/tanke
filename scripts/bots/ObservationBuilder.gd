class_name ObservationBuilder
extends RefCounted

# Builds a BotObservation from the live scene — the single source of truth for
# "what the bot sees," shared by BotInputDriver (U3, drives the policy) and
# TelemetryRecorder (U4, samples per tick). Reads ONLY screen-visible PlayerTank
# state + scene-tree spatial state; never level internals, enemy plans, or
# spawn schedules (consult §3 constraint that makes ui_action_correlation a
# meaningful legibility proxy).
#
# Field reads verified against scripts/PlayerTank.gd (iter-1 subsystem map):
#   hp:107, max_hp:50, current_shell:80, _last_fire_time:140, loadout:63,
#   _applied_cards:171, _overdrive_timer:83, overdrive_mult:76, speed:44.
# Q1ProofRoom grid: 8px cells (Q1ProofRoomScene.CELL_PX), enemies in group
# "enemy" (Enemy.gd:123), bullets = Area2D children with start() + shell_class
# + source_label (""=player) (Bullet.gd).

const CELL_PX: float = 8.0
const SPEED_BASELINE: float = 32.0  # PlayerTank SPEED_BASELINE:145


static func _to_tile(world: Vector2) -> Vector2i:
	return Vector2i(roundi(world.x / CELL_PX), roundi(world.y / CELL_PX))


static func build(player: Node, level: Node, iter_n: int, time_sec: float) -> BotObservation:
	var obs := BotObservation.new()
	obs.iter_n = iter_n
	obs.time_sec = time_sec
	if player == null or not is_instance_valid(player):
		return obs

	# --- screen-visible UI state ---
	obs.player_hp = int(player.get("hp"))
	obs.player_hp_max = int(player.get("max_hp"))
	obs.current_shell_class = int(player.get("current_shell"))
	obs.player_pos_tile = _to_tile(player.global_position)

	# reload bar from the ACTUAL game-time fire gate (PlayerTank.can_shoot +
	# GunTimer.time_left), NOT wall clock. PlayerTank.can_shoot is cleared on
	# fire and restored by GunTimer.timeout (a game-time Timer); _last_fire_time
	# is wall-time display-only. Reading wall time made reload state CPU-speed-
	# dependent under --fixed-fps and the reload-cancel/correlation telemetry
	# non-deterministic. (Codex PR#5 P1.)
	var can_shoot = player.get("can_shoot")
	var gun: Node = player.get_node_or_null("GunTimer")
	if can_shoot != null and not bool(can_shoot) and gun != null \
			and not gun.is_stopped() and float(gun.wait_time) > 0.0:
		obs.reload_bar_value = clampf(1.0 - float(gun.time_left) / float(gun.wait_time), 0.0, 1.0)
	else:
		obs.reload_bar_value = 1.0  # ready: can_shoot true, or no live cooldown

	# shell reserves (AP unlimited = -1)
	var loadout = player.get("loadout")
	if loadout != null:
		obs.shell_reserves = {
			"AP": -1,
			"HE": int(loadout.get("he_reserve")),
			"HEAT": int(loadout.get("heat_reserve")),
			"APCR": int(loadout.get("apcr_reserve")),
		}

	# active-cards ribbon count (capped at 8 like the HUD)
	var applied = player.get("_applied_cards")
	if applied != null:
		obs.active_card_count = mini((applied as Array).size(), 8)

	# speed meter normalized
	var spd: float = float(player.get("speed"))
	var od_timer = player.get("_overdrive_timer")
	var od_mult = player.get("overdrive_mult")
	if od_timer != null and float(od_timer) > 0.0 and od_mult != null:
		spd *= float(od_mult)
	obs.speed_meter_normalized = spd / SPEED_BASELINE

	# --- spatial: enemies (group "enemy") ---
	var tree := player.get_tree()
	if tree != null:
		for e in tree.get_nodes_in_group("enemy"):
			if e == null or not is_instance_valid(e):
				continue
			obs.visible_enemies.append({
				"pos_tile": _to_tile(e.global_position),
				"hp": int(e.get("hp")) if e.get("hp") != null else 1,
				"type": str(e.get("enemy_type")) if e.get("enemy_type") != null else "Light",
			})

	# --- spatial: projectiles + obstacles (scan level children) ---
	if level != null and is_instance_valid(level):
		for c in level.get_children():
			if not is_instance_valid(c):
				continue
			if c is Area2D and c.has_method("start"):
				# Bullet: derive heading from velocity, owner from source_label
				var vel: Vector2 = c.get("velocity") if c.get("velocity") != null else Vector2.ZERO
				var src: String = str(c.get("source_label")) if c.get("source_label") != null else ""
				obs.visible_projectiles.append({
					"pos_tile": _to_tile(c.global_position),
					"dir": vel.normalized() if vel.length() > 0.001 else Vector2.ZERO,
					"shell_class": int(c.get("shell_class")) if c.get("shell_class") != null else 0,
					"owner": "player" if src == "" else "enemy",
				})
			elif c is StaticBody2D:
				var nm: String = c.name
				var kind: String = ""
				if nm.begins_with("BrickBlock"):
					kind = "brick"
				elif nm.begins_with("SteelBlock"):
					kind = "steel"
				if kind != "":
					obs.visible_obstacles.append({
						"pos_tile": _to_tile(c.global_position),
						"type": kind,
					})

	return obs
