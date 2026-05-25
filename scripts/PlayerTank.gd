extends CharacterBody2D

# arc-4 breach mode: PlayerTank carries a Loadout (finite HE/HEAT
# reserves) + a current_shell cursor cycled via KEY_TAB. Default
# loadout = null preserves arc-2/3 baseline behavior (unlimited AP).
# Sanctioned substrate write per PROMPT §SUBSTRATE FREEZE +
# CONSULT 001 "no player has yet sacrificed one resource to alter one
# route — that is the atomic verb".
const BulletT = preload("res://scripts/Bullet.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const RunRecapT = preload("res://scripts/RunRecap.gd")
const MetaProgressT = preload("res://scripts/MetaProgress.gd")

# arc-4 iter 146 (Pro Consult 011 step 4/5): per-archetype atlas. PRISM row 0,
# MORTAR row 1, RAM row 2; each row 8 cells matching TankSprite.gd dir_set
# layout (U=[0,1], L=[2,3], D=[4,5], R=[6,7]). Default texture stays
# sprites_0.png so arc-2/3 mode + DEFAULT archetype = bit-identical.
const ARCHETYPE_ATLAS_TEX = preload("res://img/archetype_sprites.png")
const DEFAULT_ATLAS_TEX = preload("res://img/sprites_0.png")
# Per-archetype base frame in the archetype atlas (hframes=16, vframes=3).
# DEFAULT keeps frame_base=0 against sprites_0.png (existing behavior).
const _ARCHETYPE_FRAME_BASE = {
	TankArchetype.PRISM: 0,
	TankArchetype.MORTAR: 16,
	TankArchetype.RAM: 32,
}

# arc-4 iter 64 (Round 9b): tank archetype enum — distinct personalities
# the user named in playtest-4 (Red Alert / Into the Breach references).
# Per-archetype behaviour lands in 9c (PRISM beam), 9d (MORTAR lob), 9e
# (RAM collision + swing). DEFAULT preserves the current breach behavior
# bit-identically.
enum TankArchetype { DEFAULT, PRISM, MORTAR, RAM }

# arc-4: shoot signal carries the chosen shell_class. Default in any
# emit-site that doesn't override = SHELL_CLASS_AP (= 0), preserving
# arc-2/3 callers bit-identically.
signal shoot(bullet_scene: PackedScene, pos: Vector2, dir: int, shell_class: int)
signal hp_changed(new_hp: int, max_hp: int)
signal died

@export var speed: int = 32
# iter 82: shield-pickup invulnerability window. take_damage early-returns
# while _shield_timer > 0.
var _shield_timer: float = 0.0
@export var gun_cooldown: int = 100
@export var Bullet: PackedScene
@export var max_hp: int = 3
@export var damage_iframes: float = 0.6
@export var forest_hidden_alpha: float = 0.3
@export var forest_visible_alpha: float = 1.0
# Hit flash (iter 19) — red pulse on damage + alternating blink during iframes
@export var hit_flash_color: Color = Color(1.6, 0.3, 0.3, 1.0)
# Camera shake (iter 42) — kicks Camera2D.offset on non-kill damage. Independent
# of Camera2D.position which is driven by PlayerTank's RemoteTransform2D.
@export var screen_shake_magnitude: float = 3.0  # px at 320×240
@export var screen_shake_duration: float = 0.25
@export var screen_shake_steps: int = 5
# arc-4: optional Loadout. null = arc-2/3 baseline (unlimited AP).
# When set, current_shell cycles via KEY_TAB and HE/HEAT consume reserves.
@export var loadout: LoadoutT = null
# arc-4 iter 64 (Round 9b): chosen tank archetype for this run. DEFAULT
# = the existing breach behavior (bit-identical). PRISM / MORTAR / RAM
# gate per-archetype code paths in 9c/9d/9e.
@export var archetype: int = TankArchetype.DEFAULT
# arc-4 iter 27 (C3 anchor 4): shell-swap reload cost. After a swap the
# tank cannot fire for shell_swap_cost seconds — pre-commitment under
# reload pressure (CONSULT §2 "the interesting WoT idea"). Only ever
# armed in breach mode (a swap requires a loadout); arc-2/3 unaffected.
@export var shell_swap_cost: float = 0.5
# arc-4 iter 28 (C8 anchor 3): OVERDRIVE sprint burst. The open_killbox
# band's positioning answer — a speed burst (KEY_SHIFT) to break flanker
# sightlines. Granted by the depot OVERDRIVE upgrade (loadout.has_overdrive).
@export var overdrive_mult: float = 1.6      # speed × this during a burst
@export var overdrive_burst: float = 1.0     # burst duration (s)
@export var overdrive_cooldown: float = 2.5  # cooldown after a burst (s)

var current_shell: int = 0  # = BulletT.SHELL_CLASS_AP; cycled via KEY_TAB
var _tab_was_pressed: bool = false
var _swap_cooldown: float = 0.0  # >0 = mid reload beat, _fire blocked
var _overdrive_timer: float = 0.0   # >0 = sprint burst active
var _overdrive_cd: float = 0.0      # >0 = burst on cooldown
var _shift_was_pressed: bool = false
# arc-4: death-attribution recap. Created per-run in _ready when breach
# mode is active (loadout != null). Null in arc-2/3 — those code paths
# never touch run_recap, so behavior stays bit-identical.
var run_recap = null
# arc-4 iter 109 (Round 12 Gap 2): the source string for the most
# recent damage event, set by `set_last_damage_source` just before
# `take_damage`. Read in `_die()` to stamp `run_recap.killer`.
# Empty string = no attribution → falls back to "shell impact".
var _last_damage_source: String = ""

@onready var sprite: Sprite2D = $Sprite2D

var _grass_tilemap: TileMapLayer = null
var _flash_tween: Tween = null
var _shake_tween: Tween = null
var _camera: Camera2D = null
var _is_flashing: bool = false

var direction: int = Constants.Dir.U
var grid: Vector2 = Vector2(4, 4)  # minimum grid size to snap to when turning
var can_shoot: bool = true
var hp: int = 0
var _iframe_timer: float = 0.0
var _dead: bool = false
var _restart_armed: bool = false
var _hp_label: Label
# arc-4 iter 35: breach-mode shell panel (4 slots — AP/HE/HEAT/APCR).
var _shell_panel: ColorRect = null
var _shell_slot_classes: Array[int] = []
var _shell_slot_bgs: Array[ColorRect] = []
var _shell_slot_chips: Array[ColorRect] = []
var _shell_slot_labels: Array[Label] = []
var _shell_codex: ColorRect = null  # arc-4 iter 36: run-start shell primer
# arc-4 iter 116 (Round 14 Phase 2): REAR_GUARD cooldown timer +
# tunables. _rear_guard_cd ticks down to 0.0; when 0.0 + an enemy
# is in the rear cone + loadout has the flag, fires an AP backward
# at no shell cost, then re-arms the cooldown.
const REAR_GUARD_RANGE: float = 96.0          # max distance to scan
const REAR_GUARD_COOLDOWN: float = 2.5        # seconds between auto-fires
const REAR_GUARD_CONE_COS: float = 0.707      # cos(45°) → 90° total cone
var _rear_guard_cd: float = 0.0
# arc-4 iter 102 (P1-C fix from code-review-iter-100): track the live
# band-arrival banner so a Y-boundary-oscillating player can't stack
# Labels indefinitely. Each new band crossing frees the prior banner
# before spawning the next.
var _band_banner: Label = null
# arc-4 iter 102 (P1-D fix): default + flash colors for the shell-panel
# BG. When _fire is rejected by _swap_cooldown > 0, the panel briefly
# flashes warm-orange — making the input rejection visible. Preserves
# the iter-27 swap-cost design (the reload beat IS the commitment cost);
# only the silent-drop UX failure is fixed.
const SHELL_PANEL_BG_DEFAULT: Color = Color(0.07, 0.07, 0.09, 0.82)
const SHELL_PANEL_BG_REJECTED: Color = Color(1.0, 0.35, 0.15, 0.95)
const SHELL_PANEL_REJECT_FADE_S: float = 0.18
# arc-4 iter 50 (Round 7c): persistent run-route strip — one cell per
# depth band, in this run's shuffled order, the current band highlighted.
var _route_panel: ColorRect = null
var _route_cell_bgs: Array[ColorRect] = []
var _route_cell_labels: Array[Label] = []
var _route_bands: Array = []
# arc-4 iter 104 (P2-C fix from code-review-iter-100): highest band
# idx ever visited this run. Cells <= this idx (excluding the
# current cell) keep their "cleared" tint, even after the player
# retreats to a lower band. -1 = no band visited yet.
var _route_max_cleared_idx: int = -1
# arc-4 iter 56 (Round 8a): XP + level-up — the roguelite power curve
# (playtest-3). Breach-mode only (gated on loadout != null).
const XP_PER_KILL: int = 12
const XP_PER_DEPTH_ROW: int = 3
const XP_BASE: int = 60       # XP to reach level 2
const XP_STEP: int = 30       # +XP_STEP to each successive threshold
const RELOAD_STEP: float = 0.1
const RELOAD_MIN: float = 0.35
var _xp: int = 0
var _level: int = 1
var _xp_to_next: int = XP_BASE
var _xp_kills_counted: int = 0
var _xp_depth_counted: int = 0
var _spawner: Node = null
var _xp_bar_bg: ColorRect = null
var _xp_bar_fg: ColorRect = null
var _level_label: Label = null
# arc-4 iter 59 (Round 8d): shields last longer in breach mode.
const BREACH_SHIELD_DURATION: float = 6.0
var _shield_label: Label = null
# arc-4 iter 65 (Round 9c): PRISM Tank beam — continuous line-cast,
# damages first body, stop-and-fire. Built only when archetype=PRISM.
const BEAM_RANGE: float = 160.0
# arc-4 iter 193 (PLAYTEST-FIX): double PRISM start DPS per user
# direction — was 0.25 (4 ticks/sec). Now 0.125 (8 ticks/sec) doubles
# the DPS at the start of a run without changing per-tick damage.
const BEAM_DAMAGE_COOLDOWN: float = 0.125
var _beam_line: Line2D = null
var _beam_dmg_timer: float = 0.0
# arc-4 iter 66 (Round 9d): MORTAR Tank — lobbed AoE shell, fires over
# walls, slow rate of fire. The shell handles arc + AoE; PlayerTank
# just spawns it on _fire when archetype=MORTAR.
const MortarShellScene = preload("res://scenes/MortarShell.tscn")
const MORTAR_RANGE: float = 96.0
const MORTAR_GUN_COOLDOWN: float = 1.5
# arc-4 iter 67 (Round 9e): RAM Tank — collision damage + short-range
# swing + built-in sprint. The movement-as-weapon archetype.
const RAM_COLLISION_DAMAGE: int = 1
const RAM_DAMAGE_COOLDOWN: float = 0.35
const RAM_SWING_DAMAGE: int = 2
const RAM_SWING_RANGE: float = 18.0
const RAM_SWING_COOLDOWN: float = 0.5
const RAM_SPEED_BONUS: int = 6
var _ram_collision_timer: float = 0.0
var _ram_swing_timer: float = 0.0
# arc-4 iter 68 (Round 9f): start-pick selection screen. The auto-show
# in _ready is gated on this @export (default false → harnesses are
# unaffected); the live BreachLevel.tscn overrides to true.
@export var force_archetype_select: bool = false
var _archetype_initialized: bool = false
var _archetype_selecting: bool = false
var _archetype_panel: ColorRect = null
var _archetype_choice_labels: Array[Label] = []
var _hp_bar_bg: ColorRect = null
var _hp_bar_fg: ColorRect = null
var _death_label: Label
var _death_panel: ColorRect = null  # iter 71: dark backing panel behind death label
var _restart_hint_label: Label = null  # iter 76: pulsing [R] RESTART hint

# arc-4 iter 78 (Round 10 Phase 3): breach-mode playtest prompt
# overlay shown on death only. Per Consult 008's H5 ("deferral !=
# passivity") — improves playtest verdict quality without changing
# design surface. Built + shown only when loadout != null (breach
# mode); arc-2/3 codepath unchanged.
var _breach_prompt_panel: ColorRect = null
var _breach_prompt_label: Label = null
var _restart_hint_tween: Tween = null

# arc-4 iter 092 (P0-2 fix from code-review-iter-090): cache the
# scene's default GunTimer.wait_time + track cumulative XP-earned
# reload reduction. The previous design hard-reset wait_time to 1.0
# on archetype switches, wiping FASTER_RELOAD level-up bonuses.
# New model: reduction is a "savings" that persists across switches;
# each archetype's effective wait_time = archetype_base − reduction
# (floored at RELOAD_MIN).
var _base_default_gun_wait_time: float = 1.0
var _reload_reduction: float = 0.0
# Roguelike ascender state (iter 11 — Pro Consult 003 reframe)
var _start_y: float = 0.0
var _min_y_reached: float = 0.0
var _run_time: float = 0.0
var _depth_label: Label
var _time_label: Label
var _best_label: Label = null  # arc-4 iter 42: live best-depth readout
var _run_best_depth: int = 0
# iter 30: depth milestone flash (Pro Consult 005 META — ascent legibility)
var _last_milestone_depth: int = 0
@export var depth_milestone_step: int = 10
# iter 31: ascender-metric instrumentation (Pro Consult 005 H4)
var _stall_time_total: float = 0.0  # cumulative seconds with ascent_velocity < threshold
var _last_y_for_velocity: float = 0.0
var _ascent_velocity_player: float = 0.0  # smoothed rows/sec, player-side estimate
@export var stall_velocity_threshold: float = 0.3  # rows/sec; matches Spawner.stall_threshold
@export var velocity_ema_alpha_player: float = 2.0

# iter 019 (arc 3 soft-substrate write per PROMPT Layer-2 spec, F003 fix):
# the DEPTH / TIME ascender labels are arc-2 specific (ascender mode shows
# climb progress). In arc-3 OG mode they're meaningless. Default true
# preserves arc-2 procedural behavior bit-identical; OriginalLevel.tscn
# sets this false to hide the ascender HUD. HP bar + death overlay stay
# regardless (HP is gameplay-relevant in both modes).
@export var show_ascender_hud: bool = true

# iter 023 (arc 3 substrate write #3, per PROMPT Layer-2 "eagle-protect
# mechanic" sanction): BC-canonical lives system. Default 1 preserves
# arc-2 single-life death-flow bit-identical. OriginalLevel.tscn overrides
# to 3 (BC canonical). On HP=0 with lives_remaining > 1: respawn at start
# position with fresh HP and brief iframes. On lives_remaining <= 1:
# existing death code path runs unchanged.
@export var max_lives: int = 1
signal lives_changed(remaining: int, max_lives_val: int)
var _lives_remaining: int = 1
var _start_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	hp = max_hp
	# iter 023: lives system init. Default max_lives=1 means _lives_remaining=1;
	# first _die() decrements to 0 → original death flow → arc-2 bit-identical.
	_lives_remaining = max_lives
	_start_position = global_position
	rotation = Constants.dir_to_rotation(direction)
	_start_y = global_position.y
	_min_y_reached = _start_y
	_last_y_for_velocity = _start_y  # iter 31: instrumentation seed
	# arc-4: breach-mode death recap (only when a loadout is assigned).
	if loadout != null:
		# arc-4 iter 44 (F004): the loadout is a SHARED Resource
		# (BreachLevel bakes breach_starter_loadout.tres). consume() +
		# depot upgrades mutate it, and reload_current_scene reuses the
		# resource cache — so without a private per-run copy, run 2+
		# would start with run 1's depleted reserves + purchased
		# upgrades. duplicate() gives each run a fresh loadout from the
		# .tres template; the template is never mutated.
		loadout = loadout.duplicate()
		run_recap = RunRecapT.new()
		# arc-4 iter 095 (P1-4 fix from code-review-iter-090):
		# capture the START-OF-RUN archetype immediately. The field
		# is documented as "TankArchetype at run start" — for runs
		# that don't show the pick screen (force_archetype_select=
		# false), this @export default IS the run-start identity.
		# _pick_archetype updates this on the picked archetype below;
		# _on_breach_band_changed no longer overwrites it.
		run_recap.archetype = archetype
	# iter 101 (review-fix): sibling lookup via Tiles parent, not root-walk.
	var level: Node = get_parent()
	if level != null:
		_grass_tilemap = level.get_node_or_null("Tiles/Grass") as TileMapLayer
	_camera = get_parent().get_node_or_null("Camera2D") as Camera2D
	# arc-4 iter 56 (Round 8a): the Spawner sibling tracks enemies_killed
	# — polled by _tick_xp for kill XP. Cached here; null in arc-2/3 is fine.
	_spawner = get_parent().get_node_or_null("Spawner")
	_setup_hurtbox()
	_setup_hud()
	# arc-4 iter 42 (Round 6d): band-arrival banner — connect to the
	# breach level's band-change signal. The signal exists only on
	# ProceduralLevel and fires only when breach_mode_enabled, so this
	# is breach-mode-only; arc-2/3 never connects.
	if loadout != null and level != null and level.has_signal("breach_band_changed"):
		level.breach_band_changed.connect(_on_breach_band_changed)
	# arc-4 iter 50 (Round 7c): build the run-route strip deferred — the
	# level's _init_breach_mode shuffles the band order in the level's
	# _ready, which runs AFTER this child _ready. Deferring reads
	# breach_config once the shuffle is done.
	if loadout != null:
		call_deferred("_build_route_strip")
	hp_changed.emit(hp, max_hp)
	_update_run_hud()
	# arc-4 iter 092 (P0-2 fix): capture the scene's default GunTimer
	# wait_time BEFORE any per-archetype init mutates it. MORTAR
	# overrides to MORTAR_GUN_COOLDOWN, so we must capture the
	# DEFAULT base first for the FASTER_RELOAD bonus math to compose.
	if has_node("GunTimer"):
		_base_default_gun_wait_time = ($GunTimer as Timer).wait_time
	# arc-4 iter 68 (Round 9f): per-archetype init is extracted into a
	# single function — also called after _pick_archetype (post-_ready)
	# when the user picks a non-DEFAULT archetype from the start-pick
	# screen. Guarded by _archetype_initialized so it fires at most once
	# per archetype change.
	_init_archetype()
	# arc-4 iter 68 (Round 9f): start-pick selection — when breach mode
	# + archetype is still the unset DEFAULT + the .tscn has opted in +
	# more than one archetype is unlocked.
	if loadout != null and archetype == TankArchetype.DEFAULT and force_archetype_select:
		var best: int = MetaProgressT.best_depth()
		var unlocked: Array = MetaProgressT.unlocked_archetypes(best)
		if unlocked.size() > 1:
			_show_archetype_select()


func _physics_process(delta: float) -> void:
	# arc-4 iter 68 (Round 9f): while the archetype-select screen is up,
	# everything else pauses — only the picker polls input. Released on
	# _pick_archetype.
	# arc-4 iter 091 (P0-1 fix): defensive dead-during-selector escape.
	# Even though the iter-091 tree-pause SHOULD prevent the player from
	# dying while the selector is up, if some path bypasses pause (e.g.
	# a scripted death, an HUD codex dismiss damage path), exit the
	# selector cleanly and route to restart input.
	if _archetype_selecting:
		if _dead:
			_exit_archetype_select()
			_handle_restart_input()
			return
		_poll_archetype_select_input()
		return
	# arc-4 iter 36: the shell codex is dismissed by the first gameplay
	# input — the player reads the breach-economy primer, then plays.
	# arc-4 iter 101 (P1-B fix from code-review-iter-100): return after
	# dismiss so the same-frame ui_accept doesn't continue to _fire()
	# (which would consume a shell + arm GunTimer cooldown unintentionally).
	if _shell_codex != null and _shell_codex.visible and _any_gameplay_input():
		_dismiss_codex()
		return
	if _iframe_timer > 0.0:
		_iframe_timer -= delta
	# arc-4 iter 27: tick down the shell-swap reload beat.
	if _swap_cooldown > 0.0:
		_swap_cooldown -= delta
	# arc-4 iter 28: tick the OVERDRIVE sprint burst → cooldown.
	if _overdrive_timer > 0.0:
		_overdrive_timer -= delta
		if _overdrive_timer <= 0.0:
			_overdrive_timer = 0.0
			_overdrive_cd = overdrive_cooldown
	elif _overdrive_cd > 0.0:
		_overdrive_cd -= delta
	# iter 82: tick down shield invulnerability
	if _shield_timer > 0.0:
		_shield_timer -= delta
		if _shield_timer < 0.0:
			_shield_timer = 0.0
	# iter 84/92: unified tint update — shield > white (speed cut iter 88)
	if sprite != null:
		if _shield_timer > 0.0:
			sprite.self_modulate = Color(0.7, 0.85, 1.0, 1.0)
		else:
			sprite.self_modulate = Color(1, 1, 1, 1)
	# arc-4 iter 59 (Round 8d): the shield HUD indicator tracks the timer.
	if _shield_label != null:
		_shield_label.visible = _shield_timer > 0.0
	# arc-4 iter 116 (Round 14 Phase 2, substrate write ×44): REAR_GUARD
	# auto-defense tick. Closes the open_killbox C8 anchor-3 gap. When
	# the loadout has has_rear_guard AND the cooldown is clear AND an
	# enemy is in the rear 90° cone within REAR_GUARD_RANGE, fire an
	# AP shell backward (free; no shell consumed) and arm the cooldown.
	# Loadout-gated → arc-2/3 player (no loadout) is bit-identical.
	if loadout != null and loadout.has_rear_guard:
		if _rear_guard_cd > 0.0:
			_rear_guard_cd = maxf(0.0, _rear_guard_cd - delta)
		if _rear_guard_cd <= 0.0:
			var target = _find_rear_cone_enemy()
			if target != null:
				_fire_rear_guard()
				_rear_guard_cd = REAR_GUARD_COOLDOWN

	if _dead:
		_handle_restart_input()
		return

	# Roguelike ascender: track depth + run time (iter 11)
	_run_time += delta
	if global_position.y < _min_y_reached:
		_min_y_reached = global_position.y
	_update_run_hud()
	_update_forest_hide()
	# iter 31: ascender-metric instrumentation
	if delta > 0.0:
		var dy_rows: float = (_last_y_for_velocity - global_position.y) / 16.0
		var instant: float = dy_rows / delta
		var a: float = clampf(velocity_ema_alpha_player * delta, 0.0, 1.0)
		_ascent_velocity_player = lerpf(_ascent_velocity_player, instant, a)
		_last_y_for_velocity = global_position.y
		if _ascent_velocity_player < stall_velocity_threshold:
			_stall_time_total += delta

	var input_vector: Vector2 = Vector2()

	if Input.is_action_pressed("ui_up"):
		input_vector.y += -1
		set_dir(Constants.Dir.U)
		sprite.play()
	elif Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		set_dir(Constants.Dir.D)
		sprite.play()
	elif Input.is_action_pressed("ui_left"):
		input_vector.x += -1
		set_dir(Constants.Dir.L)
		sprite.play()
	elif Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		set_dir(Constants.Dir.R)
		sprite.play()
	else:
		sprite.stop()
	# arc-4 iter 65 (Round 9c): PRISM stop-and-fire — no movement while
	# the beam is firing. The player commits, gets exposed in exchange.
	# arc-4 iter 193 (PLAYTEST-FIX): zero the MOVEMENT vector but
	# preserve `input_vector` for the sprite-facing call below. Before
	# this fix, zeroing input_vector caused `sprite.set_dir_set` to
	# keep the old dir_set (no input → no branch matched), so the
	# hull sprite stayed facing the prior direction even though the
	# `direction` variable (and the beam ray) had rotated — visible
	# as a beam pointing one way while the hull faced another.
	var move_vector: Vector2 = input_vector
	if archetype == TankArchetype.PRISM and Input.is_action_pressed("ui_accept"):
		move_vector = Vector2.ZERO

	# arc-4 iter 28: OVERDRIVE sprint — KEY_SHIFT triggers a speed burst
	# when the depot upgrade is owned. Gated on loadout.has_overdrive, so
	# arc-2/3 movement is bit-identical (no loadout → branch never taken).
	# arc-4 iter 67 (Round 9e): sprint is unlocked by the OVERDRIVE depot
	# upgrade OR by the RAM archetype (built-in).
	var _sprint_unlocked: bool = (loadout != null and loadout.has_overdrive) or archetype == TankArchetype.RAM
	if _sprint_unlocked:
		var shift_now: bool = Input.is_physical_key_pressed(KEY_SHIFT)
		if shift_now and not _shift_was_pressed \
				and _overdrive_timer <= 0.0 and _overdrive_cd <= 0.0:
			_overdrive_timer = overdrive_burst
		_shift_was_pressed = shift_now
	# arc-4 iter 67 (Round 9e): RAM damage/swing cooldowns tick down.
	if archetype == TankArchetype.RAM:
		_ram_collision_timer -= delta
		_ram_swing_timer -= delta
	var move_speed: float = float(speed)
	if _overdrive_timer > 0.0:
		move_speed *= overdrive_mult
	velocity = move_vector * move_speed
	sprite.set_dir_set(input_vector)

	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
		# arc-4 iter 67 (Round 9e): RAM damages any body it collides with.
		if archetype == TankArchetype.RAM and _ram_collision_timer <= 0.0:
			var collider: Object = collision.get_collider()
			if collider != null and collider.has_method("take_damage"):
				collider.take_damage(RAM_COLLISION_DAMAGE)
				_ram_collision_timer = RAM_DAMAGE_COOLDOWN
	sprite.colliding = collision != null

	# arc-4 iter 65 (Round 9c) + iter 67 (Round 9e): per-archetype fire
	# input handling — PRISM beams, RAM swings, DEFAULT/MORTAR via _fire.
	if archetype == TankArchetype.PRISM:
		if Input.is_action_pressed("ui_accept"):
			_tick_beam(delta)
		else:
			_stop_beam()
	elif archetype == TankArchetype.RAM:
		if Input.is_action_pressed("ui_accept") and _ram_swing_timer <= 0.0:
			_ram_swing()
			_ram_swing_timer = RAM_SWING_COOLDOWN
	elif Input.is_action_pressed("ui_accept"):
		_fire()

	# arc-4: shell cycle via KEY_TAB (just-pressed edge). No InputMap
	# action registered — raw key check keeps project.godot untouched.
	# Only engages when a loadout is set; otherwise we stay on AP.
	if loadout != null:
		var tab_now: bool = Input.is_physical_key_pressed(KEY_TAB)
		if tab_now and not _tab_was_pressed:
			_cycle_shell()
		_tab_was_pressed = tab_now


func set_dir(new_dir: int) -> void:
	# snap to grid
	if direction != new_dir:
		position = position.snapped(grid)
	direction = new_dir
	set_rotation(Constants.dir_to_rotation(direction))


func _fire() -> void:
	if not can_shoot:
		return
	# arc-4 iter 27: a shell swap imposes a reload beat — no fire until
	# it elapses. The pre-commitment cost of choosing a shell.
	# arc-4 iter 102 (P1-D fix): flash the shell-panel BG so the reject
	# is visible. Without this the input is silently dropped and the
	# player reads it as a broken input, not as the commitment-cost
	# design surface.
	if _swap_cooldown > 0.0:
		_flash_shell_panel_reject()
		return
	# arc-4 iter 66 (Round 9d): MORTAR fires a lobbed shell, not a
	# discrete bullet — branch before the shell-consume + shoot.emit path.
	if archetype == TankArchetype.MORTAR:
		_fire_mortar()
		$GunTimer.start()
		can_shoot = false
		return
	# arc-4: determine the actual shell to fire. With no loadout, we
	# always fire AP (arc-2/3 baseline). With a loadout, we attempt the
	# current_shell — consume() falls back to AP if the chosen reserve
	# is empty (the player wasted a frame's fire on an empty mag — that
	# IS the breach-economy commitment cost surface).
	var actual_shell: int = BulletT.SHELL_CLASS_AP
	if loadout != null:
		actual_shell = loadout.consume(current_shell)
	$GunTimer.start()
	shoot.emit(Bullet, $Muzzle.global_position, direction, actual_shell)
	can_shoot = false
	if run_recap != null:
		run_recap.record_shot(actual_shell)


# arc-4: cycle current_shell among AP/HE/HEAT/APCR, skipping classes the
# loadout can't fire (zero reserve). If loadout is null this is a no-op
# (input check up-stream gates it).
func _cycle_shell() -> void:
	if loadout == null:
		return
	# AP → HE → HEAT → APCR → AP (skip out-of-reserve when cycling onto it).
	var order: Array[int] = [
		BulletT.SHELL_CLASS_AP,
		BulletT.SHELL_CLASS_HE,
		BulletT.SHELL_CLASS_HEAT,
		BulletT.SHELL_CLASS_APCR,
	]
	var idx: int = order.find(current_shell)
	if idx < 0:
		idx = 0
	# Try at most order.size() hops (full ring).
	for hop in order.size():
		idx = (idx + 1) % order.size()
		if loadout.can_fire(order[idx]):
			if order[idx] != current_shell:
				current_shell = order[idx]
				# arc-4 iter 27: a real swap arms the reload beat —
				# unless the iter-41 QUICK_SWAP rule-changer is owned.
				if not loadout.quick_swap:
					_swap_cooldown = shell_swap_cost
			return
	# All other classes empty; stay on current.


func _on_GunTimer_timeout() -> void:
	can_shoot = true


# arc-4 iter 65 (Round 9c): build the PRISM beam visual — a Line2D
# from the muzzle along the tank's facing. Hidden until firing.
# iter 69 (Round 9g): idempotent — no-op when already built, so a
# DEFAULT→PRISM→DEFAULT→PRISM switch cycle doesn't stack Line2D nodes.
func _build_beam_line() -> void:
	if _beam_line != null:
		return
	_beam_line = Line2D.new()
	_beam_line.name = "BeamLine"
	_beam_line.points = [Vector2(8, 0), Vector2(BEAM_RANGE, 0)]
	_beam_line.width = 2.0
	_beam_line.default_color = Color(0.4, 0.95, 1.0, 0.9)
	_beam_line.z_index = 30
	_beam_line.visible = false
	add_child(_beam_line)


# arc-4 iter 138 (PLAYTEST-FIX from user): thick-beam tuning.
# Replaces the iter-65 thin-ray cast with a 2-step approach:
#   (1) ray-cast with mask=9 (Environment+Enemy, NOT water layer 10)
#       to find the visual end-point of the beam (stops at first
#       solid hit; passes through water as bullets do).
#   (2) shape-intersect with an 8px-tall RectangleShape2D over the
#       beam corridor → finds ALL damageable bodies in the path.
#       When beam is aimed along a horizontal tile seam (player
#       muzzle at Y multiple of 8), the rect overlaps 2 adjacent
#       rows → both get damaged simultaneously (user spec: "4 tiles
#       = 1 block; centered beam hits 2 horizontal tiles at the
#       same time").
#   (3) per-target damage accumulator via set_meta — each beam tick
#       adds BEAM_DAMAGE_PER_TICK to the target's accumulator; when
#       ≥ 1.0, take_damage(1) + decrement. HP bar drains visibly
#       in discrete steps across the beam-active window.
const BEAM_HEIGHT_PX: float = 8.0              # one tile tall = covers seam-adjacent rows
# arc-4 iter 139 (PLAYTEST-FIX-2): each cooldown tick = 1 beam HP
# (no accumulator). With BEAM_DAMAGE_COOLDOWN = 0.25s, that's 4 HP/sec
# DPS. Enemy beam_hp_max = 10 → 2.5s + 10 visible bar steps. Brick
# beam_hp_max = 3 → 0.75s.
const BEAM_DAMAGE_PER_TICK: int = 1
func _tick_beam(delta: float) -> void:
	if _beam_line == null:
		return
	var muzzle: Node2D = $Muzzle
	var origin: Vector2 = muzzle.global_position
	var dir: Vector2 = Vector2(1.0, 0.0).rotated(rotation)
	var end_pos: Vector2 = origin + dir * BEAM_RANGE
	var ss := get_world_2d().direct_space_state
	# (1) Ray-cast for the beam's visual endpoint. Mask=9 means the
	# beam passes through water (layer 10) like bullets do, matching
	# the iter-101 bullet target-mask pattern.
	var ray_q := PhysicsRayQueryParameters2D.create(origin, end_pos)
	ray_q.exclude = [self]
	ray_q.collision_mask = 9
	var ray_hit: Dictionary = ss.intersect_ray(ray_q)
	var beam_dist: float = BEAM_RANGE
	if not ray_hit.is_empty():
		beam_dist = origin.distance_to(ray_hit.position)
	_beam_line.points = [muzzle.position, muzzle.position + Vector2(beam_dist, 0.0)]
	_beam_line.visible = true
	# (2) Shape-intersect for damage application — covers the beam
	# corridor including any horizontal-seam-adjacent rows. Width =
	# the beam's visible length, height = one tile (BEAM_HEIGHT_PX).
	var shape := RectangleShape2D.new()
	shape.size = Vector2(beam_dist, BEAM_HEIGHT_PX)
	var shape_q := PhysicsShapeQueryParameters2D.new()
	shape_q.shape = shape
	# Center of the rect at (origin + dir * beam_dist / 2.0), rotated
	# to align with beam direction.
	shape_q.transform = Transform2D(rotation, origin + dir * (beam_dist * 0.5))
	shape_q.collision_mask = 9
	shape_q.exclude = [self]
	var bodies: Array = ss.intersect_shape(shape_q, 16)
	_apply_beam_to_targets(delta, bodies)


# arc-4 iter 138 (PLAYTEST-FIX): per-target beam-damage accumulator.
# Each beam tick adds BEAM_DAMAGE_PER_TICK to the target's stored
# accumulator (via set_meta); when accumulator >= 1.0, take_damage(1)
# fires + decrement by 1.0. Multiple targets each track independently
# so a thick-beam multi-hit doesn't share the damage budget. Steel-
# style bodies (no take_damage) are skipped (beam passes their cell
# but they don't break).
func _apply_beam_to_targets(delta: float, bodies: Array) -> void:
	_beam_dmg_timer -= delta
	if _beam_dmg_timer > 0.0:
		return
	for entry in bodies:
		var body: Node = entry.get("collider")
		if body == null:
			continue
		# arc-4 iter 139 (PLAYTEST-FIX-2): prefer the beam-pool path
		# (take_beam_damage) so the beam drains a dedicated 10-HP pool
		# for visible DPS-style drain. Falls back to take_damage for
		# legacy bodies (arc-2/3 brick/enemy without the beam pool).
		if body.has_method("take_beam_damage"):
			body.take_beam_damage(BEAM_DAMAGE_PER_TICK)
		elif body.has_method("take_damage"):
			body.take_damage(BEAM_DAMAGE_PER_TICK)
	_beam_dmg_timer = BEAM_DAMAGE_COOLDOWN


# arc-4 iter 138 (PLAYTEST-FIX): thin back-compat shim — harness
# test_breach_prism still drives the single-body path via this
# method. Forwards to the new array-of-bodies pipeline.
func _apply_beam_to_body(delta: float, hit_body: Node) -> void:
	if hit_body == null:
		_apply_beam_to_targets(delta, [])
	else:
		_apply_beam_to_targets(delta, [{"collider": hit_body}])


# arc-4 iter 65 (Round 9c): hide the beam visual + reset the damage
# cooldown. Called when fire is released (PRISM only).
func _stop_beam() -> void:
	if _beam_line != null:
		_beam_line.visible = false
	_beam_dmg_timer = 0.0


# arc-4 iter 66 (Round 9d): MORTAR fires a lobbed shell into the parent
# level — target is MORTAR_RANGE in the tank's facing direction; the
# shell handles the arc + impact AoE.
func _fire_mortar() -> void:
	var muzzle: Node2D = $Muzzle
	var lvl: Node = get_parent()
	if lvl == null:
		return
	var origin: Vector2 = muzzle.global_position
	var dir: Vector2 = Vector2(1.0, 0.0).rotated(rotation)
	var target: Vector2 = origin + dir * MORTAR_RANGE
	var shell = MortarShellScene.instantiate()
	lvl.add_child(shell)
	shell.launch(origin, target)


# arc-4 iter 69 (Round 9g): undo the current archetype's per-init mods
# before switching to a new one. Keeps speed / GunTimer / beam-line
# clean across multiple switches.
# arc-4 iter 88 (BUILD-QUALITY): also clears per-archetype timer state
# (S1/S2/S3 from iter-87 audit). Side effect: stopping the GunTimer
# before resetting wait_time means a SWITCH cancels any pending
# MORTAR reload — the new archetype's first fire is immediate. Read
# as "swap reloads instantly," consistent with the iter-69 user
# direction ("almost like switching a weapon").
func _revert_archetype() -> void:
	# arc-4 iter 146: restore default sprite atlas before next _init.
	# Idempotent — _apply_archetype_sprite(DEFAULT) is a no-op if already
	# on sprites_0.png + frame_base 0.
	_apply_archetype_sprite(TankArchetype.DEFAULT)
	if archetype == TankArchetype.PRISM and _beam_line != null:
		_beam_line.visible = false
		_beam_dmg_timer = 0.0  # S2: clear pending beam damage cooldown
	elif archetype == TankArchetype.MORTAR and has_node("GunTimer"):
		var gt: Timer = $GunTimer
		gt.stop()  # S3: cancel any pending 1.5s cooldown before reset
		# arc-4 iter 092 (P0-2 fix): restore default-archetype base
		# minus any accumulated FASTER_RELOAD reduction, instead of
		# hardcoded 1.0 (which wiped the XP bonus).
		gt.wait_time = maxf(RELOAD_MIN, _base_default_gun_wait_time - _reload_reduction)
		can_shoot = true  # consistent post-stop state
	elif archetype == TankArchetype.RAM:
		speed -= RAM_SPEED_BONUS
		_ram_swing_timer = 0.0  # S1: clear pending swing cooldown


# arc-4 iter 69 (Round 9g): mid-run archetype switch — called by the
# new Depot SWITCH_TO_* upgrades. Reverts current state, sets the new
# value, re-runs init. Public so Depot.apply_upgrade drives it; idempotent
# on same-value.
func switch_archetype(value: int) -> void:
	# arc-4 iter 093 (P1-3 fix from code-review-iter-090): reject
	# out-of-range values silently (with a warning) — prevents
	# `archetype = 99` putting the tank in undefined state where
	# no _init_archetype branch matches and no _revert_archetype
	# branch can restore.
	if value < TankArchetype.DEFAULT or value > TankArchetype.RAM:
		push_warning("switch_archetype: invalid value %d (valid range %d-%d)" % [value, TankArchetype.DEFAULT, TankArchetype.RAM])
		return
	if value == archetype:
		return
	_revert_archetype()
	archetype = value
	_archetype_initialized = false
	_init_archetype()


# arc-4 iter 68 (Round 9f): per-archetype init — extracted from _ready
# so post-_ready selection can re-init when the user picks. Guarded by
# _archetype_initialized so re-calls without an archetype change are no-ops.
# arc-4 iter 146 (Pro Consult 011 step 4/5): swap sprite texture +
# frame_base when archetype changes. Gating: only takes effect when
# loadout != null (= arc-4 breach mode). DEFAULT archetype always
# restores sprites_0.png + frame_base 0, so arc-2/3 baseline + arc-4
# DEFAULT runs are bit-identical to before. Hash anchor preserved on
# procedural baseline (loadout=null in that codepath).
func _apply_archetype_sprite(arch: int) -> void:
	if sprite == null:
		return
	# `frame_base` is a TankSprite dynamic field. sprite.set("frame_base",
	# ...) works because (a) when sprite IS a TankSprite (the production
	# config per PlayerTank.tscn), the field exists with default 0; (b)
	# even if some test substitutes a plain Sprite2D, Godot's set() on
	# an absent property creates a dynamic entry — no AttributeError.
	# Gating: arc-2/3 mode (no loadout) keeps the original texture.
	if loadout == null:
		sprite.texture = DEFAULT_ATLAS_TEX
		sprite.vframes = 18
		sprite.set("frame_base", 0)
		return
	if arch == TankArchetype.DEFAULT or not _ARCHETYPE_FRAME_BASE.has(arch):
		sprite.texture = DEFAULT_ATLAS_TEX
		sprite.vframes = 18
		sprite.set("frame_base", 0)
		_set_shell_hud_visible(true)
		return
	sprite.texture = ARCHETYPE_ATLAS_TEX
	sprite.vframes = 3
	sprite.hframes = 16
	sprite.set("frame_base", _ARCHETYPE_FRAME_BASE[arch])
	# arc-4 iter 190 (PLAYTEST-FIX): hide shell-cycle HUD for non-DEFAULT
	# archetypes. PRISM uses beam, MORTAR lobs (no cycle), RAM uses
	# physical collision — the AP/HE/HEAT/APCR strip + codex are CRUFT
	# for them, eating bottom-screen space and adding visual noise.
	_set_shell_hud_visible(false)


func _set_shell_hud_visible(show: bool) -> void:
	if _shell_panel != null:
		_shell_panel.visible = show
	# Shell codex is the run-start primer that explains shells — only
	# meaningful for DEFAULT. Don't auto-show it (visibility controlled
	# elsewhere); only force-hide when non-DEFAULT.
	if not show and _shell_codex != null:
		_shell_codex.visible = false


func _init_archetype() -> void:
	if _archetype_initialized:
		return
	_archetype_initialized = true
	_apply_archetype_sprite(archetype)
	if archetype == TankArchetype.PRISM:
		_build_beam_line()
	elif archetype == TankArchetype.MORTAR:
		# arc-4 iter 092 (P0-2 fix): apply accumulated FASTER_RELOAD
		# reduction to MORTAR's base cooldown (not just hard-set).
		# arc-4 iter 096 (P2-3 fix): stop the GunTimer before setting
		# wait_time so DEFAULT→MORTAR doesn't carry stale cooldown
		# (mirrors the iter-88 _revert_archetype hygiene).
		var gt: Timer = $GunTimer
		gt.stop()
		gt.wait_time = maxf(RELOAD_MIN, MORTAR_GUN_COOLDOWN - _reload_reduction)
		can_shoot = true
	elif archetype == TankArchetype.RAM:
		speed += RAM_SPEED_BONUS
	# DEFAULT — no per-archetype init.


# arc-4 iter 68 (Round 9f): build the start-pick panel. Shown by
# _show_archetype_select; hidden after _pick_archetype.
func _build_archetype_panel(canvas: CanvasLayer) -> void:
	_archetype_panel = ColorRect.new()
	_archetype_panel.name = "ArchetypePanel"
	_archetype_panel.position = Vector2(28, 26)
	_archetype_panel.size = Vector2(264, 188)
	_archetype_panel.color = Color(0.05, 0.05, 0.08, 0.96)
	_archetype_panel.visible = false
	canvas.add_child(_archetype_panel)
	_codex_line(_archetype_panel, "— PICK YOUR TANK —", Vector2(40, 12), 13,
		Color(1.0, 0.95, 0.6, 1.0))
	for i in 4:
		var lbl: Label = Label.new()
		lbl.name = "ArchetypeRow%d" % i
		lbl.position = Vector2(18, 48 + i * 22)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		lbl.add_theme_constant_override("outline_size", 2)
		lbl.add_theme_font_size_override("font_size", 10)
		_archetype_panel.add_child(lbl)
		_archetype_choice_labels.append(lbl)
	_codex_line(_archetype_panel, "Press 1-4 to pick.", Vector2(18, 158), 9,
		Color(0.78, 0.8, 0.86, 1.0))


# arc-4 iter 68 (Round 9f): show the start-pick panel + arm the
# selecting gate (which makes _physics_process poll only for KEY_1-4).
func _show_archetype_select() -> void:
	_archetype_selecting = true
	# arc-4 iter 091 (P0-1 fix from code-review-iter-090): pause the
	# world so enemies don't spawn/shoot while the player reads the
	# pick screen. PlayerTank stays processing (PROCESS_MODE_ALWAYS)
	# so the picker input poll keeps firing.
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	var canvas: CanvasLayer = $HUD if has_node("HUD") else null
	if canvas == null:
		return
	if _archetype_panel == null:
		_build_archetype_panel(canvas)
	_refresh_archetype_panel()
	_archetype_panel.visible = true


# arc-4 iter 091 (P0-1 fix): centralized selector cleanup — unpause
# the tree, restore default process_mode, hide the panel. Called by
# _pick_archetype (normal path) and the dead-during-selector escape
# in _physics_process.
func _exit_archetype_select() -> void:
	_archetype_selecting = false
	if _archetype_panel != null:
		_archetype_panel.visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT


# arc-4 iter 68 (Round 9f): populate the panel's 4 rows from the
# current unlock state — unlocked rows show "[N]  NAME"; locked rows
# are dimmed + name the depth tier.
func _refresh_archetype_panel() -> void:
	var best: int = MetaProgressT.best_depth()
	var unlocked: Array = MetaProgressT.unlocked_archetypes(best)
	var arche_info: Array = [
		[TankArchetype.DEFAULT, "DEFAULT  (multi-shell)", 0],
		[TankArchetype.PRISM, "PRISM  (continuous beam)", MetaProgressT.UNLOCK_PRISM_DEPTH],
		[TankArchetype.MORTAR, "MORTAR  (lobbed AoE)", MetaProgressT.UNLOCK_MORTAR_DEPTH],
		[TankArchetype.RAM, "RAM  (collision + sprint)", MetaProgressT.UNLOCK_RAM_DEPTH],
	]
	for i in arche_info.size():
		if i >= _archetype_choice_labels.size():
			break
		var info: Array = arche_info[i]
		var arch_val: int = int(info[0])
		var nm: String = String(info[1])
		var lock_depth: int = int(info[2])
		var lbl: Label = _archetype_choice_labels[i]
		var idx_in_unlocked: int = unlocked.find(arch_val)
		if idx_in_unlocked >= 0:
			lbl.text = "[%d]  %s" % [idx_in_unlocked + 1, nm]
			lbl.modulate = Color(1, 1, 1, 1)
		else:
			lbl.text = "     %s  -  unlock at depth %d" % [nm, lock_depth]
			lbl.modulate = Color(0.5, 0.5, 0.55, 1)


# arc-4 iter 68 (Round 9f): apply a picked archetype + re-init +
# release the selecting gate. Public so the harness drives it without
# needing to fake input.
func _pick_archetype(value: int) -> void:
	if not _archetype_selecting:
		return
	# arc-4 iter 094 (P1-2 fix from code-review-iter-090): route
	# through switch_archetype so _revert_archetype runs if the
	# current archetype is non-DEFAULT (latent today — start-pick is
	# always from DEFAULT — but defensive against future callers
	# that drive _pick_archetype from a non-DEFAULT state, where the
	# old direct-assignment path would leak RAM_SPEED_BONUS / MORTAR
	# GunTimer / PRISM beam state).
	switch_archetype(value)
	# arc-4 iter 095 (P1-4 fix): the pick-screen choice IS the
	# run-start archetype (overrides the _ready DEFAULT capture).
	# Only update if the switch succeeded — if switch_archetype
	# rejected out-of-range or same-value, archetype didn't change
	# and run_recap should reflect the actual state.
	if run_recap != null:
		run_recap.archetype = archetype
	# arc-4 iter 091 (P0-1 fix): centralized cleanup — also unpauses
	# tree + restores process_mode. Always runs even if switch_archetype
	# early-returned (out-of-range or same-value).
	_exit_archetype_select()


# arc-4 iter 68 (Round 9f): KEY_1-4 = the Nth unlocked archetype.
func _pick_archetype_by_index(idx: int) -> void:
	var unlocked: Array = MetaProgressT.unlocked_archetypes(MetaProgressT.best_depth())
	if idx < 0 or idx >= unlocked.size():
		return
	_pick_archetype(int(unlocked[idx]))


# arc-4 iter 68 (Round 9f): KEY_1-4 input poll — used by
# _physics_process while _archetype_selecting.
func _poll_archetype_select_input() -> void:
	if Input.is_physical_key_pressed(KEY_1):
		_pick_archetype_by_index(0)
	elif Input.is_physical_key_pressed(KEY_2):
		_pick_archetype_by_index(1)
	elif Input.is_physical_key_pressed(KEY_3):
		_pick_archetype_by_index(2)
	elif Input.is_physical_key_pressed(KEY_4):
		_pick_archetype_by_index(3)


# arc-4 iter 67 (Round 9e): RAM melee swing — damage every Node2D
# sibling in the forward semicircle within RAM_SWING_RANGE that has
# take_damage. Sibling-distance pattern (cf. MORTAR AoE, HE blast).
# Public so the harness drives it.
func _ram_swing() -> void:
	var lvl: Node = get_parent()
	if lvl == null:
		return
	var origin: Vector2 = global_position
	var dir: Vector2 = Vector2(1.0, 0.0).rotated(rotation)
	for sibling in lvl.get_children():
		if sibling == self:
			continue
		if not (sibling is Node2D):
			continue
		if not sibling.has_method("take_damage"):
			continue
		var to_target: Vector2 = (sibling as Node2D).global_position - origin
		var forward_proj: float = to_target.dot(dir)
		if forward_proj <= 0.0:
			continue  # behind the tank
		if to_target.length() > RAM_SWING_RANGE:
			continue  # out of range
		sibling.take_damage(RAM_SWING_DAMAGE)


# arc-4 iter 116 (Round 14 Phase 2): scan the "enemy" group for the
# closest enemy in the player's rear 90° cone within REAR_GUARD_RANGE.
# Returns null if none. Used by the REAR_GUARD auto-defense tick in
# _physics_process. Pure read — does not mutate state.
func _find_rear_cone_enemy() -> Node:
	var rear_vec: Vector2 = -Vector2(1, 0).rotated(rotation)
	var closest: Node = null
	var closest_d: float = REAR_GUARD_RANGE
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not (enemy is Node2D) or not is_instance_valid(enemy):
			continue
		var to_enemy: Vector2 = (enemy as Node2D).global_position - global_position
		var dist: float = to_enemy.length()
		if dist > REAR_GUARD_RANGE or dist < 0.1:
			continue
		var cos_angle: float = to_enemy.normalized().dot(rear_vec)
		if cos_angle < REAR_GUARD_CONE_COS:
			continue
		if dist < closest_d:
			closest_d = dist
			closest = enemy
	return closest


# arc-4 iter 116 (Round 14 Phase 2): fire an AP shell backward (180°
# from current facing) via the shoot signal. No shell consumed; the
# REAR_GUARD upgrade is a free auto-defense per cooldown window.
# Public so the harness can drive it directly.
func _fire_rear_guard() -> void:
	var rear_dir: int
	match direction:
		Constants.Dir.L: rear_dir = Constants.Dir.R
		Constants.Dir.R: rear_dir = Constants.Dir.L
		Constants.Dir.U: rear_dir = Constants.Dir.D
		Constants.Dir.D: rear_dir = Constants.Dir.U
		_: rear_dir = Constants.Dir.L
	var rear_offset: Vector2 = -Vector2(1, 0).rotated(rotation) * 8.0
	var spawn_pos: Vector2 = global_position + rear_offset
	shoot.emit(Bullet, spawn_pos, rear_dir, BulletT.SHELL_CLASS_AP)


func take_damage(amount: int) -> void:
	if _dead or _iframe_timer > 0.0:
		return
	# iter 82: shield-pickup blocks damage during _shield_timer window
	if _shield_timer > 0.0:
		return
	hp = max(0, hp - amount)
	_iframe_timer = damage_iframes
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		_die()
	else:
		_start_hit_flash()
		_start_screen_shake()


# arc-4 iter 109 (Round 12 Gap 2): receives the source taxon from
# the damaging bullet (Bullet._on_body_entered) just before
# take_damage. Stored in `_last_damage_source` so `_die()` can
# stamp `run_recap.killer` with a concrete cause instead of the
# "shell impact" placeholder. Empty string = no attribution (the
# default; preserves "shell impact" fallback).
func set_last_damage_source(label: String) -> void:
	_last_damage_source = label


# iter 78 (Q5 priority 4): heal called by HP pickup overlap. Clamped to max_hp.
# No effect if already dead.
func heal(amount: int) -> void:
	if _dead or amount <= 0:
		return
	hp = mini(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)
	_show_pickup_toast("HP+%d" % amount, Color(0.3, 0.95, 0.4, 1.0))


# iter 79 → CUT iter 88 → DELETED iter 92 (Pro Consult 008 visual budget):
# apply_speed_boost stub removed. Speed pickup was cut iter 88; stub had no callers.


# iter 82 (Q5 priority 4): shield pickup grants brief invulnerability.
# take_damage early-returns while _shield_timer > 0.
func apply_shield(duration: float) -> void:
	if _dead:
		return
	# arc-4 iter 59 (Round 8d): in breach mode the shield lasts longer —
	# playtest-3 "make shields longer." arc-2/3 keeps the passed value.
	var effective: float = duration
	if loadout != null:
		effective = maxf(duration, BREACH_SHIELD_DURATION)
	_shield_timer = max(_shield_timer, effective)  # take the longer of active/new
	_show_pickup_toast("SHIELD", Color(0.9, 0.9, 1.0, 1.0))


# iter 80: brief HUD toast on pickup activation. Confirmation feedback.
# Label spawned at top-center, fades over 1.5s, then self-frees.
# arc-4 iter 104 (P2-B fix from code-review-iter-100): stagger Y
# offset based on live-toast count so multi-level-up XP bursts
# don't pile 3 toasts at the same position. Cap stagger at TOAST_
# STAGGER_MAX (4) — beyond that, wrap to 0; concurrent toasts
# beyond 4 are a different problem (likely a bug worth seeing).
const TOAST_BASE_Y: float = 28.0
const TOAST_STAGGER_PX: float = 12.0
const TOAST_STAGGER_MAX: int = 4
func _show_pickup_toast(text: String, color: Color) -> void:
	var canvas: CanvasLayer = $HUD if has_node("HUD") else null
	if canvas == null:
		return
	var toast: Label = Label.new()
	toast.text = text
	# Stagger Y by counting live (non-deletion-queued) toasts on the
	# canvas — those tagged with our metadata key. Caps at
	# TOAST_STAGGER_MAX so the stack doesn't push off-HUD.
	var live: int = _count_live_toasts(canvas)
	var stagger: int = mini(live, TOAST_STAGGER_MAX)
	toast.position = Vector2(140, TOAST_BASE_Y + float(stagger) * TOAST_STAGGER_PX)
	toast.set_meta("is_pickup_toast", true)
	toast.add_theme_color_override("font_color", color)
	toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	toast.add_theme_constant_override("outline_size", 2)
	canvas.add_child(toast)
	var tween: Tween = toast.create_tween()
	tween.set_parallel(true)
	tween.tween_property(toast, "modulate:a", 0.0, 1.5)
	tween.tween_property(toast, "position:y", 16.0, 1.5)
	tween.chain().tween_callback(toast.queue_free)


# arc-4 iter 104 (P2-B fix): count toasts on the HUD that are
# tagged with our is_pickup_toast meta key and not queued for
# deletion. Used to compute the stagger offset for the next toast.
func _count_live_toasts(canvas: CanvasLayer) -> int:
	var n: int = 0
	for child in canvas.get_children():
		if child is Label and child.has_meta("is_pickup_toast"):
			if is_instance_valid(child) and not child.is_queued_for_deletion():
				n += 1
	return n


# Visual damage cue (iter 19): bright red pulse + alternating alpha blink
# during the iframe window. Suppresses forest_hide for the duration so the
# flash isn't masked by grass concealment.
func _start_hit_flash() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_is_flashing = true
	_flash_tween = create_tween()
	# Red pulse (saturated red, brief)
	_flash_tween.tween_property(sprite, "modulate", hit_flash_color, 0.0)
	_flash_tween.tween_interval(0.08)
	# Iframe blink — 3 cycles of dimmed/normal (~0.48s)
	for i in 3:
		_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.4), 0.08)
		_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	# Restore: forest_hide will resume on next physics frame
	_flash_tween.tween_callback(_end_hit_flash)


