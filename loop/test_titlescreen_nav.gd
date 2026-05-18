extends SceneTree

# iter 025: TitleScreen navigation auto-verification (C6 anchor 5).
# Drives headless input synthesis per spike-1 pattern:
#   InputEventKey(pressed=true, keycode=KEY_X) + Input.parse_input_event
#   + await process_frame -> Input.is_key_pressed reflects state.
#
# Test A: KEY_ENTER from boot → ORIGINALS launches (default _selection=0).
# Test B: fresh tree; KEY_DOWN → _selection=1 → KEY_ENTER → PROCEDURAL.
# Also verifies UI affordances are structurally present at boot.

const TITLE_SCENE = preload("res://scenes/TitleScreen.tscn")

var _failures: int = 0


func _initialize() -> void:
	await _test_affordances_present()
	await _test_originals_path()
	await _test_procedural_path()

	if _failures == 0:
		print("TITLESCREEN_NAV_OK")
		quit(0)
	else:
		print("TITLESCREEN_NAV_FAILURES: %d" % _failures)
		quit(1)


func _test_affordances_present() -> void:
	print("[titlescreen-nav] AFFORDANCES")
	var title: Node = TITLE_SCENE.instantiate()
	root.add_child(title)
	for i in 3:
		await process_frame
	# Title Sprite2D has texture (BC logo)
	var t: Sprite2D = title.get_node_or_null("Title") as Sprite2D
	_assert(t != null and t.texture != null, "Title Sprite2D has texture")
	# Cursor AnimatedSprite2D has sprite_frames
	var cur: AnimatedSprite2D = title.get_node_or_null("Cursor") as AnimatedSprite2D
	_assert(cur != null and cur.sprite_frames != null, "Cursor AnimatedSprite2D has sprite_frames")
	# Options/Originals + Options/Procedural Labels
	var o: Label = title.get_node_or_null("Options/Originals") as Label
	var p: Label = title.get_node_or_null("Options/Procedural") as Label
	_assert(o != null and o.text == "ORIGINALS", "Options/Originals label present")
	_assert(p != null and p.text == "PROCEDURAL", "Options/Procedural label present")
	# Hint label
	var h: Label = title.get_node_or_null("Hint") as Label
	_assert(h != null and h.text.length() > 0, "Hint label present")
	title.queue_free()
	await process_frame


func _test_originals_path() -> void:
	print("[titlescreen-nav] PATH A: ENTER → ORIGINALS")
	var title: Node = TITLE_SCENE.instantiate()
	root.add_child(title)
	for i in 3:
		await process_frame
	_send_key(KEY_ENTER, true)
	# Wait several frames for change_scene_to_file to complete
	for i in 8:
		await process_frame
	_send_key(KEY_ENTER, false)  # release
	# After scene change, current_scene reflects the new scene's root node
	var cs: Node = current_scene
	var name_str: String = cs.name if cs != null else "<null>"
	_assert(name_str == "OriginalLevel", "current_scene == OriginalLevel (got: %s)" % name_str)
	# Cleanup: free current scene before next test
	if cs != null:
		cs.queue_free()
		await process_frame


func _test_procedural_path() -> void:
	print("[titlescreen-nav] PATH B: DOWN + ENTER → PROCEDURAL")
	var title: Node = TITLE_SCENE.instantiate()
	root.add_child(title)
	for i in 3:
		await process_frame
	# Press DOWN, wait a frame so _process polls it
	_send_key(KEY_DOWN, true)
	await process_frame
	await process_frame
	_send_key(KEY_DOWN, false)  # release before assert
	await process_frame
	var selection: int = int(title.get("_selection"))
	_assert(selection == 1, "_selection == 1 after KEY_DOWN (got: %d)" % selection)
	# ENTER
	_send_key(KEY_ENTER, true)
	for i in 8:
		await process_frame
	_send_key(KEY_ENTER, false)
	var cs: Node = current_scene
	var name_str: String = cs.name if cs != null else "<null>"
	_assert(name_str == "ProceduralLevel", "current_scene == ProceduralLevel (got: %s)" % name_str)
	if cs != null:
		cs.queue_free()
		await process_frame


func _send_key(keycode: int, pressed: bool) -> void:
	var ev := InputEventKey.new()
	ev.pressed = pressed
	ev.keycode = keycode
	Input.parse_input_event(ev)


func _assert(cond: bool, label: String) -> void:
	if cond:
		print("  ok %s" % label)
	else:
		print("  FAIL %s" % label)
		_failures += 1
