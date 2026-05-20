class_name Loadout
extends Resource

# Arc-4 breach mode: player loadout state. AP is unlimited (baseline
# capability — like vanilla BC). HE + HEAT are *finite breach
# resources* — the atomic verb of breach economy per CONSULT 001:
# "no player has yet sacrificed one resource to alter one route".
#
# Depots refill these (iter 9+). Without finite reserves, breach
# economy isn't an economy — it's just shell variety. The exhaustion
# point creates the tradeoff CONSULT §9 names ("what are you willing
# to spend to open the next vertical lane?").

const Bullet = preload("res://scripts/Bullet.gd")

@export var he_reserve: int = 0       # finite; spent on HE fire
@export var heat_reserve: int = 0     # finite; spent on HEAT fire
@export var max_he_reserve: int = 6   # cap; depot upgrades extend
@export var max_heat_reserve: int = 3 # cap; depot upgrades extend
# arc-4 iter 24: "Breach Dividend" depot rule-changer (CONSULT 002).
# When true, an HE shot that breaches >=4 bricks refunds 1 HE (capped
# at max_he_reserve). Default false — granted only by the depot upgrade.
@export var breach_dividend: bool = false
# arc-4 iter 28: "Overdrive" depot upgrade — grants the sprint-burst
# positioning verb (PlayerTank reads this). The open_killbox band's
# answer is facing-aware positioning; OVERDRIVE is its catalog entry.
@export var has_overdrive: bool = false


# Returns true if the player can fire the given shell class. AP is
# always allowed (baseline); HE/HEAT require positive reserve.
func can_fire(shell_class: int) -> bool:
	if shell_class == Bullet.SHELL_CLASS_AP:
		return true
	if shell_class == Bullet.SHELL_CLASS_HE:
		return he_reserve > 0
	if shell_class == Bullet.SHELL_CLASS_HEAT:
		return heat_reserve > 0
	return false


# Decrement reserve for a shell. AP no-ops. Returns the *actual* shell
# fired — if the requested shell is out of reserve, falls back to AP
# (consume nothing; the player wasted a frame on an empty mag).
func consume(shell_class: int) -> int:
	if shell_class == Bullet.SHELL_CLASS_HE:
		if he_reserve > 0:
			he_reserve -= 1
			return Bullet.SHELL_CLASS_HE
		return Bullet.SHELL_CLASS_AP
	if shell_class == Bullet.SHELL_CLASS_HEAT:
		if heat_reserve > 0:
			heat_reserve -= 1
			return Bullet.SHELL_CLASS_HEAT
		return Bullet.SHELL_CLASS_AP
	return Bullet.SHELL_CLASS_AP


func refill_he(amount: int) -> void:
	he_reserve = min(max_he_reserve, he_reserve + amount)


func refill_heat(amount: int) -> void:
	heat_reserve = min(max_heat_reserve, heat_reserve + amount)


# === UPGRADE CATALOG (C8) ===========================================
# The 5 depot upgrades (Depot.gd UpgradeKind enum) all mutate this
# Loadout. Every entry is an economy VERB — refill / expand capacity /
# resupply — not a passive %stat (CONSULT §9 constraint 7). Each passes
# the sentence test "This upgrade helps me climb through ___ by
# changing how I use ___" — cited verbatim:
#
#   HE_REFILL_2      → refill_he(2)
#     "...climb through brick mazes by changing how I use HE shells."
#   HEAT_REFILL_1    → refill_heat(1)
#     "...climb through bunker bands by changing how I use HEAT shells."
#   HE_MAX_EXPAND_2  → max_he_reserve += 2; refill_he(2)
#     "...climb through long HE-required stretches by changing how I
#      use my HE economy."
#   HEAT_MAX_EXPAND_2 → max_heat_reserve += 2; refill_heat(2)
#     "...climb through deep bunker chains by changing how I use my
#      HEAT economy."
#   FULL_RESUPPLY    → refill_he(max); refill_heat(max)
#     "...climb through the band after an over-spend by changing how I
#      use a recovery beat."
#   BREACH_DIVIDEND  → breach_dividend = true (rule-changer, not stock)
#     "...climb through brick mazes by changing how I use HE — precise
#      cluster breaches (>=4 bricks) refund their own shell."
#   OVERDRIVE        → has_overdrive = true (positioning verb)
#     "...climb through open killboxes by changing how I use
#      positioning — a speed burst to break flanker sightlines."
#
# Band-pressure coverage (C8 anchor 3 — >=1 upgrade per band):
#   tutorial_choke (brick)   → HE_REFILL_2 / HE_MAX_EXPAND_2
#   brick_maze     (brick)   → BREACH_DIVIDEND
#   bunker_zone    (steel)   → HEAT_REFILL_1 / HEAT_MAX_EXPAND_2
#   open_killbox   (position)→ OVERDRIVE
#   endgame_mixed  (composed)→ FULL_RESUPPLY
# ====================================================================