func _end_hit_flash() -> void:
	_is_flashing = false
	# Reset modulate to white; _update_forest_hide will set alpha next frame
	if sprite != null:
		sprite.modulate = Color.WHITE


# Camera shake (iter 42) — randomized Camera2D.offset kicks with decaying
# amplitude, ending in snap-to-zero restore. Independent of position smoothing
# because we tween `offset`, not `position`. RemoteTransform2D on PlayerTank
# drives Camera2D.position; offset is undriven and free to animate.
func _start_screen_shake() -> void:
	if _camera == null:
		return
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	var step_dur: float = screen_shake_duration / float(screen_shake_steps)
	for i in screen_shake_steps:
		var t: float = float(i) / float(maxi(screen_shake_steps - 1, 1))
		var amp: float = screen_shake_magnitude * (1.0 - t)
		var offset: Vector2 = Vector2(randf_range(-amp, amp), randf_range(-amp, amp))
		_shake_tween.tween_property(_camera, "offset", offset, step_dur)
	# Restore to (0,0) — fast snap so the camera doesn't drift after damage
	_shake_tween.tween_property(_camera, "offset", Vector2.ZERO, 0.05)


func _die() -> void:
	# iter 023: lives system. Decrement first; if any remain, respawn
	# without running the heavy run-summary / death-screen code path.
	# Procedural mode (max_lives=1) decrements 1 → 0 and falls through to
	# the original death flow — arc-2 bit-identical.
	_lives_remaining -= 1
	lives_changed.emit(_lives_remaining, max_lives)
	if _lives_remaining > 0:
		_respawn()
		return
	_dead = true
	sprite.stop()
	velocity = Vector2.ZERO
	# arc-4 iter 097 (P2-4 fix from code-review-iter-090): stop the
	# PRISM beam on death so the death overlay doesn't have a beam
	# line still drawn across the screen.
	if archetype == TankArchetype.PRISM and _beam_line != null:
		_stop_beam()
	# iter 31: ascender run summary on death (Pro Consult 005 H4)
	var depth: int = int(maxf(0.0, (_start_y - _min_y_reached) / 16.0))
	# arc-4: capture death attribution. Passes the killing BreachBand
	# object from the parent level's _current_breach_band (set by
	# ProceduralLevel breach mode) so the recap can name both the band
	# and its dominant_pressure. null when absent.
	# arc-4 iter 108: hoist `band` out of the run_recap block so the
	# death-label verdict path (below) can also read its canonical_answer.
	var band = null
	var lvl: Node = get_parent()
	if lvl != null and "_current_breach_band" in lvl:
		band = lvl._current_breach_band
	if run_recap != null:
		# arc-4 iter 109 (Round 12 Gap 2): stamp the killer from the
		# last damage event's source taxon. Empty fallback preserves the
		# placeholder so the verdict still reads cleanly.
		if not _last_damage_source.is_empty():
			run_recap.killer = _last_damage_source
		run_recap.capture_death(depth, band, loadout)
	var t: int = int(_run_time)
	var ascent_rate: float = 0.0
	if _run_time > 0.0:
		ascent_rate = float(depth) / _run_time
	var stall_pct: float = 0.0
	if _run_time > 0.0:
		stall_pct = 100.0 * _stall_time_total / _run_time
	# iter 43: kills lookup from Spawner sibling (best-effort)
	# iter 56: aim-cancels counter from same Spawner
	# iter 57: seed from ProceduralLevel parent
	var kills: int = 0
	var aim_cancels: int = 0
	var spawner: Node = get_parent().get_node_or_null("Spawner")
	if spawner != null:
		if "enemies_killed" in spawner:
			kills = int(spawner.enemies_killed)
		if "aim_cancels_landed" in spawner:
			aim_cancels = int(spawner.aim_cancels_landed)
	var level_seed: int = 0
	if "level_seed" in get_parent():
		level_seed = int(get_parent().level_seed)
	print("[run] depth=%d time=%d:%02d kills=%d aim_cancels=%d ascent_rate=%.2f rows/s stall_total=%.1fs (%.0f%%) seed=%d" % [depth, t / 60, t % 60, kills, aim_cancels, ascent_rate, _stall_time_total, stall_pct, level_seed])
	# iter 44: persistent best-depth tracking
	var prior_best: int = _load_best_depth()
	var is_new_best: bool = depth > prior_best
	if is_new_best:
		_save_best_depth(depth)
	# iter 73: best-time tracking (only count runs that reach depth >= 10
	# to filter trivial deaths). best_time = LONGEST survival in seconds at
	# any qualifying run.
	var prior_best_time: int = _load_best_time()
	var is_new_best_time: bool = depth >= 10 and t > prior_best_time
	if is_new_best_time:
		_save_best_time(t)
	# iter 43: render run summary on death label (iter 44: + BEST line)
	# iter 71: also show dark backing panel for readability
	if _death_label != null:
		var best_line: String
		if is_new_best:
			best_line = "\n* NEW BEST DEPTH!  (was %d)" % prior_best
		else:
			best_line = "\nBEST %d" % prior_best
		var best_time_line: String
		if is_new_best_time:
			best_time_line = "\n* NEW BEST TIME!  (was %d:%02d)" % [prior_best_time / 60, prior_best_time % 60]
		else:
			best_time_line = "\nBEST TIME %d:%02d" % [prior_best_time / 60, prior_best_time % 60]
		# arc-4 iter 108 (Round 12 γ, substrate write ×42): the death
		# overlay now shows the RunRecap verdict sentence (constraint-6-
		# shaped diagnosis) + a compact ASCENDER footer. In arc-2/3 modes
		# (run_recap == null), the iter-43 ASCENDER block is preserved
		# bit-identical — keeps the procedural baseline + OG mode HUD
		# behaviour untouched.
		if run_recap != null:
			var canonical: String = ""
			if band != null and "canonical_answer" in band:
				canonical = String(band.canonical_answer)
			var verdict: String = run_recap.verdict_sentence(canonical)
			_death_label.text = "YOU DIED\n\n%s\n\nDEPTH %d · TIME %d:%02d · KILLS %d%s%s" % [
				verdict, depth, t / 60, t % 60, kills, best_line, best_time_line
			]
		else:
			_death_label.text = "YOU DIED\n\nDEPTH %d\nTIME %d:%02d\nKILLS %d\nCANCELS %d\nSTALL %d%%%s%s" % [depth, t / 60, t % 60, kills, aim_cancels, int(stall_pct), best_line, best_time_line]
		_death_label.visible = true
	if _death_panel != null:
		_death_panel.visible = true
	# iter 76: start pulsing restart hint
	if _restart_hint_label != null:
		_restart_hint_label.visible = true
		if _restart_hint_tween != null and _restart_hint_tween.is_valid():
			_restart_hint_tween.kill()
		_restart_hint_tween = create_tween().set_loops()
		_restart_hint_tween.tween_property(_restart_hint_label, "modulate:a", 0.35, 0.6)
		_restart_hint_tween.tween_property(_restart_hint_label, "modulate:a", 1.0, 0.6)
	# arc-4 iter 78 (Round 10 Phase 3): breach-mode playtest prompt
	# visible only when both dead and breach mode (loadout != null,
	# which is implied by the prompt nodes being non-null since they
	# are only built under that gate in _setup_hud).
	if _breach_prompt_panel != null:
		_breach_prompt_panel.visible = true
	if _breach_prompt_label != null:
		# arc-4 iter 83 (Round 11 Phase 1 continuation): append the
		# band-visit sequence to the prompt label so the user sees
		# the actual run-shape next to the reflection questions.
		# Per CONSULT 009 — band-shape distinctness is the open
		# axis; the visible sequence anchors the user's recall.
		# arc-4 iter 123 (Round 17 BUILD-QUALITY, Gap 5 from iter-106):
		# REPLACE the generic playtest prompt with an auto-generated
		# regret-quote candidate when one is available (dry-on-shell
		# signal present). Falls back to the iter-78 generic prompt
		# when no signal. Loadout-gated entire block.
		var regret: String = ""
		if run_recap != null:
			var rb = null
			if lvl != null and "_current_breach_band" in lvl:
				rb = lvl._current_breach_band
			var rc: String = ""
			if rb != null and "canonical_answer" in rb:
				rc = String(rb.canonical_answer)
			regret = run_recap.regret_quote_candidate(rc)
		var prompt_text: String
		if not regret.is_empty():
			prompt_text = "— playtest prompt —\n" + regret
		else:
			prompt_text = "— playtest prompt —\nwhich moment did you regret?  right archetype?  would switching help?"
		# arc-4 iter 121 (Round 16 BUILD-QUALITY, Gap 4 from iter-106):
		# replace the simple "bands visited" line with the route-diff
		# clause that names BOTH the visited path AND the path-not-
		# taken — strongest constraint-6 form for ROUTE attribution.
		# Falls back to the iter-83 simple line if route data missing.
		if run_recap != null and run_recap.band_visit_log.size() > 0:
			var route_names: Array = []
			for b in _route_bands:
				if "band_name" in b:
					route_names.append(String(b.band_name))
			var diff: String = run_recap.route_diff_clause(route_names)
			if not diff.is_empty():
				prompt_text += "\n" + diff
			else:
				var seq_names: Array = []
				for v in run_recap.band_visit_log:
					seq_names.append(String(v["band"]))
				prompt_text += "\nbands visited: %s" % " > ".join(seq_names)
		_breach_prompt_label.text = prompt_text
		_breach_prompt_label.visible = true
	died.emit()


