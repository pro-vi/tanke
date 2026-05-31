class_name TelemetryRecorder
extends Node

# Records one run's telemetry (AC-002) by subscribing to PlayerTank signals +
# sampling a BotObservation each physics tick, then on run-end writes a
# schema-conforming JSON. A SIBLING of PlayerTank (zero substrate touch); the
# batch runner (U7) creates one per run, sets the config fields below, adds it,
# and reads back the emitted JSON.
#
# Signals subscribed (verified PlayerTank.gd:40-42,380): shoot(scene,pos,dir,
# shell_class), hp_changed(new,max), died, lives_changed. _ready asserts they
# exist so a future PlayerTank refactor that drops one fails loud here.
#
# ui_action_correlation is the consult-001 P2/P3 legibility proxy: for each
# watched UI STATE (reload-ready / shell-chip / ribbon-visible), the fraction
# of state flips that are followed by an action change within CORR_WINDOW ticks.
# Needs the chosen action; read from the BotInputDriver sibling (`driver`).

const SHELL_NAMES := ["AP", "HE", "HEAT", "APCR"]
const PHYSICS_FPS := 60.0     # game-time clock (physics ticks/sec)
const TIMEOUT_SEC := 30.0     # game-time cap (frame-based; headless-stable)
const EXPOSURE_RADIUS_TILES := 12
const GOAL_ROW := 0          # Q1ProofRoom victory row (PLAYER_START_ROW=29 -> 0)
const CORR_WINDOW := 30      # ticks to watch for an action change after a UI flip
const RELOAD_READY := 0.8    # reload_bar_value >= this == "ready" state

# --- config (set by the runner before add_child) ---
var player: Node = null
var level: Node = null
var driver = null            # BotInputDriver sibling (optional; for actions)
var seed_value: int = 0
var bot_id: String = "unknown"
var out_path: String = ""    # JSON write target; "" -> no write (signal only)

# --- run accumulators ---
var _ended: bool = false
var _start_ms: int = 0
var _tick: int = 0
var _shells_fired := {"AP": 0, "HE": 0, "HEAT": 0, "APCR": 0}
var _damage_taken: int = 0
var _prev_hp: int = -1
var _exposed_ticks: int = 0
var _reload_cancel_events: int = 0
var _hits_at_end: int = 0
var _last_obs: BotObservation = null

# correlation: per field [flips, flips_followed_by_action_change]; pending = ticks
# since the last unmatched flip (-1 = none pending)
var _corr := {"reload_bar": [0, 0], "shell_chip": [0, 0], "ribbon_visible": [0, 0]}
var _corr_pending := {"reload_bar": -1, "shell_chip": -1, "ribbon_visible": -1}
var _prev_reload_ready: int = -1   # -1 unknown, else 0/1
var _prev_shell: int = -1
var _prev_ribbon: int = -1         # 0/1 visible
var _prev_action_sig := "__init__"
var _result: Dictionary = {}   # the finalized record (read by the batch runner)

signal recorded(telemetry: Dictionary)


func _ready() -> void:
	_start_ms = Time.get_ticks_msec()
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("PlayerTank")
	if level == null:
		level = get_parent()
	assert(player != null, "TelemetryRecorder: no PlayerTank to record")
	if player == null:
		return
	# fail loud if a PlayerTank refactor dropped a contract signal
	for sig in ["shoot", "hp_changed", "died", "lives_changed"]:
		assert(player.has_signal(sig), "TelemetryRecorder: PlayerTank missing signal '%s'" % sig)
	player.shoot.connect(_on_shoot)
	player.hp_changed.connect(_on_hp_changed)
	player.died.connect(_on_died)
	_prev_hp = int(player.get("hp")) if player.get("hp") != null else 0


func _physics_process(_delta: float) -> void:
	if _ended or player == null or not is_instance_valid(player):
		return
	_tick += 1
	var obs := ObservationBuilder.build(player, level, _tick, _elapsed_sec())
	_last_obs = obs

	# exposure: under threat when an enemy is within EXPOSURE_RADIUS tiles
	var ne := obs.nearest_enemy()
	if not ne.is_empty():
		var p: Vector2i = ne["pos_tile"]
		var d: int = absi(p.x - obs.player_pos_tile.x) + absi(p.y - obs.player_pos_tile.y)
		if d <= EXPOSURE_RADIUS_TILES:
			_exposed_ticks += 1

	# action this tick (from the driver, if present)
	var act: BotAction = null
	if driver != null and is_instance_valid(driver):
		act = driver.last_action
	var act_sig := "idle"
	if act != null:
		act_sig = "%d|%d|%d" % [act.move_dir, (1 if act.fire else 0), act.shell_swap_to]
		# reload_cancel: fired while not ready
		if act.fire and obs.reload_bar_value < RELOAD_READY:
			_reload_cancel_events += 1

	_update_correlation(obs, act_sig)

	# victory: reached the goal row at the top of the room
	if obs.player_pos_tile.y <= GOAL_ROW:
		finalize("victory")
		return
	# timeout
	if _elapsed_sec() >= TIMEOUT_SEC:
		finalize("timeout")
		return


