# tanke — Originals Loop REVIEW QUEUE

Append-only list of items the loop can't verify on its own and needs human
eyes for. Adopted iter 10 per user directive to suspend the 3-iter PLAYTEST
halt rule and accumulate review items instead.

The user reviews this queue at arc close (or whenever they want a batch
look). Each item has a STATUS field:
- `open` — needs human review
- `closed:VERDICT` — user reviewed; verdict cited
- `superseded:ITER` — later iter rendered item moot

When closing, cite the LEDGER iter that captured the closure.

---

## Queue items

### #1 — TitleScreen aesthetic ("ugly" feedback)

**Opened:** iter 10
**Source:** user playtest reply to iter-9 halt message:
> "title can nav but is ugly"

**Context:** `scenes/TitleScreen.tscn` ships a minimal layout: black background, "TANKE" title (size 24), subtitle "Battle City NES — 1985 / Procedural Ascender", two text options (ORIGINALS / PROCEDURAL), yellow `>` cursor, hint text. Functional but austere.

**Anchor options for direction:**
- (a) **BC-style logo**: render "TANKE" as a pixel-art logo with the BC tank silhouettes; keeps text but adds visual identity.
- (b) **Animated cursor**: replace the static `>` with a small animated tank sprite that moves between options + pulses; adds motion + game-context.
- (c) **Background scene**: a slow-scrolling Stage 1 layout in the background of the menu; ties title to gameplay visually.
- (d) **Combination**: (a) + (b), keep background black.

**What I need from the user:** a direction-pick (a/b/c/d) OR a free-form description of what "less ugly" looks like. Without it, any visual change is Goodhart-prone.

**STATUS:** open

---

### #2 — Q2 BC-recognition cite still missing

**Opened:** iter 10
**Source:** user playtest reply mentioned Stage 1 only via the eagle mechanic test:
> "stage 1 shooting my own eagle trigger game over"

**Context:** Q2 was "Does Stage 1 look like Battle City Stage 1?" — user didn't explicitly cite recognition. They did treat it as Stage 1 (no "this doesn't look right"), but the rubric anchors for C11 (Identity / BC fidelity) ≥3 require explicit recognition statement.

**What I need from the user:** at end of arc (or whenever convenient), a yes/no on:
- Does Stage 1 visually scan as BC Stage 1 within 10 seconds of looking? (C11 anchor 3)
- Can you name 3+ specific BC features that match? (C11 anchor 4)
- Does it feel like BC unprompted? (C11 anchor 5)

**STATUS:** open

---

### #3 — Full 1-35 playthrough (C10 anchor 5)

**Opened:** iter 10
**Source:** PROMPT close condition: "Full 1-35 reachable + 'win' state when stage 35 cleared; full playthrough verified via playtest."

**Context:** Iter 7 wired the StageDirector + dev N-key to advance stages programmatically. But "playthrough verified via playtest" requires a human to actually advance through all 35 stages in one session and confirm the ARC COMPLETE overlay fires. With Spawner integration (iter 11+), this becomes a real playthrough (clear-condition fires naturally).

**What I need from the user:** at end of arc, ~5-15 minutes of advancing through stages (with N-key OR natural clear), confirming progression works end-to-end and the ARC COMPLETE overlay renders.

**STATUS:** open

---

### #4 — Eagle-felt-like-BC cite (C2 anchor 4-5)

**Opened:** iter 10
**Source:** C2 anchor 4: "Eagle gameplay verified via playtest — 'the eagle felt like BC's eagle' — feel-cited."

**Context:** User confirmed the mechanic (eagle takes damage → game over) but didn't speak to whether the eagle FEELS like BC's eagle (tension, sprite identity, defend-or-die anchor).

**What I need from the user:** when reviewing queue, name whether the eagle's presence + destruction created the BC defend-the-eagle feeling. If yes, anchor 4 lifts. If no, queue → "eagle redesign needed" sub-item.

**STATUS:** open

---

## Queue review policy

- The loop runs structurally between queue updates.
- Items added each iter that surfaces something user-only-verifiable.
- User triggers a queue review by saying "review queue" (or any clear signal).
- On review, batch-close items with cited verdicts; each closure can lift criterion scores AND/OR spawn iter follow-ups.
- This pattern overrides PROMPT § HALT CONDITIONS: "PLAYTEST unfulfilled for 3 iters → HALTED.md" — formally still in PROMPT.md as v2 text; operationally suspended per user iter-10 directive. (PROMPT v3 candidate would codify this; not done in-arc.)
