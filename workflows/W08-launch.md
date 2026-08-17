# W08 — Launch (Phase F8)

Put the product in production **with a net**: infra provisioned as code, pipelines running
green, backups verified, rollback rehearsed and monitoring on — so that go-live is a
**reversible, observable event**, not a leap of faith. It is the phase where
`knowledge/permanent-rules.md` §Reversible by default weighs the most — nothing goes to production
without a way back and a prior backup.

> **Phase:** F8 · **Entry gate:** P7 (quality & security clean; residual risk signed)
> · **Exit gate:** P8 (production with rollback rehearsed — **human approval, always**)
> · **Previous workflow:** `workflows/W07-quality-and-security.md`
> · **next:** `workflows/W09-continuous-operation.md`

## Objective

Take the verified MVP to production in a controlled, documented way: infra as code, automated
delivery, operations ready to receive phase F9. At the end, the product is **live, monitored and
reversible**, and the team has runbooks to operate it.

## Preconditions (entry gate)

- [ ] P7 passed: consolidated plan clean, `checklists/pre-production-security.md` complete,
      `product/05-security/residual-risk.md` signed.
- [ ] F3 ADRs pinned, including the **hosting decision**
      (`agents/08-infrastructure/hosting-arbiter.md`) and the stack on stable versions
      (`product/02-architecture/stack.md`).
- [ ] Quality and security pipelines already green since F6 (`pipelines/ci-quality.md`,
      `pipelines/ci-security.md`).
- [ ] Production secrets **out of Git**, in a vault or dedicated store
      (`playbooks/secrets-management.md`).

## Steps (agent → artifact)

Infra first, then delivery, then operations, and only then go-live. Operations artifacts live in
`product/07-operations/`; infra as code lives in the repository (`infra/`).

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | `agents/08-infrastructure/` (the specialist for the chosen cloud/on-prem: `aws-specialist.md` / `azure-specialist.md` / `hetzner-specialist.md` / `on-premises-specialist.md` …) + `agents/07-devops/terraform-specialist.md` | infra as code in `infra/`; network, TLS and storage (`network-architect.md`, `tls-ssl-specialist.md`, `storage-specialist.md`) | hosting decision (F3) |
| 2 | `agents/06-data/backup-specialist.md` + `agents/08-infrastructure/infra-backup-specialist.md` + `agents/06-data/disaster-recovery-planner.md` | `product/07-operations/dr-plan.md` (RTO/RPO) + backups configured **and restore tested** | 1 |
| 3 | `agents/07-devops/` (`github-actions-specialist.md` / `gitlab-ci-specialist.md` / `azure-devops-specialist.md`) | `pipelines/cd-delivery.md` instantiated: environments, approvals, blue-green/canary, automatic rollback | 1 |
| 4 | `agents/05-backend/observability-architect.md` (+ `metrics-specialist.md`, `logging-specialist.md`) | `product/07-operations/observability.md` + `slos.md`; actionable alerts wired | 1 |
| 5 | `agents/11-documentation/documentation-architect.md` + `technical-writer.md` | `product/07-operations/runbooks/` (mold `templates/technical/runbook.md.template`) | 2–4 |
| 6 | `agents/07-devops/deployment-strategist.md` conducts the **go-live**: `checklists/go-live.md` + `playbooks/release-and-rollback.md` | release in production + record in `STATE.md` | 1–5 |

**Golden rule of step 6 (`playbooks/release-and-rollback.md`,
`agents/07-devops/deployment-strategist.md`):** **backup first**, reversal state ready,
**rollback rehearsed** (not just documented — executed in staging), and a **hard block against
the wrong infra** — the pipeline refuses to apply if the target does not match, so production is
never launched onto the wrong environment. Any DB migration accompanying the release is
**expand-contract** (`playbooks/expand-contract-db-migration.md`): additive first, never
dropping what is in use in the same step.

