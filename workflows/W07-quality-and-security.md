# W07 — Quality & Security (Phase F7)

The independent scrutiny between "MVP accepted" and "the real world": a **panel of reviewers**
that looks at the product across several dimensions at once, an **adversarial audit** that tries
to break it on purpose, and a **pre-production security gate** with an authorized pentest.
Nothing here builds — everything here **verifies**, and the principle behind the phase is a
concrete AI pitfall: **whoever produces never validates their own work** and **a single
perspective is not enough** (`knowledge/ai-pitfalls.md` §AR-20/§AR-21).

> **Phase:** F7 · **Entry gate:** P6b (MVP accepted vs spec; regression harness green)
> · **Exit gate:** P7 (zero open critical/high findings; residual risk signed)
> · **Previous workflow:** `workflows/W06-build.md` · **next:** `workflows/W08-launch.md`
> · **Also convened by:** `workflows/W12-global-review.md` (same mechanics, global scope).

## Objective

Give the user a grounded decision — **launch or not?** — resting on independent evidence, not on
the word of whoever built it. F7 produces a **consolidated fix plan** and a **signed residual
risk record**; it leaves clean or it does not leave.

## Preconditions (entry gate)

- [ ] P6b passed: complete MVP checked against `product/04-specification/`, every MVP FR with
      traceable code and tests, regression harness green in the target environment.
- [ ] `product/05-security/threat-model.md` (from F5) exists and is `approved` — it gives the
      attack map to the panel and the pentester.
- [ ] Known technical debt **recorded** (`loops/L08-technical-debt.md`), not hidden.
- [ ] Reproducible build in an environment equivalent to production (otherwise what does the
      pentest test?).

If anything is missing, **F7 does not open** — return it to the build (`core/lifecycle.md`
rule 2).

## Steps (agent → artifact)

Three blocks: the panel runs **in parallel and blind**; the audit and security run over the same
base; consolidation merges everything. All reports live in `product/99-records/`.

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | Panel `agents/12-reviewers/` (architecture, backend, frontend, ux, devops, performance, security, documentation, tests) | one report per reviewer in `product/99-records/reviews/<dimension>-YYYY-MM-DD.md` (mold `templates/technical/review-report.md.template`) | MVP + specs |
| 2 | `agents/09-security/security-coordinator.md` (coordinates OWASP, ASVS, least-privilege, headers, TLS, exposed secrets, dependencies, containers, infra, AI security) | `checklists/pre-production-security.md` filled in + findings in `product/05-security/` | threat-model |
| 3 | `agents/09-security/pentester.md` + `agents/09-security/ai-security-specialist.md` (runs the adversarial LLM plan — direct and indirect prompt injection, excessive agency — when `product/05-security/ai-security.md` exists) | authorized intrusion report (scope + exploitation proofs) in `product/99-records/audits/pentest-YYYY-MM-DD.md` | production-like build |
| 4 | `playbooks/adversarial-audit.md` (multidisciplinary, independent verification of every conclusion) | `product/99-records/audits/adversarial-YYYY-MM-DD.md` | 1–3 |
| 5 | `agents/12-reviewers/review-consolidator.md` | prioritized **consolidated plan**, without duplicates or contradictions, in `product/99-records/reviews/consolidated-plan-YYYY-MM-DD.md` | 1–4 |

**Blind panel (`agents/12-reviewers/README.md`):** each reviewer receives the same artifacts and
the same scope but **does not read the others' reports** — the convergence of two separate
opinions is a strong signal; contamination destroys it. The `review-consolidator` is the
**only** one who reads everything, and only **after** everyone has written. The
`security-coordinator` holds a cross-cutting seat (`core/lifecycle.md` §5): security is not a
step, it is a dimension present in all of them.

> **Scale to the profile:** in a prototype, the panel collapses to the minimum (security +
> architecture) and the Orchestrator consolidates; on an enterprise platform the full panel
> runs, ASVS level 2+ and the adversarial audit is mandatory before go-live
> (`core/orchestrator.md` §Effort profiles).

## Decision points

- **Severity → destination.** Each finding in the consolidated plan has a severity (**blocker ·
  major · minor · nit**). **Blockers and majors go back to the build** (`workflows/W06-build.md`)
  through the right loops; minors/nits may become recorded debt if the user accepts.
