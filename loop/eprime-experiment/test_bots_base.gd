extends SceneTree

# U1 verifier (AC-001 contract foundation) — proves the bot contract exists and
# has oracle teeth. Three things are asserted:
#   1. BotAction / BotObservation / BotPolicy types load (parse-fails RED until
#      the three scripts/bots/*.gd files exist — that is the red->green proof).
#   2. BotAction.is_valid() REJECTS a malformed action (move_dir out of range,
#      shell_swap_to out of range). If is_valid() were a rubber stamp, this case
#      fails — that is the verifier's teeth (oracle principle #2).
#   3. BotObservation instantiates with empty arrays (no crash) and BotPolicy is
#      a Resource whose tick() returns a BotAction (never a bare null).
#
# Emits `BOTS_BASE_OK` on full pass; quit(1) on any failure.

func _initialize() -> void:
	var failures: int = 0

	# --- 1. BotAction valid construction + field reads ---
	var a := BotAction.new(Constants.Dir.U, true, Bullet_SHELL_HE())
	if a.move_dir != Constants.Dir.U or a.fire != true or a.shell_swap_to != 1:
		print("  FAIL — BotAction field reads wrong: dir=%d fire=%s swap=%d" % [a.move_dir, a.fire, a.shell_swap_to])
		failures += 1
	else:
		print("  case BotAction-construct OK")
	if not a.is_valid():
		print("  FAIL — valid BotAction reported invalid")
		failures += 1

	# default (stationary, no fire, no swap) is valid
	var idle := BotAction.new()
	if idle.move_dir != BotAction.NONE or idle.fire != false or idle.shell_swap_to != BotAction.NO_SWAP:
		print("  FAIL — BotAction defaults wrong")
		failures += 1
	if not idle.is_valid():
		print("  FAIL — idle BotAction reported invalid")
		failures += 1
	else:
		print("  case BotAction-idle OK")

	# --- 2. TEETH: malformed actions must be REJECTED ---
	var bad_dir := BotAction.new(99, false, -1)        # move_dir out of Dir range
	if bad_dir.is_valid():
		print("  FAIL — TEETH: out-of-range move_dir accepted (is_valid rubber-stamped)")
		failures += 1
	else:
		print("  case TEETH-bad-dir rejected OK")
	var bad_swap := BotAction.new(BotAction.NONE, false, 7)  # shell_swap_to out of 0..3
	if bad_swap.is_valid():
		print("  FAIL — TEETH: out-of-range shell_swap_to accepted")
		failures += 1
	else:
		print("  case TEETH-bad-swap rejected OK")

	# --- 3. BotObservation empty-array safety ---
	var obs := BotObservation.new()
	if obs.visible_enemies.size() != 0 or obs.visible_projectiles.size() != 0 or obs.visible_obstacles.size() != 0:
		print("  FAIL — BotObservation default arrays not empty")
		failures += 1
	else:
		print("  case BotObservation-empty OK")

	# --- 4. BotPolicy is a Resource exposing tick() (the @export-assignable base) ---
	# We do NOT call the abstract base tick() here — its override is enforced by
	# check-bots (U6), where every shipped policy must return a triggering action.
	var p := BotPolicy.new()
	if not (p is Resource):
		print("  FAIL — BotPolicy is not a Resource")
		failures += 1
	elif not p.has_method("tick"):
		print("  FAIL — BotPolicy has no tick() method")
		failures += 1
	else:
		print("  case BotPolicy-contract OK")

	if failures == 0:
		print("BOTS_BASE_OK")
		quit(0)
	else:
		print("BOTS_BASE_FAIL %d failures" % failures)
		quit(1)


# Local mirror of Bullet.SHELL_CLASS_HE (=1) so the test does not depend on
# Bullet preload semantics; verified against scripts/Bullet.gd:12.
func Bullet_SHELL_HE() -> int:
	return 1
