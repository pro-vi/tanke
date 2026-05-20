class_name RunRecap
extends RefCounted

# Arc-4 breach mode: death attribution. CONSULT 000 named this the
# "paired omission" alongside depots. CONSULT §9 constraint 6: "every
# run produces a death reason tied to resource/build/route — not 'got
# overwhelmed'."
#
# Owned by PlayerTank (created per-run when breach mode is active).
# record_shot() ticks during play; capture_death() snapshots on death;
# format() renders the recap text.

const Bullet = preload("res://scripts/Bullet.gd")

# Captured at death:
var depth_reached: int = 0
var killing_band: String = ""        # the breach band the player died in
var killing_pressure: String = ""    # that band's dominant_pressure text
var killer: String = "shell impact"  # what dealt the fatal blow
var he_reserve_at_death: int = 0
var heat_reserve_at_death: int = 0
var captured: bool = false

# Ticked during the run:
var shells_fired: Dictionary = {
	Bullet.SHELL_CLASS_AP: 0,
	Bullet.SHELL_CLASS_HE: 0,
	Bullet.SHELL_CLASS_HEAT: 0,
}


# Called on every player shot. Increments the per-class fired counter.
func record_shot(shell_class: int) -> void:
	if shells_fired.has(shell_class):
		shells_fired[shell_class] += 1
	else:
		shells_fired[shell_class] = 1


# Snapshot run state at death. `band` is a BreachBand (or null if the
# player died outside any band); `loadout` may be null. Defensive on
# both — duck-typed reads.
func capture_death(depth: int, band, loadout) -> void:
	depth_reached = depth
	if band != null:
		killing_band = band.band_name
		killing_pressure = band.dominant_pressure
	if loadout != null:
		he_reserve_at_death = loadout.he_reserve
		heat_reserve_at_death = loadout.heat_reserve
	captured = true


# Total shells fired across all classes.
func total_shells_fired() -> int:
	var t: int = 0
	for k in shells_fired:
		t += shells_fired[k]
	return t


# Derive a build identity tag from the run's shell mix (C1/C6 anchor 3
# substrate). Whichever non-AP shell dominated names the build; an
# AP-only run is a "lane sniper" (precise, conservation-minded).
func build_tag() -> String:
	var he: int = shells_fired.get(Bullet.SHELL_CLASS_HE, 0)
	var heat: int = shells_fired.get(Bullet.SHELL_CLASS_HEAT, 0)
	var ap: int = shells_fired.get(Bullet.SHELL_CLASS_AP, 0)
	if he == 0 and heat == 0:
		return "lane sniper"        # AP-only — precision, conservation
	if he >= heat and he >= ap:
		return "rubble plow"        # HE-dominant — breaches terrain
	if heat >= he and heat >= ap:
		return "bunker cracker"     # HEAT-dominant — anti-armor
	return "mixed breacher"


# Render the recap text. Reads as an actionable diagnosis tied to
# resource/build/route (constraint 6) — NOT "got overwhelmed".
func format() -> String:
	if not captured:
		return "RUN RECAP — (no death captured)"
	var ap: int = shells_fired.get(Bullet.SHELL_CLASS_AP, 0)
	var he: int = shells_fired.get(Bullet.SHELL_CLASS_HE, 0)
	var heat: int = shells_fired.get(Bullet.SHELL_CLASS_HEAT, 0)
	return "\n".join([
		"RUN RECAP",
		"  depth reached : %d  (%s band)" % [depth_reached, killing_band],
		"  band pressure : %s" % killing_pressure,
		"  build         : %s" % build_tag(),
		"  killed by     : %s" % killer,
		"  shells fired  : AP %d / HE %d / HEAT %d" % [ap, he, heat],
		"  reserve left  : HE %d / HEAT %d" % [he_reserve_at_death, heat_reserve_at_death],
	])
