# 06 — Data (the persisted truth)

The agents that design, protect and maintain the system's **persisted state** — the layer where
business invariants become non-negotiable because a violation **corrupts data**, not just an HTTP
response. The principle that runs through the whole category: **the database is the last line of
defense for integrity** — constraint in the DB, friendly guard in the application, one single
source of truth per fact (`knowledge/proven-patterns.md` §4–§5, `knowledge/origin-lessons.md` §B,§C).

## Phase(s) and when it enters

Dominant phase **F5–F6** (`core/lifecycle.md`), with a foot in F8–F9:

- **F5 (specification):** the `data-modeler.md` derives the **engine-agnostic logical model**
  (`templates/specification/logical-data-model.md.template`) from the business rules and the
  state machines — entities, relations, invariants — **without** choosing a DB engine. It is the
  *what* of the data.
- **F6 (build):** the logical model becomes the physical model; the `migration-engineer`
  materializes it in additive migrations; the `indexing-specialist` and the
  `db-performance-optimizer` tune the access; the `data-auditor` installs audit trails and
  provenance.
- **F8–F9 (launch and operation):** the `backup-specialist`, the `disaster-recovery-planner`
  and the `schema-versioning-manager` ensure the data survives failures and the environments do
  not diverge. `agents/13-guardians/backup-guardian.md` **operates** on cadence what these
  agents **designed**.

## Agents in this category

**Model and integrity**
- `agents/06-data/data-modeler.md` — engine-agnostic logical model → physical; invariants in the
  DB, bidirectional relations with a single source, seeds with relative dates.
- `agents/06-data/migration-engineer.md` — expand-contract migrations, always with a rollback
  plan; never drops/renames what is in use.
- `agents/06-data/schema-versioning-manager.md` — schema version, migration order, seeds per
  environment, convergent environments.

**Access performance**
- `agents/06-data/indexing-specialist.md` — indexes per real access pattern; write vs. read cost,
  partial and composite indexes.
- `agents/06-data/db-performance-optimizer.md` — slow-query diagnosis by execution plan,
  partitioning, configuration tuning.

**Trust and survival**
- `agents/06-data/data-auditor.md` — immutable audit trails, provenance of AI-touched data,
  retention and data quality.
- `agents/06-data/backup-specialist.md` — automatic backups, RPO per data class, **tested**
  restore (not presumed).
- `agents/06-data/disaster-recovery-planner.md` — system RTO/RPO, recovery runbooks, periodic
  catastrophic-loss drills.

## Recommended order of work

1. **Model first** (`data-modeler`) — derives entities, relations and invariants from the business
   rules (`agents/01-requirements/business-rules-modeler.md`); it is the input for everyone else.
2. **Materialization and versioning** (`migration-engineer` + `schema-versioning-manager`) —
   every schema change is a versioned, reversible additive migration.
3. **Access** (`indexing-specialist` → `db-performance-optimizer`) — indexes designed from the
   access patterns; the optimizer diagnoses what slipped through when slow queries appear.
4. **Trust** (`data-auditor`) — audit and provenance are not a final touch-up.
5. **Survival** (`backup-specialist` → `disaster-recovery-planner`) — backups are an input to the
   DR plan; DR covers the disaster the backup alone does not solve.

## How the Orchestrator convenes it

`core/orchestrator.md` builds the dependency graph from the **Inputs**/**Interactions** sections
of each agent spec. In F5 it calls only the `data-modeler`; in F6 it calls the rest per vertical
slice, coordinating **upstream** with `agents/01-requirements/` (rules and invariants) and
**downstream** with `agents/05-backend/` (which orchestrates writes in transactions —
`knowledge/origin-lessons.md` §C3/§C4). Transactional integrity and authorization live in the
backend; **structural integrity (constraints, keys, uniqueness) lives here** and is enforced by
the DB itself.

## Related

- `agents/05-backend/README.md` — who orchestrates the writes into the data this category models.
- `agents/08-infrastructure/README.md` — where the DB runs; storage, HA and **infra** backup (not
  data).
- `agents/13-guardians/backup-guardian.md` — operates on cadence the backups designed here.
- `modules/state-machines.md` · `modules/audit-and-provenance.md` · `modules/entity-lifecycle.md`
  — reusable capabilities the agents apply.
- `knowledge/proven-patterns.md` §4–§5 · `knowledge/origin-lessons.md` §B,§C — the patterns the
  category implements.
