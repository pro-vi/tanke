class_name MetaProgress
extends RefCounted

# Arc-4 breach mode: meta-progression (Round 6e). Climbing deep across
# runs unlocks advanced depot upgrade kinds into the depot offer pool —
# OPTIONS, not power (CONSULT 003: power-creep dilutes "what will you
# spend"). Persistence rides on the existing user://stats.cfg best_depth
# that PlayerTank already saves; this script only READS it.
#
# All unlock predicates are pure (best-depth in, bool out) so harnesses
# test them with explicit values; best_depth() reads the file.

const _STATS_CFG_PATH: String = "user://stats.cfg"

# Depth thresholds at which each advanced rule-changer unlocks into the
# depot pool. The 7 core upgrade kinds are always available.
const UNLOCK_QUICK_SWAP_DEPTH: int = 40
const UNLOCK_STEEL_SALVAGE_DEPTH: int = 80


# The deepest depth ever reached, from the persistent stats file.
# 0 on a fresh save / unreadable file (defensive — never blocks).
static func best_depth() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(_STATS_CFG_PATH) != OK:
		return 0
	return int(cfg.get_value("run", "best_depth", 0))


static func quick_swap_unlocked(best: int) -> bool:
	return best >= UNLOCK_QUICK_SWAP_DEPTH


static func steel_salvage_unlocked(best: int) -> bool:
	return best >= UNLOCK_STEEL_SALVAGE_DEPTH
