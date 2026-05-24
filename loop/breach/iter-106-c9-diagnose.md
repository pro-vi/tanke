# Iter 106 — DIAGNOSE — C9 death-recap surface map

**Rubric axis**: C9 (death attribution / run recap legibility) at 2/5
— the lowest score on the 15-criterion rubric.

**CONSULT constraint at stake**: §9 constraint 6 — "every run produces
a death reason tied to resource/build/route — not 'got overwhelmed'."

**Question this diagnosis answers**: what does the recap CURRENTLY tell
the player, and what's missing?

---

## What's there

### `scripts/RunRecap.gd` (RefCounted; per-run instance on PlayerTank)

Captured at death:
- `depth_reached: int`
- `killing_band: String` (from BreachBand.band_name)
- `killing_pressure: String` (from BreachBand.dominant_pressure)
- `killer: String = "shell impact"` — **placeholder, never updated** ★
- `he_reserve_at_death: int`, `heat_reserve_at_death: int`

Captured during run:
- `archetype: int` (run-start; iter-95 fix locks this to start-pick)
- `shells_fired: Dictionary` (AP / HE / HEAT counts)
- `band_visit_log: Array` (sequence of band crossings, iter-82)

Derived:
- `build_tag()` → "lane sniper" / "rubble plow" / "bunker cracker" /
  "mixed breacher" (based on shell mix)
- `band_signature()` → run-shape vector for the cross-archetype analyzer
- `format()` → multi-line text:
  ```
  RUN RECAP
    depth reached : N  (BAND band)
    band pressure : PRESSURE
    build         : BUILD_TAG
    killed by     : KILLER          ← currently always "shell impact"
    shells fired  : AP n / HE n / HEAT n
    reserve left  : HE n / HEAT n
    band visits   : a > b > c
  ```

### `scripts/PlayerTank.gd` death overlay (the on-screen UI)

`_death_label.text` rendered at death is **the arc-2 ASCENDER stat
block** — the iter-31 design before RunRecap existed:
```
YOU DIED

DEPTH N
TIME M:SS
KILLS K
CANCELS C
STALL P%
BEST N
BEST TIME M:SS
```

Plus, since iter-83, the breach-mode playtest-prompt panel below
appends: `bands visited: a > b > c`.

**RunRecap.format() output is NOT rendered on the death overlay.**
The data is captured, but the rich representation never reaches
the player.

---

## What's missing — the 5 high-leverage additions

### Gap 1 (★ root cause): RunRecap.format() unwired from `_death_label`

The rich recap is invisible. The player sees stat soup (DEPTH /
KILLS / STALL / BEST) — exactly the "got overwhelmed" surface
constraint 6 says to avoid. Fixing this is a single-iter BUILD:
make `_death_label.text` include format() output below YOU DIED.

### Gap 2 (★): `killer` field is a placeholder

`run_recap.killer` defaults to `"shell impact"` and is never updated
by the damage path. The post-death recap line `killed by : shell
impact` is meaningless — could be a Light enemy bullet, a Heavy
mortar splash, terrain damage, or anything. Needs:

- pipe the damage source into `take_damage()` (which is currently
  parameterless) OR have `take_damage()` snapshot `_last_damage_source`
  set by the damaging bullet's collision path
- `run_recap.killer = source_name` set when the fatal hit lands
- source name comes from a small taxonomy: "light bullet" / "heavy
  bullet" / "mortar splash" / "ram impact" / "prism beam" (player-
  vs-player not applicable) / "self-detonation" (HE blowback if
  that's a thing) / "terrain spike" (band-specific hazards if any)

### Gap 3: Resource attribution sentence (CONSULT constraint 6 spirit)

Beyond just listing `reserve left: HE 0 / HEAT 0`, generate a
natural-language sentence that names WHY the resource state
mattered. Template:
> "You were dry on **HE** entering **BUNKER**, where the pressure
> wants HE blast for the wall density."

This is the constraint-6 "tied to resource" formulation. Logic
runs at `format()` time using existing fields:
- `reserve_left[shell] == 0` AND `killing_band == band_where_that_
  shell_is_canonical_answer` → emit the dry-on-X sentence
- pressure-to-shell-answer mapping already exists in PRESSURES.md
  (canonical-answer doc, iter 76); could be a hardcoded const in
  RunRecap.gd or read from BreachConfig

### Gap 4: Route attribution (path-not-taken)

The player saw a route at run-start (the route strip with all bands
in shuffled order). The `band_visit_log` is the path actually
walked. Bands in the run that the player NEVER reached are the
path-not-taken. Surfacing this lets the recap say:
> "Visited: warmup > swarm > bunker. **Skipped: forest, lattice.**"

This is the constraint-6 "tied to route" formulation. Logic: diff
`_route_bands` against `band_visit_log` band-names.

### Gap 5: Auto-generated regret-quote (also serves C15 anchor 5)

From CONSULT 008 + REVIEW-QUEUE #15: the cleanest evidence of the
identity-vs-weapons framing is the regret-quote the player can
articulate. If the recap surfaces a CANDIDATE regret automatically
based on the death state, it gives the player a sharp hypothesis
to confirm or deny in the playtest debrief. Examples:
- "You overcommitted as Prism" (identity framing — you stuck with
  the chassis past its pressure window)
- "You should have switched to Ram before SWARM" (weapons framing
  — the chassis was wrong for the pressure)
- "You ran out of HE before BUNKER — that's a resource bet, not a
  chassis bet"

This is also the cleanest connection to REVIEW-QUEUE #14 (the open
playtest gate) — the recap's regret-quote becomes the playtest
debrief seed.

