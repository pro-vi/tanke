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

