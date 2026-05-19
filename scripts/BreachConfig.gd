class_name BreachConfig
extends Resource

# Arc-4 breach mode: depth-band roadmap as a Resource. Encodes the 5-band
# roadmap from loop/breach/BANDS.md. Each band has a distinct terrain
# pressure (constraint 5 from CONSULT §9 — no generic-harder bands).
#
# Used by scripts/ProceduralLevel.gd when breach_mode_enabled=true. When
# breach_mode_enabled=false this resource is never read; arc-2 procedural
# baseline (hash anchor 23d6a2ec3bf2821f… on seed 42) is preserved.

const BreachBandT = preload("res://scripts/BreachBand.gd")

@export var bands: Array[BreachBandT] = []


# Returns the BreachBand active at the given row-depth (rows climbed from
# the player's start), or null if no band covers it.
func band_for_depth(rows_climbed: int) -> BreachBandT:
	for b in bands:
		if b != null and b.contains(rows_climbed):
			return b
	return null


# Returns the count of distinct bands. Used by harness + tests to verify
# C4 anchor cites.
func band_count() -> int:
	return bands.size()
