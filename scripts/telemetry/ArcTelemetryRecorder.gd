class_name ArcTelemetryRecorder
extends TelemetryRecorder

# Arc telemetry producer (arc-harness-v0.2 AC-A2) for the REAL procedural climb
# (BreachLevel). A SUBCLASS of TelemetryRecorder so it reuses ~90% of the v0.1
# machinery (signal wiring, shell/damage tallies, exposure, ui_action_correlation,
# finalize/_write_json) and overrides ONLY what the arc changes — the base file is
# NOT modified, so the frozen Q1 recorder + its verifiers stay bit-identical.
#
# What's arc-specific:
#   * VICTORY = reached the endgame band (not Q1's y<=0 row), driven by the
#     level's breach_band_changed signal — not a per-tick position check.
#   * scaled timeout (the climb is minutes, not the Q1 30s room).
#   * per-band SEGMENTS: each band the player crosses gets {entered/duration,
#     shells_fired delta, damage_taken delta} — the playtest signal per pressure.
#   * DEPOT PICKS: every safe-gate upgrade chosen (from each depot's depot_picked).
#   * max_depth: the deepest rows_climbed reached.
# Output validates against ArcTelemetrySchema (v0.2-arc), a strict v0.1 superset.

const ENDGAME_BAND := "endgame_mixed"   # reaching this band = arc victory
const ARC_TIMEOUT_SEC := 240.0          # game-time cap for the whole climb (frame-based)

# --- arc accumulators ---
var _arc_max_depth: int = 0
var _bands_reached: Array[String] = []
var _band_segments: Array = []          # closed segments (one per band crossed)
var _depot_picks: Array = []
var _reached_endgame: bool = false
# open-segment cursor
var _cur_band: String = ""
var _seg_start_sec: float = 0.0
var _seg_start_shells: Dictionary = {}
var _seg_start_damage: int = 0


func _ready() -> void:
	super._ready()   # asserts player, wires shoot/hp_changed/died (reused as-is)
	# breach_band_changed only fires on a CHANGE, so seed the starting band/segment
	# from the level's current band (set in ProceduralLevel._init_breach_mode).
	if level != null and is_instance_valid(level) and ("_current_breach_band" in level):
		var b = level._current_breach_band
		if b != null and ("band_name" in b):
			_cur_band = String(b.band_name)
			_bands_reached.append(_cur_band)
	_seg_start_sec = _elapsed_sec()
	_seg_start_shells = _shells_fired.duplicate()
	_seg_start_damage = _damage_taken
	# per-band segmentation + arc victory
	if level != null and is_instance_valid(level) and level.has_signal("breach_band_changed"):
		level.breach_band_changed.connect(_on_band_changed)
	# depot picks — connect every safe-gate's depot_picked(depot, kind)
	if level != null and is_instance_valid(level):
		for c in level.get_children():
			if is_instance_valid(c) and c.has_signal("depot_picked"):
				c.depot_picked.connect(_on_depot_pick)


# Arc sampling tick — mirrors the base sampler (reusing inherited accumulators +
# _update_correlation) but tracks max_depth and ends on the ARC timeout; victory
# is signal-driven (see _on_band_changed), never a per-tick position test.
func _physics_process(_delta: float) -> void:
	if _ended or player == null or not is_instance_valid(player):
		return
	_tick += 1
	var obs := ObservationBuilder.build(player, level, _tick, _elapsed_sec())
	_last_obs = obs
	_arc_max_depth = maxi(_arc_max_depth, obs.rows_climbed)

	var ne := obs.nearest_enemy()
	if not ne.is_empty():
		var p: Vector2i = ne["pos_tile"]
		if absi(p.x - obs.player_pos_tile.x) + absi(p.y - obs.player_pos_tile.y) <= EXPOSURE_RADIUS_TILES:
			_exposed_ticks += 1

	var act: BotAction = null
	if driver != null and is_instance_valid(driver):
		act = driver.last_action
	var act_sig := "idle"
	if act != null:
		act_sig = "%d|%d|%d" % [act.move_dir, (1 if act.fire else 0), act.shell_swap_to]
		if act.fire and obs.reload_bar_value < RELOAD_READY:
			_reload_cancel_events += 1
	_update_correlation(obs, act_sig)

	if _elapsed_sec() >= ARC_TIMEOUT_SEC:
		finalize("timeout")


# Band boundary crossed: close the prior segment, open the new one, and — if it's
# the endgame band — declare victory (finalize is idempotent via the _ended latch).
func _on_band_changed(band) -> void:
	if _ended or band == null or not ("band_name" in band):
		return
	var nm := String(band.band_name)
	_close_current_segment()
	_cur_band = nm
	_seg_start_sec = _elapsed_sec()
	_seg_start_shells = _shells_fired.duplicate()
	_seg_start_damage = _damage_taken
	if not (nm in _bands_reached):
		_bands_reached.append(nm)
	if nm == ENDGAME_BAND:
		_reached_endgame = true
		finalize("victory")


func _on_depot_pick(depot, kind) -> void:
	if depot == null:
		return
	var dn = depot.get("depot_name")
	var bn = depot.get("band_name_next")
	_depot_picks.append({
		"depot": str(dn) if dn != null and str(dn) != "" else String(depot.name),
		"kind": int(kind),
		"band_next": str(bn) if bn != null else "",
	})


# Close the open band segment (deltas since it opened). No-op if no band is open.
func _close_current_segment() -> void:
	if _cur_band == "":
		return
	_band_segments.append({
		"band": _cur_band,
		"entered_sec": _seg_start_sec,
		"duration_sec": maxf(0.0, _elapsed_sec() - _seg_start_sec),
		"shells_fired": _shell_delta(_seg_start_shells),
		"damage_taken": maxi(0, _damage_taken - _seg_start_damage),
	})


func _shell_delta(start: Dictionary) -> Dictionary:
	var out := {}
	for k in SHELL_NAMES:
		out[k] = int(_shells_fired.get(k, 0)) - int(start.get(k, 0))
	return out


# Extend the v0.1 record with the arc fields. Called once from the inherited
# finalize(); closes the final open segment first.
func build_record(cause: String) -> Dictionary:
	_close_current_segment()
	var rec := super.build_record(cause)
	rec["schema_version"] = ArcTelemetrySchema.SCHEMA_VERSION
	rec["max_depth"] = _arc_max_depth
	rec["final_band"] = _cur_band
	rec["reached_endgame"] = _reached_endgame
	rec["bands_reached"] = _bands_reached.duplicate()
	rec["band_segments"] = _band_segments.duplicate(true)
	rec["depot_picks"] = _depot_picks.duplicate(true)
	return rec
