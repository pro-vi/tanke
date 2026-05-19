# Breach loop pre-mortems (arc 4)

Append-only. One block per iter, written **before** ACT. H2 RULE v2 tags
mandatory: `[STRUCTURE]` / `[FEEL]` / `[MIXED]` / `[STRUCTURE-DEFERRED]` /
`[IDENTITY-PROTECTED]`.

Every entry cites which of the seven CONSULT §9 constraints the iter
respects or risks. Falsifiable claim required.

Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [<tag>]
- CONSULT constraints respected: <list>
- CONSULT constraints risked: <list, if any>
- Predicted failure: <where this iter might fail>
- Falsifiable claim: <a concrete observable that would prove the prediction>
- Sentence test (if upgrade-touching): "This upgrade helps me climb through ___ by changing how I use ___"
- Substrate touched: <files, if Layer 1/2/3>
- Hash-anchor verification plan: <pre-/post-edit check, or n/a>
```

---

## iter 000 — META — preloop complete

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design work yet; substrate-only)
- CONSULT constraints risked: none
- Predicted failure: substrate may have drifted across the 3 modified files
  in git status (`project.godot` shows `M`) → either hash anchor breaks or
  `make test` fails.
- Falsifiable claim: `make test` exits 0 AND `loop/test_runner.gd` on seed
  42 / default config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND
  `playable: true` AND OG `check-chain` reports `CHAIN_25_OK`.
- Sentence test: n/a (no upgrade)
- Substrate touched: none (read-only verification)
- Hash-anchor verification plan: post-verification, pre-flip of
  `preloop_complete: yes`. Result: PASS (`23d6a2ec3bf2821f` confirmed).
