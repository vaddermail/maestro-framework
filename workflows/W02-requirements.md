# W02 — Requirements (F2)

> **Phase:** F2 · **Exit gate:** P2 · **Core agents:** `agents/01-requirements/` (6
> specialists) + the `loops/L01-ambiguous-requirements.md` loop, conducted by
> `core/orchestrator.md`.

## Objective

Turn the discovery dossier (F1) into **traceable requirements, explicit business rules,
quantified NFRs and a glossary without synonyms** — so that architecture (F3), specification
(F5) and tests can consume them **without guessing**. Here the *what* and the *rules* are decided,
never the *how* (that is F3, `agents/02-architecture/`). The output is the base of the chained
traceability (`core/artifact-protocol.md` §4): idea → `FR-nnn` → `BR-nnn` → acceptance criteria →
specification → code → test. The non-negotiable closing condition is **zero critical ambiguities
open**.

## Preconditions (entry gate)

- [ ] P1 closed: discovery dossier `approved` in `product/00-discovery/` — use cases, MVP and
      priorities confirmed by the user.
- [ ] User available for question batches (disambiguation is Q&A-intensive).

If the MVP is not delimited or the priorities are not approved, **F2 does not start** — it goes
back to F1 (`core/lifecycle.md` §2). Requirements built on an unclosed scope generate rework.

## Steps (agent → artifact)

The order follows `agents/01-requirements/README.md`. All artifacts live in
`product/01-requirements/`.

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | `agents/01-requirements/glossary-curator.md` | `glossary.md` (ubiquitous language, banned synonyms) | dossier (F1) |
| 2 | `agents/01-requirements/requirements-engineer.md` | `functional-requirements.md` (`FR-nnn` traceable to `UC-nnn`/MVP) | 1, use cases (F1) |
| 3 | `agents/01-requirements/business-rules-modeler.md` | `business-rules.md` (`BR-nnn`, invariants, state-machine sketch) | 2 |
| 4 | `agents/01-requirements/nfr-specifier.md` | `nfr.md` (`NFR-nnn` **quantified**) | 2, risks and goals (F1) |
| 5 | `agents/01-requirements/acceptance-criteria-writer.md` | `acceptance-criteria.md` (verifiable ACs per `FR`) | 2 stabilized, 3 |
| 6 | `agents/01-requirements/ambiguity-hunter.md` | `questions-and-answers.md` (question batch + ambiguity marks) | runs over 1–5 |
| 7 | `agents/01-requirements/requirements-engineer.md` | marks `[AI]` on every `FR` where the product calls a language model (generate, classify, semantic search, act) — this is the trigger for the conditional step in `workflows/W05-specification.md` that invokes `agents/09-security/ai-security-specialist.md`; with no `FR` marked, it is recorded in `STATE.md` that the product does not call models | 2 |

**Parallelism (`core/orchestrator.md` §Parallelism):** steps 3 (rules) and 4 (NFRs) run in
parallel — the rules the `FR`s must respect and the quality attributes that cut across them do
not share a written artifact. The glossary (1) **keeps growing throughout the whole phase**; it is
not a step that closes at the start. The `ambiguity-hunter` (6) **is not a single final step**: it
fires whenever an F2 artifact changes, feeding loop L01 until it closes, and it is the **last one
to give the OK**.

> **Scales with the profile (`core/artifact-protocol.md`):** in a prototype, the five artifacts
> collapse into a single `product/01-requirements/functional-requirements.md` — but the **section
> titles and IDs** (`FR-nnn`, `BR-nnn`, `NFR-nnn`) are kept, so traceability survives growth.

Each `FR` references the `UC-nnn`(s) it satisfies; each `BR` points to the `FR`s it constrains;
each AC proves an `FR`. A requirement without an acceptance criterion is detectable — and does not
pass the gate. Templates: `templates/specification/functional-requirement.md.template` and
`templates/specification/business-rules.md.template`.

## Decision points

The gaps the agents raise go up to the Orchestrator, which groups them into **batches by theme**
(never piecemeal — `core/question-engine.md`). Typical F2 batches:

- **Business rules** — who may do what, within which limits, which invariants are never violated.
- **Edge cases** — what happens at zero, when empty, under concurrency, out of scope.
- **NFRs** — concrete numbers: target latency, availability, volumes, compliance, retention.
- **Requirement priority** — mandatory in the MVP vs nice-to-have (feeds back into F1's
  `prioritizer`).

**Mandatory human approval (P2):** the **functional requirements, the business rules and the
NFRs** are approved by the user — they pin the product's contract. Any requirement touching
**personal/sensitive data** is marked here for the F5 threat model
(`agents/09-security/security-coordinator.md`, with a cross-cutting seat).

## Loops it opens

- **`loops/L01-ambiguous-requirements.md`** — opened by the `ambiguity-hunter`: while a
  **critical** ambiguity, contradiction or gap exists, each one is converted into a `P-nnn` and
  asked to the user in a batch. **Exit condition:** zero critical items left unanswered.
  **Anti-loop safeguard** (`loops/README.md`): 3 iterations without progress → the Orchestrator
  stops, records the diagnosis and goes up to the user with options, instead of insisting.

## Exit gate (P2)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] `loops/L01-ambiguous-requirements.md` closed: **zero critical ambiguities/contradictions**
      open.
- [ ] `NFR-nnn` **quantified** (no "must be fast" — each one with a verifiable number).
- [ ] Business rules **numbered** (`BR-nnn`) and approved; every MVP `FR` has an acceptance
      criterion.
- [ ] Glossary covers the terms used in the requirements, with no competing synonyms.
- [ ] No solution decision made (nothing on technology/screens — that is F3/F4).

**Who verifies:** the `ambiguity-hunter` (open items) + the Orchestrator (completeness and
traceability). **Who approves:** the user (requirements, rules, NFRs). With P2 closed,
`workflows/W03-architecture.md` starts.

## Recovery from failures and blockages

`core/orchestrator.md` §Recovery. Agent without input (e.g. NFRs without F1 risks) → schedule the
upstream agent or add it to the next question batch. Ambiguity the user does not resolve →
it stays in `STATE.md` §Pending decisions; it is only assumed by default when the **single
rule** allows it (`core/question-engine.md` §When to assume by default) — **critical** ambiguities
are never assumed.
A divergence discovered later (in F5) sends work back to this phase — the reason is recorded in
`STATE.md` and L01 reopens (that is the cycle working, not a failure).

## Effort profiles

| Profile | F2 depth |
| --- | --- |
| **Prototype** | Requirements and rules in a single file; only the NFRs that block decisions; ACs on the risky flows. |
| **Internal product** | Full structure; NFRs quantified with the system's owner; L01 formally closed. |
| **Commercial product** | + explicit compliance in the NFRs; acceptance criteria on every MVP `FR`. |
| **Enterprise platform** | + NFRs with contractual SLAs; business rules reviewed by multi-team stakeholders. |

## Related

- `agents/01-requirements/README.md` — the category, the order and the dependency graph.
- `workflows/W01-discovery.md` — the previous phase (supplies the dossier).
- `workflows/W03-architecture.md` — the next phase (consumes requirements and NFRs).
- `workflows/W05-specification.md` — where the `business-rules-modeler` re-enters.
- `loops/L01-ambiguous-requirements.md` — the loop this phase runs until it closes.
- `core/artifact-protocol.md` — the `product/01-requirements/` tree and the ID chain.