> **Scale to the profile:** in a prototype there may be no real production (the "launch" is
> publishing the static file) and step 3 shrinks to a documented manual deploy; on an enterprise
> platform there is blue-green/canary, **exercised** DR and high availability
> (`agents/08-infrastructure/high-availability-architect.md`).

## Decision points

- **Mandatory human approval (P8) — always, never delegable to agents:** going to production is
  the user's decision (`core/orchestrator.md` §Human approval, `core/quality-gates.md`).
  The Orchestrator prepares everything and **stops** at production's door.
- **Spending money / taking on commitments:** provisioning paid infra, contracting services or
  domains is the user's decision — the cost is presented in plain language before applying.
- **Release window and strategy:** blue-green vs canary vs big-bang, and the lowest-impact
  window, go up to the user (`core/decision-engine.md`) when they affect availability.

Multi-domain example: an **e-commerce** picks canary at 5% of traffic in an off-peak window and
a feature-flag kill-switch for the new checkout; a **B2B SaaS** does blue-green with an
expand-contract migration so there is no per-tenant downtime; an **internal app** accepts an
announced maintenance window and a simple deploy, as long as backup and rollback are ready.

## Loops it opens

- `loops/L03-security-issues.md` — if a last-minute scan (headers, TLS, secrets) flags
  something, it is resolved by severity **before** go-live; no launching with an open security
  blocker.
- `loops/L02-failing-tests.md` — the post-deploy smoke test must turn green; red triggers
  rollback, not "we'll look tomorrow".

## Exit gate (P8)

`core/quality-gates.md`:

- [ ] `checklists/go-live.md` **complete**: backups verified, **rollback rehearsed**, monitoring
      and alerts active, owners reachable, runbooks written.
- [ ] Infra as code applied and reproducible; secrets injected at runtime, never in the
      repository.
- [ ] **Real live smoke test** green in production (`knowledge/ai-pitfalls.md` §2 — tested ≠
      "works"; attach the output).
- [ ] `product/07-operations/` complete (runbooks, SLOs, observability, DR plan).
- [ ] **Explicit human approval for production** recorded in `STATE.md`.

**Who verifies:** the Orchestrator (completeness) + the pipeline (green). **Who approves:** the
user, **always**. With P8 closed, the product enters `workflows/W09-continuous-operation.md`
(F9) and the guardians activate.

## Effort profiles

| Profile | What changes |
| --- | --- |
| **Prototype** | No real production, or a documented manual deploy; backup/rollback trivial but present; guardians off until a decision to continue. |
| **Internal product** | Simple delivery pipeline; daily backups with one tested restore; essential monitoring and basic alerts. |
| **Commercial product** | Blue-green/canary; automatic rollback; formal SLOs; on-call defined before go-live. |
| **Enterprise platform** | + multi-zone high availability, **exercised DR** (not just planned), IaC reviewed in PR, environment approvals in the pipeline. |

## Anti-patterns

- ❌ Deploy without backup or rollback ("we'll see later") → ✅ backup first, reversal rehearsed.
- ❌ Secrets in the repository or in the logs → ✅ vault + runtime injection
  (`playbooks/secrets-management.md`).
- ❌ A migration that drops/renames what is in use in the same step → ✅ expand-contract.
- ❌ "Deploy green in the pipeline, so it's fine" without a live smoke → ✅ real proof in
  production is the gate.
- ❌ An agent declaring production on its own → ✅ explicit human approval, always.

## Related

- `agents/08-infrastructure/README.md` — where it runs; the hosting decision.
- `agents/07-devops/README.md` — from commit to production; deploy/rollback/secrets.
- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/ci-security.md` ·
  `pipelines/cd-delivery.md`
- `checklists/go-live.md` · `playbooks/release-and-rollback.md` ·
  `playbooks/expand-contract-db-migration.md`
- `core/quality-gates.md` — P8 in detail.
- `workflows/W07-quality-and-security.md` (where it comes from) ·
  `workflows/W09-continuous-operation.md` (where it goes).
