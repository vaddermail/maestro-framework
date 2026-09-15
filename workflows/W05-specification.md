# W05 — Specification (F5)

> **Phase:** F5 · **Exit gate:** P5 (**unlocks code**) · **Core agents:**
> `agents/01-requirements/business-rules-modeler.md`, `agents/06-data/data-modeler.md`,
> `agents/05-backend/api-designer.md` and `agents/09-security/threat-modeler.md`,
> coordinated by `core/orchestrator.md`.

## Objective

Produce the **canonical, technology-agnostic functional source of truth**: the business rules
consolidated per module, the critical flows as state machines, the logical data model and the
backend contract (authorization, scoping, integrity, sensitive fields). It is the document that
**survives code rewrites** — when code and spec diverge, the spec wins
(`core/artifact-protocol.md` §H4). **Only after P5 is product code written** (F6).

## Preconditions (entry gate)

- [ ] P2 closed: requirements, `BR-nnn`, NFRs and acceptance criteria `approved`
      (`product/01-requirements/`).
- [ ] P3 closed: ADRs and stack `approved` (`product/02-architecture/`) — the backend contract
      assumes the style and boundaries already decided.
- [ ] P4 closed: screen map and flows `approved` (`product/03-experience/`) — the state machines
      of the critical flows reflect what UX designed.

If any is missing, **there is no specifying**: the spec would be built on scope, architecture or
UX left open (`core/lifecycle.md` §2).

## Steps (agent → artifact)

The specification **consolidates** what F2–F4 produced — it does not reinvent. Artifacts in
`product/04-specification/` (and the threat model in `product/05-security/`).

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | Orchestrator | `README.md` (index of the modules to specify, derived from the MVP) | priorities (F1), `FR` (F2) |
| 2 | `agents/01-requirements/business-rules-modeler.md` | `modules/<module>.md` (consolidated `BR-nnn` rules, permissions, flows per module) | `BR-nnn` (F2), flows (F4) |
| 3 | `agents/01-requirements/business-rules-modeler.md` | `state-machines.md` (states, transitions, effects, who may — `modules/state-machines.md`) | 2 |
| 4 | `agents/06-data/data-modeler.md` | `logical-data-model.md` (entities, **coherent bidirectional** relations, invariants — database-agnostic) | 2 |
| 5 | `agents/05-backend/api-designer.md` | `backend-contract.md` (authz/scoping/integrity/sensitive fields **100% on the server**) | 2, 4, ADRs (F3) |
| 6 | `agents/09-security/threat-modeler.md` | `product/05-security/threat-model.md` (STRIDE per critical feature) | 2–5 |
| 7 (conditional — only if any `FR` is marked `[AI]`) | `agents/09-security/ai-security-specialist.md` | `product/05-security/ai-security.md` (trust boundaries and guardrails per feature) | 2, 5, 6 |
| 8 (conditional — only if a KPI in `product/00-discovery/goals-and-kpis.md` depends on product events: activation, flow completion, abandonment) | `agents/05-backend/product-analytics-specialist.md` | `product/04-specification/backend/product-analytics.md` (event plan tied to the KPIs, zero PII) | 2, 5 |

**Templates:** `templates/specification/business-rules.md.template`,
`state-machine.md.template`, `logical-data-model.md.template`,
`backend-contract.md.template` (and `functional-requirement.md.template` for the `FR`→spec trail).

**Parallelism (`core/orchestrator.md` §Parallelism):** independent modules (step 2) are specified
in parallel; state machines (3), data model (4) and backend contract (5) share the rules from
step 2 and chain by dependency. The `threat-modeler` (6) runs over the already-drafted whole.
The `agents/09-security/security-coordinator.md` holds a cross-cutting seat — security is not a
phase, it is a dimension (`core/lifecycle.md` §5).

> **Golden rule of the backend contract (`modules/rbac-and-scoping.md`):** the client
> **declares**, the server **confirms**; fail-closed; out-of-scope answers **404** (never a 403
> that confirms existence). Sensitive fields never leave the server to whoever may not see them.
> This is specified here, not "remembered" in F6.

