# Definition of Done

What closes each phase of the lifecycle (`core/lifecycle.md`, F1–F9) and what closes any code
change within F6. It is the factual basis of each phase's gate (`core/quality-gates.md`) — the
checklist does not decide the passage on its own, but without it the gate has no evidence to
decide with. **Cross-cutting to every phase close:** the phase's line in the genesis dossier
(`product/99-records/genesis.md` — `templates/project/GENESIS.md.template`) is part of the gate;
and a green `bash Maestro/_meta/verify-project.sh` confirms the process is being followed, not
just declared.

## F1 — Discovery

- [ ] Discovery dossier complete in `product/00-discovery/`: stakeholders, personas, use cases,
      goals, KPIs, risks, roadmap and MVP written.
- [ ] MVP scoped and explicitly approved by the user (recorded in `STATE.md`).
- [ ] Every risk has a named owner and a described mitigation.
- [ ] Zero critical gaps left open — the phase's questions answered or recorded as pending.

## F2 — Requirements

- [ ] Zero **critical** ambiguities open in `loops/L01-ambiguous-requirements.md`; non-critical
      ones recorded with the risk accepted by the user (the criterion L01 operationalizes).
- [ ] Non-functional requirements quantified with concrete numbers (e.g. "P95 < 300ms", not
      "fast").
- [ ] Business rules numbered and approved by the user.
- [ ] Every functional requirement has an associated verifiable acceptance criterion.

## F3 — Architecture

- [ ] Every ADR written with compared alternatives and an explicit rollback plan
      (`templates/project/ADR-DECISION.md.template`).
- [ ] Stack pinned to stable versions (LTS/GA); no alpha/beta/RC without a recorded justification
      (`knowledge/permanent-rules.md` §6).
- [ ] User validated costs and trade-offs in plain language, with the decision recorded in
      `STATE.md`.

## F4 — Experience

- [ ] Wireframes of the critical flows validated by the user.
- [ ] Design system tokens defined (color, typography, spacing) — no hardcoded values.
- [ ] Target WCAG level confirmed and accessibility plan written
      (`agents/03-experience/accessibility-specialist.md`).
- [ ] Performance budgets per route type defined
      (`agents/03-experience/web-performance-specialist.md`). *(waivable in: prototype)*

## F5 — Specification

- [ ] Specification reviewed by the minimum panel (architecture + security + UX) and approved by
      the user (`agents/12-reviewers/review-consolidator.md`). *(in a prototype, review by the
      Orchestrator + the user's OK replaces the panel — `core/quality-gates.md`)*
- [ ] State machines of all critical flows written (`modules/state-machines.md`).
- [ ] Logical data model complete, with explicit invariants.
- [ ] Backend contract written: authorization, scoping, transactional integrity, sensitive fields.

## F6 — Skeleton (slice 0), once before the feature slices

What many gates presuppose but is only found missing late — one surface with no test *runner*, a
guardrail that was never wired up — must exist **before** the first feature slice. It is an
**entry** criterion, not just an exit one: a rule only checked at the end of F7 has already been
bypassed throughout the entire build.

- [ ] Every testable surface (frontend, backend, …) has a test *runner* **configured and running
      in CI** — a passing typecheck and build do **not** count as tested
      (`checklists/pre-merge.md`).
- [ ] The guardrails the product will demand are wired into CI from the start (lint, static
      analysis, architecture boundaries, secrets scanning), even if they still catch little — they
      get wired early, not on the eve of go-live.
- [ ] The pipeline runs on all surfaces, separately, and is green before the first slice starts.

## F6 — Build (per slice)

- [ ] "Per code change" section (below) satisfied.
- [ ] `checklists/pre-merge.md` satisfied.
- [ ] The slice honors the specification — or the specification was updated first, in the open.
- [ ] Slice progress recorded in `STATE.md`; the non-obvious that belongs to the **framework**
      (not the product) recorded in the moment in `FRAMEWORK-IMPROVEMENTS.md`
      (`templates/project/FRAMEWORK-IMPROVEMENTS.md.template`).

## P6b — F6 close (MVP acceptance)

- [ ] Every MVP FR with traceable code and test; regression harness green in the target
      environment (`workflows/W06-build.md` §The per-slice gate (P6) and the phase gate (P6b)).
- [ ] Unresolved technical debt **recorded** (`loops/L08-technical-debt.md`), not hidden.
- [ ] `FRAMEWORK-IMPROVEMENTS.md` consolidated and report sent to the upstream framework
      (`playbooks/report-framework-improvements.md`) — in long builds, the lessons go upstream at
      MVP acceptance, not months later.
- [ ] MVP acceptance by the user recorded in `STATE.md`.

## F7 — Quality & Security

- [ ] Zero critical or high findings left unresolved.
- [ ] `checklists/pre-production-security.md` complete.
- [ ] Adversarial audit run when the effort profile demands it
      (`playbooks/adversarial-audit.md`).
- [ ] Residual risk explicitly signed off by the user.
- [ ] `FRAMEWORK-IMPROVEMENTS.md` consolidated and report sent to the upstream framework
      (`playbooks/report-framework-improvements.md`).

## F8 — Launch

- [ ] `checklists/go-live.md` complete.
- [ ] Explicit human approval for production recorded in `STATE.md` — never delegable to agents.
- [ ] Go-live lessons (the ones only production exposes) recorded and report sent
      (`playbooks/report-framework-improvements.md`).

## F9 — Continuous operation

- [ ] Guardian cadences met at the defined periodicity (`agents/13-guardians/README.md`).
- [ ] No loop with a critical pending item open beyond the defined ceiling (`loops/README.md`).
- [ ] Post-mortems of closed incidents have verified actions, not just planned ones
      (`checklists/post-incident.md`).
- [ ] Improvement report sent at the profile's cadence
      (`playbooks/report-framework-improvements.md`).

## Per code change

Applies to any slice, PR or hotfix, from the first commit of F6 onward:

- [ ] Valid syntax and build/compilation without errors.
- [ ] No console/log errors while exercising the affected screens or endpoints, under the affected
      profiles/roles.
- [ ] Relationship integrity and business invariants preserved (rules in
      `product/04-specification/`).
- [ ] Scoping and authorization preserved on the touched lists/endpoints.
- [ ] `STATE.md` updated; `CHANGELOG.md` too if it is a milestone.

## Related

- `core/lifecycle.md` — the phases this checklist closes.
- `core/quality-gates.md` — how the outcome decides the passage.
- `checklists/pre-merge.md` — each slice's next gate.
- `checklists/README.md` — how it is used and who runs it.
- `core/project-memory.md` — where the outcome is recorded.
- `knowledge/permanent-rules.md` — the principles the items operationalize.
