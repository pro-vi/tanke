# Arc-4 iter 308 (Round 25 Probe 2): Shell × target pressure matrix.
#
# Measures the canonical mechanic for every (shell, target) cell:
#   damage_per_hit, hits_to_destroy, route_hit_recorded_per_shot.
#
# Targets: brick (hp=1) / steel (no take_damage, breach() only) /
#          light enemy (hp=1) / heavy enemy (hp=3, armored).
# Shells:  AP / HE / HEAT / APCR.
#
# Per cell, the harness:
#   - Instantiates a fresh target (with is_route_gate meta so the route
#     ledger fires when take_damage runs).
#   - Wraps it in a Q1ProofRoom-style mock parent that exposes a `player`
#     with a `record_shot_hit` method (Bullet._try_record_shot_hit needs
#     this reachable via parent.player).
#   - Fires bullets one by one until target is queued_for_deletion OR
#     MAX_HITS_PER_CELL reached.
#   - Records damage_per_hit (target.hp delta if take_damage; "drills"
#     for APCR-steel; "bounces" for AP/HE-steel) + hits_to_destroy +
#     route_hits_recorded.
#
# Output: tools/out/shell_pressure_matrix.json (4×4 grid).
#
# Run with:
#   godot --headless --path . --script res://tools/shell_pressure_matrix.gd

extends SceneTree

const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const BrickBlockScene = preload("res://scenes/BrickBlock.tscn")
const SteelBlockScene = preload("res://scenes/SteelBlock.tscn")
const EnemyScene = preload("res://scenes/Enemy.tscn")

const SHELL_NAMES: Array = ["AP", "HE", "HEAT", "APCR"]
const SHELL_CLASSES: Array = [0, 1, 2, 3]  # SHELL_CLASS_{AP,HE,HEAT,APCR}
const TARGET_NAMES: Array = ["brick", "steel", "light_enemy", "heavy_enemy"]
const MAX_HITS_PER_CELL: int = 10  # safety cap; any cell needing more is reported as ">10"


# Mock-Level node that exposes a `player` property carrying the
# record_shot_hit method so Bullet._try_record_shot_hit can reach it
# via the iter-24 `"player" in lvl` pattern. Without this the route
# ledger silently no-ops on every cell.
class MockLevel extends Node2D:
	var player: MockPlayer = null

	func _init() -> void:
		player = MockPlayer.new()
		add_child(player)


# Mock-Player with the record_shot_hit pass-through. The probe is the
# observer here, so the player itself just counts.
class MockPlayer extends Node:
	var route_hits: int = 0
	var combat_hits: int = 0

	func record_shot_hit(shell_class: int, hit_kind: String) -> void:
		if hit_kind == "route":
			route_hits += 1
		elif hit_kind == "combat":
			combat_hits += 1


func _spawn_target(name: String, on_gate: bool) -> Node:
	var node: Node = null
	if name == "brick":
		node = BrickBlockScene.instantiate()
	elif name == "steel":
		node = SteelBlockScene.instantiate()
	elif name == "light_enemy":
		node = EnemyScene.instantiate()
		(node as Node2D).set("enemy_type", "Light")
		(node as Node2D).set("max_hp", 1)
		(node as Node2D).set("hp", 1)
	elif name == "heavy_enemy":
		node = EnemyScene.instantiate()
		(node as Node2D).set("enemy_type", "Heavy")
		(node as Node2D).set("max_hp", 3)
		(node as Node2D).set("hp", 3)
		(node as Node2D).add_to_group("armored")
	if on_gate:
		node.set_meta("is_route_gate", true)
	return node


