extends SceneTree

# U3 verifier (arc-harness-v0.2 AC-A2) — ArcTelemetryRecorder produces a
# SCHEMA-CONFORMING v0.2-arc record from breach signals, end to end, on a stub
# scene (true unit test — no BreachLevel load). It must: seed the starting band,
# segment each band crossing, record depot picks, track max_depth, declare
# victory on the endgame band, and emit a record ArcTelemetrySchema accepts.
# Teeth: the validate()==[] assertion fails on a non-conforming record; the
# ordered-bands / segment-count / depot-pick assertions fail on mis-accounting.
#
# Emits `ARC_RECORDER_OK` on full pass; quit(1) otherwise.

const OUT := "user://test_arc_recorder_smoke.json"
const EXPECTED_BANDS := ["tutorial_choke", "brick_maze", "bunker_zone", "open_killbox", "endgame_mixed"]


class StubBand extends RefCounted:
	var band_name: String = ""
	func _init(n: String) -> void:
		band_name = n


class StubDepot extends Node:
	signal depot_picked(depot, kind)
	var depot_name: String = "depot_2"
	var band_name_next: String = "bunker_zone"


class StubPlayer extends Node2D:
	signal shoot(scene, pos, dir, shell_class)
	signal hp_changed(new_hp, max_hp)
	signal died
	signal lives_changed(remaining, maxv)
	var hp: int = 50
	var max_hp: int = 50
	var current_shell: int = 0
	var loadout = null
	var speed: int = 32
	var _start_y: float = 1600.0


class StubLevel extends Node2D:
	signal breach_band_changed(band)
	var _current_breach_band = null


func _initialize() -> void:
	var failures: int = 0

	var level := StubLevel.new()
	level._current_breach_band = StubBand.new("tutorial_choke")
	var depot := StubDepot.new()
	level.add_child(depot)               # depot present BEFORE recorder wires signals
	get_root().add_child(level)

	var player := StubPlayer.new()
	player.global_position = Vector2(80, 1600)
	level.add_child(player)

	var rec := ArcTelemetryRecorder.new()
	rec.player = player
	rec.level = level
	rec.seed_value = 1234
	rec.bot_id = "competent"
	rec.out_path = OUT
	level.add_child(rec)                 # rec._ready wires band + depot signals now

	await process_frame
	await process_frame

	# climb through the bands, accumulating shots/damage/depth between crossings
	player.emit_signal("shoot", null, Vector2.ZERO, 0, 0)   # AP in choke
	player.global_position = Vector2(80, 1280)              # rows_climbed ~20
	await process_frame
	level.emit_signal("breach_band_changed", StubBand.new("brick_maze"))

	player.emit_signal("shoot", null, Vector2.ZERO, 0, 1)   # HE in maze
	player.hp = 43
	player.emit_signal("hp_changed", 43, 50)               # 7 damage in maze
	player.global_position = Vector2(80, 640)              # rows_climbed ~60
	await process_frame
	depot.emit_signal("depot_picked", depot, 4)            # FULL_RESUPPLY pick
	level.emit_signal("breach_band_changed", StubBand.new("bunker_zone"))

	player.emit_signal("shoot", null, Vector2.ZERO, 0, 2)   # HEAT in bunker
	await process_frame
	level.emit_signal("breach_band_changed", StubBand.new("open_killbox"))
	await process_frame
	level.emit_signal("breach_band_changed", StubBand.new("endgame_mixed"))  # -> victory
	await process_frame
	await process_frame

	var t: Dictionary = rec._result
	if t.is_empty():
		print("  FAIL — recorder produced no _result")
		print("ARC_RECORDER_FAIL 1 failures"); quit(1); return

	var errs: Array = ArcTelemetrySchema.validate(t)
	if not errs.is_empty():
		print("  FAIL — record does NOT conform: %s" % str(errs)); failures += 1
	else:
		print("  case schema-conforms OK")

	failures += _expect("death_cause == victory", t.get("death_cause", "") == "victory")
	failures += _expect("reached_endgame == true", t.get("reached_endgame", false) == true)
	failures += _expect("bands_reached ordered choke..endgame", t.get("bands_reached", []) == EXPECTED_BANDS)
	failures += _expect("5 band_segments closed", (t.get("band_segments", []) as Array).size() == 5)
	failures += _expect("max_depth > 0", int(t.get("max_depth", 0)) > 0)
	failures += _expect("final_band == endgame_mixed", t.get("final_band", "") == "endgame_mixed")

	var picks: Array = t.get("depot_picks", [])
	failures += _expect("1 depot pick recorded", picks.size() == 1)
	if picks.size() == 1:
		var p: Dictionary = picks[0]
		failures += _expect("depot pick depot==depot_2", p.get("depot", "") == "depot_2")
		failures += _expect("depot pick kind==4", int(p.get("kind", -1)) == 4)
		failures += _expect("depot pick band_next==bunker_zone", p.get("band_next", "") == "bunker_zone")

	# the maze segment should hold the HE shot + 7 damage (segment-delta accounting)
	var segs: Array = t.get("band_segments", [])
	if segs.size() == 5:
		var maze: Dictionary = segs[1]
		failures += _expect("maze segment band==brick_maze", maze.get("band", "") == "brick_maze")
		failures += _expect("maze segment HE==1", int((maze.get("shells_fired", {}) as Dictionary).get("HE", 0)) == 1)
		failures += _expect("maze segment damage==7", int(maze.get("damage_taken", 0)) == 7)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(OUT))

	if failures == 0:
		print("ARC_RECORDER_OK")
		quit(0)
	else:
		print("ARC_RECORDER_FAIL %d failures" % failures)
		quit(1)


func _expect(desc: String, cond: bool) -> int:
	if cond:
		print("  case %s OK" % desc)
		return 0
	print("  FAIL — %s" % desc)
	return 1
