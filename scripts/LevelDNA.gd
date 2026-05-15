class_name LevelDNA
extends Resource

# A complete recipe for one reproducible level: seed + LevelConfig (+ biome).
# Serializable to/from a flat dict — round-trips through JSON without loss.
# iter 101 (review-fix): biome_path added so biomed levels actually round-trip;
# previously to_dict dropped the biome reference silently while still
# reporting ROUNDTRIP_OK.

const LevelConfigT = preload("res://scripts/LevelConfig.gd")
const BiomeConfigT = preload("res://scripts/BiomeConfig.gd")

@export var level_seed: int = 42
@export var config: LevelConfigT
@export var biome: BiomeConfigT  # optional; depth-modulates per-row config


func to_dict() -> Dictionary:
	var d: Dictionary = {"level_seed": level_seed}
	if config != null:
		d["merge_probability"] = config.merge_probability
		d["empty_weight"] = config.empty_weight
		d["brick_weight"] = config.brick_weight
		d["steel_weight"] = config.steel_weight
		d["grass_weight"] = config.grass_weight
		d["water_weight"] = config.water_weight
	else:
		d["config"] = null
	if biome != null and biome.resource_path != "":
		d["biome_path"] = biome.resource_path
	return d


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
	var biome_path: String = String(d.get("biome_path", ""))
	if biome_path != "":
		var biome_res = load(biome_path)
		if biome_res != null:
			dna.biome = biome_res
	return dna


func to_json() -> String:
	return JSON.stringify(to_dict(), "  ")


static func from_json(s: String) -> Resource:
	var parsed: Variant = JSON.parse_string(s)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return from_dict(parsed)
