# W03 — Architecture (F3)

> **Phase:** F3 · **Exit gate:** P3 · **Core agents:** `agents/02-architecture/` (arbiter +
> style specialists convened per context + stack selector), with
> `agents/08-infrastructure/hosting-arbiter.md` when applicable, conducted by
> `core/orchestrator.md`.

## Objective

Decide **how it gets built** — architectural style, concrete stack at stable versions, boundaries
and integrations — before writing a single line of product code. Structural decisions are **not
made by fashion or by the opinion of the most talkative agent**: they are generated in a blind
panel, decided by an arbiter, recorded in an **ADR** and closed (`core/decision-engine.md`).
Reverting a style choice costs months — which is why this is among the framework's most formal
decisions.

## Preconditions (entry gate)

- [ ] P2 closed: `product/01-requirements/` `approved` — requirements, `BR-nnn` and **quantified
      NFRs** exist (they are the weighted criteria that decide the architecture).
- [ ] F1 risks and costs available (`product/00-discovery/risks.md`, `costs.md`) — they feed the
      criteria weights and the user's cost validation.

Without quantified NFRs **no architecture is decided**: expected scale, availability and volumes
are what separates a monolith from microservices. If they are missing, go back to F2
(`core/lifecycle.md` §2).

## Steps (agent → artifact)

The process is that of `core/decision-engine.md` §The process for structural decisions. Artifacts
in `product/02-architecture/`.

| # | Step | Who | Artifact |
| --- | --- | --- | --- |
| 1 | **Frame** the decision and the weighted criteria (scale, number of teams, operation, reversibility, cost, deadline, lock-in) | Orchestrator | decision question + criteria (draft of `architecture-vision.md`) |
| 2 | **Propose in a panel, blind** — 2–4 *relevant* style specialists | `agents/02-architecture/` (style) | one independent proposal per specialist |
| 3 | **Arbitrate** — compare against the criteria, merge ideas, write the decision | `agents/02-architecture/architecture-arbiter.md` | `decisions/ADR-nnn-title.md` + `architecture-vision.md` |
| 4 | **Validate** in plain language and **pin the stack** (only after the style) | user → `agents/02-architecture/stack-selector.md` | ADR `approved` + `stack.md` (pinned versions) |
| 5 | **Decide hosting** (cloud/on-prem/hybrid), when applicable | `agents/08-infrastructure/hosting-arbiter.md` | hosting `ADR-nnn` |
| 6 | **Pin external contracts** (read-only systems, identity) | Orchestrator + specialists | `integrations.md` (`modules/readonly-external-integrations.md`) — per dependency: external owner, status (available / pending with date), fields managed elsewhere, stub plan |

**Selective convening (`agents/02-architecture/README.md`):** the Orchestrator convenes **only the
style specialists relevant** to the problem (`monolith-specialist`,
`modular-monolith-specialist`, `microservices-specialist`, `event-driven-specialist`,
`cqrs-specialist`, `clean-architecture-specialist`, `hexagonal-specialist`, `ddd-specialist`,
`vertical-slice-specialist`, `serverless-specialist`, `edge-computing-specialist`) — **never all
of them by reflex**. A proposal saying "my style does not fit here" is valid and saves the arbiter
from discarding a bad option. The arbiter is **never one of the proposers** (separate who proposes
from who decides).

**Parallelism:** the panel's proposals (step 2) run in parallel and **blind** — without seeing one
another (`core/orchestrator.md` §Parallelism). The stack (4) is **never** chosen before the style:
technology serves the architecture, not the other way around.

## Decision points

This is the **decision engine's** workflow — almost everything here is a recorded decision:

- **Architectural style (mandatory ADR):** arbiter's proposal → **user validation** in plain
  language (what was chosen, what was rejected and why, what it costs, how to revert it).
- **Stack (stable versions):** LTS / GA majors by default; `alpha`/`beta`/`RC` only with a
  recorded reason (`knowledge/permanent-rules.md` §Stable versions). Lockfiles pinned.
- **Hosting:** cost, data residency, team competence and compliance — if it involves
  **money/commitment** (paid infra), human approval is mandatory.

**Mandatory human approval (P3):** the **ADRs and the costs**. The Orchestrator stops and asks
before assuming any paid commitment (`core/orchestrator.md` §Human approval). Each approved ADR
becomes **closed** — it is not reopened without material news (`core/decision-engine.md` §Closed
decisions); the list of closed decisions goes into the project's `CLAUDE.md`.

## Loops it opens

- F3 does not run one of the numbered `loops/`; its iteration is the **arbitration cycle**: if no
  proposal satisfies the criteria, the Orchestrator reworks the weights (or requests an extra
  proposal) and returns to step 2. **Safeguard:** 3 rounds without convergence → go up to the user
  with the trade-off to be decided, instead of arbitrating in a vacuum
  (`core/orchestrator.md` §Recovery).

## Exit gate (P3)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] ADRs written with the **options considered** (incl. the status quo), decision, consequences
      and **reversal path** (`core/decision-engine.md` §ADR — what it must contain).
- [ ] Stack **pinned** at stable versions, with lockfiles (`stack.md`).
- [ ] External integrations with an assumed contract (read-only, sync, fields managed elsewhere).
- [ ] User **validated costs and trade-offs** in plain language.

**Who verifies:** the Orchestrator (ADR completeness) —
`agents/12-reviewers/architecture-reviewer.md` only audits *adherence* in F7. **Who approves:**
the user (ADRs + costs). With P3 closed, `workflows/W04-experience.md` starts.

## Recovery from failures and blockages

`core/orchestrator.md` §Recovery. Contradictory proposals between specialists → **no picking in
silence**: confront them against the weighted criteria, or go up to the user if it is a product
decision. User unavailable to validate costs → the ADR stays in `draft`, the pending item in
`STATE.md` §Pending decisions, and **no stack is pinned and no infra is contracted** by
assumption. A closed decision the user wants to reopen → remind them of the original why before
executing; if it is reopened, the old ADR is marked `superseded by ADR-nnn` (never deleted).

## Effort profiles

| Profile | F3 depth |
| --- | --- |
| **Prototype** | Short ADR (1 page) for the obvious style; minimal stable stack; hosting deferred; the panel of 2 may be the Orchestrator itself sketching the options. |
| **Internal product** | Real panel of 2–3 styles; ADRs for the structural decisions; hosting decided. |
| **Commercial product** | + hosting ADR with validated costs; stack with an update policy. |
| **Enterprise platform** | **ADR for every structural decision**; full panel; compliance and data residency explicit in the hosting. |

## Related

- `core/decision-engine.md` — the panel→arbiter→ADR process this phase embodies.
- `agents/02-architecture/README.md` — the category and the selective convening of specialists.
- `agents/08-infrastructure/hosting-arbiter.md` — the hosting arbitration.
- `templates/project/ADR-DECISION.md.template` — the format of the decision record.
- `workflows/W02-requirements.md` — the previous phase (supplies requirements and NFRs).
- `workflows/W05-specification.md` — consumes the ADRs and the stack for the specification.
