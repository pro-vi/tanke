# One-off driver: load Q1ProofRoom, dismiss codex, let physics run a
# couple frames so HUD updates, then quit. Used with --write-movie to
# capture the post-codex view of the actual playable layout.
#
# OS env var Q1_PICK_CARD=1 triggers a card pick during the capture so
# the iter-302 toast + ribbon chip render together (used by
# `make screenshot-q1-post-pick` to baseline that visual state).

extends SceneTree

const Q1ProofRoomScene = preload("res://scenes/Q1ProofRoom.tscn")
const UpgradeCatalogT = preload("res://scripts/UpgradeCatalog.gd")


func _initialize() -> void:
	var room: Node = Q1ProofRoomScene.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame
	if room.player != null:
		room.player._dismiss_codex()
		# Trigger HUD update path so shell chips render with reserves.
		room.player._update_run_hud()
	# Let a few frames render with the codex hidden so the post-codex
	# baseline shows the playable layout.
	for i in 4:
		await process_frame
	# iter 304: apply a card LATE so the captured final frame shows the
	# iter-302 toast at near-full opacity. The toast tween fades over
	# 1.5s; at --fixed-fps 1, each captured frame is 1s of game time.
	# Apply the pick right before the last few captured frames so the
	# toast is visible in at least one PNG.
	if room.player != null and OS.get_environment("Q1_PICK_CARD") == "1":
		room.player._apply_card(UpgradeCatalogT.CardKind.HP_PLUS_1)
		room.player._update_run_hud()
		# Await just 1 frame so the toast is captured mid-spawn.
		await process_frame
	# (Don't quit — let --quit-after handle it so frames are captured.)