func _update_correlation(obs: BotObservation, act_sig: String) -> void:
	var action_changed := act_sig != _prev_action_sig and _prev_action_sig != "__init__"
	# resolve any pending flips with this tick's action change
	for k in _corr_pending.keys():
		if _corr_pending[k] >= 0:
			if action_changed:
				_corr[k][1] += 1
				_corr_pending[k] = -1
			elif _corr_pending[k] >= CORR_WINDOW:
				_corr_pending[k] = -1   # window expired, no action change
			else:
				_corr_pending[k] += 1
	# detect new flips
	var reload_ready := 1 if obs.reload_bar_value >= RELOAD_READY else 0
	if _prev_reload_ready != -1 and reload_ready != _prev_reload_ready:
		_corr["reload_bar"][0] += 1
		_corr_pending["reload_bar"] = 0
	_prev_reload_ready = reload_ready

	if _prev_shell != -1 and obs.current_shell_class != _prev_shell:
		_corr["shell_chip"][0] += 1
		_corr_pending["shell_chip"] = 0
	_prev_shell = obs.current_shell_class

	var ribbon := 1 if obs.active_card_count > 0 else 0
	if _prev_ribbon != -1 and ribbon != _prev_ribbon:
		_corr["ribbon_visible"][0] += 1
		_corr_pending["ribbon_visible"] = 0
	_prev_ribbon = ribbon

	_prev_action_sig = act_sig


func _on_shoot(_scene, _pos, _dir, shell_class: int) -> void:
	if shell_class >= 0 and shell_class < SHELL_NAMES.size():
		_shells_fired[SHELL_NAMES[shell_class]] += 1


func _on_hp_changed(new_hp: int, _max_hp: int) -> void:
	if _prev_hp >= 0 and new_hp < _prev_hp:
		_damage_taken += (_prev_hp - new_hp)
	_prev_hp = new_hp


func _on_died() -> void:
	finalize(_classify_death())


# projectile / melee / suicide by the nearest threat at the moment of death.
func _classify_death() -> String:
	var obs := _last_obs if _last_obs != null else ObservationBuilder.build(player, level, _tick, _elapsed_sec())
	var ppos: Vector2i = obs.player_pos_tile
	for pr in obs.visible_projectiles:
		if pr.get("owner", "") == "enemy":
			var q: Vector2i = pr["pos_tile"]
			if absi(q.x - ppos.x) + absi(q.y - ppos.y) <= 2:
				return "projectile"
	for e in obs.visible_enemies:
		var q2: Vector2i = e["pos_tile"]
		if absi(q2.x - ppos.x) + absi(q2.y - ppos.y) <= 2:
			return "melee"
	return "suicide"


func finalize(cause: String) -> void:
	if _ended:
		return
	_ended = true
	var t := build_record(cause)
	_result = t
	if out_path != "":
		_write_json(t)
	recorded.emit(t)


func build_record(cause: String) -> Dictionary:
	var fired_total := 0
	for k in SHELL_NAMES:
		fired_total += _shells_fired[k]
	var hit_rate := _read_hit_rate(fired_total)
	var total_ticks := maxi(_tick, 1)
	return {
		"survival_time_sec": _elapsed_sec(),
		"damage_taken": _damage_taken,
		"shells_fired_per_class": _shells_fired.duplicate(),
		"shell_hit_rate": hit_rate,
		"reload_cancel_events": _reload_cancel_events,
		"time_exposed_pct": clampf(float(_exposed_ticks) / float(total_ticks), 0.0, 1.0),
		"death_cause": cause,
		"ui_action_correlation": {
			"reload_bar": _corr_ratio("reload_bar"),
			"shell_chip": _corr_ratio("shell_chip"),
			"ribbon_visible": _corr_ratio("ribbon_visible"),
		},
		"seed": seed_value,
		"bot_id": bot_id,
		"schema_version": TelemetrySchema.SCHEMA_VERSION,
	}


func _corr_ratio(field: String) -> float:
	var flips: int = _corr[field][0]
	if flips <= 0:
		return 0.0
	return clampf(float(_corr[field][1]) / float(flips), 0.0, 1.0)


# shell_hit_rate from PlayerTank.run_recap's hit accounting when present (Q1
# wires Bullet -> player.run_recap.record_shot_hit). 0.0 if unavailable.
func _read_hit_rate(fired_total: int) -> float:
	if fired_total <= 0:
		return 0.0
	if player == null:
		return 0.0
	var rr = player.get("run_recap")
	if rr == null:
		return 0.0
	var hits := 0
	if rr.has_method("total_shells_on_routes"):
		hits += int(rr.total_shells_on_routes())
	if rr.has_method("total_shells_on_combat"):
		hits += int(rr.total_shells_on_combat())
	return clampf(float(hits) / float(fired_total), 0.0, 1.0)


# Game time (physics-frame count / fps), NOT wall clock — stable whether the
# batch runs real-time or as-fast-as-possible (--fixed-fps headless).
func _elapsed_sec() -> float:
	return float(_tick) / PHYSICS_FPS


func _write_json(dict: Dictionary) -> void:
	var dir := out_path.get_base_dir()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("TelemetryRecorder: cannot open '%s' for write (err %d)" % [out_path, FileAccess.get_open_error()])
		return
	f.store_string(JSON.stringify(dict, "  "))
	f.close()
