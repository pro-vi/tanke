# Iter 127 — DIAGNOSE — Audio cues surface assessment

Per iter-126 next_action: walk 6 audio-cue candidates and
honestly assess whether audio adds meaningful constraint-6
surface worth building WITHOUT user direction.

---

## The 6 candidates

| # | Candidate | Constraint-6 tie-in | Implementation |
|---|-----------|---------------------|----------------|
| a | Swap-cost rejection cue (audio counterpart to iter-102 panel flash) | Weak — UX feedback only; the iter-102 flash already surfaces the rejection | 1× short "denied" WAV + AudioStreamPlayer trigger in `_flash_shell_panel_reject` |
| b | HE-blast explosion sound | Weak — visual cue (iter-52 `_spawn_he_explosion`) already does the work | 1× boom WAV + trigger in `_spawn_he_explosion` |
| c | Shell-class differentiation by firing sound (AP/HE/HEAT/APCR distinct timbres) | Moderate — lets player identify shell-class by ear; but chip color + Bullet modulate + HUD already do this | 4× distinct fire WAVs; trigger per-shell-class in `_fire` |
| d | Low-HP heartbeat/warning (volume tied to hp ratio) | Moderate — ties to "you're going to die" awareness; could marginally support C9 anchor 3 (identity singularity — "this is its own thing") | 1× looping WAV + per-frame volume update tied to `hp / max_hp` |
| e | Band-arrival musical sting (escalation beat) | Moderate — supports C12 (stakes & escalation); iter-42 visual banner is the structural anchor and already covers the beat | 5× distinct WAVs (one per band); trigger from `_on_breach_band_changed` |
| f | Depot-entry chime | Weak — UX feedback; iter-9 depot pause + visible upgrade choices already do the work | 1× chime WAV + trigger on `depot_entered` |

---

## Asset-generation gating

Critical constraint: **audio asset generation is NOT sanctioned
by PROMPT or any user override.**

- PROMPT explicitly sanctions algorithmic asset gen via
  extended `tools/gen_tile.py` ONLY (no MLX-SD, no external
  generators).
- Round-9 amendment (iter 62) sanctioned `/agentify image_gen`
  specifically for archetype concept SPRITES — image only,
  not audio.
- The loop has no sanctioned path to ship audio assets.

Available alternatives:
1. **Algorithmic synthesis** via Godot's `AudioStreamGenerator` —
   technically possible but produces only basic tones (sine/
   square/saw). Wouldn't satisfy "professional UX" bar; risks
   feeling worse than no audio (cheap-game vibe).
2. **CC0-licensed WAV sourcing** — would require manual user
   action (loop can't browse + license-check audio archives
   autonomously without user direction).
3. **Skip audio assets** — defer until user direction.

Option 3 is the only honest path the loop can take alone.

---

## Constraint-6 honest evaluation

The structural-ceiling audit (iter 115) found that the
constraint-6 surface is already saturated:

- 5-layer death-overlay diagnosis (verdict + killed-by +
  resource + route + candidate-question) covers
  resource/build/route attribution structurally
- Shell-class is visible 3 ways (chip + modulate + HUD)
- Band-arrival has a visual banner + route-strip
- Swap-cost has a panel-flash UX cue (iter 102)

Adding audio to any of these REINFORCES the existing surface
but does NOT add a new diagnosis surface. The visual layer
already does the constraint-6 work.

**None of the 6 candidates would lift a rubric anchor**:
- a/b/f are pure UX polish
- c duplicates info the chip color provides
- d/e could marginally support C9/C12 anchor 3 but those are
  already structurally met

---

## Forward-value-without-user-direction assessment

| Candidate | Cost (asset + code) | Rubric movement | Honest verdict |
|-----------|---------------------|-----------------|----------------|
| a | low (1 WAV) | none | not worth building alone |
| b | low (1 WAV) | none | not worth building alone |
| c | medium (4 WAVs) | none (duplicates visual) | not worth building alone |
| d | low (1 WAV + per-frame logic) | maybe C9 marginal | not worth building alone |
| e | medium (5 WAVs) | maybe C12 marginal | not worth building alone |
| f | low (1 WAV) | none | not worth building alone |

**Conclusion**: NO audio surface is worth building without
user direction. The cost (asset-gen barrier + zero rubric
lift) outweighs the marginal UX gain. Honest output.

---

## The deeper finding

This is the **second consecutive substantive DIAGNOSE** to
conclude "no scope worth building without user direction":
- iter-118 4-option walk concluded Option A (playtest) was the
  highest-value but user-gated; declined C (RUBRIC extension)
- iter-127 (this iter) concludes Audio is gated on asset
  sourcing AND doesn't lift rubric anyway

Combined with the structural-ceiling reality + iter-106
backlog exhaustion, the loop is at the **honest saturation
point**. Per PROMPT it runs non-stop, but the cadence and
scope should reflect this reality. Per ScheduleWakeup guidance:

> Default to 1200s–1800s (20-30 min) for idle ticks with no
> specific signal to watch.

Iter 128+ should shift to ≥1500s wakeup intervals + smaller
META-only scope (status checks, REVIEW-QUEUE maintenance).
The loop continues but doesn't burn cache cycles or generate
busywork.

---

## Recommendation for iter 128

**Round 19 close (1 iter, META)**:
- Write loop/breach/round-19-summary.md naming the DIAGNOSE
  finding ("no audio surface without user direction") as the
  round outcome
- Append REVIEW-QUEUE #25 surfacing the honest saturation
  finding + the audio-DIAGNOSE-also-empty signal
- Update STATE.next_action to **honest cadence shift**: iter
  129+ runs status-check META iters at ≥1500s wakeup until
  user direction arrives (REVIEW-QUEUE #14 playtest OR #13
  asset-gen integration OR explicit scope direction)
- PushNotification to user is appropriate here per
  ScheduleWakeup guidance: "the user may be away and waiting
  to hear it's done" — adapted: "the user may be away and
  the loop is honestly saturated; surface the state"

This is the right time. The loop has shipped 50/75, closed
all backlog, completed every cognitive-max claim, and now
honestly run out of scope it can address alone. Per the
iter-89 directive ("u havent done enough to deserve a pause"),
the loop has now DONE enough — and the explicit ceiling
+ backlog + 2nd-empty-DIAGNOSE evidence justifies surfacing
this to the user honestly.