- **Mandatory human approval (P7):** the **residual risk** is the user's decision — findings one
  decides **not** to fix go to `product/05-security/residual-risk.md`, **signed** by the user,
  with the why and the risk taken on (`core/orchestrator.md` §Human approval). The agent
  recommends; it never accepts risk on the user's behalf.
- **Criterion waiver** (a checklist item that fails but one decides to proceed anyway) belongs
  to the user and is recorded (`core/quality-gates.md`) — never an Orchestrator shortcut.

Multi-domain example: in a **B2B SaaS**, the backend-reviewer confirms that a tenant A user
cannot see tenant B data (out-of-scope → 404); in an **e-commerce**, the pentester tries to
forge the price in the cart and the security-coordinator verifies that the total is always
recalculated on the server; in an **internal app**, the ux-reviewer walks the real offboarding
and confirms it releases **all** of the person's resources, not just the first.

## Loops it opens

- `loops/L03-security-issues.md` — while a security problem is open, it is resolved by severity;
  fed by the coordinator, the pentester and the security-reviewer.
- `loops/L02-failing-tests.md` — regressions found in the scrutiny are fixed at the cause, never
  in the test. F7 does not close red.
- `loops/L04-code-smells.md` — smells above the threshold flagged by the reviewers are improved
  without changing behavior.
- `loops/L05-inconsistencies.md` — docs↔code↔data divergence detected by the panel is reconciled
  with the source of truth (the spec wins).
- `loops/L07-cves.md` — CVEs in dependencies raised by the supply-chain analysis enter triage.

Anti-loop safeguard (`loops/README.md`): three iterations without progress stop the loop and
raise it to the user with a diagnosis — no insisting blindly.

## Exit gate (P7)

`core/quality-gates.md`:

- [ ] **Zero unresolved critical/high findings (blockers/majors)** in the consolidated plan —
      the resolved ones with proof of fix, the accepted ones signed as residual risk.
- [ ] `checklists/pre-production-security.md` **complete** (headers, TLS, secrets out of Git,
      SAST/DAST/dependency/container scan, least privilege).
- [ ] Pentest with no critical exploitation open; the pentester's findings addressed or accepted.
- [ ] Consolidated plan **clean** and `product/05-security/residual-risk.md` **signed by the
      user**.

**Who verifies:** the `review-consolidator` (substance) + the Orchestrator (checklist
completeness). **Who approves:** the user (residual risk). With P7 closed,
`workflows/W08-launch.md` starts. While a blocker remains, F7 **does not pass** — the product
goes back to the build and re-enters the panel.

## Effort profiles

| Profile | F7 depth |
| --- | --- |
| **Prototype** | Minimal panel (security + architecture), consolidation by the Orchestrator, no formal pentest; the security checklist still runs on the essentials. |
| **Internal product** | Panel on the critical flows; automated scans; light pentest; residual risk signed. |
| **Commercial product** | Full panel; **mandatory adversarial audit** before go-live; full pentest; guardians already prepared for F9. |
| **Enterprise platform** | + ASVS level 2+, independent verification of every conclusion, periodic global review (`workflows/W12-global-review.md`). |

## Anti-patterns

- ❌ An omniscient reviewer skimming everything with little depth → ✅ one dimension per
  reviewer.
- ❌ A panel that reads each other's opinions → ✅ blind reviews, consolidation afterwards.
- ❌ "No critical findings, therefore secure" without pentest or audit → ✅ try to break it on
  purpose.
- ❌ An agent "accepting" residual risk → ✅ only the user signs what stays unfixed.

## Related

- `agents/12-reviewers/README.md` — the panel, the report format and the consolidation.
- `agents/09-security/README.md` — the security coverage (design → build → verify → operate).
- `playbooks/adversarial-audit.md` — this phase's maximum scrutiny.
- `checklists/pre-production-security.md` · `checklists/pr-review.md` · `checklists/pre-merge.md`
- `core/quality-gates.md` — P7 in detail.
- `workflows/W06-build.md` (where it comes from) · `workflows/W08-launch.md` (where it goes) ·
  `workflows/W12-global-review.md`.
