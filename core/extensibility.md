# Extensibility

How the framework grows **without breaking**: new agents, workflows, loops, modules and templates
are added **by addition, never by surgery** on the existing ones. It is the open-closed principle
applied to executable documentation — and it is what lets Maestro accompany a product for years.

## Why it works

Three structural properties make addition safe:

1. **Contracts through artifacts, not calls.** Agents do not know each other — they know
   artifacts (`core/artifact-protocol.md`). A new agent that produces/consumes existing
   artifacts fits in without any existing one knowing about it.
2. **Discovery through indexes, not hardcoding.** The Orchestrator finds agents through the
   indexes (`agents/README.md` + category README + `_meta/INVENTORY.md`), assembling the
   dependency graph from the agent specs. To be registered is to exist.
3. **Self-contained agent specs.** Each spec declares everything (inputs, outputs, rules,
   interactions); there is no hidden behavior in some other file that would need editing.

## Adding an agent

Full process in `playbooks/add-an-agent.md`. The essentials:

1. Confirm it really is **a new agent** (a responsibility no existing one has) and not a
   missing section in an existing agent spec.
2. Copy `agents/_template/AGENT-TEMPLATE.md` into the right category; fill in **all**
   sections.
3. Declare inputs/outputs in terms of existing artifacts — or, if it creates new artifacts,
   add them to `core/artifact-protocol.md` (adding rows, not changing the existing
   ones).
4. Register in the indexes: category README + `_meta/INVENTORY.md`.
5. If the agent joins a workflow, add the step to that workflow — as a **new step**,
   without reordering the existing ones unless a reason is recorded.

**What is never needed:** editing other agent specs, the Orchestrator, or the template.
If the addition seems to require that, the design is wrong — go back to step 1.

## Adding an agent category

New folder `agents/NN-name/` with its own index README + an entry in `agents/README.md` and in the
inventory. Numbers are never recycled (like artifact IDs — `core/artifact-protocol.md`).

## Adding workflows, loops, modules, templates, checklists, playbooks

Same pattern for all: **create the file following the folder's convention (see its README) →
register it in the folder's index → register it in the inventory.** Loops always declare an entry
condition, an exit condition and an anti-infinite safeguard (`loops/README.md`); modules declare
themselves decoupled and adoptable in isolation (`modules/README.md`).

## Changing the existing ones (the exception)

Sometimes a contract really does have to change (agent template, artifact protocol, lifecycle).
That is a **MAJOR change** of the framework (`_meta/VERSION.md`):

- It is justified in writing (what, why, what breaks).
- Prefer the expand-contract path here too: introduce the new one alongside, migrate the agent
  specs, retire the old one — never break everything in one step.
- Existing projects **do not inherit the change automatically**: they re-sync deliberately.

## Deprecating

Nothing is deleted blindly: a deprecated spec/document is marked `obsolete` at the top, with a
pointer to its replacement, and leaves the active indexes. (The same reversibility principle as
always — `MANIFESTO.md` §5.)

## Related

- `playbooks/add-an-agent.md` — the step-by-step.
- `agents/_template/AGENT-TEMPLATE.md` — the mold.
- `_meta/INVENTORY.md` — the register that makes a file "exist".
- `_meta/VERSION.md` — versioning of the framework itself.
- `playbooks/framework-curation.md` — where many of the additions come from: the circuit of
  improvements reported by projects (`knowledge/README.md` §Como o conhecimento circula).
