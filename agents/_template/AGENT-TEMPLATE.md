# Agent Template — `AGENT-TEMPLATE`

> **How to use:** copy this file into the right category (`agents/NN-category/agent-name.md`),
> fill in **all** sections and register the new agent in the category index (the folder's
> `README.md`) and in the global inventory (`_meta/INVENTORY.md`). No section is optional — if one
> does not apply, write explicitly "Not applicable, because …". See `playbooks/add-an-agent.md` for
> the full process and `core/extensibility.md` for the compatibility guarantees.

---

## Identification

| Field | Value |
| --- | --- |
| **Name** | Agent name (e.g. Security Guardian) |
| **Alias** | International name, if any (e.g. Security Guardian) |
| **Category** | `NN-category` (the folder it lives in) |
| **Phases** | Lifecycle phases where it acts (see `core/lifecycle.md`) — e.g. F1, F9 |
| **Type** | `specialist` \| `arbiter` \| `reviewer` \| `guardian` \| `coordinator` |
| **Suggested model** | Model tier + effort, per `core/model-routing.md` (e.g. `standard` / `top, effort medium`) |

## Objective

One paragraph: this agent's **single responsibility**. If you need an "and" to describe two
independent responsibilities, that is two agents.

## When it starts

Concrete activation conditions: which phase, which event, which artifact became available, who
invokes it (normally the Orchestrator — see `core/orchestrator.md`). An agent never invokes itself
outside these conditions.

## When it ends

Verifiable completion criteria (not "when it looks good"): which artifacts exist, which checklist
passed, which quality gate was met. If the agent can end **blocked** (waiting for an answer from
the user), say how it records the block (`STATE.md` → pending decisions).

## Inputs

| Artifact | Source (agent/phase) | Required? | Notes |
| --- | --- | --- | --- |
| `product/…/example.md` | Agent X (F1) | Yes | What it needs to contain to be usable |

If a required input does not exist or is incomplete, the agent **does not proceed on assumptions**:
it returns to the Orchestrator the list of gaps and the questions to ask (see
`core/question-engine.md`).

## Outputs

| Artifact | Destination (location in the project) | Consumers |
| --- | --- | --- |
| `product/…/example.md` | Where it gets written | Agents that will read it downstream |

Every output is **written to a file** in the project (never just "said" in the conversation) —
that is how the project memory stays auditable (see `core/project-memory.md`).

## Questions to the user

The typical questions this agent asks when information is missing, in the format of
`core/question-engine.md`: context → question → why it matters → options with pros/cons in plain
language → default recommendation. Questions grouped in batches; never a machine gun of loose
questions.

## Rules

Non-negotiable rules the agent always follows. Numbered, verifiable, with the why when it is not
obvious. E.g.: "1. Never declares the analysis complete with unresolved ambiguous requirements —
opens the loop `loops/L01-ambiguous-requirements.md`."

## Limitations (what this agent does NOT do)

Explicit boundaries with the neighboring agents, to avoid overlap and duplicated work. Name the
agent responsible for each excluded item. E.g.: "Does not choose technologies — that belongs to
`agents/02-architecture/stack-selector.md`."

## Workflow

Numbered step-by-step of the agent's work, from the first input to the last output. Include the
decision points, the loops it can open and the moments when it returns control to the Orchestrator.
If a step produces an artifact, say which one.

## Examples

At least **one concrete and realistic example** end to end: input received → reasoning → questions
asked (if applicable) → output produced (excerpt). Prefer examples from varied domains
(e-commerce, B2B SaaS, internal app) to show the agent is domain-agnostic.

## Best practices

What separates an excellent result from an acceptable one in this role. Distilled from experience
(see `knowledge/`), not generic theory.

## Anti-patterns

Typical mistakes this agent must refuse to make, each with the symptom and the correct alternative.
E.g.: "❌ Assuming the answer instead of asking → ✅ record the gap and ask in a batch."

## Interactions

| Agent | Relationship |
| --- | --- |
| `path/to/agent.md` | upstream (provides X) / downstream (consumes Y) / parallel (coordinates Z) |

## Done criteria

Final verifiable checklist before the agent delivers (links to `checklists/` and to the phase gate
in `core/quality-gates.md`):

- [ ] …
- [ ] …
