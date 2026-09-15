# L08 — Technical Debt

> Loop `L08` of the Maestro framework — persists while recorded technical debt exists, reducing it
> in a planned, reversible way, prioritized by the interest it charges, never by the size of the
> item. Follows the anatomy in `loops/README.md`.

Unrecorded technical debt is not "zero debt" — it is invisible debt, the most expensive kind of
all, because nobody prioritizes it. This loop exists so that debt is a living list, with estimated
interest, paid down deliberately — never in an end-of-quarter "big bang".

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F9 — planned, per cycle (not per event) |
| **Agent that executes the action** | The Orchestrator prioritizes and plans the cycle; the agent that owns the item's area (`agents/05-backend/`, `agents/04-frontend/`, `agents/06-data/`, `agents/07-devops/`, depending on the item) executes |
| **Suggested model** | Standard for planning and executing; Top when the item requires revisiting an architecture decision (ADR) to be resolved for good (`core/model-routing.md`) |

## Progress metric

**Total estimated interest** of the recorded, unpaid debt — recurring cost in time/risk/friction
(e.g. hours lost per month, avoidable incidents, slowness of change), not the count nor the size of
the items. A small item with high interest is prioritized before a large item with low interest.

The interest unit is **person-hours per month** of recurring friction attributable to the item
(manual workaround time, re-interventions, avoidable incidents × duration), estimated per item
**with the evidence behind it** (occurrences counted in the period, measured times). A downward
re-estimate without new evidence is metric fraud (`loops/README.md` §Cross-cutting principles);
only paying off the item or new data changes it.

## Entry condition

There is ≥1 item in `STATE.md` §Debt (the debt's only home — `core/project-memory.md` §STATE.md —
the handover) with estimated interest > 0, still unpaid.

## Action (the body of the iteration)

1. Order the items by **interest**, not by size nor by age.
2. Pick the highest-interest item and design the **smallest additive, reversible step** that
   reduces it — never a big-bang that rewrites everything at once
   (`knowledge/permanent-rules.md` §3, §4).
3. Implement behind a feature flag when the step carries regression risk
   (`modules/feature-flags.md`).
4. Measure whether the interest actually dropped (the symptom that motivated the record
   disappeared or measurably decreased) — the feeling of "cleaner code" is not enough.

## Exit condition (success)

Total interest ≤ the threshold agreed with the user for the cycle. Defaults per profile (in
person-hours per month, the unit of §Progress metric): prototype — loop disarmed; internal product
≤10 h/month; commercial product ≤6 h/month; enterprise platform ≤3 h/month. The value agreed during
F0 calibration is recorded in the project's `CLAUDE.md`, §F0 calibration
(`workflows/W00-project-kickoff.md` §Decision points). An item counted as closed has proof that the
interest stopped accruing, not just that the code changed.

## Anti-infinite-loop safeguard

- **Stagnation:** 3 items paid consecutively without lowering the total interest → stop the cycle.
- **Oscillation:** paying debt A creates debt B with equivalent interest (swapping one shortcut for
  another) → stop immediately; sign that the chosen step was not truly additive/structural.
- **Hard cap:** 5 items per planning cycle, regardless of progress. Once exceeded, the cycle stops:
  record what was paid, what remains, and why (lack of time, item larger than estimated, pending
  architecture decision), and escalate to the user to replan the next cycle — never stretch a cycle
  indefinitely to "finish the list".

## STATE.md record

```
L08 · technical debt · metric interest 40h/mo→28h/mo→28h/mo · iter 3 (cap 5) · last progress: iter 2 · status: AT RISK
```

## Example (data platform — reporting pipeline)

The debt register has an old item: "the nightly aggregation job runs serially, takes 6h, and 1
person has to restart it manually when it fails midway" — estimated interest: ~4h/week of manual
attention + risk of late reports. It is the highest-interest item of the cycle (more than a bigger
item — "migrate the ORM" — whose interest is near zero because it rarely hurts). The additive step
chosen: not rewriting the whole pipeline, just making it **resumable per stage** (a checkpoint
after each data source processed), behind a flag. After a month in production, midway failures no
longer require a manual restart — the measured interest drops to near zero. The "migrate the ORM"
item stays on the list, untouched, because its interest did not justify the cycle.

## Related

- `core/orchestrator.md` — §Effort profiles; the threshold defaults live in this loop's
  §Exit condition and the project's value in its `CLAUDE.md` §F0 calibration.
- `core/project-memory.md` — where technical debt is recorded and tracked across sessions.
- `modules/feature-flags.md` — how to pay down risky debt behind a kill-switch.
- `knowledge/proven-patterns.md` — the target patterns of many debt payments.
- `workflows/W09-continuous-operation.md` — the F9 cadence where this loop runs by default.
- `workflows/W10-feature-evolution.md` — when a debt item converts into an evolution request.
