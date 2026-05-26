# Z-index / layering audit — iter 298

User feedback at iter 297 #2: "z index needs review for the UI elements...
when there is a popup, understand how much overlap and will UI show
above it."

This doc maps every render layer in the scene and identifies overlap
issues. Fixes applied in iter 298 set explicit `z_index` per UI class
so insertion order is no longer the only stacking rule.

---

## Godot rendering split

Two independent render passes:

1. **World** (Node2D subtree under scene root, including PlayerTank
   children) — Node2D.z_index controls order. All world elements
   render together.
2. **CanvasLayer "$HUD"** — its own pass, drawn AFTER all world (so
   HUD is always over world by default). Within the CanvasLayer,
   child order + z_index control stacking.

`Q1ProofRoomScene` plus the PlayerTank-internal `$HUD` CanvasLayer
gives us these two layers.

---

## World layer — z_index map

| Element                       | z_index | Lifecycle              | Where set |
|-------------------------------|---------|------------------------|-----------|
| Bullet impact spark           | 60      | 0.08s tween then free  | Bullet.gd:335 |
| Enemy HP bar fg               | 51      | persistent per enemy   | Enemy.gd:552 |
| Enemy HP bar bg               | 50      | persistent per enemy   | Enemy.gd:543 |
| Enemy death burst (16×16)     | 50      | 0.3s tween then free   | Enemy.gd:709 |
| Enemy kill-flash ring edges   | 49      | 0.3s tween then free   | Enemy.gd:660–681 |
| HP pickup                     | 45      | 8s lifetime            | Enemy.gd:744 |
| Shield pickup                 | 45      | 8s lifetime            | Enemy.gd:790 |
| PRISM beam line               | 30      | while beam active      | PlayerTank.gd:721 |
| MORTAR aim reticle            | 30      | while charging         | PlayerTank.gd:917 |
| HE blast bloom                | 58–59   | 0.3s tween then free   | Bullet.gd:237–240 |
| Bullet (in flight)            | 0       | until hit/timeout      | (Bullet.tscn default) |
| PlayerTank sprite             | 0       | persistent             | (PlayerTank.tscn default) |
| Enemy sprite                  | 0       | persistent per enemy   | (Enemy.tscn default) |
| BrickBlock                    | 0       | until destroyed        | (BrickBlock.tscn default) |
| SteelBlock                    | 0       | until drilled          | (SteelBlock.tscn default) |

### World-layer issue: kill-flash ring (z=49) below enemy HP bar (z=50/51)

When an enemy dies, the iter-281 ring renders at z=49 — but the dying
enemy's HP bar (z=50/51) is still on screen for the brief moment
between `killed.emit()` and `queue_free()`. The bar renders OVER the
ring. Minor cosmetic — visible on the kill frame only.

**Fix iter 298:** raise ring edges to z=52 so they render OVER the
HP bar at death (consistent with the burst at z=50 also being below
the bar — but burst is shell-tinted, the ring is the SHAPE signal
the consult valued; ring should not be occluded).

### World-layer issue: tank/bullet/enemy all at z=0

Insertion order determines stacking. In Q1ProofRoom the spawn order
is terrain → enemies → player, so the tank renders on top of bricks
and enemies. Bullets get add_child'd LATER (when the player fires),
so bullets render OVER the tank. That's acceptable (the bullet you
fired flies forward away from you).

**No fix needed** unless playtest reveals a specific occlusion
problem (e.g. tank disappearing behind enemy).

---

## HUD CanvasLayer — pre-iter-298 stacking (insertion order ONLY)

Build sequence inside `_setup_hud()`:

1. HP bar BG / FG / label (always-on)
2. Death panel / death label / restart hint (popup, invisible until die)
3. (loadout-gated) Breach prompt panel / label (popup, invisible until die)
4. Depth / Time / Best labels (always-on, top-right)
5. Shell panel (always-on bottom strip — the "legacy ammo tray" user wants gone in iter 299)
6. Shell codex (popup, invisible until run start)
7. Reload bar BG / FG (always-on, top-left)
8. Shell chips panel + 4 chips + 4 labels (always-on, top-left)
9. Active-cards ribbon panel + 8 chip slots + labels (always-on, fades on pressure)
10. Speed meter label (always-on, top-right)
11. Level label + XP bar (always-on)
12. Other top-right labels (best-depth)

