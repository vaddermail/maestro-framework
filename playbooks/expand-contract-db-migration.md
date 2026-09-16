# DB Migration — Expand-Contract

Procedure for schema changes in three separate phases: **expand** (additive), **migrate data and
code**, and only then **contract** (drop/rename the old) — never in the same step. Executed by
`agents/06-data/migration-engineer.md`, both inside a slice of `workflows/W06-build.md`
and alongside a release in `playbooks/release-and-rollback.md`. Each phase has a documented *down*;
the Contract phase only runs after an explicit **point of no return**.

## Preconditions

- Logical data model approved for the target state (`agents/06-data/data-modeler.md`).
- Working regression harness against the **real** DB engine (not a lightweight engine that
  serializes races production does not serialize — `knowledge/ai-pitfalls.md` §AR-15).
- `templates/technical/migration-plan.md.template` available to instantiate.

## Steps

1. **Write the migration plan** from `templates/technical/migration-plan.md.template`:
   current state, target state, the three phases, and each one's *down*. *Verified* by the plan
   existing as a file and covering the 3 phases with rollback described. *If there is no written
   plan*: no migration is applied — the plan is a precondition, not an after-the-fact formality.

2. **Expand phase — additive.** Create the new column/table/index without touching what is in use;
   the old schema keeps working unchanged. *Verified* by the old code, without any change, still
   passing the existing tests against the schema with the addition in place. *If it fails*: the
   change is not purely additive — fix it before moving on.

3. **Validate the Expand phase in isolation.** The type of a column referenced by a foreign key is
   read from the **oldest** environment (production), not from dev — an unsigned integer
   referenced by a wide integer fails only there; and where DDL is not transactional, the
   migration can leave the table created but unrecorded, with the second pass "passing" via a
   `hasTable` check — read the migration command's **entire** output: an exception at the end is
   red even with green tests right after. Apply in staging, run the full regression (frontend +
   backend), confirm zero impact on code not yet migrated. *Verified* with the harness green and the
   old application working without knowing the new thing exists.

4. **Deploy the Expand phase as its own release**, following `playbooks/release-and-rollback.md`
   (backup, hard-block, rehearsed rollback). *Verified* with a green release + live smoke.

5. **Migrate the data.** Backfill existing records into the new schema, in controlled batches — not
   a blind mass `UPDATE` (changes to sensitive data follow plan + list + per-item reason,
   `knowledge/permanent-rules.md` §4). *Verified* by the migrated row count matching the
   source, with a manually validated sample. *If the backfill fails midway*: it must be resumable
   and idempotent — never leave the schema in a mixed state without knowing exactly where it
   stopped.

6. **Migrate the code.** Update the application to read/write the new schema, keeping the ability
   to read the old one during the transition when needed (dual-read). *Verified* with tests that
   cover both paths — the new already written, the old still read by whoever has not migrated.

7. **Validate the constraints in two phases, with legacy data** (lesson C7,
   `knowledge/origin-lessons.md`). Apply new `CHECK`/`NOT NULL`/FK **only after** the backfill is
   confirmed — never before, or legacy data still to migrate gets rejected. *Verified* with a test
   that inserts the "old" row and confirms it passes before the constraint takes effect and fails
   after. Watch out for `NULL` vs `FALSE`: a `CHECK` only rejects on strict `FALSE` — `NULL` passes
   (lesson C8).

8. **Explicit point of no return.** Before contracting, confirm — with the user or an agreed
   objective criterion (e.g. N days without writes to the old schema) — that no consumer of the old
   one remains. *Verified* with the old path's access log/metric at zero during the agreed window.
   *If consumers remain* (another service, a report, an external integration): do not contract —
   one more iteration of step 6, or accept keeping both schemas for longer.

9. **Contract phase — only after the point of no return, in its own release.** Drop/rename the old
   column/table. *Verified* with green regression and zero references to the old schema in the
   code (confirmed by exhaustive search, not by memory). *If something still references the old
   one*: abort the contraction — it is not safe to proceed.

10. **Document.** Migration plan updated with each phase's outcome; lesson in `STATE.md` if
    anything surprised; the filled-in template archived in `product/` for future audit.

## Rollback

Each phase has a *down* documented in the step 1 plan. **Expand** is reverted by removing the new
column/table — no loss, because nothing in production depended on it yet. **Migrate data/code** is
reverted by returning the code to reading only the old schema (the old one was never touched until
the Contract phase, by design). **Contract** is the only phase with an expensive rollback (data
already dropped) — that is why it only runs after step 8's explicit point of no return; if a revert
is still needed after Contract, fall back to the corresponding release's verified backup
(`playbooks/release-and-rollback.md`), not to a schema *down* that no longer exists.

## Related

- `agents/06-data/migration-engineer.md` — who executes this playbook.
- `templates/technical/migration-plan.md.template` — the document instantiated in step 1.
- `playbooks/release-and-rollback.md` — each phase (Expand and Contract) is its own release.
- `knowledge/origin-lessons.md` C7, C8 — the origin lessons behind this discipline.
- `knowledge/permanent-rules.md` §3, §4 — reversibility and mass changes.
- `modules/state-machines.md` — when the migration accompanies a critical flow change.
