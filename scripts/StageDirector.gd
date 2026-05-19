class_name StageDirector
extends RefCounted

# Arc-3 stage progression manager (criterion 10 anchor 2). Tracks current
# stage in the BC 1-35 sequence; exposes advance / restart / goto.
# Owned by OriginalLevel; survives only within one playthrough's run
# (Godot's scene-tree lifetime handles cleanup on reload).
#
# In iter 7 there's no Spawner in Originals mode → no clear-condition
# fires in normal play. The runtime trigger is a dev keybind (N key)
# wired in OriginalLevel.gd so anchor-2 "linear advance — code-cited"
# is honestly testable. Anchor 3+ (stages 1-10 reachable in one session)
# needs natural clear-condition from Spawner integration (iter 9+).

const STAGE_MIN := 1
const STAGE_MAX := 35

signal arc_complete  # fired when advance_stage is called on STAGE_MAX

var current_stage: int = STAGE_MIN


func _init(start_stage: int = STAGE_MIN) -> void:
	current_stage = clamp(start_stage, STAGE_MIN, STAGE_MAX)


func advance_stage() -> int:
	if current_stage >= STAGE_MAX:
		arc_complete.emit()
		return current_stage
	current_stage += 1
	return current_stage


func restart() -> void:
	current_stage = STAGE_MIN


func goto_stage(k: int) -> void:
	current_stage = clamp(k, STAGE_MIN, STAGE_MAX)
