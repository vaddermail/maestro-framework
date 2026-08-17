# Product Lifecycle (F0–F9)

The lifecycle is the framework's backbone: ten phases, from idea to perpetual operation. Each phase
has a **workflow** that executes it, **agents** that work in it, **artifacts** it produces and a
**quality gate** that decides the passage to the next (`core/quality-gates.md`).

```
F0 Kickoff
└─▶ F1 Discovery ─▶ F2 Requirements ─▶ F3 Architecture ─▶ F4 Experience ─▶ F5 Specification
                                                                              │
        ┌─────────────────────────────────────────────────────────────────────┘
        ▼
    F6 Build ─▶ F7 Quality & Security ─▶ F8 Launch ─▶ F9 Continuous operation ──▶ ∞
                                                                 │
                                              (new requests) ◀───┘
                                              W10-feature-evolution re-enters F2–F8 in miniature
```

## Lifecycle rules

1. **No skipping.** No phase is skipped — it is scaled. The effort profile
   (`core/orchestrator.md` §Effort profiles) decides the depth: in a prototype, F1–F5 may fit in
   a day; on an enterprise platform, they take weeks. But a gate is never crossed out of haste.
2. **Going back is normal; advancing without a gate is not.** Discovering in F5 that a requirement
   is missing sends work back to F2 — that is the process working. Record the reason in `STATE.md`.
3. **Iteration inside a phase is free.** Loops (`loops/`) run inside the phases until the exit
   condition closes.
4. **F9 never ends.** Continuous operation lasts the product's lifetime. New requests come in
   through `workflows/W10-feature-evolution.md`, which re-runs F2→F8 in miniature for each feature.
5. **Cross-cutting concerns always on:** memory (`core/project-memory.md`), question engine
   (`core/question-engine.md`), security (the `agents/09-security/security-coordinator.md`
   has a seat in every phase — security is not a phase, it is a dimension).

## The phases

### F0 — Kickoff

- **Goal:** project foundation: memory instantiated, effort profile calibrated, raw idea recorded.
- **Workflow:** `workflows/W00-project-kickoff.md`
- **Agents:** the Orchestrator in person (`core/orchestrator.md`).
- **Artifacts:** `STATE.md`, `CLAUDE.md` (or equivalent), the `product/` tree.
- **Gate:** memory created + effort profile confirmed by the user.

### F1 — Discovery

- **Goal:** understand the problem before the solution: stakeholders, personas, use cases,
  goals, KPIs, risks, costs, roadmap, MVP.
- **Workflow:** `workflows/W01-discovery.md`
- **Agents:** `agents/00-discovery/` (12 specialists).
- **Artifacts:** `product/00-discovery/` (complete dossier).
- **Gate:** discovery dossier validated by the user; MVP and priorities approved;
  no critical gap left open.

### F2 — Requirements

- **Goal:** turn discovery into traceable requirements, explicit business rules and verifiable
  acceptance criteria — **with no ambiguities**.
- **Workflow:** `workflows/W02-requirements.md`
- **Agents:** `agents/01-requirements/` (6 specialists); loop `loops/L01-ambiguous-requirements.md`.
- **Artifacts:** `product/01-requirements/`.
- **Gate:** zero **critical** ambiguities (non-critical ones recorded with accepted risk); NFRs
  quantified; business rules numbered and approved.

### F3 — Architecture

- **Goal:** decide how it gets built: architectural style (specialist panel with an
  arbiter), concrete stack (stable versions), integrations and boundaries.
- **Workflow:** `workflows/W03-architecture.md`
- **Agents:** `agents/02-architecture/` (arbiter + 11 specialists + stack selector);
  engines in `core/decision-engine.md`.
- **Artifacts:** `product/02-architecture/` (vision + ADRs + stack).
- **Gate:** ADRs written with alternatives and reversibility; stack pinned; user validated
  costs and trade-offs in plain language.

### F4 — Experience (UX/UI)

- **Goal:** design the experience before the code: flows, wireframes, design system (tokens),
  screen map, accessibility and responsiveness planned.
- **Workflow:** `workflows/W04-experience.md`
- **Agents:** `agents/03-experience/` (10 specialists).
- **Artifacts:** `product/03-experience/`.
- **Gate:** user validated the wireframes of the critical flows; design system with tokens defined;
  accessibility requirements accepted.

### F5 — Specification

- **Goal:** the canonical functional source of truth, technology-agnostic: business rules
  per module, critical flows, state machines, logical data model, backend contract.
  It is the document that survives code rewrites.
- **Workflow:** `workflows/W05-specification.md`
- **Agents:** `agents/01-requirements/business-rules-modeler.md`,
  `agents/06-data/data-modeler.md`, `agents/05-backend/api-designer.md`,
  `agents/09-security/threat-modeler.md`, coordinated by the Orchestrator.
- **Artifacts:** `product/04-specification/` (specs per module + cross-cutting).
- **Gate:** specification reviewed by `agents/12-reviewers/review-consolidator.md` (minimal
  panel: architecture + security + UX) and approved by the user. **Only here is code unlocked.**

### F6 — Build

- **Goal:** build in vertical slices (data → backend → frontend per feature),
  each slice with tests, following the specification. Divergence from the spec → the spec wins or
  the spec is updated first.
- **Workflow:** `workflows/W06-build.md`
- **Agents:** `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`,
  `agents/10-quality/`; loops L02/L04/L05.
- **Artifacts:** code + tests + `product/99-records/` (progress per slice in `STATE.md`).
- **Gate per slice:** `checklists/definition-of-done.md` + `checklists/pre-merge.md`.
- **Phase gate:** MVP complete against the specification; regression harness green.

### F7 — Quality & Security

- **Goal:** independent scrutiny before the real world: reviewer panel, adversarial audit,
  pentest, performance and accessibility verification.
- **Workflow:** `workflows/W07-quality-and-security.md` (uses `workflows/W12-global-review.md`)
- **Agents:** `agents/12-reviewers/` (full panel), `agents/09-security/pentester.md`,
  `playbooks/adversarial-audit.md`.
- **Artifacts:** `product/99-records/reviews/` + consolidated fix plan.
- **Gate:** zero critical/high findings left unresolved; `checklists/pre-production-security.md`
  complete; residual-risk decisions signed off by the user.

### F8 — Launch

- **Goal:** go to production with a net: infra provisioned, pipelines working, backups and
  rollback rehearsed, monitoring on.
- **Workflow:** `workflows/W08-launch.md`
- **Agents:** `agents/07-devops/`, `agents/08-infrastructure/`; pipelines from `pipelines/`.
- **Artifacts:** `product/07-operations/` (runbooks, SLOs, DR plan) + infrastructure as code.
- **Gate:** `checklists/go-live.md` complete; **explicit human approval for production**
  (never delegable to agents).

### F9 — Continuous operation

- **Goal:** keep the product healthy forever: guardians on cadence, maintenance loops,
  incident response, feature evolution.
- **Workflow:** `workflows/W09-continuous-operation.md` (+ W10 evolution, W11 incidents)
- **Agents:** `agents/13-guardians/` (permanent team of 8).
- **Artifacts:** guardian reports in `product/99-records/guardians/`, post-mortems,
  `STATE.md` always alive.
- **Gate:** none — there are **cadences** (daily/weekly/monthly, defined in
  `agents/13-guardians/README.md`) and loops L02–L08 always armed.

## Related

- `core/orchestrator.md` — who drives the cycle.
- `core/quality-gates.md` — the gates in detail.
- `core/artifact-protocol.md` — the complete `product/` tree.
- `workflows/README.md` — workflow conventions.
