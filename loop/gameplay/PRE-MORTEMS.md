# tanke — Gameplay Loop Pre-Mortems

Append-only. Written before DIAGNOSE/MODE/ACT each iter (PROMPT §1).
Iter-21 evidence: pre-mortems-in-writing work as a falsification mechanism
even when external CONSULT fails.

---

## Iter 001 — BUILD (Bullet system)

Going in, I expect this iter's biggest miss to be: bullet travels and
despawns cleanly on terrain collision, but with no enemies to shoot and no
visible impact spark, the "core loop closes" criterion lands at 1
(move + shoot + bullet has no effect) rather than 2 (move + shoot +
collisions register). The collision will technically register on terrain
StaticBody2D, but without a visible target it'll feel like firing into the
void. Secondary risk: format-2 → format-3 .tscn migration introduces a
UID/resource regression that breaks scene loading entirely — would surface
in headless boot, so recoverable in-iter.

Falsifiable predictions:
1. Criterion 1 lands at 2/5 (not 1, not 3). Anchor: collision registers
   even without enemies — bullet visibly despawns hitting brick.
2. Headless `godot --quit` returns 0 with no parse errors.
3. Reachability oracle at seed 42 unchanged: `playable: true`, `tile_hash
   f873ae60ee3c420c…` (Bullet changes don't touch tile placement).

---
