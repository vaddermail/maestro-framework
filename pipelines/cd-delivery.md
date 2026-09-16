# Delivery CD

Pipeline that takes the green artifact from `pipelines/ci-quality.md` — already filtered by
`pipelines/ci-security.md` — and carries it to production reversibly: promotion across
environments, backup before touching production, a release strategy with health criteria and
automatic *rollback* when those criteria fail. It executes the strategy defined by
`agents/07-devops/deployment-strategist.md`; materialized by
`agents/07-devops/github-actions-specialist.md` or equivalent vendor.

## Principles

- **The same artifact that passed CI is what gets promoted**, by hash/tag — it is never rebuilt per
  environment (`agents/07-devops/deployment-strategist.md` rule 5).
- **Never promote over red.** Without a green build from the quality CI and the security CI gate,
  the delivery pipeline does not start (`core/quality-gates.md`).
- **Backup/rollback state before any production deploy** — without a verified point of return,
  there is no promotion (`knowledge/permanent-rules.md` §3).
- **Production behind human approval, always.** Never automatic on merge, no matter how green the
  upstream pipeline is.
- **Hard-block against the wrong infra.** The pipeline confirms the target
  (environment/account/cluster/host) before any step touches it, and **aborts** if it does not
  match — a staging deploy that lands on production is the most expensive class of error.
- **Automatic rollback on an objective criterion**, defined before the release (error rate,
  latency, availability), never decided "by eye" during the incident.

## Stages

1. **Trigger** — a merge into the integration branch fires an automatic deploy to **dev**; a
   tag/release fires promotion to **staging**; promotion to **production** is always a manual
   approval step, never automatic on an event.
2. **Target confirmation (hard-block)** — before any action, the pipeline validates that the
   destination environment/account/cluster is the intended one; if it diverges, it aborts without
   touching anything.
3. **Deploy to dev** — automatic on every merge; disposable environment, no approval, fast feedback
   for whoever developed the change.
4. **Deploy to staging** — automatic after dev is healthy (or fired by a tag); mirrors production
   as closely as possible (data, configuration, topology) so the release holds no surprises later.
   Before this deploy, the suite also runs on a **production profile** against the exact commit
   (`knowledge/proven-patterns.md` §Production configuration) — the environment difference is
   proven there and against real staging, never by running the suite inside the server — in there
   it does not exercise the proxy or the secure transport, it writes errors to the real log the
   team reads, and it touches real external services.
5. **Production backup** — mandatory and **verified** before the first step that touches production
   (`agents/06-data/backup-specialist.md`, `agents/08-infrastructure/infra-backup-specialist.md`);
   without a confirmed backup, the pipeline does not advance.
6. **Human approval (production environment)** — manual gate with reviewers defined up front;
   records who approved and when, as part of the release evidence.
7. **Promotion with a release strategy** — recreate/rolling/blue-green/canary as decided by
   `agents/07-devops/deployment-strategist.md`; if there is a DB migration, it runs expand-contract
   coordinated with `agents/06-data/migration-engineer.md`
   (`playbooks/expand-contract-db-migration.md`).
   Before promoting, the pipeline **verifies the artifact's signature/attestation** against the
   expected build (the commit + pipeline that produced it — stage 9 of `pipelines/ci-security.md`);
   with no valid verification, it aborts as in stage 2's hard-block.
8. **Health checks against a pre-agreed criterion** — preceded by **warm-up** (a few disposable
   requests: freshly spawned processes, cold pools and caches read as a regression without it);
   the health script compares full SHAs (a short one is 7 characters on one side and 8 on the
   other), computes time windows in the application's timezone, and reads the day's log file by
   streaming, never a whole file into memory. Error/latency/availability observed over a
   defined window (e.g. 5–20 min of canary), never "it seems fine".
9. **Decision: promote to 100% or revert** — mechanical application of the objective criterion; if
   the health checks fail within the window, **automatic rollback** to the previous version,
   without waiting for human confirmation.
10. **Record** — version, decision and evidence written to the release/rollback runbook
    (`playbooks/release-and-rollback.md`) and to the product's `STATE.md`
    (`core/project-memory.md`); mandatory even when the release goes without incident.

## Example (neutral pseudocode, illustrative)

```yaml
pipeline: cd-delivery
triggers: [merge(integration), tag(release), manual_promotion(production)]
stages:
  - job: confirm-target
    hard_block: true
  - job: deploy-dev
    runs_on: [merge(integration)]
    depends_on: [confirm-target]
  - job: deploy-staging
    runs_on: [tag(release)]
    depends_on: [deploy-dev-healthy]
  - job: production-backup
    runs_on: [manual_promotion(production)]
    mandatory: true
  - job: production-approval
    type: human-gate
    depends_on: [production-backup]
  - job: promote-production
    strategy: canary
    depends_on: [production-approval]
    verifies: signed-attestation
    health_check:
      window: 20m
      criterion: error < 1%
  - job: decision
    if_healthy: promote_100
    otherwise: automatic_rollback
```

## Related

- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/ci-security.md`
- `playbooks/release-and-rollback.md` · `checklists/go-live.md` · `playbooks/expand-contract-db-migration.md`
- `agents/07-devops/deployment-strategist.md` · `agents/07-devops/github-actions-specialist.md`
- `agents/06-data/migration-engineer.md` · `agents/07-devops/feature-flags-specialist.md`
