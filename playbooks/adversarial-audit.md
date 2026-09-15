# Playbook — Adversarial Audit

An **extensive, adversarial, multidisciplinary** review of the product, with **independent
verification of every finding** before accepting it. It operationalizes
`knowledge/permanent-rules.md` §7 and the pitfalls `knowledge/ai-pitfalls.md` §AR-20
(self-validation) and §21 (a single perspective is not enough). It is the escalation of the normal
review panel (`agents/12-reviewers/README.md`): more lenses, a mandate to **refute**, and a
verification filter that only lets into the report what has been reproduced.

**When it runs:** at important **milestones**, in **pre-production** (before go-live,
`workflows/W07-quality-and-security.md`), in the global review on request
(`workflows/W12-global-review.md`), and whenever the user asks for it. **Who:** the Orchestrator
(`core/orchestrator.md`) assembles the panel; the auditors are independent agents, **none an
author of what it audits**.

## What sets it apart from the normal F7 panel

| Normal panel (F7) | Adversarial audit |
| --- | --- |
| Each reviewer looks for what may be wrong in **their dimension** | Each auditor has an **explicit mandate to refute** — the null hypothesis is "this is wrong" |
| A finding plausible by inspection may enter the report | A finding **not reproduced does not enter** — independent verification is the gate |
| Convened for every slice/release | Reserved for milestones, pre-production and requests (it is expensive by design) |
| Consolidation merges reports | Consolidation merges **and** re-verifies the blockers before promoting them |

## Preconditions

- [ ] Scope frozen: which slice/release/commits are audited, with the artifacts available
      (`core/artifact-protocol.md`).
- [ ] A real live-proof environment available (not just tests — `knowledge/ai-pitfalls.md` §AR-2,
      §18).
- [ ] Model tier chosen per lens (`core/model-routing.md`); the hardest adversarial
      verification/judgment justifies the top tier.

## Steps

### 1. Fix the scope and the lenses
**Do:** define the exact scope and the **lenses** — at minimum: **correctness**, **security**,
**data integrity**, **silent failures**, **UX**, **tests** (add performance, architecture, docs
according to risk). One lens per auditor.
**Verify:** each lens has an assigned auditor and the artifacts it needs; no lens critical to this
milestone was left without an owner.
**If it fails:** if an artifact is missing for a lens, record it as "not verifiable" (absolute
honesty), do not let the auditor **assume** (`knowledge/ai-pitfalls.md` §AR-3).

### 2. Launch independent auditors, blind, one per lens
**Do:** launch the auditors **in parallel**, each with the same scope but **without reading the
others' reports** (the convergence of two separate opinions is a strong signal; contamination
destroys it — `agents/12-reviewers/README.md`). Mandate to each: **find what is wrong, not
confirm that it is right.**
**Verify:** no auditor is an author of what it audits; none received another's report while
working.
**If it fails:** if only one perspective is available, that is **not** an adversarial audit — it is
a simple review; call it that (`knowledge/ai-pitfalls.md` §AR-21).

### 3. Every finding with a concrete failure scenario
**Do:** each auditor writes in the common mold (`templates/technical/review-report.md.template`):
`id`, severity (**blocker · major · minor · nit**), location (`file:line`/artifact), the defect in
one sentence, the **concrete failure scenario** (inputs/state → wrong result), the recommendation
and the **confidence** (`confirmed` if reproduced, `plausible` if by inspection).
**Verify:** no finding is vague ("looks fragile") — each one says **how** it fails, with inputs.
**If it fails:** a finding without a concrete scenario goes back to the auditor; it does not move
on to verification without the inputs that reproduce it.

### 4. Independent verification of every finding (the gate)
**Do:** for each finding, **a verifier who is not the finding's author** tries to reproduce it from
the concrete scenario. Finding reproduced → `confirmed`. Not reproduced → it stays **out of the
report** (or as a lead to investigate, never as a conclusion).
**Verify:** every finding in the final report is `confirmed` by independent reproduction; findings
about correctness, authorization, money, personal data and irreversible flows received the
utmost scrutiny (`MANIFESTO.md` §9).
**If it fails:** **an unverified finding does not enter the report** — it is this playbook's
central rule. Reporting suspicions as facts is the same failure as the self-validation the audit
exists to prevent.

### 5. Consolidate into a single prioritized plan
**Do:** the `agents/12-reviewers/review-consolidator.md` merges the reports into a single plan,
without duplicates or contradictions, ordered by **real risk** (one `confirmed` is worth more than
ten suspicions), not by number of findings. Re-verify the blockers before promoting them.
**Verify:** the plan has no findings repeated across lenses nor recommendations that contradict
each other; each blocker links to the quality gate (`core/quality-gates.md`).
**If it fails:** contradictions between lenses are resolved by re-verifying, not by picking the
most convenient one.

### 6. Route and close
**Do:** the blockers go back to the build through their loops (`loops/L02-failing-tests.md`,
`loops/L03-security-issues.md`, `loops/L04-code-smells.md`, `loops/L05-inconsistencies.md`); the
audit closes when the F7 gate passes (`core/quality-gates.md`). For security, the panel brings in
`agents/09-security/pentester.md`.
**Verify:** each blocker has a loop/owner; the overall verdict (`pass` · `pass-with-reservations` ·
`block`) is recorded — a single blocker is enough to block.
**If it fails:** if a blocker has neither owner nor loop, the audit did **not** close; do not
go live with unresolved blockers.

## Rollback

The audit is **non-destructive by nature** — it only reads and reports, it does not change the
product; there is nothing to revert in the act of auditing. The **fixes** it triggers follow the
normal reversibility (branch, green PR, flags/kill-switch for risky changes —
`knowledge/permanent-rules.md` §3). The convergence of **two** independent audits is high
confidence; even that is verified again before an irreversible go-live.

## Related

- `agents/12-reviewers/README.md` — the review panel this audit escalates.
- `agents/12-reviewers/review-consolidator.md` — the consolidation into a single plan.
- `knowledge/ai-pitfalls.md` — §20 (self-validation), §21 (a single perspective).
- `knowledge/permanent-rules.md` §7 — verification and audit with maximum breadth.
- `workflows/W07-quality-and-security.md` · `workflows/W12-global-review.md` ·
  `core/quality-gates.md`
- `templates/technical/review-report.md.template` · `agents/09-security/pentester.md`
- `loops/L02-failing-tests.md` · `loops/L03-security-issues.md` · `loops/L05-inconsistencies.md`