# iter 023: BC-style life-respawn. Resets HP + position + iframes. Doesn't
# touch _dead (was never set on respawning life). Brief iframes prevent
# instant-re-death from same bullet/collision that killed the previous life.
func _respawn() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)
	global_position = _start_position
	velocity = Vector2.ZERO
	_iframe_timer = 1.5  # 1.5s grace period after respawn
	_start_hit_flash()  # visual cue: tank flashes briefly on respawn


# iter 44: persistent best-depth via ConfigFile at user://stats.cfg.
# First-run path: ConfigFile.load returns ERR_FILE_NOT_FOUND → treat as 0.
# Other errors: print warning and treat as 0 (defensive — corruption should
# not block UI).
const _STATS_CFG_PATH: String = "user://stats.cfg"

func _load_best_depth() -> int:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load(_STATS_CFG_PATH)
	if err == OK:
		return int(cfg.get_value("run", "best_depth", 0))
	if err != ERR_FILE_NOT_FOUND:
		push_warning("[stats] ConfigFile.load err=%d (treating as no prior best)" % err)
	return 0


func _save_best_depth(d: int) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	# Re-load to preserve any other future keys. iter 101 (review-fix): bail
	# on parse-corrupt files so we don't overwrite a partially-readable
	# stats file with just this single key.
	var load_err: int = cfg.load(_STATS_CFG_PATH)
	if load_err != OK and load_err != ERR_FILE_NOT_FOUND:
		push_warning("[stats] best_depth load err=%d — refusing to overwrite" % load_err)
		return
	cfg.set_value("run", "best_depth", d)
	var err: int = cfg.save(_STATS_CFG_PATH)
	if err != OK:
		push_warning("[stats] ConfigFile.save err=%d" % err)


