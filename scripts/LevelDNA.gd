class_name LevelDNA
extends Resource

# A complete recipe for one reproducible level: seed + LevelConfig.
# Serializable to/from a flat dict — round-trips through JSON without loss.

const LevelConfigT = preload("res://scripts/LevelConfig.gd")

@export var level_seed: int = 42
@export var config: LevelConfigT


func to_dict() -> Dictionary:
	if config == null:
		return {"level_seed": level_seed, "config": null}
	return {
		"level_seed": level_seed,
		"merge_probability": config.merge_probability,
		"empty_weight": config.empty_weight,
		"brick_weight": config.brick_weight,
		"steel_weight": config.steel_weight,
		"grass_weight": config.grass_weight,
		"water_weight": config.water_weight,
	}


static func from_dict(d: Dictionary) -> Resource:
	# Resolve our own script via load() to avoid headless class_name lookup.
	var DNAScript = load("res://scripts/LevelDNA.gd")
	var dna = DNAScript.new()
	dna.level_seed = int(d.get("level_seed", 42))
	var cfg = LevelConfigT.new()
	cfg.merge_probability = float(d.get("merge_probability", 0.333))
	cfg.empty_weight = float(d.get("empty_weight", 0.10))
	cfg.brick_weight = float(d.get("brick_weight", 0.40))
	cfg.steel_weight = float(d.get("steel_weight", 0.15))
	cfg.grass_weight = float(d.get("grass_weight", 0.20))
	cfg.water_weight = float(d.get("water_weight", 0.15))
	dna.config = cfg
	return dna


func to_json() -> String:
	return JSON.stringify(to_dict(), "  ")


static func from_json(s: String) -> Resource:
	var parsed: Variant = JSON.parse_string(s)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return from_dict(parsed)
