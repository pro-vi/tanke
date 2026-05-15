---
topic: "Original Battle City (NES, 1985) enemy AI"
date: 2026-05-12
sources:
  - title: "Quantifying Engagement of Battle City with different AI strength"
    url: https://ieeexplore.ieee.org/document/8992667
    source_quality: doc-stated
  - title: "Trying to figure out AI in Battle City — GameDev.net forum"
    url: https://www.gamedev.net/forums/topic/514880-trying-to-figure-out-ai-in-battle-city/
    source_quality: doc-stated
  - title: "Battle City in Unity Part 6: Enemy AI"
    url: https://yarnthen.github.io/yarnthencohosking/tutorials/2018/03/10/battle-city-unity-7.html
    source_quality: doc-stated (reverse-engineering by tutorial author)
  - title: "Battle City — Wikipedia"
    url: https://en.wikipedia.org/wiki/Battle_City
    source_quality: doc-stated
  - title: "Battle City/Gameplay — StrategyWiki"
    url: https://strategywiki.org/wiki/Battle_City/Gameplay
    source_quality: doc-stated
  - title: "Tank Battalion / Battle City — Hardcore Gaming 101"
    url: http://www.hardcoregaming101.net/tank-battalion-battle-city/
    source_quality: doc-stated
hypotheses:
  - claim: "Original BC AI was random with directional bias, NOT omniscient or vision-based"
    result: confirmed
  - claim: "Heavy tanks differ in HP/armor, not behavior (per-type AI roughly the same)"
    result: confirmed
key_findings:
  - "Original BC enemy AI is fundamentally DUMB — random movement + collision-turn + slight bias toward player/base"
  - "No vision system, no x-ray of player position, no aiming at player (fires in facing direction)"
  - "Tank types differ in speed/HP/fire-rate, not in AI sophistication"
  - "Modern remakes commonly use 80/20 (80% toward target, 20% random) or BFS-to-base + DFS-to-player"
unexplored_threads:
  - "Sequel AI evolution (Tank 1990, Battle City 4) — sources didn't surface concrete data; would need TCRF or NESDev disassembly"
  - "Exact NES disassembly of BC AI routines — not located in this research pass"
---

# Battle City (1985, NES) Enemy AI — Research Synthesis

Researched 2026-05-12 to inform `tanke`'s Heavy/Light enemy AI redesign after user playtest at iter 33 reported Heavy tanks "too smart/cheaty." User's stated design law: **vision first, transmission second**.

## TL;DR

**The original Battle City enemy AI is much DUMBER than my current Heavy tank's `CHASE/AIM_FIRE` state machine.** The original game has:

- **No vision system**. Tanks don't "see" the player — they don't know where the player is.
- **No aimed shots**. Tanks fire in their current facing direction, not at the player.
- **No pathfinding**. Movement is random + collision-driven turns + slight directional bias toward player/base.
- **Tank type ≠ AI type**. The four tank types differ in **speed, HP, fire rate** — not in *behavior*. They all share the same dumb AI.

My iter-24 Heavy state machine uses `_player_in_line_of_sight()` which reads `player.global_position` directly — **omniscient through walls**. That's why user called it "too smart/cheaty." It's *more* intelligent than the source material's AI by several orders of magnitude.

The fix is **regression to authentic BC dumbness, then layered intelligence per user's ladder**.

## 1. Original Battle City enemy AI characteristics

### Movement

Per HG101 on the Tank Battalion arcade predecessor (whose AI BC inherited): "The enemy AI alternates between taking a random detour and making advance on you, but eventually they'll go after your base at the bottom."

GameDev forum + Unity-tutorial reverse-engineering consensus:
- **Pick a random cardinal direction (U/D/L/R)** when needed
- **Continue in that direction** until either (a) a collision, (b) a periodic re-decision (every N frames), or (c) a random "change mind" event
- **Light directional bias** toward player and/or base — but the bias is small enough that enemies feel like they wander

A specific quote from a Unity tutorial recreation: "implementing A* pathfinding algorithm works great but is considered overkill for the game and makes it harder to play." Original BC explicitly does *not* pathfind.

### Targeting / firing

- Tanks fire in their **current facing direction**, NOT at the player
- Fire cadence is per-type (rapid-fire type fires faster)
- No aim adjustment, no leading shots, no LOS checks

### Vision / awareness

- **None.** Tanks don't know where the player is. The "bias toward player" is implemented as a small probability of preferring direction-toward-player when picking a new random direction — but the tank has no real model of player position.
- No vision cone, no raycast, no x-ray, no pathfinding.

This is the key insight: **a BC enemy that ends up shooting the player did so by accident, not by intent**. The player's strategy is to avoid being in tanks' firing lines, not to outsmart tank AI.

### Two-tier targeting in some implementations

The IEEE paper "Quantifying Engagement of Battle City with different AI strength" notes the original 1985 Namco arcade BC ran *without* sophisticated AI, while modern Python remakes use BFS/DFS:
- **DFS** to hunt the eagle base (the "kill the base" enemy goal)
- **BFS** to hunt the player