# iter 73: best-time persistence (longest survival on a run with depth >= 10)
func _load_best_time() -> int:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load(_STATS_CFG_PATH)
	if err == OK:
		return int(cfg.get_value("run", "best_time", 0))
	return 0


func _save_best_time(t: int) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var load_err: int = cfg.load(_STATS_CFG_PATH)
	if load_err != OK and load_err != ERR_FILE_NOT_FOUND:
		push_warning("[stats] best_time load err=%d — refusing to overwrite" % load_err)
		return
	cfg.set_value("run", "best_time", t)
	var err: int = cfg.save(_STATS_CFG_PATH)
	if err != OK:
		push_warning("[stats] best_time save err=%d" % err)


func _handle_restart_input() -> void:
	var pressed: bool = Input.is_physical_key_pressed(KEY_R)
	if pressed and _restart_armed:
		get_tree().reload_current_scene()
		return
	if not pressed:
		_restart_armed = true


func _setup_hurtbox() -> void:
	var hurtbox: Area2D = Area2D.new()
	hurtbox.name = "HurtBox"
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 8  # Enemy layer
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(12, 12)
	shape.shape = rect
	hurtbox.add_child(shape)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	add_child(hurtbox)


func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		take_damage(1)


func _setup_hud() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD"
	# iter 49: HP bar (graphical) above numeric text. Anchor 3 of crit 9
	# requires HP shown via bar; anchor 1's numeric stays as hybrid.
	_hp_bar_bg = ColorRect.new()
	_hp_bar_bg.name = "HPBarBG"
	_hp_bar_bg.size = Vector2(34, 6)
	_hp_bar_bg.position = Vector2(3, 3)
	_hp_bar_bg.color = Color(0.15, 0.15, 0.15, 0.85)
	canvas.add_child(_hp_bar_bg)
	_hp_bar_fg = ColorRect.new()
	_hp_bar_fg.name = "HPBarFG"
	_hp_bar_fg.size = Vector2(32, 4)
	_hp_bar_fg.position = Vector2(4, 4)
	_hp_bar_fg.color = Color(0.3, 0.9, 0.3, 1.0)  # green; turns red at low HP
	canvas.add_child(_hp_bar_fg)
	_hp_label = Label.new()
	_hp_label.name = "HPLabel"
	_hp_label.position = Vector2(4, 10)  # iter 49: moved below bar
	_hp_label.text = "HP %d/%d" % [hp, max_hp]
	_hp_label.add_theme_color_override("font_color", Color.WHITE)
	_hp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_hp_label.add_theme_constant_override("outline_size", 2)
	canvas.add_child(_hp_label)
	# iter 71 (F011 typography): dark semi-transparent backing panel behind
	# death label improves readability against any terrain. Larger font_size
	# + black outline for impact + presence.
	_death_panel = ColorRect.new()
	_death_panel.name = "DeathPanel"
	_death_panel.position = Vector2(56, 56)
	_death_panel.size = Vector2(208, 130)
	_death_panel.color = Color(0.0, 0.0, 0.0, 0.65)  # dark semi-transparent
	_death_panel.visible = false
	canvas.add_child(_death_panel)
	_death_label = Label.new()
	_death_label.name = "DeathLabel"
	# iter 43: position raised to make room for multi-line run summary
	_death_label.position = Vector2(72, 64)
	_death_label.size = Vector2(176, 116)
	_death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_death_label.text = "YOU DIED\n[R] RESTART"
	_death_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.95))
	_death_label.add_theme_color_override("font_outline_color", Color(0.6, 0.1, 0.1, 1.0))
	_death_label.add_theme_constant_override("outline_size", 2)
	_death_label.add_theme_font_size_override("font_size", 12)
	_death_label.visible = false
	canvas.add_child(_death_label)
	# iter 76: separate pulsing [R] RESTART hint (Q3 polish)
	_restart_hint_label = Label.new()
	_restart_hint_label.name = "RestartHintLabel"
	_restart_hint_label.position = Vector2(72, 170)
	_restart_hint_label.size = Vector2(176, 14)
	_restart_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_restart_hint_label.text = "press [R] to restart"
	_restart_hint_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.7, 1.0))
	_restart_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_restart_hint_label.add_theme_constant_override("outline_size", 2)
	_restart_hint_label.visible = false
	canvas.add_child(_restart_hint_label)
	# arc-4 iter 78 (Round 10 Phase 3): breach-mode playtest prompt
	# panel — gated on loadout != null (the established breach-mode
	# gate). Arc-2/3 unaffected. Three structured questions focus
	# the user on the open C15 anchor 5 / identity-vs-weapons axis
	# per Consult 008.
	if loadout != null:
		_breach_prompt_panel = ColorRect.new()
		_breach_prompt_panel.name = "BreachPromptPanel"
		_breach_prompt_panel.position = Vector2(24, 192)
		_breach_prompt_panel.size = Vector2(272, 56)  # iter 83: +12 for band-visit line
		_breach_prompt_panel.color = Color(0.0, 0.0, 0.0, 0.65)
		_breach_prompt_panel.visible = false
		canvas.add_child(_breach_prompt_panel)
		_breach_prompt_label = Label.new()
		_breach_prompt_label.name = "BreachPromptLabel"
		_breach_prompt_label.position = Vector2(32, 196)
		_breach_prompt_label.size = Vector2(256, 48)  # iter 83: +12 for band-visit line
		_breach_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_breach_prompt_label.text = "— playtest prompt —\nwhich moment did you regret?  right archetype?  would switching help?"
		_breach_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_breach_prompt_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		_breach_prompt_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_breach_prompt_label.add_theme_constant_override("outline_size", 2)
		_breach_prompt_label.add_theme_font_size_override("font_size", 8)
		_breach_prompt_label.visible = false
		canvas.add_child(_breach_prompt_label)
	# Roguelike ascender HUD (iter 11) — top-right.
	# iter 019 (F003 fix): gated on show_ascender_hud. When false (OG mode),
	# _depth_label / _time_label stay null; _update_run_hud already null-checks,
	# so the update path is a silent noop. arc-2 procedural mode unaffected
	# (export default is true).
	if show_ascender_hud:
		_depth_label = Label.new()
		_depth_label.name = "DepthLabel"
		_depth_label.position = Vector2(232, 4)
		_depth_label.text = "DEPTH 0"
		_depth_label.add_theme_color_override("font_color", Color.WHITE)
		_depth_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_depth_label.add_theme_constant_override("outline_size", 2)
		canvas.add_child(_depth_label)
		_time_label = Label.new()
		_time_label.name = "TimeLabel"
		_time_label.position = Vector2(232, 16)
		_time_label.text = "TIME 0:00"
		_time_label.add_theme_color_override("font_color", Color.WHITE)
		_time_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_time_label.add_theme_constant_override("outline_size", 2)
		canvas.add_child(_time_label)
	# arc-4 iter 35-36: breach-mode shell panel + run-start codex. Gated
	# on loadout != null so arc-2/3 HUD is bit-identical (neither built).
	if loadout != null:
		_build_shell_panel(canvas)
		_build_shell_codex(canvas)
		# arc-4 iter 42 (Round 6d, stakes): the live best-depth readout —
		# the depth chase, always visible (not just on the death recap).
		_run_best_depth = _load_best_depth()
		_best_label = Label.new()
		_best_label.name = "BestLabel"
		_best_label.position = Vector2(232, 28)
		_best_label.text = "BEST %d" % _run_best_depth
		_best_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 1.0))
		_best_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_best_label.add_theme_constant_override("outline_size", 2)
		canvas.add_child(_best_label)
		# arc-4 iter 56 (Round 8a): XP bar + level readout — the visible
		# roguelite progression beat (playtest-3). Top strip, right of HP.
		_level_label = Label.new()
		_level_label.name = "LevelLabel"
		_level_label.position = Vector2(44, 2)
		_level_label.text = "LVL 1"
		_level_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		_level_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_level_label.add_theme_constant_override("outline_size", 2)
		_level_label.add_theme_font_size_override("font_size", 9)
		canvas.add_child(_level_label)
		_xp_bar_bg = ColorRect.new()
		_xp_bar_bg.name = "XPBarBG"
		_xp_bar_bg.position = Vector2(44, 14)
		_xp_bar_bg.size = Vector2(90, 4)
		_xp_bar_bg.color = Color(0.15, 0.15, 0.18, 0.85)
		canvas.add_child(_xp_bar_bg)
		_xp_bar_fg = ColorRect.new()
		_xp_bar_fg.name = "XPBarFG"
		_xp_bar_fg.position = Vector2(45, 15)
		_xp_bar_fg.size = Vector2(0, 2)
		_xp_bar_fg.color = Color(1.0, 0.85, 0.3, 1.0)
		canvas.add_child(_xp_bar_fg)
		# arc-4 iter 59 (Round 8d): shield indicator — visible only while
		# a shield is active (toggled in _physics_process).
		_shield_label = Label.new()
		_shield_label.name = "ShieldLabel"
		_shield_label.position = Vector2(44, 24)
		_shield_label.text = "SHIELD"
		_shield_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 1.0))
		_shield_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_shield_label.add_theme_constant_override("outline_size", 2)
		_shield_label.add_theme_font_size_override("font_size", 8)
		_shield_label.visible = false
		canvas.add_child(_shield_label)
	add_child(canvas)
	hp_changed.connect(_on_hp_changed_hud)


