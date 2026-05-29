# Iter 107 — SPIKE — C9 recap rendering-shape POCs

3 parallel POCs against the same `RunRecap` data model. Goal:
pick the shape that lifts C9 from 2/5 → 4/5 in one BUILD iter
(Gap 1 wire), with the most room to absorb Gaps 2-4 later.

## Constraints from the substrate

- **Death panel size**: 208×130 px at (56, 56).
- **Death label size**: 176×116 px at (72, 64); centered; font_size=12;
  outline_size=2; light pink color, dark red outline.
- **Effective text capacity**: ~9-10 lines of font_size=12 text.
- **Breach playtest prompt** lives in a SEPARATE panel
  (`_breach_prompt_panel` at (24, 192), 272×56) — appears below the
  death panel. It already shows `bands visited: a > b > c` since iter
  83. The SPIKE is about the DEATH panel; the prompt panel is
  orthogonal.
- **Data sources** (all already present):
  - `RunRecap.depth_reached`, `killing_band`, `killing_pressure`,
    `killer`, `he_reserve_at_death`, `heat_reserve_at_death`,
    `band_visit_log`, `archetype`, `shells_fired`
  - `RunRecap.build_tag()`, `format()`, `band_signature()`
  - **`band.canonical_answer`** — already a field on every
    BreachBand resource. Each band has a one-sentence diagnostic
    string like `"APCR 1-shots; HEAT 2-shots entrenched heavies"`.
    This is the killer feature for shape γ.

## Test death state (used to render each POC)

A representative MORTAR-build run that died in the bunker:
- depth_reached: 95
- killing_band: "bunker_zone"
- killing_pressure: "steel-armored bunkers; entrenched heavy tanks"
- band.canonical_answer: "APCR 1-shots; HEAT 2-shots entrenched heavies"
- killer: "shell impact" (current placeholder — Gap 2 would change it)
- he_reserve_at_death: 0, heat_reserve_at_death: 1
- archetype: MORTAR (=2)
- shells_fired: AP 14 / HE 5 / HEAT 2 / APCR 0
- band_visit_log: tutorial_choke → brick_maze → bunker_zone
- skipped (path-not-taken): open_killbox, endgame_mixed
- build_tag(): "mixed breacher"
- time: 4:32, kills: 18, cancels: 3, stall: 12%, best: 110

---

## POC α — full-replace

Wholesale replace `_death_label.text` with `RunRecap.format()`
prefixed by "YOU DIED". Drop the arc-2 ASCENDER stat block.

```
YOU DIED

RUN RECAP
  depth reached : 95  (bunker_zone band)
  band pressure : steel-armored bunkers; entrenched
  build         : mixed breacher
  killed by     : shell impact
  shells fired  : AP 14 / HE 5 / HEAT 2
  reserve left  : HE 0 / HEAT 1
  band visits   : tutorial_choke > brick_maze > bunker_zone
```

**Lines used**: 9 (fits at the ceiling).
**Pros**:
- Uses `RunRecap.format()` verbatim — minimal code (one line).
- Shows everything the recap captures.
- Constraint-6 shape (band / build / shells / reserve).
**Cons**:
- Loses arc-2 ASCENDER ritual: no DEPTH separately, no TIME,
  KILLS, CANCELS, STALL, BEST — those are the LONG-RUN progression
  signals across deaths.
- Wraps the long pressure string mid-word at the panel width.
- "killed by : shell impact" is the placeholder — looks broken
  until Gap 2 lands.
- Reads as a doc dump, not a verdict.

## POC β — append

Keep the arc-2 ASCENDER block, append a "— WHY —" section below
from `RunRecap.format()` (subset: build / killed_by / reserve /
band_visits).

```
YOU DIED

DEPTH 95
TIME 4:32
KILLS 18 / CANCELS 3
STALL 12%
BEST 110

— WHY —
band: bunker_zone (steel+heavies)
build: mixed breacher
killed: shell impact
HE 0 / HEAT 1 left
route: choke > maze > bunker
```

**Lines used**: 14 (OVERFLOWS the 116px label height).
**Pros**:
- Preserves arc-2 ASCENDER continuity.
- Adds constraint-6 payload below.
- Long-run players still get BEST tracking.
**Cons**:
- Overflows the death panel — needs either a larger panel (substrate
  growth) or compression of one block. Compressing ASCENDER to one
  line ("D95 · T4:32 · K18 · BEST 110") brings it down to ~11
  lines, still tight.
- Two distinct sections feel like two recaps glued together; no
  single verdict statement.
- Worst legibility-per-line of the three.

## POC γ — sentence

Derive a single natural-language verdict sentence from
`build_tag` + `killing_band` + `reserve_left` + `canonical_answer`.
Compact ASCENDER as a one-line footer.

```
YOU DIED

Died at depth 95 in BUNKER_ZONE
as a MIXED BREACHER —
0 HE, 1 HEAT against
steel + heavies.

(canonical answer: APCR)

DEPTH 95 · TIME 4:32 · KILLS 18
BEST 110
```

**Lines used**: 9 (fits).
**Pros**:
- Single declarative verdict satisfies constraint 6 directly: names
  band + build + resource state in one sentence.
- "canonical answer: APCR" turns the recap into a DIAGNOSIS — the
  player learns what the band wanted, not just what they had. This
  is the constraint-6 "tied to resource/build/route" formulation
  made *actionable*.
- Compact ASCENDER footer preserves BEST tracking + the arc-2 metric
  ritual without dominating the panel.
- Most directly answers "what did I do wrong here?" — the question
  the playtest prompt asks below.
