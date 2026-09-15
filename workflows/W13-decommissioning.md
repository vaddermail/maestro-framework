# W13 — Decommissioning (cross-cutting to F9: end of life of a product or a feature)

> **Trigger:** the user decides to **shut down a product** in production (F9) or **remove a
> feature that has data** · **Coordinates:** the Orchestrator, with
> `agents/09-security/security-coordinator.md` (security has a seat) and
> `agents/09-security/privacy-specialist.md` (personal data) · **Closing condition:** nothing
> connected, nothing paid, nothing personal outside legal retention — verified by whoever did not
> execute it and recorded in `product/99-records/gates/`.

## Objective

Take a product — or a feature — out of production in a way that is **reversible until the last
step**, with no orphaned data and no phantom costs. "F9 never ends" (`core/lifecycle.md` §Lifecycle
rules) is true while the product is alive; when the owner decides it no longer is, that moment
carries the highest risk of irreversibility and compliance failure of the whole lifecycle: personal
data retained with no legal basis, live secrets, infrastructure still billing, API partners with no
notice, backups expiring without a rehearsed restore. This workflow exists so the path is neither
"delete everything" (a mass destructive action with no item-by-item plan —
`knowledge/permanent-rules.md` §4) nor "leave it running." Do not confuse this with
`core/extensibility.md` §Deprecating, which covers retiring documents from the framework itself.

## Trigger and preconditions

