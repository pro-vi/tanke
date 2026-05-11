# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 3
preloop_complete: yes
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
Iter 3 BUILD complete. HP + HUD + death/restart:
- PlayerTank.gd: max_hp=3, damage_iframes=0.6, hp_changed/died signals,
  take_damage with iframe gate, _die freezes player + shows death label,
  R-restart with debounce (must release then press)
- Dynamic HurtBox Area2D (mask=8, layer=0, 12×12) created in _ready —
  avoids editing PlayerTank.tscn (still format=2)
- Dynamic HUD CanvasLayer with HP %d/%d label + hidden YOU DIED [R]
  RESTART label, all created in _ready
- Enemy.gd: add_to_group("enemy") so HurtBox detects via group check
Headless boot clean (carryover Bullet.gd UID warning, harmless).
Crit 3 → 2, crit 9 → 1; crit 1 holds at 2 (feel-criterion playtest cap).
Total 7/50.

Pending external evidence: agentify GPT-Pro consult (key
tanke-iter-2-secondopinion) was still mid-flight at commit. Iter 4 starts
by reading the response; integrates material critique if any.
Next: iter 4 AUDIT — read Pro response, re-score with oracle re-check.
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 4 AUDIT (with Pro-consult integration):
  - Pre-mortem to PRE-MORTEMS.md
  - FIRST: agentify_status + agentify_read_page for key
    tanke-iter-2-secondopinion. Read GPT-Pro critique of H1-H5.
  - If Pro response surfaces material issues:
    - Substrate-freeze critique (H1) — re-read META-RETRO §"What survives";
      either retract Spawner-in-tscn pattern or document why it's distinct
    - Pre-mortem credibility (H2) — restructure pre-mortems to predict
      something the *external evidence* (playtest, Pro) decides, not just
      my own scoring
    - Naive enemy AI (H3) — if Pro suggests a 30-line cheap fix, evaluate
    - Iter-3 scope (H4) — already shipped; learn for next iter
    - Silent bugs (H5) — patch any identified critical bug pre-iter-5
  - Re-run reachability oracle for discipline (should still match
    f873ae60ee3c420c…)
  - Re-score all 10 criteria with fresh eyes
  - Update LEDGER iter 4 with AUDIT findings
  - Commit; ScheduleWakeup 240s
  - Iter 5 = mandatory PLAYTEST (user-look gate)`

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
