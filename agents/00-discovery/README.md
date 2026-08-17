# 00 — Discovery

The product's first agent category. It works entirely in **F1** (`core/lifecycle.md`), driven by
`workflows/W01-discovery.md`. Its purpose: turn a raw idea into an **approved discovery dossier** —
the problem made sharp, who lives it, what we want to achieve and how we will know we did —
**without deciding anything about the solution** (technology, screens, architecture wait for F3+).
It is the phase where "never assume — ask" (`MANIFESTO.md` §2) weighs most: every assumption left
unvalidated here becomes an expensive defect down the road.

## Agents in this category

| Agent | One line |
| --- | --- |
| `agents/00-discovery/idea-analyst.md` | Structures the raw idea into a testable description (is/is-not, assumptions, anchor questions). |
| `agents/00-discovery/problem-definer.md` | Isolates the real problem, the affected audience and the cost of not solving it. |
| `agents/00-discovery/stakeholder-mapper.md` | Identifies stakeholders, roles, power/interest and contact channels. |
| `agents/00-discovery/persona-builder.md` | User personas with goals, pains and context of use. |
| `agents/00-discovery/use-case-modeler.md` | Use cases (UC-nnn) and end-to-end journeys per actor. |
| `agents/00-discovery/business-goals-analyst.md` | Measurable business goals and the constraints that bound them. |
| `agents/00-discovery/kpi-definer.md` | KPIs per goal, with baseline and target — how success is proven. |
| `agents/00-discovery/roadmap-planner.md` | Roadmap by horizons, including what is left for the future. |
| `agents/00-discovery/mvp-scoper.md` | Cuts the minimal demonstrable MVP and what is explicitly left out. |
| `agents/00-discovery/risk-analyst.md` | Business/technical/legal risks, with mitigation and owner. |
| `agents/00-discovery/cost-estimator.md` | Order of magnitude of costs (build, infra, AI, operation). |
| `agents/00-discovery/prioritizer.md` | Prioritizes features (value × effort × risk); ties go to the user. |

## Recommended working order

Discovery is a chain with real dependencies between artifacts:

1. **Idea** (`idea-analyst`) — the structured starting point every other agent consumes.
2. **Problem** (`problem-definer`) — deepens the problem the idea sketches.
3. **Stakeholders** (`stakeholder-mapper`) — who holds interest/power in the problem.
4. **Personas** (`persona-builder`) — user archetypes among those stakeholders.
5. **Use cases** (`use-case-modeler`) — what each persona wants to achieve.
6. **Business goals** (`business-goals-analyst`) — the outcome the organization wants.
7. **KPIs** (`kpi-definer`) — how each goal is measured (baseline → target).
8. **Roadmap · MVP · Risks · Costs · Priority** — close the scope and the viability.

Steps 3–4 and 6–7 can run in parallel within the same batch of questions to the user; step 5 needs
the personas (step 4); the MVP (`mvp-scoper`) needs prioritized use cases. The Orchestrator builds
the graph from the **Inputs**/**Interactions** sections of each agent spec
(`core/extensibility.md`), not from this fixed order.

## How the Orchestrator convenes it

`workflows/W01-discovery.md` (F1) kicks off this category right after F0 has recorded the raw idea
in `STATE.md`. The Orchestrator (`core/orchestrator.md`) invokes the agents by artifact dependency,
groups the questions of several agents into a **single batch** to the user
(`core/question-engine.md`) and does not let the phase advance until the **F1 gate**
(`core/quality-gates.md`) passes: sharp problem, stakeholders and personas confirmed, goals with
KPIs, MVP scoped and the user approving the dossier. Decisions about scope, money and personal
data always belong to the human (`MANIFESTO.md` §7). No agent in this category picks technology —
that only starts in F3 (`agents/02-architecture/README.md`).

## Related

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `workflows/W01-discovery.md` · `core/lifecycle.md` · `core/quality-gates.md`
- `agents/01-requirements/README.md` — the next phase, turning this into unambiguous requirements.
