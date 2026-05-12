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

**Q1 (crit 6 — enemy types).** Which enemy types did you notice, and how
did you tell them apart? (Were Heavy / Light / Fast distinguishable in
play?)

**Q2 (crit 8 — feedback).** Name one moment where the hit/fire feedback
helped or confused you. (Bullet sparks, hit flashes, camera shake, low-HP
red — did any feel right or feel like noise?)

**Q3 (crit 10 — run loop).** Did the death screen / best-depth tracker
make you want to retry? (Or just feel like extra UI?)

**Q4 (CORE STONE — decision quality).** During ascent, did you feel you
were making route/combat decisions, or mostly reacting? (Specifically:
did you try to bait Heavy / use cover / cancel Heavy's wind-up shot?)

**Q5 (forced choice — direction).** What should be improved first:
**enemy behavior** / **map / ascent structure** / **feedback & juice** /
**run goals & replayability**?

**Bonus**: copy the `[run]` line from terminal if you die (depth/time/kills/stall counters).

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

`[run] depth=N time=M:SS kills=K ascent_rate=R rows/s stall_total=T.Ts (P%)`

- `depth`: hit anchor 1-5 of crit 1/4 progression
- `kills`: balances "kill-loop" awareness without HUD live-count (death-screen only per iter 30 Pro Consult 005 H4)
- `stall_total / P%`: if P > 30%, player struggled with ascent pressure (suggest iter 61 tuning); if P < 10%, ascent was smooth
- `ascent_rate`: rows/s. Iter-31 baseline was ~0.3 rows/s. Higher = aggressive ascender, lower = cautious player.

## Score targets if all 5 cites land favorably

| Criterion | Current | Best-case post-playtest | Gate |
|-----------|---------|--------------------------|------|
| 5. Forward survivability | 1 | 3 | Q4 cite "deciding while moving" |
| 6. Enemy variety | 3 | 4-5 | Q1 cite + Q4 LKP cite |
| 8. Impact/feedback | 3 | 4 | Q2 cite "punchy" |
| 10. Run loop closure | 3 | 4-5 | Q3 cite "I want one more" / "beat my best" |
| 4. Depth feedback | 2 | 3 | Q4 / Q5 cite "varied rhythm" / "felt authored" |

Best-case post-iter-60: 30/50 → ~36-40/50.