- [ ] **Explicit request from the user** — never an inference by the agent ("nobody uses it
      anymore"). A product with no traffic is a signal for `agents/13-guardians/value-guardian.md`
      to bring to the user (`workflows/W09-continuous-operation.md` §Escalation), not a decision.
- [ ] `STATE.md` and `product/04-specification/` up to date: the step 2 inventory is checked
      against both the spec and reality, and the two have to match
      (`loops/L05-inconsistencies.md`).
- [ ] Personal data inventory (`product/05-security/personal-data-map.md`) and secrets inventory
      (`product/05-security/secrets-inventory.md`, with rotation in
      `product/07-operations/secrets/`) already exist — or are produced in step 2 before anything
      else.
- [ ] Open `product/99-records/evolutions/EV-nnn.md` with the raw request: decommissioning is the
      last request on a product in production and uses the same record as the others
      (`workflows/W10-feature-evolution.md`). It is the real-time log of everything being switched
      off.

## The principle: reversible until the last step — only the last step is not

The order of the steps is deliberate. Everything done up to step 4 undoes by switching off a flag;
step 5 is the sequence of irreversible actions, **each one** with item-by-item approval, and it
only starts once the final backup has been **restored** successfully — not "taken", restored
(`agents/06-data/backup-specialist.md`: a backup that has never been restored is a hope). A generic
"approve everything" covers the reversible items; the irreversible ones are requested one at a time
(`core/orchestrator.md` §Human approval).

## Steps (agent → artifact)

| # | Step | Agent | Artifact / action | Depends on |
| --- | --- | --- | --- | --- |
| 1 | **Decision and scope** | Orchestrator + user | Decommissioning ADR in `product/02-architecture/decisions/` (`templates/project/ADR-DECISION.md.template`): what dies (whole product / feature / module), why, the target date, what stays (legal archive, exports) and the reversal plan up to step 4; `EV-nnn.md` opened | request |
| 2 | **Inventory of what dies** (in parallel) | `agents/09-security/privacy-specialist.md` · `agents/05-backend/api-versioning-specialist.md` · `agents/07-devops/secrets-manager.md` · `agents/13-guardians/cost-guardian.md` · `agents/06-data/backup-specialist.md` | Privacy: destination of each processing activity in `product/05-security/personal-data-map.md` — delete, anonymize, retain under legal obligation (with a deadline and a legal basis), or portability to offer. API: identified consumers + `Deprecation`/`Sunset` plan with a deadline. Secrets: inventory in `product/07-operations/secrets/` with the revocation order (third-party credentials first). Costs: list of paid resources to shut down, with monthly cost and dependencies. Backups: **final backup restored** successfully in an isolated environment, RTO measured, record in `product/99-records/data/`. Consolidation: runbook `product/07-operations/runbooks/decommissioning.md` (`templates/technical/runbook.md.template`) with the order of the items, each marked **reversible** or **irreversible** | 1 |
| 3 | **Communication with a deadline** | Orchestrator | Who notifies whom, with how much notice and through which channel (table below); `Deprecation`/`Sunset` headers active on the API; record of the notices in `EV-nnn.md`. The deadline counts from the notice, not from the decision | 2 |
| 4 | **Read-only mode and export, behind a flag** | `agents/07-devops/feature-flags-specialist.md` + the backend specialist for the slice (`agents/05-backend/`) | Operational flag (kill-switch — `modules/feature-flags.md` §Non-negotiable rules) that blocks writes **on the server** (not just in the UI) and keeps reads and export/portability open until `Sunset`. Turning the flag off restores the product — it is the last fully reversible point. Live proof: a rejected write, a completed export | 3 |
| 5 | **Shut down in stages** | Orchestrator executes the runbook; each specialist from step 2 handles their item | By the runbook's order: revoke third-party credentials and integrations → shut down paid infrastructure (compute, domains, certificates, CDN, queues) → delete personal data outside retention (`agents/06-data/data-auditor.md` applies the policy) → archive encrypted, with an owner and a deletion date, whatever the law requires to be kept → close pipelines and access. **Every irreversible item: human approval item by item before, evidence after**, both in `EV-nnn.md` | 2 (backup restored), 4 |
| 6 | **Closure** | Orchestrator + `agents/06-data/data-auditor.md` (independent verification) | `STATE.md` §Situation header: phase "F9 — decommissioned on YYYY-MM-DD"; guardians deactivated in `CLAUDE.md` §F0 calibration; the auditor confirms no personal data remains outside legal retention and that what stays has an owner, a legal basis and a deletion date (record in `product/99-records/audits/`); gate record in `product/99-records/gates/W13-YYYY-MM-DD.md` (`templates/project/GATE.md.template`); end-of-life lessons in `FRAMEWORK-IMPROVEMENTS.md` and reported upstream (`playbooks/report-framework-improvements.md`) | 5 |

**Communication — minimum notice per recipient** (the user sets the values in step 1; these are
the minimums the Orchestrator proposes):

| Recipient | Notice | Channel and cadence |
| --- | --- | --- |
| End users with data in the product | ≥ 30 days before read-only; export available the whole period | in-product notice + email; reminder halfway through and the day before |
| API consumers / integrators | ≥ 90 days (or the contractual term, if longer) | `Deprecation`/`Sunset` headers + changelog + direct contact per partner |
| Internal stakeholders and whoever operates the product | at the decision (step 1) | per milestone: read-only, first shutdown, closure |
| Authorities/regulators, when regulation requires it | per the obligation | by `agents/09-security/privacy-specialist.md` |

### For a feature: the same in miniature via W10

Removing a feature that has data is an **evolution with a negative sign** and goes through
`workflows/W10-feature-evolution.md` with the rigor of a **medium or large** request (never
trivial): stage 1 (impact) = the step 2 inventory narrowed to the feature — what data only it
processed, what API consumers use it, what flags and secrets belong only to it; stage 2 (decision)
= ADR; stage 3 (spec) = the personal data map updated; stage 4 = **removal behind a flag** and, if
it touches data, the **contract** side of `playbooks/expand-contract-db-migration.md` (drop the
column/table only after the point of no return, with the backup restored first); the flag and both
code paths are removed at the end (`modules/feature-flags.md` §Non-negotiable rules, rule 8); stage
6 = release with a rehearsed rollback. Deleting personal data that only the feature processed is an
irreversible item of step 5 — item-by-item approval, same as for a whole product.

## Decision points (human approval)

The Orchestrator **stops and asks** (`core/orchestrator.md` §Human approval):

- **Step 1 — decommission?** It is scope and it is money (what stops being paid for and what
  closing costs): the decision belongs to the user and lands in an ADR. A product "nobody uses" is
  an input to the decision, not the decision.
- **Step 2 — destination of personal data.** Delete, anonymize or retain under legal obligation is
  a decision about personal data (item 6 of the approval list) and about legal risk: the privacy
  specialist proposes per processing activity, the user decides, the data auditor executes.
- **Step 3 — deadlines and commitments.** The `Sunset` date and the lead time of the notices are
  commitments with third parties; the user sets them.
- **Step 5 — every irreversible item, one at a time.** Revoking a shared credential, deleting a
  database, canceling a domain, dropping an archive: the Orchestrator presents the item, the
  effect, what stops being reversible and the evidence that the final backup was restored — and
  only executes with a "yes" for that item. Reversible items (turning off a flag, pausing a job)
  can go in a batch.
- **Backing out midway.** If the user wants to reverse the decision, up to step 4 it is just
  turning the flag off; from the first item of step 5 onward, what has already died only comes back
  through the restored backup — this is said before each item, not after.

Questions go in batches per step (`core/question-engine.md` §Batches); step 5 is the deliberate
exception — it is item by item by design.

## Loops it opens

- `loops/L05-inconsistencies.md` — the inventory is confirmed against **reality** (resources being
  billed, active credentials, consumers calling the API), not against the documentation; every
  divergence between spec/runbooks and what is actually connected is reconciled before step 5.
- `loops/L03-security-issues.md` — a secret that cannot be revoked, or a residual access to a
  third-party system, is a security finding with a severity, not a footnote.
- `loops/L08-technical-debt.md` — what stays archived under legal obligation is debt with an owner
  and a payment trigger (the deletion date): it is recorded in `STATE.md` §Debt, with the deadline,
  so it does not turn into eternal retention.

## Closing condition (this workflow's gate)

Decommissioning **closes** when, verified by whoever did not execute it (the Orchestrator for the
formal criteria; the data auditor and `agents/12-reviewers/backend-reviewer.md` for the substance —
`core/quality-gates.md` §Anatomy of a gate):

- [ ] Step 2 inventory with a **terminal state on every line**: switched off / revoked / deleted /
      archived with an owner and a deletion date / kept (with a why and an owner). No line "under
      review."
- [ ] Final backup **restored successfully before the first deletion**, with RTO measured and a
      record in `product/99-records/data/`.
- [ ] Every irreversible item of step 5 with human approval recorded (name, date, a short quote)
      and evidence of what happened (literal output, not "done"), in `EV-nnn.md`.
- [ ] No active paid resource (the cost guardian confirms it from the invoice, not the console); no
      live secret (the secrets manager confirms the revocation, credential by credential).
- [ ] API consumers notified with the deadline honored; `Sunset` past; no third-party traffic in
      the last days before shutdown.
- [ ] The data auditor confirms: no personal data remains outside legal retention; what stays has
      an owner, a legal basis and a deletion date; the retention policy was applied through a
      process reversible within the backup window.
- [ ] `STATE.md` phase "F9 — decommissioned on YYYY-MM-DD"; guardians deactivated in `CLAUDE.md`;
      gate record written in `product/99-records/gates/W13-YYYY-MM-DD.md`
      (`templates/project/GATE.md.template`); end-of-life lessons reported upstream.

**Who verifies:** whoever did not execute it. **Who approves:** the user — on every irreversible
item, not just at the end.

## Failure recovery

| Situation | Response |
| --- | --- |
| The final backup restore fails | **Nothing** gets deleted. Fix the backup strategy first (`agents/06-data/backup-specialist.md`); if no restore is possible, escalate to the user with the risk made explicit — deleting without a rehearsed restore is accepted data loss, their decision and recorded. |
| An API consumer shows up after `Sunset` | Read-only is still behind a flag: switching it back on temporarily is reversible. Renegotiate the deadline with the user; never "delete now, we already warned them." |
| A paid resource not inventoried turns up months later (phantom cost) | Shut it down via the platform specialist fixed in F3 (`agents/08-infrastructure/`) or `agents/07-devops/deployment-strategist.md`, with approval; `agents/13-guardians/cost-guardian.md` confirms it from the next invoice; the lesson goes into the runbook's inventory and, if the gap is the framework's, into `FRAMEWORK-IMPROVEMENTS.md`. |
| A legal retention obligation is discovered mid-step-5 | Stop the deletions. Privacy and the auditor reassess the map; whatever must stay goes into encrypted archive with an owner and a deadline; resume with the runbook updated and new item-by-item approval. |
| The user wants to go back after the first deletion | Only the restored final backup restores the state; what was revoked (credentials, domains) has to be recreated, it does not "un-revoke." The decision to reverse is a new ADR that supersedes the one from step 1. |
| Pressure to "close it today" by skipping step 4 | It does not get skipped: read-only is what makes the rest reversible and what gives users the export window. A closure with no window is a mass action with no plan (`knowledge/permanent-rules.md` §4). |

## Effort profiles

| Profile | How it changes |
| --- | --- |
| **Prototype** | Step 2 by the Orchestrator itself; no external communication if there were never real users; guardians were already deactivated. **If there was real data** (even test data about real people), the restored final backup and the personal data audit are still mandatory. |
| **Internal product** | Full inventory by the specialists; internal communication with a deadline; data export to users; legal archive with a named owner. |
| **Commercial product** | Contractual `Sunset`; portability to customers and confirmation of receipt; revocation of partner credentials with notice; communication by milestones; formal personal data audit; record of every irreversible item with a quote of the approval. |
| **Enterprise platform** | + processing register and DPIA closed by privacy; legal archive with explicit data residency; `workflows/W12-global-review.md` with scope "decommissioning inventory" before step 5; compliance signs off on the closure. |

## Related

- `workflows/W09-continuous-operation.md` — the operation this workflow exits from (§Escalation).
- `workflows/W10-feature-evolution.md` — the miniature for removing a feature; the `EV-nnn.md`
  record.
- `workflows/W11-incident-response.md` — the communication cadence this reuses.
- `core/orchestrator.md` §Human approval — destructive actions item by item; personal data; money.
- `modules/feature-flags.md` — read-only as a kill-switch, the last reversible point.
- `agents/06-data/backup-specialist.md` · `agents/06-data/data-auditor.md` — the rehearsed restore
  and the applied retention.
- `agents/09-security/privacy-specialist.md` · `agents/05-backend/api-versioning-specialist.md` ·
  `agents/07-devops/secrets-manager.md` · `agents/13-guardians/cost-guardian.md` — the owners of
  the inventory.
- `templates/project/GATE.md.template` — the closing gate's record.
