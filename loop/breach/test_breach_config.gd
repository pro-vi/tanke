# Arc-4 breach mode: BreachConfig + BreachBand verifier.
# Verifies configs/breach_default.tres loads cleanly + has ≥2 distinct
# bands with different terrain weights (C4 anchor 1 structural cite).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_config.gd

extends SceneTree

const BreachConfigT = preload("res://scripts/BreachConfig.gd")


func _init() -> void:
	var cfg: Resource = load("res://configs/breach_default.tres")
	if cfg == null:
		push_error("FAIL — breach_default.tres did not load")
		quit(1)
		return
	if not (cfg is BreachConfigT):
		push_error("FAIL — loaded resource is not BreachConfig: %s" % cfg.get_class())
		quit(1)
		return
	var n: int = cfg.band_count()
	print("band_count: %d" % n)
	if n < 2:
		push_error("FAIL — expected ≥2 bands, got %d" % n)
		quit(1)
		return
	# Confirm distinct terrain weights per band (C4 anchor 1: "different
	# terrain weights" — not just "different names").
	var weights := []
	for b in cfg.bands:
		if b == null:
			push_error("FAIL — null band in array"); quit(1); return
		print("  band[%s]  depth=[%d..%d]  pressure=%s" % [b.band_name, b.depth_min, b.depth_max, b.dominant_pressure])
		if b.level_config == null:
			push_error("FAIL — band %s has null level_config" % b.band_name); quit(1); return
		weights.append([b.level_config.brick_weight, b.level_config.water_weight])
	# Compare consecutive bands; at least one weight pair must differ.
	var distinct: bool = false
	for i in range(weights.size() - 1):
		if weights[i] != weights[i + 1]:
			distinct = true
			break
	if not distinct:
		push_error("FAIL — bands share identical terrain weights")
		quit(1)
		return
	print("BREACH_CONFIG_OK %d bands, distinct terrain weights" % n)
	quit(0)