# arc-4 iter 30: render the shell HUD line. Shell-class index → name.
func _shell_name(sc: int) -> String:
	if sc == BulletT.SHELL_CLASS_HE:
		return "HE"
	if sc == BulletT.SHELL_CLASS_HEAT:
		return "HEAT"
	if sc == BulletT.SHELL_CLASS_APCR:
		return "APCR"
	return "AP"


# arc-4 iter 35: per-shell HUD colour — matches the Bullet.gd in-flight
# modulate so the panel chip and the airborne shell read as one thing.
func _shell_color(sc: int) -> Color:
	if sc == BulletT.SHELL_CLASS_HE:
		return Color(1.0, 0.85, 0.25, 1.0)
	if sc == BulletT.SHELL_CLASS_HEAT:
		return Color(1.0, 0.35, 0.25, 1.0)
	if sc == BulletT.SHELL_CLASS_APCR:
		return Color(0.6, 0.85, 1.0, 1.0)
	return Color(0.92, 0.92, 0.95, 1.0)  # AP — pale steel


# arc-4 iter 35: finite reserve for a shell class. AP is unlimited → 0
# here; the panel renders AP as "--" rather than a count.
func _shell_reserve(sc: int) -> int:
	if loadout == null:
		return 0
	if sc == BulletT.SHELL_CLASS_HE:
		return loadout.he_reserve
	if sc == BulletT.SHELL_CLASS_HEAT:
		return loadout.heat_reserve
	if sc == BulletT.SHELL_CLASS_APCR:
		return loadout.apcr_reserve
	return 0


