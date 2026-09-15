# W06 — Build (Phase F6)

How the approved specification becomes working code, **vertical slice by vertical slice**,
without the phase turning into a mega-batch where everything depends on everything. It is the
longest phase of the lifecycle (`core/lifecycle.md`) and the one that breeds the most defects
when discipline slips — which is why the gate is **per slice** (P6), not only at the end.

> **Phase:** F6 · **Entry gate:** P5 (approved specification — only here is code unlocked)
> · **Exit gate:** P6b (complete MVP vs spec; regression harness green)
> · **Previous workflow:** `workflows/W05-specification.md`
> · **next:** `workflows/W07-quality-and-security.md`

## Objective

Turn the approved specification into a working product, vertical slice by vertical slice — each
slice delivered end to end (data → backend → frontend → tests), verified with a real live proof
and closed by the P6 gate, until the complete MVP passes P6b with the user's acceptance.

## Preconditions (check before writing the first line)

- [ ] `product/04-specification/` in `approved` state (P5 passed) — rules, state machines,
      logical data model and backend contract exist and were reviewed.
- [ ] F3 ADRs pinned and the chosen stack on stable versions (`product/02-architecture/stack.md`).
- [ ] Design system with tokens and wireframes of the critical flows validated
      (`product/03-experience/`).
- [ ] `product/06-tests/test-strategy.md` written by (if it does not exist yet, it is step 0.0 of
      slice 0 — you do not "return it to the phase", you produce it here)
      `agents/10-quality/test-strategist.md` — slice 0 and the test plan derive from it, and
      `agents/12-reviewers/test-reviewer.md` demands it as input in F7.
- [ ] Repository with the skeleton created, quality and security CI armed
      (`pipelines/ci-quality.md`, `pipelines/ci-security.md`) — the first merge already runs
      green. If a **validated starter** exists for the stack chosen in F3, the skeleton starts
      from it (`starters/README.md`) instead of being built by hand — same bar, slice 0 cost
      ~zero.

If anything is missing, **the build does not start** — return it to the phase that produces it
(lifecycle rule 2).
The skeleton is the exception: no earlier phase produces it — it happens in §Slice 0, below.

## Slice 0 — the skeleton (once, before the first slice)

The skeleton is a hard precondition of F6 and has no upstream phase — it happens here, **once**,
before the first feature slice; a skeleton assembled partway through the build is a retrofit, the
most expensive avoidable cost of the phase.

| # | Who | Action | Artifact |
| --- | --- | --- | --- |
| 0.0 | `agents/10-quality/test-strategist.md` | Test strategy (levels by risk, runners per surface) — only if it does not exist yet | `product/06-tests/test-strategy.md` |
| 0.1 | Orchestrator | If a **validated starter** exists for the F3 stack, start from it (`starters/README.md`) and skip to 0.5; otherwise, 0.2–0.4 | — |
| 0.2 | `agents/07-devops/github-specialist.md` (or `agents/07-devops/gitlab-ci-specialist.md` / `agents/07-devops/azure-devops-specialist.md`, per the platform pinned in F3 in `product/02-architecture/stack.md`) | Repository, branches, protections, first pipeline | `product/07-operations/git-workflow.md` |
| 0.3 | `agents/04-frontend/frontend-architect.md` | Client skeleton: structure, design system wired in, one empty screen that builds | code |
| 0.4 | `agents/05-backend/` (the specialist for the style chosen in the F3 ADR) | Server skeleton with a health endpoint and the DB connection | code |
| 0.5 | `agents/10-quality/regression-test-engineer.md` | Runners per surface (front **and** back, run separately) + `pipelines/ci-quality.md` and `pipelines/ci-security.md` armed — the first merge runs green | CI |
| 0.6 | Orchestrator | `checklists/definition-of-done.md` §F6 — Skeleton (slice 0) item by item, verified by a clean subagent | record `product/99-records/gates/P6-slice-0-YYYY-MM-DD.md` (`templates/project/GATE.md.template`) + summary in `STATE.md` |

## The principle: vertical slice, not horizontal layer

