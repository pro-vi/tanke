# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 4
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
Iter 4 AUDIT complete. GPT-Pro consult integrated:
- H1 (substrate freeze .tscn exemption): "too convenient" — installed
  H1 TRIPWIRE (≤3 gameplay siblings inside ProceduralLevel.tscn before
  mandatory refactor). Current count: 1 (Spawner).
- H2 (rubric theater): "self-grading convergence" — installed H2 RULE
  in PRE-MORTEMS.md: ≥1 independently observable falsifiable claim per
  pre-mortem. Iter-4 pre-mortem itself shipped 4 such claims; 3 landed,
  1 deferred to iter-5 playtest.
- H5 #2 (off-map/inside-wall spawns): patched Spawner.gd with
  rejection sampling (max_spawn_attempts=8) using PhysicsDirectSpaceState2D
  intersect_point against collision_mask=1 (Environment). Counters
  exposed via debug print every 10 ticks for iter-5 playtest verification.
- H5 #1 (bullet self-collision): Pro WRONG — PlayerTank is layer 2,
  not 1; Bullet mask=9 doesn't include layer 2. Logged FALSIFICATION 001.
- AUDIT re-score: 7/50 unchanged (Pro work was substrate discipline,
  not gameplay feature).
- Oracle re-check: tile_hash f873ae60ee3c420c… matches iter-0 baseline.
  Substrate integrity verified across iters 1-4.
- Headless boot exit 0 clean.
- Created creative-consults.md and FALSIFICATIONS.md (per-file
  bookkeeping artifacts per PROMPT §CONSULT/§USER-LOOK).
Next: iter 5 PLAYTEST (mandatory user-look gate).
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 5 PLAYTEST (mandatory user-look gate per PROMPT §USER-LOOK):
  - Pre-mortem to PRE-MORTEMS.md — must include ≥1 independently
    observable falsifiable claim per H2 RULE
  - Verify build runs: godot --headless --quit exit 0
  - Capture run config: seed (random per launch), config=playable.tres,
    spawn_interval=2.0s, max_enemies=20, spawn_distance=120, max_hp=3,
    damage_iframes=0.6s, max_spawn_attempts=8
  - Output to user: "Please play one F5 run (~1-2 min). Specifically
    observe these THREE things and report:
    1. BULLETS: Press space. Do bullets visibly travel forward and
       disappear when they hit a wall? Or are they invisible / stuck /
       persistent?
    2. ENEMIES: Do enemies move toward you? Do any get stuck on walls
       and never reach you? About how many actually engage vs. get
       stuck?
    3. SPAWNS: Look at the Output dock. Do you see "[spawner] tick N:
       spawns=X rejections=Y" lines every ~20 seconds? Is Y > 0?
    Also: anything else that felt off / broken / surprising."
  - AWAIT user response. No scheduled retry per PROMPT §7.
  - Halt rule: if 3 subsequent iters pass without user playtest
    response, write loop/gameplay/HALTED.md and stop.
  - On user response: iter 6 morphs to BUILD targeting whatever the
    playtest surfaced as most broken (likely enemy AI per H3 critique).`

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
