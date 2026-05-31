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
const DEPTH_PX: float = 16.0        # level's logical grid for rows-climbed/depth
const VISION_TILES: int = 30        # terrain/depot planning horizon (~a screen of the player)
# On-screen half-extents in 8px tiles for the 320x240 viewport (project.godot
# window/size): ~20 tiles horizontally (160px) and ~15 vertically (120px).
# These bound the ENEMY scan (not the looser VISION_TILES Manhattan radius) so
# off-screen enemy positions never feed aiming/dodging or exposure telemetry,
# honoring the screen-visible observation contract the harness measures
# (PR#5 #6). They are the PLAYER-CENTERED fallback used by the fixed Q1 lane;
# the arc/breach lane instead derives the on-screen bound from the live,
# bottom-clamped Camera2D rect (see _arc_view_rect + the enemy scan below),
# because a player-centered box is wrong under the arc's clamped/pinned camera.
# Terrain/depot scans keep VISION_TILES: a planning horizon (NavMemory
# accumulation), not a combat-fairness surface.
const VIEWPORT_HALF_X_TILES: int = 20   # 320px / 8px / 2
const VIEWPORT_HALF_Y_TILES: int = 15   # 240px / 8px / 2


static func _to_tile(world: Vector2) -> Vector2i:
	return Vector2i(roundi(world.x / CELL_PX), roundi(world.y / CELL_PX))


# Live on-screen world rect from the active Camera2D — the breach/arc lane's
# screen-visible bound. The arc camera (ProceduralLevel) is BOTTOM-CLAMPED
# (limit_bottom=240, player start y=232 -> every run begins clamped) and
# horizontally PINNED (level width == viewport width). Under the clamp a
# player-centered box hides on-screen enemies ABOVE the player — exactly where
# top-spawned enemies live — and, off-center, on the far horizontal side, which
# biased the very climb metric the arc measures (PR#5 Codex P2: deferred, now
# fixed arc-scoped). get_screen_center_position() honors limits + smoothing, so
# the rect is the actual rendered region. Returns an empty Rect2 (size 0) when
# no camera resolves, signalling the caller to use the player-centered fallback.
# Deterministic under --fixed-fps (fixed delta + seeded player path).
static func _arc_view_rect(player: Node, level: Node) -> Rect2:
	var vp := player.get_viewport()
	if vp == null:
		return Rect2()
	var cam: Camera2D = vp.get_camera_2d()
	if cam == null and level != null and is_instance_valid(level):
		cam = level.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return Rect2()
	var zoom: Vector2 = cam.zoom
	if zoom.x == 0.0 or zoom.y == 0.0:
		zoom = Vector2.ONE
	var size: Vector2 = vp.get_visible_rect().size / zoom
	var center: Vector2 = cam.get_screen_center_position()
	# one-tile margin so an enemy straddling the screen edge still counts visible
	return Rect2(center - size * 0.5, size).grow(CELL_PX)


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
	obs.player_pos_px = player.global_position   # continuous pos for motion lane-error

	# rows climbed (16px logical grid) from the start — the game's depth metric
	var start_y = player.get("_start_y")
	if start_y != null:
		obs.rows_climbed = int(maxf(0.0, (float(start_y) - player.global_position.y) / DEPTH_PX))

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
	# Screen-visible only. The arc/breach lane bounds enemies by the LIVE camera
	# rect (bottom-clamped + width-pinned — a player-centered box is wrong on both
	# axes there, hiding on-screen enemies above/beside the player; PR#5 Codex P2).
	# The fixed Q1 lane keeps the static player-centered VIEWPORT half-extents,
	# byte-identical to before (De Morgan of the old |dx|>X or |dy|>Y cutoff), so
	# its frozen telemetry/HASH sentinel is untouched. Off-screen enemy positions
	# must NOT inform aiming/dodging or exposure telemetry — that breaks the
	# screen-visible observation contract the harness measures (PR#5 #6).
	var is_breach := false
	if level != null and is_instance_valid(level) and ("breach_mode_enabled" in level):
		is_breach = bool(level.breach_mode_enabled)
	var view_rect := Rect2()
	if is_breach:
		view_rect = _arc_view_rect(player, level)
	var use_view: bool = view_rect.size.x > 0.0
	var tree := player.get_tree()
	if tree != null:
		for e in tree.get_nodes_in_group("enemy"):
			if e == null or not is_instance_valid(e):
				continue
			var et: Vector2i = _to_tile(e.global_position)
			var on_screen: bool
			if use_view:
				on_screen = view_rect.has_point(e.global_position)
			else:
				on_screen = abs(et.x - obs.player_pos_tile.x) <= VIEWPORT_HALF_X_TILES \
						and abs(et.y - obs.player_pos_tile.y) <= VIEWPORT_HALF_Y_TILES
			if not on_screen:
				continue
			obs.visible_enemies.append({
				"pos_tile": et,
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
				# Classify terrain by GROUP + SCRIPT, then name. The procedural
				# BreachLevel instantiates BrickBlock.tscn whose ROOT is a bare
				# StaticBody2D, so converted bricks auto-name `@StaticBody2D@N` —
				# a name-substring match (Q1's "BrickBlock_c_r") misses every one,
				# which left the bot blind to the entire procedural climb. The
				# attached script path (res://scripts/BrickBlock.gd) is the stable
				# tell; steel self-registers in group "steel". Scoped to a screen
				# of the player (faithful + bounds scan cost on the arc).
				# WaterBlock.tscn is a SCRIPTLESS StaticBody2D on collision layer 512,
				# and only the first instance keeps the name "WaterBlock" — the rest
				# auto-name `@StaticBody2D@N`, so neither name nor script identifies
				# them. The collision LAYER does (512 == water), which is why a tank
				# kept wedging on invisible water it couldn't see or breach.
				var nm: String = c.name
				var sp: String = ""
				var scr = c.get_script()
				if scr != null and scr.resource_path != null:
					sp = String(scr.resource_path)
				var layer: int = int(c.collision_layer)
				var kind: String = ""
				if c.is_in_group("steel") or nm.contains("Steel") or sp.contains("Steel"):
					kind = "steel"
				elif (layer & 512) != 0 or nm.contains("Water") or sp.contains("Water"):
					kind = "water"
				elif nm.contains("Brick") or sp.contains("Brick"):
					kind = "brick"
				if kind != "":
					var ot: Vector2i = _to_tile(c.global_position)
					if abs(ot.x - obs.player_pos_tile.x) + abs(ot.y - obs.player_pos_tile.y) <= VISION_TILES:
						obs.visible_obstacles.append({"pos_tile": ot, "type": kind})
			elif c is Area2D and c.has_method("apply_choice"):
				# breach-mode field depot — the next safe-gate a human sees.
				# Duck-typed on the public apply_choice (Depot.gd:355). Lets the
				# arc CompetentBot steer onto the depot column to trigger its
				# upgrade gate. Absent in fixed rooms -> visible_depots stays [].
				var dt: Vector2i = _to_tile(c.global_position)
				if abs(dt.x - obs.player_pos_tile.x) + abs(dt.y - obs.player_pos_tile.y) <= VISION_TILES:
					var dn = c.get("depot_name")
					var nm2: String = str(dn) if dn != null and str(dn) != "" else String(c.name)
					obs.visible_depots.append({"pos_tile": dt, "name": nm2})

	return obs
