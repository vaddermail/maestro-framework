# AI Model Routing

How to choose **which model and which effort** to use for each development task. The principle:
**the model is chosen per task, never fixed** — maximum quality where reasoning is distinctive,
minimum cost where the work is mechanical. This mechanism was learned at the cost of exhausted
budgets in the origin project (`knowledge/origin-lessons.md`): what burns through credits is not
using a strong model on the hard problem — it is **replicating the expensive model across every
subagent, including the mechanical ones**.

> The layer names below are abstract on purpose: concrete models change every quarter; the layers
> do not. The project maps layers→models in its `CLAUDE.md` (from
> `templates/project/CLAUDE.md.template`) and **revisits the mapping deliberately** when prices or
> capabilities change — cost rules are versioned with the why, like any decision.

## The four layers

| Layer | For what | Task examples |
| --- | --- | --- |
| **Top** | Hard, distinctive reasoning, where getting it right first time saves expensive rework | Multi-profile RBAC design, state machines, critical flows with reversibility, expand-contract migrations, architecture arbitration, **adversarial verification** |
| **Standard** | The day-to-day default: implementation and code review with business rules | Vertical slices, domain logic, PR reviews, report consolidation |
| **Economy** | Standardized work with a clear spec | Replicating screens, writing tests from a plan, mirroring mocks, straightforward CRUD, updating docs/help |
| **Mechanical** | Trivial and repetitive | Mass find/replace, moving files, lint fixes, regenerating snapshots |

## The second axis: effort (effort/thinking)

Orthogonal to the model. Proven rule: **a strong model at low effort beats a weak model at maximum
effort** on reasoning tasks. Start at medium/high and raise only if needed — never maximum effort
by reflex. A task's cost is `model × effort × context volume`; all three get managed, not just the
first.

## Routing rules

1. **Default = Standard layer.** Any task without a clear classification goes to Standard —
   including, when in doubt, any subagent.
2. **Going down is deliberate:** only when the task is **clearly mechanical/standardized**
   (complete spec, zero ambiguity, failure cheap to detect).
3. **Going up is deliberate:** only for hard, distinctive reasoning or **adversarial
   verification/judgment** — and by tuning the effort rather than jumping to maximum.
4. **The orchestrating session stays strong** (Standard, or Top on the hard problem):
   coordinating, deciding and verifying is where mistakes cost the most.
5. **Fan-out is where the budget dies.** Before launching N subagents, classify their task —
   N × top × high effort is the proven recipe for burning through credits in a day.
6. **Give the full spec upfront.** A complete prompt cuts round-trip turns — the cheapest cost
   optimization there is.
7. **Exceptions with a recorded reason.** Departing from this table is legitimate with a concrete
   written justification (in `STATE.md` or in the task's plan).

## Cost observability (development's "credit system")

- **Account per unit of work:** each block/slice records in `STATE.md` its approximate consumption
  (tokens/cost) and what it produced — cost ties to value, not to an opaque total.
- **Review the trend:** `agents/13-guardians/cost-guardian.md` includes development AI cost in its
  analysis (not just the product's infrastructure).
- **Kill-switch:** the same primitive that cuts risk cuts cost — being able to turn off a
  model/layer (e.g. "no Top-layer credits → everything that was Top becomes Standard + doubled
  verification") without stopping the project. Interim rules like these come **with a written
  deadline and reversal condition**.
- **Skepticism toward optimizations:** do not trust savings (prompt caching, batching, reused
  context) without verifying the real prerequisites — presumed optimization is hidden cost.
- **Context is recurring cost:** tools/documents loaded in every session are paid for in every
  session. Adopt tools when they add value **now**, remove them when they stop doing so
  (evolutionary adoption — `adapters/claude-code.md`).

## For the product (do not confuse the two)

This document governs the cost of **building** the product. If the product itself consumes paid
AI/APIs, that is governed by the `modules/credit-management.md` (ledger, quotas, per-user and
per-organization rates) and `modules/ai-observability.md` (accounting, alerts, per-model
kill-switch) modules — the same principles, decoupled and inside the product.

## Related

- `core/orchestrator.md` — who applies the routing when delegating.
- `modules/credit-management.md` · `modules/ai-observability.md` — the product-side equivalents.
- `knowledge/origin-lessons.md` — the story that originated these rules.
- `adapters/claude-code.md` — concrete mapping of layers onto real tools.
