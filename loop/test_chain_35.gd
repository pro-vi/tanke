extends SceneTree

# iter 024: 35-stage chain + ARC COMPLETE overlay assertion (C10 anchor 5).
# Extends iter-22's test_chain_25.gd pattern from 25 to 35 stages, then
# triggers stage_director.advance_stage() on a stage-35 level instance to
# verify the arc_complete signal fires and the ARC COMPLETE overlay
# materializes via _on_arc_complete -> _show_game_over_arc_complete.
#
# Spike-2 confirmed: advance_stage on STAGE_MAX returns early without
# reload_current_scene(), so the test level survives the signal fire.

const OG_SCENE = preload("res://scenes/OriginalLevel.tscn")
const StageDirectorT = preload("res://scripts/StageDirector.gd")
const RosterT = preload("res://scripts/Roster.gd")

var _failures: int = 0


func _initialize() -> void:
	# Phase 1 — verify all 35 stages instantiate cleanly.
	var director = StageDirectorT.new(1)
	for target_stage in range(1, 36):
		var ok: bool = await _verify_stage(target_stage)
		if not ok:
			_failures += 1
		if target_stage < 35:
			director.advance_stage()
	if _failures > 0:
		print("CHAIN_35_FAILURES: %d (phase 1)" % _failures)
		quit(1)
		return
	print("CHAIN_35_OK 35 stages instantiated cleanly")

	# Phase 2 — verify ARC COMPLETE overlay on stage-35 advance.
	var ok2: bool = await _verify_arc_complete_overlay()
	if not ok2:
		print("ARC_COMPLETE_OVERLAY_FAIL")
		quit(1)
		return
	print("ARC_COMPLETE_OVERLAY_OK")
	quit(0)


func _verify_stage(stage_n: int) -> bool:
	var level: Node = OG_SCENE.instantiate()
	level.stage_number = stage_n
	root.add_child(level)
	for i in 3:
		await process_frame
	var failures: Array = []
	if level.get("eagle") == null:
		failures.append("eagle null")
	elif not is_instance_valid(level.eagle):
		failures.append("eagle invalid")
	var spawner = level.get_node_or_null("Spawner")
	if spawner == null:
		failures.append("Spawner missing")
	elif int(spawner.get("stage_number")) != stage_n:
		failures.append("Spawner.stage_number=%d (expected %d)" % [int(spawner.get("stage_number")), stage_n])
	var p: float = RosterT.armored_probability(stage_n)
	if p < 0.0 or p > 1.0:
		failures.append("Roster p_armored=%.4f out of [0, 1]" % p)
	if failures.is_empty():
		print("  ok stage %2d  eagle=valid  spawner=%d  p_armored=%.4f" % [stage_n, int(spawner.get("stage_number")), p])
		level.queue_free()
		await process_frame
		return true
	else:
		print("  FAIL stage %d: %s" % [stage_n, ", ".join(failures)])
		level.queue_free()
		await process_frame
		return false


func _verify_arc_complete_overlay() -> bool:
	# Build a stage-35 level; trigger _advance_to_next_stage(); search the
	# scene tree for a Label with text "ARC COMPLETE" under any CanvasLayer.
	var level: Node = OG_SCENE.instantiate()
	level.stage_number = 35
	root.add_child(level)
	for i in 3:
		await process_frame
	# Call the advance path. On stage 35, StageDirector.advance_stage
	# returns early (current_stage already == STAGE_MAX) and emits
	# arc_complete synchronously. The early-return branch in
	# _advance_to_next_stage skips reload_current_scene, so this level
	# survives.
	level._advance_to_next_stage()
	for i in 3:
		await process_frame
	# Recursive walk for the Label.
	var found_label: Label = _find_arc_complete_label(level)
	if found_label == null:
		print("  overlay-fail: no Label with text 'ARC COMPLETE' under any CanvasLayer")
		level.queue_free()
		await process_frame
		return false
	# Verify it's under a CanvasLayer
	var parent: Node = found_label.get_parent()
	while parent != null and not (parent is CanvasLayer):
		parent = parent.get_parent()
	if parent == null:
		print("  overlay-partial: Label found but not under CanvasLayer")
		level.queue_free()
		await process_frame
		return false
	print("  overlay-ok: Label text='ARC COMPLETE' under CanvasLayer (layer=%d)" % (parent as CanvasLayer).layer)
	level.queue_free()
	await process_frame
	return true


func _find_arc_complete_label(root_node: Node) -> Label:
	if root_node is Label and (root_node as Label).text.find("ARC COMPLETE") != -1:
		return root_node
	for child in root_node.get_children():
		var hit: Label = _find_arc_complete_label(child)
		if hit != null:
			return hit
	return null