Then deferred / event-built:
- Route strip (`_build_route_strip` deferred to next frame after _ready)
- Archetype select panel (`_build_archetype_panel` on first show)
- Levelup pick panel (`_build_levelup_panel` on first show)
- Depot panel (built by Depot.gd, parented to player's HUD)
- Band banner (transient label, freed after fade)
- Pickup toasts (transient labels, freed after fade)
- Run-recap death overlay (uses the existing death panel/label)

### HUD-layer issue: popups have no explicit z_index → insertion order

If a transient toast spawns DURING a popup, the toast renders OVER the
popup (because it was add_child'd later). That can read as "the toast
escaped the modal" — visually buggy.

Likewise, if a deferred build (route strip / archetype panel) happens
AFTER popups already exist, the deferred element renders OVER popups
that were build earlier in `_setup_hud`. Currently doesn't fire that
order because both popups are built lazy-on-first-show, but it's
fragile.

**Fix iter 298:** assign explicit z_index per UI class.

---

## Proposed iter 298 z_index assignment (HUD CanvasLayer)

| Class                              | z_index | Rationale |
|------------------------------------|---------|-----------|
| Base HUD (HP, reload, chips, ascender, speed, level, XP) | 0  | Default — bottom of HUD pass |
| Route panel / active-cards ribbon (run-context strips)   | 1  | Above base HUD, below interrupts |
| Legacy shell panel (bottom tray)                          | 1  | Same group; goes away iter 299 anyway |
| Shell codex (run-start primer)                            | 10 | Above run HUD but it auto-dismisses |
| Archetype select panel (run start)                        | 20 | Above codex |
| Levelup pick panel                                        | 20 | Above run HUD |
| Depot panel                                               | 20 | Above run HUD |
| Death panel / death label / restart hint / breach prompt | 30 | Top of HUD when active |
| Band banner (transient confirmation)                      | 35 | Above popups so player still sees band changes |
| Pickup toasts (transient feedback)                        | 40 | Above everything — confirmation is always visible |

Conventions:
- 0 = default base HUD
- 10s = informational popups (codex)
- 20s = MODAL popups blocking input
- 30 = death overlay (the most-important post-run information)
- 35-40 = transient confirmation overlays that should ALWAYS reach the player

This means: even if you die and the death overlay is up, a pickup
toast or band banner fired in the moment WILL render over it. That's
arguably correct — those moments are temporary and informative.

---

## Death overlay overlap question

User asked: "when there is a popup, understand how much overlap and
will UI show above it."

Death panel: (56, 56) size 208×130 → covers y=56–186, x=56–264 of the
viewport. Outside this rectangle: top-left HP/reload/chips (y=0–44),
top-right ascender (y=4–40), and the bottom strips (y=180+). The
death panel's bottom edge at y=186 is BELOW the active-cards ribbon
(y=180) and ABOVE the route strip (y=195). So:

- Top-left HUD: visible at top-left corner of viewport, OUTSIDE death panel
- Top-right ascender: visible at top-right, OUTSIDE death panel
- Active-cards ribbon: y=180–192 → partly INSIDE death panel's
  bottom edge → death overlay covers this strip
- Route strip: y=195–208 → OUTSIDE death panel → visible
- Shell panel: y=209–235 → OUTSIDE death panel → visible

With iter 298 z_index = 30 on death panel, the legacy ammo tray + route
strip remain visible BELOW it (their z=1 < 30), and they're spatially
outside anyway. The active-cards ribbon at z=1 is spatially overlapped
by the death panel — and the death panel renders OVER it correctly.

---

## Fixes applied iter 298

1. Add explicit z_index per build-site per the table above
2. Raise kill-flash ring edges to z=52 (above HP bar)
3. Harness verifies popup z-stack: open death panel, fire a pickup
   toast, assert toast.z_index > death panel z_index
