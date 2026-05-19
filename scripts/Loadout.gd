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
