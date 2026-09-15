# W10 — Feature Evolution (re-enters F2→F8)

> **Trigger:** a new request on a product **already in production** (F9) · **Coordinates:**
> `agents/13-guardians/feature-evolution-agent.md` · **Exit gate:** the gates of the phases
> the slice touches (P2…P8), sized to the risk.

## Objective

Take a new request — a feature, a rule change, one more field — from idea to production by
**re-running F2→F8 in miniature** (`core/lifecycle.md` §rule 4), without repeating the whole
discovery or breaking what already runs. The live product does not stop for every request: each
evolution is a **vertical slice** that crosses only the phases it needs, with rigor proportional
to the risk it carries.

## Trigger and preconditions (entry gate)

- [ ] Product in F9 (`workflows/W09-continuous-operation.md`) — there is a stable base to evolve.
- [ ] Request recorded (not in memory): who asks, what they want, why. The `feature-evolution-agent`
      opens `product/99-records/evolutions/EV-nnn.md` with the raw request.
- [ ] Parent specification (`product/04-specification/`) and `STATE.md` up to date — impact is
      measured against them. If the spec lags behind the code, reconcile first
      (`loops/L05-inconsistencies.md`).

## The principle: proportionality (it is not always all 6 stages)

A small request does **not** go through the six stages with equal weight. Stage 1 (impact) is what
calibrates the rest: it defines how many stages run and at what depth. The calibration rule:

| Size | Example | Stages it runs |
| --- | --- | --- |
| **Trivial** | change a label, adjust an alert threshold (SSOT, `modules/single-source-of-content.md`) | 1 (impact confirms it is trivial) → 4 (slice) → 6 (release). No ADR, no panel review. |
| **Small** | new optional field on a form; new filter on a list | 1 → 3 (spec delta) → 4 → 5 (review by the Orchestrator itself) → 6. |
| **Medium** | new report type in a SaaS; coupon code in an e-commerce | all 6 stages; partial panel review (the dimensions touched). |
| **Large / structural** | new ingestion source in a data platform; changing the state machine of a critical flow | all 6 + **ADR** (stage 2) + full panel review (stage 5); may require going back to F3 (architecture). |

**The classifier is not the requester:** the `feature-evolution-agent` proposes the size in the
impact report and the Orchestrator confirms it. When in doubt between two sizes, go one up
(`MANIFESTO.md` §9 — maximum scrutiny goes to correctness, authorization, money, personal data and
irreversible flows).

## Steps (stage → agent → artifact)

All trail artifacts live in `product/99-records/evolutions/EV-nnn.md`; the knowledge deltas live
in the canonical trees (`product/01-requirements/`, `product/02-architecture/`,
`product/04-specification/`).

| # | Stage | Agent | Artifact | Depends on |
| --- | --- | --- | --- | --- |
| 1 | **Impact** | `agents/13-guardians/feature-evolution-agent.md` (coordinates) + `agents/12-reviewers/architecture-reviewer.md` (touched boundaries) | `EV-nnn.md` §impact: which **modules/data/flows** it touches, what can break, proposed size | request |
| 2 | **Decision** | Orchestrator + user; `core/decision-engine.md` | verdict (proceed / defer / refuse) in `EV-nnn.md`; **ADR** in `product/02-architecture/` if it changes architecture (`templates/project/ADR-DECISION.md.template`) | 1 |
| 3 | **Specification (mini-W05)** | `agents/01-requirements/business-rules-modeler.md`, `agents/06-data/data-modeler.md`, `agents/05-backend/api-designer.md` — **the slice only** | delta in `product/04-specification/` + traceable requirement in `product/01-requirements/` | 2 |
| 4 | **Implementation (mini-W06)** | `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`, `agents/10-quality/` | code + tests for the **vertical slice** (data→backend→frontend); expand-contract migration if it touches data | 3 |
| 5 | **Proportional review** | panel from `agents/12-reviewers/` **sized to the risk** (stage 1) | reports in `product/99-records/reviews/` + verdict | 4 |
| 6 | **Release** | `agents/07-devops/deployment-strategist.md` via `playbooks/release-and-rollback.md` | release in production + `STATE.md` updated | 5 |

