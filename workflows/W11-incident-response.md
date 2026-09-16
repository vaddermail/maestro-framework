# W11 — Incident Response (cross-cutting to F9)

> **Trigger:** something in production is failing or putting data at risk **now** · **Coordinates:**
> the Orchestrator (with `agents/09-security/security-coordinator.md` if it is a security
> incident) · **Closing condition:** `checklists/post-incident.md` complete.

## Objective

Contain a production incident with minimal damage and nothing hidden: **mitigate first, diagnose
later**, communicate with honesty and cadence, fix the cause and learn without hunting for
culprits. It is not a phase gate — it is a cross-cutting procedure that can fire at any moment
during operation (`workflows/W09-continuous-operation.md`). **Reversibility is the first weapon**
(`knowledge/permanent-rules.md` §3): almost every incident is softened by switching
off a recent change before understanding the cause.

## Trigger and preconditions

- [ ] Incident signal: an alert from a guardian (`agents/13-guardians/README.md`), an error
      reported by a user, observed degradation, or suspicion of a leak/unauthorized access.
- [ ] A rollback and/or flags exist for the suspect change (`playbooks/release-and-rollback.md`,
      `modules/feature-flags.md`) — if they do not, that is the post-mortem's first lesson.
- [ ] Open `product/99-records/incidents/INC-nnn.md` **immediately** and record in real time: the
      incident log is the source of truth, not memory.

## The principle: mitigate first, diagnose later

The order is deliberate and does not invert under pressure:

1. **Stopping the bleeding** (mitigation) comes before **understanding the cause** (diagnosis).
   A rollback or kill-switch cuts the damage in minutes; the root cause can take hours.
   Diagnosing while production bleeds trades real damage for curiosity.
2. **Absolute honesty in the report** (`knowledge/permanent-rules.md` §2):
   communicate what is known, what is not known and what is being done. Never minimize, never
   invent a cause before confirming it.
3. **Reverting is not admitting defeat** — it is the correct response. Diagnosis is done on the
   already stabilized system (or on a replica), not on the users.

## Steps (incident phase → agent → artifact)

| # | Phase | Agent | Artifact / action | Depends on |
| --- | --- | --- | --- | --- |
| 1 | **Triage** | Orchestrator (+ the guardian that detected it) | `INC-nnn.md` §triage: **severity** (table below), **scope** (which service/module), **affected data** (personal data? corrupted? exposed?) | signal |
| 2 | **Immediate mitigation** | `agents/07-devops/deployment-strategist.md` (rollback) · `agents/07-devops/feature-flags-specialist.md` (kill-switch) | suspect change reverted/switched off; service stabilized; timestamp in the log | 1 |
| 3 | **Data assessment** (if §affected data ≠ none) | `agents/06-data/data-auditor.md` (+ `security-coordinator` if a leak) | extent of the data damage: records touched, provenance, restore needed (`agents/06-data/backup-specialist.md`) | 1 |
| 4 | **Communication** | Orchestrator | who informs whom, at what cadence (table below); notices recorded in `INC-nnn.md` | 1 (starts in parallel with 2) |
| 5 | **Definitive fix** | build team via `workflows/W10-feature-evolution.md` (fix slice) | root cause fixed with a test that **reproduces** the incident before closing it | 2, diagnosis |
| 6 | **Blameless post-mortem** | Orchestrator + `agents/11-documentation/technical-writer.md` | `product/99-records/incidents/INC-nnn-postmortem.md` (`templates/technical/post-mortem.md.template`) | 5 |

**Triage — severity** (what dictates the cadence and who gets woken up):

| Sev | Criterion | Multi-domain example |
| --- | --- | --- |
| **SEV1** | Unavailable, or user data at risk/exposed | E-commerce checkout down; broken scoping in a SaaS shows one customer's data to another. |
| **SEV2** | Core functionality degraded, with a workaround | Data pipeline hours behind; reports failing but reads OK. |
| **SEV3** | Localized failure, limited impact | One filter returns an error; a secondary screen broken. |
| **SEV4** | Cosmetic / no functional impact | Wrong label, missing icon. |

## Decision points (human approval)

- **Low-risk mitigation does not wait for approval:** reverting to a known-good state and firing
  kill-switches are reversible actions within a runbook — do them now (`core/quality-gates.md`
  §Human approval matrix — never need a human: refactors/reversible actions). Stopping to ask for
  authorization while bleeding is the mistake.
- **Goes up to the human, always:** any **destructive or irreversible** action in the mitigation
  (deleting data, restoring a backup over new data —
  `agents/06-data/disaster-recovery-planner.md`); **notifying customers/regulators** of a personal
  data leak; accepting residual risk when reopening the service before the root cause is closed.
- **Communication — cadence by severity:** SEV1 → update the user/stakeholders every 30–60 min
  until stable; SEV2 → per milestone; SEV3/4 → at closure. The Orchestrator communicates; the
  recipients (product owner, affected users, security) are defined at triage.

## Loops it opens

- `loops/L03-security-issues.md` — if it is a security incident, it is resolved by severity and
  the `security-coordinator` steps in as risk owner.
- `loops/L07-cves.md` / `playbooks/cve-response.md` — if the cause is a dependency vulnerability.
- `loops/L08-technical-debt.md` — post-mortem preventive actions not done right away enter as
  traceable debt, with an owner and a deadline (never "we'll be careful next time").

## Closing condition (this workflow's gate)

The incident **closes** when `checklists/post-incident.md` is complete:

- [ ] Service stable and **verified** (live proof, not assumption); temporary mitigation replaced
      by the definitive fix (step 5) **or** the fix is scheduled with an owner and the mitigation
      is safe.
- [ ] A regression test that **reproduces** the incident added and green (`agents/10-quality/`).
- [ ] Data assessed: restored/reconciled, or confirmed undamaged
      (`agents/06-data/data-auditor.md`).
- [ ] **Blameless post-mortem** written: timeline, root cause, what went well, preventive actions
      with an owner and a deadline (`templates/technical/post-mortem.md.template`). Focus on the
      system, not the people.
- [ ] `STATE.md` updated; non-obvious lessons recorded (`core/project-memory.md`).

## Failure recovery (the incident inside the incident)

A blocked operator is an incident of its own: a responding ping with every port timing out means a
blocked path, not a dead machine — confirm from a third point of view before any restart
(`checklists/go-live.md` §Target reconnaissance and environment pre-flight).

| Situation | Response |
| --- | --- |
| No rollback or flag for the suspect change | Mitigate by whatever means available (isolate the service, degrade gracefully); **1st preventive action of the post-mortem:** make that change reversible. |
| The rollback fails too | Escalate to DR (`agents/06-data/disaster-recovery-planner.md`); call in the human owner — never improvise destructively under panic. |
| Root cause not found after mitigation | Stay mitigated; diagnose unhurried on a replica; do not reopen the broken path "to see if it happens again" in production. |
| Pressure to close without a post-mortem | It does not close: the post-mortem is what prevents repetition (`knowledge/permanent-rules.md`). SEV3/4 may have a short post-mortem; have one they must. |

## Related

- `checklists/post-incident.md` — the detailed closing condition.
- `templates/technical/post-mortem.md.template` — the blameless post-mortem template.
- `playbooks/release-and-rollback.md` · `modules/feature-flags.md` — the mitigation weapons.
- `workflows/W10-feature-evolution.md` — the path of the definitive fix.
- `workflows/W09-continuous-operation.md` — the operation the incident emerges from.
- `agents/13-guardians/README.md` — the guardians that detect early.