- Highest sentence-test compatibility: the diagnosis reads as
  "I died in __X__ because my __Y__ build was dry on __Z__ for
  __W__ pressure" — the canonical mapping back to the upgrade
  sentence-test grammar.
**Cons**:
- Hardest to author. The sentence template has 4-5 fill-ins; need
  defensive defaults for null/missing fields.
- "MIXED BREACHER" / "0 HE, 1 HEAT against steel+heavies" template
  uses `build_tag()` + first-2-words of pressure — could read
  awkwardly for some pressures (e.g. "all prior pressures composed
  ; no further depots" → "all prior").
- Reveals the canonical answer every run — could be seen as
  spoonfeeding the design. Mitigation: only show on death (not
  on win), make it parenthetical, keep it terse.

---

## Comparison matrix

| Axis | α full-replace | β append | γ sentence |
|------|----------------|----------|------------|
| Lines (must be ≤ 10) | 9 ✓ | 14 ✗ | 9 ✓ |
| Constraint-6 shape | ✓ payload | ✓ payload | ✓ verdict + diagnosis |
| Arc-2 ASCENDER continuity | ✗ lost | ✓ kept | ✓ compact footer |
| BEST tracking visible | ✗ | ✓ | ✓ |
| Verdict-grade legibility | ✗ doc dump | ✗ split | ✓ single sentence |
| Sentence-test compatibility | weak | weak | strong |
| canonical_answer surfaced | no | no | **yes** |
| Substrate write count (Gap 1) | 1 | 1 + panel resize | 1 |
| Authoring complexity | trivial | trivial | medium |
| Brittleness on null fields | low | low | medium (template) |
| Room to absorb Gap 2-4 later | ✓ | tight | ✓ |

---

## Recommendation: **γ — sentence**

γ wins on the criteria that matter for C9's rubric movement:
- It IS a verdict ("tied to resource/build/route, not 'got
  overwhelmed'"), not a stat dump. That's the constraint-6 spirit.
- The `canonical_answer` surfacing turns the recap into a DIAGNOSIS
  — closes the loop from "what happened" to "what would have
  worked." That's the C9 jump from 3/5 to 4/5+.
- Compact footer preserves arc-2 ritual (BEST tracking) without
  competing for verdict space.
- Sentence-test compatibility makes it a direct connection to
  Gap 5 (auto-regret-quote, future round) — the sentence IS a
  regret-quote candidate already.

Fallback to **β** if the sentence template proves brittle in
iter-108 BUILD (e.g., 2+ null fields produce ungrammatical output).
The fallback is structural — α and β both use RunRecap.format()
verbatim, so swapping the renderer would be one-line.

## Authoring spec for γ (iter 108 blueprint)

Add to `RunRecap.gd`:

```gdscript
# Compose a one-sentence verdict from build + killing_band +
# reserve_left + (optionally) the band's canonical_answer.
# `canonical_answer` is read from the killing band at format() time
# OR passed in via capture_death extension (BreachBand has the field).
func verdict_sentence(canonical_answer: String = "") -> String:
    var build: String = build_tag()
    var resource_clause: String = _format_resource_clause()
    var pressure_short: String = _pressure_first_phrase()
    var s: String = "Died at depth %d in %s\nas a %s —\n%s against\n%s." % [
        depth_reached,
        killing_band.to_upper(),
        build.to_upper(),
        resource_clause,
        pressure_short,
    ]
    if not canonical_answer.is_empty():
        s += "\n\n(canonical answer: %s)" % _canonical_answer_brief(canonical_answer)
    return s
```

Helpers:
- `_format_resource_clause()` → "0 HE, 1 HEAT" (skip APCR; only
  show reserves that are LOW relative to max; if all comfortable,
  fall back to "with shells to spare")
- `_pressure_first_phrase()` → take pressure up to first ";" then
  truncate to ≤30 chars
- `_canonical_answer_brief(s)` → take answer up to first ";" then
  truncate to ≤24 chars

PlayerTank.gd change (substrate write ×42):
```gdscript
# replace _death_label.text line with:
var verdict: String = ""
if run_recap != null:
    var ca: String = ""
    if band != null and "canonical_answer" in band:
        ca = String(band.canonical_answer)
    verdict = "\n" + run_recap.verdict_sentence(ca)
var footer: String = "DEPTH %d · TIME %d:%02d · KILLS %d\n%s" % [
    depth, t / 60, t % 60, kills, best_line_compact
]
_death_label.text = "YOU DIED" + verdict + "\n\n" + footer
```

Regression harness `test_breach_run_recap_verdict_sentence`:
- Set known death state, assert `verdict_sentence(canonical)` matches
  the expected template.
- Edge cases: missing band (null killing_band → grammar fallback),
  all reserves comfortable (→ "with shells to spare"), missing
  canonical_answer (→ skip the trailing parenthetical).
- Substrate write ×42 verifiable in test_breach_recap if it exists,
  or add a new harness asserting `_death_label.text` after a
  simulated death includes "Died at depth" and the verdict shape.

---

## Next iter (108) commitment

iter 108 — DECISION + BUILD:
1. Affirm γ recommendation (or fall back to β with a noted
   reason).
2. Implement `RunRecap.verdict_sentence()` + helpers + wire to
   `_death_label.text` in PlayerTank.gd (substrate write ×42).
3. Add regression `test_breach_run_recap_verdict_sentence`
   (≥4 assertions: shape, resource-clause, canonical-skip,
   long-pressure-truncate).
4. Verify hash anchor + test-all + test-breach (55 → 58).
5. Score C9 → 3/5 (effective; absolute 5/5 requires playtest cite
   per R3, deferred to playtest pass).
6. ScheduleWakeup iter 109 (Gap 2 — kill source tracking).
