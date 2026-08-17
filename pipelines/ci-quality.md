# Quality CI

Pipeline that runs on **every push and pull/merge request**: it guarantees that only linted, typed,
tested and buildable code reaches the integration branch. It is the first gate — early, fast, always
green before merge (`knowledge/permanent-rules.md` §7). The concrete adapter (GitHub Actions,
GitLab CI, Azure DevOps) materializes it; see `agents/07-devops/github-actions-specialist.md` and
the sibling per-vendor agent specs.

## Principles

- **Frontend and backend in separate jobs/stages, both green.** One never masks the other; a red
  in either one blocks the merge (`knowledge/permanent-rules.md` §7).
- **Fast before exhaustive.** Lint and typecheck run first (seconds); heavier tests come after —
  fail early, without waiting minutes to discover a syntax error.
- **Cache keyed on the lockfile hash**, never on a fixed key — a fixed key hides outdated
  dependencies; the right key invalidates itself whenever the lockfile changes.
- **The build artifact is what gets promoted**, never code rebuilt in each environment
  (`agents/07-devops/deployment-strategist.md` rule 5) — this pipeline produces that artifact
  exactly once, immutable and versioned.
- **Generated-contract drift is a failure, not a warning.** A TypeScript client out of date with the
  OpenAPI (or equivalent) is the same class of bug as a red test — it blocks the same way.

## Stages

1. **Trigger** — every `push` to a branch and every *pull/merge request* opened or updated. It always
   runs; it is not optional based on diff size.
2. **Lint** — frontend and backend in separate jobs, each with only its own language/framework
   rules. Blocks the merge if either of the two fails.
3. **Typecheck** — when the stack is statically typed, a dedicated job per app. Blocks the merge.
4. **Unit and integration tests** — frontend and backend **always in distinct jobs**
   (`knowledge/permanent-rules.md` §7); integration tests use real services in containers
   (DB, queue) instead of mocks production does not have. Blocks if any job fails.
5. **Build** — compiles/packages each app; produces the immutable, versioned artifact (hash or tag)
   that `pipelines/cd-delivery.md` promotes later. Blocks if it does not compile.
6. **Generated-contract drift** — regenerates the derived artifact (e.g. client from the OpenAPI,
   types from a schema) and compares it with what is committed; any difference fails the job
   (`agents/05-backend/api-versioning-specialist.md`). Blocks the merge.
7. **Artifact publishing** — build, test and coverage reports stay attached to the run, versioned by
   commit/tag; it is what reviewers and `pipelines/cd-delivery.md` consume next.
   It does not block on its own, but it must run so the CD has something to promote.

## Cache

Cache key = lockfile hash, per app (frontend and backend with independent keys). Restores only
dependencies, never non-deterministic build artifacts or secrets. Lockfile changed → cache rebuilt
from scratch, never patched on top of the old one.

## What blocks the merge

| Stage | Blocks merge? |
| --- | --- |
| Lint (frontend / backend) | Yes |
| Typecheck (frontend / backend) | Yes |
| Unit/integration tests (frontend / backend) | Yes |
| Build | Yes |
| Generated-contract drift | Yes |
| Artifact publishing | Does not block — but it must run |

## Example (neutral pseudocode, illustrative)

```yaml
pipeline: ci-quality
triggers: [push, pull_request]
cache:
  key: hash(lockfile-per-app)
stages:
  - job: lint-frontend
    blocks_merge: true
  - job: lint-backend
    blocks_merge: true
  - job: typecheck-frontend
    blocks_merge: true
  - job: typecheck-backend
    blocks_merge: true
  - job: tests-frontend
    depends_on: [lint-frontend, typecheck-frontend]
    blocks_merge: true
  - job: tests-backend
    depends_on: [lint-backend, typecheck-backend]
    services: [test-db]
    blocks_merge: true
  - job: build
    depends_on: [tests-frontend, tests-backend]
    blocks_merge: true
    produces: immutable-artifact
  - job: contract-drift
    depends_on: [build]
    blocks_merge: true
```

## Related

- `pipelines/README.md` · `pipelines/ci-security.md` · `pipelines/cd-delivery.md`
- `checklists/pre-merge.md` · `knowledge/permanent-rules.md`
- `agents/07-devops/github-actions-specialist.md` · `agents/10-quality/test-strategist.md`
- `agents/05-backend/api-versioning-specialist.md`
