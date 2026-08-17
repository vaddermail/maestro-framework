# Demo Data

How to create and maintain demonstration data — to explore the product, show it to a
client/stakeholder, or populate an analysis environment. Demo data is **code that rots with the
schema**: it breaks silently when the model changes (an event, an invariant or a field the seed
depended on stops existing), and it is a risk when confused with real data. Executed by
`agents/06-data/migration-engineer.md` or by the data agent of the module in question, within a
slice of `workflows/W06-build.md` or as preparation for a demonstration.

## Preconditions

- Schema/migrations at the target state (the seed runs against the current model, not an old one).
- A reproducible way to run seeds/fixtures (single command).
- Clear separation between demo data and real data — a dedicated environment, or a guard that
  prevents the seed from running over production data.

## Steps

1. **Write the seed idempotent and guarded.** It runs twice without duplicating and does not
   collide with existing data (guard by marker or by count). *Verified* by running it twice and
   confirming it does not duplicate. *If it fails*: add the guard — a seed that duplicates is not
   reproducible.
2. **Fictional data only — never real PII or secrets.** Names, contacts and addresses are made up.
   External effects the seed may trigger (e-mails, SMS, webhooks to the demo contacts) run with
   the transport in null/log mode, **never sending to the world** — demo addresses generate
   *bounces* and tarnish the domain's reputation. *Verified* that no real delivery goes out to
   demo addresses. *If it fails*: force the null transport during the seed.
3. **Cover the breadth of the product, not the happy path.** The value of a demo is showing all
   the states and flows the observer should see (edge cases, error states, history), not one row
   of each.
4. **Smoke test in CI that runs the seed against a fresh schema.** It is the only defense against
   the seed rotting unnoticed. *Verified* by the green CI job. *If it fails*: fix the seed like
   any code — the failure is real (the product changed underneath the seed).
5. **Keep demo and real separate to the end.** The demo seed **never** enters the production seed
   by default. Before an environment goes into real use, clean out the demo and start with true
   data — record that transition in `STATE.md`.

## Rollback

Delete the demo data by the marker that identifies it, or recreate the database from the
migrations. In an environment about to go to production, cleaning out the demo is mandatory, not
optional.

## Related

- `workflows/W06-build.md` — where the seeds are born, alongside the slices.
- `checklists/pre-merge.md` — the gate the seed's smoke test reinforces.
- `playbooks/secrets-management.md` — why there is never real PII/secrets in demo data.
- `agents/06-data/migration-engineer.md` — typical owner of the seeds and fixtures.
- `agents/10-quality/integration-test-engineer.md` — the smoke test that stops the rot.
