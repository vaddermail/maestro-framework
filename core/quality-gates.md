# Quality Gates

A gate is a **binary, verifiable decision**: either the work meets the criteria and moves forward,
or it does not and it stays. Gates exist to replace "looks ready" with evidence — and to
guarantee that the decisions that belong to the human actually reach the human.

## Anatomy of a gate

Every gate declares:

1. **What it guards** — the transition (phase→phase, slice→merge, release→production).
2. **Criteria** — a verifiable checklist (lives in `checklists/`), no subjective items. The
   automatable criteria are called *gates* (`core/glossary.md`); none of them, alone, passes the
   gate. An automated gate only counts once it is proven to **fail** on a real case — a positive
   control (`knowledge/ai-pitfalls.md` §AR-25); before that, its green does not distinguish
   "passed" from "did not measure".
3. **Who verifies** — never whoever produced (reviewers, the test harness, or the Orchestrator
   for formal criteria).
4. **Who approves** — the user, when the decision is theirs (see matrix below); otherwise the
   Orchestrator declares the pass.
5. **Record** — result in `product/99-records/gates/Pn-YYYY-MM-DD.md`
   The record is the source; `STATE.md` summarizes it in §Done; the genesis reads the "1st?"
   column from it. (`templates/project/GATE.md.template`: items, evidence, verified by, approved
   by, waivers) and a summary in `STATE.md`.

**There is no partial pass.** A gate with one failed criterion does not pass; what exists is the
user being able to **explicitly waive** a criterion — and the waiver is recorded with the why and
the risk assumed (it is the user's decision, not an agent's shortcut).

## The lifecycle gates

| Gate | Transition | Main criteria | Human approval? |
| --- | --- | --- | --- |
| **P0** | F0 → F1 | Memory instantiated; effort profile calibrated | Yes (profile) |
| **P1** | F1 → F2 | Discovery dossier complete; MVP and priorities defined; risks with owners | **Yes** (scope) |
| **P2** | F2 → F3 | Zero critical ambiguities (L01 closed); NFRs quantified; business rules numbered | **Yes** (requirements) |
| **P3** | F3 → F4 | ADRs approved with reversal path; stack pinned to stable versions; costs validated | **Yes** (ADRs + costs) |
| **P4** | F4 → F5 | Wireframes of the critical flows validated; design system tokens defined; accessibility plan | **Yes** (UX) |
| **P5** | F5 → F6 | Specification approved; state machines for the critical flows; logical data model; backend contract; minimal review (architecture+security+UX) | **Yes** — unlocks code |
| **P6** | per slice, F6 | `checklists/definition-of-done.md` + `checklists/pre-merge.md`; tests green (front and back); spec respected | No (unless new scope) |
| **P6b** | F6 → F7 | MVP complete vs spec; regression harness green; debt recorded | Yes (MVP acceptance) |
| **P7** | F7 → F8 | Zero critical/high findings open; `checklists/pre-production-security.md`; residual risk signed off | **Yes** (residual risk) |
| **P8** | F8 → production | `checklists/go-live.md`; rollback rehearsed; backups verified; monitoring active | **Yes, always** — production belongs to the human |
| **P9** | continuous, F9 | Guardian cadences met; loops with no critical pending items | By exception (reports) |

## Human approval matrix

Regardless of the gate, these **always** require a human (see `core/orchestrator.md` §Human
approval): scope and priorities · money and commitments · destructive/bulk actions · production ·
residual security risk · personal data · reopening closed decisions.

And these **never** need a human: running tests, lint and scans; writing drafts; refactors with no
behavior change inside a slice; questions to the code itself (analysis). Automating verification
is desirable; automating **approval**, forbidden.

## Gates and effort profiles

The profile (`core/orchestrator.md` §Effort profiles) scales the **depth of the evidence**, not
the existence of the gate: in a prototype, P5 can be "a 3-page spec reviewed by the Orchestrator
itself + the user's OK"; on an enterprise platform it is a full panel. Each checklist's table
states what is waivable per profile — whatever is not marked as waivable, is not.
**Gate records** (`templates/project/GATE.md.template`): mandatory in every profile for P0–P5,
P6b, P7 and P8; the P6 record **per slice** is waivable in a prototype —
`_meta/verify-project.sh` reads the profile from `STATE.md` and does not require it in that case.
**Single exception: adoption in a product that already exists** — records count from the adoption
phase declared in `STATE.md` (the "Adoption" field); earlier gates are not reconstructed
(`workflows/W00-project-kickoff.md` §Adopting in a product that already exists). This is the single
rule; the template, W00, W06 and the checklists all point back here.

## Anti-patterns

- ❌ Rubber gate ("almost there, let it pass") → ✅ it either passes or it stays; a waiver is the
  user's, recorded.
- ❌ Self-validation (whoever built it declares it done) → ✅ independent verification, always.
- ❌ "Tested" without output → ✅ evidence attached (actual test results, in the format of
  `knowledge/proven-patterns.md` §Live proof) — absolute honesty.
- ❌ Surprise gate (criteria revealed on the spot) → ✅ criteria known from the start of the phase.
- ❌ Piling everything into one final mega-gate → ✅ small, frequent gates (P6 per slice).

## Related

- `checklists/README.md` and all the checklists — the concrete criteria.
- `core/lifecycle.md` — where the gates fit.
- `core/orchestrator.md` — who enforces them.
- `playbooks/adversarial-audit.md` — maximum scrutiny, used at P7.