A **vertical slice** delivers a feature end to end — data → backend → frontend → tests — small
enough to fit through a gate and big enough to be demonstrable. One does not build "the whole
database", then "the whole backend": one builds *one* complete feature, proves it, integrates
it, and only then the next.

- **Why:** horizontal layers only validate at the end (big-bang integration), when fixing is
  expensive; vertical slices give an early live proof and isolate regressions to the slice
  (`knowledge/origin-lessons.md` A4, E1).
- **Slice order:** first the ones that support the risk skeleton (authentication,
  authorization/scoping, the central entity and its state machine); then the ones that depend on
  them. The `prioritizer` (`agents/00-discovery/prioritizer.md`) already gave the value order;
  the Orchestrator orders by technical dependency within it.
- **Independent slices run in parallel** (`core/orchestrator.md` §Parallelism); slices that
  share the same central entity do not.

## Steps (agent → artifact): anatomy of a slice

| Step | Who | Input → Output | Model tier |
| --- | --- | --- | --- |
| 1. Slice plan | Orchestrator | Module spec → self-contained plan (FR/BR covered, files to touch, tests to write, status) delivered in the briefing handoff (`templates/technical/agent-briefing.md.template` §Briefing) and summarized in one line of `STATE.md` §In progress (slice, FR/BR covered, files, status) — this is what the next session picks up | Standard |
| 2. Data | `agents/06-data/data-modeler.md` + `agents/06-data/migration-engineer.md` | Logical model → expand-contract migration + invariants in the DB | Top (migration/invariants) |
| 3. Backend | `agents/05-backend/` (authorization, business rule, contract) | Backend contract → transactional use case + endpoint | Standard (Top if RBAC/state/critical flow) |
| 4. Contract/types | `agents/05-backend/api-designer.md` | Single schema → snapshot (OpenAPI/equivalent) regenerated by command | Economy |
| 5. Frontend | `agents/04-frontend/` (screen, API integration, state) | Wireframe + design system + snapshot → screen with tooltips, filters, error states | Economy (Standard for client logic) |
| 6. Tests | `agents/10-quality/` | Acceptance criteria → unit (rule), integration (real DB), smoke E2E | Economy (Standard for risk logic) |
| 7. Live proof + record | Clean subagent — receives only the artifact/diff, the checklist, and the evidence format, never the conversation (`adapters/claude-code.md` §Independent verification); the Orchestrator validates the return against the `git diff` | Slice → real evidence (format: `knowledge/proven-patterns.md` §Live proof) + `STATE.md` updated | Standard |

**Give the full spec upfront** at each step (`knowledge/origin-lessons.md` A4;
`core/model-routing.md` §Routing rules, rule 6): a self-contained plan cuts round-trip turns
and reduces AI cost.

## Non-negotiable rules during the build

1. **The spec wins.** If while building one finds the spec wrong or incomplete, **stop and
   update the spec first** (with approval, `core/artifact-protocol.md` §H4), then the code.
   Never "fix it in code" against the spec in silence — that creates the second source of truth
   (`knowledge/ai-pitfalls.md` §AR-7).
2. **No scope creep.** The slice delivers what the plan says. "While at it I also redid…" is the
   user's decision, not the agent's initiative (`knowledge/ai-pitfalls.md` §AR-5). Additive within
   the plan proceeds; lateral/destructive asks.
3. **Hard invariants in the DB + guards in the app** (`knowledge/proven-patterns.md` §5): the
   constraint is the last line; the app gives the friendly error. A test inserts the illegal row
   and asserts the violation **by name**.
4. **Authorization, scoping and sensitive-field hiding 100% on the server**
   (`modules/rbac-and-scoping.md`): the client declares, the server confirms; fail-closed;
   out-of-scope → 404.
5. **Reversibility per slice:** migration with a *down* plan
   (`playbooks/expand-contract-db-migration.md`); risky change behind a flag
   (`modules/feature-flags.md`); never drop what is in use in the same step.
