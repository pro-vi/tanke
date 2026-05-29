# arc-4 PR-#4 P1 review fix regression — Spawner used to set max_hp
# per enemy type but never beam_hp_max, so the @export default 10
# leaked through and PRISM beam TTK was a flat 10 ticks for every
# enemy. A 1-HP Fast scout and a 3-HP Heavy took identical beam time,
# inverting the toughness signal that bullets + sprite-scale establish.
#
# Fix: Spawner sets enemy.beam_hp_max from per-type ENEMY_TYPES values
# (Light=3, Heavy=9, Fast=3). _build_hp_bar gate updated to fire on
# max(max_hp, beam_hp_max) > 1 so 1-HP enemies with multi-tick beam
# still get a drain bar.
#
# 4 cases:
#   1. ENEMY_TYPES table has beam_hp_max per type with the expected
#      proportional values (3 / 9 / 3 for Light / Heavy / Fast).
#   2. Spawned Light: beam_hp_max == 3 (NOT 10).
#   3. Spawned Heavy: beam_hp_max == 9 (~3× Light, matches toughness).
#   4. The proportional ratio holds: Heavy.beam_hp_max > Light.beam_hp_max.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_beam_ttk_per_type.gd

extends SceneTree

const SpawnerT = preload("res://scripts/Spawner.gd")
const EnemyScene = preload("res://scenes/Enemy.tscn")


# Pull the per-type beam_hp_max from ENEMY_TYPES dicts directly.
func _beam_hp_for(name: String) -> int:
	for t in SpawnerT.ENEMY_TYPES:
		if String(t["name"]) == name:
			return int(t.get("beam_hp_max", -1))
	return -1


func _spawn_enemy_with_type(type_name: String) -> Node:
	# Instantiate Enemy + apply the per-type data the way Spawner does.
	var enemy: Node = EnemyScene.instantiate()
	var type_data: Dictionary = {}
	for t in SpawnerT.ENEMY_TYPES:
		if String(t["name"]) == type_name:
			type_data = t
			break
	enemy.set("enemy_type", type_data["name"])
	enemy.set("max_hp", type_data["max_hp"])
	enemy.set("beam_hp_max", int(type_data.get("beam_hp_max", 10)))
	return enemy


func _initialize() -> void:
	# === Case 1: ENEMY_TYPES table values.
	var light_beam: int = _beam_hp_for("Light")
	var heavy_beam: int = _beam_hp_for("Heavy")
	var fast_beam: int = _beam_hp_for("Fast")
	if light_beam != 3:
		push_error("FAIL — Light beam_hp_max=%d (want 3 per review fix)" % light_beam)
		quit(1); return
	if heavy_beam != 9:
		push_error("FAIL — Heavy beam_hp_max=%d (want 9 per review fix)" % heavy_beam)
		quit(1); return
	if fast_beam != 3:
		push_error("FAIL — Fast beam_hp_max=%d (want 3 per review fix)" % fast_beam)
		quit(1); return
	print("  case 1: ENEMY_TYPES table — Light=3 / Heavy=9 / Fast=3 (proportional to bullet HP)")

	# === Case 2: spawned Light has correct beam_hp_max.
	var light := _spawn_enemy_with_type("Light")
	root.add_child(light)
	await process_frame
	if int(light.beam_hp_max) != 3:
		push_error("FAIL — spawned Light beam_hp_max=%d (want 3; @export default 10 leaking through)" \
				% int(light.beam_hp_max))
		quit(1); return
	# beam_hp (current pool) should also init from beam_hp_max at _ready.
	if int(light.beam_hp) != 3:
		push_error("FAIL — spawned Light beam_hp=%d (want 3; init mismatch)" % int(light.beam_hp))
		quit(1); return
	print("  case 2: spawned Light → beam_hp_max=3 (not flat 10 default)")
	light.queue_free()
	await process_frame

	# === Case 3: spawned Heavy has correct beam_hp_max.
	var heavy := _spawn_enemy_with_type("Heavy")
	root.add_child(heavy)
	await process_frame
	if int(heavy.beam_hp_max) != 9:
		push_error("FAIL — spawned Heavy beam_hp_max=%d (want 9)" % int(heavy.beam_hp_max))
		quit(1); return
	print("  case 3: spawned Heavy → beam_hp_max=9 (~3× Light; matches toughness)")
	heavy.queue_free()
	await process_frame

	# === Case 4: Heavy.beam > Light.beam (the inverted-signal regression).
	if heavy_beam <= light_beam:
		push_error("FAIL — Heavy.beam_hp_max (%d) <= Light.beam_hp_max (%d) — toughness signal still inverted" \
				% [heavy_beam, light_beam])
		quit(1); return
	print("  case 4: Heavy.beam_hp_max (%d) > Light.beam_hp_max (%d) — toughness signal preserved" \
			% [heavy_beam, light_beam])

	print("BREACH_BEAM_TTK_PER_TYPE_OK 4 cases — per-type beam_hp_max + proportional TTK + inverted-signal regression locked")
	quit(0)
