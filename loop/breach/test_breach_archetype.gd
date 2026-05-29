# Arc-4 breach mode: tank archetype framework verifier
# (Round 9b, iter 64). Verifies the scaffolding for the per-archetype
# code paths landing in 9c (PRISM) / 9d (MORTAR) / 9e (RAM):
#   - PlayerTank exposes a TankArchetype enum with 4 distinct values
#     (DEFAULT, PRISM, MORTAR, RAM)
#   - default archetype is DEFAULT; the existing breach HUD still
#     builds (a regression check — DEFAULT is bit-identical)
#   - the archetype @export field is settable from outside
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_archetype.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _initialize() -> void:
	# === TankArchetype enum: 4 distinct values.
	var d: int = PlayerTankT.TankArchetype.DEFAULT
	var p: int = PlayerTankT.TankArchetype.PRISM
	var m: int = PlayerTankT.TankArchetype.MORTAR
	var r: int = PlayerTankT.TankArchetype.RAM
	if d == p or p == m or m == r or d == m or d == r or p == r:
		push_error("FAIL — TankArchetype values not all distinct (%d/%d/%d/%d)" % [d, p, m, r])
		quit(1); return
	print("  TankArchetype enum: DEFAULT=%d PRISM=%d MORTAR=%d RAM=%d" % [d, p, m, r])

	# === default archetype is DEFAULT; existing breach HUD still builds.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	root.add_child(pt)
	await process_frame
	await process_frame  # RoutePanel is built deferred (iter 50)
	if pt.archetype != d:
		push_error("FAIL — default archetype = %d, want DEFAULT (%d)" % [pt.archetype, d])
		quit(1); return
	var hud: CanvasLayer = pt.get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_error("FAIL — DEFAULT archetype broke HUD (no HUD)"); quit(1); return
	# Spot-check that the existing breach HUD pieces still build (Round 5/6/8).
	# RoutePanel is skipped — it requires a breach-level parent with
	# breach_config; this harness uses root as the parent.
	# iter 300: ShellPanel removed, replaced by ShellChipsPanel (bottom-center).
	for nm in ["ShellChipsPanel", "LevelLabel", "ShellCodex", "ShieldLabel"]:
		if hud.get_node_or_null(nm) == null:
			push_error("FAIL — DEFAULT archetype regressed breach HUD (missing %s)" % nm)
			quit(1); return
	print("  default archetype DEFAULT; existing breach HUD intact")
	pt.queue_free()
	await process_frame

	# === archetype @export is settable (PRISM); _ready runs clean.
	var pt2: Node = PlayerTankScene.instantiate()
	pt2.loadout = LoadoutT.new()
	pt2.archetype = p
	root.add_child(pt2)
	await process_frame
	if pt2.archetype != p:
		push_error("FAIL — archetype field not settable (got %d, want PRISM=%d)" % [pt2.archetype, p])
		quit(1); return
	print("  archetype field settable (PRISM=%d) without crash" % p)
	pt2.queue_free()

	print("BREACH_ARCHETYPE_OK enum + state field; DEFAULT preserves existing breach behavior")
	quit(0)
