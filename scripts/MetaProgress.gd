class_name MetaProgress
extends RefCounted

# Arc-4 breach mode: meta-progression (Round 6e, retiered Round 7d).
# Climbing deep across runs unlocks advanced depot upgrade kinds into
# the depot offer pool — OPTIONS, not power (CONSULT 003: power-creep
# dilutes "what will you spend"). Persistence rides on the existing
# user://stats.cfg best_depth that PlayerTank already saves; this script
# only READS it.
#
# The ladder has 4 rungs (iter 51, playtest finding 3 — "what can be
# unlocked?"). The 5 core economy upgrades (refills / expands /
# resupply) are always available; the 4 rule-changer / verb upgrades
# each unlock at a depth tier. All unlock predicates are pure
# (best-depth in, bool out) so harnesses test them with explicit
# values; best_depth() reads the file.

const _STATS_CFG_PATH: String = "user://stats.cfg"

# Depth thresholds at which each advanced upgrade unlocks into the depot
# pool. The 5 core upgrade kinds are always available.
const UNLOCK_BREACH_DIVIDEND_DEPTH: int = 20
const UNLOCK_OVERDRIVE_DEPTH: int = 40
const UNLOCK_QUICK_SWAP_DEPTH: int = 60
const UNLOCK_STEEL_SALVAGE_DEPTH: int = 80


# The deepest depth ever reached, from the persistent stats file.
# 0 on a fresh save / unreadable file (defensive — never blocks).
static func best_depth() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(_STATS_CFG_PATH) != OK:
		return 0
	return int(cfg.get_value("run", "best_depth", 0))


static func breach_dividend_unlocked(best: int) -> bool:
	return best >= UNLOCK_BREACH_DIVIDEND_DEPTH


static func overdrive_unlocked(best: int) -> bool:
	return best >= UNLOCK_OVERDRIVE_DEPTH


static func quick_swap_unlocked(best: int) -> bool:
	return best >= UNLOCK_QUICK_SWAP_DEPTH


static func steel_salvage_unlocked(best: int) -> bool:
	return best >= UNLOCK_STEEL_SALVAGE_DEPTH


# The unlock ladder as ordered data — one dict {depth, name} per rung,
# shallowest first. Drives the codex unlock-ladder display + harness.
static func unlock_ladder() -> Array:
	return [
		{"depth": UNLOCK_BREACH_DIVIDEND_DEPTH, "name": "DIVIDEND"},
		{"depth": UNLOCK_OVERDRIVE_DEPTH, "name": "OVERDRIVE"},
		{"depth": UNLOCK_QUICK_SWAP_DEPTH, "name": "SWAP"},
		{"depth": UNLOCK_STEEL_SALVAGE_DEPTH, "name": "SALVAGE"},
	]


# arc-4 iter 68 (Round 9f): tank archetype unlocks. DEFAULT (value 0)
# is always unlocked; PRISM/MORTAR/RAM unlock at depth tiers (mirroring
# the iter-51 4-tier upgrade ladder). The int values match the
# PlayerTank.TankArchetype enum (DEFAULT=0/PRISM=1/MORTAR=2/RAM=3) —
# defined here as ints to avoid a circular preload with PlayerTank.gd.
const UNLOCK_PRISM_DEPTH: int = 20
const UNLOCK_MORTAR_DEPTH: int = 40
const UNLOCK_RAM_DEPTH: int = 60
const _ARCHETYPE_DEFAULT: int = 0
const _ARCHETYPE_PRISM: int = 1
const _ARCHETYPE_MORTAR: int = 2
const _ARCHETYPE_RAM: int = 3


static func prism_unlocked(best: int) -> bool:
	return best >= UNLOCK_PRISM_DEPTH


static func mortar_unlocked(best: int) -> bool:
	return best >= UNLOCK_MORTAR_DEPTH


static func ram_unlocked(best: int) -> bool:
	return best >= UNLOCK_RAM_DEPTH


# arc-4 iter 098 (P2-9 fix from code-review-iter-090): companion
# to `unlock_ladder()` (which lists the 4 depot-upgrade rungs).
# `archetype_ladder()` lists the 3 archetype-unlock rungs.
# Consumers (HUD codex, depot panel) needing the full unlock
# state should render BOTH ladders.
static func archetype_ladder() -> Array:
	return [
		{"depth": UNLOCK_PRISM_DEPTH, "name": "PRISM"},
		{"depth": UNLOCK_MORTAR_DEPTH, "name": "MORTAR"},
		{"depth": UNLOCK_RAM_DEPTH, "name": "RAM"},
	]


# Ordered list of unlocked TankArchetype values (ints) for a given
# best-depth — DEFAULT (always) followed by tier-unlocked archetypes.
# PlayerTank's start-pick screen indexes into this list (key 1 → first
# unlocked, etc.).
static func unlocked_archetypes(best: int) -> Array:
	var out: Array = [_ARCHETYPE_DEFAULT]
	if prism_unlocked(best):
		out.append(_ARCHETYPE_PRISM)
	if mortar_unlocked(best):
		out.append(_ARCHETYPE_MORTAR)
	if ram_unlocked(best):
		out.append(_ARCHETYPE_RAM)
	return out
