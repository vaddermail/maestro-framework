# W12 — Global Review (on demand)

> **Trigger:** the user requests a full multidisciplinary review · **Coordinates:** the
> Orchestrator assembles the panel from `agents/12-reviewers/` · **Closing condition:** the
> consolidated plan delivered and the user has decided what gets fixed now vs backlog.

## Objective

Give the user an **independent, multidisciplinary snapshot** of the state of a scope of their
choosing — the whole product, a module, a release, an inherited repository — and a **prioritized
plan** of fixes for them to decide on. Unlike every phase, W12 **is not a gate** and **blocks**
nothing by itself: it is diagnosis on demand. What to do with the findings is the user's call.

### W12 vs W07 — the difference that matters

| | `workflows/W07-quality-and-security.md` | `workflows/W12-global-review.md` (this one) |
| --- | --- | --- |
| **Nature** | **Mandatory** pre-launch gate (P7) | Review **summonable** at any time |
| **When** | Always, before F8 | At the user's request |
| **Scope** | The MVP / the release to launch | Any scope the user defines |
| **Effect of a blocker** | Prevents the launch | Becomes a prioritized item; the user decides |

W07 **uses** this workflow as its panel mechanics; W12 can run with no launch in sight at all
(e.g. a quarterly review of a SaaS, due diligence before an acquisition, an audit of a legacy
module before touching it).

## Trigger and preconditions

- [ ] Explicit request from the user with a **defined scope**. If it arrives vague ("review the
      project"), the Orchestrator delimits it in a batch (`core/question-engine.md`): which
      modules, what depth, with or without an adversarial audit.
- [ ] The scope's artifacts exist and are accessible (code, specs in `product/04-specification/`,
      ADRs in `product/02-architecture/`). A reviewer without an artifact **declares it** as
      "out of scope", never invents (`agents/12-reviewers/README.md` §Report format).

## Steps (agent → artifact)

All reviewers' reports live in `product/99-records/reviews/RG-nnn/`; the consolidated plan in
`product/99-records/reviews/RG-nnn/consolidated-plan.md`.

| # | Step | Agent | Artifact | Depends on |
| --- | --- | --- | --- | --- |
| 1 | **Delimit the scope** | Orchestrator + user | `RG-nnn/scope.md`: what is reviewed, depth, whether it includes an adversarial audit | request |
| 2 | **Launch the full panel, in parallel and blind** | the 9 reviewers in `agents/12-reviewers/` (architecture, frontend, backend, ux, devops, performance, security, documentation, tests) | one report per reviewer (`templates/technical/review-report.md.template`) | 1 |
| 3 | **Adversarial audit** (if requested in step 1) | `playbooks/adversarial-audit.md` | adversarial report attached | 1 |
| 4 | **Consolidate** | `agents/12-reviewers/review-consolidator.md` | `consolidated-plan.md`: findings merged, no duplicates or contradictions, ordered by real risk | 2, 3 |
| 5 | **Present and decide** | Orchestrator → user | decision recorded in `STATE.md`: **fix-now** vs **backlog**, per item | 4 |

**Panel = independence + blindness** (`agents/12-reviewers/README.md`): every reviewer receives
the same artifacts and the same scope but **does not read the others' reports** while working —
two separate opinions converging is a strong signal; contamination destroys that signal. One
dimension per reviewer; the consolidator is the **only one** who reads everything, and only in
step 4. The Orchestrator routes each reviewer's model per task (`core/model-routing.md`), not the
top model across the whole queue.

## Decision points (human approval)

- **Step 1 — the scope and the depth** belong to the user (they set the cost of the review).
- **Step 5 — the core of W12:** for **each** finding, the user decides **fix now** or **send to
  the backlog**. The agent does not decide that alone — the technical prioritization
  (`consolidator`) informs; the business decision belongs to the user (`core/orchestrator.md`
  §Human approval). Findings involving personal data, money or irreversible flows get an explicit
  "fix now" recommendation (`MANIFESTO.md` §9), but the final word is the user's.

## Loops it opens

The findings the user sends to **fix now** feed the normal loops, per dimension:

- `loops/L02-failing-tests.md` (test findings), `loops/L03-security-issues.md` (security, by
  severity), `loops/L04-code-smells.md` (quality), `loops/L05-inconsistencies.md`
  (docs↔code↔data).
- What goes to the **backlog** enters `loops/L08-technical-debt.md` — traceable, with an owner and
  a deadline, never forgotten in a report nobody reopens.

## Closing condition (not a gate)

W12 **finishes** — it does not "approve" — when:

- [ ] Every reviewer in scope delivered a report in the common template (or explicitly declared
      what they could not review and why — absolute honesty, `knowledge/permanent-rules.md` §2).
- [ ] The `review-consolidator` produced **one** prioritized plan, with no duplicates or
      contradictions.
- [ ] The user triaged every item (fix-now / backlog) and the decision landed in `STATE.md`.

If W12 was summoned **as part of a launch** (from W07), then yes, its outcome feeds gate P7 — but
that binding belongs to W07, not to this workflow.

## Failure recovery

| Situation | Response |
| --- | --- |
| Two reviewers contradict each other | The `consolidator` does not pick a side in silence: it exposes the contradiction in the plan and raises it to the user, or requests re-analysis with the conflict made explicit (`core/orchestrator.md` §Recovery and exceptions). |
| A reviewer lacks the artifact they need | They declare it "out of scope"; the Orchestrator schedules the missing artifact or notes the gap in the plan. No verdict is invented about what was not seen. |
| Too many findings to triage at once | The consolidator groups by severity and by module; the user triages in batches (blockers first). |
| The scope turned out larger than requested | Renegotiate the scope with the user (step 1) before spending the whole panel — the depth is their cost decision. |

## Effort profiles

| Profile | How it changes |
| --- | --- |
| **Prototype** | Minimal panel (architecture + security + the reviewer of the dimension at hand); no adversarial audit. |
| **Internal product** | Full panel on the risky modules; adversarial optional. |
| **Commercial product / Platform** | Full panel + `playbooks/adversarial-audit.md` as standard; W12 as a scheduled **periodic review**, not only on ad-hoc request. |

## Related

- `agents/12-reviewers/README.md` — the panel, the blindness rule, the report format.
- `agents/12-reviewers/review-consolidator.md` — who merges the reports into a single plan.
- `workflows/W07-quality-and-security.md` — the mandatory gate that uses this mechanics.
- `playbooks/adversarial-audit.md` — maximum scrutiny, optional here.
- `templates/technical/review-report.md.template` — the reviewers' common template.
- `loops/L08-technical-debt.md` — where whatever stays in the backlog goes.
