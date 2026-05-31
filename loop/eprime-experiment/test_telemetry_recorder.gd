extends SceneTree

# U4b verifier — TelemetryRecorder produces a SCHEMA-CONFORMING record end to
# end: it subscribes to PlayerTank signals (shoot/hp_changed/died), accumulates,
# then on death writes a JSON that TelemetrySchema.validate() accepts AND whose
# fields match the emitted events. Stub player (inner class) so this is a true
# unit test — no Q1ProofRoom load. Teeth: the validate()==[] assertion fails if
# the recorder emits a non-conforming record; the count assertions fail if it
# mis-tallies shells/damage.
#
# Emits `RECORDER_OK` on full pass; quit(1) otherwise.

const OUT := "user://test_telemetry_smoke.json"


class StubPlayer extends Node2D:
	signal shoot(scene, pos, dir, shell_class)
	signal hp_changed(new_hp, max_hp)
	signal died
	signal lives_changed(remaining, maxv)
	var hp: int = 3
	var max_hp: int = 3
	var current_shell: int = 0
	var loadout = null
	var speed: int = 32


func _initialize() -> void:
	var failures: int = 0

	var player := StubPlayer.new()
	# realistic start (Q1 PLAYER_START_ROW=29 @ 8px) so the victory check
	# (tile.y <= GOAL_ROW=0) does not fire instantly at world origin
	player.global_position = Vector2(80, 232)
	get_root().add_child(player)

	var rec := TelemetryRecorder.new()
	rec.player = player
	rec.level = get_root()
	rec.seed_value = 7
	rec.bot_id = "stub-bot"
	rec.out_path = OUT
	get_root().add_child(rec)

	await process_frame
	await process_frame

	# emit a few shots: 2x AP(0), 1x HE(1)
	player.emit_signal("shoot", null, Vector2.ZERO, 0, 0)
	player.emit_signal("shoot", null, Vector2.ZERO, 0, 0)
	player.emit_signal("shoot", null, Vector2.ZERO, 0, 1)
	# take damage 3 -> 1
	player.hp = 1
	player.emit_signal("hp_changed", 1, 3)
	await process_frame
	await process_frame

	# die
	player.emit_signal("died")
	await process_frame
	await process_frame

	# --- read back the emitted JSON ---
	if not FileAccess.file_exists(OUT):
		print("  FAIL — no telemetry JSON written at %s" % OUT)
		print("RECORDER_FAIL 1 failures"); quit(1); return
	var f := FileAccess.open(OUT, FileAccess.READ)
	var t = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(t) != TYPE_DICTIONARY:
		print("  FAIL — telemetry JSON did not parse to an object")
		print("RECORDER_FAIL 1 failures"); quit(1); return

	# schema conformance (the core assertion)
	var errs: Array = TelemetrySchema.validate(t)
	if not errs.is_empty():
		print("  FAIL — emitted telemetry does NOT conform: %s" % str(errs)); failures += 1
	else:
		print("  case schema-conforms OK")

	# field tallies match emitted events
	var sf = t.get("shells_fired_per_class", {})
	if int(sf.get("AP", -1)) != 2 or int(sf.get("HE", -1)) != 1 or int(sf.get("HEAT", -1)) != 0 or int(sf.get("APCR", -1)) != 0:
		print("  FAIL — shells_fired_per_class wrong: %s (expected AP=2,HE=1,HEAT=0,APCR=0)" % str(sf)); failures += 1
	else:
		print("  case shells-tally OK")
	if int(t.get("damage_taken", -1)) != 2:
		print("  FAIL — damage_taken=%s (expected 2)" % str(t.get("damage_taken"))); failures += 1
	else:
		print("  case damage-tally OK")
	if int(t.get("seed", -1)) != 7 or str(t.get("bot_id", "")) != "stub-bot":
		print("  FAIL — seed/bot_id wrong: seed=%s bot_id=%s" % [str(t.get("seed")), str(t.get("bot_id"))]); failures += 1
	else:
		print("  case identity OK")

	# cleanup
	DirAccess.remove_absolute(ProjectSettings.globalize_path(OUT))

	if failures == 0:
		print("RECORDER_OK")
		quit(0)
	else:
		print("RECORDER_FAIL %d failures" % failures)
		quit(1)
