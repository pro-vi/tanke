# Iter-60 PLAYTEST prompt — DRAFT

Drafted iter 54. Ready to copy-paste at iter 60 (after build verification).

## Pre-fire checklist (iter 60)

```bash
make test                                                # exit 0
godot --headless --quit-after 60                         # exit 0, no warnings
```

If both clean → fire prompt. Otherwise diagnose first.

## Prompt to paste (after verifying build clean)

---

**Iter 60 PLAYTEST — sprint conclusion (iter 39-59 mid-arc)**

Sprint authorized iter 38 ("21 iters before next playtest"). Major ships
since iter 38 wind-up:

- 3rd enemy type **Fast** (harassment rusher, continuous fire, no aim)
- Bullet impact **spark** + enemy **hit-flash** + camera **shake** on player damage
- **Death screen** run summary: DEPTH / TIME / KILLS / STALL / BEST
- **Persistent best-depth** with `* NEW BEST!` highlight
- **Heavy LKP** de-omniscience — Heavy chases last-known position, searches on reach, wanders upward-bias when no LKP
- **Depth landmarks** every 20 rows (yellow posts + center label)
- **HP bar** graphical + low-HP red color shift
- **Heavy aim-cancel** — shoot Heavy during red telegraph to interrupt the burst
- **Heavy bullet damage=2** (orange-tinted bullets); Light/Fast=1

Score: 30/50. Many [STRUCTURE-DEFERRED → iter 60] tags depend on your cites.

Please play 2-3 lives and answer 5 short questions (≤30s each):

**Q1.** Did you notice 3 enemy types? How did you tell them apart?

**Q2.** Name one moment where hit/fire feedback (sparks, flashes, shake, low-HP red) helped — or felt like noise.

**Q3.** Did the death screen + best-depth make you want to retry?

**Q4 (LOAD-BEARING).** During ascent — were you making decisions, or mostly reacting? Specifically: did you bait Heavy, use cover, cancel Heavy's wind-up shot?

**Q5.** What should I improve first: **enemy behavior** / **map structure** / **feedback** / **run goals**?

**Bonus**: copy the `[run]` line from terminal if you die (depth/time/kills/aim_cancels/stall).

Halt rule: iter 63 if no response.

---

## Falsification-clause checklist (post-response)

| Q | Lift gated on | Revert if |
|---|---------------|-----------|
| Q1 | Crit 6 anchor 3 holds at 3 ([STRUCTURE] iter 40); anchor 4 lift to 4 [FEEL] if user cites Heavy/Fast as band-markers ("Heavy showed up at depth N") | If user "couldn't tell types apart" → crit 6 revert 3→2 |
| Q2 | Crit 8 anchor 4 lift 3→4 [FEEL] if cite "hits feel solid" / "punchy" / similar | If cite "didn't notice" / "felt the same" → hold 3, defer to iter-61 polish |
| Q3 | Crit 10 anchor 4 lift 3→4 [FEEL] if cite "I want one more"; anchor 5 lift to 5 if "I want to beat my best" | If "didn't care" → hold 3 |
| Q4 | Crit 5 anchor 3 lift 1→3 [FEEL] if cite "I was deciding"; Crit 6 anchor 5 LKP if cite "I used walls to bait Heavy"; Crit 8 anchor 4 path reinforced if cite "aim-cancel was important" | If "mostly reacting" → hold all combat-decision lifts at structure-deferred |
| Q5 | Iter 61-65 direction set per user forced-choice | N/A — directive |

## Iter-60 [run] log interpretation guide

`[run] depth=N time=M:SS kills=K aim_cancels=A ascent_rate=R rows/s stall_total=T.Ts (P%) seed=S`

- `depth`: hit anchor 1-5 of crit 1/4 progression
- `kills`: balances "kill-loop" awareness without HUD live-count (death-screen only per iter 30 Pro Consult 005 H4)
- `aim_cancels`: iter 56 instrumentation. How many Heavy aim-cancels landed. >0 = player engaged Heavy tactical decision (crit 5 + 6 + 8 cite gate). 0 = player never tried OR Heavy too rare.
- `stall_total / P%`: if P > 30%, player struggled with ascent pressure (suggest iter 61 tuning); if P < 10%, ascent was smooth
- `ascent_rate`: rows/s. Iter-31 baseline was ~0.3 rows/s. Higher = aggressive ascender, lower = cautious player.
- `seed`: iter 57 instrumentation. RNG seed for the run. If user reports a weird run, I can reproduce iter 61+ for root-cause investigation.

## Score targets if all 5 cites land favorably

| Criterion | Current | Best-case post-playtest | Gate |
|-----------|---------|--------------------------|------|
| 5. Forward survivability | 1 | 3 | Q4 cite "deciding while moving" |
| 6. Enemy variety | 3 | 4-5 | Q1 cite + Q4 LKP cite |
| 8. Impact/feedback | 3 | 4 | Q2 cite "punchy" |
| 10. Run loop closure | 3 | 4-5 | Q3 cite "I want one more" / "beat my best" |
| 4. Depth feedback | 2 | 3 | Q4 / Q5 cite "varied rhythm" / "felt authored" |

Best-case post-iter-60: 30/50 → ~36-40/50.
