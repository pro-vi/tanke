class_name BandedBiomeConfig
extends BiomeConfig

# Banded biome — extends BiomeConfig with 4 distinct LevelConfig bands keyed
# by row threshold (player ascends → row decreases). Maps to Spawner.DEPTH_BANDS:
#   warmup    (depth 0-8)   → BiomeConfig.surface (inherited slot)
#   first_push (depth 8-20)  → first_push
#   heavy_gate (depth 20-40) → heavy_gate
#   rush       (depth 40+)   → rush
#
# Row thresholds (rows are signed; row=14 at spawn, row=0 at depth 14, etc.):
#   first_push_row_threshold: row at which first_push takes over (default 6, depth 8)
#   heavy_gate_row_threshold: default -6 (depth 20)
#   rush_row_threshold: default -26 (depth 40)
#
# Returns the appropriate band's LevelConfig at each row. No interpolation —
# discrete bands per user iter-60 directive: "interesting local map" via
# visible terrain mix shifts at band boundaries.

@export var first_push: LevelConfig
@export var heavy_gate: LevelConfig
@export var rush: LevelConfig
@export var first_push_row_threshold: int = 6   # depth 8
@export var heavy_gate_row_threshold: int = -6  # depth 20
@export var rush_row_threshold: int = -26       # depth 40


func config_at(row: int) -> LevelConfigT:
	if rush != null and row <= rush_row_threshold:
		return rush
	if heavy_gate != null and row <= heavy_gate_row_threshold:
		return heavy_gate
	if first_push != null and row <= first_push_row_threshold:
		return first_push
	return surface  # default: warmup (inherited from BiomeConfig)
