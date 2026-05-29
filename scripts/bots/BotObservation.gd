class_name BotObservation
extends RefCounted

# What a bot SEES on a given tick — constrained to screen-visible state per
# /agentify Pro 2026-05-27 §3 ("bots see what the screen shows, not ground
# truth"). This constraint is what makes ui_action_correlation (AC-002) a
# meaningful proxy for the consult-001 P2/P3 legibility predictions. See
# loop/eprime-experiment/iter-0-architect.md § Observation contract.
#
# Tile coordinates use the Q1ProofRoom 8px grid (Q1ProofRoomScene.CELL_PX).
# Built per tick by the bot harness from the live PlayerTank + scene tree;
# bots never reach into level internals, enemy AI plans, or spawn schedules.

# --- screen-visible UI state (what a human reads off the HUD) ---
var player_hp: int = 0
var player_hp_max: int = 0
# [0.0, 1.0]; 1.0 == ready to fire. Mirrors the reload bar fill.
var reload_bar_value: float = 1.0
# Bullet.SHELL_CLASS_* (0..3) — the highlighted shell chip.
var current_shell_class: int = 0
# Reserve counts per class. AP is unlimited, represented as -1.
var shell_reserves: Dictionary = {"AP": -1, "HE": 0, "HEAT": 0, "APCR": 0}
# Visible active-card ribbon chip count.
var active_card_count: int = 0
# Speed meter display, normalized to baseline (1.0 == base speed).
var speed_meter_normalized: float = 1.0

# --- spatial state (what the rendered tiles reveal) ---
var player_pos_tile: Vector2i = Vector2i.ZERO
# Each: {pos_tile: Vector2i, hp: int, type: String}
var visible_enemies: Array[Dictionary] = []
# Each: {pos_tile: Vector2i, type: String}  (type: "brick"|"steel")
var visible_obstacles: Array[Dictionary] = []
# Each: {pos_tile: Vector2i, dir: Vector2, shell_class: int, owner: String}
# owner: "player" | "enemy"
var visible_projectiles: Array[Dictionary] = []

# --- timing ---
var iter_n: int = 0        # physics ticks since run start
var time_sec: float = 0.0  # wall seconds since run start


# Closest enemy by Manhattan tile distance, or {} if none visible. Manhattan
# (not Euclidean) because movement is cardinal — there is no Manhattan helper
# in the repo (Enemy.gd uses Euclidean distance_to), so bots get it here.
func nearest_enemy() -> Dictionary:
	var best: Dictionary = {}
	var best_d: int = 1 << 30
	for e in visible_enemies:
		var p: Vector2i = e["pos_tile"]
		var d: int = absi(p.x - player_pos_tile.x) + absi(p.y - player_pos_tile.y)
		if d < best_d:
			best_d = d
			best = e
	return best


# Incoming non-player projectile whose heading points roughly at the player,
# or {} if none. Used by DodgeShellBot.
func incoming_projectile() -> Dictionary:
	for pr in visible_projectiles:
		if pr.get("owner", "") == "player":
			continue
		var to_player := Vector2(player_pos_tile - (pr["pos_tile"] as Vector2i))
		if to_player.length() < 0.001:
			return pr
		var dir: Vector2 = pr.get("dir", Vector2.ZERO)
		if dir.length() < 0.001:
			continue
		# heading aligned within ~45deg of the player bearing
		if dir.normalized().dot(to_player.normalized()) > 0.5:
			return pr
	return {}