> **Scale to the profile:** in a prototype, the four documents collapse into a
> `product/04-specification/spec.md` of a few pages — but the **state machines of the critical
> flows and the data invariants** are always written (they are the historical origin of most
> defects, `knowledge/origin-lessons.md`).

## Decision points

Gaps go up to the Orchestrator in **batches** (`core/question-engine.md`). Typical F5 batches:

- **States and transitions** — which transitions are legal, which effects fire, who may run them.
- **Data invariants** — what may never become incoherent (bidirectional relations, uniqueness).
- **Fine-grained authorization** — which profile sees/does what, and what org-unit scoping cuts.
- **Sensitive fields** — what is confidential and from whom it is hidden.

**Mandatory human approval (P5):** the **complete specification** is approved by the user — it is
the contract that unlocks the build. Any **new processing of personal/sensitive data** flagged in
F2 is confirmed here in the threat model.

## Loops it opens

- **`loops/L05-inconsistencies.md`** — while there is divergence between spec ↔ requirements ↔
  data model (e.g. a rule without an entity, a state without an outgoing transition), reconcile
  with the upstream source of truth. **Exit condition:** zero open inconsistencies.
- A gap that reveals a **missing requirement** reopens F2 via
  `loops/L01-ambiguous-requirements.md` — the spec **does not invent** the requirement, it
  returns it (`core/lifecycle.md` §2). Anti-loop **safeguard** of 3 iterations on both
  (`loops/README.md`).

## Exit gate (P5)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] Specification **reviewed by a minimal panel** — architecture + security + UX — and
      consolidated by `agents/12-reviewers/review-consolidator.md` into a single plan without
      contradictions.
- [ ] **State machines** of the critical flows complete (states, transitions, effects, who may).
- [ ] **Logical data model** with invariants and coherent bidirectional relations.
- [ ] **Backend contract** defines authz, scoping and sensitive-field hiding **on the server**.
- [ ] Every MVP `FR` has a traceable spec; the threat model covers the critical features.
- [ ] If there are LLM features: `product/05-security/ai-security.md` written and reviewed; if
      there are none, recorded in `STATE.md` that there are none.
- [ ] The user **approved** the specification.

**Who verifies:** the reviewer panel (substance) + the consolidator (coherence) — never the
author. **Who approves:** the user. **With P5 closed, code is unlocked:**
`workflows/W06-build.md` starts.

## Failure and blocker recovery

`core/orchestrator.md` §Recovery. Contradictory reviews (e.g. backend contract vs threat
model) → the consolidator does not choose in silence: it exposes the conflict and asks for
reanalysis, or raises it to the user if it is a product decision. A missing requirement found
while specifying → return it to F2, record it in `STATE.md`; **no advancing to F6** with an
incomplete spec. User unavailable to approve → the spec stays `in-review`, the pending item in
`STATE.md` §Pending decisions; **not one line of product code** is written before P5.

## Effort profiles

| Profile | F5 depth |
| --- | --- |
| **Prototype** | Spec of a few pages reviewed by the Orchestrator itself + user OK; state machines only for the critical flows. |
| **Internal product** | Spec per module; minimal panel (architecture + security + UX); full data model and contract. |
| **Commercial product** | + formal threat model (STRIDE); extended panel review; backend contract detailed per endpoint. |
| **Enterprise platform** | + data model with audit/retention; contract with a target ASVS; global review (`workflows/W12-global-review.md`) before P5. |

## Related

- `core/artifact-protocol.md` — `product/04-specification/` is the source of truth downstream.
- `workflows/W02-requirements.md` · `workflows/W03-architecture.md` ·
  `workflows/W04-experience.md` — the phases this one consolidates.
- `workflows/W06-build.md` — the phase P5 unlocks.
- `modules/state-machines.md` · `modules/rbac-and-scoping.md` — the patterns the spec applies.
- `agents/12-reviewers/review-consolidator.md` — who merges the P5 review panel.
- `templates/specification/backend-contract.md.template` — the mold of the server contract.
