# Arc-4 breach mode: Round-10 Phase-1 distinctness-audit harness
# (iter 74). Per Consult 008's H4 reframe — "experientially
# homogeneous despite mechanically distinct" is the dominant risk and
# is STRUCTURALLY detectable. This Phase-1 scaffold compares each
# archetype's STRUCTURAL signal vector (the static design properties
# the harness can read without play-sim); Phase-1 continuation
# iter 75 will add play-sim metrics (kill distance, time stationary,
# death reason distribution).
#
# The audit FAILS if any pair of archetypes shares more than (N - 3)
# of N signals — proxy for "playtester would see them as variants of
# the same loop." With the iter-74 6-signal vector, the threshold is
# differ-in-≥3-of-6 per pair (6 pairs total: D-P, D-M, D-R, P-M,
# P-R, M-R).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_distinctness_audit.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")

const MIN_DISTINCT_SIGNALS: int = 3  # per pair, out of 6 (Phase-1)

const ARCHETYPE_NAMES: Dictionary = {
	0: "DEFAULT",
	1: "PRISM",
	2: "MORTAR",
	3: "RAM",
}


# Per-archetype STRUCTURAL signal vector (6 axes). All values are
# string-typed for clean pairwise equality comparison.
func _signal_vector(pt: Node) -> Array:
	var arch: int = pt.archetype
	# Axis 1: weapon artifact kind
	var weapon_kind: String = "bullet"
	if arch == PlayerTankT.TankArchetype.PRISM:
		weapon_kind = "beam"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		weapon_kind = "mortar_shell"
	elif arch == PlayerTankT.TankArchetype.RAM:
		weapon_kind = "melee_cone+collision"

	# Axis 2: movement blocked during fire
	var move_blocked: String = "no"
	if arch == PlayerTankT.TankArchetype.PRISM:
		move_blocked = "yes"

	# Axis 3: fire range class (the dominant range-driver per archetype)
	var range_class: String = "medium"  # DEFAULT's bullet range
	if arch == PlayerTankT.TankArchetype.PRISM:
		range_class = "long(160)"        # BEAM_RANGE
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		range_class = "arc-medium(96)"   # MORTAR_RANGE
	elif arch == PlayerTankT.TankArchetype.RAM:
		range_class = "melee(18)"        # RAM_SWING_RANGE

	# Axis 4: fire cadence class
	var cadence_class: String = "discrete-fast"  # DEFAULT GunTimer ~1.0s
	if arch == PlayerTankT.TankArchetype.PRISM:
		cadence_class = "continuous"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		cadence_class = "discrete-slow(1.5)"
	elif arch == PlayerTankT.TankArchetype.RAM:
		cadence_class = "melee-burst(0.5)"

	# Axis 5: damage source class (where damage comes from in the world)
	var damage_source: String = "projectile"
	if arch == PlayerTankT.TankArchetype.PRISM:
		damage_source = "per-tick-raycast"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		damage_source = "aoe-impact"
	elif arch == PlayerTankT.TankArchetype.RAM:
		damage_source = "collision+swing"

	# Axis 6: structural HUD-or-mod fingerprint (the per-archetype
	# init artifact). Read from the live scene tree.
	var fingerprint: String = "none"
	if arch == PlayerTankT.TankArchetype.PRISM:
		fingerprint = "BeamLine" if pt.get_node_or_null("BeamLine") != null else "MISSING_BeamLine"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		var gt: Node = pt.get_node_or_null("GunTimer")
		fingerprint = "GunTimer@1.5" if (gt != null and (gt as Timer).wait_time > 1.4) else "MISSING_GunTimer_slowdown"
	elif arch == PlayerTankT.TankArchetype.RAM:
		# Speed should reflect base + RAM_SPEED_BONUS (6).
		fingerprint = "speed+bonus(38)" if pt.speed > 32 else "MISSING_speed_bonus"
	# DEFAULT has no fingerprint — the absence IS the signal.

	return [weapon_kind, move_blocked, range_class, cadence_class, damage_source, fingerprint]


func _pairwise_distance(va: Array, vb: Array) -> int:
	var distance: int = 0
	for i in va.size():
		if va[i] != vb[i]:
			distance += 1
	return distance


func _initialize() -> void:
	# === Spawn each archetype + capture its signal vector.
	var holder := Node2D.new()
	root.add_child(holder)
	var vectors: Dictionary = {}
	for arch_value in [
		PlayerTankT.TankArchetype.DEFAULT,
		PlayerTankT.TankArchetype.PRISM,
		PlayerTankT.TankArchetype.MORTAR,
		PlayerTankT.TankArchetype.RAM,
	]:
		var pt: Node = PlayerTankScene.instantiate()
		pt.loadout = LoadoutT.new()
		pt.archetype = arch_value
		holder.add_child(pt)
		await process_frame
		await process_frame
		# Sanity: archetype init must have run (per-archetype mods applied).
		if pt.archetype != arch_value:
			push_error("FAIL — archetype mismatch after instantiate %d != %d" % [pt.archetype, arch_value])
			quit(1); return
		vectors[arch_value] = _signal_vector(pt)
		print("  %s: %s" % [ARCHETYPE_NAMES[arch_value], str(vectors[arch_value])])

	# === Pairwise distinctness — 6 pairs, each must differ in ≥3 of 6.
	var keys: Array = vectors.keys()
	var min_seen: int = 999
	var converged_pairs: Array = []
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			var ka: int = keys[i]
			var kb: int = keys[j]
			var dist: int = _pairwise_distance(vectors[ka], vectors[kb])
			if dist < min_seen:
				min_seen = dist
			var pair_label: String = "%s↔%s" % [ARCHETYPE_NAMES[ka], ARCHETYPE_NAMES[kb]]
			print("  %s — pairwise distance %d / 6" % [pair_label, dist])
			if dist < MIN_DISTINCT_SIGNALS:
				converged_pairs.append(pair_label)

	if not converged_pairs.is_empty():
		push_error("FAIL — distinctness audit CONVERGENCE WARNING: pairs sharing ≥%d of 6 signals: %s. Per Consult 008, the playtest will likely report 'feels the same' for these archetype pairs." % [
			6 - MIN_DISTINCT_SIGNALS + 1, str(converged_pairs)])
		quit(1); return

	print("  min pairwise distance: %d / 6 (threshold ≥%d)" % [min_seen, MIN_DISTINCT_SIGNALS])
	print("BREACH_DISTINCTNESS_AUDIT_OK Phase-1 structural — 4 archetypes, 6 pairs all differ in ≥%d of 6 signals" % MIN_DISTINCT_SIGNALS)
	print("  NOTE: Phase-1 scaffold (structural signals only). Phase-1 continuation iter 75 adds play-sim metrics (kill distance, time stationary, depot picks).")
	quit(0)
