extends SceneTree

# iter 013: LevelLoader edge-case test harness (C1 anchor 5 — "Loader handles
# edge cases gracefully; covered by make test").
#
# Exercises 4 failure-mode shapes via /tmp fixtures + stages_dir_override.
# Uses a real OriginalLevel scene instance so the level.brickTileMap (etc.)
# references resolve; cells are harmlessly written when the loader takes the
# happy path. For error paths the early-return prevents any cell writes.

const LevelLoaderT = preload("res://scripts/LevelLoader.gd")
const OriginalLevelScene = preload("res://scenes/OriginalLevel.tscn")

var _failures: int = 0


func _initialize() -> void:
	# Set up a single OriginalLevel instance to provide TileMapLayer refs.
	var level: Node = OriginalLevelScene.instantiate()
	# Override stage_number to 0 so OriginalLevel.gd's _ready doesn't load
	# stage 1 automatically — we'll call parse_stage manually per test.
	level.stage_number = 0
	root.add_child(level)
	# Wait one frame so @onready vars resolve.
	await process_frame

	_run_test_happy_path(level)
	_run_test_missing_file(level)
	_run_test_short_row(level)
	_run_test_unknown_char(level)

	if _failures == 0:
		print("ALL_LOADER_TESTS_PASS")
		quit(0)
	else:
		print("LOADER_TEST_FAILURES: %d" % _failures)
		quit(1)


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("  PASS %s" % label)
	else:
		print("  FAIL %s" % label)
		_failures += 1


func _run_test_happy_path(level: Node) -> void:
	print("[test_loader] HAPPY PATH: canonical stage 1")
	var result: Dictionary = LevelLoaderT.parse_stage(level, 1)
	_assert(result.ok == true, "ok = true")
	_assert(result.brick == 220, "brick == 220 (got %d)" % result.brick)
	_assert(result.steel == 8, "steel == 8 (got %d)" % result.steel)
	_assert(result.error == "", "error string empty")


func _run_test_missing_file(level: Node) -> void:
	print("[test_loader] MISSING FILE: stages_dir = /tmp/nonexistent_dir_xyz")
	var result: Dictionary = LevelLoaderT.parse_stage(level, 1, 7, 2, "/tmp/nonexistent_dir_xyz")
	_assert(result.ok == false, "ok = false on missing file")
	_assert(result.error.find("open failed") != -1, "error contains 'open failed' (got: %s)" % result.error)


func _run_test_short_row(level: Node) -> void:
	print("[test_loader] SHORT ROW: fixture with 25-char row 0")
	var tmp_dir: String = "/tmp/tanke_loader_test_short"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	# 25 chars on row 0 (one short of the required 26)
	var bad_row: String = "..........................".substr(0, 25)
	var rows: PackedStringArray = PackedStringArray()
	rows.append(bad_row)
	for i in 25:
		rows.append("..........................")
	var f: FileAccess = FileAccess.open(tmp_dir + "/1", FileAccess.WRITE)
	f.store_string("\n".join(rows))
	f.close()
	var result: Dictionary = LevelLoaderT.parse_stage(level, 1, 7, 2, tmp_dir)
	_assert(result.ok == false, "ok = false on short row")
	_assert(result.error.find("chars") != -1 or result.error.find("need") != -1,
		"error mentions char/need count (got: %s)" % result.error)


func _run_test_unknown_char(level: Node) -> void:
	print("[test_loader] UNKNOWN CHAR: fixture with 'X' at (0, 0)")
	var tmp_dir: String = "/tmp/tanke_loader_test_unknown"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var rows: PackedStringArray = PackedStringArray()
	rows.append("X" + ".........................")  # 'X' at col 0, then 25 dots
	for i in 25:
		rows.append("..........................")
	var f: FileAccess = FileAccess.open(tmp_dir + "/2", FileAccess.WRITE)
	f.store_string("\n".join(rows))
	f.close()
	var result: Dictionary = LevelLoaderT.parse_stage(level, 2, 7, 2, tmp_dir)
	_assert(result.unknown > 0, "unknown counter incremented (got: %d)" % result.unknown)
	_assert(result.ok == false, "ok = false when unknown chars present")