# arc-4 iter 35 (Round 5, playtest finding 1 — "no shell UI"): build the
# breach-mode shell panel. A 4-slot strip — one slot per shell class —
# each with a colour chip (matching the in-flight Bullet modulate), the
# shell name, and the finite reserve. Gated on loadout != null by the
# caller, so arc-2/3 HUD is bit-identical (panel never built).
func _build_shell_panel(canvas: CanvasLayer) -> void:
	_shell_panel = ColorRect.new()
	_shell_panel.name = "ShellPanel"
	_shell_panel.position = Vector2(2, 209)
	_shell_panel.size = Vector2(316, 26)
	_shell_panel.color = SHELL_PANEL_BG_DEFAULT
	canvas.add_child(_shell_panel)
	_shell_slot_classes = [
		BulletT.SHELL_CLASS_AP, BulletT.SHELL_CLASS_HE,
		BulletT.SHELL_CLASS_HEAT, BulletT.SHELL_CLASS_APCR,
	]
	for i in _shell_slot_classes.size():
		var slot_x: float = 4.0 + float(i) * 78.0
		var bg: ColorRect = ColorRect.new()
		bg.position = Vector2(slot_x, 2)
		bg.size = Vector2(76, 22)
		bg.color = Color(0, 0, 0, 0)  # set per-frame by _update_shell_panel
		_shell_panel.add_child(bg)
		_shell_slot_bgs.append(bg)
		var chip: ColorRect = ColorRect.new()
		chip.position = Vector2(slot_x + 4.0, 9)
		chip.size = Vector2(8, 8)
		chip.color = _shell_color(_shell_slot_classes[i])
		_shell_panel.add_child(chip)
		_shell_slot_chips.append(chip)
		var lbl: Label = Label.new()
		lbl.position = Vector2(slot_x + 15.0, 4)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		lbl.add_theme_constant_override("outline_size", 2)
		lbl.add_theme_font_size_override("font_size", 10)
		_shell_panel.add_child(lbl)
		_shell_slot_labels.append(lbl)
	_update_shell_panel()


