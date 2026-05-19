# Breach loop review queue (arc 4)

User-look pattern per L3 (carried from arc 3). Append-only by the loop;
batch-closed by the user between sessions. The loop continues running
structurally between user reviews.

Format per item:

```
#K — <topic> — <round-NNN> — <SHA> — <status: open / closed / superseded>
  Finding: <one-sentence summary>
  Affordance: <what it lets the player do>
  Risk: <seductive-but-hollow framing from CONSULT, if applicable>
```

---

#1 — Breach scaffolding (round 1) — iters 2-5 — SHA 9e0b088 — open
  Finding: Four-piece structural scaffolding for breach economy shipped:
    (a) ProceduralLevel.gd default-on `breach_mode_enabled` flag (iter 2);
    (b) BreachConfig + BreachBand schemas + 2-band sample (iter 3);
    (c) Bullet.gd shell_class with AP/HE/HEAT constants (iter 4);
    (d) Depot.gd + Depot.tscn + pause-on-entry (iter 5).
    Hash anchor `23d6a2ec3bf2821f` preserved bit-identical through all
    4 substrate writes (3 substrate-touching iters + 2 new-file iters).
    Rubric: 7/50 (C2=1, C3=1, C4=1, C9=1, C10=3).
  Affordance: lets the loop wire actual breach mechanics in round 2
    (HE-terrain-cracking, depot upgrades, depth-band-aware spawning)
    without rebuilding plumbing.
  Risk: **schema-before-mechanic**. Round 1 produced structural surfaces
    but the player can't yet *experience* breach economy. Per CONSULT §4
    iter-30 embarrassment list: "BC-like tank game with too many icons
    and not enough tactical difference between builds" — round 2 must
    avoid this trap by wiring *behavior*, not more schema. iter-6 fired
    consult 001 to ground-truth this risk read.

#2 — Round 2 atomic verb (iter 7+8) — iters 7-8 — open
  Finding: CONSULT 001 returned (tab-timeout but response landed —
    arc-4 documented behavior reproduced). It named the missing piece:
    "no player has yet sacrificed one resource to alter one route. That
    is the atomic verb." Iter 7 shipped HE radius brick-blast (3 stub
    bricks destroyed by one HE shot vs 0 for AP). Iter 8 shipped
    Loadout.gd + PlayerTank.gd shell cycle (KEY_TAB) + finite HE/HEAT
    reserves consumed on fire. Now the player CAN sacrifice a resource
    (HE reserve) to alter a route (open brick lane). C1=1, C9=2; total
    10/50.
  Affordance: player has a shell cycle + a finite breach budget;
    firing HE is now a commitment, not a free option.
  Risk: not yet placed in a BreachLevel scene; harness-tested only.
    The lived breach decision doesn't happen yet — no band yet places
    bricks in a choke that *requires* HE to breach. Round 2's next
    iter (iter 9+) wires the choke band + the 2-choice depot.

