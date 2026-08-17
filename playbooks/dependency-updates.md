# Dependency Updates

Procedure for **deliberate** updates of libraries, frameworks and runtimes — never by drift, never
as a reflex to a bot. Executed by `agents/13-guardians/dependency-guardian.md` on a weekly
cadence (routine) and monthly (majors/EOL), or inside `workflows/W06-build.md` when a slice
needs a newer version. Majors with breaking changes always go up to the user.

## Preconditions

- Lockfiles/manifests in place, plus the truth of what is actually installed.
- Working regression harness, with frontend and backend separated. Without it, this playbook does
  **not update blindly**: it flags the gap to the Orchestrator and records it.
- `product/02-architecture/stack.md` with the target versions and support policy.

## Steps

1. **List outdated dependencies.** Compare lockfile/manifest against upstream; note the jump (patch/
   minor/major) and the support status (EOL?) of each one. *Verified* by manually reviewing the
   dependency tool's output — never accepted as-is. *If the list comes from an automated bot*:
   treat it as input to triage, never as a decision ready to merge.

2. **Prioritize.** EOL and deferred security majors first; then minors with useful fixes;
   trivial patches grouped into a light batch. *Verified* by each item having a written priority.

3. **Read the changelog of every relevant dependency — mandatory before any bump.** Look for
   breaking changes, removed/deprecated functions, silent behavior changes (e.g.:
   error mapping that changes without warning — `knowledge/ai-pitfalls.md` §16). *Verified* with
   a written summary of the changelog, not an impression. *If no changelog is accessible*: treat it
   as a risky major (goes up to the user) until proven otherwise.

4. **Group into a small, coherent batch.** One PR per dependency, or per cohesive group (e.g.: all
   the test libs of one area) — never an "update everything" in a single PR. *Verified* by the diff
   touching only lockfile + manifest + the strictly necessary adaptation code.

5. **Apply the bump and regenerate the lockfile.** Raise the version in the manifest; regenerate the
   lockfile deterministically. *Verified* by a lockfile rebuild giving the same result. *If the
   version does not end up pinned exactly*: fail the step — without a pinned version there is no
   deliberate update (`knowledge/permanent-rules.md` §6).

6. **Run the full harness.** Frontend and backend regression, separately, both green, plus the
   suite specific to what the dependency touches. *Verified* with the real output attached. *If it
   fails*: investigate the cause before blaming the dependency by reflex; if confirmed to be an
   undocumented breaking change, record it as a lesson.

7. **Live smoke test on the touched paths.** Exercise manually (or via harness) the real flows the
   dependency affects, in the target environment. *Verified* with concrete evidence (output/capture)
   — not "it should work".

8. **Decide majors with breaking changes.** Never by drift: write the plan (migration cost, gain,
   suggested window) and raise it to the user via `core/question-engine.md`. *Verified* by the
   explicit decision recorded before applying. *If the major reaches EOL with no replacement*:
   escalate as a future security risk, not as routine.

9. **Pin deliberately when not upgrading.** If the new version drops a feature in use, the decision
   is not to upgrade — record the why and a review deadline in `STATE.md` /
   `loops/L08-technical-debt.md`. *Verified* by the justification existing in writing, so it does
   not resurface as noise in the next cadence.

10. **Merge via green PR and document.** Cycle report in
    `product/99-records/guardians/dependencies-YYYY-MM-DD.md`
    (`templates/technical/guardian-report.md.template`); deferred/pinned debt recorded; non-obvious
    lessons in `STATE.md`.

## Rollback

Each bump is reversible via a surgical revert of the PR + the previous lockfile — that is why step 4
isolates each dependency or cohesive group in its own PR (a "general bump" that breaks something
forces manual bisection). Risky majors that change behavior go behind `modules/feature-flags.md`,
switchable off without a new deploy. A pinned dependency (step 9) is not a pending rollback — it is
a recorded decision with a review deadline, not an oversight.

## Related

- `agents/13-guardians/dependency-guardian.md` — who executes this playbook.
- `agents/13-guardians/security-guardian.md` — hands over the urgent fixes that require a major.
- `playbooks/cve-response.md` — when the update is an urgent security fix, not routine.
- `loops/L08-technical-debt.md` — where deferred/pinned version debt is reduced in a planned way.
- `checklists/pre-merge.md` — the gate common to every PR before integrating.
- `knowledge/permanent-rules.md` §6 · `knowledge/ai-pitfalls.md` §16.
