# Pipelines — reference automation

A **pipeline** is the sequence of automated stages that validates and delivers code, from commit to
production. This folder describes the framework's **three reference pipelines** in a **CI-vendor
agnostic** way (GitHub Actions, GitLab CI, Azure DevOps, …): *what* runs, when it runs and what
blocks. The concrete per-vendor adapter lives in `agents/07-devops/` (e.g.
`agents/07-devops/github-actions-specialist.md`), which translates this agnostic contract into real
workflows.

## Principles

- **Pipeline as code, versioned in the repository.** Reviewed by PR like any other code; never
  configured only through the CI vendor's UI, where there is no history and no review.
- **CI split per app.** Frontend and backend run in separate jobs/stages; **both must be green**
  before merge — a red never hides behind a green on the other side
  (`knowledge/permanent-rules.md` §7).
- **Nothing merges without green.** Required checks block the merge; there is no silent *bypass* and
  no `continue-on-error` painting failures green (`core/quality-gates.md`).
- **Secrets injected at runtime, never hardcoded.** They live in the vendor's *secrets store*/OIDC,
  never in plain text in the pipeline file or in logs (`knowledge/permanent-rules.md` §5).
- **Pipeline times kept under watch.** A slow pipeline is a pipeline the team learns to ignore or to
  work around; correct caching (keyed on the lockfile) and parallelization are part of the contract,
  not optional optimization.

## The three pipelines

| Pipeline | What it guarantees |
| --- | --- |
| `pipelines/ci-quality.md` | Lint, typecheck, unit/integration tests (frontend and backend separated), build and detection of generated-contract *drift* — on every push/PR. |
| `pipelines/ci-security.md` | SAST, *secrets scan* (diff and history), *dependency scan*, *container scan*, generated SBOM, scheduled DAST against a test environment. |
| `pipelines/cd-delivery.md` | Promotion across environments with human approval, backup before production, blue-green/canary strategy and automatic *rollback*. |

The quality and security pipelines run **in parallel**, from the same commit/PR. The delivery one
only starts with **both green** — it never promotes an artifact that has not passed both
(`core/quality-gates.md`).

## Related

- `agents/07-devops/github-actions-specialist.md` · `agents/07-devops/azure-devops-specialist.md` · `agents/07-devops/gitlab-ci-specialist.md`
- `agents/07-devops/deployment-strategist.md` · `core/quality-gates.md`
- `checklists/pre-merge.md` · `knowledge/permanent-rules.md`
