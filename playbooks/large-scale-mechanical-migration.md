# Large-Scale Mechanical Migration

How to run a mechanical sweep that touches **many files/call-sites** at once — renaming a
concept, changing the shape of a contract/serialization, replacing a cross-cutting mechanism,
swapping a UI library — without breaking the branch midway. Distinct from
`playbooks/expand-contract-db-migration.md` (which is about schema and data): here the risk is the
**code** ending up half-migrated and observable. Executed by the agent of the layer in question
(frontend, backend, data), typically inside a slice of `workflows/W06-build.md`.

## Preconditions

- Final state decided; if it changes a contract or a closed decision, the specification/ADR is
  updated **first** (`core/decision-engine.md`).
- Gates green before starting (the baseline): without an initial green, there is no telling what
  the migration broke.
- A fast way to run all the gates (the sweep's correctness oracle).

## Steps

1. **Build the GUARD first.** A test/guardrail that *fails* while the migration is not complete
   and that catches reintroductions afterwards (e.g. an architecture/boundary test, a strict
   typecheck, a forbidden-pattern scanner). *Verified* by the guard **failing** in the current
   state. *If it does not fail*: the guard does not measure what matters — rewrite it before
   touching anything else.
2. **Public surface before the internal one.** Change what the outside sees first (the contract,
   the serialization, the route) and only then the internals — this avoids a half-migrated state
   *observable* by consumers.
3. **Sweep in an automatable but verified way.** Prefer mechanical transformations (script/codemod)
   with the gates as the oracle, over site-by-site manual editing — and run the gates **after each
   sweep**, not only at the end. *If one step breaks hundreds of tests*: an additive intermediate
   step is missing — it is not something to "fix at the end".
4. **Keep the gates green along the way.** The branch is never broken between steps. Each thematic
   phase is a revertible commit; the migration must be restartable (idempotence).
5. **Finish with the guard protecting.** Once the migration is done, the guard switches to
   defending against reintroduction of the old pattern and stays in CI — today's sweep is
   tomorrow's guardrail.

## Rollback

Revert by thematic phase. The guard ensures that a partial revert (one that reintroduces the old
pattern) is detected instead of slipping through unnoticed.

## Related

- `playbooks/expand-contract-db-migration.md` — the sibling for schema/data; many migrations use
  both.
- `checklists/pre-merge.md` — the gates kept green throughout the sweep.
- `checklists/pr-review.md` — the guard as a "test that fails without the change".
- `loops/L02-failing-tests.md` — fix the cause, never the detector, when the sweep goes red.
- `loops/L05-inconsistencies.md` — reconcile docs↔code↔data the migration may misalign.
