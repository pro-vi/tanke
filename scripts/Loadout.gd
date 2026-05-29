class_name Loadout
extends Resource

# Arc-4 breach mode: player loadout state. AP is unlimited (baseline
# capability — like vanilla BC). HE, HEAT + APCR are *finite breach
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
@export var apcr_reserve: int = 0     # finite; spent on APCR fire (steel)
@export var max_he_reserve: int = 6   # cap; depot upgrades extend
@export var max_heat_reserve: int = 3 # cap; depot upgrades extend
@export var max_apcr_reserve: int = 4 # cap; the steel-lane budget
# arc-4 iter 24: "Breach Dividend" depot rule-changer (CONSULT 002).
# When true, an HE shot that breaches >=4 bricks refunds 1 HE (capped
# at max_he_reserve). Default false — granted only by the depot upgrade.
@export var breach_dividend: bool = false
# arc-4 iter 28: "Overdrive" depot upgrade — grants the sprint-burst
# positioning verb (PlayerTank reads this). The open_killbox band's
# answer is facing-aware positioning; OVERDRIVE is its catalog entry.
@export var has_overdrive: bool = false
# arc-4 iter 41 (Round 6c) rule-changers — depot upgrades that change
# HOW you climb (CONSULT 003 Q2). quick_swap: shell swaps cost no reload
# beat. steel_salvage: an APCR steel-cluster breach refunds 1 APCR.
@export var quick_swap: bool = false
@export var steel_salvage: bool = false
# arc-4 iter 113 (Round 13 Phase 2, C8 anchor 3): SCOUT_TELEGRAPH —
# closes the tutorial_choke band-coverage gap surfaced by iter-112
# audit. When true, Light enemies spawn with a warm yellow tint so
# the player can see them earlier and pre-aim. Sentence:
# "helps me climb tutorial_choke by changing how I see Light scouts."
@export var has_scout_telegraph: bool = false
# arc-4 iter 116 (Round 14 Phase 2, C8 anchor 3): REAR_GUARD —
# closes the open_killbox band-coverage gap deferred from Round 13.
# When true, an AP shot auto-fires at the closest enemy in the
# rear 90° cone (range REAR_GUARD_RANGE, cooldown REAR_GUARD_
# COOLDOWN) when one enters it. Costs no shell. Sentence:
# "helps me climb open_killbox by changing how I commit to facing
# — rear scouts no longer demand a turn."
@export var has_rear_guard: bool = false

# arc-4 iter 315 (Round 26 Phase B — visual identity sprint activation):
# optional brick tile variant texture. When non-null, BrickBlock instances
# self-discover this via the iter-313 variant_texture override and render
# the variant instead of the canonical sprites_1.png frame 5. Default null
# → arc-2/3 baseline preserved + arc-4 breach mode without explicit variant
# config also preserved. Hash anchor 23d6a2ec3bf2821f bit-identical when
# this field is null.
@export var brick_variant: Texture2D = null


# Returns true if the player can fire the given shell class. AP is
# always allowed (baseline); HE/HEAT require positive reserve.
func can_fire(shell_class: int) -> bool:
	if shell_class == Bullet.SHELL_CLASS_AP:
		return true
	if shell_class == Bullet.SHELL_CLASS_HE:
		return he_reserve > 0
	if shell_class == Bullet.SHELL_CLASS_HEAT:
		return heat_reserve > 0
	if shell_class == Bullet.SHELL_CLASS_APCR:
		return apcr_reserve > 0
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
	if shell_class == Bullet.SHELL_CLASS_APCR:
		if apcr_reserve > 0:
			apcr_reserve -= 1
			return Bullet.SHELL_CLASS_APCR
		return Bullet.SHELL_CLASS_AP
	return Bullet.SHELL_CLASS_AP


func refill_he(amount: int) -> void:
	he_reserve = min(max_he_reserve, he_reserve + amount)


func refill_heat(amount: int) -> void:
	heat_reserve = min(max_heat_reserve, heat_reserve + amount)


func refill_apcr(amount: int) -> void:
	apcr_reserve = min(max_apcr_reserve, apcr_reserve + amount)


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
#   FULL_RESUPPLY    → refill_he(max); refill_heat(max); refill_apcr(max)
#     "...climb through the band after an over-spend by changing how I
#      use a recovery beat."
#   BREACH_DIVIDEND  → breach_dividend = true (rule-changer, not stock)
#     "...climb through brick mazes by changing how I use HE — precise
#      cluster breaches (>=4 bricks) refund their own shell."
#   OVERDRIVE        → has_overdrive = true (positioning verb)
#     "...climb through open killboxes by changing how I use
#      positioning — a speed burst to break flanker sightlines."
#   QUICK_SWAP       → quick_swap = true (rule-changer, iter 41)
#     "...climb through pressure-mixed bands by changing how I use
#      shell-swapping — free swaps, no reload beat, to adapt mid-fight."
#   STEEL_SALVAGE    → steel_salvage = true (rule-changer, iter 41)
#     "...climb through steel-walled bunkers by changing how I use
#      APCR — opening a steel cluster refunds its own shell."
#
# Band-pressure coverage (C8 anchor 3 — >=1 upgrade per band):
#   tutorial_choke (brick)   → HE_REFILL_2 / HE_MAX_EXPAND_2
#   brick_maze     (brick)   → BREACH_DIVIDEND
#   bunker_zone    (steel)   → HEAT_REFILL_1 / HEAT_MAX_EXPAND_2
#   open_killbox   (position)→ OVERDRIVE
#   endgame_mixed  (composed)→ FULL_RESUPPLY
#
# arc-4 iter 34: APCR (the 4th shell — steel breacher) is refilled by
# FULL_RESUPPLY. A dedicated APCR depot upgrade is a Round-5 follow-up.
# ====================================================================
