# Playbooks — step-by-step procedures

A **playbook** is the operating procedure for **one** recurring, risky operation, at the level of
detail where any agent or human can follow it without inventing steps: applying a security patch,
updating a dependency, cutting a release, migrating a DB schema, managing a secret, growing the
team, extending the framework, running an audit. Where a workflow (`workflows/README.md`)
coordinates **several agents across an entire phase** of the lifecycle, a playbook is typically
executed by **one** agent (or by the human) — it is the framework's finest, most verifiable unit
of execution: each step says what it does, how to confirm it worked, and what to do if it fails.

## When it runs

- **Inside a workflow**, as the "how" of one of its steps — e.g. `workflows/W08-launch.md`
  step 6 runs `playbooks/release-and-rollback.md`.
- **On an event**, outside any phase — e.g. a published CVE triggers
  `playbooks/cve-response.md`.
- **On a cadence**, as the body of a guardian's work (`agents/13-guardians/README.md`) — e.g.
  the weekly sweep of `agents/13-guardians/dependency-guardian.md` runs
  `playbooks/dependency-updates.md`.

A playbook **does not decide** scope or architecture — that was already decided upstream (spec, ADR,
the workflow that invokes it). The playbook takes the decision as given and executes it with
discipline.

## Common skeleton of a playbook

All playbooks (except this README) follow this structure, in this order:

| Section | What it answers |
| --- | --- |
| `# Title · context line` | What it is, when it runs, who executes it (human, agent, or both) |
| `## Preconditions` | What must exist/be true before the first step |
| `## Steps` | Numbered, executable: what it does → how to verify → what to do if it fails |
| `## Rollback` | How to undo, when applicable (`knowledge/permanent-rules.md` §3) |
| `## Related` | 3–8 paths that exist in `_meta/INVENTORY.md` |

An **optional** context/framing section may come before the Preconditions
(`playbooks/adversarial-audit.md` uses one); the four mandatory sections and their order
remain.

## The framework's playbooks

| Playbook | What it covers |
| --- | --- |
| `playbooks/cve-response.md` | From CVE notification to a validated, documented patch. |
| `playbooks/dependency-updates.md` | Deliberate updating: changelog, tests, lockfile, never by drift. |
| `playbooks/release-and-rollback.md` | Release with prior backup, verification and a rehearsed rollback. |
| `playbooks/expand-contract-db-migration.md` | Additive migration → migrate data/code → contract; never break what is in use. |
| `playbooks/secrets-management.md` | Secrets out of Git, by file path, rotation and leak response. |
| `playbooks/developer-onboarding.md` | A new hands-on contributor with one command (setup + kickoff protocol). |
| `playbooks/add-an-agent.md` | Extending the framework: template → agent spec → indexes → inventory, without touching the existing ones. |
| `playbooks/adversarial-audit.md` | Extensive, adversarial, multidisciplinary audit with independent verification of findings. |
| `playbooks/sync-framework.md` | Bringing a project's copy of the framework to a newer version, deliberately and with rollback. |
| `playbooks/report-framework-improvements.md` | The project's side of the learning circuit: consolidate `FRAMEWORK-IMPROVEMENTS.md` and send it upstream as an issue, sanitized. |
| `playbooks/framework-curation.md` | The upstream side: triage reports, manage `knowledge/candidates.md` and propose promotions by PR — never a direct commit. |
| `playbooks/demo-data.md` | Demo data as code: idempotent, no real PII, outbound delivery in null mode, smoke test in CI, kept apart from real data. |
| `playbooks/large-scale-mechanical-migration.md` | Sweeping many files/call sites without breaking the branch: guard first, public surface before internal, gates green throughout. |
| `playbooks/change-effort-profile.md` | A prototype that becomes a product (or any profile upgrade): record it, list what the old profile waived, snapshot with W12, and run the missing gates in phase order. |
| `playbooks/legacy-system-migration.md` | Replacing or extending a system in use: strategy (big-bang / phased / parallel), import with raw payload and provenance, cutover rehearsal in staging, reconciliation, rollback with the old system alive for N days, decommissioning as its own slice. |

## Related

- `workflows/README.md` — the difference between coordinating a phase and executing a procedure.
- `core/quality-gates.md` — the gates many playbooks close (P6, P8).
- `checklists/README.md` — the checklists the verification steps consult.
- `knowledge/permanent-rules.md` — the principles (reversibility, honesty, mass changes)
  that every playbook operationalizes.
- `agents/13-guardians/README.md` — who executes the cadence playbooks.