In the original game, the "hunt the base" behavior emerges from the slight downward-bias of random direction picks — most enemies eventually drift toward the bottom (where the base is) — but the original didn't run an actual pathfinding search. The "hunt the player" behavior didn't really exist; player encounters were near-random.

## 2. The four enemy tank types

Per StrategyWiki / GameFAQs consensus:

| Type | Speed | HP | Fire rate | Points | Visual cue |
|------|-------|------|-----------|--------|------------|
| **Basic / Light** | slow | 1 | slow (1 bullet) | 100 | Default small tank sprite |
| **Speed / Fast** | fastest | 1 | slow | 200 | Distinct sprite |
| **Power / Rapid-fire** | normal | 1 | **fast** (bullets travel faster too) | 300 | Distinct sprite |
| **Armored / Heavy** | slow | **4** | normal | 400 | Color flashes per hit: 1/4 → 2/4 → 3/4 → destroyed |

Key points:
- **Tank types differ on stats, not behavior.** All four use the same underlying movement AI. Difference is speed/HP/fire-rate.
- **Armored tank has 4 HP and color-cycles** to show damage. This is a visual feedback channel my current Heavy doesn't have (I just queue_free on hp=0).
- **Spawn locations are fixed**: 3 specific top-edge points (top-left, top-center, top-right). The classic spawn animation is a brief swirl/star indicator before the tank materializes.

## 3. Mapping to `tanke`'s current state

### What `tanke` does that BC doesn't

| Feature | tanke | BC |
|---------|-------|-----|
| 4-dir cardinal movement | ✓ | ✓ |
| Top-edge spawn | ✓ | ✓ (3 fixed points) |
| Spawn telegraph (warning marker) | ✓ (yellow rect) | ✓ (swirl animation) |
| Tank-type variety | 2 types (Light/Heavy) | 4 types |
| Tank type = stats difference | ✓ | ✓ |
| Tank type = behavior difference | ✓ (Heavy CHASE/AIM_FIRE) | ✗ (all share same AI) |
| Omniscient knowledge of player position | ✓ (Heavy LOS check uses raw player.position) | ✗ (no awareness) |
| Aimed shots | ✗ (fires in facing direction) | ✗ |
| Pathfinding | ✗ | ✗ |
| Procedural ascending maze | ✓ (the novel twist) | ✗ |
| Visible damage state on tanks | ✗ | ✓ (color flash on Armored) |

### What `tanke` is missing that BC has

1. **Visible damage state** — Heavy at HP=1 vs HP=2 looks identical (just hp counter). Should color-flash or sprite-swap.
2. **More tank-type variety** — only 2 of BC's 4 types. Could add Speed (fast/fragile) or Power (rapid-fire) for variety.
3. **Map boundary collision** — confirmed bug from iter-33 playtest ("enemies drive out of map border"). BC has fixed-screen with walls; tanke has scrolling but should still clamp.

### What `tanke` does that BC doesn't, and SHOULD KEEP

- **Procedural ascending maze** — the genuine differentiation. BC has 35 hand-crafted levels; tanke has infinite procedural ascent. This is the loop's identity.
- **Behavioral split between types** — even though BC didn't have this, it's a *legitimate enhancement* if done right. The user signaled the SPECIFIC failure is "too smart" — not "behaviorally distinct."

## 4. The "vision first, transmission second" implementation ladder

User's stated design law. Maps to a stage system where AI grows in sophistication:

### Stage 0 — DUMB (original BC baseline)

- Random cardinal direction
- Persist direction until collision or N-frame re-roll
- On collision: pick perpendicular alternate, fall back to reverse
- Slight directional bias toward player (e.g., 70% random, 30% biased-toward-player)
- Fires in current facing direction every fire_cooldown

**`tanke` Light should regress to this.** Currently Light has vertical bias + 3s commit + 3.5s fire. That's already Stage 0.5 — close to authentic BC dumb. Acceptable.

### Stage 1 — VISION (Heavy redesign target for iter 35)

- Tank has a **vision cone** in its current facing direction
- Cone is cardinal (no diagonal vision) — within `vision_range` px straight ahead
- **Vision is BLOCKED BY WALLS** (raycast against env collision_layer 1)
- Tank only "sees" player when player is in vision cone AND no wall in between
- On seeing player → enter AIM_FIRE state (existing iter-24 code)
- On losing sight → return to CHASE (existing iter-24 code with min_dwell)

**Implementation for tanke**:
```gdscript
func _player_in_line_of_sight() -> bool:
    if _player == null: return false
    var dir_vec: Vector2 = _direction_vector(direction)
    var to_player: Vector2 = _player.global_position - global_position
    # Project to_player onto facing direction; require positive distance + within cone
    var forward_dist: float = to_player.dot(dir_vec)
    var lateral_dist: float = absf(to_player.dot(Vector2(-dir_vec.y, dir_vec.x)))
    if forward_dist <= 0.0 or forward_dist > vision_range: return false
    if lateral_dist > vision_lateral_tolerance: return false  # cone width
    # Raycast through environment layer to check wall obstruction
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
        global_position, _player.global_position, 1  # env layer mask
    )
    var hit: Dictionary = space_state.intersect_ray(query)
    return hit.is_empty()  # no wall between us
```

