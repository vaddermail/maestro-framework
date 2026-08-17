# Workflows — the processes that connect agents

A workflow is the **execution recipe of a phase** of the lifecycle (`core/lifecycle.md`):
it says which agents work, in what order, which artifacts they produce, which questions go to the
user, which loops open and which gate closes the phase. If `core/orchestrator.md` is the
conductor and the agent specs are the musicians, the workflows are the **score**.

The Orchestrator does not improvise: at every moment it knows which phase the project is in
(by reading `STATE.md`, never from memory) and runs the matching workflow until its gate passes. A
workflow never replaces the gates (`core/quality-gates.md`) or the question engine
(`core/question-engine.md`) — it only sequences them.

## Naming convention

| Prefix | Meaning | Example |
| --- | --- | --- |
| `Wnn` | Phase workflow, numbered by lifecycle order | `W00`–`W09` |
| `W10`–`W12` | Cross-cutting workflows, triggered on condition (not by phase order) | evolution, incident, global review |

Workflow ↔ phase ↔ gate correspondence (the mandatory reading map):

| Workflow | Phase | Exit gate | Core agents |
| --- | --- | --- | --- |
| `workflows/W00-project-kickoff.md` | F0 Kickoff | P0 | Orchestrator |
| `workflows/W01-discovery.md` | F1 Discovery | P1 | `agents/00-discovery/` |
| `workflows/W02-requirements.md` | F2 Requirements | P2 | `agents/01-requirements/` + `loops/L01-ambiguous-requirements.md` |
| `workflows/W03-architecture.md` | F3 Architecture | P3 | `agents/02-architecture/` |
| `workflows/W04-experience.md` | F4 Experience | P4 | `agents/03-experience/` |
| `workflows/W05-specification.md` | F5 Specification | P5 (unlocks code) | modelers + API designer + threat modeler |
| `workflows/W06-build.md` | F6 Build | P6/P6b | `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`, `agents/10-quality/` |
| `workflows/W07-quality-and-security.md` | F7 Quality & Security | P7 | `agents/12-reviewers/`, `agents/09-security/` |
| `workflows/W08-launch.md` | F8 Launch | P8 | `agents/07-devops/`, `agents/08-infrastructure/` |
| `workflows/W09-continuous-operation.md` | F9 Operation | cadences (P9) | `agents/13-guardians/` |
| `workflows/W10-feature-evolution.md` | re-enters F2→F8 | gates of the phases touched | `agents/13-guardians/feature-evolution-agent.md` |
| `workflows/W11-incident-response.md` | cross-cutting over F9 | `checklists/post-incident.md` | response + post-mortem |
| `workflows/W12-global-review.md` | on request | consolidation | full panel of reviewers |

## Structure of every workflow (fixed sections)

Every `Wnn` follows the same anatomy, so the Orchestrator can jump from one to another without
relearning the format:

1. **Objective** — what the phase delivers, in one sentence.
2. **Preconditions (entry gate)** — which artifacts must be `approved` before starting.
3. **Steps (agent → artifact)** — the sequence, with dependencies and what each step writes.
4. **Decision points** — what goes up to the user (`core/question-engine.md`) or to the decision
   engine (`core/decision-engine.md`); where human approval is mandatory.
5. **Loops it opens** — the `loops/` that run inside the phase and their exit condition.
6. **Exit gate** — the verifiable criteria from `core/quality-gates.md` and who approves.
7. **Effort profiles** — how the profile (`core/orchestrator.md` §Effort profiles) sizes the phase.
8. **Related** — where the reader goes next.

## How a workflow is executed

1. **Read the state.** The Orchestrator reads `STATE.md` and confirms the active phase and the
   effort profile.
2. **Confirm the precondition.** Do the input artifacts exist and are they `approved`? If not, the
   previous workflow did not close — this one does not start (`core/lifecycle.md` §1, no skipping).
3. **Walk the steps by dependency**, not by blind numbering: a step starts when its inputs exist
   (graph built from the specs, `core/orchestrator.md`). Independent steps may run in parallel;
   panels run blind (`core/orchestrator.md` §Parallelism).
4. **Group the questions into batches** per phase, never piecemeal (`core/question-engine.md`).
5. **Close the open loops** before attempting the gate.
6. **Pass the gate** — independent verification + human approval where mandatory — and record it
   in `STATE.md`. Only then does the next workflow start.

## Rules that cut across all workflows

- **Going back is normal.** Discovering in a late workflow that upstream work is missing sends you
  back to the earlier phase — the reason is recorded in `STATE.md` (`core/lifecycle.md` §2). That
  is not a process failure; moving on without the gate is.
- **Every step writes.** Output that does not land in a `product/` artifact does not exist
  (`core/artifact-protocol.md` §1). A workflow "run" without written artifacts did not run.
- **Routing per task.** The Orchestrator picks the model tier for each step
  (`core/model-routing.md`) — never the top model by reflex across the whole queue of agents.
- **Security is cross-cutting.** `agents/09-security/security-coordinator.md` has a seat in
  every workflow; security is not a phase, it is a dimension (`core/lifecycle.md` §5).

## Related

- `core/lifecycle.md` — the phases these workflows execute.
- `core/orchestrator.md` — who conducts them.
- `core/quality-gates.md` — the gates that close each phase.
- `core/artifact-protocol.md` — the `product/` tree the workflows fill in.
- `agents/README.md` — the specs of the agents each step invokes.
- `loops/README.md` — the loops that run inside the phases.
