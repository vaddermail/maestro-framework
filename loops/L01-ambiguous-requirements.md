# L01 — Ambiguous Requirements

> Loop `L01` of the Maestro framework — persists while ambiguous, contradictory or missing
> requirements exist, until everything critical is disambiguated or proven to be beyond the
> session's reach. Follows the anatomy in `loops/README.md`.

An ambiguous requirement accepted in silence is the cheapest defect to avoid and the most expensive
to discover late — it resurfaces in every following phase, more expensive to fix each time
(architecture already chosen, UI already designed, code already written). This loop exists so that
no ambiguity survives F2 without becoming an explicit question to the user.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F2 (main); reopened in F5 when the specification exposes new gaps |
| **Agent that executes the action** | `agents/01-requirements/ambiguity-hunter.md` detects and phrases the question; the artifact's owner agent (`requirements-engineer`, `business-rules-modeler`, `nfr-specifier`, `acceptance-criteria-writer`, `glossary-curator`) applies the answer |
| **Suggested model** | Top, medium effort, for the adversarial detection (`core/model-routing.md`); Standard to apply the answer to the artifact |

## Progress metric

Number of `A-nnn` findings with **critical** severity in `open` state in the F2/F5 artifacts
(ambiguity + contradiction + gap, summed). Countable per artifact and in total, comparable batch to
batch because each finding has a stable ID.

## Entry condition

At least one critical `A-nnn` finding exists in `open` state — detected by the Ambiguity Hunter in
a per-artifact or cross-artifact pass (`agents/01-requirements/ambiguity-hunter.md` §Workflow).

## Action (the body of the iteration)

1. The Hunter reads the artifact(s) changed since the last pass and updates the list of `A-nnn`
   findings (new, reopened, closed).
2. The Orchestrator groups the findings that require a user decision into a **coherent batch** (3–8
   questions, never more than 12) via `core/question-engine.md`, stating what each answer unblocks.
3. The batch is put to the user; meanwhile, work that does not depend on the answers continues —
   the loop does not wait in the dark.
4. Each answer that arrives is applied by the owner agent of the corresponding artifact (never by
   the Hunter, which only detects).
5. The Hunter re-verifies the findings touched by the answer and closes those that were resolved.

## Exit condition (success)

Zero critical findings in `open` state, confirmed by the Ambiguity Hunter in a final cross-artifact
pass over all F2 artifacts — each owner agent declaring its own artifact fixed in isolation is not
enough, because contradiction lives **between** documents.

## Anti-infinite-loop safeguard

- **Stagnation:** 3 consecutive question batches without reducing the critical findings count →
  stop.
- **Oscillation:** a finding closed by one answer is reopened by a later contradictory answer about
  the same term/rule → treat as a cycle immediately, do not wait for the 3rd iteration; a sign that
  the original question was badly designed (revise it, do not repeat it as-is).
- **Hard cap:** 8 batches per phase. Once exceeded, the loop stops: it records in `STATE.md` →
  "Decisões pendentes" the findings that remain, with why they did not converge (user unavailable,
  contradictory answers, scope still to be decided), and escalates to the user with options (cut
  the requirement from the MVP, accept a non-critical ambiguity with the risk recorded, or change
  who decides).
- A user who does not answer **does not count as an iteration without progress** — the question
  engine already ensures the loop does not spin on empty (`core/question-engine.md` §Associated
  loop); the safeguard fires on batches actually answered that resolved nothing.

## STATE.md record

```
L01 · ambiguous requirements · metric 9→5→2 · iter 3 (cap 8) · last progress: iter 3 · status: in progress
```

On closing (metric at zero, verified), it collapses into one line in "Registo histórico"
(`core/project-memory.md` §Memory hygiene) with the date and the total of findings resolved.

## Example (B2B SaaS — subscription billing)

The `requirements-engineer` writes **FR-018**: *"The system charges automatically at the start of
each cycle."* The Hunter raises three findings on the same statement: **A-031** (ambiguity) — is
"start of the cycle" each customer's subscription date, or the 1st of the calendar month for
everyone?; **A-032** (gap) — what happens if the card is declined: retry, suspend access, or only
notify finance?; **A-033** (contradiction) — FR-018 implies automatic charging, but **BR-009** says
"any charge above €500 requires manual approval from finance". The three become batch
P-041/042/043. The user answers: cycle by subscription date; retry 3× within 48h and then suspend;
BR-009 only applies to one-off upsell invoices, not the recurring monthly fee. The
`requirements-engineer` and the `business-rules-modeler` fix the artifacts, the Hunter re-verifies
and closes the three findings.

## Related

- `core/question-engine.md` — the batched questioning mechanism this loop triggers.
- `agents/01-requirements/ambiguity-hunter.md` — the agent that owns detection.
- `agents/01-requirements/README.md` — the owner agents that apply the answers.
- `core/quality-gates.md` — P2 does not pass with critical findings open.
- `core/orchestrator.md` — §Recovery and exceptions, the origin of the rule of 3.
- `knowledge/ai-pitfalls.md` — §3, assuming instead of asking, the pitfall this loop blocks.
