class_name BiomeConfig
extends Resource

# A pair of LevelConfigs interpolated over depth.
# t = 0   → surface
# t = 1   → deep
# t = clamp((surface_row - row) / depth_scale, 0, 1)
#   surface_row: row index considered "shallowest" (top of starting screen, default 14)
#   depth_scale: row count over which the transition completes
#
# Ratchet behavior: rows numerically less than surface_row count as deeper.
# Initial _ready generates rows 14..0 → t sweeps 0 → 1 over visible area
# (with depth_scale ≤ 14). Subsequent _process rows go further into the deep biome.

const LevelConfigT = preload("res://scripts/LevelConfig.gd")

@export var surface: LevelConfigT
@export var deep: LevelConfigT
@export var surface_row: int = 14
@export_range(1, 200) var depth_scale: int = 14


func depth_t(row: int) -> float:
	var depth: int = max(0, surface_row - row)
	return clamp(float(depth) / float(depth_scale), 0.0, 1.0)


func config_at(row: int) -> LevelConfigT:
	# iter 101 (review-fix): explicit assert when both endpoints null —
	# downstream null-deref in _pave_set → sample_terrain() was silent.
	assert(surface != null or deep != null, "BiomeConfig: both surface and deep are null")
	if surface == null or deep == null:
		return surface if surface != null else deep
	var t: float = depth_t(row)
	var c: LevelConfigT = LevelConfigT.new()
	c.merge_probability = lerpf(surface.merge_probability, deep.merge_probability, t)
	c.empty_weight = lerpf(surface.empty_weight, deep.empty_weight, t)
	c.brick_weight = lerpf(surface.brick_weight, deep.brick_weight, t)
	c.steel_weight = lerpf(surface.steel_weight, deep.steel_weight, t)
	c.grass_weight = lerpf(surface.grass_weight, deep.grass_weight, t)
	c.water_weight = lerpf(surface.water_weight, deep.water_weight, t)
	return c
