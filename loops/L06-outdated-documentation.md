# L06 — Outdated Documentation

> Loop `L06` of the Maestro framework — persists while documentation exists that is out of sync
> with the product's real state, always updating from the source. Follows the anatomy in
> `loops/README.md`.

Wrong documentation is worse than none — it misleads with confidence. This loop exists so that
documentation never becomes "a known, tolerated mess": either it is in sync, or it is flagged and
being fixed.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F9 (the guardian's cadence); also triggered right after any relevant change to the code/product |
| **Agent that executes the action** | `agents/13-guardians/documentation-guardian.md` detects and updates; `agents/11-documentation/technical-writer.md` writes when the change is substantial; `agents/12-reviewers/documentation-reviewer.md` confirms sync |
| **Suggested model** | Economy when the update is mechanical (mirroring a change already clear in the code/spec); Standard when it requires reconciling with a business decision (`core/model-routing.md`) |

## Progress metric

Number of documents/sections detected as outdated (reference to something that has already changed,
example that no longer matches real behavior, link to an obsolete artifact).

## Entry condition

`agents/13-guardians/documentation-guardian.md` (or any agent/reviewer) detects ≥1 document that
diverges from the real state of the code/product.

## Action (the body of the iteration)

1. Confirm the **current source of truth** for the documented fact (code, approved spec, ADR) —
   never invent what changed; if the source is unclear, the loop does not advance on its own — it
   asks (`core/question-engine.md`).
2. Update the documentation from that source, with real, current examples.
3. If the fact also lives in UI labels/help text, update the **single source**
   (`modules/single-source-of-content.md`) instead of duplicating the fix in two places.
4. Mark the artifact as `approved` again (`core/artifact-protocol.md`).

## Exit condition (success)

Zero documents detected as outdated; `agents/12-reviewers/documentation-reviewer.md` confirms the
sync in an independent pass.

## Anti-infinite-loop safeguard

- **Stagnation:** 3 update cycles without reducing the count of outdated documents → stop.
- **Oscillation:** the same document diverges again in the very next cycle → sign that it is being
  maintained by hand where it should be derived (e.g. an API reference that should be generated
  from the schema, `agents/11-documentation/api-documenter.md`) — stop and propose the automation
  instead of repeating the manual fix.
- **Hard cap:** 4 iterations per document. Once exceeded, escalate to the user with a proposal to
  change how that document is maintained (generated vs. hand-written).

## STATE.md ledger

```
L06 · documentation · metric 8→4→4 · iter 3 (cap 4) · last progress: iter 2 · status: AT RISK
```

## Example (internal app — expense approval tool)

The operations runbook (`product/07-operations/runbooks/reprocess-failed-expense.md`) describes a
command `npm run reprocess -- --id=X`, but the most recent F6 slice replaced the CLI script with a
button in the backoffice ("Reprocess"), without updating the runbook. The documentation guardian
detects the divergence on its weekly cadence by cross-checking the runbook against `CHANGELOG.md`.
It confirms the source (the backoffice code, already in production), rewrites the runbook with the
new procedure and a migration note ("before: CLI; now: button X on screen Y, same permission"), and
asks the `documentation-reviewer` to confirm against real behavior. Without this loop, the next
3 a.m. incident would follow a runbook that no longer exists.

## Related

- `agents/13-guardians/documentation-guardian.md` — owner of the detection-and-fix cadence.
- `agents/13-guardians/README.md` — cadences and the report shared by all guardians.
- `agents/12-reviewers/documentation-reviewer.md` — independent verification.
- `agents/11-documentation/technical-writer.md` — who writes when the change is substantial.
- `modules/single-source-of-content.md` — avoids duplicating the fix in screen and document.
- `workflows/W09-continuous-operation.md` — the F9 cadence where this loop runs by default.
