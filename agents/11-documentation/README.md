# 11 · Documentation — living knowledge

**Cross-cutting** category (F1→F9). While the other categories produce the product, this one ensures
the product **explains itself** — to those who build it, those who operate it and those who use it —
and that the explanation **neither lies nor ages**. Documentation here is not a final report: it is
a living artifact, derived from the sources of truth and synchronized with the code on every slice.

The category's anchor principle: **every fact has a single source**
(`modules/single-source-of-content.md`).
User help serves the screen **and** the grounding of any help AI; the API reference is generated
from the contract; technical docs derive from the code. Nothing is handwritten twice — what gets
duplicated, diverges (`knowledge/origin-lessons.md`).

## Agents in this category

| Agent | One line | Type |
| --- | --- | --- |
| `agents/11-documentation/documentation-architect.md` | Designs the **documentation structure** (specs, ADRs, runbooks, help) and declares the sources of truth and the precedence between them. | Specialist |
| `agents/11-documentation/technical-writer.md` | Writes and **updates the technical documentation** (README, architecture, onboarding) in sync with the code. | Specialist |
| `agents/11-documentation/user-help-writer.md` | Maintains the **complete Help menu, with examples**, as the single source serving the screen and AI grounding. | Specialist |
| `agents/11-documentation/api-documenter.md` | Produces the **API reference generated from the contract** (OpenAPI/schema), always current and never handwritten. | Specialist |

## Recommended order of work

1. **`documentation-architect`** first (early, in F1): defines the documentation map — where each
   document lives, who owns it and which source it derives from. Without this map, the writers
   write to inconsistent places.
2. **`technical-writer`**, **`user-help-writer`** and **`api-documenter`** in **parallel**, each in
   its own layer, as the sources come into existence (the code for the technical writer, the
   content-layer for help, the contract for the API). There is no dependency between them — they
   only share the architect's map.

## How the Orchestrator convenes it

- **On every build slice (F6)** the Orchestrator invokes the relevant writer to update the
  documentation touched — the slice only closes with docs up to date (`core/quality-gates.md`).
- **On drift**, `loops/L06-outdated-documentation.md` (opened by
  `agents/13-guardians/documentation-guardian.md` or by
  `agents/12-reviewers/documentation-reviewer.md`)
  re-convenes the right writer to reconcile documentation and reality.
- **In F1** the Orchestrator calls the `documentation-architect` to install the structure.

## Which phases it belongs to

Dominant phase: **cross-cutting (F1–F9)**. The architect works in F1 and revisits the structure at
each milestone; the writers accompany the build (F5–F6) and operation (F9). **Watching** the sync on
cadence belongs to the guardian (F9); the independent **review** belongs to the reviewer (F7) — this
category **writes**, it does not police itself.

## Related

- `agents/13-guardians/documentation-guardian.md` — watches drift on cadence; opens the loop.
- `agents/12-reviewers/documentation-reviewer.md` — reviews docs↔code sync before the milestone.
- `modules/single-source-of-content.md` — the SSOT foundation for labels, descriptions and help.
- `loops/L06-outdated-documentation.md` — the loop that re-convenes the writers.
- `agents/_template/AGENT-TEMPLATE.md` · `_meta/INVENTORY.md`
