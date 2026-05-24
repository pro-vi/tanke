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
const MetaProgressT = preload("res://scripts/MetaProgress.gd")

# Upgrade catalog (C8 — 9 entries, all affordance/economy verbs, no
# passive %stats). Each passes the sentence test "This upgrade helps me
# climb through ___ by changing how I use ___" — verbatim sentences are
# documented in Loadout.gd's UPGRADE CATALOG block.
enum UpgradeKind {
	HE_REFILL_2,        # +2 HE reserve (capped at max_he_reserve)
	HEAT_REFILL_1,      # +1 HEAT reserve (capped at max_heat_reserve)
	HE_MAX_EXPAND_2,    # +2 to max_he_reserve, then refill 2
	HEAT_MAX_EXPAND_2,  # +2 to max_heat_reserve, then refill 2
	FULL_RESUPPLY,      # refill ALL reserves to their current caps
	BREACH_DIVIDEND,    # rule-changer: HE breach of >=4 bricks refunds 1 HE
	OVERDRIVE,          # positioning verb: grants the sprint-burst ability
	QUICK_SWAP,         # rule-changer: shell swaps cost no reload beat
	STEEL_SALVAGE,      # rule-changer: APCR steel-cluster breach refunds APCR
	# arc-4 iter 69 (Round 9g): mid-run archetype switching. Calls
	# PlayerTank.switch_archetype(value) — value matches the
	# TankArchetype enum (PRISM=1, MORTAR=2, RAM=3).
	SWITCH_TO_PRISM,    # archetype swap: become PRISM (beam, stop-and-fire)
	SWITCH_TO_MORTAR,   # archetype swap: become MORTAR (lobbed AoE)
	SWITCH_TO_RAM,      # archetype swap: become RAM (collision + swing + sprint)
	# arc-4 iter 113 (Round 13 Phase 2, C8 anchor 3): closes the
	# tutorial_choke band-coverage gap from iter-112 audit. SCOUT_
	# TELEGRAPH gives the player a perceptual affordance — Light
	# enemies spawn with a warm yellow tint, making them easier to
	# spot and pre-aim. Sentence: "helps me climb tutorial_choke
	# by changing how I see Light scouts."
	SCOUT_TELEGRAPH,
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
# arc-4 iter 69 (Round 9g): player ref captured on entry — used by the
# SWITCH_TO_* upgrades to call switch_archetype on the player. Duck-typed.
var _player: Node = null
var _picked: bool = false
# arc-4 iter 100 (P0-A fix from code-review-iter-100): lifetime
# pick latch. Without this, re-entering a depot resets _picked
# (in _on_body_entered) and allows the same depot's 3 offers to be
# picked again — exploit lets player unboundedly pick
# HE_REFILL_2 / HE_MAX_EXPAND_2 / FULL_RESUPPLY on re-entry.
# Set once in apply_choice; never cleared.
var _lifetime_picked: bool = false
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
	# arc-4 iter 100 (P0-A fix): only reset _picked if this depot
	# hasn't been picked in this run. Re-entering a picked depot
	# stays in "PICKED" state — no second pick possible.
	if not _lifetime_picked:
		_picked = false
	# Capture loadout if the body has one. Duck-typed.
	if body.has_method("get") and "loadout" in body:
		_player_loadout = body.loadout
	# arc-4 iter 69 (Round 9g): capture the player node itself for the
	# SWITCH_TO_* upgrades (which call switch_archetype on it).
	_player = body
	# iter 29: show the depot UI panel — the safe-gate is the only place
	# the player reads upgrade choices (CONSULT §9 constraint 1).
	_show_panel()
	depot_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	get_tree().paused = false
	_player_loadout = null
	_player = null
	_hide_panel()
	depot_exited.emit(self)


# iter 29: populate the UI panel from the depot's choice labels +
# next-band hint, then show it. Defensive — the panel is optional
# (harness-instantiated depots may lack the UILayer).
func _show_panel() -> void:
	var layer: CanvasLayer = get_node_or_null("UILayer") as CanvasLayer
	if layer == null:
		return
	# arc-4 iter 57 (Round 8b): the depot reads as a per-phase reward
	# beat — the Title names the band just cleared (each phase becomes a
	# named milestone, the real fix for "phases don't read"); the
	# choices are a numbered upgrade pick.
	var cleared: String = _resolve_cleared_band_name()
	if cleared != "":
		_set_panel_label("Panel/Title", "— %s CLEARED —" % cleared.to_upper())
	else:
		_set_panel_label("Panel/Title", "— PHASE CLEARED —")
	_set_panel_label("Panel/NextBand", "→  next: " + _resolve_next_band_hint())
	_set_panel_label("Panel/ChoiceA", "[1]  " + _choice_label(1))
	_set_panel_label("Panel/ChoiceB", "[2]  " + _choice_label(2))
	_set_panel_label("Panel/ChoiceC", "[3]  " + _choice_label(3))
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


# arc-4 iter 57 (Round 8b): the band JUST cleared — the band one row
# below this depot's boundary depth. Names the panel's reward header.
# Empty when there is no level context (e.g. a harness-bare depot).
func _resolve_cleared_band_name() -> String:
	var lvl: Node = get_parent()
	if lvl == null or not ("breach_config" in lvl) or lvl.breach_config == null:
		return ""
	if not lvl.has_method("_rows_climbed_at_y"):
		return ""
	var depot_depth: int = lvl._rows_climbed_at_y(global_position.y)
	var cleared = lvl.breach_config.band_for_depth(depot_depth - 1)
	if cleared == null or cleared.band_name == "":
		return ""
	return cleared.band_name.replace("_", " ")


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
	# arc-4 iter 097 (P2-6): pass current archetype to filter out
	# same-archetype SWITCH_TO_* picks (no-op picks).
	var current_arch: int = -1
	if _player != null and is_instance_valid(_player) and "archetype" in _player:
		current_arch = int(_player.archetype)
	var pool: Array[int] = _upgrade_pool(-1, current_arch)
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var t: int = pool[i]
		pool[i] = pool[j]
		pool[j] = t
	_rolled_kinds = [pool[0], pool[1], pool[2]]


# arc-4 iter 45 (Round 6e meta-progression, retiered iter 51 Round 7d):
# the depot offer pool. The 5 core economy upgrade kinds are always
# available; the 4 rule-changer / verb upgrades each unlock at a
# best-depth threshold (MetaProgress) — OPTIONS earned by climbing, not
# power. `best` defaults to the live best-depth; a caller may pass an
# explicit value (harnesses).
func _upgrade_pool(best: int = -1, current_archetype: int = -1) -> Array[int]:
	if best < 0:
		best = MetaProgressT.best_depth()
	# arc-4 iter 097 (P2-6 fix from code-review-iter-090): if the
	# caller passes the player's CURRENT archetype, filter the
	# SWITCH_TO_X entry for that archetype out of the pool — picking
	# it would be a no-op (switch_archetype returns early on
	# value == archetype).
	# 5 core economy upgrades — always available.
	var pool: Array[int] = [
		UpgradeKind.HE_REFILL_2, UpgradeKind.HEAT_REFILL_1,
		UpgradeKind.HE_MAX_EXPAND_2, UpgradeKind.HEAT_MAX_EXPAND_2,
		UpgradeKind.FULL_RESUPPLY,
	]
	# 4 rule-changer / verb upgrades — each unlocks at a depth tier.
	if MetaProgressT.breach_dividend_unlocked(best):
		pool.append(UpgradeKind.BREACH_DIVIDEND)
	if MetaProgressT.overdrive_unlocked(best):
		pool.append(UpgradeKind.OVERDRIVE)
	if MetaProgressT.quick_swap_unlocked(best):
		pool.append(UpgradeKind.QUICK_SWAP)
	if MetaProgressT.steel_salvage_unlocked(best):
		pool.append(UpgradeKind.STEEL_SALVAGE)
	# arc-4 iter 69 (Round 9g): archetype-switch entries — gated on the
	# same MetaProgress tiers as the start-pick screen (PRISM@20,
	# MORTAR@40, RAM@60).
	# arc-4 iter 097 (P2-6): also gate by current_archetype to avoid
	# offering SWITCH_TO_X when X == current.
	if MetaProgressT.prism_unlocked(best) and current_archetype != 1:
		pool.append(UpgradeKind.SWITCH_TO_PRISM)
	if MetaProgressT.mortar_unlocked(best) and current_archetype != 2:
		pool.append(UpgradeKind.SWITCH_TO_MORTAR)
	if MetaProgressT.ram_unlocked(best) and current_archetype != 3:
		pool.append(UpgradeKind.SWITCH_TO_RAM)
	# arc-4 iter 113 (Round 13): SCOUT_TELEGRAPH always-available
	# (no meta-gate; small perceptual affordance for tutorial_choke).
	pool.append(UpgradeKind.SCOUT_TELEGRAPH)
	return pool


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
		UpgradeKind.QUICK_SWAP: return "Quick Swap  (free shell swaps)"
		UpgradeKind.STEEL_SALVAGE: return "Steel Salvage  (APCR clusters refund)"
		UpgradeKind.SWITCH_TO_PRISM: return "Switch to PRISM  (continuous beam)"
		UpgradeKind.SWITCH_TO_MORTAR: return "Switch to MORTAR  (lobbed AoE)"
		UpgradeKind.SWITCH_TO_RAM: return "Switch to RAM  (collision + sprint)"
		UpgradeKind.SCOUT_TELEGRAPH: return "Scout Telegraph  (see Light scouts earlier)"
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
	# arc-4 iter 100 (P0-A fix): set the lifetime latch so re-entry
	# can't reset _picked + offer the same 3 picks again.
	_lifetime_picked = true
	# iter 29: pick locked — clear the panel so the player reads "done"
	# and moves on (depot dwell stays short).
	_hide_panel()
	depot_picked.emit(self, kind)


# Apply one UpgradeKind effect to a loadout. Public so the harness can
# exercise every catalog entry directly. All 9 entries are economy
# verbs — refills, capacity expands, resupply, rule-changers — not
# passive %stats.
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
		UpgradeKind.QUICK_SWAP:
			loadout.quick_swap = true
		UpgradeKind.STEEL_SALVAGE:
			loadout.steel_salvage = true
		# arc-4 iter 69 (Round 9g): SWITCH_TO_* upgrades flip the player's
		# archetype mid-run. value 1=PRISM, 2=MORTAR, 3=RAM (matches
		# PlayerTank.TankArchetype enum).
		# arc-4 iter 093 (P1-5 fix from code-review-iter-090): also
		# `is_instance_valid` check — _player could have been freed
		# by a scene reload or death-restart while the upgrade panel
		# was up, leaving a dangling reference that would crash on
		# has_method().
		UpgradeKind.SWITCH_TO_PRISM:
			if _player != null and is_instance_valid(_player) \
					and _player.has_method("switch_archetype"):
				_player.switch_archetype(1)
		UpgradeKind.SWITCH_TO_MORTAR:
			if _player != null and is_instance_valid(_player) \
					and _player.has_method("switch_archetype"):
				_player.switch_archetype(2)
		UpgradeKind.SWITCH_TO_RAM:
			if _player != null and is_instance_valid(_player) \
					and _player.has_method("switch_archetype"):
				_player.switch_archetype(3)
		UpgradeKind.SCOUT_TELEGRAPH:
			loadout.has_scout_telegraph = true


func _is_player(body: Node) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	if body.has_method("_on_PlayerTank_shoot"):
		return true
	return false
