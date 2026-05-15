# Iter-99 PLAYTEST prompt — DRAFT (Pro Consult 008 3Q form)

Drafted iter 93 per Pro Consult 008 H5 reduction: 5Q template too long for
sprint scope. Three diagnostic questions tied to load-bearing rubric axes.

## Pre-fire checklist (iter 99)

```bash
make test                                        # exit 0
godot --headless --quit-after 60                 # exit 0, no warnings
```

If both clean → fire prompt. Otherwise diagnose first.

## Prompt to paste (after verifying build clean)

---

**Iter 99 PLAYTEST — Legibility Lock sprint conclusion (iter 61-98)**

Sprint authorized iter 60 ("next playtest at iter 99"). 38 iters of work.
Score 30 → 32/50 via crit 5 [FEEL] cite (iter-60 Q4 routing decisions).

Key changes since iter 60:

**Map (Q5 priority 1)**: 4 bands now mechanically distinct
- Warmup (depth 0-8): sparse + slow + Light-only (onboarding)
- First_push (8-20): brick-heavy maze (28% brick — almost double warmup)
- Heavy_gate (20-40): Heavy-dominant 60% + dense spawn + low cap (stop-and-aim)
- Rush (40+): Fast-dominant 70% + fastest spawn + high cap (chaos)
- Visual: band-themed HUD overlays + gate-post colors + milestone flashes
  (all green→yellow→orange→red palette per band)

**Enemies (F009)**:
- Light 1 HP white, Fast 1 HP cyan tint (iter 67), Heavy 2 HP white
- Heavy: vision-cone + 0.45s wind-up red telegraph + 2-dmg orange bullets
- Size variance: Heavy 1.15× / Light 1.0× / Fast 0.85× (iter 86)
- Heavy aim-cancel: hit Heavy during red telegraph → interrupt burst (iter 51)

**Roguelite pickups (Q5 priority 4, reduced to 2 per Pro Consult 008)**:
- Heavy 25% → HP+1 (green plus visual, capped at max_hp=3)
- Light 10% → Shield 2s invulnerability (pale-blue square)
- Speed pickup CUT iter 88 (Pro: alters control feel + cyan collides with Fast tint)

**HUD/death**:
- HP bar graphical + low-HP red shift
- Death screen: dark panel + multi-line stats (DEPTH/TIME/KILLS/CANCELS/STALL) + BEST DEPTH + BEST TIME + NEW BEST highlights + pulsing "press [R] to restart"

Please play 2-3 lives and answer 3 short questions (≤45s each):

**Q1 (enemies).** Did you understand the 3 enemy types? Could you tell Light from Fast from Heavy at a glance?

**Q2 (pickups).** Did the HP and Shield pickups help — or feel like distraction/noise?

**Q3 (map).** Did the 4 map sections (warmup → first_push → heavy_gate → rush) feel mechanically different, or still "same maze, different colors"?

**Bonus**: copy the `[run]` line from terminal if you die (depth/time/kills/aim_cancels/stall/seed).

Halt rule: iter 102 if no response.

---

## Falsification-clause checklist (post-response)

| Q | Lift gated on | Revert if |
|---|---------------|-----------|
| Q1 | Crit 6 anchor 4 lift 3→4 [FEEL] if user cites "yellow lane-invader / cyan rusher / big Heavy with red telegraph" or similar 3-type distinction | If "still hard to tell apart" → hold 3, log F009-v2 for iter-100+ |
| Q2 | Crit 5 anchor 4 lift 3→4 [FEEL] (forward-friendly mechanics rewarding advance) if user cites "I picked up HP after Heavy kill" / similar reward feel | If "didn't notice" / "distracted me" → consider further cutting (per Pro framework) |
| Q3 | Crit 4 anchor 3 lift 2→3 [FEEL] if user cites "warmup felt easier" / "heavy_gate felt tense" / similar band-distinct-mechanically | If "still feels the same" → Pro Consult 008 H3 confirmed: wrapper-around-Eller's insufficient. F012-v2 logged for major refactor. |

## Iter-99 [run] log interpretation guide

`[run] depth=N time=M:SS kills=K aim_cancels=A ascent_rate=R rows/s stall_total=T.Ts (P%) seed=S`

- `depth`: how far user reached. >40 = reached rush band. <8 = died in warmup.
- `aim_cancels`: >0 = user engaged Heavy tactical decision.
- `stall_pct`: >30% = pressure-tuning needed; <10% = ascent smooth.
- `seed`: reproducible if user reports issue.

## Score targets if all 3 cites land favorably

| Criterion | Current | Best-case post-playtest | Gate |
|-----------|---------|--------------------------|------|
| 4. Depth feedback | 2 | 3 | Q3 cite "felt different" |
| 5. Forward survivability | 3 | 4 | Q2 cite "pickups helped" |
| 6. Enemy variety | 3 | 4 | Q1 cite "could tell apart" |

Best-case: 32/50 → 35/50.
