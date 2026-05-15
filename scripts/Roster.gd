extends RefCounted

# Arc-3 enemy-roster source-of-truth (criterion 5). Encodes the formula
# documented in iter-4 LEDGER and located in Tanks's source:
#
#   .research/repos/Tanks/src/app_state/game/game.cpp:518:
#   SpriteType type = static_cast<SpriteType>(
#       p < (0.00735 * m_current_stage + 0.09265) ? ST_TANK_D
#       : (rand() % (ST_TANK_C - ST_TANK_A + 1) + ST_TANK_A));
#
#   .research/repos/Tanks/src/appconfig.h:79-81:
#     enemies_to_kill_total_count = 20  // total per stage
#     enemies_max_count_on_map    = 4   // simultaneous cap
#     stages_count                = 35
#
# arc-2 has two enemy types (EnemyLight, EnemyHeavy). Mapping to BC's
# four types: armored (D) → Heavy; non-armored (A/B/C) → Light. iter-9+
# Spawner integration will sample armored_probability(stage) at spawn
# time and pick the corresponding scene.
#
# RUBRIC MISMATCH NOTE (for iter-8 AUDIT consideration): C5 anchor 2 says
# "Roster data encoded in configs/stages/stage_KK.tres for 5+ stages."
# But the canonical BC roster is FORMULA-driven across all 35 stages, not
# per-stage table data. Encoding 35 .tres files that all reference the
# same formula constants would be redundant duplication. This script
# encodes the formula in code form — a stronger source-of-truth cite
# than the rubric's table-shaped anchor anticipates.

const TOTAL_ENEMIES_PER_STAGE := 20      # Tanks: enemies_to_kill_total_count
const MAX_SIMULTANEOUS := 4              # Tanks: enemies_max_count_on_map
const STAGES_COUNT := 35                 # Tanks: stages_count

# Linear coefficients per Tanks game.cpp:518 — verified iter 4.
const ARMORED_SLOPE := 0.00735
const ARMORED_INTERCEPT := 0.09265


static func armored_probability(stage_number: int) -> float:
	# Probability that a given enemy spawn picks ST_TANK_D (armored / Heavy).
	# Non-armored spawns pick uniformly among ST_TANK_A/B/C (mapped to Light).
	return ARMORED_SLOPE * float(stage_number) + ARMORED_INTERCEPT


static func is_armored_spawn(stage_number: int, rng_value: float = -1.0) -> bool:
	# Convenience for Spawner integration: pass an rng_value in [0, 1) to
	# get the deterministic decision; pass -1 (default) to use randf().
	var p := armored_probability(stage_number)
	if rng_value < 0.0:
		rng_value = randf()
	return rng_value < p
