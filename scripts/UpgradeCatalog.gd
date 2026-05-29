extends Node

# Arc-4 Round 23 Phase 1 (iter 197): class-specific upgrade card
# catalog. Data-only module — no scene, no apply logic (that lives
# in PlayerTank apply_card in Phase 3+4). Per the iter-196 blueprint.
#
# Each CardKind enum value pairs with a label + sentence-test
# description + the archetype pool(s) it belongs to. Pools cap at
# 4 entries each for v1 (scope control per blueprint risk register).
#
# Arc-4-owned; not in any Layer 1-4 substrate freeze list.

# All cards across all archetypes share a single enum so apply_card
# can `match` on a single value. Some entries (like HP_PLUS_1) are
# multi-archetype — they appear in multiple pools.
enum CardKind {
	# DEFAULT pool — universal-feeling generalist
	HP_PLUS_1,                  # +1 max_hp (clamped to ceiling)
	FASTER_RELOAD,              # -RELOAD_STEP from GunTimer wait (existing iter-92 mechanic)
	SHELL_CAP_PLUS_1,           # +1 to every shell cap, then refill 1
	MOMENTUM,                   # +20% move speed (permanent for run)

	# PRISM pool — beam improvements
	BEAM_DPS_UP,                # BEAM_DAMAGE_COOLDOWN × 0.7
	BEAM_RANGE_UP,              # BEAM_RANGE × 1.5
	BEAM_PIERCE,                # beam continues past first body (multi-target)
	# PRISM also gets HP_PLUS_1

	# MORTAR pool — lob improvements
	AOE_DAMAGE_UP,              # MortarShell.AOE_DAMAGE +1
	AOE_RADIUS_UP,              # MortarShell.AOE_RADIUS +6
	MORTAR_COOLDOWN_DOWN,       # MORTAR_GUN_COOLDOWN × 0.7
	# MORTAR also gets HP_PLUS_1

	# RAM pool — collision improvements
	SWING_DAMAGE_UP,            # RAM_SWING_DAMAGE +1
	COLLISION_DAMAGE_UP,        # RAM_COLLISION_DAMAGE +1
	SPRINT_DURATION_UP,         # overdrive_burst +0.5
	# RAM also gets HP_PLUS_2 (the "tank" class)
	HP_PLUS_2,                  # +2 max_hp (RAM-exclusive — tank flavor)
}

# Per-archetype card pools. Mirror PlayerTank.TankArchetype enum
# values (DEFAULT=0, PRISM=1, MORTAR=2, RAM=3).
const POOL_DEFAULT: Array[int] = [
	CardKind.HP_PLUS_1,
	CardKind.FASTER_RELOAD,
	CardKind.SHELL_CAP_PLUS_1,
	CardKind.MOMENTUM,
]

const POOL_PRISM: Array[int] = [
	CardKind.BEAM_DPS_UP,
	CardKind.BEAM_RANGE_UP,
	CardKind.BEAM_PIERCE,
	CardKind.HP_PLUS_1,
]

const POOL_MORTAR: Array[int] = [
	CardKind.AOE_DAMAGE_UP,
	CardKind.AOE_RADIUS_UP,
	CardKind.MORTAR_COOLDOWN_DOWN,
	CardKind.HP_PLUS_1,
]

const POOL_RAM: Array[int] = [
	CardKind.SWING_DAMAGE_UP,
	CardKind.COLLISION_DAMAGE_UP,
	CardKind.SPRINT_DURATION_UP,
	CardKind.HP_PLUS_2,
]

# Map: archetype-value → pool. Use `pool_for(archetype)` rather than
# indexing this directly so an out-of-range archetype falls back to
# DEFAULT safely (matches iter-93 P1-3 switch_archetype defense).
const _POOL_BY_ARCHETYPE: Dictionary = {
	0: POOL_DEFAULT,
	1: POOL_PRISM,
	2: POOL_MORTAR,
	3: POOL_RAM,
}


# Return the card pool for the given archetype value, falling back
# to DEFAULT if archetype is out of range.
static func pool_for(archetype: int) -> Array[int]:
	if _POOL_BY_ARCHETYPE.has(archetype):
		return _POOL_BY_ARCHETYPE[archetype]
	return POOL_DEFAULT


# Human-readable short label per CardKind. Used by the pick UI.
static func label_for(kind: int) -> String:
	match kind:
		CardKind.HP_PLUS_1: return "HP +1"
		CardKind.HP_PLUS_2: return "HP +2"
		CardKind.FASTER_RELOAD: return "FASTER RELOAD"
		CardKind.SHELL_CAP_PLUS_1: return "+1 SHELL CAPS"
		CardKind.MOMENTUM: return "MOMENTUM"
		CardKind.BEAM_DPS_UP: return "BEAM DPS +"
		CardKind.BEAM_RANGE_UP: return "BEAM RANGE +"
		CardKind.BEAM_PIERCE: return "BEAM PIERCE"
		CardKind.AOE_DAMAGE_UP: return "AOE DAMAGE +"
		CardKind.AOE_RADIUS_UP: return "AOE RADIUS +"
		CardKind.MORTAR_COOLDOWN_DOWN: return "FASTER LOB"
		CardKind.SWING_DAMAGE_UP: return "SWING DAMAGE +"
		CardKind.COLLISION_DAMAGE_UP: return "COLLISION +"
		CardKind.SPRINT_DURATION_UP: return "LONGER SPRINT"
	return "?"


# One-line sentence-test description per CardKind. Used by the
# pick UI to surface "helps me climb X by changing how I use Y".
static func sentence_for(kind: int) -> String:
	match kind:
		CardKind.HP_PLUS_1: return "survive one more hit"
		CardKind.HP_PLUS_2: return "tank built for impact"
		CardKind.FASTER_RELOAD: return "shoot more, wait less"
		CardKind.SHELL_CAP_PLUS_1: return "carry more spend-ammo"
		CardKind.MOMENTUM: return "outrun the killbox"
		CardKind.BEAM_DPS_UP: return "melt faster per second"
		CardKind.BEAM_RANGE_UP: return "reach across the lane"
		CardKind.BEAM_PIERCE: return "drill through stacked enemies"
		CardKind.AOE_DAMAGE_UP: return "shells hit harder"
		CardKind.AOE_RADIUS_UP: return "wider blast for clusters"
		CardKind.MORTAR_COOLDOWN_DOWN: return "lob more often"
		CardKind.SWING_DAMAGE_UP: return "ramming swings hit harder"
		CardKind.COLLISION_DAMAGE_UP: return "body-checks hurt more"
		CardKind.SPRINT_DURATION_UP: return "sprint window expanded"
	return ""
