class_name BotPolicy
extends Resource

# Abstract base for the 7 deterministic bot policies (AC-001). Each policy is a
# pure function of observation -> action with NO mutable state between ticks
# (deterministic + unit-testable). NOT LLM-controlled: per /agentify Pro
# 2026-05-27 §3 the LLM operates BETWEEN runs, never inside the frame loop.
#
# Resource (not RefCounted) so each bot is `@export`-assignable and ships as a
# .tres instance the harness loads by path — mirrors the repo's
# class_name + extends Resource + @export convention (scripts/LevelConfig.gd).
#
# Subclasses MUST override tick(). The base returns a stationary BotAction (and
# logs) rather than crashing, so a misconfigured harness fails loud-but-safe;
# real abstractness is enforced by check-bots (U6): every shipped policy must
# return a non-default action for a triggering observation.

# Human-readable id, e.g. "move-to-cover". Subclasses set this in their _init.
@export var bot_id: String = "base"


func tick(_obs: BotObservation) -> BotAction:
	push_warning("BotPolicy.tick() is abstract — subclass %s must override; returning stationary" % bot_id)
	return BotAction.new()