6. **SSOT for content and contract:** labels/tooltips/help from the single catalog
   (`modules/single-source-of-content.md`); types and docs derive from the single schema,
   regenerated by command, never by hand (`knowledge/origin-lessons.md` E4).
7. **A slice with LLM functionality** is built by `agents/05-backend/ai-features-specialist.md`
   **after** `product/05-security/ai-security.md` exists: grounding in the single source,
   versioned prompts, runnable evals, fail-closed guardrails, visible costs
   (`modules/ai-observability.md`, `modules/credit-management.md`); Top tier.

## Decision points

The human approvals of F6, consolidated (format of `core/question-engine.md`, in batches per
slice — never one interruption at a time):

- **MVP acceptance (P6b)** — only the user accepts; record it in `STATE.md`.
- **New scope mid-phase** — an unspecified feature goes back to F5 through the question engine;
  it is never implemented on the agent's initiative.
- **Change to the specification** — when code and spec diverge, the spec wins: change the spec
  in the open first (approved by the user) and only then the code.
- **Technical debt taken on** — recording it in `STATE.md` §Debt (owner + payment trigger; this
  is what `loops/L08-technical-debt.md` reads from) is a visible decision, with the user aware of
  the interest.

## Loops it opens

- `loops/L02-failing-tests.md` — while there is a red test, fix the **cause** (never the test,
  except a provably wrong test). Red does not get merged.
- `loops/L04-code-smells.md` — smells above the threshold are improved without changing behavior.
- `loops/L05-inconsistencies.md` — docs↔code↔data divergence is reconciled with the source of
  truth.

## Exit gate (P6 per slice · P6b for the phase)

**P6 (each slice → merge):** `checklists/definition-of-done.md` + `checklists/pre-merge.md` —
green tests (front **and** back, run separately), spec respected, PR review
(`checklists/pr-review.md`), no secrets, reversible, **real live proof** done. Independent
verification: whoever wrote the slice is not who declares it done (`core/quality-gates.md`).

**P6b (F6 → F7):** complete MVP checked against the specification (every MVP FR has traceable
code and tests); regression harness green in the target environment; unresolved technical debt
**recorded** in `STATE.md` §Debt (`loops/L08-technical-debt.md`), not hidden. This is where the
user **accepts the MVP**.

## Recovering from failures and blockers

`core/orchestrator.md` §Recovery. A slice blocked by an external dependency (credentials, an API,
or a third-party contract yet to arrive) → the matching row of that table: build against the
contract with a stub behind a flag, and the slice **does not pass P6** with a live proof over a
stub; a slice whose spec turns out wrong → rule 1 (the spec wins); context compacted mid-slice →
re-read `CLAUDE.md` and `STATE.md` §In progress before continuing.

## Effort profiles

| Profile | What changes |
| --- | --- |
| Prototype | Bigger slices, tests only on risk logic, P6 review by the Orchestrator itself; live proof remains mandatory. |
| Internal product | Full structure; panel review on the critical flows. |
| Commercial product / Platform | Small, frequent slices; real DB parity on every slice touching data (`knowledge/ai-pitfalls.md` §AR-15); AI consumption recorded per slice. |

## Anti-patterns

- ❌ Building by layers (whole DB → whole backend) and integrating at the end → ✅ demonstrable
  vertical slices.
- ❌ Fixing the spec in code without updating the spec → ✅ spec first, with approval.
- ❌ "Tests are green, so it works" → ✅ the real live proof is an irreplaceable gate
  (`knowledge/ai-pitfalls.md` §AR-2).
- ❌ A migration that drops/renames what is in use in the same step → ✅ expand-contract.
- ❌ A giant slice that never closes the gate → ✅ if it does not fit through one P6, split it in
  two.

## Related

- `core/lifecycle.md` — F6 on the overall map.
- `core/quality-gates.md` — P5, P6, P6b in detail.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` · `checklists/pr-review.md`
- `playbooks/expand-contract-db-migration.md` · `pipelines/ci-quality.md`
- `knowledge/proven-patterns.md` — the patterns every slice applies.
- `workflows/W07-quality-and-security.md` — the scrutiny that follows the MVP.
