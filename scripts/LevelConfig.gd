class_name LevelConfig
extends Resource

# Eller's algorithm — probability of merging horizontally adjacent cells
# into the same set (0.0 = never merge, 1.0 = always merge)
@export_range(0.0, 1.0, 0.01) var merge_probability: float = 0.333

# Per-set terrain weights. Each Eller set samples one outcome from this
# distribution. Weights are normalized; absolute scale doesn't matter.
@export_range(0.0, 10.0, 0.01) var empty_weight: float = 0.10
@export_range(0.0, 10.0, 0.01) var brick_weight: float = 0.40
@export_range(0.0, 10.0, 0.01) var steel_weight: float = 0.15
@export_range(0.0, 10.0, 0.01) var grass_weight: float = 0.20
@export_range(0.0, 10.0, 0.01) var water_weight: float = 0.15


func sample_terrain() -> String:
	var weights := [empty_weight, brick_weight, steel_weight, grass_weight, water_weight]
	var labels := ["", "brick", "steel", "grass", "water"]
	var total := 0.0
	for w in weights:
		total += w
	if total <= 0.0:
		return ""
	var r := randf() * total
	var acc := 0.0
	for i in weights.size():
		acc += weights[i]
		if r < acc:
			return labels[i]
	return labels[-1]