**Miniatures, not shortcuts.** Stage 3 is a `workflows/W05-specification.md` reduced to the slice;
stage 4 is a single-slice `workflows/W06-build.md` (its non-negotiable rules still hold: the spec
wins, invariants in the DB, authz on the server, reversibility per slice). You shrink the
**scope**, never the **rigor** of the gates you cross.

## Decision points (human approval)

The Orchestrator **stops and asks** (`core/orchestrator.md` §Human approval):

- **Stage 2 — is it worth it?** The proceed/defer/refuse decision belongs to the user: it is scope
  and it is money (effort). An agent's "while we're at it" does not become a feature
  (`knowledge/ai-pitfalls.md` §AR-5).
- **Stage 2 — does it reopen a closed decision?** If the request contradicts a closed decision
  (`core/decision-engine.md` §Closed decisions), state **why it is closed** before reopening.
- **Stage 4 — touches personal/sensitive data** in a new way, or requires a destructive
  migration → explicit approval with an item-by-item plan (`core/quality-gates.md`).
- **Stage 6 — production** → human approval always (P8), never delegable.

Questions go in **batches** per stage, never one by one (`core/question-engine.md`).

## Loops it opens

- `loops/L02-failing-tests.md` and `loops/L04-code-smells.md` — inside stage 4 (identical to F6).
- `loops/L05-inconsistencies.md` — if stage 1 reveals the parent spec already diverges from the
  code, reconcile **before** measuring impact against a false baseline.
- `loops/L08-technical-debt.md` — what you decide not to do in this evolution is recorded as debt,
  not hidden (`core/quality-gates.md`).

## Exit gate (verifiable closing condition)

The evolution **closes** when:

- [ ] The slice passed the gates of the phases it touched (P2/P5 if there was a spec delta; **P6**
      per slice — `checklists/definition-of-done.md` + `checklists/pre-merge.md`; P8 on release).
- [ ] Real **live proof** in production: the original request was exercised and observed working
      (`knowledge/ai-pitfalls.md` §AR-2 — "green tests" is not proof).
- [ ] Rollback rehearsed and available (`playbooks/release-and-rollback.md`); risky change behind
      a switchable flag (`modules/feature-flags.md`).
- [ ] `EV-nnn.md` closed (what was done, what was left behind and why) and `STATE.md` updated.

**Who verifies:** the Orchestrator (formal gates) + the stage 5 panel (substance). **Who approves
the release:** the user.

## Failure recovery

| Situation | Response |
| --- | --- |
| Stage 1 reveals a much bigger impact than the request suggested (structural) | Reclassify as **large**; if it touches architecture, return to F3 (`workflows/W03-architecture.md`) with an ADR — going back is normal (`core/lifecycle.md` §rule 2). |
| While building (stage 4) the slice's spec turns out to be wrong | Stop, fix the spec first (stage 3), **then** the code — never fix against the spec in silence (`knowledge/ai-pitfalls.md` §AR-7). |
| Release (stage 6) degrades production | Revert first (flag/rollback), diagnose later: open `workflows/W11-incident-response.md`. |
| Requests piling up faster than they ship | Do not parallelize slices that share the central entity; prioritize with the user (value × effort × risk). |

## Effort profiles

| Profile | How it changes |
| --- | --- |
| **Prototype** | Almost everything is "trivial/small"; stage 5 by the Orchestrator itself; live proof still mandatory. |
| **Internal product** | Mediums get a partial panel; ADR only for structural. |
| **Commercial product / Platform** | Structurals always with ADR + full panel; AI consumption tracked per slice; adversarial audit if the evolution touches a critical flow. |

## Related

- `agents/13-guardians/feature-evolution-agent.md` — the coordinator of this re-entry.
- `core/lifecycle.md` — rule 4 (F9 → re-entry into F2→F8 in miniature).
- `workflows/W05-specification.md` · `workflows/W06-build.md` — the phases that get miniaturized.
- `workflows/W08-launch.md` · `playbooks/release-and-rollback.md` — the slice's release.
- `workflows/W11-incident-response.md` — when a release goes wrong.
- `core/decision-engine.md` — the stage 2 decision and closed decisions.
