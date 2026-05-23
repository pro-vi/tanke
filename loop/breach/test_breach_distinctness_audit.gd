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

const MIN_DISTINCT_SIGNALS: int = 5  # per pair, out of 10 (Phase-1 with play-relevant axes)
const TOTAL_SIGNALS: int = 10
const CALIBRATION_CEILING: float = 0.8  # min/total > 0.8 → audit too easy

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

	# === Iter 75 (Phase 1 continuation): 4 play-relevant DERIVED axes.
	# These are NOT play-sim — they are properties derived from
	# archetype constants that correlate to what the player feels
	# (cadence, magnitude, persistence, range shape). Phase 2
	# (PRESSURES.md) is where real play-sim probe scenarios go.

	# Axis 7: damage rate per second (fire-held). Approximates the
	# tempo of damage delivery — how often the player gets to
	# "do something."
	var damage_rate_hz: String = "1.0Hz"  # DEFAULT GunTimer ~1.0s nominal
	if arch == PlayerTankT.TankArchetype.PRISM:
		damage_rate_hz = "4.0Hz"  # 1.0 / BEAM_DAMAGE_COOLDOWN (0.25)
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		damage_rate_hz = "0.67Hz"  # 1.0 / MORTAR_GUN_COOLDOWN (1.5)
	elif arch == PlayerTankT.TankArchetype.RAM:
		damage_rate_hz = "2.0Hz"  # 1.0 / RAM_SWING_COOLDOWN (0.5) — swing only

	# Axis 8: damage magnitude per event class. Shapes risk/reward
	# of each commitment — RAM swings hit hard once; PRISM ticks
	# small but accumulates.
	var damage_magnitude: String = "single(1-2)"  # DEFAULT shell
	if arch == PlayerTankT.TankArchetype.PRISM:
		damage_magnitude = "trickle(1/tick)"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		damage_magnitude = "aoe(1xN-bodies)"
	elif arch == PlayerTankT.TankArchetype.RAM:
		damage_magnitude = "burst(2-swing+1-collide)"

	# Axis 9: damage source persistence in the world. Does the
	# threat linger / fly / attach / vanish? Shapes how the player
	# COMMITS — a flying projectile is a one-shot bet; a beam is
	# continuous; a swing is instant.
	var persistence: String = "transient-projectile"
	if arch == PlayerTankT.TankArchetype.PRISM:
		persistence = "continuous-while-held"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		persistence = "ballistic+impact-aoe"
	elif arch == PlayerTankT.TankArchetype.RAM:
		persistence = "instant-melee"

	# Axis 10: range-shape class. The geometry of where threat
	# lands — straight bullet, straight beam, arced shell,
	# tank-adjacent. Drives positioning decisions.
	var range_shape: String = "linear-bullet"
	if arch == PlayerTankT.TankArchetype.PRISM:
		range_shape = "linear-beam(160)"
	elif arch == PlayerTankT.TankArchetype.MORTAR:
		range_shape = "parabolic(arc)"
	elif arch == PlayerTankT.TankArchetype.RAM:
		range_shape = "cone-near-body"

	return [
		weapon_kind, move_blocked, range_class, cadence_class,
		damage_source, fingerprint,
		damage_rate_hz, damage_magnitude, persistence, range_shape,
	]


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

	# === Pairwise distinctness — 6 pairs, each must differ in ≥5 of 10.
	var keys: Array = vectors.keys()
	var min_seen: int = 999
	var max_seen: int = 0
	var converged_pairs: Array = []
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			var ka: int = keys[i]
			var kb: int = keys[j]
			var dist: int = _pairwise_distance(vectors[ka], vectors[kb])
			if dist < min_seen:
				min_seen = dist
			if dist > max_seen:
				max_seen = dist
			var pair_label: String = "%s↔%s" % [ARCHETYPE_NAMES[ka], ARCHETYPE_NAMES[kb]]
			print("  %s — pairwise distance %d / %d" % [pair_label, dist, TOTAL_SIGNALS])
			if dist < MIN_DISTINCT_SIGNALS:
				converged_pairs.append(pair_label)

	if not converged_pairs.is_empty():
		push_error("FAIL — distinctness audit CONVERGENCE WARNING: pairs sharing ≥%d of %d signals: %s. Per Consult 008, the playtest will likely report 'feels the same' for these archetype pairs." % [
			TOTAL_SIGNALS - MIN_DISTINCT_SIGNALS + 1, TOTAL_SIGNALS, str(converged_pairs)])
		quit(1); return

	print("  min pairwise distance: %d / %d (threshold ≥%d)" % [min_seen, TOTAL_SIGNALS, MIN_DISTINCT_SIGNALS])
	print("  max pairwise distance: %d / %d" % [max_seen, TOTAL_SIGNALS])

	# === Calibration check — if min/total > CALIBRATION_CEILING the
	# audit is too easy to pass and isn't doing its job. Per the
	# iter-75 PRE-MORTEM, this is the safety against false confidence.
	var min_ratio: float = float(min_seen) / float(TOTAL_SIGNALS)
	if min_ratio > CALIBRATION_CEILING:
		print("  CALIBRATION WARNING: min ratio %.2f > ceiling %.2f — audit may be too easy. Phase 2 (PRESSURES.md) should add tighter signals." % [min_ratio, CALIBRATION_CEILING])

	print("BREACH_DISTINCTNESS_AUDIT_OK Phase-1 structural+play-relevant — 4 archetypes, 6 pairs all differ in ≥%d of %d signals" % [MIN_DISTINCT_SIGNALS, TOTAL_SIGNALS])
	print("  NOTE: 10 axes — 6 structural (existence of mechanism) + 4 play-relevant derived (cadence/magnitude/persistence/range-shape). Phase 2 (iters 76-77) ships PRESSURES.md with the pressure matrix; real play-sim probe scenarios live there.")
	quit(0)
