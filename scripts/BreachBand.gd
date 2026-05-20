class_name BreachBand
extends Resource

# Arc-4 breach mode: one depth band. Each band is a *specific climb
# problem* (CONSULT constraint 5) — NOT generic-harder. Per BANDS.md
# the 5-band roadmap encodes terrain/enemy pressure + canonical breach
# answer per band.

const LevelConfigT = preload("res://scripts/LevelConfig.gd")

@export var band_name: String = ""
@export var depth_min: int = 0    # in tile-rows climbed from start (inclusive)
@export var depth_max: int = 0    # in tile-rows climbed from start (inclusive)
@export var dominant_pressure: String = ""   # e.g. "brick walls + light scouts"
@export var canonical_answer: String = ""    # e.g. "AP — cheap pierce"
@export var level_config: LevelConfigT = null  # terrain-weight override; null = use base
# arc-4 iter 15: per-band enemy roster. Maps Spawner ENEMY_TYPES role
# names ("Light"/"Heavy"/"Fast") to spawn weights. Empty = Spawner falls
# back to its arc-2 DEPTH_BANDS weights. Read by Spawner._pick_enemy_type
# when the level is in breach mode.
@export var enemy_weights: Dictionary = {}


func contains(rows_climbed: int) -> bool:
	return rows_climbed >= depth_min and rows_climbed <= depth_max