func _run_cell(shell_class: int, target_name: String) -> Dictionary:
	var mock_lvl: MockLevel = MockLevel.new()
	root.add_child(mock_lvl)
	await process_frame

	var target: Node = _spawn_target(target_name, true)
	mock_lvl.add_child(target)
	await process_frame

	var has_take_damage: bool = target.has_method("take_damage")
	var has_breach: bool = target.has_method("breach")
	var initial_hp: int = -1
	if "hp" in target:
		initial_hp = int(target.hp)

	var hits: int = 0
	var damages_dealt: Array = []
	var destroyed: bool = false

	while hits < MAX_HITS_PER_CELL and not destroyed:
		var hp_before: int = -1
		if "hp" in target and is_instance_valid(target):
			hp_before = int(target.hp)
		var b: Node = BulletScene.instantiate()
		b.shell_class = shell_class
		mock_lvl.add_child(b)
		b._on_body_entered(target)
		hits += 1
		await process_frame
		if not is_instance_valid(target) or (target as Node).is_queued_for_deletion():
			destroyed = true
			# Last hit may have dealt the remaining hp; if we had hp_before
			# captured, the final damage is hp_before.
			if hp_before > 0:
				damages_dealt.append(hp_before)
			break
		if "hp" in target:
			var hp_after: int = int(target.hp)
			if hp_before >= 0:
				damages_dealt.append(hp_before - hp_after)

	# Outcome classification.
	var outcome: String = "alive"
	if destroyed:
		outcome = "destroyed"
	elif hits >= MAX_HITS_PER_CELL:
		outcome = "alive_after_max_hits"

	# Effect classification (synthesized).
	var effect: String = "n/a"
	if not has_take_damage and not has_breach:
		effect = "bounces"  # AP/HE on steel without breach method
	elif not has_take_damage and has_breach and shell_class == BulletT.SHELL_CLASS_APCR:
		effect = "drills"  # APCR on steel
	elif not has_take_damage:
		effect = "bounces"  # AP/HE/HEAT on steel (no take_damage; breach gated to APCR)
	else:
		# enemy or brick — take_damage worked. damage_per_hit observable.
		if damages_dealt.size() > 0:
			# Standard "damage_per_hit" = first observed nonzero, or 0 if all 0.
			var first_nonzero: int = 0
			for d in damages_dealt:
				if d > 0:
					first_nonzero = d
					break
			effect = "damage_%d_per_hit" % first_nonzero

	var stats: Dictionary = {
		"shell": SHELL_NAMES[shell_class],
		"target": target_name,
		"hits_fired": hits,
		"outcome": outcome,
		"effect": effect,
		"damages_observed": damages_dealt,
		"route_hits_recorded": mock_lvl.player.route_hits,
		"combat_hits_recorded": mock_lvl.player.combat_hits,
		"initial_hp": initial_hp,
		"has_take_damage": has_take_damage,
		"has_breach": has_breach,
	}

	mock_lvl.queue_free()
	await process_frame
	return stats


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tools/out")

	var matrix: Array = []
	for s in SHELL_CLASSES.size():
		var row: Array = []
		for t in TARGET_NAMES.size():
			var cell: Dictionary = await _run_cell(SHELL_CLASSES[s], TARGET_NAMES[t])
			row.append(cell)
			print("  %-5s × %-13s: %s (%d hit%s, %s, routes=%d combat=%d)" % [
				SHELL_NAMES[s],
				TARGET_NAMES[t],
				cell["outcome"],
				cell["hits_fired"],
				"" if cell["hits_fired"] == 1 else "s",
				cell["effect"],
				cell["route_hits_recorded"],
				cell["combat_hits_recorded"],
			])
		matrix.append(row)

	var out_path: String = "res://tools/out/shell_pressure_matrix.json"
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("FAIL — could not write %s" % out_path)
		quit(1)
		return
	var payload: Dictionary = {
		"shells": SHELL_NAMES,
		"targets": TARGET_NAMES,
		"matrix": matrix,
		"max_hits_per_cell": MAX_HITS_PER_CELL,
	}
	f.store_string(JSON.stringify(payload, "  "))
	f.close()

	print("SHELL_PRESSURE_MATRIX_OK 16 cells (4 shells × 4 targets) — output to tools/out/shell_pressure_matrix.json")
	quit(0)
