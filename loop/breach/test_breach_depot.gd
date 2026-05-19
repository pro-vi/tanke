# Arc-4 breach mode: Depot pause-on-entry verifier (C2 anchor 1).
# Verifies scenes/Depot.tscn instantiates cleanly + the body_entered
# handler pauses the scene tree + body_exited resumes it.
#
# Uses arc-3's _initialize() + await process_frame pattern (cf.
# loop/test_chain_25.gd) so Depot._ready() fires before we drive the
# pause contract.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_depot.gd

extends SceneTree

const DepotScene = preload("res://scenes/Depot.tscn")


func _initialize() -> void:
	var stub_player := Node.new()
	stub_player.add_to_group("player")

	var non_player := Node.new()

	var depot: Area2D = DepotScene.instantiate()
	root.add_child(depot)
	root.add_child(stub_player)
	root.add_child(non_player)

	# Let _ready() fire (sets process_mode + wires signals).
	await process_frame

	# Pre-condition: not paused.
	if paused:
		push_error("FAIL — scene tree was already paused at start")
		quit(1); return

	# Non-player entry should NOT pause.
	depot._on_body_entered(non_player)
	if paused:
		push_error("FAIL — non-player entry paused the tree")
		quit(1); return

	# Player entry SHOULD pause.
	depot._on_body_entered(stub_player)
	if not paused:
		push_error("FAIL — player entry did not pause the tree")
		quit(1); return

	# Non-player exit should NOT resume.
	depot._on_body_exited(non_player)
	if not paused:
		push_error("FAIL — non-player exit resumed the tree")
		quit(1); return

	# Player exit SHOULD resume.
	depot._on_body_exited(stub_player)
	if paused:
		push_error("FAIL — player exit did not resume the tree")
		quit(1); return

	# process_mode contract: depot must run while tree paused so body_exited
	# can fire.
	if depot.process_mode != Node.PROCESS_MODE_ALWAYS:
		push_error("FAIL — depot.process_mode != PROCESS_MODE_ALWAYS (got %d)" % depot.process_mode)
		quit(1); return

	print("BREACH_DEPOT_OK pause-on-entry contract verified")
	quit(0)
