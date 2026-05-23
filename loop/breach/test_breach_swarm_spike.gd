# Arc-4 breach mode: Round-11 Phase-2 SWARM SPIKE harness (iter 85).
# Empirically compares the 3 SWARM variants (α/β/γ) named in
# iter-084-round11-phase2-spike.md. For each variant, places its
# enemy cluster + tests each archetype's damage delivery — verifies
# whether the cross-archetype hierarchy criterion (per Pro's H2)
# holds: ≤1 archetype shares the worst outcome.
#
# Hybrid approach: real MORTAR _explode + RAM _ram_swing on
# armored/unarmored stub clusters at variant formations; DEFAULT
# and PRISM outcomes DERIVED from constants (DEFAULT = 1 bullet per
# enemy = N shots; PRISM = beam stops at first body = 1 hit per
# fire-event burst).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_swarm_spike.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")


# Stub mimicking the take_damage interface; configurable armor + hp.
class _SwarmStub extends Node2D:
	var hp: int = 1
	var damage_received: int = 0
	func take_damage(amount: int) -> void:
		hp -= amount
		damage_received += amount


func _make_cluster(parent: Node, positions: Array, hp_each: int, armored: bool) -> Array:
	var stubs: Array = []
	for pos in positions:
		var stub: Node = _SwarmStub.new()
		stub.position = pos
		stub.hp = hp_each
		parent.add_child(stub)
		if armored:
			stub.add_to_group("armored")
		stubs.append(stub)
	return stubs


# Variant α: swarmlet — 5 Light-clones, 1hp, chevron formation
# (3 front + 2 back), ~10px spacing.
func _spawn_alpha(parent: Node) -> Array:
	var positions: Array = [
		Vector2(0, 0),    # center-front
		Vector2(-10, 0),  # left-front
		Vector2(10, 0),   # right-front
		Vector2(-5, 10),  # left-rear
		Vector2(5, 10),   # right-rear
	]
	return _make_cluster(parent, positions, 1, false)


# Variant β: Fast-rusher pack — 3 Fast, 1hp, lateral spread (~16px).
func _spawn_beta(parent: Node) -> Array:
	var positions: Array = [
		Vector2(-16, 0),
		Vector2(0, 0),
		Vector2(16, 0),
	]
	return _make_cluster(parent, positions, 1, false)


# Variant γ: Heavy-pair spinet — 2 Heavies, 3hp armored, 16px apart.
func _spawn_gamma(parent: Node) -> Array:
	var positions: Array = [
		Vector2(-8, 0),
		Vector2(8, 0),
	]
	return _make_cluster(parent, positions, 3, true)


# Outcome classifications (for cross-archetype hierarchy check).
const BEST: String = "BEST"
const GOOD: String = "GOOD"
const COSTLY: String = "COSTLY"
const WEAK: String = "WEAK"
const BAD: String = "BAD"


# Score a damage-delivery vector to an outcome class.
# Inputs: kills_per_event (how many cluster members die per fire
# event) + clear_efficiency (kills / cluster_size). Higher = better.
func _classify(kills_per_event: int, cluster_size: int, archetype_label: String) -> String:
	var ratio: float = float(kills_per_event) / float(cluster_size)
	if ratio >= 0.6:
		return BEST     # one event clears most of the cluster
	elif ratio >= 0.4:
		return GOOD     # solid coverage
	elif ratio >= 0.2:
		return COSTLY   # picks off one, costly to clear
	elif ratio > 0.0:
		return WEAK     # tiny coverage
	else:
		return BAD      # zero coverage on the event


func _measure_mortar(parent: Node, stubs: Array, impact_pos: Vector2) -> int:
	# MORTAR explode at impact_pos hits siblings within AOE_RADIUS=18.
	var shell: Node = MortarShellScene.instantiate()
	shell.position = impact_pos
	parent.add_child(shell)
	var pre_hp_sum: int = 0
	for s in stubs:
		pre_hp_sum += s.hp
	shell._explode()
	var kills: int = 0
	for s in stubs:
		if s.hp <= 0:
			kills += 1
	return kills


func _measure_ram(parent: Node, stubs: Array, player_pos: Vector2) -> int:
	# RAM swing iterates Node2D siblings within RAM_SWING_RANGE=18.
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.archetype = PlayerTankT.TankArchetype.RAM
	pt.position = player_pos
	pt.direction = 0  # UP
	parent.add_child(pt)
	await process_frame
	await process_frame
	pt._ram_swing()
	var kills: int = 0
	for s in stubs:
		if s.hp <= 0:
			kills += 1
	return kills


# DEFAULT/PRISM are derived (not run in-frame). DEFAULT fires 1
# bullet per fire-event hitting 1 enemy (kills 1 if unarmored;
# 0 with AP vs armored γ — see iter-77 probe). PRISM beam hits 1
# body and stops (BEAM stops at first hit).
func _derive_default(cluster_size: int, hp_each: int, armored: bool) -> int:
	if armored:
		return 0  # AP blocked vs Heavy (matrix DEFAULT default loadout)
	return 1  # one bullet hits the front-most enemy, kills it (1hp)


func _derive_prism(cluster_size: int, hp_each: int) -> int:
	if hp_each > 1:
		return 0  # beam DPS too slow for one-event kill on Heavy
	return 1  # beam hits first body, kills it (1hp)


