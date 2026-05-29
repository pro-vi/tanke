class_name BotAction
extends RefCounted

# The single struct a BotPolicy emits per tick — the API the LLM-between-runs
# reads back from telemetry. One flat struct, no nested objects (clean to
# interpret post-run, clean to diff across iterations). See
# loop/eprime-experiment/iter-0-architect.md § Action contract.
#
# move_dir uses Constants.Dir (L=0, D=1, U=2, R=3 — note the non-cardinal
# enum order in scripts/Constants.gd:4). Constants.Dir has no NONE member, so
# NONE below is the stationary sentinel. shell_swap_to uses Bullet shell-class
# ints (AP=0, HE=1, HEAT=2, APCR=3 — scripts/Bullet.gd:11) with NO_SWAP for
# "keep current shell".

# Stationary sentinel for move_dir (Constants.Dir has no NONE).
const NONE: int = -1
# "do not change shell this tick" sentinel for shell_swap_to.
const NO_SWAP: int = -1

# Constants.Dir value or NONE.
var move_dir: int = NONE
# SPACE / ui_accept equivalent.
var fire: bool = false
# Bullet.SHELL_CLASS_* (0..3) or NO_SWAP.
var shell_swap_to: int = NO_SWAP


func _init(p_move_dir: int = NONE, p_fire: bool = false, p_shell_swap_to: int = NO_SWAP) -> void:
	move_dir = p_move_dir
	fire = p_fire
	shell_swap_to = p_shell_swap_to


# A well-formed action: move_dir is NONE or a real Constants.Dir (0..3);
# shell_swap_to is NO_SWAP or a real shell class (0..3). The bot harness'
# input synthesis assumes these ranges; an out-of-range action is a policy bug
# and must be rejected by the verifier (oracle teeth — see test_bots_base.gd).
func is_valid() -> bool:
	if move_dir != NONE and (move_dir < Constants.Dir.L or move_dir > Constants.Dir.R):
		return false
	if shell_swap_to != NO_SWAP and (shell_swap_to < 0 or shell_swap_to > 3):
		return false
	return true


func _to_string() -> String:
	return "BotAction(move_dir=%d, fire=%s, shell_swap_to=%d)" % [move_dir, fire, shell_swap_to]
