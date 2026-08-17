# Architecture (F3)

The category that decides **how it gets built** — the architectural style and the concrete stack —
before writing a single line of product code. It works in phase **F3** of the lifecycle
(`core/lifecycle.md`), between the closed requirements (F2) and the experience design (F4), and its
product (architecture vision + ADRs + pinned stack) is the base of all specification (F5) and
build (F6).

The central principle of this category: **structural decisions are not made by fashion nor by the
opinion of the most talkative agent — they are generated in a panel, decided by an arbiter,
recorded in an ADR and closed** (`core/decision-engine.md`). Reverting an architectural style
choice costs months; that is why it is among the most formal decisions in the framework.

## Agents in this category

| Agent | Type | What it does |
| --- | --- | --- |
| `agents/02-architecture/architecture-arbiter.md` | Arbiter | Compares the panel's proposals against weighted criteria and decides with a justified ADR |
| `agents/02-architecture/stack-selector.md` | Specialist | Picks the concrete technologies after the style is decided (stable/LTS versions, lockfiles) |
| `agents/02-architecture/monolith-specialist.md` | Specialist | Proposes and justifies a classic monolith (a single deployable) |
| `agents/02-architecture/modular-monolith-specialist.md` | Specialist | Proposes a monolith with explicit internal boundaries and a migration path |
| `agents/02-architecture/microservices-specialist.md` | Specialist | Proposes independent services; honestly exposes the operational cost |
| `agents/02-architecture/event-driven-specialist.md` | Specialist | Proposes event-based communication; brokers, delivery guarantees, idempotency |
| `agents/02-architecture/cqrs-specialist.md` | Specialist | CQRS (with/without event sourcing): when the complexity pays off |
| `agents/02-architecture/clean-architecture-specialist.md` | Specialist | Clean Architecture: layers, dependency rule, costs |
| `agents/02-architecture/hexagonal-specialist.md` | Specialist | Ports & Adapters: domain isolation and testability |
| `agents/02-architecture/ddd-specialist.md` | Specialist | Strategic and tactical DDD: bounded contexts, aggregates |
| `agents/02-architecture/vertical-slice-specialist.md` | Specialist | Vertical slices: organization by feature |
| `agents/02-architecture/serverless-specialist.md` | Specialist | Serverless/FaaS: costs, cold starts, lock-in |
| `agents/02-architecture/edge-computing-specialist.md` | Specialist | Edge: latency, data at the edge, runtime constraints |

> The Orchestrator convenes **only the specialists relevant** to the problem — never all of them by
> reflex.

## How the arbiter uses the specialists (panel + ADR)

The process is the one in `core/decision-engine.md`, section "decisões estruturais", applied to
this category:

1. **Frame.** The Orchestrator formulates the decision question ("which architectural style for
   this product?") and the **weighted criteria**, derived from the F2 requirements and NFRs
   (expected scale, number of teams, operational maturity, reversibility, cost, deadline).
2. **Propose in a panel, blind.** It convenes 2–4 relevant style specialists. Each produces an
   **independent** proposal, without seeing the others', with a design, honest pros/cons against
   the criteria, cost, risks and a reversal path. **A proposal saying "my style does not fit
   here" is valid and valuable** — it saves the arbiter discarding a bad option and shows the
   specialist thought it through.
3. **Arbitrate.** The `architecture-arbiter` — who is **never one of the proponents** — compares
   against the weighted criteria, may merge ideas, and writes the reasoned ADR, including the
   rejected options and the "do nothing" (the status quo).
4. **Validate and pin the stack.** The user validates in plain language; only then does the ADR
   become `approved`. With the style closed, the `stack-selector` picks the concrete
   technologies.

This design deliberately separates **who proposes** from **who decides**: a rubber-stamp panel
(where the specialists validate a choice already made) is an anti-pattern the decision engine
forbids.

## Recommended order of work

Style first, stack second. `style specialists (in parallel) → architecture-arbiter (ADR) → user
validation → stack-selector`. The stack is **never** chosen before the style: technology
serves the architecture, not the other way around.

## Phase exit gate

`core/quality-gates.md` (F3): ADRs written with the alternatives considered and a reversal path;
stack pinned with versions and lockfiles; user validated costs and trade-offs. Only with the gate
closed does work move on to F4/F5.

## Related

- `core/decision-engine.md` — the panel→arbiter→ADR process this category embodies.
- `workflows/W03-architecture.md` — the workflow that runs the phase.
- `templates/project/ADR-DECISION.md.template` — the decision record format.
- `agents/08-infrastructure/hosting-arbiter.md` — the same arbitration pattern for infrastructure.
- `agents/12-reviewers/architecture-reviewer.md` — who, in F7, checks adherence to what was decided.
