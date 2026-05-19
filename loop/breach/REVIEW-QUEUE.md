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

(empty — first round has not yet shipped a finding)
