# One-off driver: load Q1ProofRoom, dismiss codex, let physics run a
# couple frames so HUD updates, then quit. Used with --write-movie to
# capture the post-codex view of the actual playable layout.

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")


func _initialize() -> void:
	var room: Node = Q1ProofRoomScene.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame
	if room.player != null:
		room.player._dismiss_codex()
		# Trigger HUD update path so shell chips render with reserves.
		room.player._update_run_hud()
	# Let a couple more frames render with the codex hidden.
	for i in 4:
		await process_frame
	# (Don't quit — let --quit-after handle it so frames are captured.)
