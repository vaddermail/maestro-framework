# Agents

The framework's team of specialists. Each agent has **one responsibility**, a self-contained
agent spec (`agents/_template/AGENT-TEMPLATE.md`) and a place in the lifecycle. Agents do not
know each other — they collaborate through **artifacts** (`core/artifact-protocol.md`),
coordinated by `core/orchestrator.md`.

## How to read an agent spec

Every agent spec follows the template: Identification · Objective · When it starts · When it ends
· Inputs · Outputs · Questions to the user · Rules · Limitations · Workflow · Examples · Best
practices · Anti-patterns · Interactions · Done criteria. If a section says "Not applicable", it
says **why**.

## Agent types

| Type | Role | Examples |
| --- | --- | --- |
| **Specialist** | Produces an artifact in its area | `idea-analyst`, `data-modeler`, `rest-specialist` |
| **Arbiter** | Decides between independent proposals, with an ADR | `architecture-arbiter`, `hosting-arbiter` |
| **Reviewer** | Examines others' work along one dimension, with a report | `12-reviewers/`, except the consolidator (coordinator) |
| **Guardian** | Watches one dimension in production, on a cadence | `13-guardians/` (and the `framework-curator`, which watches the upstream framework), except the evolution agent (coordinator) |
| **Coordinator** | Follows one dimension across several phases | `security-coordinator`, `review-consolidator`, `feature-evolution-agent` |

## The 15 categories (by dominant lifecycle phase)

| # | Category | Phase | What it produces |
| --- | --- | --- | --- |
| 00 | `00-discovery/` | F1 | Understand the problem: idea, personas, use cases, KPIs, MVP, risks, costs |
| 01 | `01-requirements/` | F2 | The what without ambiguity: requirements, rules, acceptance criteria, glossary |
| 02 | `02-architecture/` | F3 | How to build: architectural style (panel + arbiter), stack, integrations |
| 03 | `03-experience/` | F4 | UX/UI before code: flows, wireframes, design system, accessibility |
| 04 | `04-frontend/` | F6 | Client engineering: screens, API integration, state, UI tests |
| 05 | `05-backend/` | F5–F6 | Server engineering: APIs, authn/z, queues, events, observability |
| 06 | `06-data/` | F5–F6 | The persisted truth: model, migrations, indexes, backups, DR |
| 07 | `07-devops/` | F8 | From commit to production: containers, IaC, CI/CD, deploy, flags, secrets |
| 08 | `08-infrastructure/` | F8 | Where it runs: cloud/on-prem (arbiter), network, TLS, storage, high availability |
| 09 | `09-security/` | F1–F9 | Defense in depth: threat modeling, OWASP/ASVS, hardening, scans, pentest |
| 10 | `10-quality/` | F6–F7 | Prove it works: test strategy and execution, risk-based coverage |
| 11 | `11-documentation/` | F1–F9 | Living knowledge: technical docs, user help, API reference |
| 12 | `12-reviewers/` | F7 | Independent eyes: review panel per dimension + consolidation |
| 13 | `13-guardians/` | F9 | The permanent production team: security, deps, performance, costs, docs, backups, evolution |
| 14 | `14-meta/` | — | Outside the project cycle: the framework learning from those who use it — curation of improvement reports, in the upstream repository |

> The "dominant phase" marks where the category works most — not where it works only. Security and
> documentation cross the whole cycle; the reviewers return at every milestone. Category 14 is the
> structural exception: it does not act on projects, it acts on the framework itself
> (`agents/14-meta/README.md`) — a project's Orchestrator never summons it.

## How agents fit into the cycle

Each category is summoned by the workflow of its phase (`workflows/`). The Orchestrator builds the
dependency graph from the **Inputs**/**Interactions** sections of the agent specs — registering an
agent in the indexes is what makes it discoverable (`core/extensibility.md`).

## Adding an agent

`playbooks/add-an-agent.md`: copy the template → fill in everything → register in the category
README and in `_meta/INVENTORY.md`. Without touching the existing agents.

## Related

- `agents/_template/AGENT-TEMPLATE.md` — the mold for every agent spec.
- `core/orchestrator.md` — who directs the team.
- `core/lifecycle.md` — when each category comes in.
- `_meta/INVENTORY.md` — the complete, canonical list.
