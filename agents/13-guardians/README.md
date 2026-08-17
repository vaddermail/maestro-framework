# Guardians — the permanent production team

The category that embodies principle 10 of `MANIFESTO.md`: **maintenance starts on day 0**. A
product is not "finished" when it reaches production — that is where it starts to live. The
guardians are the team that keeps it alive years later, each watching **one** dimension on **its
own cadence**, without waiting for a human to remember to look.

All belong to phase **F9 — continuous operation** (`core/lifecycle.md`), orchestrated by
`workflows/W09-continuous-operation.md`. They are not one-off like the F7 reviewers
(`agents/12-reviewers/`): reviewers give a verdict at a milestone and leave; guardians **never
finish** — they come back on the next cadence. Where a reviewer asks "is it good enough to
launch?", a guardian asks "is it still good, today?".

## What sets a guardian apart

- **Own cadence** (daily/weekly/monthly or per event), not a single convocation.
- **Fixed cycle:** analyze → plan → apply → validate → document. Never applies without validating;
  never closes without writing.
- **Auditable terminal states:** every finding of the cycle ends resolved, mitigated (residual
  risk accepted by the user) or not-applicable (justified). No "under analysis" pending without an
  owner and a deadline.
- **Reports to the Orchestrator** (`core/orchestrator.md`), which batches questions to the user
  and chains guardians together (Security triggers Dependencies; Costs reads Performance's
  output).

## Agents in this category

| Agent | Watches | Typical cadence |
| --- | --- | --- |
| `agents/13-guardians/security-guardian.md` | CVEs, dependencies, containers, OS, cloud (exemplar) | daily + per CVE |
| `agents/13-guardians/dependency-guardian.md` | deliberate dependency updates (non-security) | weekly + monthly (majors) |
| `agents/13-guardians/performance-guardian.md` | CPU, RAM, queries, APIs, cache, LCP/CLS/TTFB vs budgets | continuous + weekly |
| `agents/13-guardians/cost-guardian.md` | infra, API and AI costs (product and development) | monthly + anomaly alert |
| `agents/13-guardians/quality-guardian.md` | code smells, duplication, complexity, coverage, architecture drift | weekly + per release |
| `agents/13-guardians/documentation-guardian.md` | docs↔code↔product sync | per release + weekly |
| `agents/13-guardians/backup-guardian.md` | existence **and** real restore of backups | daily check + periodic drill |
| `agents/13-guardians/value-guardian.md` | business KPIs vs discovery targets — did the promised value happen? | monthly |
| `agents/13-guardians/feature-evolution-agent.md` | new requests in production (W10 coordinator) | per event (request) |

## Cadences per profile (the single source)

This table is the **single source** of cadences — `core/orchestrator.md` §Effort profiles and
`workflows/W09-continuous-operation.md` point here. In the **prototype**, all guardians stay
**disabled** until the decision to continue. A project may **tighten** a cadence (never loosen it
without user-accepted risk), recording it in its `CLAUDE.md`.

| Guardian | Internal product | Commercial product | Enterprise platform |
| --- | --- | --- | --- |
| Security | weekly + per critical CVE | daily + per CVE | daily + per CVE |
| Dependencies | monthly | weekly + monthly (majors) | weekly + monthly (majors) |
| Performance | monthly | continuous + weekly | continuous + weekly |
| Costs | monthly | monthly + anomaly alert | monthly + anomaly alert |
| Quality | monthly | weekly + per release | weekly + per release |
| Documentation | per release | per release + weekly | per release + weekly |
| Backups | weekly check + quarterly drill | daily check + monthly drill | daily check + monthly drill + regular DR |
| Value (KPIs) | monthly | monthly + per target near its deadline | monthly + per target near its deadline |
| Feature evolution | per event | per event | per event |

On the enterprise platform, the periodic global review is added (`workflows/W12-global-review.md`).

## Duties shared by all

1. **The analyze→plan→apply→validate→document cycle**, with real proof before closing (never
   "looks fine" — `core/quality-gates.md`, `knowledge/permanent-rules.md` §7).
2. **Reversibility:** every change a guardian applies has a reversal path; risk behind a flag when
   applicable (`modules/feature-flags.md`).
3. **Honesty:** report the real state with numbers — never a cosmetic "all good"
   (`knowledge/permanent-rules.md` §2).
4. **Only the user accepts residual risk** and decides scope/money/data/production — the guardian
   recommends, it does not decide (`MANIFESTO.md` §8).
5. **Open the right loop** when the finding persists: L03 (security), L04 (code smells), L05/L06
   (docs), L07 (CVEs), L08 (technical debt) — see `loops/README.md`.
6. **Write everything** in `product/99-records/guardians/` and the non-obvious lessons in
   `STATE.md` (`core/project-memory.md`).

## Cycle report format

All use the same mold — `templates/technical/guardian-report.md.template` — written to
`product/99-records/guardians/<dimension>-YYYY-MM-DD.md`, with: the cycle window, findings by
terminal state (resolved / mitigated / not-applicable, each justified), actions applied and how
they were validated, what was escalated to the user, and the trend against the previous cycle. A
report without numbers and without terminal states does not close the cycle.

## How the Orchestrator convenes them

In F9, `workflows/W09-continuous-operation.md` schedules each guardian on its cadence and collects
the reports. Outside the cadence, an event triggers the right guardian (a CVE → Security; a cost
anomaly → Costs; a new request → the Evolution Agent, which fires
`workflows/W10-feature-evolution.md`). When a finding outgrows one guardian's dimension (a CVE
being exploited, a degradation turning into unavailability), it escalates to
`workflows/W11-incident-response.md`.

## Related

- `core/lifecycle.md` (F9) · `workflows/W09-continuous-operation.md` · `workflows/W10-feature-evolution.md`
- `agents/12-reviewers/README.md` — the one-off eyes of F7, upstream of the guardians.
- `templates/technical/guardian-report.md.template` · `loops/README.md`
- `agents/README.md` — the global index and the agent types.