# arc-4 iter 102 (P1-D fix from code-review-iter-100): a brief
# warm-orange flash on the shell-panel BG when `_fire` is rejected
# because `_swap_cooldown > 0`. Preserves the iter-27 swap-cost
# reload-beat design (constraint 7 — verbs over passive stats), only
# fixes the silent-input-drop UX failure (player would otherwise
# read the rejection as a broken input). Tween fades back to default
# over SHELL_PANEL_REJECT_FADE_S (~0.18s).
func _flash_shell_panel_reject() -> void:
	if _shell_panel == null:
		return
	_shell_panel.color = SHELL_PANEL_BG_REJECTED
	var t: Tween = _shell_panel.create_tween()
	t.tween_property(_shell_panel, "color", SHELL_PANEL_BG_DEFAULT,
		SHELL_PANEL_REJECT_FADE_S)


# arc-4 iter 35: refresh the shell panel — reserve counts, the selection
# highlight on current_shell, and dimming for out-of-reserve shells.
func _update_shell_panel() -> void:
	if _shell_panel == null or loadout == null:
		return
	for i in _shell_slot_classes.size():
		var sc: int = _shell_slot_classes[i]
		var shell_nm: String = _shell_name(sc)
		if sc == BulletT.SHELL_CLASS_AP:
			_shell_slot_labels[i].text = "%s  --" % shell_nm  # AP unlimited
		else:
			_shell_slot_labels[i].text = "%s  %d" % [shell_nm, _shell_reserve(sc)]
		if sc == current_shell:
			_shell_slot_bgs[i].color = Color(0.95, 0.95, 0.55, 0.45)
		else:
			_shell_slot_bgs[i].color = Color(0, 0, 0, 0)
		var dim: float = 1.0 if loadout.can_fire(sc) else 0.4
		_shell_slot_labels[i].modulate.a = dim
		_shell_slot_chips[i].modulate.a = dim


# arc-4 iter 36: any movement / fire / shell-swap key — used to dismiss
# the shell codex overlay once the player starts playing.
func _any_gameplay_input() -> bool:
	return Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") \
		or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_accept") \
		or Input.is_physical_key_pressed(KEY_TAB)


# arc-4 iter 36: hide the shell codex. Called on first gameplay input;
# public so the harness can dismiss it without synthesising input.
func _dismiss_codex() -> void:
	if _shell_codex != null:
		_shell_codex.visible = false
	# arc-4 iter 50: the route strip sits behind the codex — reveal it
	# when the player dismisses the primer and play begins.
	if _route_panel != null:
		_route_panel.visible = true


# arc-4 iter 36: a styled Label inside the codex panel.
func _codex_line(parent: Control, text: String, pos: Vector2,
		font_size: int, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.position = pos
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_font_size_override("font_size", font_size)
	parent.add_child(lbl)


# arc-4 iter 36 (Round 5, playtest findings 2-3 — "no tutorial" + "I
# don't understand when to use which shell"): the shell codex. A
# one-screen primer shown at the start of a breach run — the breach-
# economy framing + each shell's one-line role. Dismissed by the first
# gameplay input (_physics_process). Gated on loadout != null by the
# caller, so arc-2/3 never builds it.
func _build_shell_codex(canvas: CanvasLayer) -> void:
	_shell_codex = ColorRect.new()
	_shell_codex.name = "ShellCodex"
	_shell_codex.position = Vector2(28, 26)
	_shell_codex.size = Vector2(264, 206)
	_shell_codex.color = Color(0.05, 0.05, 0.08, 0.96)
	canvas.add_child(_shell_codex)
	_codex_line(_shell_codex, "BREACH ECONOMY", Vector2(12, 8), 13,
		Color(1.0, 0.95, 0.6, 1.0))
	_codex_line(_shell_codex, "Shells are finite. Spend them to open the next lane.",
		Vector2(12, 27), 8, Color(0.82, 0.84, 0.9, 1.0))
	var rows: Array = [
		[BulletT.SHELL_CLASS_AP, "AP - cheap, precise. Your default shell."],
		[BulletT.SHELL_CLASS_HE, "HE - blast. Opens BRICK walls fast."],
		[BulletT.SHELL_CLASS_HEAT, "HEAT - 2x vs armor. Kills ARMORED heavies."],
		[BulletT.SHELL_CLASS_APCR, "APCR - the only shell that breaches STEEL."],
	]
	for i in rows.size():
		var row_y: float = 48.0 + float(i) * 29.0
		var chip: ColorRect = ColorRect.new()
		chip.position = Vector2(14, row_y + 3.0)
		chip.size = Vector2(10, 10)
		chip.color = _shell_color(rows[i][0])
		_shell_codex.add_child(chip)
		_codex_line(_shell_codex, rows[i][1], Vector2(32, row_y), 9, Color.WHITE)
	# arc-4 iter 50 (Round 7c): run-route line — teaches that the climb
	# is a shuffled band sequence (playtest finding 2); pairs with the
	# persistent route strip.
	_codex_line(_shell_codex, "ROUTE  5 depth bands; the middle 3 reshuffle each run.",
		Vector2(12, 150), 8, Color(0.85, 0.88, 0.6, 1.0))
	# arc-4 iter 51 (Round 7d, playtest finding 3 — "what can be
	# unlocked?"): the meta-progression unlock ladder.
	_build_unlock_ladder(MetaProgressT.best_depth())
	_codex_line(_shell_codex, "TAB swaps shells.  Move or fire to begin.",
		Vector2(12, 190), 8, Color(0.78, 0.8, 0.86, 1.0))


# arc-4 iter 51 (Round 7d, playtest finding 3 — "what can be
# unlocked?"): render the meta-progression unlock ladder into the shell
# codex — a header naming the player's best depth, then one cell per
# unlock tier (green = the best depth has reached it, dark = still
# locked). Replaces the iter-45 single (vague) meta line. Static within
# a run (best_depth only changes between runs), so it is built once
# with no update path.
func _build_unlock_ladder(best: int) -> void:
	if _shell_codex == null:
		return
	_codex_line(_shell_codex,
		"UNLOCKS  best depth %d  —  climb to earn depot options:" % best,
		Vector2(12, 161), 8, Color(0.62, 0.82, 1.0, 1.0))
	var ladder: Array = MetaProgressT.unlock_ladder()
	var cell_w: float = 60.0
	for i in ladder.size():
		var tier: Dictionary = ladder[i]
		var depth: int = int(tier["depth"])
		var unlocked: bool = best >= depth
		var cx: float = 12.0 + float(i) * cell_w
		var cell: ColorRect = ColorRect.new()
		cell.position = Vector2(cx, 172)
		cell.size = Vector2(cell_w - 3.0, 13.0)
		cell.color = Color(0.24, 0.5, 0.3, 0.92) if unlocked else Color(0.16, 0.16, 0.2, 0.92)
		_shell_codex.add_child(cell)
		var lbl: Label = Label.new()
		lbl.position = Vector2(cx + 3.0, 172.0)
		lbl.size = Vector2(cell_w - 7.0, 13.0)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.text = "%d %s" % [depth, String(tier["name"])]
		var fc: Color = Color(0.96, 1.0, 0.92, 1.0) if unlocked else Color(0.58, 0.58, 0.64, 1.0)
		lbl.add_theme_color_override("font_color", fc)
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		lbl.add_theme_constant_override("outline_size", 2)
		lbl.add_theme_font_size_override("font_size", 7)
		_shell_codex.add_child(lbl)


# arc-4 iter 42 (Round 6d): the breach level reports a band crossing.
func _on_breach_band_changed(band) -> void:
	if band != null:
		_show_band_banner(band)
		_update_route_for_band(band)
		# arc-4 iter 82 (Round 11 Phase 1): record the band crossing
		# into the run recap's per-band visit log for CONSULT-009
		# band-shape analysis.
		# arc-4 iter 095 (P1-4 fix): the previous code overwrote
		# run_recap.archetype on every band crossing, contradicting
		# the documented "at run start" contract. Removed. Run-start
		# capture lives in _ready (line ~244) and _pick_archetype
		# (line ~769) now.
		if run_recap != null and "band_name" in band:
			run_recap.enter_band(String(band.band_name))


# arc-4 iter 42 (Round 6d, stakes & escalation): the band-arrival banner.
# When the player crosses into a new depth band, name it + its dominant
# pressure for ~2s — each band is a new climb problem (CONSULT §9 #5)
# and the transition is the escalation beat the run is built around.
func _show_band_banner(band) -> void:
	var canvas: CanvasLayer = $HUD if has_node("HUD") else null
	if canvas == null:
		return
	var nm: String = ""
	var pressure: String = ""
	if "band_name" in band:
		nm = String(band.band_name).to_upper().replace("_", " ")
	if "dominant_pressure" in band:
		pressure = String(band.dominant_pressure)
	# arc-4 iter 102 (P1-C fix): free any prior live banner before
	# spawning the next. A Y-boundary-oscillating player can emit
	# breach_band_changed every few frames; the tween's 1.3s interval
	# + 0.9s fade meant Labels stacked on the HUD layer until the
	# slowest tween finished. Track + free.
	if _band_banner != null and is_instance_valid(_band_banner):
		_band_banner.queue_free()
	var banner: Label = Label.new()
	banner.name = "BandBanner"
	banner.text = "ENTERING:  %s\n%s" % [nm, pressure]
	banner.position = Vector2(20, 58)
	banner.size = Vector2(280, 40)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6, 1.0))
	banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	banner.add_theme_constant_override("outline_size", 2)
	banner.add_theme_font_size_override("font_size", 11)
	canvas.add_child(banner)
	_band_banner = banner
	var tween: Tween = banner.create_tween()
	tween.tween_interval(1.3)
	tween.tween_property(banner, "modulate:a", 0.0, 0.9)
	tween.tween_callback(banner.queue_free)


# arc-4 iter 50 (Round 7c): the run's ordered band list, read from the
# breach level's (post-shuffle) breach_config. Empty when there is no
# breach level / config — the route strip then never builds.
func _run_band_route() -> Array:
	var lvl: Node = get_parent()
	if lvl == null or not ("breach_config" in lvl):
		return []
	var cfg = lvl.breach_config
	if cfg == null or not ("bands" in cfg):
		return []
	return cfg.bands


# arc-4 iter 50: a short, legible name for a depth band — the route
# strip cells are ~63px wide, too narrow for the full two-word names.
func _band_short_name(band) -> String:
	if band == null or not ("band_name" in band):
		return "?"
	var raw: String = String(band.band_name)
	var short_names: Dictionary = {
		"tutorial_choke": "CHOKE",
		"brick_maze": "MAZE",
		"bunker_zone": "BUNKER",
		"open_killbox": "KILLBOX",
		"endgame_mixed": "ENDGAME",
	}
	if short_names.has(raw):
		return short_names[raw]
	var parts: PackedStringArray = raw.split("_", false)
	if parts.size() > 0:
		return String(parts[parts.size() - 1]).to_upper()
	return raw.to_upper()