---

## 3-iter BUILD plan (for review at iter 107 SPIKE)

**iter 107 — SPIKE** (parallel; ~360s): 2-3 alternative recap
rendering shapes. Candidates:
- **α — full-replace**: death panel text = `RunRecap.format()` only
  (keep "YOU DIED" header). Maximally informative but loses the
  ASCENDER stat continuity from arc-2.
- **β — append**: keep ASCENDER block, append a "WHY" section
  below from `format()` (sub-set: build / killed_by / reserve_left
  / band_visits). Preserves arc-2 ritual + adds constraint-6
  payload.
- **γ — sentence**: single natural-language regret-quote derived
  from build_tag + killing_band + reserve_left ("You died in
  BUNKER as a bunker-cracker, dry on HE — wrong band for an
  empty mag."). The other lines collapse to compact ASCENDER
  format. Highest legibility, hardest to author template-wise.

Pick winner at iter 108 DECISION; blueprint the chosen shape.

**iter 108 — DECISION + BUILD** (~240s): implement the winning
shape (Gap 1). One PlayerTank.gd substrate write (×42 — extend
the `_death_label.text =` formatter to include `run_recap.format()`).
Regression harness: `test_breach_run_recap_renders` — set up a
PlayerTank, simulate death, assert `_death_label.text` includes
"build" / "killed by" / "shells fired" lines.

**iter 109 — BUILD** (~240s): kill-source tracking (Gap 2).
Substrate writes ×43 (Bullet.gd or PlayerTank.gd to pipe source
through `take_damage`). Tax: requires either a new `take_damage`
signature OR a `_last_damage_source: String` field set just before
the damage call. Default-on gating: when `run_recap == null`,
don't change behavior. Regression: `test_breach_run_recap_killer`
— hit player with stub Light vs Heavy bullets, assert killer
field reflects the source.

**iter 110 — BUILD** (~240s): resource-attribution sentence
(Gap 3) — adds a derived line in `RunRecap.format()`. Optionally
also Gap 4 (route diff). Regression: `test_breach_run_recap_
resource_sentence` — set various reserve states + bands, assert
the sentence is generated correctly + passes sentence-test
("you ran out of X to handle Y by changing how you used Z" form).

**iter 111 (stretch)**: regret-quote (Gap 5) — optional polish;
deferable if iters 107-110 already lift C9 from 2/5 → 4/5. Reserve
this for a separate round if the surface naturally widens to C15
anchor 5 evidence.

---

## C9 rubric movement projection

Current: **2/5**.

After Gap 1 (wire `format()`): **3/5** — recap is visible; lines
are constraint-6 shaped.

After Gap 2 (kill source): **4/5** — "killed by" is no longer a
placeholder; recap names a concrete cause.

After Gap 3 (+/- Gap 4): **5/5 (effective)** — the recap reads as
an actionable diagnosis tied to resource/build/route. Absolute 5/5
likely requires playtest-cite confirmation (R3 effective-vs-absolute
distinction); iter 110 lifts effective to 5.

---

## Risks + notes

- **Substrate ceiling pressure**: 3-4 PlayerTank.gd substrate writes
  in close succession (×42-44). All default-on gated (the changes
  only run when `run_recap != null`, which only happens in breach
  mode). Hash anchor preserved by construction.
- **Don't over-engineer the kill taxonomy** (Gap 2). 5-7 source
  strings is enough; adding more invites a long-tail of edge cases.
- **Sentence-test discipline** (Gap 3): the generated sentence
  must pass "this upgrade helps me climb through ___ by changing
  how I use ___" reformulated for recap as "I died in ___ because
  I lacked ___" or "my ___ build ran out of ___ for ___ pressure."
- **Regret-quote** (Gap 5) is design-grade — overdetermining the
  quote risks putting words in the player's mouth. Better to
  GENERATE A QUESTION than a STATEMENT — "Could Ram have changed
  SWARM?" beats "Ram would have won SWARM."
- **C9-as-spike-for-C15**: a strong recap also feeds REVIEW-QUEUE
  #14 (playtest gate) and the open identity-vs-weapons question
  (#15). C9 is genuinely the right next round.