This is **exactly the fix** for "Heavy too smart." Heavy no longer omnisciently knows player position — it has to actually see them in its forward cone with no wall blocking.

### Stage 2 — TRANSMISSION (future iter, e.g., iter 38+)

When a tank enters AIM_FIRE (i.e., spots the player), it broadcasts the player's **Last Known Position (LKP)** to nearby tanks within radio range. Recipients then:
- Cache LKP for N seconds
- Use LKP as a strong directional bias even if they themselves can't see player
- "Forget" LKP after timeout → return to random wander

This makes a sighting by one tank cascade — player has to break LOS AND outlast the LKP timeout.

Implementation: a `Spawner.last_known_player_pos` shared variable with timestamp; tanks consult it as a fallback when their own vision misses.

### Stage 3+ — Aspiration (skip until needed)

- **Specialization**: one enemy type seeks base via DFS, another seeks player via BFS (Battle City's emergent two-tier targeting)
- **Memory**: tank remembers where it last fired and avoids those spots
- **Coordination**: tanks try not to all converge on same player position

Don't build any of this before user explicitly asks. Stages 0-2 cover the user's "vision first, transmission second" directive.

## 5. Specific design implications for `tanke` Heavy/Light split

### Heavy regression target

Current `Enemy.gd:_player_in_line_of_sight`:
```gdscript
var horizontal: bool = absf(dy) < aim_fire_axis_tolerance and absf(dx) < aim_fire_range
var vertical: bool = absf(dx) < aim_fire_axis_tolerance and absf(dy) < aim_fire_range
return horizontal or vertical
```

This is omniscient — uses raw player position, doesn't care about walls.

**Iter 35 BUILD plan**: replace with raycast-based vision-cone-in-facing-direction (Stage 1 above). Heavy must actually FACE the player AND have clear LOS through walls. This will significantly nerf Heavy's effectiveness — they'll only fire when:
- Player is in their forward direction
- No walls between
- Within ~80px range

User can then "hide" behind brick walls, peek out to shoot, hide again. Authentic BC tactical play.

### Light reinforcement

Light is already close to Stage 0 (BC-authentic): vertical-bias direction picks, 3s commit, 3.5s fire, no targeting. Could go fully dumb:
- Remove vertical bias entirely → pure random
- Remove direction-toward-player calculation
- Just commit to a direction, fire on cooldown, change on collision

This would make Light TRULY dumb (BC-authentic) and Heavy the only "smart" enemy (Stage 1 vision). Stronger role distinction.

**However**: Light's current vertical bias serves the **ascender** framing — Light comes DOWN at the player from above. Going fully random might make Light wander sideways without ever reaching player. So vertical bias is **a tanke-specific enhancement that earns its keep** despite being more sophisticated than BC.

Decision: Keep Light vertical-bias. Don't regress further.

### Heavy visual feedback (BONUS)

BC's Armored tank flashes color per hit (1/4 → 2/4 → 3/4 → destroyed). My Heavy at HP=2 has no visible damage state. Easy fix:
- Heavy on take_damage (non-lethal): modulate sprite to red-tint briefly + persist a damage-tint
- Or: swap sprite to a "damaged" frame

This is iter 36+ work (visual juice). Not blocking.

## 6. Iter 35 BUILD recommendation (for the loop)

Per user feedback at iter 33, three concrete fixes are needed in priority order:

1. **BUG: Water doesn't block player** — iter-8 collision graph regression. Verify and fix. ~5 lines.
2. **BUG: Tanks drift off map** — add invisible walls at x=0 and x=320 (or modify enemy/player to clamp). ~15 lines.
3. **REWORK: Heavy vision cone (Stage 1)** — replace `_player_in_line_of_sight` with cone+raycast per Stage 1 above. ~30 lines. **This is the user's headline request.**

Plus iter 35 should NOT touch Stage 2 transmission yet. Save for iter 37+ after user playtests Stage 1.

## Transfer assessment

🟢 **Direct transfer**: BC's random+collision-turn movement → already in `tanke` Light.
🟡 **Adapt**: BC's vision-LESS model. We're going *beyond* BC with Stage 1 vision because user requested it. Adaptation: raycast through env layer 1 only (not water layer 10 — bullets pass water, so should vision).
🟡 **Adapt**: BC's 3-fixed-spawn-point convention. tanke uses random x along top edge. Adaptation: keep random — procedural maze identity demands variability.
🔴 **Doesn't transfer**: BC's hand-crafted level grammar. tanke is procedural. The "tactical authorship" Pro v4 called out is created procedurally via DEPTH_BANDS encounter rules, not hand-placed.

## Lessons

1. **My iter-24 Heavy is significantly smarter than 1985 BC enemies.** That's the source of "too smart/cheaty." Regression is the right move.
2. **The user's "vision first, transmission second" is the right ladder.** It scales sophistication explicitly, citably, and falsifiably.
3. **Procedural maze is the genuine innovation.** Even regressing AI to Stage 0/1, the maze itself plus the ascender framing make the run distinctive from BC.
