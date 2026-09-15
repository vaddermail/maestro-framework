# L05 — Inconsistencies (docs ↔ code ↔ data)

> Loop `L05` of the Maestro framework — persists while inconsistencies exist between
> documentation, code and data, always reconciling against the declared source of truth. Follows
> the anatomy in `loops/README.md`.

Two versions of the same fact that diverge are the most stubborn class of bug there is
(`knowledge/proven-patterns.md` §4) — because neither of them "fails" on its own; they just produce
wrong decisions in silence. This loop exists so that divergence is never resolved by "picking the
one that looks most likely", but always by the declared source of truth.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | Continuous, in any phase — triggered by any agent/guardian/reviewer that notices the divergence |
| **Agent that executes the action** | The agent that owns the source of truth for the fact at hand (`core/artifact-protocol.md` — the spec, the ADR, or the data model, depending on the kind of fact); the Orchestrator coordinates when the source of truth itself is in doubt |
| **Suggested model** | Standard to reconcile against an already clear source; Top when the source of truth itself may be wrong and the decision carries the weight of a business rule (`core/model-routing.md`) |

## Progress metric

Number of inconsistencies detected between artifact pairs (docs↔code, spec↔data, code↔data) in
`open` state.

## Entry condition

There is ≥1 pair of facts that contradict each other across two artifacts (or between an artifact
and the system's actual observed behavior).

## Action (the body of the iteration)

1. Identify the **declared source of truth** for that fact (general rule:
   `product/04-specification/` wins over the code; code+tests win over an outdated secondary
   document — `core/project-memory.md` §The memory layers).
2. If the source of truth is right, fix the diverging side to match it.
3. If the source of truth is **wrong**, fix the source first, with the user's approval
   (`MANIFESTO.md` §8), and only then propagate to the artifacts that depended on it.
4. Record the reconciliation: what diverged, which side won, and why — so the same question is not
   asked again in the next session.

## Exit condition (success)

Zero inconsistencies in `open` state; each one closed with the corrected side identified and the
final source of truth recorded. Verified by someone who did not make the fix (the area's reviewer
or the Orchestrator).

## Anti-infinite-loop safeguard

- **Stagnation:** 3 iterations without reducing the count of open inconsistencies → stop.
- **Oscillation:** the same inconsistency reappears after being "fixed" → sign that the root cause
  keeps generating the drift (e.g. a manual process that should be derived automatically,
  `knowledge/proven-patterns.md` §7) — stop immediately, do not fix the symptom again.
- **Hard cap:** 4 iterations per inconsistency. Once exceeded, escalate to the user: usually a sign
  that an automated guardrail is missing (a test that sweeps and fails), not that the next manual
  fix will stick.

## STATE.md record

```
L05 · inconsistencies · metric 6→3→1 · iter 3 (cap 4) · last progress: iter 3 · status: in progress
```

## Example (B2B SaaS — subscription plan)

The `documentation-reviewer` notices that the help page says "the Starter plan allows up to 5 users
per account", but the validation code (`userLimit.ts`) uses the constant `10`. The specification
(`product/04-specification/modules/subscriptions.md`) says `5` — it is the source of truth. The
origin of the `10` is investigated: it was a manual tweak made during an incident three months ago
to unblock a customer, never reverted nor documented. The code is fixed to `5` (the source of truth
is right), the reconciliation is recorded, and a lesson is written in `STATE.md`: "manual tweaks in
production need a reversal ticket — this one stayed divergent for three months without anyone
noticing."

## Related

- `core/artifact-protocol.md` — §Handling rules, the spec precedence rule.
- `core/project-memory.md` — the layering of sources of truth.
- `knowledge/proven-patterns.md` — §4, §7, SSOT and automated guardrails.
- `agents/13-guardians/documentation-guardian.md` — detects docs↔code divergence on its cadence.
- `agents/12-reviewers/documentation-reviewer.md` — the main manual detector.
- `core/decision-engine.md` — when the source of truth itself needs to be corrected.
