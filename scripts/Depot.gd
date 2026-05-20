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

# Upgrade catalog (C8 — 5 entries, all affordance/economy verbs, no
# passive %stats). Each passes the sentence test "This upgrade helps me
# climb through ___ by changing how I use ___" — verbatim sentences are
# documented in Loadout.gd's UPGRADE CATALOG block.
enum UpgradeKind {
	HE_REFILL_2,        # +2 HE reserve (capped at max_he_reserve)
	HEAT_REFILL_1,      # +1 HEAT reserve (capped at max_heat_reserve)
	HE_MAX_EXPAND_2,    # +2 to max_he_reserve, then refill 2
	HEAT_MAX_EXPAND_2,  # +2 to max_heat_reserve, then refill 2
	FULL_RESUPPLY,      # refill BOTH reserves to their current caps
	BREACH_DIVIDEND,    # rule-changer: HE breach of >=4 bricks refunds 1 HE
	OVERDRIVE,          # positioning verb: grants the sprint-burst ability
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

# arc-4 iter 40 (Round 6b): when true, the depot draws 3 distinct
# upgrade kinds from the catalog per run (deterministic from the run
# seed + this depot's depth) instead of the fixed choice_*_kind exports.
# Default false preserves the fixed-choice path (and the harnesses).
@export var randomize_offers: bool = false

# Player loadout reference captured on entry; consumed by apply_choice.
# Cleared on exit. Avoids the depot needing to know about PlayerTank.gd
# directly (Layer-2 substrate stays untouched).
var _player_loadout: LoadoutT = null
var _picked: bool = false
var _rolled_kinds: Array[int] = []  # arc-4 iter 40: drawn offers (lazy)


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
	# iter 29: show the depot UI panel — the safe-gate is the only place
	# the player reads upgrade choices (CONSULT §9 constraint 1).
	_show_panel()
	depot_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	get_tree().paused = false
	_player_loadout = null
	_hide_panel()
	depot_exited.emit(self)


# iter 29: populate the UI panel from the depot's choice labels +
# next-band hint, then show it. Defensive — the panel is optional
# (harness-instantiated depots may lack the UILayer).
func _show_panel() -> void:
	var layer: CanvasLayer = get_node_or_null("UILayer") as CanvasLayer
	if layer == null:
		return
	_set_panel_label("Panel/NextBand", "next: " + _resolve_next_band_hint())
	_set_panel_label("Panel/ChoiceA", "1: " + _choice_label(1))
	_set_panel_label("Panel/ChoiceB", "2: " + _choice_label(2))
	_set_panel_label("Panel/ChoiceC", "3: " + _choice_label(3))
	layer.visible = true


func _hide_panel() -> void:
	var layer: CanvasLayer = get_node_or_null("UILayer") as CanvasLayer
	if layer != null:
		layer.visible = false


func _set_panel_label(path: String, text: String) -> void:
	var layer: CanvasLayer = get_node_or_null("UILayer") as CanvasLayer
	if layer == null:
		return
	var lbl: Label = layer.get_node_or_null(path) as Label
	if lbl != null:
		lbl.text = text


# arc-4 iter 39 (Round 6a): with per-run band-order shuffle the static
# next_band_hint @export is no longer reliable. Resolve the actual next
# band from the level's (shuffled) breach_config + this depot's depth.
# Falls back to the static hint when the level context is absent (e.g.
# a harness-instantiated depot with no ProceduralLevel parent).
func _resolve_next_band_hint() -> String:
	var lvl: Node = get_parent()
	if lvl == null or not ("breach_config" in lvl) or lvl.breach_config == null:
		return next_band_hint
	if not lvl.has_method("_rows_climbed_at_y"):
		return next_band_hint
	var depot_depth: int = lvl._rows_climbed_at_y(global_position.y)
	var nxt = lvl.breach_config.band_for_depth(depot_depth + 1)
	if nxt == null or nxt.band_name == "":
		return next_band_hint
	return nxt.band_name.replace("_", " ")


# arc-4 iter 40 (Round 6b): roll this depot's 3 upgrade offers — 3
# distinct UpgradeKinds drawn from the 7-entry catalog. Deterministic
# from the run seed + this depot's depth (so each depot offers a
# different set and a run stays reproducible). Rolled once, lazily, on
# first need — by then the level's _ready has resolved level_seed.
func _ensure_rolled() -> void:
	if not randomize_offers or not _rolled_kinds.is_empty():
		return
	var seed_val: int = 0
	var lvl: Node = get_parent()
	if lvl != null and "level_seed" in lvl:
		seed_val = int(lvl.level_seed)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val + int(global_position.y)
	var pool: Array[int] = [
		UpgradeKind.HE_REFILL_2, UpgradeKind.HEAT_REFILL_1,
		UpgradeKind.HE_MAX_EXPAND_2, UpgradeKind.HEAT_MAX_EXPAND_2,
		UpgradeKind.FULL_RESUPPLY, UpgradeKind.BREACH_DIVIDEND,
		UpgradeKind.OVERDRIVE,
	]
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var t: int = pool[i]
		pool[i] = pool[j]
		pool[j] = t
	_rolled_kinds = [pool[0], pool[1], pool[2]]


# The UpgradeKind for a 1-based choice index. Randomized depots draw
# from the rolled set; fixed depots use the choice_*_kind exports.
func _choice_kind(idx: int) -> int:
	if randomize_offers:
		_ensure_rolled()
		if idx >= 1 and idx <= _rolled_kinds.size():
			return _rolled_kinds[idx - 1]
	match idx:
		2: return choice_b_kind
		3: return choice_c_kind
	return choice_a_kind


# The panel label for a 1-based choice index. Randomized depots derive
# the label from the rolled kind; fixed depots use the choice_*_label
# exports.
func _choice_label(idx: int) -> String:
	if randomize_offers:
		return _label_for_kind(_choice_kind(idx))
	match idx:
		2: return choice_b_label
		3: return choice_c_label
	return choice_a_label


# Human label per UpgradeKind — used when a depot's offers are rolled.
# Each phrasing is an economy VERB, not a %stat (CONSULT §9 #7).
func _label_for_kind(kind: int) -> String:
	match kind:
		UpgradeKind.HE_REFILL_2: return "+2 HE  (open brick lanes)"
		UpgradeKind.HEAT_REFILL_1: return "+1 HEAT  (crack armor)"
		UpgradeKind.HE_MAX_EXPAND_2: return "+2 HE cap  (deeper HE economy)"
		UpgradeKind.HEAT_MAX_EXPAND_2: return "+2 HEAT cap  (deeper HEAT economy)"
		UpgradeKind.FULL_RESUPPLY: return "Full resupply  (recover all shells)"
		UpgradeKind.BREACH_DIVIDEND: return "Breach Dividend  (HE clusters refund)"
		UpgradeKind.OVERDRIVE: return "Overdrive  (sprint-burst verb)"
	return "upgrade"


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
	if idx < 1 or idx > 3:
		return
	var kind: int = _choice_kind(idx)
	apply_upgrade(kind, _player_loadout)
	_picked = true
	# iter 29: pick locked — clear the panel so the player reads "done"
	# and moves on (depot dwell stays short).
	_hide_panel()
	depot_picked.emit(self, kind)


# Apply one UpgradeKind effect to a loadout. Public so the harness can
# exercise every catalog entry directly. All 5 entries are economy
# verbs — refill / expand capacity / resupply — not passive %stats.
func apply_upgrade(kind: int, loadout) -> void:
	if loadout == null:
		return
	match kind:
		UpgradeKind.HE_REFILL_2:
			loadout.refill_he(2)
		UpgradeKind.HEAT_REFILL_1:
			loadout.refill_heat(1)
		UpgradeKind.HE_MAX_EXPAND_2:
			loadout.max_he_reserve += 2
			loadout.refill_he(2)
		UpgradeKind.HEAT_MAX_EXPAND_2:
			loadout.max_heat_reserve += 2
			loadout.refill_heat(2)
		UpgradeKind.FULL_RESUPPLY:
			loadout.refill_he(loadout.max_he_reserve)
			loadout.refill_heat(loadout.max_heat_reserve)
			loadout.refill_apcr(loadout.max_apcr_reserve)
		UpgradeKind.BREACH_DIVIDEND:
			loadout.breach_dividend = true
		UpgradeKind.OVERDRIVE:
			loadout.has_overdrive = true


func _is_player(body: Node) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	if body.has_method("_on_PlayerTank_shoot"):
		return true
	return false
