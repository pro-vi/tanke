class_name BotRegistry
extends RefCounted

# The canonical bot_id -> policy mapping. Single source of truth for the 7
# shipped policies (AC-001), used by check-bots (U6), the batch runner (U7), and
# the orchestration entry point (U9). Code-driven (Path B / AR-001) — policies
# are instantiated with .new(), so no per-bot .tres files are needed.
#
# Order is the canonical bot order for the 84-run matrix (7 bots x 12 seeds).

const SCRIPTS := {
	"move-to-cover":     "res://scripts/bots/MoveToCoverBot.gd",
	"dodge-shell":       "res://scripts/bots/DodgeShellBot.gd",
	"approach-enemy":    "res://scripts/bots/ApproachEnemyBot.gd",
	"fire-when-lined-up":"res://scripts/bots/FireWhenLinedUpBot.gd",
	"reload-aware-wait": "res://scripts/bots/ReloadAwareWaitBot.gd",
	"panic-random":      "res://scripts/bots/PanicRandomBot.gd",
	"objective-rush":    "res://scripts/bots/ObjectiveRushBot.gd",
}

# Canonical ordering (Dictionary insertion order is preserved in GDScript, but
# expose an explicit list so callers don't depend on that).
const ORDER := [
	"move-to-cover", "dodge-shell", "approach-enemy", "fire-when-lined-up",
	"reload-aware-wait", "panic-random", "objective-rush",
]


static func ids() -> Array:
	return ORDER.duplicate()


static func has(bot_id: String) -> bool:
	return SCRIPTS.has(bot_id)


# Instantiate a fresh policy for `bot_id`, or null if unknown (callers MUST
# fail loud on null — no silent skip, per AC-007).
static func make(bot_id: String) -> BotPolicy:
	if not SCRIPTS.has(bot_id):
		return null
	var script = load(SCRIPTS[bot_id])
	if script == null:
		return null
	return script.new()
