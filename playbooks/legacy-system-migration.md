# Legacy System Migration

How to replace or extend a **system in use** — spreadsheets shared in an internal purchasing app,
an e-commerce's old store, the customers of a discontinued SaaS, the old warehouse of a data
platform — without losing the truth that already exists in production and without a go-live with
no way back. Distinct from `playbooks/expand-contract-db-migration.md` (the product's own schema)
and from `playbooks/large-scale-mechanical-migration.md` (code): here the risk is **data from
another system, with different quality and different owners**, entering a product that is not yet
the truth. Executed by `agents/06-data/migration-engineer.md` (import and cutover), with
`agents/00-discovery/existing-system-analyst.md` upstream (inventory, F1) and
`agents/06-data/data-auditor.md` on reconciliation — the Orchestrator coordinates, inside slices of
`workflows/W06-build.md` (import) and `workflows/W08-launch.md` (cutover).

## Preconditions

- `product/00-discovery/existing-system.md` **approved**: functional inventory in use, map of the
  data to migrate with volume, quality and owner, integrations to preserve, cutover constraints and
  what dies. Without it, F1 invents requirements "from scratch" for a domain that already has truth
  in production.
- The new product's approved logical data model (`product/04-specification/logical-data-model.md`)
  with the **field-by-field mapping** old → new, including what does **not** migrate and why — every
  field that gets dropped is a user decision, not an oversight.
- **Read-only** access to the current system and data, by file path or credential outside the
  repository (`knowledge/permanent-rules.md` §5). The current data is the **source of truth until
  cutover**; nobody "fixes it in passing".
- Staging with real DB parity (`knowledge/ai-pitfalls.md` §AR-15) and a way to produce an
  **anonymized** copy of the real data for the rehearsal (step 3).
- Strategy decided in an ADR (step 1) and a **reversal plan written before a cutover date exists**
  — without a reversal plan there is no date.

## Steps

1. **Choose the strategy and record it in an ADR** (`product/02-architecture/decisions/`,
   `templates/project/ADR-DECISION.md.template`), with alternatives compared, the reconciliation
   criterion (step 4) and the reversal plan:

   | Strategy | How | When it makes sense | What it costs |
   | --- | --- | --- | --- |
   | **Big-bang** | Single window: the old one freezes (read-only), everything gets imported, reconciled, and the new one opens. | Small volume, few integrators, an acceptable downtime window (e.g. an internal purchasing app replacing spreadsheets over a weekend). | All or nothing; rollback means going back to the old one, which stayed intact. |
   | **Phased** | By module, entity or user group; the old and the new coexist with an **explicit boundary** of who owns which data in each phase; each phase is a small cutover with its own reconciliation. | Large system, separable users (e.g. a SaaS absorbing the customers of a discontinued product, customer by customer). | Dual writes and integrations crossing the boundary — the boundary has to be written down and tested. |
   | **Parallel with reconciliation** | The two run simultaneously for a period; the old one stays the truth; the new one imports continuously and reconciles every day; the cutover is just "swap who is the truth". | Critical data — money, stock, billing (e.g. an e-commerce absorbing the catalog and orders of the old store). | Dual operation during the period; requires automated reconciliation from day one. |

   *Verify*: ADR approved with all three things — strategy, reconciliation criterion, reversal plan.
   *If it fails*: there is no cutover date; go back to the user with the options.
2. **Import with raw payload and provenance.** Every imported record keeps the **stable external
   ID**, `origin`, `importedAt` and the source's **raw payload**
   (`modules/readonly-external-integrations.md` §The model); the transformation into the new model
   is a pure, rerunnable function over the raw data; the write is an **upsert by external ID**,
   idempotent (`knowledge/proven-patterns.md` §2); the provenance marks each record as "imported
   from {system}" with batch correlation (`modules/audit-and-provenance.md` §The model), so what
   came from outside is always distinguishable from what was born in the new system. Rejections
   **do not abort the batch**: they land in a rejection log with the reason, to be reprocessed —
   never "fixed by hand" in the destination. New constraints on legacy data in two phases
   (`agents/06-data/migration-engineer.md` §Rules). *Verify*: importing the same batch twice does
   not duplicate; any migrated record can be rebuilt from the raw data; the rejection count has
   reasons. *If it fails*: fix the transformation and rerun it over the raw data — never edit the
   result by hand.
3. **Rehearse the cutover in staging with anonymized real data.** Copy the current data to staging;
   anonymize PII **consistently** (the same real value always yields the same fake value, so
   relations stay intact); external effects in null mode — emails, SMS, webhooks never go out to
   the world (the discipline of `playbooks/demo-data.md`); run the full import, time it (that is
   the cutover's RTO), run the reconciliation (step 4) and **rehearse the rollback**. Repeat until
   it passes **without manual intervention**. *Verify*: the rehearsal report in
   `product/99-records/data/cutover-rehearsal-YYYY-MM-DD.md` with time, rejections, green
   reconciliation and a rehearsed rollback. *If it fails*: there is no cutover date — an "almost"
   rehearsal does not count.
4. **Define and run the reconciliation criterion.** Per migrated entity: **counts** (origin =
   destination + rejections — the sum must balance), **checksums** on the money and quantity
   fields, a **random sample** compared field by field against the origin, and the new model's
   **invariants** (`product/04-specification/logical-data-model.md`) verified against the migrated
   data. **Zero** tolerance on correction entities, money, personal data and irreversible flows
   (`MANIFESTO.md` §9); explicit, numeric tolerance signed off by the user on the rest. Run and
   sign off by `agents/06-data/data-auditor.md` — never whoever wrote the import
   (`core/quality-gates.md` §Anatomy of a gate). *Verify*: reconciliation report with numbers and
   every difference explained line by line. *If it fails*: go back to step 2.
5. **Cutover in production.** Only with: green rehearsal, green reconciliation in staging,
   rehearsed rollback, deadline communication to users and integrators, and **explicit human
   approval** (P8 — `core/orchestrator.md` §Human approval). Sequence: freeze the old one
   (read-only, announced) → the old one's restored backup rehearsed → final import (the delta since
   the last batch, in the phased and parallel strategies) → production reconciliation (step 4) →
   open the new one → **real live proof** of the critical flows with migrated data → integrations
   to preserve verified one by one. The release itself follows
   `playbooks/release-and-rollback.md`. *Verify*: cutover record in
   `product/99-records/data/cutover-YYYY-MM-DD.md` with the reconciliation, the live proof and the
   time of each step. *If it fails*: Rollback (below) **before** diagnosing.
6. **Coexistence window: the old one stays alive and readable for N days.** N is decided in the
   ADR — the typical choice is **one full business cycle** (a monthly close, a sales season, a
   billing cycle). During the N days the old one accepts no writes but stays accessible for
   reading and remains the source of the rollback; the new one is the truth; the user confirms the
   real flows ran on the new one (`agents/13-guardians/value-guardian.md` reads the KPIs if the
   product is already in F9). *Verify*: end date of N in `STATE.md` §Up next; no user nor integration
   writing to the old one (from the logs, not by assumption).
7. **Decommission the old one as its own slice.** Never on cutover day: it is a slice of
   `workflows/W06-build.md` (or of `workflows/W10-feature-evolution.md`, if the product is already
   in F9) with its own gate — or, if the old one is an entire product,
   `workflows/W13-decommissioning.md` with its own inventory. Final restored backup of the old one
   before shutting it down; encrypted export or archive, with an owner and a deletion date, of
   what the law requires retaining; revocation of the old integrations' credentials; costs shut
   off. The raw payload kept in step 2 is what lets the migration be audited after the old one
   disappears. *Verify*: no resource of the old one still billing; no credential of the old one
   alive; the slice's gate record written.

## Rollback

- **Up to cutover:** there is nothing to roll back — the old one is the truth; discard the
  destination and reimport (the import is idempotent by design).
- **During the N days:** rolling back means **restoring the old one as the truth**: reopen writes
  on the old one; export the **delta** written to the new one since cutover and reintroduce it into
  the old one — this is why the provenance distinguishes "imported" from "born in the new one" and
  the audit trail keeps the before and the after — or accept the loss of that delta by an explicit,
  recorded user decision; communicate with whoever was notified of the cutover. It must have been
  **rehearsed in step 3**; a rollback never rehearsed is a hope, not a plan.
- **After N days or after decommissioning:** there is no longer a cheap rollback — only the old
  one's final restored backup, and the new one's delta is lost or reintroduced by hand. That is
  why N is a user decision and decommissioning is its own slice with its own gate, never a step of
  the cutover.

## Related

- `agents/00-discovery/existing-system-analyst.md` — who writes the F1 inventory this playbook
  assumes.
- `agents/06-data/migration-engineer.md` · `agents/06-data/data-auditor.md` ·
  `agents/06-data/backup-specialist.md` — import, reconciliation, restore.
- `modules/readonly-external-integrations.md` · `modules/audit-and-provenance.md` — raw payload,
  external ID, provenance.
- `playbooks/demo-data.md` — the PII and external-send discipline the rehearsal reuses.
- `playbooks/expand-contract-db-migration.md` · `playbooks/release-and-rollback.md` — the schema
  and the release of the cutover.
- `workflows/W13-decommissioning.md` — when the old one is an entire product to retire.
- `core/orchestrator.md` §Human approval — the cutover is production; the lost delta is a user
  decision.
