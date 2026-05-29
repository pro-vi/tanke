class_name BotInputDriver
extends Node

# (Path B / AR-001) The bot-input hook — a SIBLING of PlayerTank, NOT a
# PlayerTank modification. Each physics tick it builds a BotObservation, asks
# its policy for a BotAction, and synthesizes the corresponding keyboard input
# via Input.parse_input_event. PlayerTank reads that input through the same
# Input singleton a human keyboard feeds (is_action_pressed for ui_*,
# is_physical_key_pressed for TAB) — so no in-tank change is needed.
#
# Input recipe verified in iter-1 probe: set BOTH .keycode AND .physical_keycode
# (covers the ui_* action path AND the physical-key path), and PAIR every press
# with a release (held keys persist otherwise). The driver tracks held state so
# it only emits press/release on CHANGE — a held direction keeps the tank moving
# and a held fire auto-fires at the GunTimer cooldown, matching human play.

# Set by the runner (the policy lives HERE, not on PlayerTank).
var bot_policy: BotPolicy = null
var player: Node = null   # PlayerTank sibling (observation source)
var level: Node = null    # parent level (enemy / projectile / obstacle scan)

var _iter_n: int = 0
var _run_start_ms: int = 0

# motor-level stuck-recovery state (see _unstick)
const STUCK_TICKS := 6           # ticks of zero displacement before slipping
var _last_pos := Vector2.INF
var _stuck_ticks: int = 0
var _slip_side: int = 0          # index into perpendiculars(); flips if still stuck

# The most recent action applied — read by TelemetryRecorder for
# ui_action_correlation + reload_cancel accounting (sibling, optional).
var last_action: BotAction = null

# Held-input state: only send press/release on change.
var _held_dir_keycode: int = 0   # 0 = none held
var _fire_held: bool = false
var _tab_held: bool = false

const _DIR_KEY := {
	Constants.Dir.U: KEY_UP,
	Constants.Dir.D: KEY_DOWN,
	Constants.Dir.L: KEY_LEFT,
	Constants.Dir.R: KEY_RIGHT,
}


func _ready() -> void:
	_run_start_ms = Time.get_ticks_msec()
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("PlayerTank")
	if level == null:
		level = get_parent()
	if bot_policy == null:
		push_warning("BotInputDriver: bot_policy not set; tank will be idle")


func _physics_process(_delta: float) -> void:
	if bot_policy == null or player == null or not is_instance_valid(player):
		return
	_iter_n += 1
	var obs := ObservationBuilder.build(
		player, level, _iter_n, (Time.get_ticks_msec() - _run_start_ms) / 1000.0)
	var action: BotAction = bot_policy.tick(obs)
	if action == null:
		action = BotAction.new()  # null policy output -> idle (safe)
	action = _unstick(action)
	apply_action(action, obs.current_shell_class)


# Motor-level stuck recovery (NOT strategy — that stays in the policy). The
# policies reason at 8px tile granularity, but the tank is 16px (2 cells) wide,
# so it can wedge on a wall's flank while the tile check thinks the path is
# clear; being stateless, a policy can't notice it stopped moving. Here the
# driver watches actual displacement: if it commanded a move but the tank didn't
# move for a few ticks, slip to a perpendicular (alternating sides) to slide off
# the wall. Deterministic (no RNG) → reproducible. Per-run state (fresh driver
# per run) so nothing leaks across the 84 reloads.
func _unstick(action: BotAction) -> BotAction:
	if not is_instance_valid(player):
		return action
	var pos: Vector2 = player.global_position
	if action.move_dir != BotAction.NONE and _last_pos != Vector2.INF and pos.distance_to(_last_pos) < 0.5:
		_stuck_ticks += 1
	else:
		_stuck_ticks = 0
	_last_pos = pos
	if _stuck_ticks >= STUCK_TICKS and action.move_dir != BotAction.NONE:
		var perps := BotHeuristics.perpendiculars(action.move_dir)
		if _stuck_ticks >= STUCK_TICKS * 3:  # slip didn't work -> try the other side
			_slip_side = 1 - _slip_side
			_stuck_ticks = STUCK_TICKS
		return BotAction.new(perps[_slip_side], action.fire, action.shell_swap_to)
	return action


# Synthesize input for a single action. Public so the unit verifier can drive it
# without a full scene. `current_shell` (Bullet.SHELL_CLASS_* or -1 if unknown)
# lets the shell-swap pulse stop once the requested shell is selected.
func apply_action(action: BotAction, current_shell: int = -1) -> void:
	last_action = action
	# --- movement (held until direction changes) ---
	var want_key: int = 0
	if action.move_dir != BotAction.NONE and _DIR_KEY.has(action.move_dir):
		want_key = _DIR_KEY[action.move_dir]
	if want_key != _held_dir_keycode:
		if _held_dir_keycode != 0:
			_send_key(_held_dir_keycode, false)
		if want_key != 0:
			_send_key(want_key, true)
		_held_dir_keycode = want_key

	# --- fire (held; PlayerTank auto-fires at cooldown while ui_accept down) ---
	if action.fire and not _fire_held:
		_send_key(KEY_SPACE, true)
		_fire_held = true
	elif not action.fire and _fire_held:
		_send_key(KEY_SPACE, false)
		_fire_held = false

	# --- shell swap: pulse physical TAB so PlayerTank's _tab_was_pressed rising
	# edge fires _cycle_shell once per 2-tick pulse; cycles toward the target
	# over successive ticks. STOP once the requested shell is selected (or if
	# already on it) so it doesn't overshoot/cycle past the target. current_shell
	# == -1 (unknown) keeps pulsing while requested. (Codex PR#5 P2.)
	var want_swap := action.shell_swap_to != BotAction.NO_SWAP and action.shell_swap_to != current_shell
	if want_swap and not _tab_held:
		_send_key(KEY_TAB, true)
		_tab_held = true
	elif _tab_held:
		_send_key(KEY_TAB, false)
		_tab_held = false


func _send_key(keycode: int, pressed: bool) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.physical_keycode = keycode
	ev.pressed = pressed
	Input.parse_input_event(ev)


# Release every held input — call on teardown so a held key never leaks across
# the 84 scene reloads (U7).
func release_all() -> void:
	if _held_dir_keycode != 0:
		_send_key(_held_dir_keycode, false)
		_held_dir_keycode = 0
	if _fire_held:
		_send_key(KEY_SPACE, false)
		_fire_held = false
	if _tab_held:
		_send_key(KEY_TAB, false)
		_tab_held = false
