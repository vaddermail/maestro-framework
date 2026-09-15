# W01 — Discovery (F1)

> **Phase:** F1 · **Exit gate:** P1 · **Core agents:** `agents/00-discovery/` (13
> specialists, one of them conditional), conducted by `core/orchestrator.md`.

## Objective

Turn the raw idea (recorded in F0) into an **approved discovery dossier**: the problem made sharp,
who lives with it, what is to be achieved, how success is measured, what it costs, what it risks
and what goes into the MVP. **Without deciding anything about the solution** — technology, screens
and architecture wait for F3+. It is the phase where "never assume — ask" (`MANIFESTO.md` §2)
weighs the most: every assumption not validated here becomes an expensive defect later
(`knowledge/ai-pitfalls.md` §AR-3).

## Preconditions (entry gate)

- [ ] P0 closed: memory instantiated, effort profile pinned, raw idea in `STATE.md`.
- [ ] User available to answer question batches (discovery is Q&A-intensive).

## Steps (agent → artifact)

Discovery is a chain with real dependencies (`agents/00-discovery/README.md` §Recommended working
order). All artifacts live in `product/00-discovery/`.

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | `agents/00-discovery/idea-analyst.md` | `idea.md` (is/is-not, assumptions, anchor questions) | raw idea (F0) |
| 2 | `agents/00-discovery/problem-definer.md` | `problem.md` (real problem, audience, cost of not solving) | 1 |
| 3 | `agents/00-discovery/stakeholder-mapper.md` | `stakeholders.md` (roles, power/interest, channels) | 2 |
| 4 | `agents/00-discovery/persona-builder.md` | `personas/` (one per persona) | 3 |
| 5 | `agents/00-discovery/use-case-modeler.md` | `use-cases/` (`UC-nnn`, end-to-end journeys) | 4, 13 (if applicable) |
| 6 | `agents/00-discovery/business-goals-analyst.md` | `goals-and-kpis.md` (goals + constraints) | 2 |
| 7 | `agents/00-discovery/kpi-definer.md` | `goals-and-kpis.md` (KPIs per goal, baseline→target) | 6 |
| 8 | `agents/00-discovery/roadmap-planner.md` | `roadmap.md` (horizons, incl. future) | 7, 11, 12 |
| 9 | `agents/00-discovery/risk-analyst.md` | `risks.md` (`R-nnn`, mitigation and owner) | 2,5 |
| 10 | `agents/00-discovery/cost-estimator.md` | `costs.md` (build, infra, AI, operation — order of magnitude) | 7, 11 (8 if it exists) |
| 11 | `agents/00-discovery/mvp-scoper.md` | `mvp.md` (minimum demonstrable + explicit cuts) | 5, 7, 12 |
| 12 | `agents/00-discovery/prioritizer.md` | `prioritization.md` (value × effort × risk) | 5, 9 |
| 13 | `agents/00-discovery/existing-system-analyst.md` | `existing-system.md` (functional inventory in use, data to migrate with volume/quality/owner, integrations to preserve, cutover constraints) — **conditional: only when the product replaces or extends a system in use** | 1, 3 |

**Parallelism (`core/orchestrator.md` §Parallelism):** steps 3–4 (stakeholders/personas) and 6–7
(goals/KPIs) can run in the same question batch; risks (9) runs in parallel with goals.
The tail of the phase is sequential: prioritization (12) → MVP (11) → roadmap (8) → costs (10). The
Orchestrator builds the graph from the **Inputs**/**Interactions** sections of the specs, not from
blind numbering.
The step numbering stays stable (it is cited from outside); the real execution order is that of the
«Depends on» column. Step 13 is conditional — it only exists when there is a system in use to
replace or extend: it runs in parallel with 3–5 and feeds the risks (9) and the F2 requirements
(`playbooks/legacy-system-migration.md`).

> **Scales with the profile:** in a prototype, all these artifacts collapse into a single
> `product/00-discovery/dossier.md` — the **section titles and IDs** (`UC-nnn`, `R-nnn`)
> are kept (`core/artifact-protocol.md`).

## Decision points

Every gap goes up to the Orchestrator, which groups them into **batches by theme** (never
piecemeal — `core/question-engine.md`). Typical F1 batches:

- **Problem and audience** — who feels the pain, how often, what not solving it costs today.
- **Scope and priority** — what is essential vs nice-to-have; the MVP.
- **Goals and success** — what the organization wants to achieve and how it will know it did
  (baseline).
- **Constraints and risks** — budget, deadlines, compliance, external dependencies.

**Mandatory human approval (P1):** the **scope and the priorities** belong to the user — the
product is theirs (`core/orchestrator.md` §Human approval). Any involvement of **personal data**
is flagged here already, even if its processing is decided in later phases.

## Loops it opens

- **Question engine running continuously** (`core/question-engine.md`): each gap becomes a `P-nnn`
  in `product/01-requirements/questions-and-answers.md`; provisional answers (assumed by default)
  stay marked for confirmation before P1. It is not yet the formal
  `loops/L01-ambiguous-requirements.md` (that one belongs to F2) — but the batch mechanics are the
  same.

## Exit gate (P1)

`core/quality-gates.md`:

- [ ] Discovery dossier complete: sharp problem, stakeholders and personas confirmed, use cases,
      goals with KPIs (baseline→target), roadmap, MVP delimited, risks with an owner.
- [ ] MVP and priorities **approved by the user**.
- [ ] No critical gap open (critical provisional answers confirmed).
- [ ] Zero solution decisions made (no technology/screen choices — that is F3/F4).
- [ ] When the product replaces or extends a system in use: `product/00-discovery/existing-system.md`
      approved, with the data to migrate inventoried and the cutover reversible.

**Who approves:** the user (scope, MVP, priorities). **Who verifies:** the Orchestrator
(completeness of the dossier). With P1 closed, `workflows/W02-requirements.md` starts.

## Effort profiles

| Profile | F1 depth |
| --- | --- |
| **Prototype** | Single short dossier; minimal personas and use cases; costs at a rough order of magnitude. Just enough to validate the idea. |
| **Internal product** | Full dossier; real personas of the known users; risks with a named owner. |
| **Commercial product** | + informal market/competition analysis in the constraints; KPIs with a measured baseline, not an estimated one. |
| **Enterprise platform** | + multi-team stakeholders and explicit compliance in the constraints; roadmap in formal horizons that feeds the architecture (F3). |

## Related

- `agents/00-discovery/README.md` — the category, the order and the dependency graph.
- `workflows/W00-project-kickoff.md` — the previous phase (supplies the raw idea).
- `workflows/W02-requirements.md` — the next phase (consumes the dossier).
- `core/question-engine.md` — how this phase's batches are asked.
- `core/artifact-protocol.md` — the `product/00-discovery/` tree and the IDs.
- `templates/discovery/idea.md.template` — the mold for the first artifact.
