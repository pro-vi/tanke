extends Area2D

# Arc-4 breach mode: field depot. Combat-pause safe-gate between depth
# bands per CONSULT §9 constraint 1 ("no upgrade choices during active
# combat — all RPG choice happens at field depots / safe gates").
#
# Iter 5: schema-only (pause on entry).
# Iter 9: 3-choice upgrade catalog + next-band preview. Per CONSULT 001
# Q2 — "options legible in <5s, no scrolling/build tree/stat salad".
# Three discrete upgrade kinds (UpgradeKind enum), each surfacing as a
# verb (refill / expand). All pass the C8 sentence test.

const LoadoutT = preload("res://scripts/Loadout.gd")

enum UpgradeKind {
	HE_REFILL_2,        # +2 HE reserve (capped at max_he_reserve)
	HEAT_REFILL_1,      # +1 HEAT reserve (capped at max_heat_reserve)
	HE_MAX_EXPAND_2,    # +2 to max_he_reserve, then refill 2 (immediate effect)
}

signal depot_entered(depot: Node)
signal depot_exited(depot: Node)
signal depot_picked(depot: Node, kind: int)

@export var depot_name: String = ""
@export var band_name_next: String = ""  # the band the player previews on entry
@export var next_band_hint: String = ""  # short pressure-cue text (≤4 words)

# Iter 9: 3 inline choices. Each is a UpgradeKind + a human label that
# passes the C8 sentence test ("helps me climb through ___ by changing
# how I use ___"). Defaults are tutorial-choke depot defaults.
@export var choice_a_kind: UpgradeKind = UpgradeKind.HE_REFILL_2
@export var choice_a_label: String = "+2 HE  (open brick lanes)"
@export var choice_b_kind: UpgradeKind = UpgradeKind.HEAT_REFILL_1
@export var choice_b_label: String = "+1 HEAT  (anti-armor)"
@export var choice_c_kind: UpgradeKind = UpgradeKind.HE_MAX_EXPAND_2
@export var choice_c_label: String = "+2 HE cap  (deeper run)"

# Player loadout reference captured on entry; consumed by apply_choice.
# Cleared on exit. Avoids the depot needing to know about PlayerTank.gd
# directly (Layer-2 substrate stays untouched).
var _player_loadout: LoadoutT = null
var _picked: bool = false


func _ready() -> void:
	# Depot must run while the scene tree is paused so body_exited can fire.
	process_mode = Node.PROCESS_MODE_ALWAYS
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if not _is_player(body):
		return
	get_tree().paused = true
	_picked = false
	# Capture loadout if the body has one. Duck-typed.
	if body.has_method("get") and "loadout" in body:
		_player_loadout = body.loadout
	depot_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	get_tree().paused = false
	_player_loadout = null
	depot_exited.emit(self)


# Iter 9: poll keys 1/2/3 while paused. Depot runs with PROCESS_MODE_ALWAYS
# so _process fires during pause. Single-pick semantics: once picked,
# `_picked` blocks repeat application until body_exited resets.
func _process(_delta: float) -> void:
	if _player_loadout == null or _picked:
		return
	if Input.is_physical_key_pressed(KEY_1):
		apply_choice(1)
	elif Input.is_physical_key_pressed(KEY_2):
		apply_choice(2)
	elif Input.is_physical_key_pressed(KEY_3):
		apply_choice(3)


# Apply a 1-based choice index. Public for harness invocation
# (test_breach_depot_choice.gd bypasses raw input polling).
func apply_choice(idx: int) -> void:
	if _player_loadout == null or _picked:
		return
	var kind: int
	match idx:
		1: kind = choice_a_kind
		2: kind = choice_b_kind
		3: kind = choice_c_kind
		_: return
	match kind:
		UpgradeKind.HE_REFILL_2:
			_player_loadout.refill_he(2)
		UpgradeKind.HEAT_REFILL_1:
			_player_loadout.refill_heat(1)
		UpgradeKind.HE_MAX_EXPAND_2:
			_player_loadout.max_he_reserve += 2
			_player_loadout.refill_he(2)
	_picked = true
	depot_picked.emit(self, kind)


func _is_player(body: Node) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	if body.has_method("_on_PlayerTank_shoot"):
		return true
	return false
