# 12 — Reviewers

The product's **independent eyes**. This category builds nothing: it examines what others have
built, each reviewer along **one dimension**, and returns a **report of verifiable findings**. The
dominant phase is **F7** (`workflows/W07-quality-and-security.md`), the pre-launch gate; the same
reviewers are reconvened at every milestone and in the global review on request
(`workflows/W12-global-review.md`). The principle that justifies them is a concrete AI pitfall:
**whoever produces never validates their own work** (`knowledge/ai-pitfalls.md` §20) and **a
single perspective is not enough** (§21).

## What a review panel is

A panel is **several independent, blind reviews of the same thing**. Independent: each reviewer
receives the same artifacts and the same scope, but **does not read the others' reports** while
working — convergence of two separate opinions is a strong signal; contamination by someone
else's opinion destroys that signal. One dimension per reviewer avoids the "omniscient reviewer"
who passes over everything with little depth in each thing (`MANIFESTO.md` §1). The
`agents/12-reviewers/review-consolidator.md` merges the reports **afterwards** into a single
prioritized plan, without duplicates or contradictions — it is the only agent in the category
that reads all the reports.

## Agents in this category

| Agent | One line |
| --- | --- |
| `agents/12-reviewers/architecture-reviewer.md` | Adherence to the decided architecture (ADRs) and integrity of module boundaries. |
| `agents/12-reviewers/frontend-reviewer.md` | Client code/UX: content SSOT, tokens, screen states, error handling. |
| `agents/12-reviewers/backend-reviewer.md` | Server: authorization vs scoping, transactions, invariants, adherence to the API contract. |
| `agents/12-reviewers/ux-reviewer.md` | Real flows walked end to end against personas and use cases. |
| `agents/12-reviewers/devops-reviewer.md` | Pipelines, deploy/rollback, secrets out of Git, risk flags. |
| `agents/12-reviewers/performance-reviewer.md` | Performance budgets, queries, caching. |
| `agents/12-reviewers/security-reviewer.md` | Threat model, OWASP, least privilege. |
| `agents/12-reviewers/documentation-reviewer.md` | Docs↔code sync and help completeness. |
| `agents/12-reviewers/test-reviewer.md` | The substance of the tests, not just their existence. |
| `agents/12-reviewers/review-consolidator.md` | Merges the reports into a single prioritized plan, without duplicates or contradictions. |

## Report format (common to all)

All reviewers write in the **same mold** — `templates/technical/review-report.md.template` — so
the consolidator can merge them without translation. The report has:

1. **Header** — reviewer (dimension), scope reviewed (which slice/commits/artifacts), date, model
   and effort used (`core/model-routing.md`). Traceability of what was looked at.
2. **Global verdict** — `pass` · `pass-with-caveats` · `block`. A single blocker is enough to
   block; the verdict ties into the F7 gate (`core/quality-gates.md`).
3. **Findings, ordered by severity** — each with: `id`, severity (**blocker · major · minor ·
   nit**), location (`file:line` or artifact), the defect in one sentence, the **concrete failure
   scenario** (inputs/state → wrong result — never "looks fragile"), the recommendation and the
   **confidence** (`confirmed` if reproduced, `plausible` if by inspection).
4. **What was verified and passed** — to give confidence, not just the negative; and so the
   consolidator knows what is already covered.
5. **Out of scope / not verifiable** — absolute honesty (`knowledge/permanent-rules.md`
   §2): what this reviewer did not look at and why (missing artifact, another reviewer's
   dimension).

Cross-cutting rule: one **confirmed** finding is worth more than ten suspicions; order by real
risk, not by number of findings. Findings about correctness, authorization, money, personal data
and irreversible flows get maximum scrutiny (`MANIFESTO.md` §9).

## How the Orchestrator assembles the panel

`workflows/W07-quality-and-security.md` (F7) launches the reviewers **in parallel** over the same
slice/release, each with its own scope and the artifacts it needs (the Orchestrator —
`core/orchestrator.md` — resolves the inputs from the **Inputs** sections of each agent spec). No
reviewer is the author of what it reviews. Once the reviews are done, the `review-consolidator`
produces the single plan; blocking findings go back to the build team and, when cross-cutting,
feed the loops (`loops/L02-failing-tests.md`, `loops/L03-security-issues.md`,
`loops/L04-code-smells.md`, `loops/L05-inconsistencies.md`). The review closes when the F7 gate
passes; for extensive, adversarial reviews, the panel scales up to
`playbooks/adversarial-audit.md`.

## Related

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `templates/technical/review-report.md.template` · `checklists/pr-review.md` · `checklists/pre-merge.md`
- `workflows/W07-quality-and-security.md` · `workflows/W12-global-review.md` · `core/quality-gates.md`
- `playbooks/adversarial-audit.md` · `knowledge/ai-pitfalls.md`
