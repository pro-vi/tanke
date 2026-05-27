extends Node2D

# Arc-4 Q1 sprint iter 288 (Q1 sprint 5/7 per revised blueprint
# iter-283-round24-Q1-architect.md): playable Q1 proof room scene.
# Driver script attached to scenes/Q1ProofRoom.tscn. On _ready, parses
# Q1ProofRoom.TILE_GRID and spawns:
#   B → BrickBlock instance
#   S → SteelBlock instance
#   H → Enemy instance with enemy_type "Heavy" + armored group
#   L → Enemy instance with enemy_type "Light"
#   G → grass cell (skipped for V1; future iter can render decor)
#   X → goal marker (skipped for V1; iter 289 adds Area2D + signal)
#   P → player start marker (HE lane's P picked for V1 auto-pick;
#       iter 289 adds 4-way lane picker UI)
#
# Gate-row (Q1ProofRoom.GATE_ROW = 14) cells get is_route_gate=true meta
# so iter-286's Bullet→PlayerTank→RunRecap wiring fires correctly during
# play (HE shot on gate brick → shells_spent_on_routes[HE]++).
#
# Standalone scene — does NOT extend ProceduralLevel; no Layer 1/2/3
# substrate touch. Hash anchor preserved on the procedural baseline.

const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")
const BrickBlockScene = preload("res://scenes/BrickBlock.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")

# Brick/steel/enemy sprites are 8×8; tank is 16×16. Use 8 as the grid
# resolution; PlayerTank ends up centered on a 2×2 cell block at start.
const CELL_PX: int = 8

# V1 auto-pick: spawn the player in HE lane (cheapest to break;
# lets the user feel the breach-economy verb on first run). iter 289
# replaces this with a pick UI showing all 4 lanes.
const V1_PLAYER_LANE: String = "HE"

# Public references for the harness.
var spawned_terrain: Array[Node] = []
var spawned_enemies: Array[Node] = []
var spawned_player: Node = null

# arc-4 iter 289: `player` alias matches Level.gd's @onready var player
# so Bullet's iter-24 `"player" in lvl` reach works in this scene
# (Bullet's _try_record_shot_hit needs lvl.player to forward shot-hit
# events to RunRecap). Without this alias, the route-currency wiring
# silently no-ops on bullets fired in the proof room.
var player: Node = null


func _ready() -> void:
	_spawn_grid()
	_spawn_player()


func _spawn_grid() -> void:
	for row in Q1ProofRoomT.GRID_ROWS:
		for col in Q1ProofRoomT.GRID_COLS:
			var t: String = Q1ProofRoomT.terrain_at(col, row)
			match t:
				"B":
					_spawn_terrain_block(BrickBlockScene, col, row)
				"S":
					_spawn_terrain_block(SteelBlockScene, col, row)
				"L":
					_spawn_enemy_at(col, row, "Light")
				"H":
					_spawn_enemy_at(col, row, "Heavy")
				# G, P, X, ".", "X" handled separately or skipped V1
				_:
					pass


func _spawn_terrain_block(scene: PackedScene, col: int, row: int) -> void:
	var blk: Node2D = scene.instantiate()
	# Stable per-cell name so harness can disambiguate
	# brick vs. steel without relying on Godot's @StaticBody2D@N auto-rename.
	var base: String = "BrickBlock" if scene == BrickBlockScene else "SteelBlock"
	blk.name = "%s_%d_%d" % [base, col, row]
	blk.position = Q1ProofRoomT.grid_to_pixel(col, row, CELL_PX)
	if row == Q1ProofRoomT.GATE_ROW:
		blk.set_meta("is_route_gate", true)
	add_child(blk)
	spawned_terrain.append(blk)


func _spawn_enemy_at(col: int, row: int, enemy_type: String) -> void:
	var enemy: Node2D = EnemyScene.instantiate()
	enemy.name = "Enemy_%s_%d_%d" % [enemy_type, col, row]
	enemy.position = Q1ProofRoomT.grid_to_pixel(col, row, CELL_PX)
	# Type-specific config (mirrors Spawner.gd ENEMY_TYPES table).
	enemy.enemy_type = enemy_type
	if enemy_type == "Heavy":
		enemy.max_hp = 3
		enemy.hp = 3
		enemy.add_to_group("armored")
	else:
		enemy.max_hp = 1
		enemy.hp = 1
	if row == Q1ProofRoomT.GATE_ROW:
		enemy.set_meta("is_route_gate", true)
	add_child(enemy)
	spawned_enemies.append(enemy)


func _spawn_player() -> void:
	var col: int = Q1ProofRoomT.player_start_col(V1_PLAYER_LANE)
	if col < 0:
		push_warning("Q1ProofRoomScene: V1_PLAYER_LANE '%s' has no player start" % V1_PLAYER_LANE)
		return
	spawned_player = PlayerTankScene.instantiate()
	spawned_player.position = Q1ProofRoomT.grid_to_pixel(
			col, Q1ProofRoomT.PLAYER_START_ROW, CELL_PX)
	# Breach-mode marker: assign a Loadout so PlayerTank builds the
	# loadout-gated HUD + RunRecap. Without this the route-currency
	# wiring (iter 286) silently no-ops.
	spawned_player.loadout = LoadoutT.new()
	# arc-4 iter 315 (Round 26 Phase B activation): demonstrate the
	# brick variant pipeline by setting the variant texture on the
	# proof-room loadout. BrickBlock instances self-discover this in
	# their _ready and swap to the variant — produces visible band-
	# themed brick rendering in this scene only. arc-2/3 baseline +
	# arc-4 breach mode without explicit Loadout.brick_variant set
	# continues to render canonical sprites_1.png frame 5.
	spawned_player.loadout.brick_variant = preload("res://img/brick_012.png")
	spawned_player.add_to_group("player")
	add_child(spawned_player)
	# arc-4 iter 289: expose alias for Bullet's lvl.player reach.
	player = spawned_player
	# arc-4 iter 296 (playtest-fix from user): connect the shoot signal
	# so fired bullets actually instantiate. Mirrors Level.gd:17's pattern.
	# Without this, _fire() emits shoot but no listener spawns a bullet
	# → player feels like firing is broken.
	spawned_player.shoot.connect(_on_player_shoot)
	# arc-4 iter 315 (Round 26 Phase B post-pass): bricks were spawned
	# in _spawn_grid BEFORE the player joined the "player" group, so
	# their in-ready self-discovery returned null. Re-trigger lookup
	# now that the player is in the scene + group. BrickBlock's
	# apply_variant_lookup() is a no-op when variant_texture is
	# already set OR when the player chain doesn't have brick_variant.
	for ter in spawned_terrain:
		if ter != null and is_instance_valid(ter) and ter.has_method("apply_variant_lookup"):
			ter.apply_variant_lookup()


# arc-4 iter 296 (playtest-fix): mirror Level.gd._on_PlayerTank_shoot —
# instantiate the bullet at the muzzle position, add to scene, start with
# Environment (1) + Enemy (8) collision mask.
func _on_player_shoot(bullet: PackedScene, pos: Vector2, dir: int, shell_class: int = 0) -> void:
	var b: Node2D = bullet.instantiate()
	add_child(b)
	b.start(pos, dir, 9, shell_class)
