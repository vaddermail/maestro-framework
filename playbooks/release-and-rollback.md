# Release and Rollback

Procedure for putting a version into production with a safety net: a **verified** prior backup,
deploy, real post-deploy verification, and a **rehearsed** rollback — tested before it is needed,
never merely documented. Executed by `agents/07-devops/deployment-strategist.md`, both at the
initial go-live (`workflows/W08-launch.md`) and in any subsequent release. Going to production
always requires explicit human approval — never delegable to agents.

## Preconditions

- Matching quality/security gate clean (P7 at go-live; quality and security pipeline green on
  subsequent releases).
- Production secrets out of Git, injected at runtime (`playbooks/secrets-management.md`).
- If the release includes a schema change: written migration plan
  (`playbooks/expand-contract-db-migration.md`).

## Steps

1. **Confirm the gate preconditions.** `checklists/go-live.md` (first release) or green
   quality/security pipeline (subsequent releases). *Verified* by the completed checklist.
   *If it fails*: do not proceed — fix the missing phase first.

2. **Prior backup, verified.** Take a backup of the current state (DB + config + relevant assets)
   and confirm it is **restorable**, not just that it "ran without errors". *Verified* with a
   recent test restore (within the cadence of `agents/13-guardians/backup-guardian.md`) that proved
   it restores. *If there is no recent tested restore*: stop and test the restore first — an
   unverified backup does not count as a backup.

3. **Hard-block against the wrong infra.** Confirm the deploy target (environment, region, cluster)
   against the declared configuration, with an automatic check that refuses to apply on a mismatch.
   *Verified* by simulating a wrong target and confirming the pipeline aborts. *If the block does
   not exist or does not fire*: there is no release — it is a blocker, not a recommendation.

4. **Rehearse the rollback before the real deploy.** Run the rollback procedure in staging (or
   equivalent) and confirm it returns the system to the previous state. *Verified* when staging
   returns to the pre-deploy state with data intact and the service operational. *If the rehearsal
   fails*: the rollback is not ready — do not move on to the real deploy until it is fixed.

5. **If there is a DB migration, only the additive phase ships with this release.** Follow
   `playbooks/expand-contract-db-migration.md` — never drop/rename what is in use in the same
   release step.

6. **Explicit human approval.** Present the plan (what, risks, window, rollback already rehearsed)
   to the user and get approval recorded in `STATE.md` before applying to production. *Verified*
   by the written approval. This is never skipped, under any effort profile.

7. **Apply the deploy.** Following the chosen strategy (blue-green, canary or big-bang, per the
   profile and the lowest-impact window) with the rollback state from step 4 ready to trigger.
   *Verified* when the delivery pipeline finishes green.

8. **Post-deploy verification: real live smoke test.** Exercise the critical flows in the real
   production environment, not simulated. *Verified* with concrete evidence attached
   (output/screenshot). *If red*: trigger the step 4 rollback immediately — never "look at it
   tomorrow".

9. **Monitor the post-release window.** Alerts active, key metrics watched during the period
   defined by the effort profile. *Verified* by confirming active dashboards/alerts before
   declaring the release closed.

10. **Document.** Record in `STATE.md` (what, approval, smoke test result); runbook in
    `product/07-operations/runbooks/` updated if the procedure changed.

## Rollback

The rollback **is** the procedure rehearsed in step 4, never improvised on the spot: trigger the
prepared rollback state (previous version + configuration and, if needed, the restore of the step 2
backup), confirm with the same smoke test as step 8, and record the rollback in `STATE.md` with the
cause. A rollback must never require heroic manual data restoration — that is why any associated
schema migration follows expand-contract (step 5): the additive phase is always revertible without
loss, because nothing in production depended on it yet.

## Related

- `agents/07-devops/deployment-strategist.md` — who executes this playbook.
- `workflows/W08-launch.md` — the F8 phase where the first release runs.
- `checklists/go-live.md` — the P8 gate criteria.
- `playbooks/expand-contract-db-migration.md` — how to ship a release with a schema change.
- `agents/13-guardians/backup-guardian.md` — who keeps the backups tested.
- `core/quality-gates.md` — P8, human approval always.
- `modules/feature-flags.md` — risky changes switchable off without a new deploy.