func _spike_variant(label: String, spawn_fn: Callable, hp_each: int, armored: bool, mortar_impact: Vector2, ram_player_pos: Vector2) -> Dictionary:
	print("  ── variant %s ──" % label)
	# Spawn 4 fresh clusters (one per archetype) to avoid bleed.
	var holder := Node2D.new()
	root.add_child(holder)

	# DEFAULT: derive from constants (no live test — DEFAULT shoots
	# discrete bullets that need their own flight sim).
	var stubs_d: Array = spawn_fn.call(holder)
	var kills_default: int = _derive_default(stubs_d.size(), hp_each, armored)
	print("    DEFAULT (derived from constants): %d kill(s) per event" % kills_default)

	# PRISM: derive — beam stops at first body.
	var kills_prism: int = _derive_prism(stubs_d.size(), hp_each)
	print("    PRISM   (derived): %d kill(s) per event" % kills_prism)

	# MORTAR: live test — _explode at the cluster center.
	var sub_m := Node2D.new()
	holder.add_child(sub_m)
	var stubs_m: Array = spawn_fn.call(sub_m)
	var kills_mortar: int = _measure_mortar(sub_m, stubs_m, mortar_impact)
	print("    MORTAR  (live AoE): %d kill(s) per event" % kills_mortar)

	# RAM: live test — _ram_swing with stubs positioned in range.
	var sub_r := Node2D.new()
	holder.add_child(sub_r)
	var stubs_r: Array = spawn_fn.call(sub_r)
	var kills_ram: int = await _measure_ram(sub_r, stubs_r, ram_player_pos)
	print("    RAM     (live swing): %d kill(s) per event" % kills_ram)

	var cluster_size: int = stubs_d.size()
	var outcomes: Dictionary = {
		"DEFAULT": _classify(kills_default, cluster_size, "DEFAULT"),
		"PRISM":   _classify(kills_prism, cluster_size, "PRISM"),
		"MORTAR":  _classify(kills_mortar, cluster_size, "MORTAR"),
		"RAM":     _classify(kills_ram, cluster_size, "RAM"),
	}
	var distinct: Dictionary = {}
	for k in outcomes:
		distinct[outcomes[k]] = true
	print("    outcomes: DEFAULT=%s, PRISM=%s, MORTAR=%s, RAM=%s — %d distinct" % [outcomes["DEFAULT"], outcomes["PRISM"], outcomes["MORTAR"], outcomes["RAM"], distinct.size()])

	# Hierarchy check: count archetypes sharing the WORST outcome.
	var worst_order: Array = [BAD, WEAK, COSTLY, GOOD, BEST]
	var worst_seen: String = BEST
	for o in outcomes.values():
		var oi: int = worst_order.find(o)
		var wi: int = worst_order.find(worst_seen)
		if oi != -1 and oi < wi:
			worst_seen = o
	var worst_count: int = 0
	for o in outcomes.values():
		if o == worst_seen:
			worst_count += 1
	var violates: bool = worst_count >= 2
	if violates:
		print("    VIOLATES hierarchy — %d archetypes share worst outcome (%s)" % [worst_count, worst_seen])
	else:
		print("    PASSES hierarchy — unique worst outcome (%s) for 1 archetype" % worst_seen)
	holder.queue_free()
	await process_frame
	return {"label": label, "outcomes": outcomes, "distinct_count": distinct.size(), "violates": violates}


func _initialize() -> void:
	print("== Round 11 Phase 2 SWARM SPIKE — α/β/γ hierarchy comparison ==")

	# Variant α: swarmlet (5 Lights, chevron, ~10px spacing).
	# MORTAR impact at chevron center (0,5); RAM at chevron front
	# (0,-10) so swing range catches multiple.
	var r_alpha: Dictionary = await _spike_variant(
		"α swarmlet (5 Light chevron)", _spawn_alpha, 1, false,
		Vector2(0, 5), Vector2(0, -8))

	# Variant β: Fast-rusher pack (3 Fast, lateral spread 16px).
	# MORTAR impact at center; RAM in front of center.
	var r_beta: Dictionary = await _spike_variant(
		"β Fast-rusher pack (3 Fast, ±16px)", _spawn_beta, 1, false,
		Vector2(0, 0), Vector2(0, -8))

	# Variant γ: Heavy-pair spinet (2 Heavy, 16px apart, armored).
	# MORTAR impact at midpoint; RAM between them.
	var r_gamma: Dictionary = await _spike_variant(
		"γ Heavy-pair spinet (2 Heavy ±8px, armored)", _spawn_gamma, 3, true,
		Vector2(0, 0), Vector2(0, -2))

	# === Verdict
	print("== SPIKE verdict ==")
	for r in [r_alpha, r_beta, r_gamma]:
		var status: String = "VIOLATES" if r["violates"] else "PASSES"
		print("  %s — %d distinct outcomes — %s" % [r["label"], r["distinct_count"], status])

	# Recommendation per blueprint: ship the variant with most
	# distinct outcomes that PASSES; reject any that VIOLATES.
	# γ is Round-12-deferred per blueprint (paired-armored is a
	# different pressure than dense-swarm).
	var recommendation: String = ""
	if not r_alpha["violates"]:
		recommendation = "SHIP α (dense-swarm — primary Round-11 Phase-2 target)"
	elif not r_gamma["violates"]:
		recommendation = "SHIP γ (paired-armored — Round-11 fallback; was Round-12)"
	else:
		recommendation = "ABORT — all variants violate; revise blueprint"
	if not r_beta["violates"]:
		recommendation += "; ALSO: β passes (unexpected — re-examine spread assumptions)"
	else:
		recommendation += "; REJECT β (predicted, hierarchy violates)"

	print("  recommendation: %s" % recommendation)
	print("BREACH_SWARM_SPIKE_OK 3 variants compared; recommendation emitted")
	quit(0)