# arc-4 iter 50 (Round 7c, playtest finding 2 — "no idea what band
# shuffle means"): the persistent run-route strip. One cell per depth
# band, named in THIS run's order, so the player sees the run is a
# specific shuffled sequence — and a different one next run. Built
# deferred (see _ready); gated on loadout != null by the caller, so
# arc-2/3 builds nothing.
func _build_route_strip() -> void:
	if loadout == null:
		return
	var canvas: CanvasLayer = $HUD if has_node("HUD") else null
	if canvas == null:
		return
	_route_bands = _run_band_route()
	if _route_bands.is_empty():
		return
	_route_panel = ColorRect.new()
	_route_panel.name = "RoutePanel"
	_route_panel.position = Vector2(2, 195)
	_route_panel.size = Vector2(316, 13)
	_route_panel.color = Color(0.07, 0.07, 0.09, 0.82)
	canvas.add_child(_route_panel)
	var n: int = _route_bands.size()
	var cell_w: float = 316.0 / float(n)
	for i in n:
		var bg: ColorRect = ColorRect.new()
		bg.position = Vector2(float(i) * cell_w + 1.0, 1.0)
		bg.size = Vector2(cell_w - 2.0, 11.0)
		bg.color = Color(0, 0, 0, 0)
		_route_panel.add_child(bg)
		_route_cell_bgs.append(bg)
		var lbl: Label = Label.new()
		lbl.position = Vector2(float(i) * cell_w + 3.0, 0.0)
		lbl.size = Vector2(cell_w - 6.0, 13.0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.text = _band_short_name(_route_bands[i])
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		lbl.add_theme_constant_override("outline_size", 2)
		lbl.add_theme_font_size_override("font_size", 8)
		_route_panel.add_child(lbl)
		_route_cell_labels.append(lbl)
	# initial highlight — the run starts in the level's current band.
	var start_idx: int = 0
	var lvl: Node = get_parent()
	if lvl != null and "_current_breach_band" in lvl and lvl._current_breach_band != null:
		var ci: int = _route_bands.find(lvl._current_breach_band)
		if ci >= 0:
			start_idx = ci
	_highlight_route_cell(start_idx)
	# the strip lives behind the run-start codex; revealed on dismiss.
	_route_panel.visible = _shell_codex == null or not _shell_codex.visible


# arc-4 iter 50: paint the route strip — cleared bands behind `idx`
# tinted, the current band bright, bands ahead plain.
# arc-4 iter 104 (P2-C fix from code-review-iter-100): track the
# highest idx ever reached so cells visited then retreated-from
# keep their "cleared" tint. Before: `i < idx` lost the cleared
# tint on retreat; now `i <= _route_max_cleared_idx and i != idx`
# preserves the cleared-band visual across non-monotonic Y motion.
func _highlight_route_cell(idx: int) -> void:
	if idx > _route_max_cleared_idx:
		_route_max_cleared_idx = idx
	for i in _route_cell_bgs.size():
		if i == idx:
			_route_cell_bgs[i].color = Color(0.95, 0.95, 0.55, 0.5)
			_route_cell_labels[i].modulate = Color(1, 1, 1, 1)
		elif i <= _route_max_cleared_idx:
			_route_cell_bgs[i].color = Color(0.32, 0.55, 0.36, 0.4)
			_route_cell_labels[i].modulate = Color(1, 1, 1, 0.6)
		else:
			_route_cell_bgs[i].color = Color(0, 0, 0, 0)
			_route_cell_labels[i].modulate = Color(1, 1, 1, 0.85)


# arc-4 iter 50: move the route-strip highlight when the player crosses
# into a new band.
func _update_route_for_band(band) -> void:
	if _route_panel == null or _route_bands.is_empty():
		return
	var idx: int = _route_bands.find(band)
	if idx >= 0:
		_highlight_route_cell(idx)


func _on_hp_changed_hud(new_hp: int, the_max_hp: int) -> void:
	if _hp_label != null:
		_hp_label.text = "HP %d/%d" % [new_hp, the_max_hp]
	# iter 49: update bar width + low-HP color shift (anchor 4 partial)
	if _hp_bar_fg != null and the_max_hp > 0:
		var ratio: float = clampf(float(new_hp) / float(the_max_hp), 0.0, 1.0)
		_hp_bar_fg.size = Vector2(32.0 * ratio, 4.0)
		if ratio < 0.34:
			_hp_bar_fg.color = Color(0.95, 0.25, 0.25, 1.0)  # red at low HP
		else:
			_hp_bar_fg.color = Color(0.3, 0.9, 0.3, 1.0)  # green otherwise


func _update_run_hud() -> void:
	if _depth_label != null:
		var depth: int = int(maxf(0.0, (_start_y - _min_y_reached) / 16.0))
		_depth_label.text = "DEPTH %d" % depth
		# iter 30: milestone flash on every Nth depth row crossing.
		# iter 101 (review-fix): cross-detection instead of equality — depth
		# jumping 9→11 in one frame would silently skip the "10" landmark
		# under the old `depth % step == 0` test.
		if depth_milestone_step > 0 and depth > 0 and depth - _last_milestone_depth >= depth_milestone_step:
			var crossed: int = (depth / depth_milestone_step) * depth_milestone_step
			_last_milestone_depth = crossed
			_flash_depth_milestone(crossed)
		# arc-4 iter 42: best-depth live readout — once the run passes the
		# prior best, the label live-tracks the new record.
		if _best_label != null:
			if depth > _run_best_depth:
				_best_label.text = "NEW BEST %d" % depth
			else:
				_best_label.text = "BEST %d" % _run_best_depth
	if _time_label != null:
		var t: int = int(_run_time)
		_time_label.text = "TIME %d:%02d" % [t / 60, t % 60]
	# arc-4 iter 35: refresh the shell panel — current shell + reserves.
	# Only when a loadout exists (the panel is null otherwise).
	if _shell_panel != null and loadout != null:
		_update_shell_panel()
	# arc-4 iter 56 (Round 8a): accrue XP from kills + depth.
	_tick_xp()


# arc-4 iter 56 (Round 8a): accrue XP from enemy kills + depth climbed,
# then grant it. Breach-mode only; called every run-HUD tick.
func _tick_xp() -> void:
	if loadout == null:
		return
	var gained: int = 0
	var depth: int = int(maxf(0.0, (_start_y - _min_y_reached) / 16.0))
	if depth > _xp_depth_counted:
		gained += (depth - _xp_depth_counted) * XP_PER_DEPTH_ROW
		_xp_depth_counted = depth
	if _spawner != null and "enemies_killed" in _spawner:
		var kills: int = int(_spawner.enemies_killed)
		if kills > _xp_kills_counted:
			gained += (kills - _xp_kills_counted) * XP_PER_KILL
			_xp_kills_counted = kills
	_grant_xp(gained)


# arc-4 iter 56: add XP; each threshold crossing levels up + applies an
# automatic stat boost. Public so the harness can drive it directly.
func _grant_xp(amount: int) -> void:
	if amount <= 0 or loadout == null:
		return
	_xp += amount
	while _xp >= _xp_to_next:
		_xp -= _xp_to_next
		_level += 1
		_xp_to_next = XP_BASE + (_level - 1) * XP_STEP
		_apply_level_boost(_level)
	_update_xp_hud()


# arc-4 iter 103 (P1-E + P1-F fixes from code-review-iter-100):
# cap the level-up max-cap growth at sane ceilings so a long run
# can't inflate max_hp / max_*_reserve without bound. Starting
# values: max_hp=3, max_he=6, max_heat=3, max_apcr=4. Ceilings
# chosen for ~5-7 level-ups of headroom per axis. When at ceiling,
# the level-up still grants a refill (full heal / full reserve
# top-up) so the boost is never a silent no-op.
const MAX_HP_CEILING: int = 8
const MAX_HE_RESERVE_CEILING: int = 12
const MAX_HEAT_RESERVE_CEILING: int = 8
const MAX_APCR_RESERVE_CEILING: int = 10


# arc-4 iter 56: the level-up stat boost — AUTOMATIC (no mid-combat
# modal, so CONSULT constraint 1 holds), rotated across a small legible
# set: max HP / reload speed / shell capacity.
func _apply_level_boost(level: int) -> void:
	var kind: int = (level - 2) % 3  # level 2 is the first level-up
	var msg: String = ""
	if kind == 0:
		# arc-4 iter 103 (P1-F fix): clamp max_hp to MAX_HP_CEILING;
		# if at cap, fall back to full heal so the level-up still
		# rewards the player.
		if max_hp < MAX_HP_CEILING:
			max_hp += 1
			hp += 1
			msg = "+1 MAX HP"
		else:
			hp = max_hp
			msg = "FULL HEAL"
		hp_changed.emit(hp, max_hp)
	elif kind == 1:
		# arc-4 iter 092 (P0-2 fix): accumulate the reload reduction
		# in _reload_reduction (so it survives archetype switches),
		# then derive the current GunTimer.wait_time from per-archetype
		# base − reduction (floored at RELOAD_MIN).
		_reload_reduction += RELOAD_STEP
		var gt: Timer = $GunTimer
		var arch_base: float = MORTAR_GUN_COOLDOWN if archetype == TankArchetype.MORTAR else _base_default_gun_wait_time
		gt.wait_time = maxf(RELOAD_MIN, arch_base - _reload_reduction)
		msg = "FASTER RELOAD"
	else:
		if loadout != null:
			# arc-4 iter 103 (P1-E fix): per-shell ceiling clamp.
			# Each max_*_reserve only grows if below its ceiling.
			# The refill always fires (so an at-cap player still
			# gets a full top-up — meaningful reward).
			var grew: int = 0
			if loadout.max_he_reserve < MAX_HE_RESERVE_CEILING:
				loadout.max_he_reserve += 1
				grew += 1
			if loadout.max_heat_reserve < MAX_HEAT_RESERVE_CEILING:
				loadout.max_heat_reserve += 1
				grew += 1
			if loadout.max_apcr_reserve < MAX_APCR_RESERVE_CEILING:
				loadout.max_apcr_reserve += 1
				grew += 1
			loadout.refill_he(1)
			loadout.refill_heat(1)
			loadout.refill_apcr(1)
			msg = "+SHELL CAP" if grew > 0 else "+SHELL REFILL"
		else:
			msg = "+SHELL CAP"
	_show_pickup_toast("LEVEL %d  %s" % [level, msg], Color(1.0, 0.9, 0.35, 1.0))


# arc-4 iter 56: refresh the XP bar + level readout.
func _update_xp_hud() -> void:
	if _level_label != null:
		_level_label.text = "LVL %d" % _level
	if _xp_bar_fg != null and _xp_to_next > 0:
		var ratio: float = clampf(float(_xp) / float(_xp_to_next), 0.0, 1.0)
		_xp_bar_fg.size = Vector2(88.0 * ratio, 2.0)


# iter 30 (Pro Consult 005 META — "readable upward intent"): when player
# crosses a depth milestone (multiple of depth_milestone_step), briefly
# scale + recolor the DEPTH label. Cues the climb visually.
# iter 77: flash color now band-themed (matches iter-64 band markers +
# iter-65 themed gates). Composes with other visual band cues.
func _flash_depth_milestone(d: int) -> void:
	if _depth_label == null:
		return
	# iter 92 (visual budget): peak scale 1.8 → 1.4 (less dramatic flash)
	var band_color: Color = _band_color_for_depth(d)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_depth_label, "scale", Vector2(1.4, 1.4), 0.12)
	tween.tween_property(_depth_label, "modulate", band_color, 0.12)
	tween.chain().set_parallel(true)
	tween.tween_property(_depth_label, "scale", Vector2.ONE, 0.4)
	tween.tween_property(_depth_label, "modulate", Color.WHITE, 0.4)


# iter 77: maps depth → band color matching Spawner._band_color_for_depth.
# Kept inline (small fn) to avoid cross-script coupling for visual logic.
func _band_color_for_depth(d: int) -> Color:
	if d < 8:
		return Color(0.6, 0.9, 0.6, 1.0)       # warmup green
	if d < 20:
		return Color(1.0, 0.95, 0.5, 1.0)      # first_push yellow
	if d < 40:
		return Color(1.0, 0.55, 0.2, 1.0)      # heavy_gate orange
	return Color(1.0, 0.35, 0.35, 1.0)         # rush red


# BC forest convention: tank is concealed (low alpha) when standing on a grass
# cell. Grass tilemap has no collision; tanks drive freely over it.
func _update_forest_hide() -> void:
	if _is_flashing or _grass_tilemap == null or sprite == null:
		return
	var local_pos: Vector2 = _grass_tilemap.to_local(global_position)
	var cell: Vector2i = _grass_tilemap.local_to_map(local_pos)
	var source_id: int = _grass_tilemap.get_cell_source_id(cell)
	sprite.modulate.a = forest_hidden_alpha if source_id != -1 else forest_visible_alpha
