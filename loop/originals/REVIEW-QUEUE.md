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

**User vote (iter 18 playtest):** **(d)** — BC logo + animated tank cursor combo.

**STATUS:** **closed:d (iter 20)** — `img/title_logo.png` (96×16 hand-bitmapped "TANKE" in BC red-orange with 1-px dark shadow) + `img/title_cursor.png` (32×16 2-frame sprite sheet, yellow tank with cycling treads at 4 fps) replace the old text Label + ">" cursor. `scenes/TitleScreen.tscn` switched Title from Label to Sprite2D, Cursor from Label to AnimatedSprite2D (autoplay = default). TitleScreen.gd cursor type widened to Node2D. Visual verification: 670 logo pixels + 130 cursor pixels in their expected regions.

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

### #5 — arc-3 lacks BC's implicit edge walls (surfaced iter 12)

**Opened:** iter 12
**Source:** `tools/og_metrics.py` stage-bounded BFS vs `loop/test_runner.gd` viewport-bounded BFS divergence.

**Context:** BC's playfield has implicit walls at the 26×26 stage edge — tanks can't escape the playfield. arc-3's OG mode centers the 26×26 stage in the 40×30 viewport but leaves the 7-cell horizontal + 2-cell vertical borders open (no terrain → passable). The Godot reachability oracle therefore reports `playable: true` for all 35 stages because the player can roam through the border, even when the BC stage interior is heavily walled (e.g. stages 21, 34, 35).

**Stage-bounded measurement** (BC-authentic):
- Stage 21: 58 reachable cells; playable=false (rows_climbed=2)
- Stage 34: 26 reachable cells; playable=false (rows_climbed=2)
- Stage 35: 176 reachable cells; playable=false (rows_climbed=8)

**Viewport-bounded measurement** (current arc-3 reality):
- All 35 stages playable=true; 800+ reachable cells

**Anchor options:**
- (a) Add invisible StaticBody2D walls at scene cells 7/32 (x) and 2/27 (y) of OriginalLevel.tscn to enforce BC-authentic playfield boundaries.
- (b) Leave the leakiness; document that arc-3 v1 is "BC stages displayed in a wider viewport." Acceptable if user prefers more breathing room.
- (c) Render decorative grey-frame around the playfield to visually indicate the boundary, even if tanks can technically cross it.

**What I need from the user:** pick (a/b/c) at queue review. (a) is BC-authentic; (b) is arc-3-pragmatic; (c) is cosmetic compromise.

**User vote (iter 18 playtest):** **(a)** walls — implicit from "i can drive off border" flagged as a problem.

**STATUS:** closed:walls (iter 18). 4 invisible `StaticBody2D` walls added to `scenes/OriginalLevel.tscn` at the 26×26 BC playfield boundary. Verified via headless physics point-query (collision at wall center; interior uncolloided). PNG-diff <5% preserved across 4 sample stages.

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
