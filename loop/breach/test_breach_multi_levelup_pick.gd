# arc-4 PR-#4 P1 review fix regression — multi-level-up in one XP
# grant used to silently discard picks. _grant_xp's while-loop called
# _show_levelup_pick once per threshold crossed; each call overwrote
# _levelup_choices + re-armed the pause inside the same frame, so
# only the LAST panel survived — owed N, got 1.
#
# Fix: count threshold crossings + show one panel now + queue the rest
# via _pending_levelup_picks; _pick_levelup_card re-shows the next
# from the queue.
#
# 4 cases:
#   1. Single level-up (XP just crosses one threshold) — _pending=0
#      after the show; pick → no re-show.
#   2. Triple level-up (XP grant crosses 3 thresholds) — first panel
#      visible immediately; _pending_levelup_picks == 2 after first
#      show; pick → _pending == 1 + new panel visible; pick →
#      _pending == 0 + new panel; pick → no re-show.
#   3. Each of the 3 picks calls _apply_card (so the player gets all
#      3 cards owed, not just 1 like the pre-fix behavior).
#   4. pick_card_on_levelup=false path: auto-boost still runs once per
#      level; no pick UI shown; _pending_levelup_picks stays 0.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_multi_levelup_pick.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")


func _make(pick_card: bool) -> Node:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	pt.pick_card_on_levelup = pick_card
	root.add_child(pt)
	return pt


func _initialize() -> void:
	# === Case 1: single level-up.
	var pt1 := _make(true)
	await process_frame
	# XP_BASE=60 → just over crosses one threshold (level 1 → 2).
	pt1._grant_xp(pt1.XP_BASE)
	if pt1._level != 2:
		push_error("FAIL — single grant: level=%d (want 2)" % pt1._level)
		quit(1); return
	if pt1._pending_levelup_picks != 0:
		push_error("FAIL — single grant: _pending_levelup_picks=%d (want 0)" % pt1._pending_levelup_picks)
		quit(1); return
	if not pt1._levelup_picking:
		push_error("FAIL — single grant: pick UI not active")
		quit(1); return
	pt1._pick_levelup_card(0)
	if pt1._pending_levelup_picks != 0:
		push_error("FAIL — after single pick: _pending=%d (want 0; queue should be empty)" % pt1._pending_levelup_picks)
		quit(1); return
	if pt1._levelup_picking:
		push_error("FAIL — after single pick: pick UI still active (no re-show expected)")
		quit(1); return
	print("  case 1: single level-up → 1 pick UI → pick → done")
	pt1.queue_free()
	await process_frame

	# === Case 2 + 3: triple level-up grant.
	var pt2 := _make(true)
	await process_frame
	# Enough for 3 levels: thresholds 60 (lvl2), 90 (lvl3), 120 (lvl4) = 270.
	# Grant 300 to be safe — guarantees 3 thresholds crossed.
	pt2._grant_xp(300)
	if pt2._level != 4:
		push_error("FAIL — triple grant: level=%d (want 4 = 1 + 3 crossings)" % pt2._level)
		quit(1); return
	# After the first _show_levelup_pick: _pending should be 2 (3 owed - 1 showing).
	if pt2._pending_levelup_picks != 2:
		push_error("FAIL — triple grant: _pending=%d (want 2 = 3 owed minus 1 showing)" % pt2._pending_levelup_picks)
		quit(1); return
	if not pt2._levelup_picking:
		push_error("FAIL — triple grant: first pick UI not active")
		quit(1); return
	# Track _applied_cards growth to verify ALL 3 picks land.
	var cards_pre: int = pt2._applied_cards.size()
	# Pick first card.
	pt2._pick_levelup_card(0)
	if pt2._pending_levelup_picks != 1:
		push_error("FAIL — after 1st pick: _pending=%d (want 1)" % pt2._pending_levelup_picks)
		quit(1); return
	if not pt2._levelup_picking:
		push_error("FAIL — after 1st pick: re-show should activate next pick UI")
		quit(1); return
	# Pick second card.
	pt2._pick_levelup_card(0)
	if pt2._pending_levelup_picks != 0:
		push_error("FAIL — after 2nd pick: _pending=%d (want 0)" % pt2._pending_levelup_picks)
		quit(1); return
	if not pt2._levelup_picking:
		push_error("FAIL — after 2nd pick: re-show should activate last pick UI")
		quit(1); return
	# Pick third card.
	pt2._pick_levelup_card(0)
	if pt2._pending_levelup_picks != 0:
		push_error("FAIL — after 3rd pick: _pending=%d (want 0; queue drained)" % pt2._pending_levelup_picks)
		quit(1); return
	if pt2._levelup_picking:
		push_error("FAIL — after 3rd pick: pick UI still active (queue not drained)")
		quit(1); return
	# All 3 picks landed → _applied_cards grew by 3.
	if pt2._applied_cards.size() - cards_pre != 3:
		push_error("FAIL — triple grant: _applied_cards grew by %d (want 3 cards applied total)" \
				% (pt2._applied_cards.size() - cards_pre))
		quit(1); return
	print("  case 2+3: triple level-up → 3 sequential picks → all 3 cards applied (regression locked)")
	pt2.queue_free()
	await process_frame

	# === Case 4: pick_card_on_levelup=false → no pick UI, auto-boost only.
	var pt4 := _make(false)
	await process_frame
	pt4._grant_xp(300)  # multi-level threshold cross
	if pt4._pending_levelup_picks != 0:
		push_error("FAIL — pick_card_on_levelup=false: _pending=%d (want 0)" % pt4._pending_levelup_picks)
		quit(1); return
	if pt4._levelup_picking:
		push_error("FAIL — pick_card_on_levelup=false: pick UI active (should never show)")
		quit(1); return
	print("  case 4: pick_card_on_levelup=false → auto-boost only, no pick UI")

	print("BREACH_MULTI_LEVELUP_PICK_OK 4 cases — single + triple + all-picks-land + flag-off")
	quit(0)
