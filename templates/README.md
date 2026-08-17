# Templates — Documents Ready to Instantiate

Standard documents in `.md.template` that any agent (or person) fills in to produce a real
project artifact (`core/artifact-protocol.md`). They are not edited here — they are copied
into the project and filled in there.

## How to instantiate a template

1. **Copy** the `.template` to the right destination (see table below), **dropping the
   `.template` suffix** — e.g. `templates/project/STATE.md.template` → `STATE.md` at the
   project root.
2. **Fill in the placeholders** `{{like-this}}` — see the convention below. No `{{...}}` may
   remain in the final file.
3. **Remove the guidance**: the initial "**How to use**" block and the italic comments inside
   the sections exist only to guide the filling-in — they leave the instantiated document.
4. **Commit** the instantiated file in the project (never inside `Maestro/`, which stays
   read-only as a process reference).

## Placeholder convention

All text between double braces is to be replaced: `{{product-name}}`, `{{yyyy-mm-dd}}`,
`{{adr-number}}`. The name inside the braces describes what goes there, in kebab-case — it is
not code, it is a filling-in instruction. An instantiated file must never contain an unfilled
`{{ }}`; where information is missing, follow `core/question-engine.md` (ask the user, do not
make it up — `MANIFESTO.md` §2).

## Template index

### `templates/project/` — memory and governance (project root)

| Template | Instantiated destination | What it is |
| --- | --- | --- |
| `CLAUDE.md.template` | `CLAUDE.md` | Project instructions for AI agents (stable rules of the new product). |
| `STATE.md.template` | `STATE.md` | Shared living memory: done, in progress, up next, pending decisions, lessons log. |
| `ADR-DECISION.md.template` | `product/02-architecture/decisions/ADR-nnn-title.md` | Architecture decision record (context, options, decision, consequences, rollback). |
| `CHANGELOG.md.template` | `CHANGELOG.md` | History of what changed and why, per version. |
| `FRAMEWORK-IMPROVEMENTS.md.template` | `FRAMEWORK-IMPROVEMENTS.md` | Accumulated record, since day 0, of what the project teaches the framework; sent upstream at phase closes (`playbooks/report-framework-improvements.md`). |
| `GENESIS.md.template` | `product/99-records/genesis.md` | Genesis dossier: the numbers behind the promise (cost, days, findings, rework), phase by phase; the Close feeds `knowledge/learning-curve.md`. |

### `templates/discovery/` — F1, `product/00-discovery/`

| Template | What it is |
| --- | --- |
| `idea.md.template` | Structured description of the idea. |
| `problem.md.template` | Definition of the problem and the cost of not solving it. |
| `stakeholders.md.template` | Stakeholder map. |
| `persona.md.template` | Individual persona. |
| `use-case.md.template` | Use case/journey. |
| `goals-and-kpis.md.template` | Business goals and KPIs. |
| `risks.md.template` | Risk register with owner and mitigation. |
| `roadmap.md.template` | Roadmap by horizons. |
| `mvp.md.template` | MVP scope and explicit cuts. |

### `templates/specification/` — F2/F5, `product/01-requirements/` and `product/04-specification/`

| Template | What it is |
| --- | --- |
| `functional-requirement.md.template` | Requirement with acceptance criteria. |
| `business-rules.md.template` | Rules and invariants of a module. |
| `state-machine.md.template` | State machine of a critical flow. |
| `logical-data-model.md.template` | Entities, relations and invariants, database-agnostic. |
| `backend-contract.md.template` | Server responsibilities: authz, scoping, integrity, sensitive fields. |

### `templates/technical/` — security, testing, operations and review (multiple phases)

| Template | What it is |
| --- | --- |
| `threat-model.md.template` | Threat model of a feature/system. |
| `test-plan.md.template` | Risk-driven test plan. |
| `runbook.md.template` | Operational runbook for a procedure. |
| `migration-plan.md.template` | Expand-contract migration with a rollback plan. |
| `post-mortem.md.template` | Blameless post-mortem, with actions and owners. |
| `review-report.md.template` | Report from one reviewer (format shared across the panel). |
| `guardian-report.md.template` | Periodic report from a guardian. |

> All templates in the index above are written and ready to instantiate; the index reflects the
> full `_meta/INVENTORY.md`.

## Related

- `_meta/INVENTORY.md` — the official list of all framework files.
- `core/artifact-protocol.md` — the `product/` tree where each instantiated file lives.
- `core/project-memory.md` — `CLAUDE.md`/`STATE.md` in detail.
- `core/decision-engine.md` — the ADR in detail.
- `workflows/W00-project-kickoff.md` — when the `project/` templates are instantiated.
