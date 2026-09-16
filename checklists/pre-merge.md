# Pre-Merge

Runs before any merge into the integration branch — the P6 gate evidence per slice
(`core/quality-gates.md`). It complements `checklists/pr-review.md` (the quality and correctness
of the code) with the state of the repository and the pipeline: without this green, nothing is
integrated.

## Automated quality

- [ ] Lint with no errors and no new warnings introduced by the change.
- [ ] Typecheck with no errors, on the frontend **and** the backend, run **separately**
      (`knowledge/permanent-rules.md` §7).
- [ ] Production build completes without errors.

## Tests

- [ ] Frontend tests run and pass, isolated from the backend
      (`agents/04-frontend/frontend-test-engineer.md`).
- [ ] Backend tests run and pass, isolated from the frontend.
- [ ] Tests cover the risk logic touched (business rules, authorization, reversibility) — not
      just the happy path.
- [ ] No test was disabled, deleted or weakened to "make it pass"; the cause was fixed,
      never the detector (`loops/L02-failing-tests.md`) — a diff that touches tests, CI or
      thresholds is reviewed by someone who did not write it (`knowledge/ai-pitfalls.md` §AR-22,
      manipulated gate).
- [ ] New or changed CI script, guard or scan: proven to **fail** on a real case (positive
      control), with the failure of any step in a pipeline propagating (in bash,
      `set -o pipefail`), and without discarding the exit code of the command that decides
      (`knowledge/ai-pitfalls.md` §AR-25).
- [ ] No test depends on the dev environment file; a default test runs with the variable
      **absent** (`knowledge/proven-patterns.md` §Production configuration); the suite never
      runs against the development DB (`agents/10-quality/README.md` §Duties shared by every
      agent in the category).

## Review

- [ ] Review done by someone who is not the author of the change — `checklists/pr-review.md`
      satisfied.
- [ ] Review findings resolved or explicitly accepted, with the why recorded.
- [ ] CI green measured **this** content: before merging, confirm through the hosting service
      (not the local disk) that the PR contains the commits and files the verdict claims to have
      proven — CI may have run before the last push, and a cherry-pick changes the SHA; the check
      is by content, not by color.

## Secrets and security

- [ ] Diff swept — no keys, passwords, tokens or credentials (`playbooks/secrets-management.md`).
- [ ] No local config/secret file (`.env` or equivalent) staged by mistake.
- [ ] New dependencies with no known critical/high CVE left unaddressed
      (`agents/09-security/dependency-analyst.md`).

## Reversibility

- [ ] The change has a clear reversal path: simple revert, flag, or migration with a down plan
      (`knowledge/permanent-rules.md` §3).
- [ ] DB schema change is additive (expand) or already in the planned contraction — never both
      in the same step (`playbooks/expand-contract-db-migration.md`).
- [ ] Risky change sits behind a flag/kill-switch when rollback by redeploy is slow
      (`modules/feature-flags.md`).

## Memory and documentation

- [ ] `STATE.md` updated with what changed.
- [ ] Documentation or user help synchronized, if the change affects visible behavior
      (`agents/11-documentation/user-help-writer.md`).
- [ ] `CHANGELOG.md` updated, if it is a milestone.

## Related

- `checklists/pr-review.md` — the code quality this gate presumes.
- `checklists/definition-of-done.md` — the definition of done per code change.
- `core/quality-gates.md` — the P6 gate this checklist evidences.
- `pipelines/ci-quality.md` — the automation that runs these items.
- `playbooks/secrets-management.md` — the secrets sweep detail.
- `knowledge/permanent-rules.md` — reversibility, tests and Git discipline.
