extends Node2D

# Arc-3 title / mode-picker scene (criterion 6). Minimal: two text options,
# arrow keys to highlight, Enter/Space to launch.
#
# Per iter-006 pre-mortem F5 mitigation, we use raw keycode checks instead
# of InputMap actions so this works even on a project-config drift.
#
# F1 mitigation: _launching latch prevents double-fire from rapid Enter
# presses (Godot's change_scene_to_file is async).

const ORIGINALS_SCENE := "res://scenes/OriginalLevel.tscn"
const PROCEDURAL_SCENE := "res://scenes/ProceduralLevel.tscn"

# 0 = Originals (highlighted by default), 1 = Procedural
var _selection: int = 0
var _launching: bool = false

# iter 20: cursor is now AnimatedSprite2D (tank tread-cycle animation),
# was a Label "> " in iter 6. Type widened to Node2D to satisfy duck-typed
# global_position assignment in _update_cursor.
@onready var _cursor: Node2D = $Cursor
@onready var _option_originals: Label = $Options/Originals
@onready var _option_procedural: Label = $Options/Procedural


func _ready() -> void:
	_update_cursor()


func _process(_delta: float) -> void:
	if _launching:
		return
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		if _selection != 0:
			_selection = 0
			_update_cursor()
	elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		if _selection != 1:
			_selection = 1
			_update_cursor()
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		_launch()


func _update_cursor() -> void:
	# iter 20: cursor is AnimatedSprite2D (16×16, top-left anchored via
	# centered=false). Position 18 px left of option label + 2 px vertical
	# nudge for visual balance against label baseline.
	var target_label: Label = _option_originals if _selection == 0 else _option_procedural
	_cursor.global_position = target_label.global_position + Vector2(-18, 2)


func _launch() -> void:
	_launching = true
	var target := ORIGINALS_SCENE if _selection == 0 else PROCEDURAL_SCENE
	get_tree().change_scene_to_file(target)
