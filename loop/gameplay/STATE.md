# tanke — Gameplay Loop State

## Phase

```
phase: AWAITING_USER_PLAYTEST
iteration: 5
preloop_complete: yes
playtest_requested_iter: 5
```

---

## Preloop Checklist (cleared iter 0)

```
[x] F5 the scene; tank moves with WASD/arrows (user-confirmed iter 0)
[x] Scene loads without console errors (headless --quit exit 0, clean output)
[x] Reachability oracle reports playable: true (seed 42: reachable_cells=804, rows_climbed=29)
[x] project.godot run/main_scene flipped Level.tscn → ProceduralLevel.tscn (iter 0 preloop fix)
[~] Shooting KNOWN BROKEN — iter 1's job
```

---

## Substrate baseline (recorded iter 0)

Active scene config: `configs/playable.tres`
- empty 0.55 / brick 0.18 / steel 0.07 / grass 0.12 / water 0.08
- merge_probability 0.4
- Reachability at seed 42: reachable_cells **804**, rows_climbed **29**, **playable: true**
- Hash anchor (seed 42): `f873ae60ee3c420c57cdef5762acdad857b1a763ec50b76db80971ef4503e797`
- Engine-loop historical anchors for reference only: `6159ef2f5464edb1`, `1f80435080844dce` (post-iter-21), `8a4834679f9e4eb2` (biome_balanced)

Substrate freeze rule per `PROMPT.md`: do not modify `LevelConfig`,
`BiomeConfig`, `LevelDNA`, `ProceduralStep`, `ProceduralLevel` (the
procedural generation logic). Add new configs/scripts/scenes as needed.

**H1 tripwire (added iter 4 per GPT-Pro consult — see creative-consults.md):**
the literal-reading defense for `scenes/ProceduralLevel.tscn` ("only the
.gd is frozen") is *too convenient*. Per Pro: "the active procedural scene
is still the substrate fixture. Adding gameplay systems directly into it
blurs engine substrate and gameplay layer — the iter-28 failure mode in
softer form." Adopted stance: **≤3 gameplay-only sibling nodes** may live
inside ProceduralLevel.tscn before a mandatory refactor to either (a) a
`GameplayLayer` Node2D child that contains them all, or (b) a parent
scene `scenes/GameplayLevel.tscn` that instances ProceduralLevel.tscn.
Current count: 1 (Spawner). HurtBox + HUD are dynamic-in-PlayerTank and
don't count against this tripwire. Tripwire trigger likely iter 5-7.

---

## Current Scores

(Set at iter 1+ after BOOTSTRAP.)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Core loop closes | 2 | Anchor 3 (HP/death) in code iter 3; feel-criterion playtest rule caps at 2 |
| 2. Spawn / wave system | 1 | Iter 2: fixed-rate spawner, random angle around player |
| 3. HP + death model | 2 | Iter 3: HurtBox + HP numerically shown; anchor 2 exact |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 1 | Iter 2: one chaser type, naive move-and-slide |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None |
| 9. UI / UX | 1 | Iter 3: text HP HUD via CanvasLayer Label |
| 10. Build distinctness | 0 | No builds |
| **Total** | **7/50** | Iter 3 +3 (HP/HUD/death) |

---

## Open seams (iter 4+ priorities)

1. ~~**Bullet system broken.**~~ ✓ Fixed iter 1. Playtest validation iter 5.

2. ~~**No enemies.**~~ ✓ Iter 2. Predicted runtime miss (stuck on walls /
   BFS-unreachable spawns) deferred to iter 5 playtest.

3. ~~**No HP system.**~~ ✓ Iter 3. Real damage-detection wiring unverified
   (does HurtBox actually fire on enemy contact?) — iter 5 playtest.

4. ~~**No HUD.**~~ ✓ Iter 3 (anchor 1 only — text). Anchor 2 (HP bar +
   XP bar) needs XP system to exist first.

5. **No XP / level-up.** Iter 5+ work. Foundational for crit 4 + 5.

6. **No upgrade pool.** Foundational for criterion 5 and 10.

7. ~~**No death/restart flow.**~~ ✓ Iter 3 — `get_tree().reload_current_scene()`
   on R debounced. Restart correctness verified iter 5.

8. **Pending: integrate GPT Pro consult.** Fire-and-forget query sent
   end-of-iter-2 (key `tanke-iter-2-secondopinion`). Iter 4 first action:
   `agentify_status` + `agentify_read_page`, evaluate H1-H5 critique,
   integrate any material findings. First external evidence channel —
   primary falsification surface for the "all pre-mortems land exactly"
   pattern.

9. **No visual juice.** Crit 8 still at 0. Hit-flash on damage taken
   would be cheap: tween modulate red on take_damage. Iter 5+.

10. **No iframes visual indication.** Currently iframes work invisibly;
    player can't see when they're invincible. Tied to crit 8.

---

## Last Action

```
Iter 5 PLAYTEST request issued. AWAITING USER.
Build verified (godot --quit exit 0, make test clean). Run config
captured in LEDGER iter 005. User-facing playtest prompt output to chat;
5 independently observable claims (per H2 RULE) waiting on user report:
1. Bullets visibly travel + despawn on walls
2. Some enemies get stuck on walls
3. Output dock shows [spawner] rejections > 0 within 30s
4. HP drops on enemy contact + death triggers YOU DIED label
5. R-key restart returns to fresh state
No ScheduleWakeup. Halt rule fires if no response by iter 8.
```

---

## Stale Scores

None (new loop).

---

## Next Action

`AWAITING user playtest response.

On response (iter 6):
  - Read user report
  - For each of the 5 independently observable claims, mark
    LANDED / FALSIFIED / INDETERMINATE
  - Append FALSIFICATIONS.md entries for any falsified claim
  - Update score table per RUBRIC.md anchors using playtest evidence
    (feel-criterion >2 now unlocked for criteria the user validated)
  - Plan iter 7 BUILD targeting whichever broken thing was most
    surprising (priority: blockers > feel-criterion improvements >
    additional features)

If no user response by end-of-iter-8 (3 iters later): write HALTED.md per
PROMPT §"USER-LOOK PROTOCOL" halt rule; stop.`

---

## User-Look Gates

Per PROMPT user-look protocol:
- **Iter 5** (or first iter where shoot+move+enemies all work): mandatory PLAYTEST
- **Every 3 iters thereafter**: mandatory PLAYTEST
- **Halt rule**: 3 consecutive unfulfilled PLAYTEST requests → write `HALTED.md`, stop

The engine loop's biggest miss was 8 iters of open user-look gate without
enforcement. This loop halts hard at +3.

---

## Consult Log

None. First consult: iter 10. (External agentify failed twice in engine loop;
self-pre-mortem-in-writing is the proven fallback per iter-21 evidence.)

---

## Pre-mortems

`loop/gameplay/PRE-MORTEMS.md` — append-only record of each iter's "what I
expect this iter's biggest miss to be" prediction. Created at iter 1.

---

## Falsifications

`loop/gameplay/FALSIFICATIONS.md` — when user reaction contradicts a
pre-mortem, log it. The engine loop accumulated 4; expect more here on feel
axes where automated metrics can't help.
